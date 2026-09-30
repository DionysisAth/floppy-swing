import 'package:floppy_swing/game/level.dart';
import 'package:floppy_swing/game/ragdoll.dart';
import 'package:floppy_swing/game/simulation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge2d/forge2d.dart' show Vector2;

import 'helpers.dart';

/// A bare level: no platforms, a far-away finish, extra JSON spliced in.
Level open(String extra, {String anchors = '[]'}) => Level.parse('''{
  "id": 21, "name": "Test", "targetTime": 20, "start": [0, 0], "killY": 40,
  "finish": [200, -3, 4, 7], "platforms": [], "anchors": $anchors $extra
}''');

void steps(Simulation sim, double seconds) {
  for (var i = 0; i < (seconds * sim.cfg.stepsPerSecond).round(); i++) {
    sim.step();
  }
}

void main() {
  final cfg = loadPhysics();

  test('levels parse every World 2-5 element', () {
    final l = open(
      ''', "glass": [[5, 0, 0.4, 6]], "winds": [[10, 0, 3, 8, 0, 35]], "flips": [[20, -5, 4, 4]],
      "crumbles": [[30, 0, 4, 0.8]], "rockets": [{"x": 40, "y": 5, "angle": -90, "speed": 10, "period": 2}]''',
      anchors: '[[1, -8], [5, -8, 9, -8, 3, 0.25]]',
    );
    expect(l.world, 2);
    expect(l.anchors[1].moving, isTrue);
    expect(l.anchors[0].moving, isFalse);
    expect(l.glass, hasLength(1));
    expect(l.winds.single.strength, 35);
    expect(l.flips, hasLength(1));
    expect(l.crumbles, hasLength(1));
    expect(l.launchers.single.period, 2);
  });

  test('moving anchors move, and the rope follows them', () {
    final l = open('', anchors: '[[0, -6, 8, -6, 2]]');
    final sim = Simulation(l, cfg, spawn: const P(0, -2));
    final start = sim.anchorAt(0);
    sim.startedAt = 0;
    sim.press();
    expect(sim.isAttached, isTrue);
    var maxGap = 0.0;
    for (var i = 0; i < 60; i++) {
      sim.step();
      final a = sim.anchorAt(0);
      final h = sim.ragdoll.handWorld;
      final gap = (h - Vector2(a.x, a.y)).length - sim.snapshot.ropeLength;
      if (gap > maxGap) maxGap = gap;
    }
    expect(sim.anchorAt(0).x, isNot(closeTo(start.x, 0.5)));
    expect(sim.snapshot.ax(0), closeTo(sim.anchorAt(0).x, 1e-3));
    expect(maxGap, lessThan(0.3), reason: 'rope must stay attached to the moving ring');
  });

  test('glass smashes on a fast hit and stays solid on a slow one', () {
    final l = open(', "glass": [[3, -2, 0.4, 8]]');
    final fast = Simulation(l, cfg, spawn: const P(0, -2));
    fast.ragdoll.setVelocity(Vector2(14, 0));
    steps(fast, 0.6);
    expect(fast.events.map((e) => e.kind), contains(EventKind.shatter));
    expect(fast.snapshot.glassIsBroken(0), isTrue);
    expect(fast.ragdoll.torso.position.x, greaterThan(4), reason: 'smashes straight through');

    final slow = Simulation(l, cfg, spawn: const P(0, -2));
    slow.ragdoll.setVelocity(Vector2(3, 0));
    steps(slow, 1.0);
    expect(slow.snapshot.glassIsBroken(0), isFalse);
    expect(slow.ragdoll.torso.position.x, lessThan(3));
  });

  test('wind zones hold the character up', () {
    final calm = Simulation(open(''), cfg, spawn: const P(0, -2));
    final windy = Simulation(open(', "winds": [[0, 0, 6, 20, 0, 30]]'), cfg, spawn: const P(0, -2));
    steps(calm, 1);
    steps(windy, 1);
    expect(windy.ragdoll.torso.position.y, lessThan(calm.ragdoll.torso.position.y - 3));
  });

  test('gravity flip zones make the character fall upwards', () {
    final sim = Simulation(open(', "flips": [[0, 0, 8, 30]]'), cfg, spawn: const P(0, -2));
    steps(sim, 0.8);
    expect(sim.ragdoll.torso.position.y, lessThan(-4));
    expect(sim.events.where((e) => e.kind == EventKind.flip && e.value == 1), isNotEmpty);
  });

  test('crumbling platforms crack when touched and fall shortly after', () {
    final sim = Simulation(open(', "crumbles": [[0, 0, 5, 1]]'), cfg, spawn: const P(0, -2));
    steps(sim, 0.4);
    final crack = sim.events.where((e) => e.kind == EventKind.crumble && e.label == 'crack');
    expect(crack, hasLength(1));
    expect(sim.snapshot.crumbles[1], closeTo(0, 0.01), reason: 'still in place before the delay');
    steps(sim, cfg.crumbleDelay + 0.6);
    expect(sim.events.any((e) => e.kind == EventKind.crumble && e.label == 'fall'), isTrue);
    expect(sim.snapshot.crumbles[1], greaterThan(1), reason: 'the platform fell');
  });

  test('rockets knock the character around without killing', () {
    // Launcher right below the spawn, firing straight up.
    final l = open(', "rockets": [{"x": 0, "y": 6, "angle": -90, "speed": 14, "period": 5, "phase": 0}]');
    final sim = Simulation(l, cfg, spawn: const P(0, -2));
    sim.ragdoll.setVelocity(Vector2(0, 0));
    var hit = false;
    for (var i = 0; i < 90 && !hit; i++) {
      sim.step();
      hit = sim.events.any((e) => e.kind == EventKind.boom && e.label == 'hit');
    }
    expect(hit, isTrue);
    expect(sim.status, SimStatus.running);
    expect(sim.ragdoll.velocity.y, lessThan(-4), reason: 'blasted upwards');
    expect(sim.snapshot.explodedRockets, isNotEmpty);
  });

  test('rockets explode on walls', () {
    final l = Level.parse('''{
      "id": 81, "name": "T", "targetTime": 20, "start": [30, -20], "killY": 40,
      "finish": [200, -3, 4, 7], "platforms": [[0, -2, 4, 1]], "anchors": [],
      "rockets": [{"x": 0, "y": 6, "angle": -90, "speed": 14, "period": 5}]}''');
    final sim = Simulation(l, cfg);
    steps(sim, 1.2);
    final booms = sim.events.where((e) => e.kind == EventKind.boom).toList();
    expect(booms, isNotEmpty);
    expect(booms.first.label, isNull);
    expect(booms.first.y, closeTo(-1.5, 0.6));
  });

  test('snapshot tracks every part', () {
    final sim = Simulation(open(''), cfg);
    expect(sim.snapshot.parts, hasLength(Part.count * 3));
  });
}
