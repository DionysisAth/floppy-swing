#!/usr/bin/env python3
"""Resizes the rendered icon and logo into every platform slot.

    flutter test tool/icon/icon_test.dart   # renders tool/icon/out/*.png
    pip install pillow && python3 tool/icon/make_icons.py
"""
import json
import os

from PIL import Image

ROOT = os.path.join(os.path.dirname(__file__), '..', '..')
OUT = os.path.join(os.path.dirname(__file__), 'out')
RES = os.path.join(ROOT, 'android', 'app', 'src', 'main', 'res')
IOS = os.path.join(ROOT, 'ios', 'Runner', 'Assets.xcassets')

icon = Image.open(os.path.join(OUT, 'icon.png')).convert('RGB')  # iOS icons must be opaque
foreground = Image.open(os.path.join(OUT, 'foreground.png')).convert('RGBA')
logo = Image.open(os.path.join(OUT, 'logo.png')).convert('RGBA')


def save(img, size, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.resize((size, size), Image.LANCZOS).save(path, optimize=True)


# iOS app icon: every size listed in the asset catalogue.
icon_set = os.path.join(IOS, 'AppIcon.appiconset')
with open(os.path.join(icon_set, 'Contents.json')) as f:
    for entry in json.load(f)['images']:
        points = float(entry['size'].split('x')[0])
        scale = int(entry['scale'].rstrip('x'))
        save(icon, round(points * scale), os.path.join(icon_set, entry['filename']))

# iOS launch screen logo.
for suffix, size in (('', 240), ('@2x', 480), ('@3x', 720)):
    save(logo, size, os.path.join(IOS, 'LaunchImage.imageset', f'LaunchImage{suffix}.png'))

# Android launcher icons (legacy square and adaptive foreground) and splash logo.
densities = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
for name, k in densities.items():
    save(icon, round(48 * k), os.path.join(RES, f'mipmap-{name}', 'ic_launcher.png'))
    save(foreground, round(108 * k), os.path.join(RES, f'mipmap-{name}', 'ic_launcher_foreground.png'))
    save(logo, round(160 * k), os.path.join(RES, f'drawable-{name}', 'splash_logo.png'))

print('icons written')
