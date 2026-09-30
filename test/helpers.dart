import 'dart:io';

import 'package:floppy_swing/game/config.dart';
import 'package:floppy_swing/game/level.dart';

PhysicsConfig loadPhysics() =>
    PhysicsConfig.parse(File('assets/config/physics.json').readAsStringSync());

EconomyConfig loadEconomy() =>
    EconomyConfig.parse(File('assets/config/economy.json').readAsStringSync());

List<Level> loadLevels() => _loadDir('assets/levels');

/// The Daily Challenge pool.
List<Level> loadDailies() => _loadDir('assets/daily');

List<Level> _loadDir(String dir) {
  final files = Directory(dir)
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  return files.map((f) => Level.parse(f.readAsStringSync())).toList();
}

/// A tiny hand-made level for unit tests.
Level testLevel({
  String extra = '',
  double finishX = 40,
}) => Level.parse('''{
  "id": 99, "name": "Test", "targetTime": 20, "start": [3.5, -2], "killY": 6,
  "finish": [$finishX, -3, 4, 7],
  "platforms": [[3, 0, 5, 1], [$finishX, 1, 8, 1]],
  "anchors": [[5, -8], [13, -8.5], [21, -8], [29, -8.5]]
  $extra
}''');
