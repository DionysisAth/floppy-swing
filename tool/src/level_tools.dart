// Shared helpers for the level tools: parallel autopilot checks, coin and
// target-time balancing, and pretty JSON output.
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:floppy_swing/game/autopilot.dart';
import 'package:floppy_swing/game/config.dart';
import 'package:floppy_swing/game/level.dart';
import 'package:floppy_swing/game/simulation.dart';


PhysicsConfig loadPhysicsConfig() =>
    PhysicsConfig.parse(File('assets/config/physics.json').readAsStringSync());

String levelPath(int id) => 'assets/levels/level_${id.toString().padLeft(3, '0')}.json';

/// Whether a run actually used its world's signature mechanic (so the coin
/// trail, which follows the balancing run, leads players through it).
bool engagesMechanic(Level level, List<SimEvent> events) {
  switch (level.world) {
    case 2:
      return events.any((e) => e.kind == EventKind.grab && level.anchors[e.value.toInt()].moving);
    case 3:
      return level.glass.isEmpty || events.any((e) => e.kind == EventKind.shatter);
    case 4:
      return level.flips.isEmpty || events.any((e) => e.kind == EventKind.flip);
    case 5:
      return level.crumbles.isEmpty || events.any((e) => e.kind == EventKind.crumble);
    default:
      return true;
  }
}

/// Outcome of throwing the autopilot at a level.
class LevelCheck {
  LevelCheck(this.tried, this.wins, this.best, this.farthest, {this.engagingWins = 0});
  final int tried;
  final int wins;
  final int engagingWins;

  /// Fastest finishing run (null if none finished). When checked with
  /// requireEngagement, the fastest finishing run that uses the mechanic.
  final AutopilotRun? best;

  /// The run that got furthest without finishing.
  final AutopilotRun? farthest;

  bool get ok => best != null;
}

/// Tries every autopilot setting on [json] (stopping early after
/// [stopAfterWins] wins when > 0). Runs in a separate isolate.
Future<LevelCheck> checkLevel(
  Map<String, dynamic> json,
  PhysicsConfig cfg, {
  int stopAfterWins = 0,
  bool requireEngagement = false,
}) {
  final encoded = jsonEncode(json);
  return Isolate.run(() {
    final level = Level.parse(encoded);
    AutopilotRun? best, farthest;
    var tried = 0, wins = 0, engaging = 0;
    for (final p in autopilotSearchSpace()) {
      tried++;
      final r = runAutopilot(level, () => Simulation(level, cfg), p);
      if (r.finished) {
        wins++;
        final engages = engagesMechanic(level, r.events);
        if (engages) engaging++;
        if ((!requireEngagement || engages) && (best == null || r.time < best.time)) best = r;
        if (stopAfterWins > 0 && wins >= stopAfterWins && (!requireEngagement || engaging > 0)) break;
      } else if (farthest == null || r.x > farthest.x) {
        farthest = r;
      }
    }
    // Strip events before sending results back across the isolate boundary.
    AutopilotRun? slim(AutopilotRun? r) =>
        r == null ? null : AutopilotRun(r.params, r.status, r.time, r.coins, r.x);
    return LevelCheck(tried, wins, slim(best), slim(farthest), engagingWins: engaging);
  });
}

/// Runs [tasks] with at most [parallel] at a time.
Future<List<T>> pooled<T>(List<Future<T> Function()> tasks, {int parallel = 4}) async {
  final results = List<T?>.filled(tasks.length, null);
  var next = 0;
  Future<void> worker() async {
    while (next < tasks.length) {
      final i = next++;
      results[i] = await tasks[i]();
    }
  }

  await Future.wait([for (var i = 0; i < parallel; i++) worker()]);
  return results.cast<T>();
}

/// Replays [params] recording the torso path, then places coin trails along
/// it and sets the target time from the run. Coins have no physics, so the
/// same run still collects every coin: all three stars are proven reachable.
Map<String, dynamic> balanceLevel(Map<String, dynamic> json, PhysicsConfig cfg, AutopilotParams params) {
  final level = Level.fromJson(json);
  final sim = Simulation(level, cfg);
  final pilot = Autopilot(params);
  final pts = <List<double>>[];
  while (sim.status == SimStatus.running && sim.t < 90) {
    pilot.drive(sim);
    sim.step();
    final p = sim.ragdoll.torso.position;
    if (sim.startedAt != null) pts.add([p.x, p.y]);
  }
  final groups = (json['coinGroups'] as num?)?.toInt() ?? 5;
  final len = <double>[0];
  for (var i = 1; i < pts.length; i++) {
    final dx = pts[i][0] - pts[i - 1][0], dy = pts[i][1] - pts[i - 1][1];
    len.add(len.last + math.sqrt(dx * dx + dy * dy));
  }
  double segDist(double px, double py, double ax, double ay, double bx, double by) {
    final vx = bx - ax, vy = by - ay;
    final l2 = vx * vx + vy * vy;
    final t = l2 == 0 ? 0.0 : (((px - ax) * vx + (py - ay) * vy) / l2).clamp(0.0, 1.0);
    final cx = ax + vx * t - px, cy = ay + vy * t - py;
    return math.sqrt(cx * cx + cy * cy);
  }

  bool nearHazard(double x, double y) {
    for (final s in level.spikes) {
      if (s.distanceTo(x, y) < 1.2) return true;
    }
    for (final s in level.saws) {
      final to = s.to ?? P(s.x, s.y);
      if (segDist(x, y, s.x, s.y, to.x, to.y) < s.r + 1.0) return true;
    }
    for (final b in [...level.platforms, ...level.glass, ...level.crumbles]) {
      if (b.distanceTo(x, y) < 0.7) return true;
    }
    for (final l in level.launchers) {
      final ex = l.x + math.cos(l.angle) * l.range, ey = l.y + math.sin(l.angle) * l.range;
      if (segDist(x, y, l.x, l.y, ex, ey) < 1.0) return true;
    }
    return false;
  }

  final coins = <List<double>>[];
  final total = len.last;
  for (var g = 0; g < groups; g++) {
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
  if (coins.isEmpty && pts.isNotEmpty) {
    final mid = pts[pts.length ~/ 2];
    coins.add([(mid[0] * 10).roundToDouble() / 10, (mid[1] * 10).roundToDouble() / 10]);
  }
  return {
    ...json,
    'coins': coins,
    'targetTime': ((sim.runTime * 1.4 + 2.5) * 2).ceil() / 2,
  };
}

Map<String, dynamic> solutionFor(AutopilotParams p) => {
  'releaseAngle': p.releaseAngle,
  'regrabDelay': p.regrabDelay,
  'minFallSpeed': p.minFallSpeed,
};

AutopilotParams paramsFrom(Map<String, dynamic> m) => AutopilotParams(
  releaseAngle: (m['releaseAngle'] as num).toDouble(),
  regrabDelay: (m['regrabDelay'] as num).toDouble(),
  minFallSpeed: (m['minFallSpeed'] as num).toDouble(),
);

File solutionsFile() => File('test/level_solutions.json');

Map<String, dynamic> readSolutions() {
  final f = solutionsFile();
  return f.existsSync() ? jsonDecode(f.readAsStringSync()) as Map<String, dynamic> : <String, dynamic>{};
}

void writeSolutions(Map<String, dynamic> s) {
  final sorted = Map.fromEntries(s.entries.toList()..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key))));
  solutionsFile().writeAsStringSync(const JsonEncoder.withIndent('  ').convert(sorted));
}

/// Pretty-prints a level with one geometry entry per line.
String encodeLevel(Map<String, dynamic> json) {
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
