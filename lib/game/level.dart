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
  P positionAt(double t) {
    final target = to;
    if (target == null) return P(x, y);
    // Smooth ping-pong between the two end points.
    final f = 0.5 - 0.5 * math.cos((t / period + phase) * 2 * math.pi);
    return P(x + (target.x - x) * f, y + (target.y - y) * f);
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
      anchors: arr('anchors').map(p).toList(),
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
  final List<P> anchors;
  final List<Box> spikes;
  final List<Saw> saws;
  final List<Box> pads;
  final List<P> coins;

  /// Checkpoint flags. Each should stand on a platform: reviving drops the
  /// character just above the flag.
  final List<P> checkpoints;

  /// Horizontal extent of everything in the level, for camera clamping.
  ({double minX, double maxX, double minY}) get extent {
    var minX = start.x, maxX = finish.x + finish.w / 2, minY = start.y;
    void add(double x, double y, [double r = 0]) {
      minX = math.min(minX, x - r);
      maxX = math.max(maxX, x + r);
      minY = math.min(minY, y - r);
    }

    for (final b in [...platforms, ...spikes, ...pads]) {
      add(b.x, b.y, math.max(b.w, b.h) / 2);
    }
    for (final a in [...anchors, ...coins, ...checkpoints]) {
      add(a.x, a.y);
    }
    for (final s in saws) {
      add(s.x, s.y, s.r);
      if (s.to != null) add(s.to!.x, s.to!.y, s.r);
    }
    return (minX: minX, maxX: maxX, minY: minY);
  }
}
