// ignore_for_file: avoid_print
// Generates campaign levels 16-100 (World 1's last five, then Worlds 2-5),
// keeping only candidates the autopilot can beat, then balancing coins and
// target times along the proven run.
//
//   dart run tool/gen_levels.dart            # all generated levels
//   dart run tool/gen_levels.dart 21 22 40   # just these ids
//   dart run tool/gen_levels.dart --daily    # the Daily Challenge pool
//   dart run tool/gen_levels.dart --daily 3  # just daily #3
//
// Levels 1-15 are hand-made and never touched. Each level is built from
// "segments" (a gap between rings plus a hazard or mechanic), with a
// difficulty ramp inside each world and later worlds mixing in earlier
// mechanics. Generation is seeded by level id, so reruns are reproducible.
import 'dart:io';
import 'dart:math' as math;

import 'package:floppy_swing/game/config.dart';
import 'package:floppy_swing/game/course_builder.dart';

import 'src/level_tools.dart';

const firstGenerated = 16;
const lastLevel = 100;

/// Daily Challenge pool size. Daily n has level id [dailyBaseId] + n.
const dailyCount = 60;
const dailyBaseId = 1000;

const _dailyAdjectives = [
  'Wobbly', 'Bonkers', 'Slippery', 'Turbo', 'Sneaky', 'Jiggly', 'Mighty', 'Dizzy', 'Spicy', 'Rubbery',
  'Zippy', 'Grumpy',
];
const _dailyNouns = ['Gauntlet', 'Detour', 'Dash', 'Scramble', 'Circuit'];

String dailyName(int n) =>
    '${_dailyAdjectives[(n * 7) % _dailyAdjectives.length]} ${_dailyNouns[n % _dailyNouns.length]}';

String dailyPath(int n) => 'assets/daily/daily_${n.toString().padLeft(3, '0')}.json';

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

Future<void> main(List<String> argv) async {
  final cfg = loadPhysicsConfig();
  final daily = argv.contains('--daily');
  final args = argv.where((a) => !a.startsWith('--')).toList();
  final solutions = readSolutions();
  if (daily) {
    await _makeDailies(args.isNotEmpty ? args.map(int.parse).toList() : [for (var n = 1; n <= dailyCount; n++) n],
        cfg, solutions);
    return;
  }
  final ids = args.isNotEmpty
      ? args.map(int.parse).toList()
      : [for (var i = firstGenerated; i <= lastLevel; i++) i];

  Future<String> make(int id) async {
    for (var attempt = 0; attempt < 18; attempt++) {
      final world = (id - 1) ~/ 20 + 1;
      final index = (id - 1) % 20 + 1;
      final worldNames = names[world]!;
      final name = worldNames[(world == 1 ? index - 16 : index - 1).clamp(0, worldNames.length - 1)];
      final json = CourseBuilder.campaign(id, attempt).build(id: id, name: name, hint: hints[id]);
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

/// Daily challenges: a late-world-style level themed on each world in turn,
/// verified and balanced like campaign levels.
Future<void> _makeDailies(List<int> numbers, PhysicsConfig cfg, Map<String, dynamic> solutions) async {
  Directory('assets/daily').createSync(recursive: true);
  Future<String> make(int n) async {
    final id = dailyBaseId + n;
    final world = (n - 1) % 5 + 1;
    for (var attempt = 0; attempt < 18; attempt++) {
      final ease = attempt < 6 ? 1.0 : (attempt < 12 ? 0.8 : 0.6);
      final rng = math.Random(id * 7919 + attempt * 104729);
      final builder = CourseBuilder(
        rng: rng,
        world: world,
        index: 8 + rng.nextInt(10),
        difficulty: (0.45 + rng.nextDouble() * 0.35) * ease,
      );
      final json = builder.build(id: id, name: dailyName(n))..['world'] = world;
      final check = await checkLevel(json, cfg, stopAfterWins: minWins, requireEngagement: true);
      if (check.wins < minWins || check.engagingWins == 0) continue;
      final full = await checkLevel(json, cfg, requireEngagement: true);
      final best = full.best!;
      final balanced = balanceLevel(json, cfg, best.params);
      File(dailyPath(n)).writeAsStringSync(encodeLevel(balanced));
      solutions['$id'] = solutionFor(best.params);
      return 'OK   daily $n "${json['name']}" (world $world) attempt $attempt: ${full.wins}/${full.tried} wins, '
          'target ${balanced['targetTime']}';
    }
    exitCode = 1;
    return 'FAIL daily $n: no fair candidate found';
  }

  final results = await pooled([for (final n in numbers) () => make(n)], parallel: Platform.numberOfProcessors);
  results.forEach(print);
  writeSolutions(solutions);
}
