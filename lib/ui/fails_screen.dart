import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../app.dart';
import '../services/online_service.dart';
import 'online_ui.dart';
import 'theme.dart';
import 'widgets.dart';

const _red = Color(0xFFE63946);
const _redDark = Color(0xFFA11D2A);

/// Fail of the Week: last week's winning clip, and this week's entries to
/// watch and vote for. Clips are sent from the fail screen.
class FailsScreen extends StatefulWidget {
  const FailsScreen({super.key});

  @override
  State<FailsScreen> createState() => _FailsScreenState();
}

class _FailsScreenState extends State<FailsScreen> {
  Future<FailsPage>? _load;

  void _reload() {
    final load = AppServices.of(context).online.fails();
    setState(() {
      _load = load;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final online = AppServices.of(context).online;
    if (_load == null && online.enabled) _load = online.fails();
  }

  Future<void> _vote(FailClip clip) async {
    final services = AppServices.of(context);
    final ok = await onlineAction(context, () async {
      await services.online.vote(clip.id);
      return true;
    });
    if (ok == true) {
      services.audio.play('pop.wav');
      _reload();
    }
  }

  Future<void> _report(FailClip clip) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report this clip?'),
        content: const Text('Clips reported by several players are hidden until a moderator checks them.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Report')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await onlineAction(context, () => AppServices.of(context).online.report(clip.id));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks, we will take a look.')));
  }

  @override
  Widget build(BuildContext context) {
    final online = AppServices.of(context).online;
    return Scaffold(
      backgroundColor: const Color(0xFFFFE4E4),
      body: ContentArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'FAIL OF THE WEEK', color: _red),
            Expanded(
              child: !online.enabled
                  ? const OfflineNotice()
                  : FutureBuilder<FailsPage>(
                      future: _load,
                      builder: (context, snap) {
                        if (snap.hasError) return const OfflineNotice();
                        final page = snap.data;
                        if (page == null) return const Center(child: CircularProgressIndicator());
                        return RefreshIndicator(
                          onRefresh: () async => _reload(),
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            children: [
                              if (page.featured case final f?) ...[
                                Text("LAST WEEK'S WINNER", style: display(18, color: _redDark, shadow: false)),
                                const SizedBox(height: 6),
                                Panel(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      AspectRatio(aspectRatio: 9 / 16, child: ClipPlayer(url: f.url, autoplay: true)),
                                      const SizedBox(height: 8),
                                      Text(f.caption.isEmpty ? f.name : '"${f.caption}"', style: body(17, weight: 800)),
                                      Text('by ${f.name}  ·  ${f.votes} votes', style: body(14, weight: 600, color: AppColors.greyDark)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              Row(
                                children: [
                                  Expanded(child: Text('THIS WEEK', style: display(18, color: _redDark, shadow: false))),
                                  Text(
                                    '${page.daysLeft} ${page.daysLeft == 1 ? 'day' : 'days'} left to vote',
                                    style: body(14, weight: 700),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (page.entries.isEmpty)
                                Panel(
                                  child: Text(
                                    'No clips yet this week. After a spectacular fail, tap "Send to Fail of the Week"!',
                                    textAlign: TextAlign.center,
                                    style: body(16, weight: 700),
                                  ),
                                ),
                              for (final clip in page.entries)
                                _EntryRow(
                                  clip: clip,
                                  canVote: online.isOnline && !clip.mine && !clip.voted,
                                  onVote: () => _vote(clip),
                                  onReport: () => _report(clip),
                                ),
                              const SizedBox(height: 10),
                              Text(
                                'The most voted fail each week wins the Golden Flop skin and 50 gems.',
                                textAlign: TextAlign.center,
                                style: body(13, weight: 600, color: AppColors.greyDark),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.clip, required this.canVote, required this.onVote, required this.onReport});
  final FailClip clip;
  final bool canVote;
  final VoidCallback onVote;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: clip.mine ? const Color(0xFFFFF4C9) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.ink, width: 2),
    ),
    child: Row(
      children: [
        RoundButton(
          icon: Icons.play_arrow_rounded,
          tooltip: 'Watch',
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: Colors.black,
              insetPadding: const EdgeInsets.all(16),
              child: AspectRatio(aspectRatio: 9 / 16, child: ClipPlayer(url: clip.url, autoplay: true)),
            ),
          ),
          color: _red,
          shade: _redDark,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clip.caption.isEmpty ? 'Untitled fail' : clip.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: body(16, weight: 800),
              ),
              Text(clip.mine ? 'Your clip' : 'by ${clip.name}', style: body(13, weight: 600, color: AppColors.greyDark)),
            ],
          ),
        ),
        Column(
          children: [
            IconButton(
              tooltip: clip.voted ? 'Voted' : 'Vote',
              onPressed: canVote ? onVote : null,
              icon: Icon(
                clip.voted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: clip.voted ? _red : (canVote ? _redDark : AppColors.grey),
              ),
            ),
            Text('${clip.votes}', style: body(13, weight: 800)),
          ],
        ),
        if (!clip.mine)
          IconButton(
            tooltip: 'Report',
            onPressed: onReport,
            icon: const Icon(Icons.flag_outlined, color: AppColors.greyDark, size: 20),
          ),
      ],
    ),
  );
}

/// Streams and loops a clip from the server.
class ClipPlayer extends StatefulWidget {
  const ClipPlayer({super.key, required this.url, this.autoplay = false});
  final String url;
  final bool autoplay;

  @override
  State<ClipPlayer> createState() => _ClipPlayerState();
}

class _ClipPlayerState extends State<ClipPlayer> {
  VideoPlayerController? _video;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final v = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _video = v;
    v.initialize().then((_) {
      if (!mounted) return;
      v.setLooping(true);
      if (widget.autoplay) v.play();
      setState(() {});
    }).catchError((Object _) {
      if (mounted) setState(() => _failed = true);
    });
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = _video;
    if (_failed) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 48)),
      );
    }
    if (v == null || !v.value.isInitialized) {
      return const ColoredBox(color: Colors.black, child: Center(child: CircularProgressIndicator()));
    }
    return GestureDetector(
      onTap: () => setState(() => v.value.isPlaying ? v.pause() : v.play()),
      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: VideoPlayer(v)),
    );
  }
}
