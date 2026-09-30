#!/usr/bin/env python3
"""Google Play listing graphics: the 512x512 icon and the 1024x500 feature
graphic (artwork from tool/store/feature_art_test.dart plus the title).

    flutter test tool/icon/icon_test.dart tool/store/feature_art_test.dart
    pip install pillow && python3 tool/store/make_store_assets.py
"""
import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, '..', '..')
OUT = os.path.join(ROOT, 'docs', 'store', 'play')
FONT = os.path.join(ROOT, 'assets', 'fonts', 'LilitaOne-Regular.ttf')
INK = (43, 29, 20)

os.makedirs(OUT, exist_ok=True)

# Icon: 512x512 32-bit PNG.
icon = Image.open(os.path.join(ROOT, 'tool', 'icon', 'out', 'icon.png')).convert('RGBA')
icon.resize((512, 512), Image.LANCZOS).save(os.path.join(OUT, 'icon_512.png'))

# Feature graphic: 1024x500, drawn at 2x and scaled down.
art = Image.open(os.path.join(HERE, 'out', 'feature_art.png')).convert('RGBA')
w, h = art.size


def outlined(draw, xy, text, font, fill, outline, width):
    x, y = xy
    draw.text((x + width * 0.6, y + width), text, font=font, fill=INK + (255,))
    draw.text(xy, text, font=font, fill=fill, stroke_width=width, stroke_fill=outline)


shadow = Image.new('RGBA', art.size, (0, 0, 0, 0))
text = Image.new('RGBA', art.size, (0, 0, 0, 0))
big = ImageFont.truetype(FONT, 250)
small = ImageFont.truetype(FONT, 92)
left = 110
lines = [('FLOPPY', 150), ('SWING', 400)]
for d in (ImageDraw.Draw(shadow), ImageDraw.Draw(text)):
    pass
sd = ImageDraw.Draw(shadow)
for word, y in lines:
    sd.text((left + 10, y + 16), word, font=big, fill=(60, 10, 20, 150), stroke_width=22, stroke_fill=(60, 10, 20, 150))
sd.text((left + 8, 690 + 10), 'Swing. Fly. Faceplant.', font=small, fill=(60, 10, 20, 150), stroke_width=12,
        stroke_fill=(60, 10, 20, 150))
shadow = shadow.filter(ImageFilter.GaussianBlur(14))
td = ImageDraw.Draw(text)
for (word, y), colour in zip(lines, [(255, 255, 255, 255), (255, 226, 122, 255)]):
    outlined(td, (left, y), word, big, colour, INK + (255,), 20)
outlined(td, (left, 690), 'Swing. Fly. Faceplant.', small, (255, 255, 255, 255), INK + (255,), 10)
feature = Image.alpha_composite(Image.alpha_composite(art, shadow), text)
feature.convert('RGB').resize((1024, 500), Image.LANCZOS).save(os.path.join(OUT, 'feature_graphic.png'))
print('written to', os.path.normpath(OUT))
