import 'package:flutter/material.dart';

import '../app.dart';
import 'game_screen.dart';
import 'theme.dart';
import 'widgets.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    final progress = services.progress;
    return Scaffold(
      backgroundColor: const Color(0xFF7CC8FF),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: progress,
          builder: (context, _) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
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
                          Text('WORLD 1', style: display(18, color: AppColors.yellow)),
                          Text('Playground', style: display(32)),
                        ],
                      ),
                    ),
                    CoinBadge(coins: progress.coins),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 120,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: services.levels.length,
                  itemBuilder: (context, i) {
                    final level = services.levels[i];
                    final unlocked = progress.isUnlocked(level.id);
                    final rec = progress.record(level.id);
                    return _LevelTile(
                      number: level.id,
                      name: level.name,
                      stars: rec.stars,
                      unlocked: unlocked,
                      onTap: unlocked
                          ? () => Navigator.of(context).push(popRoute(GameScreen(levelId: level.id)))
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (unlocked)
            Text('$number', style: display(40, color: AppColors.orange))
          else
            const Icon(Icons.lock_rounded, size: 38, color: Colors.white),
          const SizedBox(height: 4),
          StarRow(mask: stars, size: 20, spacing: 0),
        ],
      ),
    ),
  );
}
