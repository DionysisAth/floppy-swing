import 'package:flutter/material.dart';

import '../app.dart';
import '../services/online_service.dart';
import 'online_ui.dart';
import 'theme.dart';
import 'widgets.dart';

enum BoardKind { daily, endless }

/// Today's Daily Challenge times and Endless scores, for everyone or just
/// friends.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, this.initial = BoardKind.daily});
  final BoardKind initial;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late BoardKind _kind = widget.initial;
  bool _friends = false;
  Future<Leaderboard>? _load;

  String _board(AppServices s) =>
      _kind == BoardKind.daily ? OnlineService.dailyBoard(s.progress.today) : OnlineService.endlessBoard;

  void _reload() {
    final s = AppServices.of(context);
    final load = s.online.leaderboard(_board(s), friends: _friends);
    if (!mounted) return;
    setState(() {
      _load = load;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = AppServices.of(context);
    if (_load == null && s.online.isOnline) _load = s.online.leaderboard(_board(s), friends: _friends);
  }

  String _format(double v) => _kind == BoardKind.daily ? '${v.toStringAsFixed(2)}s' : '${v.round()}';

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1D6),
      body: ContentArea(
        child: ListenableBuilder(
          listenable: services.online,
          builder: (context, _) {
            if (services.online.isOnline && _load == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _load == null) _reload();
              });
            }
            return Column(
              children: [
                const ScreenHeader(title: 'LEADERBOARDS', color: AppColors.orange),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      for (final k in BoardKind.values) ...[
                        Expanded(
                          child: _Toggle(
                            label: k == BoardKind.daily ? "Today's Daily" : 'Endless',
                            selected: _kind == k,
                            onTap: () {
                              _kind = k;
                              _reload();
                            },
                          ),
                        ),
                        if (k == BoardKind.daily) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Chip(label: 'Everyone', selected: !_friends, onTap: () {
                        _friends = false;
                        _reload();
                      }),
                      const SizedBox(width: 8),
                      _Chip(label: 'Friends', selected: _friends, onTap: () {
                        _friends = true;
                        _reload();
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: !services.online.isOnline
                      ? const OfflineNotice()
                      : FutureBuilder<Leaderboard>(
                          future: _load,
                          builder: (context, snap) {
                            if (snap.hasError) {
                              return Center(child: Text('${snap.error}', style: body(16, weight: 600)));
                            }
                            final lb = snap.data;
                            if (lb == null) return const Center(child: CircularProgressIndicator());
                            if (lb.entries.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Text(
                                    _friends
                                        ? 'No friends on this board yet. Add some from the Friends screen!'
                                        : 'No scores yet. Be the first!',
                                    textAlign: TextAlign.center,
                                    style: body(17, weight: 700),
                                  ),
                                ),
                              );
                            }
                            return RefreshIndicator(
                              onRefresh: () async => _reload(),
                              child: ListView(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                children: [
                                  for (final e in lb.entries) _Row(entry: e, value: _format(e.value)),
                                  if (lb.myRank != null && !lb.entries.any((e) => e.me))
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: _Row(
                                        entry: BoardEntry(
                                          rank: lb.myRank!,
                                          name: services.online.profile?.name ?? 'You',
                                          value: lb.myValue!,
                                          me: true,
                                        ),
                                        value: _format(lb.myValue!),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${lb.total} ${lb.total == 1 ? 'player' : 'players'}',
                                    textAlign: TextAlign.center,
                                    style: body(14, color: AppColors.greyDark, weight: 600),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.entry, required this.value});
  final BoardEntry entry;
  final String value;

  @override
  Widget build(BuildContext context) {
    final medal = switch (entry.rank) {
      1 => const Color(0xFFFFC21A),
      2 => const Color(0xFFC3CCD5),
      3 => const Color(0xFFD9985B),
      _ => null,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: entry.me ? const Color(0xFFFFF4C9) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: entry.me ? AppColors.orange : AppColors.ink, width: entry.me ? 3 : 2),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: medal ?? const Color(0xFFF3EEE6), shape: BoxShape.circle),
            child: FittedBox(child: Text('${entry.rank}', style: display(18, color: AppColors.ink, shadow: false))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.me ? '${entry.name} (you)' : entry.name,
              overflow: TextOverflow.ellipsis,
              style: body(17, weight: 800),
            ),
          ),
          Text(value, style: display(20, color: AppColors.orange, shadow: false)),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChunkyButton(
    onPressed: onTap,
    expand: true,
    color: selected ? AppColors.orange : Colors.white,
    shade: selected ? AppColors.orangeDark : const Color(0xFFD8CFC2),
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Center(
      child: FittedBox(
        child: Text(label, style: display(18, color: selected ? Colors.white : AppColors.ink, shadow: selected)),
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: Text(label, style: body(15, weight: 800, color: selected ? Colors.white : AppColors.ink)),
    ),
  );
}
