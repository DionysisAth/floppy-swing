import 'package:flutter/material.dart';

import 'game/config.dart';
import 'game/level.dart';
import 'services/ads_service.dart';
import 'services/analytics.dart';
import 'services/audio_service.dart';
import 'services/progress.dart';
import 'ui/menu_screen.dart';
import 'ui/theme.dart';

/// Number of campaign levels shipped in `assets/levels/`.
const levelCount = 100;

/// Loads configs and levels from the asset bundle.
Future<({PhysicsConfig physics, EconomyConfig economy, List<Level> levels})> loadContent(
  AssetBundle bundle,
) async {
  final physics = PhysicsConfig.parse(await bundle.loadString('assets/config/physics.json'));
  final economy = EconomyConfig.parse(await bundle.loadString('assets/config/economy.json'));
  final levels = <Level>[
    for (var i = 1; i <= levelCount; i++)
      Level.parse(await bundle.loadString('assets/levels/level_${i.toString().padLeft(3, '0')}.json')),
  ];
  return (physics: physics, economy: economy, levels: levels);
}

/// App-wide services, available to every screen.
class AppServices extends InheritedWidget {
  const AppServices({
    super.key,
    required this.physics,
    required this.economy,
    required this.levels,
    required this.progress,
    required this.audio,
    required this.ads,
    required this.analytics,
    required super.child,
  });

  final PhysicsConfig physics;
  final EconomyConfig economy;
  final List<Level> levels;
  final ProgressStore progress;
  final AudioService audio;
  final AdsService ads;
  final Analytics analytics;

  static AppServices of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppServices>()!;

  static AppServices? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppServices>();

  Level? levelById(int id) => id >= 1 && id <= levels.length ? levels[id - 1] : null;

  @override
  bool updateShouldNotify(AppServices oldWidget) => false;
}

class FloppySwingApp extends StatelessWidget {
  const FloppySwingApp({super.key, required this.services});

  final AppServices Function(Widget child) services;

  @override
  Widget build(BuildContext context) => services(
    MaterialApp(
      title: 'Floppy Swing',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const MenuScreen(),
    ),
  );
}

/// Screen transition used everywhere: a quick pop-in so the game never feels
/// like it's loading.
Route<T> popRoute<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 180),
  reverseTransitionDuration: const Duration(milliseconds: 140),
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (_, anim, _, child) => FadeTransition(
    opacity: anim,
    child: ScaleTransition(
      scale: Tween(begin: 0.96, end: 1.0).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
      child: child,
    ),
  ),
);
