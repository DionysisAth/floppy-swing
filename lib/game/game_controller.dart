import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';

import 'autopilot.dart';
import 'config.dart';
import 'cosmetics.dart';
import 'course_builder.dart';
import 'level.dart';
import 'ragdoll.dart';
import 'renderer.dart';
import 'simulation.dart';
import 'skins.dart';

enum GamePhase {
  /// Level loaded, waiting for the first press (clock not running).
  ready,
  playing,

  /// Just died: the ragdoll keeps flailing for a moment in real time.
  dying,

  /// Slow-motion replay of the fail.
  replay,

  /// Fail panel is showing. Any tap retries.
  failed,
  won,
}

/// How a level is being played.
enum PlayMode {
  campaign,

  /// Today's challenge: no revives, so scores stay fair.
  daily,

  /// One long generated course until you fail. No revives either.
  endless,
}

/// Score for an Endless run.
class EndlessResult {
  const EndlessResult({required this.distance, required this.style, required this.coins});

  /// Metres travelled from the start.
  final int distance;
  final int style;
  final int coins;

  int get score => distance + style;
}

/// Receives gameplay events for audio and haptics.
abstract class GameFeedback {
  void onEvent(SimEvent event, Skin skin, Loadout look);
  void onReplayStart(Skin skin, Loadout look);
}

/// Stars and numbers for a finished run.
class RunResult {
  const RunResult({
    required this.time,
    required this.targetTime,
    required this.coins,
    required this.totalCoins,
    required this.style,
    required this.revived,
  });

  final double time;
  final double targetTime;
  final int coins;
  final int totalCoins;
  final int style;
  final bool revived;

  bool get timeStar => time <= targetTime;
  bool get coinStar => coins >= totalCoins;

  /// Bit mask: 1 = finished, 2 = beat target time, 4 = all coins.
  int get starMask => 1 | (timeStar ? 2 : 0) | (coinStar ? 4 : 0);
  int get starCount => 1 + (timeStar ? 1 : 0) + (coinStar ? 1 : 0);
}

/// Drives one level: fixed-step simulation, camera, input, instant retry,
/// slow-motion fail replay and checkpoint revives. Knows nothing about
/// Flutter widgets; the game screen renders [frame] and listens for phase
/// changes.
class GameController extends ChangeNotifier {
  GameController({
    required this.level,
    required this.cfg,
    required Skin skin,
    Loadout look = const Loadout(),
    this.feedback,
    this.mode = PlayMode.campaign,
  }) : renderer = WorldRenderer(level, skin, endless: mode == PlayMode.endless),
       _skin = skin,
       _look = look {
    renderer.look = look;
    _newSim(Simulation(level, cfg));
  }

  final Level level;
  final PhysicsConfig cfg;
  final PlayMode mode;
  final WorldRenderer renderer;
  GameFeedback? feedback;
  Skin _skin;

  /// When set, the autopilot plays instead of the player (menu demo).
  Autopilot? autopilot;

  Skin get skin => _skin;
  set skin(Skin s) {
    _skin = s;
    renderer.skin = s;
  }

  Loadout _look;
  Loadout get look => _look;
  set look(Loadout l) {
    _look = l;
    renderer.look = l;
    sim.dance = l.dance;
  }

  late Simulation sim;
  GamePhase phase = GamePhase.ready;
  bool paused = false;

  /// Number of attempts at this level in this session (for analytics and the
  /// "don't show ads right after a fail" rule).
  int attempts = 1;
  bool revived = false;
  RunResult? result;

  /// This run's torso path as (run time, x, y, angle) samples, saved as a
  /// ghost when it beats the best time.
  final List<double> _ghostRec = [];
  Float32List get recordedGhost => Float32List.fromList(_ghostRec);

  /// Ghost samples are taken every this many physics steps (15 Hz).
  static const ghostEvery = 4;

  /// Endless: the run's score, set when it ends.
  EndlessResult? endlessResult;

  /// Endless: furthest distance (metres) this run.
  double distance = 0;

  /// Endless: world whose look and mechanics the player is in, and when
  /// they entered it (wall clock), for the zone banner and music.
  int zoneWorld = 1;
  double zoneEnteredAt = -10;

  /// Seconds of history kept for replays and clip export.
  static const historySeconds = 8.0;
  static const replaySlowMo = 0.4;
  static const replayBefore = 0.4;
  static const replayAfter = 0.35;
  static const flailTime = 0.45;

  /// Metres visible across the screen when moving slowly.
  static const baseViewWidth = 10.5;

  final ListQueue<Frame> history = ListQueue();
  Cam cam = const Cam(0, 0, baseViewWidth);
  double _aspect = 2.0;

  double wallTime = 0;
  double _acc = 0;
  int _eventCursor = 0;
  int _pointers = 0;

  // Death / replay bookkeeping (wall-clock).
  double _phaseStartedAt = 0;
  double _deathSimTime = 0;
  Cam _replayCam = const Cam(0, 0, 7);
  double _replayClock = 0;

  /// Frames kept after the sim stops, so the fail panel has something to
  /// look at without simulating forever.
  static const maxPostSimSeconds = 4.0;

  List<SimEvent> get events => sim.events;
  double get phaseAge => wallTime - _phaseStartedAt;
  double get deathSimTime => _deathSimTime;

  // ---------------------------------------------------------------- setup

  void _newSim(Simulation s) {
    sim = s..dance = _look.dance;
    _ghostRec.clear();
    _eventCursor = 0;
    _acc = 0;
    history.clear();
    final p = s.ragdoll.torso.position;
    cam = Cam(p.x + 2, p.y - 2, baseViewWidth);
    history.add(Frame(s.snapshot, cam));
  }

  /// Screen height / width, so the camera can keep the pit in view.
  void setViewport(double width, double height) {
    if (width > 0) _aspect = height / width;
  }

  void _setPhase(GamePhase p) {
    phase = p;
    _phaseStartedAt = wallTime;
    notifyListeners();
  }

  // ---------------------------------------------------------------- input

  void pointerDown() {
    _pointers++;
    if (_pointers != 1 || paused) return;
    switch (phase) {
      case GamePhase.ready:
      case GamePhase.playing:
        sim.press();
      case GamePhase.dying:
      case GamePhase.replay:
      case GamePhase.failed:
        // Tapping skips everything and retries immediately. A tiny guard
        // stops the tap that caused the death from also skipping it.
        if (phaseAge > 0.15 || phase != GamePhase.dying) retry();
      case GamePhase.won:
        break;
    }
  }

  void pointerUp() {
    _pointers = math.max(0, _pointers - 1);
    if (_pointers == 0) sim.release();
  }

  void pointerCancelAll() {
    _pointers = 0;
    sim.release();
  }

  // ------------------------------------------------------------- actions

  /// Restart the level from scratch. Deliberately cheap: rebuilding the
  /// physics world takes a millisecond or two.
  void retry() {
    attempts++;
    revived = false;
    result = null;
    endlessResult = null;
    distance = 0;
    zoneWorld = 1;
    zoneEnteredAt = -10;
    _newSim(Simulation(level, cfg));
    _setPhase(GamePhase.ready);
  }

  bool get canRevive =>
      mode == PlayMode.campaign &&
      (phase == GamePhase.failed || phase == GamePhase.replay || phase == GamePhase.dying) &&
      sim.lastCheckpoint >= 0;

  /// Continue from the last checkpoint reached, keeping coins and the clock.
  void revive() {
    final cp = sim.lastCheckpoint;
    if (cp < 0) return;
    final c = level.checkpoints[cp];
    final old = sim;
    revived = true;
    _newSim(
      Simulation(
        level,
        cfg,
        spawn: P(c.x, c.y - 2.2),
        runTimeOffset: old.runTime,
        collectedCoins: old.collectedCoins,
        reachedCheckpoints: old.reachedCheckpoints,
        styleScore: old.styleScore,
      )..lastCheckpoint = cp,
    );
    _setPhase(GamePhase.ready);
  }

  void setPaused(bool value) {
    if (paused == value) return;
    paused = value;
    if (paused) pointerCancelAll();
    notifyListeners();
  }

  // -------------------------------------------------------------- update

  void tick(double dt) {
    if (paused) return;
    dt = math.min(dt, 0.1);
    wallTime += dt;

    final simulating = switch (phase) {
      GamePhase.ready || GamePhase.playing => true,
      _ => sim.t - (sim.endedAt ?? sim.t) < maxPostSimSeconds,
    };
    if (simulating) {
      _acc += dt;
      final step = cfg.dt;
      while (_acc >= step) {
        _acc -= step;
        if (phase == GamePhase.ready || phase == GamePhase.playing) {
          autopilot?.drive(sim);
        }
        sim.step();
        _afterStep(step);
      }
    }

    switch (phase) {
      case GamePhase.dying:
        if (phaseAge >= flailTime) {
          _replayClock = 0;
          feedback?.onReplayStart(_skin, _look);
          _setPhase(GamePhase.replay);
        }
      case GamePhase.replay:
        _replayClock += dt * replaySlowMo;
        if (_replayClock >= replayBefore + replayAfter) _setPhase(GamePhase.failed);
      case GamePhase.ready:
      case GamePhase.playing:
      case GamePhase.failed:
      case GamePhase.won:
        break;
    }
  }

  void _afterStep(double dt) {
    _updateCamera(dt);
    history.add(Frame(sim.snapshot, cam));
    final maxFrames = (historySeconds * cfg.stepsPerSecond).round();
    while (history.length > maxFrames) {
      history.removeFirst();
    }

    final evs = sim.events;
    while (_eventCursor < evs.length) {
      final e = evs[_eventCursor++];
      feedback?.onEvent(e, _skin, _look);
      if (e.kind == EventKind.death && phase != GamePhase.dying) {
        if (mode == PlayMode.endless) {
          endlessResult = EndlessResult(
            distance: distance.floor(),
            style: sim.styleScore.round(),
            coins: sim.coinCount,
          );
        }
        _deathSimTime = e.t;
        _replayCam = Cam(e.x, e.y - 0.5, 7);
        _setPhase(GamePhase.dying);
      } else if (e.kind == EventKind.finish) {
        result = RunResult(
          time: sim.runTime,
          targetTime: level.targetTime,
          coins: sim.coinCount,
          totalCoins: level.coins.length,
          style: sim.styleScore.round(),
          revived: revived,
        );
        _setPhase(GamePhase.won);
      }
    }
    if (phase == GamePhase.ready && sim.startedAt != null) _setPhase(GamePhase.playing);
    if (sim.startedAt != null && (sim.status == SimStatus.running || phase == GamePhase.won)) {
      if (((sim.t - sim.startedAt!) / cfg.dt).round() % ghostEvery == 0 || phase == GamePhase.won) {
        final torso = sim.ragdoll.torso;
        if (_ghostRec.isEmpty || _ghostRec[_ghostRec.length - 4] < sim.runTime) {
          _ghostRec.addAll([sim.runTime, torso.position.x, torso.position.y, torso.angle]);
        }
      }
    }
    if (mode == PlayMode.endless && phase == GamePhase.playing) _trackEndless();
  }

  void _trackEndless() {
    final x = sim.ragdoll.torso.position.x;
    distance = math.max(distance, x - level.start.x);
    final w = CourseBuilder.endlessWorld(x);
    if (w != zoneWorld) {
      zoneWorld = w;
      zoneEnteredAt = wallTime;
      notifyListeners();
    }
  }

  void _updateCamera(double dt) {
    final torso = sim.ragdoll.torso.position;
    final v = sim.ragdoll.velocity;
    final frozen = phase != GamePhase.ready && phase != GamePhase.playing;
    final speed = v.length;
    var tx = torso.x + (v.x * 0.3).clamp(-3.0, 3.0) + (frozen ? 0 : 1.5);
    var ty = torso.y + (v.y * 0.15).clamp(-2.5, 2.5) - 1.5;
    final tw = baseViewWidth + ((speed - 6).clamp(0.0, 8.0)) * 0.5;
    // Keep the pit from filling the screen.
    final halfH = tw * _aspect / 2;
    ty = math.min(ty, level.killY + 3 - halfH);
    if (frozen) {
      // Don't chase the body into the pit.
      tx = cam.x + (tx - cam.x) * 0.3;
    }
    final kp = 1 - math.exp(-5 * dt), kz = 1 - math.exp(-2.5 * dt);
    cam = Cam(cam.x + (tx - cam.x) * kp, cam.y + (ty - cam.y) * kp, cam.w + (tw - cam.w) * kz);
  }

  // ------------------------------------------------------------- drawing

  /// The frame to draw right now (interpolated live frame, or the replay).
  Frame get frame {
    if (phase == GamePhase.replay) return replayFrame(_replayClock);
    if (history.length < 2) return history.last;
    final a = history.elementAt(history.length - 2), b = history.last;
    return lerpFrame(a, b, (_acc / cfg.dt).clamp(0.0, 1.0));
  }

  /// Frame at [clock] seconds into the slow-motion fail replay.
  Frame replayFrame(double clock) {
    final t = _deathSimTime - replayBefore + clock;
    final f = frameAt(t);
    final zoomIn = (clock / 0.25).clamp(0.0, 1.0);
    final eased = zoomIn * zoomIn * (3 - 2 * zoomIn);
    return Frame(f.s, f.cam.lerp(_replayCam, eased));
  }

  /// Closest recorded frame at simulation time [t].
  Frame frameAt(double t) {
    Frame? prev;
    for (final f in history) {
      if (f.s.t >= t) {
        if (prev == null) return f;
        final span = f.s.t - prev.s.t;
        return lerpFrame(prev, f, span <= 0 ? 0 : (t - prev.s.t) / span);
      }
      prev = f;
    }
    return history.last;
  }

  /// The torso's path over the [seconds] before simulation time [t], oldest
  /// first, for the motion trail.
  List<Offset> trailAt(double t, {double seconds = 0.22}) {
    final out = <Offset>[];
    for (var i = history.length - 1; i >= 0; i--) {
      final s = history.elementAt(i).s;
      if (s.t > t + 1e-6) continue;
      if (s.t < t - seconds) break;
      out.add(Offset(s.px(Part.torso), s.py(Part.torso)));
    }
    return out.reversed.toList();
  }

  /// Death point in world space, for the replay camera.
  Cam get replayCam => _replayCam;
}

double _lerpAngle(double a, double b, double t) {
  var d = b - a;
  while (d > math.pi) {
    d -= 2 * math.pi;
  }
  while (d < -math.pi) {
    d += 2 * math.pi;
  }
  return a + d * t;
}

Float32List _lerpTriples(Float32List a, Float32List b, double t) {
  if (a.length != b.length) return b;
  final out = Float32List(a.length);
  for (var i = 0; i < a.length; i += 3) {
    out[i] = a[i] + (b[i] - a[i]) * t;
    out[i + 1] = a[i + 1] + (b[i + 1] - a[i + 1]) * t;
    out[i + 2] = _lerpAngle(a[i + 2], b[i + 2], t);
  }
  return out;
}

Float32List _lerpList(Float32List a, Float32List b, double t) {
  if (a.length != b.length) return b;
  final out = Float32List(a.length);
  for (var i = 0; i < a.length; i++) {
    out[i] = a[i] + (b[i] - a[i]) * t;
  }
  return out;
}

/// Blends two frames for smooth rendering above the physics rate.
Frame lerpFrame(Frame a, Frame b, double t) {
  if (t <= 0) return a;
  if (t >= 1) return b;
  final s = b.s;
  return Frame(
    Snapshot(
      t: a.s.t + (s.t - a.s.t) * t,
      parts: _lerpTriples(a.s.parts, s.parts, t),
      saws: _lerpTriples(a.s.saws, s.saws, t),
      ropeAnchor: s.ropeAnchor,
      ropeLength: s.ropeLength,
      targetAnchor: s.targetAnchor,
      coins: s.coins,
      checkpoints: s.checkpoints,
      vx: s.vx,
      vy: s.vy,
      status: s.status,
      runTime: s.runTime,
      anchors: _lerpList(a.s.anchors, s.anchors, t),
      glassBroken: s.glassBroken,
      crumbles: _lerpTriples(a.s.crumbles, s.crumbles, t),
      explodedRockets: s.explodedRockets,
    ),
    a.cam.lerp(b.cam, t),
  );
}
