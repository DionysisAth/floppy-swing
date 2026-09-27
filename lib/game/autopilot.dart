import 'dart:math' as math;

import 'level.dart';
import 'simulation.dart';

/// Tunable knobs for [Autopilot].
class AutopilotParams {
  const AutopilotParams({
    this.releaseAngle = 0.6,
    this.regrabDelay = 0.2,
    this.minFallSpeed = -2,
    this.maxHold = 4.0,
  });

  /// Let go once the rope has swung this far (radians) past straight-down,
  /// in the direction of travel.
  final double releaseAngle;

  /// Minimum seconds between letting go and grabbing again.
  final double regrabDelay;

  /// Only grab once vertical speed (y down) is above this, i.e. near the top
  /// of a jump or falling.
  final double minFallSpeed;

  /// Safety: let go after holding this long.
  final double maxHold;

  @override
  String toString() =>
      'release=${releaseAngle.toStringAsFixed(2)} regrab=$regrabDelay '
      'fall=$minFallSpeed hold=$maxHold';
}

/// A simple closed-loop "player" that decides when to press and release.
///
/// Used to prove every level can be finished (see `test/levels_test.dart`)
/// and to play the attract-mode demo behind the main menu.
class Autopilot {
  Autopilot(this.params, {this.startDelay = 1.0});

  /// Seconds to wait before the first press.
  final double startDelay;

  final AutopilotParams params;
  double _releasedAt = -100;
  double _grabbedAt = 0;
  bool _pressed = false;

  /// Call once per step before [Simulation.step].
  void drive(Simulation sim) {
    if (sim.status != SimStatus.running) {
      if (_pressed) sim.release();
      _pressed = false;
      return;
    }
    final torso = sim.ragdoll.torso.position;
    final v = sim.ragdoll.velocity;
    final goingRight = sim.level.finish.x >= torso.x;

    if (_pressed && sim.isAttached) {
      final a = sim.anchorAt(sim.ropeAnchor);
      // Angle of the rope measured from straight down, positive towards the
      // finish.
      final dx = (torso.x - a.x) * (goingRight ? 1 : -1);
      final angle = math.atan2(dx, torso.y - a.y);
      final forward = v.x * (goingRight ? 1 : -1) > 0.5;
      final rising = v.y < 0;
      if ((angle > params.releaseAngle && forward && rising) ||
          sim.t - _grabbedAt > params.maxHold) {
        sim.release();
        _pressed = false;
        _releasedAt = sim.t;
      }
      return;
    }

    if (_pressed && !sim.isAttached) {
      // Pressed but nothing in range yet: the sim keeps trying on its own.
      return;
    }

    // Like a player, wait for the ragdoll to flop onto the start platform
    // before the first press (which proves the first anchor is reachable).
    if (sim.startedAt == null && sim.t < startDelay) return;
    if (sim.t - _releasedAt < params.regrabDelay) return;
    if (sim.startedAt != null && v.y < params.minFallSpeed) return;
    final best = sim.bestAnchor();
    if (best < 0) return;
    final a = sim.anchorAt(best);
    // Don't grab anchors well behind us (unless we're stuck and slow).
    final behind = (a.x - torso.x) * (goingRight ? 1 : -1) < -1.0;
    if (behind && v.length > 3) return;
    sim.press();
    _pressed = true;
    _grabbedAt = sim.t;
  }
}

/// Result of running the autopilot on a level.
class AutopilotRun {
  const AutopilotRun(this.params, this.status, this.time, this.coins, this.x, [this.events = const []]);
  final AutopilotParams params;
  final SimStatus status;
  final double time;
  final int coins;

  /// How far the run got horizontally.
  final double x;

  /// Everything that happened during the run.
  final List<SimEvent> events;

  bool get finished => status == SimStatus.finished;
}

/// Parameter sets the level checker tries, cheapest-to-find first.
Iterable<AutopilotParams> autopilotSearchSpace() sync* {
  for (final release in [0.5, 0.7, 0.35, 0.9, 0.2, 1.1]) {
    for (final regrab in [0.15, 0.35, 0.05, 0.6]) {
      for (final fall in [-2.0, 1.0, -6.0, 4.0]) {
        yield AutopilotParams(
          releaseAngle: release,
          regrabDelay: regrab,
          minFallSpeed: fall,
        );
      }
    }
  }
}

/// Plays [level] with [params] until it ends or [maxSeconds] pass.
AutopilotRun runAutopilot(
  Level level,
  Simulation Function() create,
  AutopilotParams params, {
  double maxSeconds = 90,
}) {
  final sim = create();
  final pilot = Autopilot(params);
  final steps = (maxSeconds * sim.cfg.stepsPerSecond).round();
  for (var i = 0; i < steps && sim.status == SimStatus.running; i++) {
    pilot.drive(sim);
    sim.step();
  }
  return AutopilotRun(
    params,
    sim.status,
    sim.runTime,
    sim.coinCount,
    sim.ragdoll.torso.position.x,
    sim.events,
  );
}
