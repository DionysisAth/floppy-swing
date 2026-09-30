// Renders the artwork for the Google Play feature graphic (1024x500, the
// banner at the top of the listing) in the app icon's style. The title is
// added by tool/store/make_store_assets.py.
//
//   flutter test tool/store/feature_art_test.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:floppy_swing/game/cosmetics.dart';
import 'package:floppy_swing/game/level.dart';
import 'package:floppy_swing/game/renderer.dart';
import 'package:floppy_swing/game/skins.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../icon/icon_test.dart' show background, coin, pose, ring, saw, sticker;

void main() {
  test('feature graphic art', () async {
    const w = 2048.0, h = 1000.0;
    final level = Level.parse('''{
      "id": 0, "name": "Art", "targetTime": 10, "start": [0, -2], "killY": 40,
      "finish": [100, -3, 4, 7], "platforms": [], "anchors": [[2.5, -8]]}''');
    final renderer = WorldRenderer(level, skinById('floppy'))..look = const Loadout(rope: 'rope');
    final s = pose(1.05);
    final torso = Offset(s.px(0), s.py(0));
    final hand = WorldRenderer.handPosition(s);
    final toRing = const Offset(2.5, -8) - hand;
    final anchor = hand + toRing / toRing.distance * 1.15;

    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    // The hero sits in the right third; the title goes on the left.
    final heroAt = Offset(w * 0.8, h * 0.5);
    const scale = h / 4.6;
    background(canvas, w, heroAt, spread: 0.75);
    // Bottom band so the title reads well.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, const Offset(w * 0.6, 0), const [
          Color(0x55D9365B),
          Color(0x00D9365B),
        ]),
    );
    canvas.save();
    canvas.translate(heroAt.dx, heroAt.dy);
    canvas.scale(scale);
    canvas.translate(-torso.dx, -torso.dy);

    canvas.drawArc(
      Rect.fromCircle(center: anchor, radius: (torso - anchor).distance),
      0.35,
      1.9,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 0.3
        ..color = const Color(0x33FFFFFF),
    );
    final line = Paint()
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xAAFFFFFF);
    for (final (dy, len, lw) in [(-0.6, 1.6, 0.06), (-0.2, 2.2, 0.08), (0.3, 1.8, 0.07), (0.75, 1.3, 0.06)]) {
      line.strokeWidth = lw;
      final start = torso + Offset(-0.75, dy);
      canvas.drawLine(start, start + Offset(-len, len * 0.28), line);
    }
    saw(canvas, torso + const Offset(-1.9, 1.25), 0.55, 0.3);
    saw(canvas, torso + const Offset(2.4, 1.5), 0.42, 1.1);
    for (final (o, r, sq) in [
      (const Offset(0.95, -0.95), 0.19, 1.0),
      (const Offset(1.4, -0.25), 0.15, 0.55),
      (const Offset(1.15, 0.6), 0.13, 0.8),
      (const Offset(2.0, -1.0), 0.16, 0.9),
      (const Offset(2.5, -0.1), 0.13, 0.6),
    ]) {
      coin(canvas, torso + o, r, sq);
    }
    for (final (o, r) in [
      (const Offset(0.5, -1.75), 0.16),
      (const Offset(-1.2, -1.1), 0.1),
      (const Offset(1.6, 1.05), 0.12),
      (const Offset(-2.2, 0.2), 0.08),
      (const Offset(2.9, -1.3), 0.1),
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
      outline: 13 / scale,
      shadow: const Offset(0.05, 0.08),
    );
    canvas.restore();

    final image = await rec.endRecording().toImage(w.toInt(), h.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    Directory('tool/store/out').createSync(recursive: true);
    File('tool/store/out/feature_art.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}
