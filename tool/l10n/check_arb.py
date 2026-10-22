#!/usr/bin/env python3
"""Checks the translations in lib/l10n/ against the English template:
every key present and nothing extra, the same {placeholders}, plural
messages with an `other` case, and capitals where English uses capitals.

    python3 tool/l10n/check_arb.py
"""
import glob
import json
import os
import re
import sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
L10N = os.path.join(ROOT, 'lib', 'l10n')


def placeholders(text):
    # Placeholder names, ignoring plural keywords and case selectors.
    return set(re.findall(r'\{(\w+)(?=[,}])', text))


def letters(text):
    # Text outside {placeholders} and plural syntax.
    return re.sub(r'\{\w+(, plural,)?|(=\d+|zero|one|two|few|many|other)\{|\}', ' ', text)


def main():
    en = json.load(open(os.path.join(L10N, 'app_en.arb')))
    keys = [k for k in en if not k.startswith('@')]
    errors = []
    for path in sorted(glob.glob(os.path.join(L10N, 'app_*.arb'))):
        lang = os.path.basename(path)[4:-4]
        if lang == 'en':
            continue
        arb = json.load(open(path))
        if arb.get('@@locale') != lang:
            errors.append(f'{lang}: @@locale is {arb.get("@@locale")}')
        have = [k for k in arb if not k.startswith('@')]
        for k in sorted(set(keys) - set(have)):
            errors.append(f'{lang}: missing {k}')
        for k in sorted(set(have) - set(keys)):
            errors.append(f'{lang}: unknown {k}')
        for k in keys:
            if k not in arb:
                continue
            t, e = arb[k], en[k]
            if not t.strip():
                errors.append(f'{lang}.{k}: empty')
            if placeholders(t) != placeholders(e):
                errors.append(f'{lang}.{k}: placeholders {sorted(placeholders(t))} != {sorted(placeholders(e))}')
            if ', plural,' in e and ', plural,' not in t and placeholders(e) - placeholders(t):
                errors.append(f'{lang}.{k}: lost the plural')
            if ', plural,' in t and 'other{' not in t:
                errors.append(f'{lang}.{k}: plural without other')
            if t.count('{') != t.count('}'):
                errors.append(f'{lang}.{k}: unbalanced braces')
            ev, tv = letters(e), letters(t)
            if any(c.isalpha() for c in ev) and ev == ev.upper() and tv != tv.upper():
                errors.append(f'{lang}.{k}: should be in capitals: {t}')
    for e in errors:
        print(e)
    print(f'{len(errors)} problems')
    sys.exit(1 if errors else 0)


if __name__ == '__main__':
    main()
