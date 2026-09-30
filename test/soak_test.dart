import 'dart:ui';

import 'package:floppy_swing/game/autopilot.dart';
import 'package:floppy_swing/game/game_controller.dart';
import 'package:floppy_swing/game/skins.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('long play sessions do not get slower', () {
    final cfg = loadPhysics();
    final levels = loadLevels();
    final c = GameController(level: levels[6], cfg: cfg, skin: skins.first)
      ..autopilot = Autopilot(const AutopilotParams(releaseAngle: 0.5, regrabDelay: 0.15, minFallSpeed: 1));
    c.setViewport(390, 844);
    final minuteMs = <int>[];
    var retries = 0;
    for (var minute = 0; minute < 6; minute++) {
      final sw = Stopwatch()..start();
      for (var f = 0; f < 60 * 60; f++) {
        c.tick(1 / 60);
        final rec = PictureRecorder();
        c.renderer.render(Canvas(rec), const Size(390, 844), c.frame, events: c.events, wallTime: c.wallTime);
        rec.endRecording().dispose();
        if ((c.phase == GamePhase.failed || c.phase == GamePhase.won) && c.phaseAge > 1) {
          c.autopilot = Autopilot(c.autopilot!.params);
          c.retry();
          retries++;
        }
      }
      minuteMs.add(sw.elapsedMilliseconds);
    }
    // ignore: avoid_print
    print('ms per simulated minute: $minuteMs, retries: $retries, history: ${c.history.length}');
    expect(minuteMs.last, lessThan(minuteMs[1] * 1.5));
  });
}
