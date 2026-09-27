import 'dart:convert';
import 'dart:io';

import 'package:floppy_swing/app.dart';
import 'package:floppy_swing/game/autopilot.dart';
import 'package:floppy_swing/game/simulation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Every level must be beatable with all coins inside the target time.
///
/// `tool/check_levels.dart` searches for autopilot settings that finish each
/// level and stores them in `test/level_solutions.json`; this test replays
/// them. If a physics or level change breaks one, re-run the tool.
void main() {
  final cfg = loadPhysics();
  final levels = loadLevels();
  final solutions =
      jsonDecode(File('test/level_solutions.json').readAsStringSync()) as Map<String, dynamic>;

  test('all $levelCount campaign levels are present with unique ids', () {
    expect(levels, hasLength(levelCount));
    expect(levels.map((l) => l.id).toSet(), {for (var i = 1; i <= levelCount; i++) i});
  });

  for (final level in levels) {
    group('level ${level.id} "${level.name}"', () {
      test('is well formed', () {
        expect(level.anchors, isNotEmpty);
        expect(level.coins, isNotEmpty);
        expect(level.coins.length, lessThan(62), reason: 'coins are stored in a bit mask');
        expect(level.targetTime, greaterThan(0));
        expect(level.finish.x, greaterThan(level.start.x));
        // The ragdoll settles on the start platform; the first press must
        // reach an anchor from wherever it lies.
        final restX = level.start.x - 1.5, restY = level.start.y + 1.2;
        final startReach = level.anchors.any((a) {
          final dx = a.x - restX, dy = a.y - restY;
          return dx * dx + dy * dy < cfg.ropeRange * cfg.ropeRange;
        });
        expect(startReach, isTrue, reason: 'first anchor out of reach from the start');
        for (final c in level.checkpoints) {
          final reachable = level.anchors.any(
            (a) => (a.x - c.x).abs() < cfg.ropeRange && (a.y - (c.y - 1)).abs() < cfg.ropeRange,
          );
          expect(reachable, isTrue, reason: 'revives at a checkpoint need an anchor in reach');
        }
      });

      test('can be finished with every coin within the target time', () {
        final s = solutions['${level.id}'] as Map<String, dynamic>?;
        expect(s, isNotNull, reason: 'run `dart run tool/check_levels.dart`');
        final params = AutopilotParams(
          releaseAngle: (s!['releaseAngle'] as num).toDouble(),
          regrabDelay: (s['regrabDelay'] as num).toDouble(),
          minFallSpeed: (s['minFallSpeed'] as num).toDouble(),
        );
        final run = runAutopilot(level, () => Simulation(level, cfg), params);
        expect(run.status, SimStatus.finished);
        expect(run.coins, level.coins.length);
        expect(run.time, lessThanOrEqualTo(level.targetTime));
        // Doc: a good run should take 20-60s for people; the bot is fast.
        expect(run.time, lessThan(60));
      });
    });
  }
}
