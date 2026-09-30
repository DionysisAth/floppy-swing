import 'dart:async';
import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../services/links.dart';
import '../game/autopilot.dart';
import '../game/floppy_game.dart';
import '../game/game_controller.dart';
import '../game/season.dart';
import '../game/skins.dart';
import '../services/games_service.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';
import 'login_reward_dialog.dart';
import 'season_screen.dart';
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
  StreamSubscription<int>? _links;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_demo != null) return;
    final services = AppServices.of(context);
    // Attract mode: the autopilot plays level 1 behind the menu, silently.
    _demo =
        GameController(
            level: services.levels.first,
            cfg: services.physics,
            skin: skinById(services.progress.selectedSkin),
            look: services.progress.loadout,
          )
          ..autopilot = Autopilot(const AutopilotParams(releaseAngle: 0.35, regrabDelay: 0.15, minFallSpeed: -2))
          ..addListener(_onDemo);
    _game = FloppyGame(_demo!, dim: 0.2);
    // A challenge link opens the friend's Endless course from anywhere.
    _links = services.challenges?.listen((seed) {
      if (!mounted) return;
      Navigator.of(context).popUntil((r) => r.isFirst);
      _open(GameScreen.endless(seed: seed));
    });
    services.audio.startMusic();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) await showLoginReward(context);
    });
  }

  /// Leaderboards and achievements live in the Play Games / Game Center UI.
  Future<void> _openGames(Future<bool> Function(GamesService games) open) async {
    final games = AppServices.of(context).games;
    final messenger = ScaffoldMessenger.of(context);
    if (!await open(games)) {
      messenger.showSnackBar(SnackBar(content: Text("Couldn't sign in to ${games.serviceName}.")));
    }
  }

  /// Plays the Endless course a friend shared ("challenge code").
  Future<void> _enterChallenge() async {
    final seed = await showDialog<int>(context: context, builder: (_) => const ChallengeCodeDialog());
    if (seed != null && mounted) await _open(GameScreen.endless(seed: seed));
  }

  Widget _social(IconData icon, String tooltip, Color color, Color shade, VoidCallback onPressed) =>
      RoundButton(icon: icon, tooltip: tooltip, onPressed: onPressed, color: color, shade: shade, size: 22);

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
    _links?.cancel();
    _wobble.dispose();
    _demo?.dispose();
    super.dispose();
  }

  Future<void> _open(Widget page) async {
    _demo!.setPaused(true);
    await Navigator.of(context).push(popRoute(page));
    if (!mounted) return;
    _demo!.skin = skinById(AppServices.of(context).progress.selectedSkin);
    _demo!.look = AppServices.of(context).progress.loadout;
    _demo!.setPaused(false);
  }

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(child: GameWidget(game: _game!)),
          ),
          ContentArea(
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
                        const SizedBox(width: 6),
                        Flexible(
                          child: FittedBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CoinBadge(coins: services.progress.coins),
                                const SizedBox(height: 4),
                                GemBadge(gems: services.progress.gems),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (services.games.available) ...[
                          _social(
                            Icons.emoji_events_rounded,
                            'Leaderboards',
                            AppColors.orange,
                            AppColors.orangeDark,
                            () => _openGames((g) => g.showLeaderboard()),
                          ),
                          const SizedBox(width: 8),
                          _social(
                            Icons.military_tech_rounded,
                            'Achievements',
                            AppColors.blue,
                            AppColors.blueDark,
                            () => _openGames((g) => g.showAchievements()),
                          ),
                          const SizedBox(width: 8),
                        ],
                        _social(
                          Icons.sports_kabaddi_rounded,
                          'Challenge code',
                          AppColors.green,
                          AppColors.greenDark,
                          _enterChallenge,
                        ),
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
                    Row(
                      children: [
                        Expanded(child: _dailyButton(services)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ModeButton(
                            onPressed: () =>
                                _open(GameScreen.endless(seed: DateTime.now().microsecondsSinceEpoch & 0x7fffffff)),
                            icon: Icons.all_inclusive_rounded,
                            label: 'ENDLESS',
                            sub: services.progress.endlessBestDistance > 0
                                ? 'Best ${services.progress.endlessBestDistance} m'
                                : 'How far can you go?',
                            color: AppColors.blue,
                            shade: AppColors.blueDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _ModeButton(
                            onPressed: () => _open(const ShopScreen()),
                            icon: Icons.checkroom_rounded,
                            label: 'SHOP',
                            sub: 'Skins, ropes & more',
                            color: AppColors.pink,
                            shade: const Color(0xFFC02E63),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ModeButton(
                            onPressed: () => _open(const SeasonScreen()),
                            icon: Icons.workspace_premium_rounded,
                            label: 'PASS',
                            sub: 'Tier ${services.progress.seasonTier}/${Season.tiers}',
                            color: const Color(0xFF8F6BC7),
                            shade: const Color(0xFF5F3F99),
                            badge: services.progress.seasonRewardsReady > 0,
                          ),
                        ),
                      ],
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

extension on _MenuScreenState {
  Widget _dailyButton(AppServices services) {
    final progress = services.progress;
    final day = progress.today;
    final done = progress.dailyRecord(day).completed;
    final streak = progress.currentDailyStreak;
    return _ModeButton(
      onPressed: services.dailies.isEmpty ? null : () => _open(GameScreen.daily(day: day)),
      icon: Icons.today_rounded,
      label: 'DAILY',
      sub: done ? 'Done! 🔥 $streak' : (streak > 0 ? 'Keep your 🔥 $streak' : 'New challenge!'),
      color: AppColors.orange,
      shade: AppColors.orangeDark,
      badge: !done,
    );
  }
}

/// A mode button with a caption underneath (best score, streak...).
class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.shade,
    this.badge = false,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final Color shade;
  final bool badge;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    fit: StackFit.passthrough,
    children: [
      ChunkyButton(
        onPressed: onPressed,
        color: color,
        shade: shade,
        expand: true,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          children: [
            FittedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 6),
                  Text(label, style: display(24)),
                ],
              ),
            ),
            FittedBox(
              child: Text(sub, style: body(14, weight: 700, color: Colors.white)),
            ),
          ],
        ),
      ),
      if (badge)
        Positioned(
          right: -4,
          top: -6,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.pink,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 3),
            ),
          ),
        ),
    ],
  );
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

/// Asks for an Endless challenge code (the course seed a friend shared).
class ChallengeCodeDialog extends StatefulWidget {
  const ChallengeCodeDialog({super.key});

  @override
  State<ChallengeCodeDialog> createState() => _ChallengeCodeDialogState();
}

class _ChallengeCodeDialogState extends State<ChallengeCodeDialog> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _play() {
    final seed = challengeSeedFromText(_code.text);
    if (seed != null) Navigator.pop(context, seed);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Challenge code'),
    content: TextField(
      controller: _code,
      autofocus: true,
      decoration: const InputDecoration(hintText: 'Code or link from a friend'),
      style: display(24, color: AppColors.ink, shadow: false),
      onSubmitted: (_) => _play(),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      TextButton(onPressed: _play, child: const Text('Play Endless')),
    ],
  );
}
