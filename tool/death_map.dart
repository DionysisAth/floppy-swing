// ignore_for_file: avoid_print
// Where does the autopilot die on a level? Helps spot unfair spots.
//   dart run tool/death_map.dart assets/levels/level_13.json
import 'dart:io';

import 'package:floppy_swing/game/autopilot.dart';
import 'package:floppy_swing/game/config.dart';
import 'package:floppy_swing/game/level.dart';
import 'package:floppy_swing/game/simulation.dart';

void main(List<String> args) {
  final cfg = PhysicsConfig.parse(File('assets/config/physics.json').readAsStringSync());
  final level = Level.parse(File(args.first).readAsStringSync());
  final hist = <String, int>{};
  for (final p in autopilotSearchSpace()) {
    final sim = Simulation(level, cfg);
    final pilot = Autopilot(p);
    while (sim.status == SimStatus.running && sim.t < 90) {
      pilot.drive(sim);
      sim.step();
    }
    final key = sim.status == SimStatus.finished
        ? 'finished'
        : '${sim.deathCause?.name ?? 'timeout'} @x=${((sim.deathPoint?.x ?? sim.ragdoll.torso.position.x) / 3).round() * 3} y=${((sim.deathPoint?.y ?? 0) / 3).round() * 3}';
    hist[key] = (hist[key] ?? 0) + 1;
  }
  final keys = hist.keys.toList()..sort((a, b) => hist[b]!.compareTo(hist[a]!));
  for (final k in keys) {
    print('${hist[k]!.toString().padLeft(3)}  $k');
  }
}
