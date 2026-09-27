import 'dart:ui';

import 'package:floppy_swing/game/autopilot.dart';
import 'package:floppy_swing/game/cosmetics.dart';
import 'package:floppy_swing/game/game_controller.dart';
import 'package:floppy_swing/game/simulation.dart';
import 'package:floppy_swing/game/skins.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  final cfg = loadPhysics();
  final levels = loadLevels();

  GameController finishLevel1({Loadout look = const Loadout()}) {
    final c = GameController(level: levels.first, cfg: cfg, skin: skins.first, look: look);
    c.setViewport(390, 844);
    c.autopilot = Autopilot(const AutopilotParams(releaseAngle: 0.5, regrabDelay: 0.15, minFallSpeed: 1));
    for (var i = 0; i < 60 * 30 && c.phase != GamePhase.won; i++) {
      c.tick(1 / 60);
    }
    expect(c.phase, GamePhase.won);
    return c;
  }

  test('every victory dance throws the character around after the finish', () {
    for (final dance in cosmetics.where((c) => c.kind == CosmeticKind.dance)) {
      final c = finishLevel1(look: Loadout(dance: dance.id));
      var minVy = 0.0, maxSpin = 0.0;
      for (var i = 0; i < 90; i++) {
        c.tick(1 / 60);
        final v = c.sim.ragdoll.velocity;
        if (v.y < minVy) minVy = v.y;
        final w = c.sim.ragdoll.torso.angularVelocity.abs();
        if (w > maxSpin) maxSpin = w;
      }
      expect(minVy, lessThan(-4), reason: '${dance.id} should jump');
      if (dance.id == 'backflip' || dance.id == 'spin') {
        expect(maxSpin, greaterThan(8), reason: '${dance.id} should spin');
      }
    }
  });

  test('a finished run records a ghost path in step with the clock', () {
    final c = finishLevel1();
    final g = c.recordedGhost;
    expect(g.length % 4, 0);
    expect(g.length ~/ 4, greaterThan(10));
    for (var i = 4; i < g.length; i += 4) {
      expect(g[i], greaterThan(g[i - 4]), reason: 'times increase');
    }
    expect(g[g.length - 4], closeTo(c.result!.time, 1e-3));
    c.retry();
    expect(c.recordedGhost, isEmpty);
  });

  test('every rope, trail and fail effect renders, with and without a ghost', () {
    final c = finishLevel1();
    final ghost = c.recordedGhost;
    for (final item in cosmetics) {
      final look = Loadout(
        rope: item.kind == CosmeticKind.rope ? item.id : 'rope',
        trail: item.kind == CosmeticKind.trail ? item.id : 'swoosh',
        failEffect: item.kind == CosmeticKind.failEffect ? item.id : 'classic',
      );
      final g = GameController(level: levels[2], cfg: cfg, skin: skins.last, look: look);
      g.setViewport(390, 844);
      g.renderer.ghost = ghost;
      g.pointerDown();
      for (var i = 0; i < 60; i++) {
        g.tick(1 / 60);
      }
      g.pointerUp();
      // Force a fail so the fail effect draws too.
      g.sim.ragdoll.setVelocity(g.sim.ragdoll.velocity..setValues(0, 40));
      for (var i = 0; i < 60 && g.phase != GamePhase.replay; i++) {
        g.tick(1 / 60);
      }
      final rec = PictureRecorder();
      final f = g.frame;
      g.renderer.render(Canvas(rec), const Size(390, 844), f, events: g.events, wallTime: g.wallTime, trail: g.trailAt(f.s.t));
      rec.endRecording().dispose();
    }
    // All skins, including the season exclusives.
    for (final skin in skins) {
      final g = GameController(level: levels.first, cfg: cfg, skin: skin);
      g.tick(1 / 60);
      final rec = PictureRecorder();
      g.renderer.render(Canvas(rec), const Size(390, 844), g.frame, events: g.events);
      rec.endRecording().dispose();
    }
  });

  test('the ragdoll in a dying frame still has a status', () {
    // Guard for the fail-effect test above actually reaching a death.
    final g = GameController(level: levels[2], cfg: cfg, skin: skins.first);
    g.pointerDown();
    for (var i = 0; i < 60; i++) {
      g.tick(1 / 60);
    }
    g.pointerUp();
    g.sim.ragdoll.setVelocity(g.sim.ragdoll.velocity..setValues(0, 40));
    for (var i = 0; i < 120 && g.sim.status == SimStatus.running; i++) {
      g.tick(1 / 60);
    }
    expect(g.sim.status, SimStatus.dead);
  });
}
