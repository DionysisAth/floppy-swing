#!/usr/bin/env python3
"""Frames raw store screens with a caption and writes store-ready JPEGs.

    pip install pillow && python3 tool/screenshots/frame.py

App Store: 1290x2796 (6.9" iPhone). Google Play: 1080x1920 (16:9 fits Play's
2:1 limit).
"""
import os

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(__file__)
ROOT = os.path.join(HERE, '..', '..')
OUT = os.path.join(ROOT, 'docs', 'store', 'screenshots')
FONT = os.path.join(ROOT, 'assets', 'fonts', 'LilitaOne-Regular.ttf')

CAPTIONS = {
    '1_swing': ('HOLD TO SWING', 'One thumb. Pure chaos.', (45, 125, 209)),
    '2_fail': ('FAILS ARE FUNNY', 'Every crash replays in slow-mo', (230, 57, 70)),
    '3_worlds': ('100 LEVELS', '5 wild worlds to swing through', (255, 138, 61)),
    '4_endless': ('ENDLESS MODE', 'How far can you go?', (143, 107, 199)),
    '5_shop': ('LOOK FABULOUS', 'Skins, ropes, trails and dances', (255, 78, 138)),
}


def frame(name, size):
    title, sub, colour = CAPTIONS[name]
    w, h = size
    canvas = Image.new('RGB', size, colour)
    draw = ImageDraw.Draw(canvas)
    # Soft vertical gradient.
    for y in range(h):
        k = 0.85 + 0.15 * (1 - y / h)
        draw.line([(0, y), (w, y)], fill=tuple(int(c * k) for c in colour))
    title_font = ImageFont.truetype(FONT, int(w * 0.105))
    sub_font = ImageFont.truetype(FONT, int(w * 0.05))
    top = int(h * 0.045)
    for text, font, y in ((title, title_font, top), (sub, sub_font, top + int(w * 0.13))):
        tw = draw.textlength(text, font=font)
        draw.text(((w - tw) / 2 + 5, y + 7), text, font=font, fill=(43, 29, 20))
        draw.text(((w - tw) / 2, y), text, font=font, fill=(255, 255, 255))
    shot = Image.open(os.path.join(HERE, 'out', f'{name}.png')).convert('RGB')
    area_top = top + int(w * 0.23)
    scale = min((h - area_top - int(h * 0.03)) / shot.height, w * 0.86 / shot.width)
    shot = shot.resize((int(shot.width * scale), int(shot.height * scale)), Image.LANCZOS)
    x = (w - shot.width) // 2
    radius = int(w * 0.06)
    mask = Image.new('L', shot.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, shot.width - 1, shot.height - 1), radius=radius, fill=255)
    border = 10
    ImageDraw.Draw(canvas).rounded_rectangle(
        (x - border, area_top - border, x + shot.width + border, area_top + shot.height + border),
        radius=radius + border, fill=(43, 29, 20))
    canvas.paste(shot, (x, area_top), mask)
    return canvas


os.makedirs(OUT, exist_ok=True)
for name in CAPTIONS:
    frame(name, (1290, 2796)).save(os.path.join(OUT, f'ios_{name}.jpg'), quality=88, optimize=True)
    frame(name, (1080, 1920)).save(os.path.join(OUT, f'android_{name}.jpg'), quality=88, optimize=True)
print('screenshots written to', OUT)
