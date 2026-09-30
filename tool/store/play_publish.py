#!/usr/bin/env python3
"""Publishes to Google Play with the Play Developer API (no extra packages
beyond `requests`; signs the service account token with the openssl CLI).

    export PLAY_SERVICE_ACCOUNT=/path/to/service-account.json   # never commit it
    python3 tool/store/play_publish.py listing              # text + graphics
    python3 tool/store/play_publish.py bundle app.aab [--track production] [--status draft]

The service account needs access to the app in Play Console (Users and
permissions). `listing` uploads docs/store/play/listing_en-US.json, the icon,
the feature graphic and docs/store/screenshots/android_*.jpg. `bundle` uploads
a signed .aab and puts it on a track; apps that haven't been published yet
only accept `--status draft` (send it for review in Play Console).
"""
import argparse
import base64
import glob
import json
import os
import subprocess
import sys
import tempfile
import time

import requests

PACKAGE = 'com.floppyswing.floppy_swing'
API = f'https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{PACKAGE}'
UPLOAD = f'https://androidpublisher.googleapis.com/upload/androidpublisher/v3/applications/{PACKAGE}'
ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
PLAY = os.path.join(ROOT, 'docs', 'store', 'play')
LANG = 'en-US'


def _b64(b):
    return base64.urlsafe_b64encode(b).rstrip(b'=')


def session():
    path = os.environ.get('PLAY_SERVICE_ACCOUNT')
    if not path:
        sys.exit('Set PLAY_SERVICE_ACCOUNT to the service account JSON file.')
    sa = json.load(open(path))
    now = int(time.time())
    head = _b64(json.dumps({'alg': 'RS256', 'typ': 'JWT'}).encode())
    claims = _b64(json.dumps({
        'iss': sa['client_email'], 'scope': 'https://www.googleapis.com/auth/androidpublisher',
        'aud': sa['token_uri'], 'iat': now, 'exp': now + 3600}).encode())
    fd, key = tempfile.mkstemp()
    try:
        os.write(fd, sa['private_key'].encode())
        os.close(fd)
        sig = subprocess.run(['openssl', 'dgst', '-sha256', '-sign', key], input=head + b'.' + claims,
                             capture_output=True, check=True).stdout
    finally:
        os.remove(key)
    r = requests.post(sa['token_uri'], data={
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion': (head + b'.' + claims + b'.' + _b64(sig)).decode()})
    r.raise_for_status()
    s = requests.Session()
    s.headers['Authorization'] = 'Bearer ' + r.json()['access_token']
    return s


def check(r):
    if not r.ok:
        sys.exit(f'{r.request.method} {r.url.split("?")[0]} -> {r.status_code}\n{r.text}')
    return r.json() if r.content else {}


class Edit:
    def __init__(self, s):
        self.s = s
        self.id = check(s.post(f'{API}/edits'))['id']
        self.url = f'{API}/edits/{self.id}'
        self.upload = f'{UPLOAD}/edits/{self.id}'

    def commit(self, not_for_review=False):
        q = '?changesNotSentForReview=true' if not_for_review else ''
        return check(self.s.post(f'{self.url}:commit{q}'))

    def abort(self):
        self.s.delete(self.url)


def listing(s):
    e = Edit(s)
    try:
        text = json.load(open(os.path.join(PLAY, f'listing_{LANG}.json')))
        check(e.s.put(f'{e.url}/listings/{LANG}', json={'language': LANG, **text}))
        print('listing text:', text['title'])
        images = {
            'icon': [os.path.join(PLAY, 'icon_512.png')],
            'featureGraphic': [os.path.join(PLAY, 'feature_graphic.png')],
            'phoneScreenshots': sorted(glob.glob(os.path.join(ROOT, 'docs', 'store', 'screenshots', 'android_*.jpg'))),
        }
        for kind, files in images.items():
            check(e.s.delete(f'{e.url}/listings/{LANG}/{kind}'))
            for f in files:
                mime = 'image/png' if f.endswith('.png') else 'image/jpeg'
                with open(f, 'rb') as fh:
                    check(e.s.post(f'{e.upload}/listings/{LANG}/{kind}?uploadType=media', data=fh.read(),
                                   headers={'Content-Type': mime}))
                print(f'{kind}: {os.path.basename(f)}')
        e.commit()
        print('listing committed')
    except SystemExit:
        e.abort()
        raise


def bundle(s, aab, track, status, notes):
    e = Edit(s)
    try:
        with open(aab, 'rb') as fh:
            up = check(e.s.post(f'{e.upload}/bundles?uploadType=media', data=fh.read(),
                                headers={'Content-Type': 'application/octet-stream'}, timeout=600))
        code = up['versionCode']
        print('uploaded bundle, version code', code)
        release = {'versionCodes': [str(code)], 'status': status}
        if notes:
            release['releaseNotes'] = [{'language': LANG, 'text': notes}]
        check(e.s.put(f'{e.url}/tracks/{track}', json={'track': track, 'releases': [release]}))
        e.commit()
        print(f'{track}: version {code} ({status})')
    except SystemExit:
        e.abort()
        raise


def main():
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest='cmd', required=True)
    sub.add_parser('listing')
    b = sub.add_parser('bundle')
    b.add_argument('aab')
    b.add_argument('--track', default='production')
    b.add_argument('--status', default='draft', choices=['draft', 'completed', 'inProgress', 'halted'])
    b.add_argument('--notes', default='')
    a = p.parse_args()
    s = session()
    if a.cmd == 'listing':
        listing(s)
    else:
        bundle(s, a.aab, a.track, a.status, a.notes)


if __name__ == '__main__':
    main()
