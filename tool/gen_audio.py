#!/usr/bin/env python3
"""Synthesises every sound effect and the music loop into assets/audio/.

Pure Python (no dependencies), so the game ships with zero third-party audio
licences. Re-run after tweaking:  python3 tool/gen_audio.py
"""
import math
import os
import random
import struct
import wave

RATE = 22050
OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')
rng = random.Random(7)


def write(name, samples, gain=0.9):
    peak = max(1e-9, max(abs(s) for s in samples))
    scale = gain / peak
    with wave.open(os.path.join(OUT, name), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b''.join(
            struct.pack('<h', int(max(-1, min(1, s * scale)) * 32767)) for s in samples))


def n(seconds):
    return int(seconds * RATE)


def env(i, total, attack=0.005, decay=None):
    """Attack then exponential (or linear-to-zero) release."""
    t = i / RATE
    a = min(1.0, t / attack) if attack > 0 else 1.0
    if decay is None:
        return a * (1 - i / total)
    return a * math.exp(-t / decay)


def sweep(f0, f1, seconds, shape='sine', decay=None, vib=0.0, vib_rate=0.0, curve=1.0):
    total = n(seconds)
    out = []
    phase = 0.0
    for i in range(total):
        x = i / total
        f = f0 + (f1 - f0) * (x ** curve)
        if vib:
            f *= 1 + vib * math.sin(2 * math.pi * vib_rate * i / RATE)
        phase += 2 * math.pi * f / RATE
        if shape == 'sine':
            s = math.sin(phase)
        elif shape == 'square':
            s = 1.0 if math.sin(phase) >= 0 else -1.0
        elif shape == 'saw':
            s = ((phase / math.pi) % 2) - 1
        else:
            s = 2 / math.pi * math.asin(math.sin(phase))
        out.append(s * env(i, total, decay=decay))
    return out


def noise(seconds, decay=None, smooth=0.0):
    total = n(seconds)
    out, prev = [], 0.0
    for i in range(total):
        v = rng.uniform(-1, 1)
        prev = prev * smooth + v * (1 - smooth)
        out.append(prev * env(i, total, decay=decay))
    return out


def mix(*tracks, offsets=None):
    offsets = offsets or [0] * len(tracks)
    length = max(len(t) + n(o) for t, o in zip(tracks, offsets))
    out = [0.0] * length
    for t, o in zip(tracks, offsets):
        start = n(o)
        for i, s in enumerate(t):
            out[start + i] += s
    return out


def scale(track, g):
    return [s * g for s in track]


def partials(freqs, seconds, decay):
    total = n(seconds)
    return [sum(math.sin(2 * math.pi * f * i / RATE) * a for f, a in freqs) * math.exp(-i / RATE / decay)
            * min(1, i / (RATE * 0.002)) for i in range(total)]


# ---------------------------------------------------------------- effects

def sfx():
    write('thwip.wav', mix(sweep(300, 1500, 0.09, decay=0.04), scale(noise(0.03, decay=0.01), 0.5)))
    write('whoosh.wav', [s * math.sin(math.pi * i / n(0.28)) for i, s in enumerate(noise(0.28, smooth=0.85))], 0.6)
    write('coin.wav', mix(sweep(988, 988, 0.07, 'square', decay=0.05),
                          sweep(1319, 1319, 0.22, 'square', decay=0.08), offsets=[0, 0.06]), 0.5)
    write('bonk.wav', mix(sweep(220, 90, 0.16, decay=0.06, curve=0.5),
                          scale(sweep(440, 180, 0.08, decay=0.03), 0.4),
                          scale(noise(0.02, decay=0.005), 0.6)))
    write('bonk_big.wav', mix(sweep(160, 50, 0.3, decay=0.1, curve=0.5),
                              scale(noise(0.15, decay=0.04, smooth=0.6), 0.7),
                              scale(sweep(90, 40, 0.3, 'triangle', decay=0.12), 0.6)))
    write('squeak.wav', sweep(900, 1250, 0.26, decay=0.12, vib=0.12, vib_rate=28))
    write('clang.wav', partials([(523, 1), (1247, 0.7), (1831, 0.5), (2733, 0.35), (3620, 0.2)], 0.8, 0.18), 0.8)
    write('whistle.wav', sweep(1900, 380, 0.65, decay=None, vib=0.02, vib_rate=7, curve=0.8), 0.6)
    boing = []
    total = n(0.5)
    phase = 0.0
    for i in range(total):
        t = i / RATE
        f = 180 + 260 * t + 110 * math.sin(2 * math.pi * 16 * t) * math.exp(-5 * t)
        phase += 2 * math.pi * f / RATE
        boing.append(math.sin(phase) * math.exp(-t / 0.18))
    write('boing.wav', boing)
    write('zing.wav', mix(sweep(2600, 1800, 0.35, 'saw', decay=0.12, vib=0.03, vib_rate=40),
                          scale(noise(0.35, decay=0.1, smooth=0.3), 0.4)), 0.6)
    # Cartoon "waah!": sawtooth with a pitch arc through a smoothing filter.
    total = n(0.42)
    yelp, phase, lp = [], 0.0, 0.0
    for i in range(total):
        x = i / total
        f = 380 + 420 * math.sin(math.pi * min(1, x * 1.6)) - 120 * x
        f *= 1 + 0.04 * math.sin(2 * math.pi * 9 * i / RATE)
        phase += 2 * math.pi * f / RATE
        s = ((phase / math.pi) % 2) - 1
        lp += (s - lp) * 0.25
        yelp.append(lp * math.sin(math.pi * x) ** 0.6)
    write('yelp.wav', yelp, 0.55)
    notes = [523.25, 659.25, 783.99, 1046.5]
    jingle = mix(*[sweep(f, f, 0.14, 'square', decay=0.09) for f in notes],
                 *[scale(sweep(f, f, 0.6, 'triangle', decay=0.3), 0.8) for f in (523.25, 659.25, 783.99)],
                 offsets=[0, 0.1, 0.2, 0.3, 0.42, 0.42, 0.42])
    write('win.wav', jingle, 0.6)
    write('ding.wav', partials([(1568, 1), (3136, 0.4), (4704, 0.15)], 0.7, 0.2), 0.6)
    write('pop.wav', sweep(500, 1300, 0.07, decay=0.03), 0.6)
    write('blip.wav', sweep(420, 380, 0.05, 'square', decay=0.02), 0.3)
    write('slowmo.wav', mix(sweep(320, 55, 0.8, 'saw', decay=0.35, curve=0.6),
                            scale(noise(0.8, decay=0.3, smooth=0.9), 0.6)), 0.55)
    write('click.wav', sweep(1400, 900, 0.025, decay=0.008), 0.4)
    # Glass: a bright crack plus a shower of tinkly shards.
    shards = [partials([(2600 + 900 * k, 1), (5200 + 700 * k, 0.4)], 0.25, 0.06) for k in range(6)]
    write('shatter.wav', mix(scale(noise(0.3, decay=0.08), 0.7), *[scale(s, 0.5) for s in shards],
                             offsets=[0] + [0.02 + 0.035 * k for k in range(6)]), 0.7)
    write('crumble.wav', mix(scale(noise(0.45, decay=0.15, smooth=0.7), 1.0),
                             sweep(120, 60, 0.4, 'triangle', decay=0.15)), 0.6)
    write('rocket.wav', mix(scale(noise(0.6, decay=0.3, smooth=0.5), 0.8),
                            sweep(300, 900, 0.5, 'saw', decay=0.25)), 0.45)
    write('boom.wav', mix(sweep(120, 35, 0.6, decay=0.2, curve=0.5),
                          scale(noise(0.6, decay=0.18, smooth=0.55), 1.2)), 0.8)
    write('flip.wav', sweep(250, 1200, 0.35, 'sine', decay=None, vib=0.05, vib_rate=18), 0.5)
    write('buy.wav', mix(sweep(1319, 1319, 0.08, 'square', decay=0.05), sweep(1760, 1760, 0.08, 'square', decay=0.05),
                         partials([(2093, 1), (4186, 0.3)], 0.5, 0.15), offsets=[0, 0.07, 0.15]), 0.5)


# ------------------------------------------------------------------ music

NOTE = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11}


def freq(name):
    """'C5' -> Hz."""
    semis = NOTE[name[0]] + (1 if '#' in name else 0)
    octave = int(name[-1])
    return 440.0 * 2 ** ((semis - 9) / 12 + (octave - 4))


SONGS = {
    # World 1, Hills: bouncy C major.
    'music.wav': dict(
        bpm=132, style='pop', lead=('pulse', 0.25), gain=0.16,
        chords=[['C3', 'E4', 'G4'], ['G2', 'D4', 'B3'], ['A2', 'C4', 'E4'], ['F2', 'A3', 'C4']] * 2,
        melody=[
            'E5 G5 - C6 B5 G5 E5 -', 'D5 - G5 ~ F5 E5 D5 -',
            'C5 E5 A5 ~ G5 E5 C5 -', 'F5 ~ E5 D5 C5 - A4 -',
            'E5 G5 - C6 B5 G5 E5 G5', 'D5 - B5 ~ A5 G5 D5 -',
            'C5 E5 A5 G5 E5 C5 E5 -', 'F5 E5 D5 B4 C5 ~ ~ -',
        ]),
    # World 2, Factory: clanky A minor.
    'music_factory.wav': dict(
        bpm=120, style='factory', lead=('pulse', 0.5), gain=0.12,
        chords=[['A2', 'C4', 'E4'], ['F2', 'A3', 'C4'], ['G2', 'B3', 'D4'], ['E2', 'G#3', 'B3']] * 2,
        melody=[
            'A4 - C5 A4 E5 - D5 C5', 'A4 ~ ~ - F4 A4 C5 -',
            'B4 - D5 B4 G5 ~ F5 D5', 'E5 ~ D5 C5 B4 - G#4 -',
            'A4 C5 E5 A5 G5 E5 C5 -', 'F5 ~ E5 C5 A4 - C5 -',
            'D5 B4 G4 B4 D5 F5 E5 D5', 'E5 ~ ~ - B4 ~ ~ -',
        ]),
    # World 3, Glass City: sparkly D major, four on the floor.
    'music_city.wav': dict(
        bpm=140, style='city', lead=('tri', 0.5), gain=0.24,
        chords=[['D3', 'F#4', 'A4'], ['B2', 'D4', 'F#4'], ['G2', 'B3', 'D4'], ['A2', 'C#4', 'E4']] * 2,
        melody=[
            'F#5 A5 D6 A5 F#5 A5 D6 -', 'F#5 ~ E5 D5 B4 D5 F#5 -',
            'G5 B5 D6 B5 G5 ~ E5 -', 'A5 ~ G5 F#5 E5 ~ C#5 -',
            'F#5 A5 D6 A5 F#5 A5 B5 A5', 'F#5 ~ D5 F#5 B5 ~ A5 -',
            'G5 F#5 E5 D5 B4 D5 G5 -', 'A5 G5 F#5 E5 D5 ~ ~ -',
        ]),
    # World 4, Sky Islands: floaty F major.
    'music_sky.wav': dict(
        bpm=112, style='sky', lead=('tri', 0.5), gain=0.26,
        chords=[['F2', 'A3', 'C4'], ['D2', 'F3', 'A3'], ['A#1', 'D3', 'F3'], ['C2', 'E3', 'G3']] * 2,
        melody=[
            'C5 ~ F5 ~ A5 ~ G5 F5', 'D5 ~ ~ F5 A5 ~ ~ -',
            'A#4 ~ D5 F5 A#5 ~ A5 G5', 'G5 ~ ~ ~ E5 ~ C5 -',
            'C5 ~ F5 A5 C6 ~ A5 F5', 'D5 ~ F5 A5 D6 ~ C6 A5',
            'A#5 ~ A5 G5 F5 ~ D5 F5', 'G5 ~ ~ ~ F5 ~ ~ -',
        ]),
    # World 5, Rocket Base: driving D minor.
    'music_base.wav': dict(
        bpm=150, style='base', lead=('pulse', 0.125), gain=0.15,
        chords=[['D2', 'F3', 'A3'], ['A#1', 'D3', 'F3'], ['C2', 'E3', 'G3'], ['A1', 'C#3', 'E3']] * 2,
        melody=[
            'D5 D5 F5 D5 A5 - G5 F5', 'A#4 ~ D5 F5 A#5 ~ A5 G5',
            'C5 E5 G5 C6 A#5 - A5 G5', 'A5 ~ ~ - C#5 E5 A5 -',
            'D5 D5 F5 D5 A5 - D6 C6', 'A#5 ~ A5 G5 F5 - D5 F5',
            'E5 - G5 E5 C5 - E5 G5', 'A5 G5 F5 E5 D5 ~ ~ -',
        ]),
}


def music(name, bpm, style, lead, gain, chords, melody):
    beat = 60 / bpm
    eighth = beat / 2
    bars = len(melody)
    total = n(bars * 4 * beat)
    out = [0.0] * total

    def add(start, samples, g):
        s0 = n(start)
        for i, v in enumerate(samples):
            if s0 + i < total:
                out[s0 + i] += v * g

    def tone(f, dur, shape, duty=0.5, decay=None):
        cnt = n(dur)
        res, phase = [], 0.0
        for i in range(cnt):
            phase = (phase + f / RATE) % 1.0
            if shape == 'pulse':
                s = 1.0 if phase < duty else -1.0
            else:  # triangle
                s = 4 * abs(phase - 0.5) - 1
            e = min(1, i / (RATE * 0.004)) * (math.exp(-i / RATE / decay) if decay else max(0.0, 1 - i / cnt) ** 0.3)
            res.append(s * e)
        return res

    def kick(t, g=0.55):
        add(t, sweep(140, 45, 0.14, decay=0.05, curve=0.4), g)

    def snare(t, g=0.3):
        add(t, noise(0.12, decay=0.035, smooth=0.2), g)

    def hat(t, g=0.08):
        add(t, noise(0.03, decay=0.008), g)

    for bar in range(bars):
        t0 = bar * 4 * beat
        root, *pad = chords[bar]
        f = freq(root)
        # Bass.
        for b in range(4):
            if style == 'base':
                add(t0 + b * beat, tone(f, eighth * 0.8, 'tri'), 0.5)
                add(t0 + b * beat + eighth, tone(f, eighth * 0.8, 'tri'), 0.4)
            elif style == 'sky':
                if b % 2 == 0:
                    add(t0 + b * beat, tone(f, beat * 1.8, 'tri'), 0.45)
            else:
                add(t0 + b * beat, tone(f, eighth * 0.9, 'tri'), 0.5)
                add(t0 + b * beat + eighth, tone(f * 2, eighth * 0.8, 'tri'), 0.3)
        # Chords: stabs on 2 and 4, or a rippling arpeggio.
        if style in ('city', 'sky'):
            for k in range(8):
                p = pad[k % len(pad)]
                add(t0 + k * eighth, tone(freq(p) * 2, eighth * 1.6, 'tri', decay=0.18), 0.07)
        else:
            for b in (1, 3):
                for p in pad:
                    add(t0 + b * beat, tone(freq(p), eighth * 0.7, 'pulse', duty=0.25, decay=0.08), 0.08)
        # Lead, one symbol per eighth note ('-' = rest, '~' = hold).
        steps = melody[bar].split()
        for k, sym in enumerate(steps):
            if sym in ('-', '~'):
                continue
            hold = 1
            while k + hold < len(steps) and steps[k + hold] == '~':
                hold += 1
            add(t0 + k * eighth, tone(freq(sym), eighth * hold * 0.92, lead[0], duty=lead[1]), gain)
        # Drums.
        for b in range(4):
            t = t0 + b * beat
            if style == 'city':
                kick(t)
                if b % 2 == 1:
                    snare(t, 0.22)
                hat(t + eighth, 0.12)
            elif style == 'sky':
                if b == 0:
                    kick(t, 0.35)
                if b == 2:
                    add(t, partials([(1800, 1), (2700, 0.5)], 0.08, 0.02), 0.12)
                hat(t + eighth, 0.05)
            elif style == 'base':
                kick(t, 0.6)
                if b % 2 == 1:
                    snare(t, 0.36)
                for h in range(4):
                    hat(t + h * eighth / 2, 0.06)
            else:
                if b % 2 == 0:
                    kick(t)
                else:
                    snare(t)
                for h in range(2):
                    hat(t + h * eighth)
                if style == 'factory' and b % 2 == 1:
                    # Anvil clank on the off-beat.
                    add(t + eighth, partials([(620, 1), (1480, 0.6), (2350, 0.4)], 0.18, 0.05), 0.1)
    write(name, out, 0.7)


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    sfx()
    for name, song in SONGS.items():
        music(name, **song)
    print('wrote', sorted(os.listdir(OUT)))
