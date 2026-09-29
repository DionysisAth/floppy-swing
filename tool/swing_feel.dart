// ignore_for_file: avoid_print
// How does swinging feel to a person? Plays every campaign level like a
// player would (slower and sloppier than the level-checking bot: presses
// late, holds until the rope is well forward, waits a moment before the next
// press) in a few different timing styles, and reports:
//
// - first swing: how long the first press holds before letting go, and the
//   speed it lets go at.
// - swings: speed at each release, and speed gained during the swing.
// - how many runs finish (with no retries).
//
//   dart run tool/swing_feel.dart [physics.json] [-v]
import 'dart:io';
import 'dart:math' as math;

import 'package:floppy_swing/game/config.dart';
import 'package:floppy_swing/game/level.dart';
import 'package:floppy_swing/game/simulation.dart';

import 'src/level_tools.dart';

class _Style {
  const _Style(this.releaseAngle, this.reaction, this.pressVy, this.firstPress);

  /// Let go once the rope is this far (radians) past straight down.
  final double releaseAngle;

  /// Seconds after letting go before pressing again.
  final double reaction;

  /// Press again once vertical speed (y down) is above this.
  final double pressVy;

  /// Seconds into the level of the first press.
  final double firstPress;
}

void main(List<String> argv) {
  final path = argv.firstWhere((a) => a.endsWith('.json'), orElse: () => 'assets/config/physics.json');
  final cfg = PhysicsConfig.parse(File(path).readAsStringSync());
  final verbose = argv.contains('-v');
  final styles = [
    for (final r in [0.6, 0.9])
      for (final re in [0.2, 0.35])
        for (final pv in [-3.0, 0.0, 3.0])
          for (final fp in [0.05, 0.6]) _Style(r, re, pv, fp),
  ];
  var runs = 0, wins = 0;
  final firstHold = <double>[], firstSpeed = <double>[], releaseSpeed = <double>[], gain = <double>[];
  for (var id = 1; id <= 100; id++) {
    final level = Level.parse(File(levelPath(id)).readAsStringSync());
    var levelWins = 0;
    for (final style in styles) {
      runs++;
      final sim = _play(level, cfg, style, (hold, speed, gained, first) {
        if (first) {
          firstHold.add(hold);
          firstSpeed.add(speed);
        }
        releaseSpeed.add(speed);
        gain.add(gained);
      });
      if (sim.status == SimStatus.finished) {
        wins++;
        levelWins++;
      }
    }
    if (verbose) print('level $id: finished $levelWins/${styles.length}');
  }
  double mean(List<double> x) => x.isEmpty ? 0 : x.reduce((a, b) => a + b) / x.length;
  print('first swing: let go after ${mean(firstHold).toStringAsFixed(2)}s at ${mean(firstSpeed).toStringAsFixed(1)} m/s');
  print('swings: let go at ${mean(releaseSpeed).toStringAsFixed(1)} m/s, '
      'gaining ${mean(gain).toStringAsFixed(2)} m/s on the rope');
  print('finished ${(100 * wins / runs).toStringAsFixed(1)}% of $runs first attempts');
}

Simulation _play(
  Level level,
  PhysicsConfig cfg,
  _Style style,
  void Function(double hold, double speed, double gained, bool first) onRelease,
) {
  final sim = Simulation(level, cfg);
  while (sim.t < style.firstPress) {
    sim.step();
  }
  sim.press();
  var held = true, first = true;
  var releasedAt = -1.0, grabbedAt = sim.t, grabSpeed = sim.ragdoll.velocity.length;
  while (sim.status == SimStatus.running && sim.t < 40) {
    final torso = sim.ragdoll.torso.position;
    final v = sim.ragdoll.velocity;
    final dir = level.finish.x >= torso.x ? 1 : -1;
    if (held && sim.isAttached) {
      final a = sim.anchorAt(sim.ropeAnchor);
      final angle = math.atan2((torso.x - a.x) * dir, torso.y - a.y);
      if ((angle > style.releaseAngle && v.y < 0 && v.x * dir > 0) || sim.t - grabbedAt > 3) {
        onRelease(sim.t - grabbedAt, v.length, v.length - grabSpeed, first);
        first = false;
        sim.release();
        held = false;
        releasedAt = sim.t;
      }
    } else if (!held && sim.t - releasedAt > style.reaction && v.y > style.pressVy && sim.bestAnchor() >= 0) {
      sim.press();
      held = true;
      grabbedAt = sim.t;
      grabSpeed = v.length;
    }
    final wasAttached = sim.isAttached;
    sim.step();
    if (held && !wasAttached && sim.isAttached) {
      // Held early; the rope caught once a ring came into range.
      grabbedAt = sim.t;
      grabSpeed = v.length;
    }
  }
  return sim;
}
