import 'dart:math' as math;
import 'dart:typed_data';

import 'package:forge2d/forge2d.dart';

import 'bits.dart';
import 'config.dart';
import 'level.dart';
import 'ragdoll.dart';

export 'bits.dart' show Bits;

enum SimStatus { running, dead, finished }

enum WorldKind { platform, spike, saw, pad, glass, crumble }

/// Why a run ended in failure.
enum DeathCause { spikes, saw, pit, stuck }

class WorldTag {
  const WorldTag(this.kind, this.index);
  final WorldKind kind;
  final int index;
}

enum EventKind {
  grab,

  /// Slingshot launch when grabbing from the ground (x/y = character).
  launch,
  release,
  miss,
  coin,
  checkpoint,
  bounce,
  bonk,
  death,
  finish,
  style,

  /// A glass pane smashed (value = pane index).
  shatter,

  /// A crumbling platform was stepped on ('crack') or started falling
  /// ('fall'); value = platform index.
  crumble,

  /// A rocket was fired nearby (x/y = launcher).
  rocket,

  /// A rocket exploded (value = rocket key); label 'hit' when it hit the
  /// character.
  boom,

  /// The character entered (value 1) or left (value 0) a gravity-flip zone.
  flip,
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
    Float32List? anchors,
    Bits? glassBroken,
    Float32List? crumbles,
    this.explodedRockets = const [],
  }) : anchors = anchors ?? Float32List(0),
       glassBroken = glassBroken ?? Bits.empty,
       crumbles = crumbles ?? Float32List(0);

  final double t;

  /// x, y for each anchor (they can move).
  final Float32List anchors;

  /// Smashed glass panes.
  final Bits glassBroken;

  /// x, y, angle for each crumbling platform.
  final Float32List crumbles;

  /// Keys of rockets in flight that already exploded (see [rocketKey]).
  final List<int> explodedRockets;

  double ax(int i) => anchors[i * 2];
  double ay(int i) => anchors[i * 2 + 1];
  bool glassIsBroken(int i) => glassBroken[i];

  /// x, y, angle for each ragdoll part.
  final Float32List parts;

  /// x, y, angle for each saw.
  final Float32List saws;

  /// Anchor index the rope is attached to, or -1.
  final int ropeAnchor;
  final double ropeLength;

  /// Anchor that would be grabbed right now (highlighted), or -1.
  final int targetAnchor;

  /// Collected coins / reached checkpoints.
  final Bits coins;
  final Bits checkpoints;

  /// Torso velocity (for the face and the velocity indicator).
  final double vx;
  final double vy;
  final SimStatus status;

  /// Level clock shown in the HUD.
  final double runTime;

  double px(int i) => parts[i * 3];
  double py(int i) => parts[i * 3 + 1];
  double pa(int i) => parts[i * 3 + 2];

  bool coinTaken(int i) => coins[i];
  bool checkpointReached(int i) => checkpoints[i];
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
    Bits? collectedCoins,
    Bits? reachedCheckpoints,
    this.styleScore = 0,
  }) : world = World(Vector2(0, cfg.gravity)),
       _coins = collectedCoins ?? Bits.empty,
       _checkpoints = reachedCheckpoints ?? Bits.empty {
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
    for (var i = 0; i < level.anchors.length; i++) {
      final a = level.anchors[i];
      _anchorBodies.add(
        a.moving ? world.createBody(BodyDef(type: BodyType.kinematic, position: Vector2(a.x, a.y))) : null,
      );
    }
    for (var i = 0; i < level.glass.length; i++) {
      _glassBodies.add(_boxBody(level.glass[i], WorldTag(WorldKind.glass, i)));
    }
    for (var i = 0; i < level.crumbles.length; i++) {
      _crumbleBodies.add(_boxBody(level.crumbles[i], WorldTag(WorldKind.crumble, i)));
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

  /// Kinematic body per moving anchor (null for fixed ones).
  final List<Body?> _anchorBodies = [];
  final List<Body?> _glassBodies = [];
  final List<Body?> _crumbleBodies = [];
  Bits _glassBroken = Bits.empty;
  final Map<int, double> _crumbleTouchedAt = {};
  final Set<int> _crumbleFallen = {};
  final Set<int> _exploded = {};
  final Set<int> _rocketsAnnounced = {};
  bool _torsoFlipped = false;
  final List<Vector2> _partVelocities = List.generate(Part.count, (_) => Vector2.zero());

  /// Current position of anchor [i] (anchors can move).
  P anchorAt(int i) => level.anchors[i].moving ? level.anchors[i].positionAt(t) : level.anchors[i];

  /// Identifies rocket [k] of launcher [launcher].
  static int rocketKey(int launcher, int k) => launcher * 100000 + k;

  /// Elapsed run time carried over from before a checkpoint revive.
  final double runTimeOffset;

  SimStatus status = SimStatus.running;
  DeathCause? deathCause;

  /// Simulation time (always advancing, drives saws and effects).
  double t = 0;

  /// Set on the first press; the level clock starts then.
  double? startedAt;

  double? endedAt;

  /// Victory dance played after finishing (a cosmetic id, see
  /// `cosmetics.dart`). Done with impulses, so it stays floppy.
  String dance = 'hop';
  int _danceBeat = -1;
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

  /// Rope was slack (or just attached) going into this step, so it may snap
  /// tight during it; see [_conserveSnapMomentum].
  bool _ropeMaySnap = false;
  final Vector2 _preStepVelocity = Vector2.zero();

  Bits _coins;
  Bits _checkpoints;
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
  Bits get collectedCoins => _coins;
  Bits get reachedCheckpoints => _checkpoints;
  int get coinCount => _coins.count;
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
    _moveKinematics(dt);
    _applyFields();
    if (status == SimStatus.running) {
      // Holding with nothing attached keeps trying, so pressing slightly
      // early still grabs as soon as an anchor comes into range.
      if (_holding && _rope == null && startedAt != null) _tryAttach(silent: true);
      _updateRope(dt);
    }

    if (_rope != null) {
      _ropeMaySnap = _ropeMaySnap || _ropeDistance() < _rope!.maxLength - 0.05;
      _preStepVelocity.setFrom(ragdoll.velocity);
    }
    for (var i = 0; i < Part.count; i++) {
      _partVelocities[i].setFrom(ragdoll.parts[i].linearVelocity);
    }
    _hits.clear();
    world.stepDt(dt);
    t += dt;
    _conserveSnapMomentum();
    _processHits();
    _updateCrumbles();
    _updateRockets();
    if (status == SimStatus.finished) _updateDance();

    if (status == SimStatus.running) {
      _checkPickups();
      _checkFinish();
      _checkKill(dt);
      _updateStyle(dt);
    }
    _captureSnapshot();
  }

  // ---------------------------------------------------------------- dance

  void _updateDance() {
    final since = t - endedAt!;
    // Dances are sequences of beats; each beat fires once.
    const beat = 0.12;
    final n = (since / beat).floor();
    if (n == _danceBeat) return;
    _danceBeat = n;
    switch (dance) {
      case 'backflip':
        if (n == 3) _danceKick(0, -10.5, -13);
      case 'spin':
        if (n == 3) _danceKick(0, -9, 24);
        if (n == 9) _danceKick(0, -6, -24);
      case 'flail':
        if (n == 3) _danceKick(0, -6, 0);
        if (n >= 3 && n <= 14) {
          const limbs = [Part.upperArmFront, Part.upperArmBack, Part.upperLegFront, Part.upperLegBack];
          for (var k = 0; k < limbs.length; k++) {
            ragdoll.parts[limbs[k]].angularVelocity = ((n + k).isEven ? 1 : -1) * 18;
          }
        }
      default: // hop
        if (n == 3 || n == 6 || n == 9) _danceKick(0, -7, 0);
    }
  }

  /// Sets every part's velocity to ([vx], [vy]) plus a spin of [spin] rad/s
  /// about the torso.
  void _danceKick(double vx, double vy, double spin) {
    final c = ragdoll.torso.position;
    for (final b in ragdoll.parts) {
      final r = b.position - c;
      b.linearVelocity = Vector2(vx - spin * r.y, vy + spin * r.x);
      b.angularVelocity = spin;
    }
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
      final a = anchorAt(i);
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
    final a = anchorAt(idx);
    final anchor = Vector2(a.x, a.y);
    final moving = _anchorBodies[idx];
    final dist = (ragdoll.handWorld - anchor).length;
    final len = dist.clamp(cfg.ropeMinLength, cfg.ropeRange + 1.0);
    final def = RopeJointDef()
      ..bodyA = moving ?? _anchorBody
      ..bodyB = ragdoll.hand
      ..localAnchorA.setFrom(moving == null ? anchor : Vector2.zero())
      ..localAnchorB.setFrom(ragdoll.handLocal)
      ..maxLength = len;
    final joint = RopeJoint(def);
    world.createJoint(joint);
    _rope = joint;
    _ropeAnchor = idx;
    _ropeTarget = math.max(cfg.ropeMinLength, dist * cfg.ropeReelFactor);
    _swingSweep = 0;
    _bigSwingAwarded = false;
    _ropeMaySnap = true;
    _lastSwingAngle = _swingAngle();
    if (_touching > 0) {
      // Slingshot: fling the character forward and up into a full swing.
      final torso = ragdoll.torso.position;
      final toAnchor = (anchor - torso)..normalize();
      final forward = (level.finish.x - torso.x).sign;
      var tangent = Vector2(-toAnchor.y, toAnchor.x);
      if (tangent.x * forward < 0) tangent = -tangent;
      final dir = (tangent * 0.8 + toAnchor * 0.6)..normalize();
      ragdoll.setVelocity(dir * cfg.groundLaunchSpeed);
      events.add(SimEvent(EventKind.launch, t, torso.x, torso.y));
    }
    events.add(SimEvent(EventKind.grab, t, a.x, a.y, value: idx.toDouble()));
  }

  void _detach({required bool boost}) {
    final rope = _rope;
    if (rope == null) return;
    world.destroyJoint(rope);
    _rope = null;
    final a = anchorAt(_ropeAnchor);
    _ropeAnchor = -1;
    if (boost) {
      final v = ragdoll.velocity;
      final dir = v.length > 0.01 ? v.normalized() : Vector2.zero();
      ragdoll.addVelocity(dir * cfg.releaseBoost + Vector2(0, -cfg.releaseLift));
    }
    events.add(SimEvent(EventKind.release, t, a.x, a.y));
  }

  double _ropeDistance() {
    final a = anchorAt(_ropeAnchor);
    final h = ragdoll.handWorld;
    final dx = h.x - a.x, dy = h.y - a.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// A rope joint going tight deletes all velocity pointing away from the
  /// anchor, which made grabs from level-with or above the ring feel like a
  /// stall. When that happens, keep most of the speed and send it along the
  /// swing instead.
  void _conserveSnapMomentum() {
    final rope = _rope;
    if (rope == null || !_ropeMaySnap) return;
    if (_ropeDistance() < rope.maxLength - 0.05) return; // Still slack.
    _ropeMaySnap = false;
    final a = anchorAt(_ropeAnchor);
    final torso = ragdoll.torso.position;
    final radial = torso - Vector2(a.x, a.y);
    if (radial.length2 < 0.01) return;
    radial.normalize();
    final before = _preStepVelocity;
    if (before.dot(radial) < 1.0) return; // Wasn't pulling on the rope.
    var tangent = Vector2(-radial.y, radial.x);
    final beforeAlong = before.dot(tangent);
    if (beforeAlong.abs() < 0.5) {
      // Falling straight at the rope: swing towards the finish.
      if (tangent.x * (level.finish.x - torso.x) < 0) tangent = -tangent;
    } else if (beforeAlong < 0) {
      tangent = -tangent;
    }
    final speed = math.min(before.length * cfg.ropeSnapKeep, cfg.ropeSnapMaxSpeed);
    // Only ever add speed: a snap should never feel like a brake.
    if (speed <= before.dot(tangent).abs()) return;
    // The joint stops the hand first and the rest of the body over the next
    // few steps (through the arm), so strip the outward part from every body
    // part now, then put the kept speed into the swing.
    for (final b in ragdoll.parts) {
      final v = b.linearVelocity;
      final out = v.dot(radial);
      if (out > 0) b.linearVelocity = v - radial * out;
    }
    final along = ragdoll.velocity.dot(tangent);
    ragdoll.addVelocity(tangent * (speed - along));
  }

  double _swingAngle() {
    final a = anchorAt(_ropeAnchor);
    final p = ragdoll.torso.position;
    return math.atan2(p.y - a.y, p.x - a.x);
  }

  void _updateRope(double dt) {
    final rope = _rope;
    if (rope == null) return;
    final dist = _ropeDistance();
    if (dist < rope.maxLength - 0.3) {
      // Slack: take in the extra length quickly (but never below the reel
      // target) so the rope catches soon instead of after a long drop.
      rope.maxLength = math.max(
        _ropeTarget,
        math.max(dist + 0.3, rope.maxLength - cfg.ropeSlackTakeUp * dt),
      );
    } else if (rope.maxLength > _ropeTarget) {
      rope.maxLength = math.max(_ropeTarget, rope.maxLength - cfg.ropeReelSpeed * dt);
    }

    // Pump: push along the swing direction so swings build up nicely.
    final a = anchorAt(_ropeAnchor);
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
    final belowAnchor = _torsoFlipped ? r.y < 0.2 * r.length : r.y > -0.2 * r.length;
    final speed = v.length;
    if (belowAnchor && speed < cfg.maxSwingSpeed) {
      final slow = ((cfg.assistBelowSpeed - speed) / cfg.assistBelowSpeed).clamp(0.0, 1.0);
      final pump = cfg.swingPump * (1 + cfg.lowSpeedAssist * slow);
      torso.applyForce(tangent * (pump * ragdoll.totalMass));
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

  void _moveKinematics(double dt) {
    void follow(Body body, P next) {
      body.linearVelocity = Vector2((next.x - body.position.x) / dt, (next.y - body.position.y) / dt);
    }

    for (var i = 0; i < _saws.length; i++) {
      final s = level.saws[i];
      if (s.to != null) follow(_saws[i], s.positionAt(t + dt));
    }
    for (var i = 0; i < _anchorBodies.length; i++) {
      final body = _anchorBodies[i];
      if (body != null) follow(body, level.anchors[i].positionAt(t + dt));
    }
  }

  /// Wind zones push; gravity-flip zones turn gravity upside down.
  void _applyFields() {
    if (level.winds.isEmpty && level.flips.isEmpty) return;
    for (var i = 0; i < Part.count; i++) {
      final b = ragdoll.parts[i];
      final p = b.position;
      for (final w in level.winds) {
        if (w.box.contains(p.x, p.y)) {
          b.applyForce(Vector2(w.dirX, w.dirY) * (w.strength * b.mass));
        }
      }
      if (level.flips.isNotEmpty) {
        final flipped = level.flips.any((f) => f.contains(p.x, p.y));
        b.gravityScale = flipped ? Vector2(1, -1) : null;
        if (i == Part.torso && flipped != _torsoFlipped) {
          _torsoFlipped = flipped;
          events.add(SimEvent(EventKind.flip, t, p.x, p.y, value: flipped ? 1 : 0));
        }
      }
    }
  }

  void _updateCrumbles() {
    for (final e in _crumbleTouchedAt.entries) {
      final i = e.key;
      final body = _crumbleBodies[i];
      if (body == null || _crumbleFallen.contains(i)) continue;
      if (t - e.value >= cfg.crumbleDelay) {
        _crumbleFallen.add(i);
        body.setType(BodyType.dynamic);
        body.angularVelocity = (i.isEven ? 1 : -1) * 0.8;
        events.add(SimEvent(EventKind.crumble, t, body.position.x, body.position.y, value: i.toDouble(), label: 'fall'));
      }
    }
    // Forget platforms that have fallen far out of the level.
    for (final i in _crumbleFallen) {
      final body = _crumbleBodies[i];
      if (body != null && body.position.y > level.killY + 40) {
        world.destroyBody(body);
        _crumbleBodies[i] = null;
      }
    }
  }

  void _updateRockets() {
    for (var li = 0; li < level.launchers.length; li++) {
      final l = level.launchers[li];
      for (final k in l.activeAt(t)) {
        final key = rocketKey(li, k);
        final age = t - l.launchTime(k);
        if (!_rocketsAnnounced.contains(key)) {
          _rocketsAnnounced.add(key);
          final torso = ragdoll.torso.position;
          if ((torso.x - l.x).abs() < 14 && (torso.y - l.y).abs() < 20) {
            events.add(SimEvent(EventKind.rocket, t, l.x, l.y, value: key.toDouble()));
          }
        }
        if (_exploded.contains(key) || age < 0.12) continue;
        final r = l.rocketAt(k, t);
        // Hit the character?
        var hit = false;
        for (final b in ragdoll.parts) {
          final dx = b.position.x - r.x, dy = b.position.y - r.y;
          if (dx * dx + dy * dy < cfg.rocketHitRadius * cfg.rocketHitRadius) {
            hit = true;
            break;
          }
        }
        if (hit) {
          _exploded.add(key);
          final dir = Vector2(math.cos(l.angle), math.sin(l.angle));
          for (final b in ragdoll.parts) {
            final away = (b.position - Vector2(r.x, r.y));
            final push = (away.length2 > 1e-6 ? away.normalized() : dir) * 0.5 + dir * 0.5;
            b.linearVelocity = b.linearVelocity + push.normalized() * cfg.rocketKnock + Vector2(0, -3);
          }
          ragdoll.torso.angularVelocity += 12 * (dir.x >= 0 ? 1 : -1);
          events.add(SimEvent(EventKind.boom, t, r.x, r.y, value: key.toDouble(), label: 'hit'));
          continue;
        }
        // Hit a wall?
        final walls = [
          ...level.platforms,
          for (var i = 0; i < level.glass.length; i++)
            if (!_glassBroken[i]) level.glass[i],
        ];
        if (walls.any((w) => w.contains(r.x, r.y))) {
          _exploded.add(key);
          events.add(SimEvent(EventKind.boom, t, r.x, r.y, value: key.toDouble()));
        }
      }
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
        case WorldKind.glass:
          if (hit.approach >= cfg.glassBreakSpeed) {
            _shatter(hit.tag.index);
          } else {
            _bonk(hit);
          }
        case WorldKind.crumble:
          final i = hit.tag.index;
          if (!_crumbleTouchedAt.containsKey(i)) {
            _crumbleTouchedAt[i] = t;
            final c = level.crumbles[i];
            events.add(SimEvent(EventKind.crumble, t, c.x, c.y, value: i.toDouble(), label: 'crack'));
          }
          _bonk(hit);
      }
    }
  }

  void _shatter(int i) {
    final body = _glassBodies[i];
    if (body == null) return;
    world.destroyBody(body);
    _glassBodies[i] = null;
    _glassBroken = _glassBroken.add(i);
    // Smash straight through: undo the bounce the collision just caused.
    for (var p = 0; p < Part.count; p++) {
      ragdoll.parts[p].linearVelocity = _partVelocities[p] * 0.9;
    }
    final g = level.glass[i];
    events.add(SimEvent(EventKind.shatter, t, g.x, g.y, value: i.toDouble()));
    _awardStyle('SMASH', 80);
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
      if (_coins[i]) continue;
      final c = level.coins[i];
      for (final pi in _pickupParts) {
        final p = ragdoll.parts[pi].position;
        final dx = p.x - c.x, dy = p.y - c.y;
        if (dx * dx + dy * dy < r2) {
          _coins = _coins.add(i);
          events.add(SimEvent(EventKind.coin, t, c.x, c.y, value: i.toDouble()));
          break;
        }
      }
    }
    // Checkpoints trigger anywhere in the column above their flag, so
    // flying over one counts too.
    final tp = ragdoll.torso.position;
    for (var i = 0; i < level.checkpoints.length; i++) {
      if (_checkpoints[i]) continue;
      final c = level.checkpoints[i];
      if ((tp.x - c.x).abs() < cfg.checkpointRadius && tp.y < c.y) {
        _checkpoints = _checkpoints.add(i);
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
    // Brake hard so the celebration happens at the finish, not off-screen.
    for (final b in ragdoll.parts) {
      b.linearVelocity = b.linearVelocity * 0.2;
    }
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
    final anchors = Float32List(level.anchors.length * 2);
    for (var i = 0; i < level.anchors.length; i++) {
      final a = anchorAt(i);
      anchors[i * 2] = a.x;
      anchors[i * 2 + 1] = a.y;
    }
    final crumbles = Float32List(level.crumbles.length * 3);
    for (var i = 0; i < level.crumbles.length; i++) {
      final body = _crumbleBodies[i];
      final c = level.crumbles[i];
      crumbles[i * 3] = body?.position.x ?? c.x;
      crumbles[i * 3 + 1] = body?.position.y ?? level.killY + 60;
      crumbles[i * 3 + 2] = body?.angle ?? c.angle;
    }
    final exploded = <int>[
      for (var li = 0; li < level.launchers.length; li++)
        for (final k in level.launchers[li].activeAt(t))
          if (_exploded.contains(rocketKey(li, k))) rocketKey(li, k),
    ];
    final v = ragdoll.torso.linearVelocity;
    snapshot = Snapshot(
      anchors: anchors,
      glassBroken: _glassBroken,
      crumbles: crumbles,
      explodedRockets: exploded,
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

  Body _boxBody(Box b, WorldTag tag) {
    final body = world.createBody(BodyDef(position: Vector2(b.x, b.y), angle: b.angle));
    body.createFixture(
      FixtureDef(
        PolygonShape()..setAsBoxXY(b.w / 2, b.h / 2),
        userData: tag,
        friction: 0.7,
        restitution: tag.kind == WorldKind.glass ? 0.1 : 0.2,
        density: 2,
      ),
    );
    return body;
  }

}

class _SightCallback implements RayCastCallback {
  bool blocked = false;

  @override
  double reportFixture(Fixture fixture, Vector2 point, Vector2 normal, double fraction) {
    final tag = fixture.userData;
    if (tag is WorldTag &&
        (tag.kind == WorldKind.platform || tag.kind == WorldKind.glass || tag.kind == WorldKind.crumble)) {
      blocked = true;
      return 0; // Stop the ray.
    }
    return -1; // Ignore this fixture and keep going.
  }
}
