#!/usr/bin/env python3
"""Builds the advertising picture pack from the clean in-game stills:

    flutter test tool/store/ad_stills_test.dart
    python3 tool/store/make_ad_pack.py [out.zip]

The zip holds clean gameplay screens (1080x1920), the store graphics,
captioned square posts (1080x1080), landscape banners (1920x1080) and the
logo.
"""
import glob
import os
import shutil
import sys
import zipfile

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
STILLS = os.path.join(HERE, 'out', 'stills')
PACK = os.path.join(HERE, 'out', 'Floppy Swing ad pack')
FONT = os.path.join(ROOT, 'assets', 'fonts', 'LilitaOne-Regular.ttf')
LOGO = os.path.join(ROOT, 'tool', 'icon', 'out', 'logo.png')
INK = (43, 29, 20)
WHITE = (255, 255, 255)
GOLD = (255, 226, 122)

# Clean screens: (still, name in the pack).
SCREENS = [
    ('menu', 'main_menu'),
    ('level_2_2.9', 'world1_playground_swing'),
    ('level_14_5.1', 'world1_playground_big_swing'),
    ('level_24_5.1', 'world2_factory_saws'),
    ('level_33_6.3', 'world2_factory_combo'),
    ('level_45_3.9', 'world3_glass_city_smash'),
    ('level_52_6.3', 'world3_glass_city_checkpoint'),
    ('level_64_1.9', 'world4_sky_islands'),
    ('level_75_2.9', 'world4_sky_islands_bonk'),
    ('level_86_1.9', 'world5_rocket_base'),
    ('level_96_2.9', 'world5_rocket_base_night'),
    ('fail_replay_1', 'fail_slowmo_replay'),
    ('fail_replay_3', 'fail_crash'),
    ('endless_4', 'endless_mode'),
    ('level_clear', 'level_clear'),
    ('worlds', 'level_select'),
    ('shop_skins', 'shop_skins'),
    ('shop_ropes', 'shop_ropes'),
    ('season_pass', 'season_pass'),
]

# Square posts: (still, title, subtitle, colour, crop centre as a fraction of the height).
SQUARES = [
    ('level_14_5.1', 'HOLD TO SWING', 'One thumb. Pure chaos.', (45, 125, 209), 0.55),
    ('fail_replay_3', 'FAILS ARE FUNNY', 'Every crash replays in slow-mo', (230, 57, 70), 0.45),
    ('level_24_5.1', 'DODGE THE SAWS', 'World 2: Factory', (232, 120, 52), 0.52),
    ('level_45_3.9', 'SMASH THE GLASS', 'World 3: Glass City', (46, 78, 134), 0.50),
    ('level_75_5.1', 'RIDE THE WIND', 'World 4: Sky Islands', (143, 107, 199), 0.55),
    ('level_86_1.9', 'DODGE ROCKETS', 'World 5: Rocket Base', (64, 48, 110), 0.55),
    ('shop_skins', 'LOOK FABULOUS', 'Skins, ropes, trails and dances', (255, 78, 138), 0.42),
]

# Banners: (file, headline, subline, colour, two stills).
BANNERS = [
    ('banner_swing_fly_faceplant', 'Swing. Fly.\nFaceplant.', 'FREE ON GOOGLE PLAY', (255, 138, 61),
     ['level_45_3.9', 'fail_replay_2']),
    ('banner_100_levels', '100 levels.\n5 wild worlds.', 'FREE ON GOOGLE PLAY', (45, 125, 209),
     ['level_75_1.9', 'level_96_2.9']),
    ('banner_skins', 'Fail in\nstyle.', 'FREE ON GOOGLE PLAY', (230, 57, 70),
     ['shop_skins', 'fail_replay_3']),
]


def font(size):
    return ImageFont.truetype(FONT, size)


def gradient(size, colour):
    w, h = size
    img = Image.new('RGB', size, colour)
    d = ImageDraw.Draw(img)
    for y in range(h):
        k = 0.82 + 0.18 * (1 - y / h)
        d.line([(0, y), (w, y)], fill=tuple(int(c * k) for c in colour))
    # Faint sun rays from the top centre.
    rays = Image.new('L', size, 0)
    rd = ImageDraw.Draw(rays)
    import math
    cx, cy = w / 2, -h * 0.2
    for i in range(18):
        a0, a1 = i * 2 * math.pi / 18, (i + 0.5) * 2 * math.pi / 18
        r = 3 * max(w, h)
        rd.polygon([(cx, cy), (cx + r * math.cos(a0), cy + r * math.sin(a0)),
                    (cx + r * math.cos(a1), cy + r * math.sin(a1))], fill=22)
    return Image.composite(Image.new('RGB', size, WHITE), img, rays)


def outlined(draw, xy, text, size, fill=WHITE, anchor='la', spacing=0):
    f = font(size)
    stroke = max(4, size // 14)
    x, y = xy
    draw.multiline_text((x + stroke * 0.5, y + stroke), text, font=f, fill=INK, anchor=anchor,
                        stroke_width=stroke, stroke_fill=INK, spacing=spacing, align='left')
    draw.multiline_text((x, y), text, font=f, fill=fill, anchor=anchor, stroke_width=stroke,
                        stroke_fill=INK, spacing=spacing, align='left')


def rounded_paste(canvas, img, xy, radius, border=10):
    x, y = xy
    ImageDraw.Draw(canvas).rounded_rectangle(
        (x - border, y - border, x + img.width + border, y + img.height + border),
        radius=radius + border, fill=INK)
    mask = Image.new('L', img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, img.width - 1, img.height - 1), radius=radius, fill=255)
    canvas.paste(img, (x, y), mask)


def still(name):
    return Image.open(os.path.join(STILLS, f'{name}.png')).convert('RGB')


def logo(width):
    img = Image.open(LOGO).convert('RGBA')
    return img.resize((width, int(img.height * width / img.width)), Image.LANCZOS)


def square(name, title, sub, colour, centre):
    s = 1080
    canvas = gradient((s, s), colour)
    d = ImageDraw.Draw(canvas)
    outlined(d, (s / 2, 70), title, 112, anchor='ma')
    outlined(d, (s / 2, 200), sub, 52, fill=GOLD, anchor='ma')
    # Gameplay crop.
    box_w, box_h = 900, 640
    shot = still(name)
    crop_h = int(shot.width * box_h / box_w)
    top = int(min(max(shot.height * centre - crop_h / 2, 0), shot.height - crop_h))
    shot = shot.crop((0, top, shot.width, top + crop_h)).resize((box_w, box_h), Image.LANCZOS)
    rounded_paste(canvas, shot, ((s - box_w) // 2, 300), 40)
    # Logo, name and the call to action.
    lg = logo(120)
    canvas.paste(lg, (36, s - lg.height - 12), lg)
    outlined(d, (36 + lg.width + 8, s - 92), 'FLOPPY SWING', 50)
    outlined(d, (s - 44, s - 92), 'FREE ON GOOGLE PLAY', 50, fill=GOLD, anchor='ra')
    return canvas


def banner(headline, subline, colour, names):
    w, h = 1920, 1080
    canvas = gradient((w, h), colour)
    d = ImageDraw.Draw(canvas)
    lg = logo(230)
    canvas.paste(lg, (90, 70), lg)
    outlined(d, (90 + lg.width + 20, 70 + lg.height // 2 - 70), 'FLOPPY\nSWING', 84, spacing=0)
    outlined(d, (100, 420), headline, 100, spacing=16)
    outlined(d, (100, h - 160), subline, 58, fill=GOLD)
    # Two screens, the right one raised.
    sh = 880
    sw = int(sh * 1080 / 1920)
    gap = 36
    x0 = w - 90 - 2 * sw - gap
    for i, n in enumerate(names):
        img = still(n).resize((sw, sh), Image.LANCZOS)
        y = (h - sh) // 2 + (25 if i == 0 else -25)
        rounded_paste(canvas, img, (x0 + i * (sw + gap), y), 32, border=9)
    return canvas


def main():
    dest = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, 'out', 'FloppySwing_ad_pack.zip')
    shutil.rmtree(PACK, ignore_errors=True)
    dirs = {k: os.path.join(PACK, v) for k, v in {
        'screens': '1 Gameplay screens 1080x1920',
        'store': '2 Store graphics',
        'square': '3 Square posts 1080x1080',
        'banner': '4 Banners 1920x1080',
        'logo': '5 Logo and icon',
    }.items()}
    for p in dirs.values():
        os.makedirs(p)
    for i, (src, name) in enumerate(SCREENS, 1):
        still(src).save(os.path.join(dirs['screens'], f'{i:02d}_{name}.png'), optimize=True)
    for f in sorted(glob.glob(os.path.join(ROOT, 'docs', 'store', 'screenshots', 'android_*.jpg'))):
        shutil.copy(f, os.path.join(dirs['store'], 'screenshot_' + os.path.basename(f)[len('android_'):]))
    shutil.copy(os.path.join(ROOT, 'docs', 'store', 'play', 'feature_graphic.png'),
                os.path.join(dirs['store'], 'feature_graphic_1024x500.png'))
    for i, (src, title, sub, colour, centre) in enumerate(SQUARES, 1):
        square(src, title, sub, colour, centre).save(
            os.path.join(dirs['square'], f'{i:02d}_{title.lower().replace(" ", "_")}.jpg'), quality=92)
    for name, headline, subline, colour, names in BANNERS:
        banner(headline, subline, colour, names).save(os.path.join(dirs['banner'], f'{name}.jpg'), quality=92)
    shutil.copy(LOGO, os.path.join(dirs['logo'], 'logo_transparent.png'))
    shutil.copy(os.path.join(ROOT, 'docs', 'store', 'play', 'icon_512.png'), os.path.join(dirs['logo'], 'icon_512.png'))
    with zipfile.ZipFile(dest, 'w', zipfile.ZIP_DEFLATED) as z:
        for folder, _, files in os.walk(PACK):
            for f in sorted(files):
                p = os.path.join(folder, f)
                z.write(p, os.path.relpath(p, os.path.dirname(PACK)))
    print(dest, f'{os.path.getsize(dest) / 1e6:.1f} MB')


if __name__ == '__main__':
    main()
