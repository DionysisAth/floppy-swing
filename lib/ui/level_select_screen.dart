import 'package:flutter/material.dart';

import '../app.dart';
import '../game/worlds.dart';
import '../services/progress.dart';
import 'game_screen.dart';
import 'theme.dart';
import 'widgets.dart';

/// World pager: swipe between worlds, each a grid of its 20 levels. Worlds
/// open once the player has collected enough stars.
class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  PageController? _pages;
  int _world = 1;

  int get _worldCount => (AppServices.of(context).levels.length / WorldInfo.levelsPerWorld).ceil();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pages != null) return;
    // Open on the world of the furthest unlocked level.
    final progress = AppServices.of(context).progress;
    var furthest = 1;
    for (final l in AppServices.of(context).levels) {
      if (progress.isUnlocked(l.id)) furthest = l.id;
    }
    _world = WorldInfo.ofLevel(furthest).clamp(1, _worldCount);
    _pages = PageController(initialPage: _world - 1);
  }

  @override
  void dispose() {
    _pages?.dispose();
    super.dispose();
  }

  void _go(int world) {
    _pages!.animateToPage(world - 1, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    final progress = services.progress;
    final info = WorldInfo.byNumber(_world);
    return Scaffold(
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) => AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [info.color, info.colorDark],
            ),
          ),
          child: ContentArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      RoundButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).pop(),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('WORLD $_world', style: display(18, color: AppColors.yellow)),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(info.name, style: display(32)),
                            ),
                          ],
                        ),
                      ),
                      CoinBadge(coins: progress.coins),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(info.tagline, style: body(15, weight: 700, color: Colors.white)),
                      ),
                      const Icon(Icons.star_rounded, color: AppColors.yellow, size: 22),
                      Text(
                        '${progress.worldStars(_world)}/${WorldInfo.levelsPerWorld * 3}',
                        style: display(18),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: _worldCount,
                    onPageChanged: (i) => setState(() => _world = i + 1),
                    itemBuilder: (context, i) => _WorldPage(world: WorldInfo.byNumber(i + 1), progress: progress),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Opacity(
                        opacity: _world > 1 ? 1 : 0.35,
                        child: RoundButton(
                          icon: Icons.chevron_left_rounded,
                          tooltip: 'Previous world',
                          onPressed: _world > 1 ? () => _go(_world - 1) : null,
                          size: 26,
                        ),
                      ),
                      Row(
                        children: [
                          for (var w = 1; w <= _worldCount; w++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: w == _world ? 22 : 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: progress.isWorldUnlocked(w) ? Colors.white : Colors.white38,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: AppColors.ink, width: 2),
                              ),
                            ),
                        ],
                      ),
                      Opacity(
                        opacity: _world < _worldCount ? 1 : 0.35,
                        child: RoundButton(
                          icon: Icons.chevron_right_rounded,
                          tooltip: 'Next world',
                          onPressed: _world < _worldCount ? () => _go(_world + 1) : null,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorldPage extends StatelessWidget {
  const _WorldPage({required this.world, required this.progress});

  final WorldInfo world;
  final ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    final levels = services.levels.where((l) => l.world == world.number).toList();
    final open = progress.isWorldUnlocked(world.number);
    final grid = GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 88,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: levels.length,
      itemBuilder: (context, i) {
        final level = levels[i];
        final unlocked = progress.isUnlocked(level.id);
        return _LevelTile(
          number: level.id,
          name: level.name,
          stars: progress.record(level.id).stars,
          unlocked: unlocked,
          onTap: unlocked ? () => Navigator.of(context).push(popRoute(GameScreen(levelId: level.id))) : null,
        );
      },
    );
    if (open) return grid;
    final need = world.starsNeeded - progress.totalStars;
    return Stack(
      children: [
        Opacity(opacity: 0.35, child: IgnorePointer(child: grid)),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Panel(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 56, color: AppColors.ink),
                  const SizedBox(height: 8),
                  Text(world.name, style: display(28, color: AppColors.ink, shadow: false)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Collect $need more ', style: body(18, weight: 800)),
                      const Icon(Icons.star_rounded, color: AppColors.yellow, size: 26),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${progress.totalStars}/${world.starsNeeded} stars', style: body(15, weight: 700)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.number,
    required this.name,
    required this.stars,
    required this.unlocked,
    required this.onTap,
  });

  final int number;
  final String name;
  final int stars;
  final bool unlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: unlocked,
    label: 'Level $number, $name${unlocked ? '' : ', locked'}',
    child: ChunkyButton(
      onPressed: onTap,
      color: unlocked ? Colors.white : AppColors.grey,
      shade: unlocked ? const Color(0xFFD8CFC2) : AppColors.greyDark,
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (unlocked)
            FittedBox(child: Text('$number', style: display(34, color: AppColors.orange)))
          else
            const Icon(Icons.lock_rounded, size: 32, color: Colors.white),
          const SizedBox(height: 2),
          StarRow(mask: stars, size: 16, spacing: 0),
        ],
      ),
    ),
  );
}
