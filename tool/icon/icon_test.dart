// Renders the app icon and splash logo from the game's own renderer.
//
//   flutter test tool/icon/icon_test.dart
//   python3 tool/icon/make_icons.py      # resizes into the platform folders
//
// Writes tool/icon/out/icon.png (1024, opaque, for iOS/stores),
// background.png + foreground.png (1024, the Android adaptive icon's two
// layers) and logo.png (transparent, splash screens).
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:floppy_swing/game/cosmetics.dart';
import 'package:floppy_swing/game/game_controller.dart';
import 'package:floppy_swing/game/level.dart';
import 'package:floppy_swing/game/renderer.dart';
import 'package:floppy_swing/game/simulation.dart';
import 'package:floppy_swing/game/skins.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers.dart';

const _ink = Color(0xFF2B1D14);

/// Swing from one ring and grab the pose [seconds] in, flying fast (so the
/// face is mid-scream).
Snapshot pose(double seconds) {
  final level = Level.parse('''{
    "id": 0, "name": "Icon", "targetTime": 10, "start": [0, -2], "killY": 40,
    "finish": [100, -3, 4, 7], "platforms": [[0, 0, 4, 1]], "anchors": [[2.5, -8]]}''');
  final c = GameController(level: level, cfg: loadPhysics(), skin: skins.first);
  c.pointerDown();
  for (var t = 0.0; t < seconds; t += 1 / 60) {
    c.tick(1 / 60);
  }
  final s = c.sim.snapshot;
  return Snapshot(
    t: s.t,
    parts: s.parts,
    saws: s.saws,
    ropeAnchor: s.ropeAnchor,
    ropeLength: s.ropeLength,
    targetAnchor: -1,
    coins: s.coins,
    checkpoints: s.checkpoints,
    vx: 11,
    vy: -3,
    status: s.status,
    runTime: s.runTime,
  );
}

Future<void> save(ui.Picture picture, int size, String name) async {
  final image = await picture.toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  Directory('tool/icon/out').createSync(recursive: true);
  File('tool/icon/out/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

/// Sunburst sky: warm rays fanning out from behind the character.
void background(Canvas canvas, double size, Offset centre, {double spread = 1}) {
  final rect = Rect.fromLTWH(0, 0, size, size);
  canvas.drawRect(
    rect,
    Paint()
      ..shader = ui.Gradient.radial(centre, size * 0.85 * spread, const [
        Color(0xFFFFE27A),
        Color(0xFFFFA93B),
        Color(0xFFFF6B3D),
        Color(0xFFD9365B),
      ], const [0, 0.3, 0.7, 1]),
  );
  const rays = 18;
  final ray = Paint()..color = const Color(0x22FFFFFF);
  for (var k = 0; k < rays; k += 2) {
    final a0 = k / rays * math.pi * 2, a1 = (k + 1) / rays * math.pi * 2;
    canvas.drawPath(
      Path()
        ..moveTo(centre.dx, centre.dy)
        ..lineTo(centre.dx + math.cos(a0) * size * 1.5, centre.dy + math.sin(a0) * size * 1.5)
        ..lineTo(centre.dx + math.cos(a1) * size * 1.5, centre.dy + math.sin(a1) * size * 1.5)
        ..close(),
      ray,
    );
  }
  // Soft glow right behind the hero.
  canvas.drawCircle(
    centre,
    size * 0.32 * spread,
    Paint()
      ..shader = ui.Gradient.radial(centre, size * 0.32 * spread, const [Color(0x88FFFFFF), Color(0x00FFFFFF)]),
  );
}

void coin(Canvas canvas, Offset c, double r, double squash) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.scale(squash, 1);
  canvas.drawCircle(Offset.zero, r, Paint()..color = const Color(0xFFFFC21A));
  canvas.drawCircle(Offset.zero, r * 0.62, Paint()..color = const Color(0xFFFFE27A));
  canvas.drawCircle(
    Offset.zero,
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.18
      ..color = _ink,
  );
  canvas.restore();
}

void saw(Canvas canvas, Offset c, double r, double spin) {
  final teeth = Path();
  const n = 14;
  for (var k = 0; k < n * 2; k++) {
    final a = spin + k / (n * 2) * math.pi * 2;
    final rr = k.isEven ? r : r * 0.8;
    final p = c + Offset(math.cos(a), math.sin(a)) * rr;
    k == 0 ? teeth.moveTo(p.dx, p.dy) : teeth.lineTo(p.dx, p.dy);
  }
  teeth.close();
  canvas.drawPath(teeth, Paint()..color = const Color(0xFFE63946));
  canvas.drawPath(
    teeth,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.08
      ..strokeJoin = StrokeJoin.round
      ..color = _ink,
  );
  canvas.drawCircle(c, r * 0.55, Paint()..color = const Color(0xFFD5DAE0));
  canvas.drawCircle(c, r * 0.18, Paint()..color = const Color(0xFF5E6772));
}

void ring(Canvas canvas, Offset c, double r) {
  canvas.drawCircle(
    c,
    r * 2.2,
    Paint()..shader = ui.Gradient.radial(c, r * 2.2, const [Color(0xAAFFFFFF), Color(0x00FFFFFF)]),
  );
  canvas.drawCircle(c, r, Paint()..color = const Color(0xFFF4FAFF));
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.5
      ..color = const Color(0xFF1C6FD1),
  );
  canvas.drawCircle(
    c,
    r * 1.25,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.12
      ..color = _ink,
  );
  canvas.drawCircle(c, r * 0.35, Paint()..color = const Color(0xFF2D9CFF));
}

/// Draws [draw] with a soft drop shadow and a thick white sticker outline, the
/// way mobile game icons make their hero pop off the background. [outline]
/// is in the canvas's current units (layer filters use the local transform).
void sticker(Canvas canvas, void Function(Canvas) draw, {required double outline, required Offset shadow}) {
  canvas.save();
  canvas.translate(shadow.dx, shadow.dy);
  canvas.saveLayer(
    null,
    Paint()
      ..colorFilter = const ColorFilter.mode(Color(0x66401010), BlendMode.srcIn)
      ..imageFilter = ui.ImageFilter.blur(sigmaX: outline * 1.2, sigmaY: outline * 1.2),
  );
  draw(canvas);
  canvas.restore();
  canvas.restore();
  canvas.saveLayer(
    null,
    Paint()
      ..colorFilter = const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn)
      ..imageFilter = ui.ImageFilter.dilate(radiusX: outline, radiusY: outline),
  );
  draw(canvas);
  canvas.restore();
  draw(canvas);
}

void main() {
  test('icon', () async {
    const size = 1024.0;
    final level = Level.parse('''{
      "id": 0, "name": "Icon", "targetTime": 10, "start": [0, -2], "killY": 40,
      "finish": [100, -3, 4, 7], "platforms": [], "anchors": [[2.5, -8]]}''');
    final renderer = WorldRenderer(level, skins.first)..look = const Loadout(rope: 'rope');
    final s = pose(1.05);
    final torso = Offset(s.px(0), s.py(0));
    final hand = WorldRenderer.handPosition(s);
    final toRing = const Offset(2.5, -8) - hand;
    final anchor = hand + toRing / toRing.distance * 1.15;

    // icon: the whole scene (iOS, stores, legacy Android).
    // background / foreground: Android adaptive icon layers. The launcher
    // shows roughly the middle 2/3 of these, masked to a circle or squircle.
    // logo: hero only, for the splash screens.
    for (final (name, back, hero, zoom) in [
      ('icon', true, true, 1.08),
      ('background', true, false, 0.62),
      ('foreground', false, true, 0.62),
      ('logo', false, true, 0.9),
    ]) {
      final rec = ui.PictureRecorder();
      final canvas = Canvas(rec);
      // World units -> icon pixels, framed on the space between ring and body.
      final centre = torso + const Offset(-0.34, -0.58);
      final scale = size / 3.7 * zoom;
      Offset px(Offset w) => Offset(size / 2 + (w.dx - centre.dx) * scale, size / 2 + (w.dy - centre.dy) * scale);
      // Adaptive layers only show their middle 2/3: squeeze the sunburst to match.
      if (back) background(canvas, size, px(torso), spread: name == 'icon' ? 1 : 0.7);

      canvas.save();
      canvas.translate(size / 2, size / 2);
      canvas.scale(scale);
      canvas.translate(-centre.dx, -centre.dy);

      if (back) {
        // The swing: a wide translucent arc sweeping through the hero.
        canvas.drawArc(
          Rect.fromCircle(center: anchor, radius: (torso - anchor).distance),
          0.35,
          1.9,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 0.34
            ..color = const Color(0x33FFFFFF),
        );
        // Speed lines streaming behind the flight.
        final line = Paint()
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xAAFFFFFF);
        for (final (dy, len, w) in [(-0.6, 1.2, 0.06), (-0.2, 1.6, 0.08), (0.3, 1.3, 0.07), (0.75, 1.0, 0.06)]) {
          line.strokeWidth = w;
          final start = torso + Offset(-0.75, dy);
          canvas.drawLine(start, start + Offset(-len, len * 0.28), line);
        }
        // A saw lurking below and coins flying by.
        saw(canvas, torso + const Offset(-1.35, 1.2), 0.55, 0.3);
        coin(canvas, torso + const Offset(0.95, -0.95), 0.19, 1);
        coin(canvas, torso + const Offset(1.3, -0.2), 0.15, 0.55);
        coin(canvas, torso + const Offset(1.05, 0.6), 0.13, 0.8);
        // Sparkles.
        for (final (o, r) in [
          (const Offset(0.5, -1.75), 0.16),
          (const Offset(-0.9, -0.9), 0.1),
          (const Offset(1.4, 1.05), 0.12),
          (const Offset(-1.6, 0.2), 0.08),
        ]) {
          final p = torso + o;
          final star = Path();
          for (var k = 0; k < 8; k++) {
            final a = k / 8 * math.pi * 2;
            final rr = k.isEven ? r : r * 0.35;
            final q = p + Offset(math.cos(a), math.sin(a)) * rr;
            k == 0 ? star.moveTo(q.dx, q.dy) : star.lineTo(q.dx, q.dy);
          }
          canvas.drawPath(star..close(), Paint()..color = const Color(0xFFFFFFFF));
        }
      }
      if (hero) {
        // A fiery trail behind the hero (outside the sticker: it's a glow).
        final trail = [
          for (var k = 16; k >= 0; k--) torso + Offset(-k * 0.09, k * 0.03 + math.sin(k * 0.4) * 0.04),
        ];
        renderer.drawTrailStyled(canvas, trail, 0.4, 'fire');
        ring(canvas, anchor, 0.34);
        sticker(
          canvas,
          (c) {
            renderer.drawRopeStyled(c, hand, Offset.lerp(hand, anchor, 0.5)! + const Offset(0.05, 0.08), anchor, 0, 'rope');
            renderer.drawRagdoll(c, s, skins.first, 0.3);
          },
          outline: 13 / 1024 * 3.7, // ~13 px at full zoom, in world units
          shadow: const Offset(0.05, 0.08),
        );
      }
      canvas.restore();
      await save(rec.endRecording(), size.toInt(), name);
    }
  });
}
