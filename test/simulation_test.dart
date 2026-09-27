import 'package:forge2d/forge2d.dart' show Vector2;
import 'package:floppy_swing/game/autopilot.dart';
import 'package:floppy_swing/game/config.dart';
import 'package:floppy_swing/game/level.dart';
import 'package:floppy_swing/game/ragdoll.dart';
import 'package:floppy_swing/game/simulation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

double maxJointError(Simulation sim) {
  var worst = 0.0;
  for (final j in sim.ragdoll.joints) {
    final d = (j.bodyA.worldPoint(j.localAnchorA) - j.bodyB.worldPoint(j.localAnchorB)).length;
    if (d > worst) worst = d;
  }
  return worst;
}

void stepFor(Simulation sim, double seconds) {
  for (var i = 0; i < (seconds * sim.cfg.stepsPerSecond).round(); i++) {
    sim.step();
  }
}

void main() {
  final cfg = loadPhysics();

  test('config parses and falls back to defaults', () {
    final c = PhysicsConfig.parse('{"gravity": 10}');
    expect(c.gravity, 10);
    expect(c.ropeRange, const PhysicsConfig().ropeRange);
    expect(cfg.stepsPerSecond, 60);
  });

  test('ragdoll spawns calmly and settles on the start platform', () {
    final sim = Simulation(testLevel(), cfg);
    sim.step();
    // Regression: forge2d's revolute joint used to explode on the first step.
    for (final b in sim.ragdoll.parts) {
      expect(b.linearVelocity.length, lessThan(2), reason: 'part launched on spawn');
    }
    stepFor(sim, 2);
    expect(maxJointError(sim), lessThan(0.05));
    final torso = sim.ragdoll.torso.position;
    expect((torso.x - 3).abs(), lessThan(2.5));
    expect(torso.y, lessThan(0));
    expect(sim.status, SimStatus.running);
    expect(sim.startedAt, isNull, reason: 'clock waits for the first press');
  });

  test('press grabs the highlighted anchor and release lets go', () {
    final sim = Simulation(testLevel(), cfg);
    stepFor(sim, 0.5);
    final target = sim.bestAnchor();
    expect(target, 0);
    sim.press();
    expect(sim.isAttached, isTrue);
    expect(sim.ropeAnchor, target);
    expect(sim.events.last.kind, EventKind.grab);
    stepFor(sim, 0.8);
    // Joints hold together while swinging.
    expect(maxJointError(sim), lessThan(0.2));
    sim.release();
    expect(sim.isAttached, isFalse);
    expect(sim.events.last.kind, EventKind.release);
    expect(sim.startedAt, isNotNull);
  });

  test('the first grab slings the character straight into a fast swing', () {
    final sim = Simulation(testLevel(), cfg);
    stepFor(sim, 1); // Settle on the start platform.
    sim.press();
    expect(sim.events.map((e) => e.kind), contains(EventKind.launch));
    stepFor(sim, 0.1);
    expect(sim.ragdoll.velocity.length, greaterThan(9));
    // Heading forward (towards the finish) and up.
    expect(sim.ragdoll.velocity.x, greaterThan(0));
  });

  test('a slack rope snapping tight keeps its momentum as swing speed', () {
    final level = Level.parse('''{"id": 1, "name": "x", "targetTime": 9, "start": [0, 0], "killY": 30,
      "finish": [80, -3, 4, 7], "platforms": [], "anchors": [[10, -8]]}''');
    // Grab a ring from well above it while flying towards it.
    final sim = Simulation(level, cfg, spawn: const P(5, -12.5));
    sim.ragdoll.setVelocity(Vector2(8, 0));
    sim.startedAt = 0;
    sim.press();
    var peak = 0.0, afterSnap = double.infinity;
    for (var i = 0; i < 60; i++) {
      sim.step();
      final v = sim.ragdoll.velocity.length;
      if (v > peak) {
        peak = v;
      } else if (peak > 15 && v < afterSnap) {
        afterSnap = v;
        break;
      }
    }
    // The raw rope joint used to leave barely a third of the speed.
    expect(afterSnap, greaterThan(peak * 0.75));
  });

  test('pressing with nothing in range is a miss', () {
    final level = Level.parse('''{"id": 1, "name": "x", "targetTime": 1, "start": [0, -2], "killY": 6,
      "finish": [50, 0, 2, 2], "platforms": [[0, 0, 5, 1]], "anchors": [[40, -8]]}''');
    final sim = Simulation(level, cfg);
    sim.press();
    expect(sim.isAttached, isFalse);
    expect(sim.events.last.kind, EventKind.miss);
  });

  test('touching spikes kills with a knockback, falling into the pit kills', () {
    final spiky = testLevel(extra: ', "spikes": [[0, -5, 3, 1]]');
    final sim = Simulation(spiky, cfg, spawn: const P(0, -8));
    stepFor(sim, 1.5);
    expect(sim.status, SimStatus.dead);
    expect(sim.deathCause, DeathCause.spikes);
    expect(sim.events.where((e) => e.kind == EventKind.death), hasLength(1));

    final pit = Simulation(testLevel(), cfg, spawn: const P(10, -2));
    stepFor(pit, 2);
    expect(pit.status, SimStatus.dead);
    expect(pit.deathCause, DeathCause.pit);
  });

  test('saws kill', () {
    final level = testLevel(extra: ', "saws": [{"x": 0, "y": -5, "r": 1}]');
    final sim = Simulation(level, cfg, spawn: const P(0, -8));
    stepFor(sim, 1.5);
    expect(sim.deathCause, DeathCause.saw);
  });

  test('bounce pads launch upwards', () {
    final level = testLevel(extra: ', "pads": [[0, -1, 4, 0.6]]');
    final sim = Simulation(level, cfg, spawn: const P(0, -6));
    var minVy = 0.0;
    for (var i = 0; i < 90; i++) {
      sim.step();
      if (sim.ragdoll.velocity.y < minVy) minVy = sim.ragdoll.velocity.y;
    }
    expect(sim.events.any((e) => e.kind == EventKind.bounce), isTrue);
    expect(minVy, lessThan(-cfg.bouncePadSpeed * 0.8));
  });

  test('coins, checkpoints and the finish register', () {
    final level = testLevel(
      finishX: 3.5,
      extra: ', "coins": [[3.5, -2]], "checkpoints": [[3.5, 0.5]]',
    );
    final sim = Simulation(level, cfg);
    stepFor(sim, 0.2);
    expect(sim.coinCount, 1);
    expect(sim.allCoins, isTrue);
    expect(sim.lastCheckpoint, 0);
    expect(sim.snapshot.coinTaken(0), isTrue);
  });

  test('finish zone ends the run', () {
    final level = testLevel(finishX: 3.5);
    final sim = Simulation(level, cfg);
    sim.step();
    expect(sim.status, SimStatus.finished);
    expect(sim.events.last.kind, EventKind.finish);
  });

  test('lying still with nothing in reach fails as stuck', () {
    final level = Level.parse('''{"id": 1, "name": "x", "targetTime": 1, "start": [0, -2], "killY": 6,
      "finish": [50, 0, 2, 2], "platforms": [[0, 0, 5, 1]], "anchors": [[40, -8]]}''');
    final sim = Simulation(level, cfg);
    sim.press(); // Starts the clock (a miss).
    sim.release();
    stepFor(sim, cfg.stuckTime + 2);
    expect(sim.deathCause, DeathCause.stuck);
  });

  test('simulation is deterministic for the same inputs', () {
    AutopilotRun run() => runAutopilot(
      testLevel(),
      () => Simulation(testLevel(), cfg),
      const AutopilotParams(),
      maxSeconds: 20,
    );
    final a = run(), b = run();
    expect(a.status, b.status);
    expect(a.x, b.x);
    expect(a.time, b.time);
  });

  test('snapshot mirrors body state', () {
    final sim = Simulation(testLevel(), cfg);
    stepFor(sim, 0.3);
    final s = sim.snapshot;
    final torso = sim.ragdoll.parts[Part.torso];
    expect(s.px(Part.torso), closeTo(torso.position.x, 1e-4));
    expect(s.py(Part.torso), closeTo(torso.position.y, 1e-4));
    expect(s.parts.length, Part.count * 3);
  });
}
