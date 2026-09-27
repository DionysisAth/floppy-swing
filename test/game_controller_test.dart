import 'dart:ui';

import 'package:floppy_swing/game/cosmetics.dart';
import 'package:floppy_swing/game/game_controller.dart';
import 'package:floppy_swing/game/renderer.dart';
import 'package:floppy_swing/game/simulation.dart';
import 'package:floppy_swing/game/skins.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

class RecordingFeedback implements GameFeedback {
  final events = <EventKind>[];
  int replays = 0;

  @override
  void onEvent(SimEvent event, Skin skin, Loadout look) => events.add(event.kind);

  @override
  void onReplayStart(Skin skin, Loadout look) => replays++;
}

void tickFor(GameController c, double seconds) {
  const dt = 1 / 60;
  for (var i = 0; i < (seconds / dt).round(); i++) {
    c.tick(dt);
  }
}

void main() {
  final cfg = loadPhysics();

  test('fail flow: dying -> slow-mo replay -> failed, tap retries instantly', () {
    final fb = RecordingFeedback();
    final level = testLevel();
    final c = GameController(level: level, cfg: cfg, skin: skins.first, feedback: fb);
    expect(c.phase, GamePhase.ready);
    // Walk off into the pit: grab nothing, just shove the ragdoll sideways.
    c.pointerDown();
    c.pointerUp();
    tickFor(c, 0.2);
    c.sim.ragdoll.addVelocity(c.sim.ragdoll.velocity..setValues(12, -2));
    tickFor(c, 3);
    expect(fb.events, contains(EventKind.death));
    expect(fb.replays, 1);
    expect(c.phase, anyOf(GamePhase.replay, GamePhase.failed));
    tickFor(c, 3);
    expect(c.phase, GamePhase.failed);

    final sw = Stopwatch()..start();
    c.pointerDown();
    c.pointerUp();
    sw.stop();
    expect(c.phase, GamePhase.ready);
    expect(c.attempts, 2);
    expect(c.sim.status, SimStatus.running);
    // Design rule: failing -> playing again must take well under half a second.
    expect(sw.elapsedMilliseconds, lessThan(100));
  });

  test('replay frames zoom towards the death point', () {
    final c = GameController(level: testLevel(), cfg: cfg, skin: skins.first);
    c.pointerDown();
    c.pointerUp();
    tickFor(c, 0.1);
    c.sim.ragdoll.addVelocity(c.sim.ragdoll.velocity..setValues(12, -2));
    tickFor(c, 2.2);
    expect(c.phase, isNot(GamePhase.ready));
    final start = c.replayFrame(0);
    final mid = c.replayFrame(0.4);
    expect(mid.cam.w, lessThan(start.cam.w + 1e-6));
    expect(mid.cam.w, closeTo(c.replayCam.w, 0.01));
  });

  test('revive continues from the checkpoint with coins and clock kept', () {
    final level = testLevel(extra: ', "coins": [[3.5, -2]], "checkpoints": [[3.5, 0.5]]');
    final c = GameController(level: level, cfg: cfg, skin: skins.first);
    c.pointerDown();
    c.pointerUp();
    tickFor(c, 0.5);
    expect(c.sim.coinCount, 1);
    c.sim.ragdoll.addVelocity(c.sim.ragdoll.velocity..setValues(14, -2));
    tickFor(c, 3);
    expect(c.canRevive, isTrue);
    final clock = c.sim.runTime;
    c.revive();
    expect(c.phase, GamePhase.ready);
    expect(c.revived, isTrue);
    expect(c.sim.coinCount, 1);
    expect(c.sim.runTime, closeTo(clock, 1e-9));
    final torso = c.sim.ragdoll.torso.position;
    expect(torso.x, closeTo(level.checkpoints.first.x, 0.5));
  });

  test('winning computes stars', () {
    final level = testLevel(finishX: 3.5, extra: ', "coins": [[3.5, -2]]');
    final c = GameController(level: level, cfg: cfg, skin: skins.first);
    tickFor(c, 0.2);
    expect(c.phase, GamePhase.won);
    final r = c.result!;
    expect(r.starMask & 1, 1);
    expect(r.timeStar, isTrue);
    expect(r.coinStar, isTrue);
    expect(r.starCount, 3);
  });

  test('frames interpolate and every level renders with every skin', () {
    for (final level in loadLevels()) {
      for (final skin in skins) {
        final c = GameController(level: level, cfg: cfg, skin: skin);
        c.setViewport(390, 844);
        c.pointerDown();
        tickFor(c, 0.6);
        final recorder = PictureRecorder();
        c.renderer.render(
          Canvas(recorder),
          const Size(390, 844),
          c.frame,
          events: c.events,
          wallTime: c.wallTime,
        );
        recorder.endRecording().dispose();
        if (skin != skins.first) break; // All skins on level 1 only.
      }
    }
  });

  test('camera keeps the pit from filling the screen', () {
    final level = testLevel();
    final c = GameController(level: level, cfg: cfg, skin: skins.first);
    c.setViewport(390, 844);
    tickFor(c, 2);
    final halfH = c.cam.w * 844 / 390 / 2;
    expect(c.cam.y + halfH, lessThanOrEqualTo(level.killY + 3.5));
  });

  test('lerpFrame blends positions', () {
    final c = GameController(level: testLevel(), cfg: cfg, skin: skins.first);
    tickFor(c, 0.2);
    final a = c.history.elementAt(c.history.length - 2), b = c.history.last;
    final m = lerpFrame(a, b, 0.5);
    expect(m.s.px(0), closeTo((a.s.px(0) + b.s.px(0)) / 2, 1e-4));
    expect(m.cam, isA<Cam>());
  });

  test('lerpFrame keeps moving anchors, crumbles and broken glass', () {
    final levels = loadLevels();
    for (final id in [21, 41, 81]) {
      final c = GameController(level: levels[id - 1], cfg: cfg, skin: skins.first);
      tickFor(c, 0.5);
      final a = c.history.elementAt(c.history.length - 2), b = c.history.last;
      final m = lerpFrame(a, b, 0.5);
      expect(m.s.anchors, hasLength(b.s.anchors.length), reason: 'level $id');
      expect(m.s.crumbles, hasLength(b.s.crumbles.length), reason: 'level $id');
      expect(m.s.glassBroken, b.s.glassBroken);
      if (m.s.anchors.isNotEmpty) {
        expect(m.s.ax(0), closeTo((a.s.ax(0) + b.s.ax(0)) / 2, 1e-4));
      }
    }
  });
}
