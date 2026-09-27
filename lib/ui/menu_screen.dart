import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../game/autopilot.dart';
import '../game/floppy_game.dart';
import '../game/game_controller.dart';
import '../game/skins.dart';
import 'level_select_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import 'theme.dart';
import 'widgets.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  GameController? _demo;
  FloppyGame? _game;
  late final AnimationController _wobble = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();
  GamePhase _lastPhase = GamePhase.ready;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_demo != null) return;
    final services = AppServices.of(context);
    // Attract mode: the autopilot plays level 1 behind the menu, silently.
    _demo = GameController(
      level: services.levels.first,
      cfg: services.physics,
      skin: skinById(services.progress.selectedSkin),
    )
      ..autopilot = Autopilot(const AutopilotParams(releaseAngle: 0.35, regrabDelay: 0.15, minFallSpeed: -2))
      ..addListener(_onDemo);
    _game = FloppyGame(_demo!, dim: 0.2);
    services.audio.startMusic();
  }

  void _onDemo() {
    final d = _demo!;
    if (d.phase == _lastPhase) return;
    _lastPhase = d.phase;
    if (d.phase == GamePhase.won || d.phase == GamePhase.failed) {
      Future<void>.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        d.autopilot = Autopilot(d.autopilot!.params);
        d.retry();
      });
    }
  }

  @override
  void dispose() {
    _wobble.dispose();
    _demo?.dispose();
    super.dispose();
  }

  Future<void> _open(Widget page) async {
    _demo!.setPaused(true);
    await Navigator.of(context).push(popRoute(page));
    if (!mounted) return;
    _demo!.skin = skinById(AppServices.of(context).progress.selectedSkin);
    _demo!.setPaused(false);
  }

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: IgnorePointer(child: GameWidget(game: _game!))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListenableBuilder(
                listenable: services.progress,
                builder: (context, _) => Column(
                  children: [
                    Row(
                      children: [
                        RoundButton(
                          icon: Icons.settings_rounded,
                          tooltip: 'Settings',
                          onPressed: () => _open(const SettingsScreen()),
                          color: AppColors.grey,
                          shade: AppColors.greyDark,
                          size: 22,
                        ),
                        const Spacer(),
                        _StarsBadge(stars: services.progress.totalStars, max: services.levels.length * 3),
                        const SizedBox(width: 8),
                        CoinBadge(coins: services.progress.coins),
                      ],
                    ),
                    const Spacer(flex: 2),
                    AnimatedBuilder(
                      animation: _wobble,
                      builder: (_, _) {
                        final t = _wobble.value * math.pi * 2;
                        return Column(
                          children: [
                            Transform.rotate(
                              angle: math.sin(t) * 0.06,
                              child: Text('FLOPPY', style: display(76, color: AppColors.orange)),
                            ),
                            Transform.translate(
                              offset: Offset(math.sin(t * 2) * 6, 0),
                              child: Transform.rotate(
                                angle: -math.sin(t + 1) * 0.05,
                                child: Text('SWING', style: display(76, color: AppColors.yellow)),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const Spacer(flex: 3),
                    ChunkyButton(
                      onPressed: () => _open(const LevelSelectScreen()),
                      label: 'PLAY',
                      icon: Icons.play_arrow_rounded,
                      fontSize: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 16),
                      color: AppColors.green,
                      shade: AppColors.greenDark,
                    ),
                    const SizedBox(height: 12),
                    ChunkyButton(
                      onPressed: () => _open(const ShopScreen()),
                      label: 'SKINS',
                      icon: Icons.checkroom_rounded,
                      fontSize: 26,
                      color: AppColors.pink,
                      shade: const Color(0xFFC02E63),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarsBadge extends StatelessWidget {
  const _StarsBadge({required this.stars, required this.max});
  final int stars;
  final int max;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: AppColors.ink, width: 3),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, color: AppColors.yellow, size: 24),
        const SizedBox(width: 4),
        Text('$stars/$max', style: display(20, color: AppColors.ink, shadow: false)),
      ],
    ),
  );
}
