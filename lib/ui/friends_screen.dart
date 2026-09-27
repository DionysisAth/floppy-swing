import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../app.dart';
import '../services/online_service.dart';
import 'game_screen.dart';
import 'online_ui.dart';
import 'theme.dart';
import 'widgets.dart';

/// Your friend code, adding friends by code, and the friends list. Friends
/// show up on friend leaderboards and as ghosts in your levels.
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _code = TextEditingController();
  List<Friend>? _friends;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_friends == null) _load();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final online = AppServices.of(context).online;
    if (!online.isOnline) return;
    final list = await onlineAction(context, online.friends);
    if (mounted && list != null) setState(() => _friends = list);
  }

  Future<void> _add() async {
    final code = _code.text.trim();
    if (code.isEmpty || _busy) return;
    setState(() => _busy = true);
    final services = AppServices.of(context);
    final friend = await onlineAction(context, () => services.online.addFriend(code));
    if (!mounted) return;
    setState(() => _busy = false);
    if (friend != null) {
      _code.clear();
      services.audio.play('ding.wav');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${friend.name} is now your friend!')));
      await _load();
    }
  }

  Future<void> _remove(Friend f) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${f.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await onlineAction(context, () => AppServices.of(context).online.removeFriend(f.id));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final online = AppServices.of(context).online;
    return Scaffold(
      backgroundColor: const Color(0xFFE4F7E9),
      body: ContentArea(
        child: ListenableBuilder(
          listenable: online,
          builder: (context, _) {
            if (online.isOnline && _friends == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _friends == null) _load();
              });
            }
            final profile = online.profile;
            return Column(
              children: [
                const ScreenHeader(title: 'FRIENDS', color: AppColors.greenDark),
                Expanded(
                  child: !online.isOnline || profile == null
                      ? const OfflineNotice()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          children: [
                            Panel(
                              child: Column(
                                children: [
                                  Text('Your friend code', style: body(16, weight: 700)),
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: profile.friendCode));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Code copied')),
                                      );
                                    },
                                    child: Text(
                                      profile.friendCode,
                                      style: display(44, color: AppColors.greenDark, shadow: false).copyWith(letterSpacing: 4),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ChunkyButton(
                                    onPressed: () => SharePlus.instance.share(
                                      ShareParams(
                                        text: 'Race my ghost in Floppy Swing! Add me with code ${profile.friendCode}',
                                      ),
                                    ),
                                    label: 'Share code',
                                    icon: Icons.ios_share_rounded,
                                    color: AppColors.green,
                                    shade: AppColors.greenDark,
                                    fontSize: 20,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Friends race your best runs as ghosts and show up on friend leaderboards.',
                                    textAlign: TextAlign.center,
                                    style: body(13, color: AppColors.greyDark, weight: 600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Panel(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _code,
                                      textCapitalization: TextCapitalization.characters,
                                      maxLength: 6,
                                      decoration: const InputDecoration(
                                        hintText: "Friend's code",
                                        counterText: '',
                                        border: InputBorder.none,
                                      ),
                                      style: display(24, color: AppColors.ink, shadow: false),
                                      onSubmitted: (_) => _add(),
                                    ),
                                  ),
                                  ChunkyButton(
                                    onPressed: _busy ? null : _add,
                                    label: 'Add',
                                    icon: Icons.person_add_rounded,
                                    color: AppColors.blue,
                                    shade: AppColors.blueDark,
                                    fontSize: 18,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            _ChallengeCard(),
                            const SizedBox(height: 14),
                            if (_friends == null)
                              const Center(child: CircularProgressIndicator())
                            else if (_friends!.isEmpty)
                              Text(
                                'No friends yet. Share your code!',
                                textAlign: TextAlign.center,
                                style: body(17, weight: 700),
                              )
                            else
                              for (final f in _friends!)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.ink, width: 2),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.person_rounded, color: AppColors.greenDark),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text(f.name, style: body(18, weight: 800))),
                                      IconButton(
                                        tooltip: 'Remove',
                                        onPressed: () => _remove(f),
                                        icon: const Icon(Icons.close_rounded, color: AppColors.greyDark),
                                      ),
                                    ],
                                  ),
                                ),
                          ],
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

/// Plays the Endless course a friend challenged you on.
class _ChallengeCard extends StatefulWidget {
  @override
  State<_ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<_ChallengeCard> {
  final _seed = TextEditingController();

  @override
  void dispose() {
    _seed.dispose();
    super.dispose();
  }

  void _play() {
    final seed = int.tryParse(_seed.text.trim());
    if (seed == null) return;
    Navigator.of(context).push(popRoute(GameScreen.endless(seed: seed)));
  }

  @override
  Widget build(BuildContext context) => Panel(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _seed,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Challenge code', border: InputBorder.none),
            style: display(22, color: AppColors.ink, shadow: false),
            onSubmitted: (_) => _play(),
          ),
        ),
        ChunkyButton(
          onPressed: _play,
          label: 'Play',
          icon: Icons.all_inclusive_rounded,
          color: AppColors.blue,
          shade: AppColors.blueDark,
          fontSize: 18,
        ),
      ],
    ),
  );
}
