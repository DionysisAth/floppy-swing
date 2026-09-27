import 'dart:math' as math;
import 'dart:typed_data';

import 'package:forge2d/forge2d.dart';

import 'config.dart';
import 'level.dart';
import 'ragdoll.dart';

enum SimStatus { running, dead, finished }

enum WorldKind { platform, spike, saw, pad }

/// Why a run ended in failure.
enum DeathCause { spikes, saw, pit, stuck }

class WorldTag {
  const WorldTag(this.kind, this.index);
  final WorldKind kind;
  final int index;
}

enum EventKind {
  grab,
  release,
  miss,
  coin,
  checkpoint,
  bounce,
  bonk,
  death,
  finish,
  style,
}

/// Something noteworthy that happened during the simulation. Audio, particle
/// effects and style pop-ups are all driven from these, which also lets the
/// slow-motion replay and clip export re-create effects from the event log.
class SimEvent {
  const SimEvent(this.kind, this.t, this.x, this.y, {this.value = 0, this.label});
  final EventKind kind;

  /// Simulation time the event happened at.
  final double t;
  final double x;
  final double y;

  /// Kind-specific payload: pad index, coin index, style points, impact speed…
  final double value;
  final String? label;
}

/// Everything needed to draw one frame: body transforms plus dynamic state.
/// Kept small so a few seconds of history can be buffered for replays.
class Snapshot {
  Snapshot({
    required this.t,
    required this.parts,
    required this.saws,
    required this.ropeAnchor,
    required this.ropeLength,
    required this.targetAnchor,
    required this.coins,
    required this.checkpoints,
    required this.vx,
    required this.vy,
    required this.status,
    required this.runTime,
  });

  final double t;

  /// x, y, angle for each ragdoll part.
  final Float32List parts;

  /// x, y, angle for each saw.
  final Float32List saws;

  /// Anchor index the rope is attached to, or -1.
  final int ropeAnchor;
  final double ropeLength;

  /// Anchor that would be grabbed right now (highlighted), or -1.
  final int targetAnchor;

  /// Bit masks of collected coins / reached checkpoints.
  final int coins;
  final int checkpoints;

  /// Torso velocity (for the face and the velocity indicator).
  final double vx;
  final double vy;
  final SimStatus status;

  /// Level clock shown in the HUD.
  final double runTime;

  double px(int i) => parts[i * 3];
  double py(int i) => parts[i * 3 + 1];
  double pa(int i) => parts[i * 3 + 2];

  bool coinTaken(int i) => (coins >> i) & 1 == 1;
  bool checkpointReached(int i) => (checkpoints >> i) & 1 == 1;
}

/// Contact reported during a physics step, processed after the step.
class _Hit {
  _Hit(this.tag, this.part, this.point, this.normal, this.approach);
  final WorldTag tag;
  final int part;
  final Vector2 point;

  /// Points from the world object towards the ragdoll part.
  final Vector2 normal;

  /// Speed at which the part was moving into the surface.
  final double approach;
}

class _Listener extends ContactListener {
  _Listener(this.sim);
  final Simulation sim;
  final WorldManifold _wm = WorldManifold();

  @override
  void beginContact(Contact contact) {
    final a = contact.fixtureA.userData, b = contact.fixtureB.userData;
    PartTag? part;
    WorldTag? tag;
    var partIsB = false;
    if (a is PartTag && b is WorldTag) {
      part = a;
      tag = b;
    } else if (b is PartTag && a is WorldTag) {
      part = b;
      tag = a;
      partIsB = true;
    } else {
      return;
    }
    sim._touching++;
    contact.getWorldManifold(_wm);
    final n = partIsB ? _wm.normal.clone() : -_wm.normal;
    final point = contact.manifold.pointCount > 0
        ? _wm.points[0].clone()
        : sim.ragdoll.parts[part.index].position.clone();
    final partBody = sim.ragdoll.parts[part.index];
    final otherBody = partIsB ? contact.fixtureA.body : contact.fixtureB.body;
    final rel = partBody.linearVelocityFromWorldPoint(point) -
        otherBody.linearVelocityFromWorldPoint(point);
    sim._hits.add(_Hit(tag, part.index, point, n, -rel.dot(n)));
  }

  @override
  void endContact(Contact contact) {
    final a = contact.fixtureA.userData, b = contact.fixtureB.userData;
    if ((a is PartTag && b is WorldTag) || (b is PartTag && a is WorldTag)) {
      sim._touching = math.max(0, sim._touching - 1);
    }
  }
}

/// The complete, headless game simulation for one attempt at a level.
///
/// Pure Dart (no Flutter), deterministic for a given input sequence, stepped
/// at a fixed rate. Rendering reads [snapshot]; audio and effects read
/// [events].
class Simulation {
  Simulation(
    this.level,
    this.cfg, {
    P? spawn,
    this.runTimeOffset = 0,
    int collectedCoins = 0,
    int reachedCheckpoints = 0,
    this.styleScore = 0,
  }) : world = World(Vector2(0, cfg.gravity)),
       _coins = collectedCoins,
       _checkpoints = reachedCheckpoints {
    world.setContactListener(_Listener(this));
    _ground = world.createBody(BodyDef());
    // Separate fixture-less body for rope anchors: joints disable collision
    // between the bodies they connect, so the rope must not hang off _ground.
    _anchorBody = world.createBody(BodyDef());
    for (var i = 0; i < level.platforms.length; i++) {
      _staticBox(level.platforms[i], WorldTag(WorldKind.platform, i));
    }
    for (var i = 0; i < level.spikes.length; i++) {
      _staticBox(level.spikes[i], WorldTag(WorldKind.spike, i));
    }
    for (var i = 0; i < level.pads.length; i++) {
      _staticBox(level.pads[i], WorldTag(WorldKind.pad, i));
    }
    for (var i = 0; i < level.saws.length; i++) {
      final s = level.saws[i];
      final body = world.createBody(
        BodyDef(
          type: BodyType.kinematic,
          position: Vector2(s.x, s.y),
          angularVelocity: 7,
        ),
      );
      body.createFixture(
        FixtureDef(
          CircleShape(radius: s.r * 0.92),
          userData: WorldTag(WorldKind.saw, i),
          friction: 0.8,
        ),
      );
      _saws.add(body);
    }
    final sp = spawn ?? level.start;
    ragdoll = Ragdoll(world, cfg, Vector2(sp.x, sp.y));
    _captureSnapshot();
  }

  final Level level;
  final PhysicsConfig cfg;
  final World world;
  late final Ragdoll ragdoll;
  late final Body _ground;
  late final Body _anchorBody;
  final List<Body> _saws = [];

  /// Elapsed run time carried over from before a checkpoint revive.
  final double runTimeOffset;

  SimStatus status = SimStatus.running;
  DeathCause? deathCause;

  /// Simulation time (always advancing, drives saws and effects).
  double t = 0;

  /// Set on the first press; the level clock starts then.
  double? startedAt;

  double? endedAt;
  Vector2? deathPoint;

  final List<SimEvent> events = [];
  late Snapshot snapshot;

  int _touching = 0;
  final List<_Hit> _hits = [];

  // Rope state.
  RopeJoint? _rope;
  int _ropeAnchor = -1;
  double _ropeTarget = 0;
  bool _holding = false;

  int _coins;
  int _checkpoints;
  int lastCheckpoint = -1;

  double _stillTime = 0;
  final Map<int, double> _padCooldown = {};
  final Map<int, double> _bonkCooldown = {};

  // Style tracking.
  double styleScore;
  int combo = 0;
  double _lastStyleAt = -100;
  double _airTime = 0;
  int _airAwards = 0;
  double _spinAccum = 0;
  double _lastTorsoAngle = 0;
  double _swingSweep = 0;
  double _lastSwingAngle = 0;
  bool _bigSwingAwarded = false;
  final Map<int, double> _nearMissCooldown = {};
  final Set<int> _hazardsTouched = {};

  bool get isHolding => _holding;
  bool get isAttached => _rope != null;
  int get ropeAnchor => _ropeAnchor;
  int get collectedCoinsMask => _coins;
  int get reachedCheckpointsMask => _checkpoints;
  int get coinCount => _popCount(_coins);
  bool get allCoins => coinCount == level.coins.length;

  /// Level clock (0 until the first press).
  double get runTime =>
      runTimeOffset +
      (startedAt == null ? 0 : ((endedAt ?? t) - startedAt!));

  // ---------------------------------------------------------------- input

  void press() {
    _holding = true;
    if (status != SimStatus.running) return;
    startedAt ??= t;
    _tryAttach();
  }

  void release() {
    _holding = false;
    if (_rope == null) return;
    _detach(boost: status == SimStatus.running);
  }

  // ------------------------------------------------------------- stepping

  void step() {
    final dt = cfg.dt;
    _moveSaws(dt);
    if (status == SimStatus.running) {
      // Holding with nothing attached keeps trying, so pressing slightly
      // early still grabs as soon as an anchor comes into range.
      if (_holding && _rope == null && startedAt != null) _tryAttach(silent: true);
      _updateRope(dt);
    }

    _hits.clear();
    world.stepDt(dt);
    t += dt;
    _processHits();

    if (status == SimStatus.running) {
      _checkPickups();
      _checkFinish();
      _checkKill(dt);
      _updateStyle(dt);
    }
    _captureSnapshot();
  }

  // ----------------------------------------------------------------- rope

  /// The anchor that a press would grab right now, or -1.
  int bestAnchor() {
    final pos = ragdoll.torso.position;
    final vel = ragdoll.velocity;
    final speed = vel.length;
    final fwd = speed > 2
        ? vel / speed
        : Vector2((level.finish.x - pos.x).sign.toDouble(), -0.3).normalized();
    var best = -1;
    var bestScore = double.infinity;
    for (var i = 0; i < level.anchors.length; i++) {
      final a = level.anchors[i];
      final dx = a.x - pos.x, dy = a.y - pos.y;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist > cfg.ropeRange || dist < 0.3) continue;
      var score = dist - cfg.anchorForwardBias * (dx * fwd.x + dy * fwd.y);
      if (dy > 0) score += cfg.anchorBelowPenalty * dy;
      if (score < bestScore && _lineOfSight(pos, Vector2(a.x, a.y))) {
        bestScore = score;
        best = i;
      }
    }
    return best;
  }

  void _tryAttach({bool silent = false}) {
    if (_rope != null) return;
    final idx = bestAnchor();
    if (idx < 0) {
      if (!silent) {
        final h = ragdoll.handWorld;
        events.add(SimEvent(EventKind.miss, t, h.x, h.y));
      }
      return;
    }
    final a = level.anchors[idx];
    final anchor = Vector2(a.x, a.y);
    final dist = (ragdoll.handWorld - anchor).length;
    final len = dist.clamp(cfg.ropeMinLength, cfg.ropeRange + 1.0);
    final def = RopeJointDef()
      ..bodyA = _anchorBody
      ..bodyB = ragdoll.hand
      ..localAnchorA.setFrom(anchor)
      ..localAnchorB.setFrom(ragdoll.handLocal)
      ..maxLength = len;
    final joint = RopeJoint(def);
    world.createJoint(joint);
    _rope = joint;
    _ropeAnchor = idx;
    _ropeTarget = math.max(cfg.ropeMinLength, dist * cfg.ropeReelFactor);
    _swingSweep = 0;
    _bigSwingAwarded = false;
    _lastSwingAngle = _swingAngle();
    if (_touching > 0) {
      final dir = (anchor - ragdoll.torso.position)..normalize();
      ragdoll.addVelocity(dir * cfg.groundGrabHop);
    }
    events.add(SimEvent(EventKind.grab, t, a.x, a.y, value: idx.toDouble()));
  }

  void _detach({required bool boost}) {
    final rope = _rope;
    if (rope == null) return;
    world.destroyJoint(rope);
    _rope = null;
    final a = level.anchors[_ropeAnchor];
    _ropeAnchor = -1;
    if (boost) {
      final v = ragdoll.velocity;
      final dir = v.length > 0.01 ? v.normalized() : Vector2.zero();
      ragdoll.addVelocity(dir * cfg.releaseBoost + Vector2(0, -cfg.releaseLift));
    }
    events.add(SimEvent(EventKind.release, t, a.x, a.y));
  }

  double _swingAngle() {
    final a = level.anchors[_ropeAnchor];
    final p = ragdoll.torso.position;
    return math.atan2(p.y - a.y, p.x - a.x);
  }

  void _updateRope(double dt) {
    final rope = _rope;
    if (rope == null) return;
    if (rope.maxLength > _ropeTarget) {
      rope.maxLength = math.max(_ropeTarget, rope.maxLength - cfg.ropeReelSpeed * dt);
    }

    // Pump: push along the swing direction so swings build up nicely.
    final a = level.anchors[_ropeAnchor];
    final torso = ragdoll.torso;
    final r = torso.position - Vector2(a.x, a.y);
    if (r.length2 < 0.01) return;
    var tangent = Vector2(-r.y, r.x)..normalize();
    final v = ragdoll.velocity;
    final along = v.dot(tangent);
    if (along.abs() < 1.0) {
      // Nearly still: nudge towards the finish to get things going.
      final towards = (level.finish.x - torso.position.x).sign;
      if (tangent.x * towards < 0) tangent = -tangent;
    } else if (along < 0) {
      tangent = -tangent;
    }
    // Only pump on the down-swing and the bottom of the arc; pumping on the
    // way up would let you climb to the top of every anchor.
    final belowAnchor = r.y > -0.2 * r.length;
    if (belowAnchor && v.length < cfg.maxSwingSpeed) {
      torso.applyForce(tangent * (cfg.swingPump * ragdoll.totalMass));
    }

    // Track how far around the anchor we've swung for the "Big Swing" bonus.
    final ang = _swingAngle();
    var d = ang - _lastSwingAngle;
    if (d > math.pi) d -= 2 * math.pi;
    if (d < -math.pi) d += 2 * math.pi;
    _swingSweep += d;
    _lastSwingAngle = ang;
    if (!_bigSwingAwarded && _swingSweep.abs() > math.pi * 1.2) {
      _bigSwingAwarded = true;
      _awardStyle('BIG SWING', 150);
    }
  }

  bool _lineOfSight(Vector2 from, Vector2 to) {
    final cb = _SightCallback();
    world.raycast(cb, from, to);
    return !cb.blocked;
  }

  // ------------------------------------------------------------- hazards

  void _moveSaws(double dt) {
    for (var i = 0; i < _saws.length; i++) {
      final s = level.saws[i];
      if (s.to == null) continue;
      final next = s.positionAt(t + dt);
      final body = _saws[i];
      body.linearVelocity = Vector2(
        (next.x - body.position.x) / dt,
        (next.y - body.position.y) / dt,
      );
    }
  }

  void _processHits() {
    for (final hit in _hits) {
      switch (hit.tag.kind) {
        case WorldKind.spike:
        case WorldKind.saw:
          _hazardsTouched.add(_hazardKey(hit.tag));
          if (status == SimStatus.running) {
            _die(
              hit.tag.kind == WorldKind.saw ? DeathCause.saw : DeathCause.spikes,
              hit.point,
              hit.normal,
            );
          } else {
            _bonk(hit);
          }
        case WorldKind.pad:
          _bounce(hit);
        case WorldKind.platform:
          _bonk(hit);
      }
    }
  }

  void _bonk(_Hit hit) {
    if (hit.approach < cfg.impactSoundSpeed) return;
    final last = _bonkCooldown[hit.part] ?? -1;
    if (t - last < 0.15) return;
    _bonkCooldown[hit.part] = t;
    events.add(
      SimEvent(
        EventKind.bonk,
        t,
        hit.point.x,
        hit.point.y,
        value: hit.approach,
        label: hit.part == Part.head ? 'head' : null,
      ),
    );
  }

  void _bounce(_Hit hit) {
    final idx = hit.tag.index;
    final last = _padCooldown[idx] ?? -1;
    if (t - last < 0.25) return;
    _padCooldown[idx] = t;
    final pad = level.pads[idx];
    // Pad normal is its local "up".
    final n = Vector2(math.sin(pad.angle), -math.cos(pad.angle));
    for (final b in ragdoll.parts) {
      final v = b.linearVelocity;
      final along = v.dot(n);
      b.linearVelocity = v - n * along + n * cfg.bouncePadSpeed;
    }
    events.add(SimEvent(EventKind.bounce, t, pad.x, pad.y, value: idx.toDouble()));
  }

  void _die(DeathCause cause, Vector2 point, Vector2 normal) {
    if (status != SimStatus.running) return;
    status = SimStatus.dead;
    deathCause = cause;
    endedAt = t;
    deathPoint = point.clone();
    _detach(boost: false);
    if (cause != DeathCause.stuck) {
      // Deliberately overpowered knockback: launch away and spin.
      final n = normal.length2 > 0 ? normal.normalized() : Vector2(0, -1);
      final kick = n * cfg.hazardKnockback + Vector2(0, -cfg.hazardKnockback * 0.35);
      for (final b in ragdoll.parts) {
        b.linearVelocity = b.linearVelocity * 0.3 + kick;
      }
      final spin = (n.x >= 0 ? 1 : -1) * cfg.hazardSpin;
      ragdoll.torso.angularVelocity = spin;
      ragdoll.parts[Part.head].angularVelocity = -spin;
    }
    events.add(
      SimEvent(EventKind.death, t, point.x, point.y, value: cause.index.toDouble()),
    );
  }

  void _checkKill(double dt) {
    if (status != SimStatus.running) return;
    for (final b in ragdoll.parts) {
      if (b.position.y > level.killY - cfg.killMargin) {
        _die(DeathCause.pit, b.position, Vector2(0, -1));
        return;
      }
    }
    // Stuck: lying still with the rope detached and nothing in reach.
    if (startedAt != null && _rope == null && ragdoll.velocity.length < 0.6) {
      _stillTime += dt;
      if (_stillTime > cfg.stuckTime && bestAnchor() < 0) {
        _die(DeathCause.stuck, ragdoll.torso.position, Vector2(0, -1));
      }
    } else {
      _stillTime = 0;
    }
  }

  // ------------------------------------------------------ pickups, finish

  static const _pickupParts = [
    Part.torso,
    Part.head,
    Part.lowerArmFront,
    Part.lowerArmBack,
    Part.lowerLegFront,
    Part.lowerLegBack,
  ];

  void _checkPickups() {
    final r2 = cfg.pickupRadius * cfg.pickupRadius;
    for (var i = 0; i < level.coins.length; i++) {
      if ((_coins >> i) & 1 == 1) continue;
      final c = level.coins[i];
      for (final pi in _pickupParts) {
        final p = ragdoll.parts[pi].position;
        final dx = p.x - c.x, dy = p.y - c.y;
        if (dx * dx + dy * dy < r2) {
          _coins |= 1 << i;
          events.add(SimEvent(EventKind.coin, t, c.x, c.y, value: i.toDouble()));
          break;
        }
      }
    }
    // Checkpoints trigger anywhere in the column above their flag, so
    // flying over one counts too.
    final tp = ragdoll.torso.position;
    for (var i = 0; i < level.checkpoints.length; i++) {
      if ((_checkpoints >> i) & 1 == 1) continue;
      final c = level.checkpoints[i];
      if ((tp.x - c.x).abs() < cfg.checkpointRadius && tp.y < c.y) {
        _checkpoints |= 1 << i;
        lastCheckpoint = i;
        events.add(SimEvent(EventKind.checkpoint, t, c.x, c.y, value: i.toDouble()));
      }
    }
  }

  void _checkFinish() {
    final p = ragdoll.torso.position;
    if (!level.finish.contains(p.x, p.y)) return;
    status = SimStatus.finished;
    startedAt ??= t;
    endedAt = t;
    _detach(boost: false);
    events.add(SimEvent(EventKind.finish, t, p.x, p.y));
  }

  // ---------------------------------------------------------------- style

  int _hazardKey(WorldTag tag) => tag.kind.index * 1000 + tag.index;

  void _awardStyle(String label, int base) {
    if (t - _lastStyleAt > 3.0) combo = 0;
    combo++;
    _lastStyleAt = t;
    final points = base * combo;
    styleScore += points;
    final p = ragdoll.torso.position;
    events.add(
      SimEvent(
        EventKind.style,
        t,
        p.x,
        p.y,
        value: points.toDouble(),
        label: combo > 1 ? '$label x$combo' : label,
      ),
    );
  }

  void _updateStyle(double dt) {
    if (startedAt == null) return;
    final torso = ragdoll.torso;
    final airborne = _touching == 0;

    // Flips: full rotations of the torso while flying free.
    var da = torso.angle - _lastTorsoAngle;
    _lastTorsoAngle = torso.angle;
    if (airborne && _rope == null) {
      _spinAccum += da;
      if (_spinAccum.abs() >= 2 * math.pi) {
        _spinAccum = 0;
        _awardStyle('FLIP', 100);
      }
    } else {
      _spinAccum = 0;
      da = 0;
    }

    // Air time: long stretches without touching anything solid.
    if (airborne) {
      _airTime += dt;
      if (_airTime > 3.0 * (_airAwards + 1)) {
        _airAwards++;
        _awardStyle('HANG TIME', 50);
      }
    } else {
      _airTime = 0;
      _airAwards = 0;
    }

    // Near misses: brushing past a hazard without touching it.
    void nearMiss(int key, double dist) {
      if (dist > cfg.nearMissDistance || _hazardsTouched.contains(key)) return;
      final last = _nearMissCooldown[key];
      if (last != null && t - last < 2.0) return;
      _nearMissCooldown[key] = t;
      _awardStyle('CLOSE CALL', 75);
    }

    for (var i = 0; i < _saws.length; i++) {
      final c = _saws[i].position;
      final r = level.saws[i].r;
      var best = double.infinity;
      for (final b in ragdoll.parts) {
        best = math.min(best, (b.position - c).length - r - 0.2);
      }
      nearMiss(_hazardKey(WorldTag(WorldKind.saw, i)), best);
    }
    for (var i = 0; i < level.spikes.length; i++) {
      final s = level.spikes[i];
      var best = double.infinity;
      for (final b in ragdoll.parts) {
        best = math.min(best, s.distanceTo(b.position.x, b.position.y) - 0.2);
      }
      nearMiss(_hazardKey(WorldTag(WorldKind.spike, i)), best);
    }
  }

  // ------------------------------------------------------------- snapshot

  void _captureSnapshot() {
    final parts = Float32List(Part.count * 3);
    for (var i = 0; i < Part.count; i++) {
      final b = ragdoll.parts[i];
      parts[i * 3] = b.position.x;
      parts[i * 3 + 1] = b.position.y;
      parts[i * 3 + 2] = b.angle;
    }
    final saws = Float32List(_saws.length * 3);
    for (var i = 0; i < _saws.length; i++) {
      final b = _saws[i];
      saws[i * 3] = b.position.x;
      saws[i * 3 + 1] = b.position.y;
      saws[i * 3 + 2] = b.angle;
    }
    final v = ragdoll.torso.linearVelocity;
    snapshot = Snapshot(
      t: t,
      parts: parts,
      saws: saws,
      ropeAnchor: _ropeAnchor,
      ropeLength: _rope?.maxLength ?? 0,
      targetAnchor: status == SimStatus.running && _rope == null ? bestAnchor() : -1,
      coins: _coins,
      checkpoints: _checkpoints,
      vx: v.x,
      vy: v.y,
      status: status,
      runTime: runTime,
    );
  }

  // --------------------------------------------------------------- helpers

  void _staticBox(Box b, WorldTag tag) {
    final shape = PolygonShape()
      ..setAsBox(b.w / 2, b.h / 2, Vector2(b.x, b.y), b.angle);
    _ground.createFixture(
      FixtureDef(
        shape,
        userData: tag,
        friction: tag.kind == WorldKind.platform ? 0.8 : 0.3,
        restitution: tag.kind == WorldKind.platform ? 0.2 : 0.0,
      ),
    );
  }

  static int _popCount(int v) {
    var c = 0;
    while (v != 0) {
      v &= v - 1;
      c++;
    }
    return c;
  }
}

class _SightCallback implements RayCastCallback {
  bool blocked = false;

  @override
  double reportFixture(Fixture fixture, Vector2 point, Vector2 normal, double fraction) {
    final tag = fixture.userData;
    if (tag is WorldTag && tag.kind == WorldKind.platform) {
      blocked = true;
      return 0; // Stop the ray.
    }
    return -1; // Ignore this fixture and keep going.
  }
}
