// Renders the app icon and splash logo from the game's own renderer.
//
//   flutter test tool/icon/icon_test.dart
//   python3 tool/icon/make_icons.py      # resizes into the platform folders
//
// Writes tool/icon/out/icon.png (1024, opaque, for iOS/stores),
// foreground.png (1024, transparent, Android adaptive icon) and logo.png
// (transparent, splash screens).
import 'dart:io';
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

/// Swing from one ring and grab the pose [seconds] in.
Snapshot pose(double seconds) {
  final level = Level.parse('''{
    "id": 0, "name": "Icon", "targetTime": 10, "start": [0, -2], "killY": 40,
    "finish": [100, -3, 4, 7], "platforms": [[0, 0, 4, 1]], "anchors": [[2.5, -8]]}''');
  final c = GameController(level: level, cfg: loadPhysics(), skin: skins.first);
  c.pointerDown();
  for (var t = 0.0; t < seconds; t += 1 / 60) {
    c.tick(1 / 60);
  }
  return c.sim.snapshot;
}

Future<void> save(ui.Picture picture, int size, String name) async {
  final image = await picture.toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  Directory('tool/icon/out').createSync(recursive: true);
  File('tool/icon/out/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  test('icon', () async {
    const size = 1024;
    final level = Level.parse('''{
      "id": 0, "name": "Icon", "targetTime": 10, "start": [0, -2], "killY": 40,
      "finish": [100, -3, 4, 7], "platforms": [], "anchors": [[2.5, -8]]}''');
    final renderer = WorldRenderer(level, skins.first)..look = const Loadout(rope: 'rope');
    final times = Platform.environment['ICON_TIMES']?.split(',').map(double.parse).toList() ?? [1.05];
    for (final t in times) {
      final s = pose(t);
      for (final (name, background, zoom) in [('icon', true, 1.0), ('foreground', false, 0.72), ('logo', false, 1.0)]) {
        final rec = ui.PictureRecorder();
        final canvas = Canvas(rec);
        if (background) {
          canvas.drawRect(
            const Rect.fromLTWH(0, 0, 1024, 1024),
            Paint()
              ..shader = ui.Gradient.linear(const Offset(0, 0), const Offset(0, 1024), const [
                Color(0xFF3F9BE0),
                Color(0xFF9CD6FF),
                Color(0xFFFFE9B8),
              ], const [0, 0.6, 1]),
          );
          // A sun and a hill for flavour.
          canvas.drawCircle(const Offset(800, 230), 120, Paint()..color = const Color(0x66FFF3B0));
          canvas.drawCircle(const Offset(800, 230), 80, Paint()..color = const Color(0xFFFFF3B0));
          canvas.drawOval(const Rect.fromLTWH(-200, 820, 1400, 500), Paint()..color = const Color(0xFF74CA52));
        }
        // Frame the anchor and body: centre between them.
        // Show a short stretch of rope so the character fills the icon.
        final hand = WorldRenderer.handPosition(s);
        final toRing = const Offset(2.5, -8) - hand;
        final anchor = hand + toRing / toRing.distance * 2.4;
        final torso = Offset(s.px(0), s.py(0));
        final centre = Offset((anchor.dx + torso.dx) / 2 + 0.2, (anchor.dy + torso.dy) / 2 + 0.35);
        final scale = size / 5.0 * zoom;
        canvas.translate(size / 2, size / 2);
        canvas.scale(scale);
        canvas.translate(-centre.dx, -centre.dy);
        renderer.drawRopeStyled(canvas, hand, Offset.lerp(hand, anchor, 0.5)!, anchor, 0, 'rope');
        // Anchor ring.
        final ring = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.22
          ..color = const Color(0xFF1C6FD1);
        canvas.drawCircle(anchor, 0.42, Paint()..color = const Color(0xFFF4FAFF));
        canvas.drawCircle(anchor, 0.42, ring);
        canvas.drawCircle(anchor, 0.14, Paint()..color = const Color(0xFF2D9CFF));
        renderer.drawRagdoll(canvas, s, skins.first, 0.3);
        await save(rec.endRecording(), size, times.length == 1 ? name : '${name}_$t');
      }
    }
  });
}
