#!/usr/bin/env python3
"""Assembles the 15 s promo video (1080x1920, 30 fps, H.264 + AAC: ready for
TikTok, Reels, Shorts and the store listings) from the
recorded gameplay: a title card, captions over each part, an end card, and a
soundtrack of the game's music plus every sound effect at the moment it
happened in the recording.

    FFMPEG=... flutter test tool/store/promo_video_test.dart
    pip install pillow numpy imageio-ffmpeg
    python3 tool/store/make_promo_video.py

Writes docs/store/play/promo_video.mp4. Google Play takes the video as a
YouTube link: upload it to YouTube (unlisted is fine) and paste the URL in
the store listing. It also works as an App Store app preview after trimming
to 30 s.
"""
import json
import os
import subprocess
import wave

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

try:
    import imageio_ffmpeg
    FFMPEG = os.environ.get('FFMPEG') or imageio_ffmpeg.get_ffmpeg_exe()
except ImportError:
    FFMPEG = os.environ.get('FFMPEG', 'ffmpeg')

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
OUT = os.path.join(HERE, 'out')
DEST = os.path.join(ROOT, 'docs', 'store', 'play', 'promo_video.mp4')
FONT = os.path.join(ROOT, 'assets', 'fonts', 'LilitaOne-Regular.ttf')
AUDIO = os.path.join(ROOT, 'assets', 'audio')
W, H, FPS = 1080, 1920, 30
INTRO, OUTRO = 1.0, 1.5
INK = (43, 29, 20)
RATE = 44100


def sunburst(size, centre, colours=((255, 226, 122), (255, 169, 59), (255, 107, 61), (217, 54, 91))):
    w, h = size
    y, x = np.mgrid[0:h, 0:w]
    d = np.hypot(x - centre[0], y - centre[1]) / (0.85 * max(w, h))
    stops = np.array([0, 0.3, 0.7, 1.0])
    img = np.zeros((h, w, 3))
    for c in range(3):
        img[..., c] = np.interp(d, stops, [col[c] for col in colours])
    # Rays.
    ang = (np.arctan2(y - centre[1], x - centre[0]) + np.pi) / (2 * np.pi) * 18
    img += ((ang.astype(int) % 2 == 0) * 18)[..., None]
    return Image.fromarray(np.clip(img, 0, 255).astype(np.uint8))


def text_centred(draw, y, text, font, fill, stroke):
    w = draw.textlength(text, font=font)
    x = (W - w) / 2
    draw.text((x + stroke * 0.5, y + stroke * 0.9), text, font=font, fill=INK)
    draw.text((x, y), text, font=font, fill=fill, stroke_width=stroke, stroke_fill=INK)


def card(path, lines, hero_y):
    img = sunburst((W, H), (W / 2, hero_y)).convert('RGBA')
    logo = Image.open(os.path.join(ROOT, 'tool', 'icon', 'out', 'logo.png')).convert('RGBA')
    logo = logo.resize((760, 760), Image.LANCZOS)
    img.alpha_composite(logo, ((W - 760) // 2, int(hero_y - 380)))
    d = ImageDraw.Draw(img)
    for text, y, size, fill in lines:
        text_centred(d, y, text, ImageFont.truetype(FONT, size), fill, max(6, size // 12))
    img.convert('RGB').save(path)


def caption(path, text):
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    if text:
        font = ImageFont.truetype(FONT, 104)
        shadow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
        sd = ImageDraw.Draw(shadow)
        tw = sd.textlength(text, font=font)
        y = int(H * 0.74)
        sd.text(((W - tw) / 2 + 6, y + 12), text, font=font, fill=(0, 0, 0, 140), stroke_width=14,
                stroke_fill=(0, 0, 0, 140))
        img.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(10)))
        ImageDraw.Draw(img).text(((W - tw) / 2, y), text, font=font, fill=(255, 255, 255), stroke_width=12,
                                 stroke_fill=INK)
    img.save(path)


def load_wav(name):
    with wave.open(os.path.join(AUDIO, name)) as w:
        data = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16).astype(np.float32) / 32768
        if w.getnchannels() == 2:
            data = data.reshape(-1, 2).mean(axis=1)
        rate = w.getframerate()
    if rate != RATE:
        t = np.arange(0, len(data) * RATE // rate) * rate / RATE
        data = np.interp(t, np.arange(len(data)), data)
    return data


def soundtrack(path, total, gameplay_start, sounds):
    n = int(total * RATE)
    music = load_wav('music.wav')
    track = np.tile(music, n // len(music) + 1)[:n] * 0.5
    fade = int(1.2 * RATE)
    track[-fade:] *= np.linspace(1, 0, fade)
    cache = {}
    sfx = np.zeros(n, dtype=np.float32)
    for s in sounds:
        clip = cache.setdefault(s['file'], load_wav(s['file']) if os.path.exists(os.path.join(AUDIO, s['file'])) else None)
        if clip is None:
            continue
        at = int((gameplay_start + s['t']) * RATE)
        end = min(n, at + len(clip))
        if at < n:
            sfx[at:end] += clip[: end - at] * s['volume'] * 0.8
    # The end card gets a win jingle.
    win = load_wav('win.wav')
    at = int((total - OUTRO + 0.15) * RATE)
    sfx[at:at + len(win)] += win[: n - at] * 0.9
    mix = np.tanh((track + sfx) * 1.1) * 0.9
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes((mix * 32767).astype(np.int16).tobytes())


def main():
    meta = json.load(open(os.path.join(OUT, 'gameplay.json')))
    gameplay = meta['frames'] / meta['fps']
    total = INTRO + gameplay + OUTRO

    card(os.path.join(OUT, 'intro.png'), [
        ('FLOPPY', 1180, 230, (255, 255, 255)),
        ('SWING', 1400, 230, (255, 226, 122)),
        ('Swing. Fly. Faceplant.', 1680, 86, (255, 255, 255)),
    ], hero_y=700)
    card(os.path.join(OUT, 'outro.png'), [
        ('FLOPPY SWING', 1160, 150, (255, 255, 255)),
        ('Can you do better?', 1360, 96, (255, 226, 122)),
        ('FREE ON GOOGLE PLAY', 1600, 100, (255, 255, 255)),
    ], hero_y=680)

    segs = meta['segments']
    inputs, overlays = [], []
    for i, seg in enumerate(segs[:-1]):
        p = os.path.join(OUT, f'caption_{i}.png')
        caption(p, seg['caption'])
        start, end = seg['t'], segs[i + 1]['t']
        inputs += ['-loop', '1', '-t', f'{gameplay:.3f}', '-i', p]
        overlays.append((start, end))
    wav = os.path.join(OUT, 'soundtrack.wav')
    soundtrack(wav, total, INTRO, meta['sounds'])

    args = [FFMPEG, '-y', '-loglevel', 'error',
            '-loop', '1', '-framerate', str(FPS), '-t', str(INTRO), '-i', os.path.join(OUT, 'intro.png'),
            '-i', os.path.join(OUT, 'gameplay.mp4'),
            '-loop', '1', '-framerate', str(FPS), '-t', str(OUTRO), '-i', os.path.join(OUT, 'outro.png'),
            *inputs, '-i', wav]
    graph, last = [], '[1:v]'
    for k, (start, end) in enumerate(overlays):
        # Captions pop in for the first 1.8 s of each part.
        until = min(end, start + 1.8)
        graph.append(f"{last}[{3 + k}:v]overlay=0:0:enable='between(t,{start:.3f},{until:.3f})'[g{k}]")
        last = f'[g{k}]'
    graph.append(f'[0:v]fps={FPS},format=yuv420p,setsar=1[a]')
    graph.append(f'{last}fps={FPS},format=yuv420p,setsar=1[b]')
    graph.append(f'[2:v]fps={FPS},format=yuv420p,setsar=1[c]')
    graph.append('[a][b][c]concat=n=3:v=1:a=0[v]')
    audio_index = 3 + len(overlays)
    args += ['-filter_complex', ';'.join(graph), '-map', '[v]', '-map', f'{audio_index}:a',
             '-c:v', 'libx264', '-preset', 'slow', '-crf', '19', '-pix_fmt', 'yuv420p', '-r', str(FPS),
             '-c:a', 'aac', '-b:a', '160k', '-movflags', '+faststart', '-t', '15', DEST]
    os.makedirs(os.path.dirname(DEST), exist_ok=True)
    subprocess.run(args, check=True)
    print(f'{DEST}: {total:.1f} s')


if __name__ == '__main__':
    main()
