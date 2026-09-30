import 'dart:math' as math;

import 'level.dart';

/// Builds courses out of "segments": a gap between rings plus a hazard or
/// mechanic. Used offline by `tool/gen_levels.dart` for campaign and daily
/// levels (which the bot then verifies), and at runtime for Endless mode.
///
/// Coordinates are metres with y pointing down; rings hang around y = -8.5
/// and the pit is at y = 6.
class CourseBuilder {
  CourseBuilder({
    required this.rng,
    required this.world,
    required this.index,
    required this.difficulty,
  });

  /// Campaign level [id]; later [attempt]s get progressively easier.
  factory CourseBuilder.campaign(int id, int attempt) {
    final index = (id - 1) % 20 + 1;
    final ease = attempt < 6 ? 1.0 : (attempt < 12 ? 0.75 : 0.5);
    return CourseBuilder(
      rng: math.Random(id * 7919 + attempt * 104729),
      world: (id - 1) ~/ 20 + 1,
      index: index,
      difficulty: (index / 20) * ease,
    );
  }

  final int world;
  final int index;
  final math.Random rng;

  /// 0 (gentle) to 1 (hardest); endless raises it as the course goes on.
  double difficulty;

  final platforms = <List<num>>[
    [3, 0, 5, 1],
  ];
  final anchors = <List<num>>[
    [5, -8],
  ];
  final spikes = <List<num>>[];
  final saws = <Map<String, num>>[];
  final pads = <List<num>>[];
  final checkpoints = <List<num>>[];
  final glass = <List<num>>[];
  final winds = <List<num>>[];
  final flips = <List<num>>[];
  final crumbles = <List<num>>[];
  final rockets = <Map<String, num>>[];

  double x = 5; // Last ring.
  double y = -8;

  double r(double a, double b) => a + rng.nextDouble() * (b - a);
  double round(double v) => (v * 10).roundToDouble() / 10;

  /// Adds the next ring [gap] metres on, returning the gap's midpoint.
  double ring(double gap, {List<num>? motion}) {
    final mid = x + gap / 2;
    x = round(x + gap);
    y = round(r(-10, -7.5));
    anchors.add([x, y, ...?motion]);
    return mid;
  }

  double gap() => r(8.5, 10.5 + difficulty * 1.8);

  // ------------------------------------------------------------ segments

  void plain() => ring(gap());

  void spikePillar() {
    final m = ring(gap());
    final h = r(6, 6.5 + difficulty * 1.6);
    spikes.add([round(m), round(3 + (h - 6) / 2 + 0.0), 2, round(h)]);
  }

  void ceiling() {
    final start = x;
    ring(gap());
    final w = x - start + 3;
    spikes.add([round(start + w / 2 - 1.5), -15.5, round(w), 1]);
  }

  void sawHigh() {
    final m = ring(gap());
    saws.add({
      'x': round(m),
      'y': round(r(-13.5, -12.5)),
      'r': round(r(1.1, 1.4)),
    });
  }

  void sawLow() {
    ring(gap());
    saws.add({'x': x, 'y': round(r(2.6, 3.0)), 'r': 1.3});
  }

  void sawMoving() {
    final m = ring(gap());
    final low = rng.nextBool();
    saws.add({
      'x': round(m),
      'y': low ? 0 : -13.5,
      'r': 1.1,
      'to': 0, // placeholder replaced below
      'period': round(r(2.6, 3.6)),
      'phase': round(r(0, 1)),
    });
    // Leave a safe high or low route.
    saws.last.remove('to');
    final toY = low ? round(r(-5, -6.5)) : round(r(-8, -7.2));
    saws.last['toX'] = round(m);
    saws.last['toY'] = toY;
  }

  void padGap() {
    final start = x;
    final g = r(18, 21);
    final padX = round(start + g * 0.55);
    platforms.add([padX, 2, 7, 1]);
    pads.add([padX, 1.2, 3.5, 0.6, round(r(13, 17))]);
    x = round(start + g);
    y = -10;
    anchors.add([x, y]);
  }

  void movingRing() {
    final horizontal = rng.nextBool();
    final range = round(r(1.8, 2.4 + difficulty * 1.5));
    final period = round(r(2.4, 3.6));
    final g = gap() - (horizontal ? range / 2 : 0);
    x = round(x + g);
    y = round(r(-9.5, -7.8));
    anchors.add([
      x,
      y,
      horizontal ? round(x + range) : x,
      horizontal ? y : round(y - range),
      period,
      round(r(0, 1)),
    ]);
  }

  void glassWall() {
    final m = ring(gap());
    glass.add([round(m), -5, 0.35, 20]);
  }

  void glassWindow() {
    // A pane across the high route: smash it or duck under it.
    final m = ring(gap());
    glass.add([round(m), -11, 0.35, 8]);
    if (difficulty > 0.4) spikes.add([round(m), 3, 2, 6]);
  }

  void updraft() {
    final start = x;
    final g = r(15, 17.5 + difficulty * 2);
    final mid = round(start + g / 2);
    winds.add([mid, -0.5, 5, 15, 0, round(r(32, 36))]);
    x = round(start + g);
    y = round(r(-10, -8.5));
    anchors.add([x, y]);
  }

  void tailwind() {
    final start = x;
    ring(gap() + 1.5);
    final w = x - start - 2;
    winds.add([
      round(start + 1 + w / 2),
      -6,
      round(w),
      8,
      90,
      round(r(14, 18)),
    ]);
  }

  void flipTunnel() {
    final m = ring(r(11, 13));
    flips.add([round(m), -3, 5, 10]);
    spikes.add([round(m), -16.5, 8, 1]);
  }

  void crumbleBridge() {
    // A long gap with a crumbling island where you naturally come down; the
    // next ring is only a slingshot away from it.
    final start = x;
    final cx = round(start + r(9.5, 11));
    crumbles.add([cx, 0.2, 4, 0.8]);
    x = round(cx + 5);
    y = -7.5;
    anchors.add([x, y]);
  }

  void rocketGap() {
    final m = ring(gap());
    rockets.add({
      'x': round(m),
      'y': 6.5,
      'angle': round(r(-105, -75)),
      'speed': round(r(9, 11.5)),
      'period': round(r(2.6, 3.4)),
      'phase': round(r(0, 1)),
      'range': 24,
    });
  }

  /// A platform to land on, with a ring a slingshot away.
  void rest() {
    final cx = round(x + 9);
    platforms.add([cx, 1, 6, 1]);
    x = round(cx + 1.5);
    y = -7.5;
    anchors.add([x, y]);
  }

  void checkpoint() {
    rest();
    checkpoints.add([platforms.last[0], 0.5]);
  }

  // --------------------------------------------------------------- build

  /// Weighted segment menu for this world and difficulty.
  List<(double, void Function())> menu() {
    final d = difficulty;
    final intro = index == 1;
    final plainW = intro ? 1.2 : 0.9 - 0.55 * d;
    return switch (world) {
      1 => [
        (plainW, plain),
        (0.35, spikePillar),
        (0.2, ceiling),
        (0.25, sawHigh),
        (0.2, sawLow),
        (0.15 + 0.2 * d, sawMoving),
        (0.2, padGap),
      ],
      2 => [
        (plainW, plain),
        (intro ? 0.6 : 0.9, movingRing),
        (0.25, sawHigh),
        (0.2, sawLow),
        (intro ? 0 : 0.3, sawMoving),
        (intro ? 0 : 0.2, spikePillar),
        (intro ? 0 : 0.12, ceiling),
      ],
      3 => [
        (plainW, plain),
        (intro ? 0.6 : 0.7, glassWall),
        (intro ? 0 : 0.3, glassWindow),
        (0.2, padGap),
        (intro ? 0 : 0.25, spikePillar),
        (intro ? 0 : 0.15, sawHigh),
        (d > 0.5 ? 0.25 : 0, movingRing),
      ],
      4 => [
        (plainW, plain),
        (intro ? 0.6 : 0.5, updraft),
        (intro ? 0 : 0.25, tailwind),
        (index >= 4 ? 0.45 : 0, flipTunnel),
        (0.15, padGap),
        (intro ? 0 : 0.15, sawHigh),
        (d > 0.5 ? 0.2 : 0, glassWall),
      ],
      _ => [
        (plainW, plain),
        (intro ? 0.6 : 0.55, crumbleBridge),
        (index >= 4 ? 0.5 : 0, rocketGap),
        (intro ? 0 : 0.2, sawMoving),
        (intro ? 0 : 0.2, spikePillar),
        (d > 0.4 ? 0.2 : 0, movingRing),
        (d > 0.6 ? 0.15 : 0, glassWall),
      ],
    };
  }

  /// The mechanic each world is about; every level must feature it.
  List<void Function()> signature() => switch (world) {
    2 => [movingRing],
    3 => [glassWall, glassWindow],
    4 => [updraft, if (index >= 4) flipTunnel, tailwind],
    5 => [crumbleBridge, if (index >= 4) rocketGap],
    _ => const [],
  };

  void Function() pick(List<(double, void Function())> options) {
    final total = options.fold(0.0, (s, o) => s + o.$1);
    var roll = rng.nextDouble() * total;
    for (final o in options) {
      roll -= o.$1;
      if (roll <= 0) return o.$2;
    }
    return options.first.$2;
  }

  /// A campaign-style level: segments until the course is long enough,
  /// then a finish platform.
  Map<String, dynamic> build({
    required int id,
    required String name,
    String? hint,
  }) {
    final length = 55 + difficulty * 75;
    final checkpointAt = [
      if (length > 90) length * 0.5,
      if (length > 118) length * 0.78,
    ];
    // Always open with a gentle swing so the slingshot start feels good.
    plain();
    final options = menu();
    final sig = signature();
    final required = sig.isEmpty ? 0 : (index == 1 ? 2 : 3);
    var sigCount = 0;
    void Function()? last;
    while (x < length) {
      if (checkpointAt.isNotEmpty && x > checkpointAt.first) {
        checkpointAt.removeAt(0);
        checkpoint();
        continue;
      }
      var seg = pick(options);
      // Avoid the same hazard twice in a row (except plain swings).
      if (seg == last && seg != plain) seg = pick(options);
      // Make sure the world's mechanic shows up often enough, spread out.
      if (sigCount < required &&
          x > length * (sigCount + 0.6) / (required + 1) &&
          !sig.contains(seg)) {
        seg = sig[rng.nextInt(sig.length)];
      }
      if (sig.contains(seg)) sigCount++;
      seg();
      last = seg;
    }
    final fx = round(x + 9);
    platforms.add([fx, 1, 8, 1]);
    return {
      'id': id,
      'name': name,
      'targetTime': 30,
      'start': [3.5, -2],
      'killY': 6,
      'platforms': platforms,
      'anchors': anchors,
      if (spikes.isNotEmpty) 'spikes': spikes,
      if (saws.isNotEmpty)
        'saws': [
          for (final s in saws)
            {
              'x': s['x'],
              'y': s['y'],
              'r': s['r'],
              if (s.containsKey('toX')) 'to': [s['toX'], s['toY']],
              if (s.containsKey('period')) 'period': s['period'],
              if (s.containsKey('phase')) 'phase': s['phase'],
            },
        ],
      if (pads.isNotEmpty) 'pads': pads,
      if (glass.isNotEmpty) 'glass': glass,
      if (winds.isNotEmpty) 'winds': winds,
      if (flips.isNotEmpty) 'flips': flips,
      if (crumbles.isNotEmpty) 'crumbles': crumbles,
      if (rockets.isNotEmpty) 'rockets': rockets,
      if (checkpoints.isNotEmpty) 'checkpoints': checkpoints,
      'coinGroups': (4 + difficulty * 4).round(),
      'hint': ?hint,
      'finish': [fx, -3, 5, 7],
    };
  }

  // ------------------------------------------------------------- endless

  /// Endless courses are split into zones this long. Each zone brings in the
  /// next world's mechanics and look; after the fifth, everything mixes and
  /// the looks cycle.
  static const zoneLength = 180.0;

  /// Theme world for endless course position [x].
  static int endlessWorld(double x) => (x / zoneLength).floor() % 5 + 1;

  factory CourseBuilder.endless(int seed) => CourseBuilder(
    rng: math.Random(seed),
    world: 1,
    index: 10,
    difficulty: 0.1,
  );

  List<(double, void Function())> _endlessMenu(int unlocked, int theme) {
    final d = difficulty;
    double w(int world, double own, double other) =>
        world == theme ? own : other;
    return [
      (0.8 - 0.4 * d, plain),
      (0.3, spikePillar),
      (0.15, ceiling),
      (0.2, sawHigh),
      (0.15, sawLow),
      (0.15 + 0.2 * d, sawMoving),
      (0.2, padGap),
      if (unlocked >= 2) (w(2, 0.9, 0.3), movingRing),
      if (unlocked >= 3) ...[
        (w(3, 0.7, 0.2), glassWall),
        (w(3, 0.3, 0.1), glassWindow),
      ],
      if (unlocked >= 4) ...[
        (w(4, 0.5, 0.2), updraft),
        (w(4, 0.25, 0.1), tailwind),
        (w(4, 0.45, 0.15), flipTunnel),
      ],
      if (unlocked >= 5) ...[
        (w(5, 0.55, 0.2), crumbleBridge),
        (w(5, 0.5, 0.2), rocketGap),
      ],
    ];
  }

  /// An Endless course [length] metres long. Difficulty rises with distance
  /// and every zone starts with a platform to catch your breath on. Coins
  /// hang under the rings.
  Map<String, dynamic> buildEndless({double length = 3000}) {
    plain();
    var zone = 0;
    void Function()? last;
    while (x < length) {
      final z = (x / zoneLength).floor();
      if (z != zone) {
        zone = z;
        rest();
        continue;
      }
      difficulty = (0.1 + x / 1400).clamp(0.0, 1.0);
      final options = _endlessMenu(math.min(z + 1, 5), endlessWorld(x));
      var seg = pick(options);
      if (seg == last && seg != plain) seg = pick(options);
      seg();
      last = seg;
    }
    final fx = round(x + 9);
    platforms.add([fx, 1, 8, 1]);
    final json = <String, dynamic>{
      'id': -1,
      'name': 'Endless',
      'targetTime': 9999,
      'start': [3.5, -2],
      'killY': 6,
      'platforms': platforms,
      'anchors': anchors,
      'spikes': spikes,
      'saws': [
        for (final s in saws)
          {
            'x': s['x'],
            'y': s['y'],
            'r': s['r'],
            if (s.containsKey('toX')) 'to': [s['toX'], s['toY']],
            if (s.containsKey('period')) 'period': s['period'],
            if (s.containsKey('phase')) 'phase': s['phase'],
          },
      ],
      'pads': pads,
      'glass': glass,
      'winds': winds,
      'flips': flips,
      'crumbles': crumbles,
      'rockets': rockets,
      'finish': [fx, -3, 5, 7],
    };
    final level = Level.fromJson(json);
    final coins = <List<double>>[];
    for (var i = 2; i < level.anchors.length; i += 2) {
      final a = level.anchors[i];
      for (final (dx, dy) in const [(-1.2, 6.3), (0.0, 6.9), (1.2, 6.3)]) {
        final cx = round(a.x + dx), cy = round(a.y + dy);
        if (!level.nearHazard(cx, cy)) coins.add([cx, cy]);
      }
    }
    json['coins'] = coins;
    return json;
  }
}
