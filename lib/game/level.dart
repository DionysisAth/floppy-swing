import 'dart:convert';
import 'dart:math' as math;

/// A 2D point in level space (meters, y points down).
class P {
  const P(this.x, this.y);
  final double x;
  final double y;
}

/// An oriented box: centre, full size and rotation (radians).
class Box {
  const Box(this.x, this.y, this.w, this.h, [this.angle = 0]);
  final double x;
  final double y;
  final double w;
  final double h;
  final double angle;

  bool contains(double px, double py) {
    final c = math.cos(-angle), s = math.sin(-angle);
    final dx = px - x, dy = py - y;
    final lx = dx * c - dy * s, ly = dx * s + dy * c;
    return lx.abs() <= w / 2 && ly.abs() <= h / 2;
  }

  /// Distance from a point to the box outline (0 inside).
  double distanceTo(double px, double py) {
    final c = math.cos(-angle), s = math.sin(-angle);
    final dx = px - x, dy = py - y;
    final lx = (dx * c - dy * s).abs() - w / 2;
    final ly = (dx * s + dy * c).abs() - h / 2;
    final ox = math.max(lx, 0.0), oy = math.max(ly, 0.0);
    return math.sqrt(ox * ox + oy * oy);
  }
}

/// Smooth back-and-forth between ([x], [y]) and [to] over [period] seconds.
P pingPong(double x, double y, P? to, double period, double phase, double t) {
  if (to == null) return P(x, y);
  final f = 0.5 - 0.5 * math.cos((t / period + phase) * 2 * math.pi);
  return P(x + (to.x - x) * f, y + (to.y - y) * f);
}

/// A grab ring. Optionally moves back and forth to [to] (World 2).
class Anchor extends P {
  const Anchor(super.x, super.y, {this.to, this.period = 3, this.phase = 0});
  final P? to;
  final double period;
  final double phase;

  bool get moving => to != null;

  /// Ring position at simulation time [t].
  P positionAt(double t) => pingPong(x, y, to, period, phase, t);
}

/// A spinning saw blade. Optionally moves back and forth between its position
/// and [to] over [period] seconds.
class Saw {
  const Saw(this.x, this.y, this.r, {this.to, this.period = 3, this.phase = 0});
  final double x;
  final double y;
  final double r;
  final P? to;
  final double period;
  final double phase;

  /// Saw centre at simulation time [t].
  P positionAt(double t) => pingPong(x, y, to, period, phase, t);
}

/// A fan zone that pushes along the box's local "up" (World 4).
class Wind {
  const Wind(this.box, this.strength);
  final Box box;

  /// Acceleration in m/s² (gravity is about 20).
  final double strength;

  double get dirX => math.sin(box.angle);
  double get dirY => -math.cos(box.angle);
}

/// A rocket launcher that fires every [period] seconds along [angle]
/// (radians, 0 = right, y down). Rockets knock the character around but are
/// not deadly by themselves (World 5).
class Launcher {
  const Launcher(
    this.x,
    this.y,
    this.angle, {
    this.speed = 9,
    this.period = 3,
    this.phase = 0,
    this.range = 22,
  });
  final double x;
  final double y;
  final double angle;
  final double speed;
  final double period;

  /// Fraction of a period before the first rocket.
  final double phase;

  /// Distance a rocket flies before fizzling out.
  final double range;

  double get flightTime => range / speed;
  double launchTime(int k) => (k + phase) * period;

  /// Rockets (by index) that are in the air at time [t].
  Iterable<int> activeAt(double t) sync* {
    final first = ((t - flightTime) / period - phase).ceil();
    final last = (t / period - phase).floor();
    for (var k = math.max(0, first); k <= last; k++) {
      yield k;
    }
  }

  P rocketAt(int k, double t) {
    final d = (t - launchTime(k)) * speed;
    return P(x + math.cos(angle) * d, y + math.sin(angle) * d);
  }
}

/// A single campaign level.
///
/// Levels live in `assets/levels/level_XX.json`. Coordinates are meters with y
/// pointing down. Boxes are `[centerX, centerY, width, height, angleDegrees?]`.
/// Spikes point towards the box's local "up" (-y) side. Pads launch along
/// their local "up" too.
class Level {
  Level({
    required this.id,
    required this.name,
    required this.targetTime,
    required this.start,
    required this.finish,
    required this.killY,
    required this.platforms,
    required this.anchors,
    required this.spikes,
    required this.saws,
    required this.pads,
    required this.coins,
    required this.checkpoints,
    this.glass = const [],
    this.winds = const [],
    this.flips = const [],
    this.crumbles = const [],
    this.launchers = const [],
    this.hint,
  });

  factory Level.fromJson(Map<String, dynamic> m) {
    List<List<num>> arr(String k) =>
        ((m[k] as List?) ?? const [])
            .map((e) => (e as List).cast<num>())
            .toList();
    P p(List<num> a) => P(a[0].toDouble(), a[1].toDouble());
    Box box(List<num> a) => Box(
      a[0].toDouble(),
      a[1].toDouble(),
      a[2].toDouble(),
      a[3].toDouble(),
      a.length > 4 ? a[4].toDouble() * math.pi / 180 : 0,
    );

    return Level(
      id: (m['id'] as num).toInt(),
      name: m['name'] as String,
      targetTime: (m['targetTime'] as num).toDouble(),
      hint: m['hint'] as String?,
      start: p((m['start'] as List).cast<num>()),
      finish: box((m['finish'] as List).cast<num>()),
      killY: (m['killY'] as num).toDouble(),
      platforms: arr('platforms').map(box).toList(),
      anchors: arr('anchors')
          .map(
            (a) => Anchor(
              a[0].toDouble(),
              a[1].toDouble(),
              to: a.length >= 4 ? P(a[2].toDouble(), a[3].toDouble()) : null,
              period: a.length >= 5 ? a[4].toDouble() : 3,
              phase: a.length >= 6 ? a[5].toDouble() : 0,
            ),
          )
          .toList(),
      glass: arr('glass').map(box).toList(),
      flips: arr('flips').map(box).toList(),
      crumbles: arr('crumbles').map(box).toList(),
      winds: arr('winds').map((a) => Wind(box(a), a.length > 5 ? a[5].toDouble() : 30)).toList(),
      launchers: ((m['rockets'] as List?) ?? const []).map((e) {
        final r = e as Map<String, dynamic>;
        double d(String k, double f) => (r[k] as num?)?.toDouble() ?? f;
        return Launcher(
          d('x', 0),
          d('y', 0),
          d('angle', -90) * math.pi / 180,
          speed: d('speed', 9),
          period: d('period', 3),
          phase: d('phase', 0),
          range: d('range', 22),
        );
      }).toList(),
      spikes: arr('spikes').map(box).toList(),
      pads: arr('pads').map(box).toList(),
      coins: arr('coins').map(p).toList(),
      checkpoints: arr('checkpoints').map(p).toList(),
      saws: ((m['saws'] as List?) ?? const []).map((e) {
        final s = e as Map<String, dynamic>;
        final to = (s['to'] as List?)?.cast<num>();
        return Saw(
          (s['x'] as num).toDouble(),
          (s['y'] as num).toDouble(),
          (s['r'] as num).toDouble(),
          to: to == null ? null : p(to),
          period: (s['period'] as num?)?.toDouble() ?? 3,
          phase: (s['phase'] as num?)?.toDouble() ?? 0,
        );
      }).toList(),
    );
  }

  factory Level.parse(String json) =>
      Level.fromJson(jsonDecode(json) as Map<String, dynamic>);

  final int id;
  final String name;

  /// Finish within this many seconds for the time star.
  final double targetTime;

  /// Optional tutorial hint shown when the level starts.
  final String? hint;

  /// Where the character spawns (torso centre).
  final P start;

  /// Reaching this box with the torso finishes the level.
  final Box finish;

  /// Falling below this line is death (drawn as a spike pit).
  final double killY;

  final List<Box> platforms;
  final List<Anchor> anchors;
  final List<Box> spikes;
  final List<Saw> saws;
  final List<Box> pads;
  final List<P> coins;

  /// Checkpoint flags. Each should stand on a platform: reviving drops the
  /// character just above the flag.
  final List<P> checkpoints;

  /// Breakable glass panes: solid, but smash when hit fast enough (World 3).
  final List<Box> glass;

  /// Fan zones (World 4).
  final List<Wind> winds;

  /// Zones where gravity points up (World 4).
  final List<Box> flips;

  /// Platforms that fall shortly after being touched (World 5).
  final List<Box> crumbles;

  /// Rocket launchers (World 5).
  final List<Launcher> launchers;

  /// World number: 20 levels per world.
  int get world => id < 1 ? 1 : (id - 1) ~/ 20 + 1;

  /// Horizontal extent of everything in the level, for camera clamping.
  ({double minX, double maxX, double minY}) get extent {
    var minX = start.x, maxX = finish.x + finish.w / 2, minY = start.y;
    void add(double x, double y, [double r = 0]) {
      minX = math.min(minX, x - r);
      maxX = math.max(maxX, x + r);
      minY = math.min(minY, y - r);
    }

    for (final b in [...platforms, ...spikes, ...pads, ...glass, ...flips, ...crumbles, for (final w in winds) w.box]) {
      add(b.x, b.y, math.max(b.w, b.h) / 2);
    }
    for (final a in [...anchors, ...coins, ...checkpoints]) {
      add(a.x, a.y);
    }
    for (final a in anchors) {
      if (a.to != null) add(a.to!.x, a.to!.y);
    }
    for (final s in saws) {
      add(s.x, s.y, s.r);
      if (s.to != null) add(s.to!.x, s.to!.y, s.r);
    }
    return (minX: minX, maxX: maxX, minY: minY);
  }
}
