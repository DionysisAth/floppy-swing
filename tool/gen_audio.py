#!/usr/bin/env python3
"""Synthesises every sound effect and the music loops into assets/audio/.

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


# Music: lively but soft. Warm sine/triangle-style tones only (no square
# waves), a bouncy bass, off-beat chord plucks, a marimba-like melody in
# A / A' / B / A sections, a sparkle arpeggio in the B part and a gentle
# groove (kick, soft clap on 2 and 4, quiet hats, a small fill every 4 bars).
# 16 bars; notes that ring past the end wrap round, so the loop is seamless.

MRATE = 22050

SONGS = {
    # World 1, Hills: sunny and bouncy.
    'music.wav': dict(bpm=112, seed=11, groove='bounce',
                      chords=['C3 E3 G3', 'A2 C3 E3', 'F2 A2 C3', 'G2 B2 D3']),
    # World 2, Factory: busy little machines, with woodblock ticks.
    'music_factory.wav': dict(bpm=108, seed=12, groove='tick',
                              chords=['A2 C3 E3', 'F2 A2 C3', 'C3 E3 G3', 'G2 B2 D3']),
    # World 3, Glass City: bright and sparkly.
    'music_city.wav': dict(bpm=116, seed=13, groove='sparkle',
                           chords=['D3 F#3 A3', 'B2 D3 F#3', 'G2 B2 D3', 'A2 C#3 E3']),
    # World 4, Sky Islands: floaty, half-time, still moving.
    'music_sky.wav': dict(bpm=100, seed=14, groove='float',
                          chords=['F2 A2 C3', 'D2 F2 A2', 'A#1 D2 F2', 'C2 E2 G2']),
    # World 5, Rocket Base: driving four-on-the-floor.
    'music_base.wav': dict(bpm=124, seed=15, groove='drive',
                           chords=['D2 F2 A2', 'A#1 D2 F2', 'F2 A2 C3', 'C2 E2 G2']),
}


def music(name, bpm, seed, groove, chords):
    beat = 60 / bpm
    bars = 16
    total = int(bars * 4 * beat * MRATE)
    out = [0.0] * total
    r = random.Random(seed)

    def at(t):
        return int(t * MRATE)

    def add(t0, samples, gain):
        start = at(t0)
        for i, v in enumerate(samples):
            out[(start + i) % total] += v * gain  # Wrap: seamless loop.

    def tone(f, dur, attack, release, harmonics=((1, 1.0),), detune=0.0):
        cnt = int((dur + release) * MRATE)
        res = []
        for i in range(cnt):
            t = i / MRATE
            e = min(1.0, t / attack) if attack > 0 else 1.0
            if t > dur:
                e *= math.exp(-(t - dur) / (release / 4))
            v = 0.0
            for h, a in harmonics:
                v += a * math.sin(2 * math.pi * f * h * t)
                if detune:
                    v += a * 0.6 * math.sin(2 * math.pi * f * h * (1 + detune) * t)
            res.append(v * e)
        return res

    def pluck(f, decay=0.3, bright=0.25):
        """Marimba-ish: sine plus a quickly fading 4th harmonic."""
        cnt = int(decay * 5 * MRATE)
        res = []
        for i in range(cnt):
            t = i / MRATE
            v = math.sin(2 * math.pi * f * t) + bright * math.sin(8 * math.pi * f * t) * math.exp(-t / 0.03)
            res.append(v * math.exp(-t / decay) * min(1, t / 0.003))
        return res

    def bass(f, dur):
        cnt = int((dur + 0.08) * MRATE)
        res = []
        for i in range(cnt):
            t = i / MRATE
            e = math.exp(-t / (dur * 0.9)) * min(1, t / 0.006)
            res.append((math.sin(2 * math.pi * f * t) + 0.3 * math.sin(4 * math.pi * f * t)) * e)
        return res

    def kick(gain):
        cnt = int(0.28 * MRATE)
        res, phase = [], 0.0
        for i in range(cnt):
            f = 50 + 90 * math.exp(-i / MRATE / 0.035)
            phase += 2 * math.pi * f / MRATE
            res.append(math.sin(phase) * math.exp(-i / MRATE / 0.1) * gain)
        return res

    def noise(length, decay, smooth=0.5):
        cnt = int(length * MRATE)
        res, prev = [], 0.0
        for i in range(cnt):
            prev = prev * smooth + r.uniform(-1, 1) * (1 - smooth)
            res.append(prev * math.exp(-i / MRATE / decay))
        return res

    def clap(gain):
        body = tone(190, 0.02, 0.001, 0.08)
        hiss = noise(0.18, 0.05, 0.35)
        n = max(len(body), len(hiss))
        return [((body[i] * 0.5 if i < len(body) else 0) + (hiss[i] if i < len(hiss) else 0)) * gain for i in range(n)]

    def hat(gain):
        h = noise(0.05, 0.012, 0.1)
        # High-pass by differencing, then a gentle smooth so it isn't hissy.
        d = [h[i] - h[i - 1] for i in range(1, len(h))]
        return [0.5 * (d[i] + d[i - 1]) * gain for i in range(1, len(d))]

    def block(f, gain):
        return [v * gain for v in tone(f, 0.01, 0.001, 0.05, ((1, 1.0), (2.7, 0.3)))]

    progression = [c.split() for c in chords]
    root = freq(progression[0][0][:-1] + '4')
    penta = [root * 2 ** (k / 12) for k in (0, 2, 4, 7, 9, 12, 14, 16, 19, 21)]

    rhythms = [[0, 0.5, 1, 2, 2.5, 3], [0, 1, 1.5, 2, 3, 3.5], [0, 0.5, 1.5, 2, 3],
               [0, 1, 2, 2.5, 3, 3.5], [0, 0.75, 1.5, 2, 3], [0, 0.5, 1, 1.5, 2, 3]]

    def motif(start):
        bars_ = []
        idx = start
        for _ in range(4):
            notes = []
            for pos in r.choice(rhythms):
                idx = max(0, min(len(penta) - 1, idx + r.choice([-2, -1, -1, 1, 1, 2, 0])))
                notes.append((pos, idx))
            bars_.append(notes)
        return bars_

    a_part, b_part = motif(3), motif(5)
    half = groove == 'float'

    for bar in range(bars):
        t0 = bar * 4 * beat
        chord = progression[bar % len(progression)]
        section = 'B' if 8 <= bar < 12 else 'A'
        # Soft pad underneath, quieter than before: the plucks carry it now.
        for note in chord:
            add(t0, tone(freq(note) * 2, 4 * beat, 0.3, 1.0, ((1, 1.0), (2, 0.12)), detune=0.003), 0.025)
        # Bouncy bass: root, octave hop, fifth.
        b0 = freq(chord[0])
        fifth = freq(chord[2])
        pattern = ([(0, b0, 1.2), (2, fifth, 1.2)] if half else
                   [(0, b0, 0.8), (1.5, b0 * 2, 0.35), (2, b0, 0.8), (3, fifth, 0.35), (3.5, b0 * 2, 0.35)])
        for pos, f, dur in pattern:
            add(t0 + pos * beat, bass(f, dur * beat), 0.2)
        # Off-beat chord plucks (the "skank"), lighter in half-time.
        for off in ((1, 3) if half else (0.5, 1.5, 2.5, 3.5)):
            for note in chord:
                add(t0 + off * beat, pluck(freq(note) * 4, decay=0.12, bright=0.1), 0.028)
        # Melody.
        phrase = (b_part if section == 'B' else a_part)[bar % 4]
        if 4 <= bar < 8 and bar % 4 == 3:
            phrase = [(p, min(len(penta) - 1, i + 1)) for p, i in phrase]  # A' answers higher.
        if bar == bars - 1:
            phrase = [(0, 0), (1, 2), (2, 0)]
        for pos, i in phrase:
            add(t0 + pos * beat, pluck(penta[i]), 0.12)
            add(t0 + pos * beat, pluck(penta[i] * 2, decay=0.15, bright=0.0), 0.02)
        # Sparkle arpeggio in the B part (and all through Glass City).
        if section == 'B' or groove == 'sparkle':
            tones = [freq(n) * 8 for n in chord] + [freq(chord[0]) * 16]
            for k in range(8):
                add(t0 + k * beat / 2, pluck(tones[k % len(tones)], decay=0.09, bright=0.0), 0.018)
        # Groove.
        fill = bar % 4 == 3
        for b in range(4):
            t = t0 + b * beat
            if groove == 'drive':
                add(t, kick(1), 0.3)
            elif groove == 'float':
                if b == 0:
                    add(t, kick(1), 0.22)
            elif b in (0, 2) or (b == 3 and groove == 'bounce' and bar % 2):
                add(t if b != 3 else t + beat / 2, kick(1), 0.28)
            if b in (1, 3) and not (half and b == 1):
                add(t, clap(1), 0.09 if not half else 0.07)
            for h in (0, 0.5):
                add(t + h * beat, hat(1), 0.05 if h else 0.03)
            if groove == 'tick':
                add(t + 0.75 * beat, block(1200 if b % 2 else 900, 1), 0.05)
        if fill and not half:
            for k in range(4):
                add(t0 + 3 * beat + k * beat / 4, clap(1), 0.035 + 0.012 * k)

    peak = max(1e-9, max(abs(v) for v in out))
    scale_to = 0.6 / peak
    with wave.open(os.path.join(OUT, name), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(MRATE)
        w.writeframes(b''.join(struct.pack('<h', int(max(-1, min(1, v * scale_to)) * 32767)) for v in out))


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    sfx()
    for name, song in SONGS.items():
        music(name, **song)
    print('wrote', sorted(os.listdir(OUT)))
