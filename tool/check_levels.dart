// ignore_for_file: avoid_print
// Finds autopilot settings that finish each level, proving it can be beaten.
//
//   dart run tool/check_levels.dart [levelFile ...]
//
// Writes the first working settings for each level to
// test/level_solutions.json, which test/levels_test.dart replays.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:floppy_swing/game/autopilot.dart';
import 'package:floppy_swing/game/config.dart';
import 'package:floppy_swing/game/level.dart';
import 'package:floppy_swing/game/simulation.dart';

void main(List<String> argv) {
  final args = argv.where((a) => !a.startsWith('--')).toList();
  // --balance: rewrite each level's coins along the best run's path and set
  // its target time from the best time. Coins have no physics, so the same
  // run still collects every coin: all three stars are proven reachable.
  final balance = argv.contains('--balance');
  final cfg = PhysicsConfig.parse(File('assets/config/physics.json').readAsStringSync());
  final files = args.isNotEmpty
      ? args
      : (Directory('assets/levels').listSync().map((f) => f.path).where((p) => p.endsWith('.json')).toList()..sort());
  final solFile = File('test/level_solutions.json');
  final solutions = solFile.existsSync()
      ? (jsonDecode(solFile.readAsStringSync()) as Map<String, dynamic>)
      : <String, dynamic>{};
  final space = autopilotSearchSpace().toList();
  var allOk = true;
  for (final path in files) {
    final level = Level.parse(File(path).readAsStringSync());
    AutopilotRun? best;
    AutopilotRun? farthest;
    var tried = 0, wins = 0;
    for (final p in space) {
      tried++;
      final r = runAutopilot(level, () => Simulation(level, cfg), p);
      if (r.finished && balance) {
        // Ignore coins while balancing: prefer the fastest clean run.
        if (best == null || r.time < best.time) best = r;
        wins++;
        continue;
      }
      if (r.finished) {
        wins++;
        if (best == null || r.coins > best.coins || (r.coins == best.coins && r.time < best.time)) best = r;
      } else if (farthest == null || r.x > farthest.x) {
        farthest = r;
      }
    }
    final name = path.split('/').last;
    if (best != null && balance) {
      _balance(path, level, cfg, best.params);
    }
    if (best != null) {
      solutions['${level.id}'] = {
        'releaseAngle': best.params.releaseAngle,
        'regrabDelay': best.params.regrabDelay,
        'minFallSpeed': best.params.minFallSpeed,
      };
      print('OK   $name "${level.name}": $wins/$tried win, best ${best.time.toStringAsFixed(1)}s '
          '(target ${level.targetTime}) coins ${best.coins}/${level.coins.length}  [${best.params}]');
    } else {
      allOk = false;
      solutions.remove('${level.id}');
      print('FAIL $name "${level.name}": best x=${farthest!.x.toStringAsFixed(1)} of ${level.finish.x} '
          '(${farthest.status.name}) [${farthest.params}]');
    }
  }
  solFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(solutions));
  if (!allOk) exitCode = 1;
}

/// Replays [params] recording the torso path, then rewrites the level JSON
/// with coins placed along it and a target time based on the run.
void _balance(String path, Level level, PhysicsConfig cfg, AutopilotParams params) {
  final sim = Simulation(level, cfg);
  final pilot = Autopilot(params);
  final pts = <List<double>>[];
  while (sim.status == SimStatus.running && sim.t < 90) {
    pilot.drive(sim);
    sim.step();
    final p = sim.ragdoll.torso.position;
    if (sim.startedAt != null) pts.add([p.x, p.y]);
  }
  final json = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  final groups = (json['coinGroups'] as num?)?.toInt() ?? 5;
  // Cumulative path length.
  final len = <double>[0];
  for (var i = 1; i < pts.length; i++) {
    final dx = pts[i][0] - pts[i - 1][0], dy = pts[i][1] - pts[i - 1][1];
    len.add(len.last + math.sqrt(dx * dx + dy * dy));
  }
  bool nearHazard(double x, double y) {
    for (final s in level.spikes) {
      if (s.distanceTo(x, y) < 1.2) return true;
    }
    for (final s in level.saws) {
      final c = s.positionAt(0);
      if (math.sqrt(math.pow(c.x - x, 2) + math.pow(c.y - y, 2)) < s.r + 1.0) return true;
    }
    for (final p in level.platforms) {
      if (p.distanceTo(x, y) < 0.7) return true;
    }
    return false;
  }

  final coins = <List<double>>[];
  final total = len.last;
  for (var g = 0; g < groups; g++) {
    // Trails of three coins spread along the run, skipping the very start.
    final centre = total * (0.08 + 0.84 * (g + 0.5) / groups);
    for (final off in [-1.4, 0.0, 1.4]) {
      final target = centre + off;
      var i = len.indexWhere((l) => l >= target);
      if (i < 0) i = len.length - 1;
      final x = pts[i][0], y = pts[i][1];
      if (nearHazard(x, y) || level.finish.contains(x, y)) continue;
      coins.add([(x * 10).roundToDouble() / 10, (y * 10).roundToDouble() / 10]);
    }
  }
  json['coins'] = coins;
  json['targetTime'] = ((sim.runTime * 1.4 + 2.5) * 2).ceil() / 2;
  File(path).writeAsStringSync(_encodeLevel(json));
}

/// Pretty-prints a level with one geometry entry per line.
String _encodeLevel(Map<String, dynamic> json) {
  final b = StringBuffer('{\n');
  final keys = json.keys.toList();
  for (var i = 0; i < keys.length; i++) {
    final k = keys[i];
    final v = json[k];
    b.write('  "$k": ');
    if (v is List && v.isNotEmpty && (v.first is List || v.first is Map)) {
      b.write('[\n');
      for (var j = 0; j < v.length; j++) {
        b.write('    ${jsonEncode(v[j])}${j < v.length - 1 ? ',' : ''}\n');
      }
      b.write('  ]');
    } else {
      b.write(jsonEncode(v));
    }
    b.write(i < keys.length - 1 ? ',\n' : '\n');
  }
  b.write('}\n');
  return b.toString();
}
