#!/usr/bin/env python3
"""Assembles the ~32 s landscape trailer (1920x1080, 30 fps, H.264 + AAC) for
YouTube and the Google Play promo video: a title card, the portrait gameplay
in the middle with a caption on the left and the name on the right, an end
card, and a soundtrack of the game's music plus every sound effect at the
moment it happened in the recording.

    FFMPEG=... flutter test tool/store/youtube_video_test.dart
    python3 tool/store/make_youtube_video.py [out.mp4]

Google Play takes the video as a YouTube link: upload it (public or
unlisted, ads off, not age-restricted) and paste the URL in the store
listing.
"""
import json
import os
import subprocess
import sys
import wave

import numpy as np
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from make_promo_video import FFMPEG, RATE, load_wav, sunburst  # noqa: E402

ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
OUT = os.path.join(HERE, 'out', 'youtube')
DEST = os.path.join(ROOT, 'docs', 'store', 'play', 'trailer_youtube.mp4')
FONT = os.path.join(ROOT, 'assets', 'fonts', 'LilitaOne-Regular.ttf')
LOGO = os.path.join(ROOT, 'tool', 'icon', 'out', 'logo.png')
W, H, FPS = 1920, 1080, 30
INTRO, OUTRO = 2.0, 3.0
INK = (43, 29, 20)
WHITE = (255, 255, 255)
GOLD = (255, 226, 122)
# The gameplay window: portrait, centred.
GH = 1000
GW = int(GH * 1080 / 1920) // 2 * 2
GX, GY = (W - GW) // 2, (H - GH) // 2
RADIUS = 36


def font(size):
    return ImageFont.truetype(FONT, size)


def text(draw, xy, s, size, fill=WHITE, anchor='ma'):
    stroke = max(5, size // 12)
    x, y = xy
    f = font(size)
    draw.text((x + stroke * 0.5, y + stroke), s, font=f, fill=INK, anchor=anchor,
              stroke_width=stroke, stroke_fill=INK)
    draw.text((x, y), s, font=f, fill=fill, anchor=anchor, stroke_width=stroke, stroke_fill=INK)


def wrap(s, size, width):
    """Splits [s] into lines that fit [width] at [size]."""
    f = font(size)
    lines, line = [], ''
    for word in s.split():
        trial = f'{line} {word}'.strip()
        if f.getlength(trial) <= width or not line:
            line = trial
        else:
            lines.append(line)
            line = word
    return lines + [line]


def logo(width):
    img = Image.open(LOGO).convert('RGBA')
    return img.resize((width, int(img.height * width / img.width)), Image.LANCZOS)


def background(path):
    img = sunburst((W, H), (W / 2, H * 0.45)).convert('RGBA')
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((GX - 10, GY - 10, GX + GW + 10, GY + GH + 10), radius=RADIUS + 10, fill=INK)
    # The name and the call to action on the right.
    cx = (GX + GW + W) // 2
    lg = logo(300)
    img.alpha_composite(lg, (cx - lg.width // 2, 170))
    text(d, (cx, 170 + lg.height + 20), 'FLOPPY', 96)
    text(d, (cx, 170 + lg.height + 120), 'SWING', 96, fill=GOLD)
    text(d, (cx, H - 230), 'FREE ON', 64)
    text(d, (cx, H - 155), 'GOOGLE PLAY', 64)
    img.convert('RGB').save(path)


def mask(path):
    m = Image.new('L', (GW, GH), 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, GW - 1, GH - 1), radius=RADIUS, fill=255)
    m.save(path)


def caption(path, title, sub):
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    if title:
        d = ImageDraw.Draw(img)
        cx, width = GX // 2, GX - 150
        lines = wrap(title, 108, width)
        y = H // 2 - (len(lines) * 118 + 80) // 2
        for line in lines:
            text(d, (cx, y), line, 108)
            y += 118
        text(d, (cx, y + 10), sub, 52, fill=GOLD)
    img.save(path)


def card(path, lines, logo_width, logo_y):
    img = sunburst((W, H), (W / 2, H * 0.4)).convert('RGBA')
    lg = logo(logo_width)
    img.alpha_composite(lg, ((W - lg.width) // 2, logo_y))
    d = ImageDraw.Draw(img)
    for s, y, size, fill in lines:
        text(d, (W / 2, y), s, size, fill)
    img.convert('RGB').save(path)


def soundtrack(path, total, gameplay_start, sounds):
    n = int(total * RATE)
    music = load_wav('music.wav')
    track = np.tile(music, n // len(music) + 1)[:n] * 0.5
    fade = int(1.5 * RATE)
    track[-fade:] *= np.linspace(1, 0, fade)
    cache = {}
    sfx = np.zeros(n, dtype=np.float32)
    for s in sounds:
        f = os.path.join(ROOT, 'assets', 'audio', s['file'])
        clip = cache.setdefault(s['file'], load_wav(s['file']) if os.path.exists(f) else None)
        if clip is None:
            continue
        at = int((gameplay_start + s['t']) * RATE)
        end = min(n, at + len(clip))
        if at < n:
            sfx[at:end] += clip[: end - at] * s['volume'] * 0.8
    win = load_wav('win.wav')
    at = int((total - OUTRO + 0.2) * RATE)
    sfx[at:at + len(win)] += win[: n - at] * 0.9
    mix = np.tanh((track + sfx) * 1.1) * 0.9
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes((mix * 32767).astype(np.int16).tobytes())


def main():
    dest = sys.argv[1] if len(sys.argv) > 1 else DEST
    meta = json.load(open(os.path.join(OUT, 'gameplay.json')))
    gameplay = meta['frames'] / meta['fps']
    total = INTRO + gameplay + OUTRO

    p = lambda name: os.path.join(OUT, name)  # noqa: E731
    card(p('intro.png'), [
        ('FLOPPY SWING', 640, 170, WHITE),
        ('Swing. Fly. Faceplant.', 850, 86, GOLD),
    ], 520, 60)
    card(p('outro.png'), [
        ('Can you do better?', 610, 130, WHITE),
        ('FREE ON GOOGLE PLAY', 800, 110, GOLD),
    ], 440, 100)
    background(p('bg.png'))
    mask(p('mask.png'))
    segs = meta['segments']
    caps = []
    for i, seg in enumerate(segs[:-1]):
        caption(p(f'caption_{i}.png'), seg['caption'], seg['sub'])
        caps.append((seg['t'], segs[i + 1]['t']))
    soundtrack(p('soundtrack.wav'), total, INTRO, meta['sounds'])

    still = lambda f, t: ['-loop', '1', '-framerate', str(FPS), '-t', f'{t:.3f}', '-i', p(f)]  # noqa: E731
    args = [FFMPEG, '-y', '-loglevel', 'error',
            *still('intro.png', INTRO),            # 0
            '-i', p('gameplay.mp4'),               # 1
            *still('outro.png', OUTRO),            # 2
            *still('bg.png', gameplay),            # 3
            *still('mask.png', gameplay)]          # 4
    for i in range(len(caps)):
        args += still(f'caption_{i}.png', gameplay)
    args += ['-i', p('soundtrack.wav')]
    graph = [
        f'[1:v]fps={FPS},scale={GW}:{GH}:flags=lanczos,format=rgba[gs]',
        '[4:v]format=gray[m]',
        '[gs][m]alphamerge[gm]',
        f'[3:v][gm]overlay={GX}:{GY}:shortest=1[g]',
    ]
    last = '[g]'
    for k, (start, end) in enumerate(caps):
        graph.append(f"{last}[{5 + k}:v]overlay=0:0:enable='between(t,{start:.3f},{end - 0.001:.3f})'[c{k}]")
        last = f'[c{k}]'
    graph += [
        f'[0:v]fps={FPS},format=yuv420p,setsar=1,fade=t=in:st=0:d=0.4[a]',
        f'{last}fps={FPS},format=yuv420p,setsar=1[b]',
        f'[2:v]fps={FPS},format=yuv420p,setsar=1,fade=t=out:st={OUTRO - 0.6}:d=0.6[c]',
        '[a][b][c]concat=n=3:v=1:a=0[v]',
    ]
    args += ['-filter_complex', ';'.join(graph), '-map', '[v]', '-map', f'{5 + len(caps)}:a',
             '-c:v', 'libx264', '-preset', 'slow', '-crf', '18', '-pix_fmt', 'yuv420p', '-r', str(FPS),
             '-c:a', 'aac', '-b:a', '192k', '-movflags', '+faststart', '-t', f'{total:.3f}', dest]
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    subprocess.run(args, check=True)
    print(f'{dest}: {total:.1f} s')


if __name__ == '__main__':
    main()
