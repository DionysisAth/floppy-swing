// ignore_for_file: avoid_print
// Finds autopilot settings that finish each level, proving it can be beaten.
//
//   dart run tool/check_levels.dart [--balance] [levelFile ...]
//
// Writes the fastest working settings for each level to
// test/level_solutions.json, which test/levels_test.dart replays.
//
// --balance also rewrites each level's coins along that run's path and sets
// its target time from it (see balanceLevel).
//
// --fix (after a physics change) checks the campaign and the Daily Challenge
// pool and only touches what broke: it keeps working settings, finds new
// ones that still collect every coin in time, and rebalances a level's coins
// and target time only when no setting can (see fixLevel).
import 'dart:convert';
import 'dart:io';

import 'package:floppy_swing/game/config.dart';
import 'package:floppy_swing/game/level.dart';

import 'src/level_tools.dart';

Future<void> main(List<String> argv) async {
  final args = argv.where((a) => !a.startsWith('--')).toList();
  final balance = argv.contains('--balance');
  final cfg = loadPhysicsConfig();
  if (argv.contains('--fix')) return _fix(args, cfg);
  final files = args.isNotEmpty
      ? args
      : (Directory('assets/levels').listSync().map((f) => f.path).where((p) => p.endsWith('.json')).toList()..sort());
  final solutions = readSolutions();
  final jsons = [for (final f in files) jsonDecode(File(f).readAsStringSync()) as Map<String, dynamic>];
  final checks = await pooled([for (final j in jsons) () => checkLevel(j, cfg)]);
  var allOk = true;
  for (var i = 0; i < files.length; i++) {
    final json = jsons[i];
    final level = Level.fromJson(json);
    final c = checks[i];
    final name = files[i].split('/').last;
    final best = c.best;
    if (best != null) {
      if (balance) File(files[i]).writeAsStringSync(encodeLevel(balanceLevel(json, cfg, best.params)));
      solutions['${level.id}'] = solutionFor(best.params);
      print('OK   $name "${level.name}": ${c.wins}/${c.tried} win, best ${best.time.toStringAsFixed(1)}s '
          '(target ${level.targetTime}) coins ${best.coins}/${level.coins.length}  [${best.params}]');
    } else {
      allOk = false;
      solutions.remove('${level.id}');
      final far = c.farthest!;
      print('FAIL $name "${level.name}": best x=${far.x.toStringAsFixed(1)} of ${level.finish.x} '
          '(${far.status.name}) [${far.params}]');
    }
  }
  writeSolutions(solutions);
  if (!allOk) exitCode = 1;
}

Future<void> _fix(List<String> args, PhysicsConfig cfg) async {
  List<String> jsonsIn(String dir) =>
      Directory(dir).listSync().map((f) => f.path).where((p) => p.endsWith('.json')).toList()..sort();
  final files = args.isNotEmpty ? args : [...jsonsIn('assets/levels'), ...jsonsIn('assets/daily')];
  final solutions = readSolutions();
  final jsons = [for (final f in files) jsonDecode(File(f).readAsStringSync()) as Map<String, dynamic>];
  final fixes = await pooled([
    for (final j in jsons) () => fixLevel(j, cfg, solutions['${j['id']}'] as Map<String, dynamic>?),
  ], parallel: Platform.numberOfProcessors);
  var allOk = true;
  for (var i = 0; i < files.length; i++) {
    final id = jsons[i]['id'];
    final fix = fixes[i];
    final name = files[i].split('/').last;
    if (fix.params == null) {
      allOk = false;
      solutions.remove('$id');
      print('FAIL $name: no setting finishes it');
      continue;
    }
    if (fix.json != null) File(files[i]).writeAsStringSync(encodeLevel(fix.json!));
    solutions['$id'] = solutionFor(fix.params!);
    if (fix.note != 'kept') print('OK   $name: ${fix.note}');
  }
  writeSolutions(solutions);
  print(allOk ? 'All ${files.length} levels can be finished with three stars.' : 'Some levels failed.');
  if (!allOk) exitCode = 1;
}
