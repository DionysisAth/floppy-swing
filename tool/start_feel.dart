// ignore_for_file: avoid_print
// How quickly does the first grab of a level get the character moving?
//   dart run tool/start_feel.dart
import 'dart:io';

import 'package:floppy_swing/game/config.dart';
import 'package:floppy_swing/game/level.dart';
import 'package:floppy_swing/game/simulation.dart';

void main() {
  final cfg = PhysicsConfig.parse(File('assets/config/physics.json').readAsStringSync());
  for (final id in [1, 5, 9]) {
    final level = Level.parse(File('assets/levels/level_${id.toString().padLeft(3, '0')}.json').readAsStringSync());
    final sim = Simulation(level, cfg);
    for (var i = 0; i < 60; i++) {
      sim.step();
    }
    sim.press();
    final samples = <String>[];
    double? reached;
    for (var i = 1; i <= 150; i++) {
      sim.step();
      final v = sim.ragdoll.velocity.length;
      if (reached == null && v >= 9) reached = i / 60;
      if (i % 15 == 0) samples.add(v.toStringAsFixed(1));
    }
    print('level $id: speed every 0.25s after grab: ${samples.join(' ')}  | time to 9 m/s: ${reached?.toStringAsFixed(2) ?? 'never'}s');
  }
}
