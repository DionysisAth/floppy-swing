import 'dart:async';
import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../app.dart';
import '../game/floppy_game.dart';
import '../game/game_controller.dart';
import '../game/simulation.dart';
import '../game/skins.dart';
import '../services/clip_exporter.dart';
import '../services/progress.dart';
import 'theme.dart';
import 'widgets.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.levelId});
  final int levelId;

  /// The most recently created controller, for widget tests.
  @visibleForTesting
  static GameController? debugLastController;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameController? _controller;
  FloppyGame? _game;
  late AppServices _services;

  GamePhase _lastPhase = GamePhase.ready;
  int _lastAttempt = 0;
  bool _showWin = false;
  LevelReward? _reward;
  bool _doubled = false;
  bool _exporting = false;
  double _exportProgress = 0;
  final _shareKey = GlobalKey();

  GameController get c => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    _services = AppServices.of(context);
    final level = _services.levelById(widget.levelId)!;
    _controller = GameController(
      level: level,
      cfg: _services.physics,
      skin: skinById(_services.progress.selectedSkin),
      feedback: _services.audio,
    )..addListener(_onControllerChanged);
    _game = FloppyGame(_controller!);
    GameScreen.debugLastController = _controller;
    _lastAttempt = c.attempts;
    _services.analytics.levelStart(level.id, c.attempts);
    _services.audio.startMusic();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    final phase = c.phase;
    if (c.attempts != _lastAttempt) {
      _lastAttempt = c.attempts;
      _services.analytics.levelStart(c.level.id, c.attempts);
    }
    if (phase != _lastPhase) {
      if (phase == GamePhase.dying) {
        final p = c.sim.deathPoint;
        _services.analytics.levelFail(c.level.id, c.sim.deathCause?.name ?? '?', p?.x ?? 0, c.sim.runTime);
      }
      if (phase == GamePhase.won && c.result != null) {
        final r = c.result!;
        _reward = _services.progress.recordWin(c.level.id, r);
        _doubled = false;
        _services.analytics.levelComplete(c.level.id, r.time, r.starCount, c.attempts);
        Future<void>.delayed(const Duration(milliseconds: 900), () {
          if (mounted && c.phase == GamePhase.won) setState(() => _showWin = true);
        });
      }
      if (phase != GamePhase.won) _showWin = false;
      _lastPhase = phase;
    }
    if (mounted) setState(() {});
  }

  // --------------------------------------------------------------- actions

  Future<void> _share() async {
    if (_exporting) return;
    setState(() {
      _exporting = true;
      _exportProgress = 0;
    });
    c.setPaused(true);
    final box = _shareKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    try {
      await ClipExporter().exportAndShare(
        c,
        caption: clipCaption(c),
        shareOrigin: origin,
        onProgress: (p) {
          if (mounted) setState(() => _exportProgress = p);
        },
      );
      _services.analytics.clipShared(c.phase == GamePhase.won ? 'win' : 'fail');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not make the clip: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
        c.setPaused(false);
      }
    }
  }

  Future<void> _reviveWithAd() async {
    c.setPaused(true);
    final ok = await _services.ads.showRewarded();
    if (!mounted) return;
    c.setPaused(false);
    if (ok) {
      _services.analytics.adRewarded('revive');
      c.revive();
    }
  }

  void _reviveWithCoins() {
    if (_services.progress.spend(_services.economy.reviveCost)) c.revive();
  }

  Future<void> _doubleCoins() async {
    final reward = _reward;
    if (reward == null || _doubled) return;
    final ok = await _services.ads.showRewarded();
    if (!mounted || !ok) return;
    _services.analytics.adRewarded('double_coins');
    _services.progress.addCoins(reward.total);
    setState(() => _doubled = true);
  }

  void _next() {
    final next = _services.levelById(widget.levelId + 1);
    if (next == null) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(popRoute(GameScreen(levelId: next.id)));
    }
  }

  // ----------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final phase = c.phase;
    return PopScope(
      canPop: c.paused || phase == GamePhase.won || phase == GamePhase.failed,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) c.setPaused(true);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF7CC8FF),
        body: Stack(
          children: [
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (_) => c.pointerDown(),
                onPointerUp: (_) => c.pointerUp(),
                onPointerCancel: (_) => c.pointerUp(),
                child: GameWidget(game: _game!),
              ),
            ),
            _Hud(controller: c, onPause: () => c.setPaused(true)),
            if (phase == GamePhase.ready && c.sim.startedAt == null && !c.paused)
              _HintBanner(text: c.revived ? 'Revived! Hold to swing.' : (c.level.hint ?? 'Hold anywhere to swing!')),
            if (phase == GamePhase.replay) const _ReplayBadge(),
            if (phase == GamePhase.replay || phase == GamePhase.failed) _failPanel(),
            if (phase == GamePhase.won && _showWin) _winPanel(),
            if (c.paused && !_exporting) _pausePanel(),
            if (_exporting) _ExportOverlay(progress: _exportProgress),
          ],
        ),
      ),
    );
  }

  static const _failLines = {
    DeathCause.spikes: ['Pointy end first.', 'That\'s gonna leave a mark.', 'Spike: 1, You: 0'],
    DeathCause.saw: ['Sliced and diced!', 'Saw that coming?', 'Bzzzzt!'],
    DeathCause.pit: ['Gravity wins again.', 'Down you go!', 'The floor is spiky.'],
    DeathCause.stuck: ['Nap time?', 'Stuck like glue.', 'Taking a breather?'],
  };

  Widget _failPanel() {
    final cause = c.sim.deathCause ?? DeathCause.pit;
    final lines = _failLines[cause]!;
    final line = lines[c.attempts % lines.length];
    final ads = _services.ads;
    final progress = _services.progress;
    final cost = _services.economy.reviveCost;
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: SafeArea(
        top: false,
        child: AnimatedOpacity(
          opacity: c.phase == GamePhase.failed ? 1 : 0.85,
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text lets taps through: tapping anywhere retries.
              IgnorePointer(
                child: Column(
                  children: [
                    Text(line, textAlign: TextAlign.center, style: display(34)),
                    const SizedBox(height: 6),
                    _Pulse(child: Text('Tap anywhere to retry', style: display(22, color: AppColors.yellow))),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  KeyedSubtree(
                    key: _shareKey,
                    child: ChunkyButton(
                      onPressed: _share,
                      icon: Icons.ios_share_rounded,
                      label: 'Share fail',
                      color: AppColors.pink,
                      shade: const Color(0xFFC02E63),
                      fontSize: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                  ),
                  if (c.canRevive) ...[
                    ListenableBuilder(
                      listenable: ads,
                      builder: (_, _) => ChunkyButton(
                        onPressed: ads.rewardedReady ? _reviveWithAd : null,
                        icon: Icons.play_circle_fill_rounded,
                        label: 'Revive',
                        color: AppColors.green,
                        shade: AppColors.greenDark,
                        fontSize: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                    ChunkyButton(
                      onPressed: progress.coins >= cost ? _reviveWithCoins : null,
                      color: AppColors.yellow,
                      shade: AppColors.yellowDark,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Revive ', style: display(20)),
                          const CoinIcon(size: 20),
                          Text(' $cost', style: display(20)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _winPanel() {
    final r = c.result!;
    final reward = _reward;
    final rec = _services.progress.record(c.level.id);
    final hasNext = _services.levelById(widget.levelId + 1) != null;
    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.scrim,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Panel(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(hasNext ? 'LEVEL CLEAR!' : 'WORLD CLEAR!', style: display(40, color: AppColors.orange)),
                    const SizedBox(height: 8),
                    _StarReveal(mask: r.starMask),
                    const SizedBox(height: 10),
                    _statRow(Icons.timer_rounded, 'Time',
                        '${r.time.toStringAsFixed(2)}s', r.timeStar ? AppColors.greenDark : AppColors.ink,
                        sub: 'target ${c.level.targetTime.toStringAsFixed(1)}s'),
                    _statRow(Icons.toll_rounded, 'Coins', '${r.coins}/${r.totalCoins}',
                        r.coinStar ? AppColors.greenDark : AppColors.ink),
                    if (r.style > 0) _statRow(Icons.auto_awesome_rounded, 'Style', '${r.style}', AppColors.ink),
                    if (rec.bestTime != null)
                      _statRow(Icons.emoji_events_rounded, 'Best', '${rec.bestTime!.toStringAsFixed(2)}s', AppColors.ink),
                    const Divider(height: 22, thickness: 2),
                    if (reward != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CoinIcon(size: 28),
                          const SizedBox(width: 8),
                          Text('+${reward.total * (_doubled ? 2 : 1)}', style: display(34, color: AppColors.yellowDark)),
                          if (reward.newStars > 0) ...[
                            const SizedBox(width: 10),
                            Text('(+${reward.newStars} ${reward.newStars == 1 ? 'star' : 'stars'})', style: body(16, weight: 600)),
                          ],
                        ],
                      ),
                    const SizedBox(height: 14),
                    if (reward != null && !_doubled)
                      ListenableBuilder(
                        listenable: _services.ads,
                        builder: (_, _) => _services.ads.rewardedReady
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ChunkyButton(
                                  onPressed: _doubleCoins,
                                  icon: Icons.play_circle_fill_rounded,
                                  label: 'Double coins',
                                  color: AppColors.green,
                                  shade: AppColors.greenDark,
                                  fontSize: 22,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RoundButton(icon: Icons.replay_rounded, tooltip: 'Retry', onPressed: c.retry,
                            color: AppColors.blue, shade: AppColors.blueDark),
                        const SizedBox(width: 10),
                        KeyedSubtree(
                          key: _shareKey,
                          child: RoundButton(icon: Icons.ios_share_rounded, tooltip: 'Share', onPressed: _share,
                              color: AppColors.pink, shade: const Color(0xFFC02E63)),
                        ),
                        const SizedBox(width: 10),
                        ChunkyButton(onPressed: _next, label: hasNext ? 'Next' : 'Levels', icon: Icons.arrow_forward_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value, Color color, {String? sub}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Icon(icon, color: AppColors.greyDark, size: 22),
        const SizedBox(width: 8),
        Text(label, style: body(18, weight: 600)),
        if (sub != null) ...[
          const SizedBox(width: 6),
          Text(sub, style: body(13, color: AppColors.greyDark)),
        ],
        const Spacer(),
        Text(value, style: display(22, color: color, shadow: false)),
      ],
    ),
  );

  Widget _pausePanel() {
    final progress = _services.progress;
    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.scrim,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Panel(
              child: ListenableBuilder(
                listenable: progress,
                builder: (_, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('PAUSED', textAlign: TextAlign.center, style: display(40, color: AppColors.orange)),
                    Text(c.level.name, textAlign: TextAlign.center, style: body(18, weight: 600)),
                    const SizedBox(height: 16),
                    ChunkyButton(onPressed: () => c.setPaused(false), label: 'Resume', icon: Icons.play_arrow_rounded, expand: true),
                    const SizedBox(height: 6),
                    ChunkyButton(
                      onPressed: () {
                        c.setPaused(false);
                        c.retry();
                      },
                      label: 'Restart',
                      icon: Icons.replay_rounded,
                      color: AppColors.blue,
                      shade: AppColors.blueDark,
                      expand: true,
                    ),
                    const SizedBox(height: 6),
                    ChunkyButton(
                      onPressed: () => Navigator.of(context).pop(),
                      label: 'Levels',
                      icon: Icons.grid_view_rounded,
                      color: AppColors.grey,
                      shade: AppColors.greyDark,
                      expand: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RoundButton(
                          icon: progress.musicVolume > 0 ? Icons.music_note_rounded : Icons.music_off_rounded,
                          tooltip: 'Music',
                          onPressed: () {
                            progress.setMusicVolume(progress.musicVolume > 0 ? 0 : 0.6);
                            _services.audio.startMusic();
                          },
                        ),
                        const SizedBox(width: 12),
                        RoundButton(
                          icon: progress.sfxVolume > 0 ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                          tooltip: 'Sound effects',
                          onPressed: () => progress.setSfxVolume(progress.sfxVolume > 0 ? 0 : 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Top bar: pause, level name, clock, coins and style score. Rebuilds every
/// frame with its own ticker so the rest of the screen doesn't.
class _Hud extends StatefulWidget {
  const _Hud({required this.controller, required this.onPause});
  final GameController controller;
  final VoidCallback onPause;

  @override
  State<_Hud> createState() => _HudState();
}

class _HudState extends State<_Hud> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => setState(() {}))..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final sim = c.sim;
    final time = sim.runTime;
    final beating = time <= c.level.targetTime;
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoundButton(icon: Icons.pause_rounded, tooltip: 'Pause', onPressed: widget.onPause, size: 22),
              Expanded(
                child: IgnorePointer(
                  child: Column(
                    children: [
                      Text('${c.level.id}. ${c.level.name}', style: display(18)),
                      Text(
                        time.toStringAsFixed(2),
                        style: display(34, color: beating ? Colors.white : const Color(0xFFFFB0A8)),
                      ),
                      if (sim.styleScore > 0)
                        Text('STYLE ${sim.styleScore.round()}', style: display(16, color: AppColors.yellow)),
                    ],
                  ),
                ),
              ),
              IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(6, 5, 12, 5),
                  decoration: BoxDecoration(
                    color: const Color(0x662B1D14),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CoinIcon(size: 22),
                      const SizedBox(width: 6),
                      Text('${sim.coinCount}/${c.level.coins.length}', style: display(20)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HintBanner extends StatelessWidget {
  const _HintBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Positioned(
    left: 24,
    right: 24,
    bottom: 60,
    child: IgnorePointer(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Pulse(child: Icon(Icons.touch_app_rounded, size: 64, color: Colors.white,
                shadows: [Shadow(color: AppColors.ink, offset: Offset(0, 3))])),
            const SizedBox(height: 6),
            Text(text, textAlign: TextAlign.center, style: display(26)),
          ],
        ),
      ),
    ),
  );
}

class _ReplayBadge extends StatelessWidget {
  const _ReplayBadge();

  @override
  Widget build(BuildContext context) => Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: IgnorePointer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 110),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: AppColors.pink, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.ink, width: 3)),
              child: Text('SLOW-MO REPLAY', style: display(18)),
            ),
          ),
        ),
      ),
    ),
  );
}

class _ExportOverlay extends StatelessWidget {
  const _ExportOverlay({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: AppColors.scrim,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Panel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Making your clip…', style: display(26, color: AppColors.orange)),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(value: progress, minHeight: 14,
                      color: AppColors.orange, backgroundColor: const Color(0x22FF8A3D)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Gently pulsing child.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});
  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: Tween(begin: 0.92, end: 1.06).animate(CurvedAnimation(parent: _a, curve: Curves.easeInOut)),
    child: widget.child,
  );
}

/// Stars popping in one after another.
class _StarReveal extends StatefulWidget {
  const _StarReveal({required this.mask});
  final int mask;

  @override
  State<_StarReveal> createState() => _StarRevealState();
}

class _StarRevealState extends State<_StarReveal> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
    ..forward();
  final List<bool> _played = [false, false, false];

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (context, _) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++) _star(context, i),
        ],
      );
    },
  );

  Widget _star(BuildContext context, int i) {
    final earned = (widget.mask >> i) & 1 == 1;
    final start = i * 0.28;
    final t = ((_a.value - start) / 0.3).clamp(0.0, 1.0);
    if (earned && t > 0 && !_played[i]) {
      _played[i] = true;
      scheduleMicrotask(() => AppServices.maybeOf(context)?.audio.play('ding.wav', volume: 0.6 + i * 0.2));
    }
    final scale = earned ? Curves.elasticOut.transform(t) : 1.0;
    const labels = ['Finish', 'Time', 'Coins'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Transform.rotate(
            angle: (i - 1) * 0.2,
            child: Transform.scale(
              scale: math.max(0.001, scale),
              child: Icon(
                Icons.star_rounded,
                size: i == 1 ? 72 : 58,
                color: earned ? AppColors.yellow : const Color(0x33000000),
                shadows: earned ? const [Shadow(color: AppColors.ink, offset: Offset(0, 3))] : null,
              ),
            ),
          ),
          Text(labels[i], style: body(13, weight: 600, color: AppColors.greyDark)),
        ],
      ),
    );
  }
}
