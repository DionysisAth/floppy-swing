// ignore_for_file: avoid_print
// Generates campaign levels 16-100 (World 1's last five, then Worlds 2-5),
// keeping only candidates the autopilot can beat, then balancing coins and
// target times along the proven run.
//
//   dart run tool/gen_levels.dart            # all generated levels
//   dart run tool/gen_levels.dart 21 22 40   # just these ids
//
// Levels 1-15 are hand-made and never touched. Each level is built from
// "segments" (a gap between rings plus a hazard or mechanic), with a
// difficulty ramp inside each world and later worlds mixing in earlier
// mechanics. Generation is seeded by level id, so reruns are reproducible.
import 'dart:io';
import 'dart:math' as math;

import 'src/level_tools.dart';

const firstGenerated = 16;
const lastLevel = 100;

/// Autopilot wins required (out of the search space) for a level to count as
/// fair: more than one lucky line through it.
const minWins = 3;

const names = <int, List<String>>{
  1: ['Treetop Trouble', 'Swing Time', 'Monkey Business', 'Backyard Blitz', 'Recess Rampage'],
  2: [
    'Clock In', 'Moving Parts II', 'Conveyor Chaos', 'Gear Grinder', 'Assembly Lines',
    'Piston Pit', 'Overtime', 'Rusty Rings', 'Sawmill Sprint', 'Hard Hat Zone',
    'Factory Reset', 'Cog Hopper', 'Shift Change', 'Hot Metal', 'Quality Control',
    'Night Shift', 'Pressure Valve', 'Heavy Machinery', 'Boiler Room', 'Foreman\'s Finale',
  ],
  3: [
    'Window Shopping', 'Pane in the Neck', 'Shatterproof? No.', 'Glass Act', 'Skyline Smash',
    'Crystal Clear', 'Mirror Mirror', 'Rooftop Rush', 'Fragile!', 'Broken Records',
    'Clean Break', 'Transparent Trouble', 'Glasshopper', 'High Rise', 'Smash Hit',
    'Crack Up', 'Tower Hopper', 'Shard Luck', 'Penthouse Panic', 'The Glass Ceiling',
  ],
  4: [
    'Head in the Clouds', 'Updraft', 'Gone With the Wind', 'Island Hopping', 'Topsy Turvy',
    'Blown Away', 'Upside Down Town', 'Breezy Does It', 'Cloud Nine', 'Jet Stream',
    'Air Mail', 'Weightless', 'Sky High', 'Flip Flop', 'Tailwind',
    'Floating Isles', 'Whirlwind', 'Gravity? Optional', 'Stormfront', 'Castle in the Air',
  ],
  5: [
    'Countdown', 'Crumble Bridge', 'Launch Window', 'Incoming!', 'Liftoff',
    'Blast Radius', 'Falling Apart', 'Mission Control', 'Rocket Surgery', 'Ground Control',
    'Red Alert', 'Kaboom Canyon', 'Orbit', 'No Solid Ground', 'Fireworks',
    'Space Race', 'Last Stand', 'Meltdown', 'T-Minus Zero', 'Grand Finale II',
  ],
};

const hints = <int, String>{
  21: 'Some rings move. Time your grab!',
  41: 'Glass breaks if you hit it fast enough. Smash through!',
  61: 'Fans blow you upwards. Ride the wind!',
  64: 'Purple zones flip gravity. Up is the new down.',
  81: 'Crumbling platforms fall soon after you land. Keep moving!',
  84: 'Rockets won\'t kill you... but the spikes will.',
};

class Builder {
  Builder(this.id, int attempt)
    : world = (id - 1) ~/ 20 + 1,
      index = (id - 1) % 20 + 1,
      rng = math.Random(id * 7919 + attempt * 104729) {
    // Struggling candidates get progressively easier.
    final ease = attempt < 6 ? 1.0 : (attempt < 12 ? 0.75 : 0.5);
    difficulty = (index / 20) * ease;
  }

  final int id;
  final int world;
  final int index;
  final math.Random rng;
  late final double difficulty;

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
    saws.add({'x': round(m), 'y': round(r(-13.5, -12.5)), 'r': round(r(1.1, 1.4))});
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
    winds.add([round(start + 1 + w / 2), -6, round(w), 8, 90, round(r(14, 18))]);
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

  void checkpoint() {
    final cx = round(x + 9);
    platforms.add([cx, 1, 6, 1]);
    checkpoints.add([cx, 0.5]);
    x = round(cx + 1.5);
    y = -7.5;
    anchors.add([x, y]);
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

  Map<String, dynamic> build() {
    final length = 55 + difficulty * 75;
    final checkpointAt = [if (length > 90) length * 0.5, if (length > 118) length * 0.78];
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
      if (sigCount < required && x > length * (sigCount + 0.6) / (required + 1) && !sig.contains(seg)) {
        seg = sig[rng.nextInt(sig.length)];
      }
      if (sig.contains(seg)) sigCount++;
      seg();
      last = seg;
    }
    final fx = round(x + 9);
    platforms.add([fx, 1, 8, 1]);
    final worldNames = names[world]!;
    final name = worldNames[(world == 1 ? index - 16 : index - 1).clamp(0, worldNames.length - 1)];
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
      if (hints.containsKey(id)) 'hint': hints[id],
      'finish': [fx, -3, 5, 7],
    };
  }
}

Future<void> main(List<String> args) async {
  final cfg = loadPhysicsConfig();
  final ids = args.isNotEmpty
      ? args.map(int.parse).toList()
      : [for (var i = firstGenerated; i <= lastLevel; i++) i];
  final solutions = readSolutions();

  Future<String> make(int id) async {
    for (var attempt = 0; attempt < 18; attempt++) {
      final json = Builder(id, attempt).build();
      final check = await checkLevel(json, cfg, stopAfterWins: minWins, requireEngagement: true);
      if (check.wins < minWins || check.engagingWins == 0) continue;
      // Re-run fully to pick the fastest run that uses the world's mechanic;
      // coins get placed along it, leading players through the mechanic.
      final full = await checkLevel(json, cfg, requireEngagement: true);
      final best = full.best!;
      final balanced = balanceLevel(json, cfg, best.params);
      File(levelPath(id)).writeAsStringSync(encodeLevel(balanced));
      solutions['$id'] = solutionFor(best.params);
      return 'OK   $id "${json['name']}" attempt $attempt: ${full.wins}/${full.tried} wins '
          '(${full.engagingWins} using the mechanic), '
          'best ${best.time.toStringAsFixed(1)}s, target ${balanced['targetTime']}';
    }
    exitCode = 1;
    return 'FAIL $id: no fair candidate found';
  }

  final results = await pooled([for (final id in ids) () => make(id)], parallel: Platform.numberOfProcessors);
  results.forEach(print);
  writeSolutions(solutions);
}
