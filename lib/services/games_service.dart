import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:games_services/games_services.dart' as gs;

import '../game/worlds.dart';
import 'games_ids.dart';
import 'progress.dart';

enum Board { daily, endless }

/// The native game services: Google Play Games on Android, Game Center on
/// iOS. Everything is hosted by Google/Apple for free:
///
/// - sign-in (automatic where the platform allows it);
/// - Daily Challenge and Endless leaderboards, shown in the platform's own UI
///   (which includes friends and daily/weekly/all-time tabs);
/// - achievements ([earnedAchievements]);
/// - cloud save: the progress JSON is stored as a saved game and merged in
///   on sign-in ([ProgressStore.mergeFrom]), so a new phone picks up where
///   the old one left off.
///
/// The game never waits on any of it, and every failure is swallowed: it's
/// all a bonus on top of the offline game.
class GamesService extends ChangeNotifier with WidgetsBindingObserver {
  GamesService(this.progress, {GamesBackend? backend, this.saveDelay = const Duration(seconds: 10)})
    : backend = backend ?? GamesBackend.forPlatform();

  /// Switched off (tests, desktop, or a build without ids).
  GamesService.disabled(this.progress) : backend = const NoGamesBackend(), saveDelay = Duration.zero;

  final ProgressStore progress;
  final GamesBackend backend;
  final Duration saveDelay;

  bool _signedIn = false;
  bool _started = false;
  bool _applying = false;
  String? _playerName;
  Timer? _saveTimer;
  final Set<String> _reported = {};
  Future<void> _work = Future.value();

  /// Configured on this platform (otherwise the UI hides its buttons).
  bool get available => backend.available;
  bool get signedIn => _signedIn;
  String? get playerName => _playerName;

  /// "Google Play Games" or "Game Center".
  String get serviceName => backend.serviceName;

  /// Signs in quietly and starts syncing. Safe to call when unavailable.
  Future<void> start() async {
    if (!available || _started) return;
    _started = true;
    progress.addListener(_onProgress);
    WidgetsBinding.instance.addObserver(this);
    await signIn();
  }

  /// Signs in (the platform may show its own sign-in UI). True on success.
  Future<bool> signIn() async {
    if (!available) return false;
    if (_signedIn) return true;
    try {
      final name = await backend.signIn();
      if (name == null) return false;
      _signedIn = true;
      _playerName = name;
      notifyListeners();
      await _queue(_afterSignIn);
      return true;
    } catch (e) {
      debugPrint('Games sign-in: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    if (_started) {
      progress.removeListener(_onProgress);
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  Future<void> _afterSignIn() async {
    await _pull();
    // Scores and achievements earned while signed out (or on older builds).
    if (progress.endlessBest > 0) await _submit(Board.endless, progress.endlessBest);
    final today = progress.dailyRecord(progress.today).bestTime;
    if (today != null) await _submit(Board.daily, (today * 1000).round());
    await _reportAchievements();
    await _push();
  }

  // ---------------------------------------------------------- leaderboards

  /// Posts a Daily Challenge time. Returns today's rank when the platform
  /// tells us.
  Future<int?> submitDaily(double seconds) => _submitAndRank(Board.daily, (seconds * 1000).round());

  /// Posts an Endless score. Returns the all-time rank when known.
  Future<int?> submitEndless(int score) => _submitAndRank(Board.endless, score);

  Future<int?> _submitAndRank(Board board, int value) async {
    if (!_signedIn) return null;
    await _submit(board, value);
    try {
      return await backend.rank(board);
    } catch (e) {
      debugPrint('Games rank: $e');
      return null;
    }
  }

  Future<void> _submit(Board board, int value) async {
    try {
      await backend.submit(board, value);
    } catch (e) {
      debugPrint('Games submit: $e');
    }
  }

  /// Opens the platform leaderboard UI ([board], or the list of all). Signs
  /// in first if needed; false if that didn't work.
  Future<bool> showLeaderboard([Board? board]) async {
    if (!await signIn()) return false;
    try {
      await backend.showLeaderboard(board);
      return true;
    } catch (e) {
      debugPrint('Games leaderboard: $e');
      return false;
    }
  }

  Future<bool> showAchievements() async {
    if (!await signIn()) return false;
    try {
      await _reportAchievements();
      await backend.showAchievements();
      return true;
    } catch (e) {
      debugPrint('Games achievements: $e');
      return false;
    }
  }

  // ---------------------------------------------------------- achievements

  Future<void> _reportAchievements() async {
    if (!_signedIn) return;
    for (final key in earnedAchievements(progress).difference(_reported)) {
      try {
        await backend.unlock(key);
        _reported.add(key);
      } catch (e) {
        debugPrint('Games unlock $key: $e');
      }
    }
  }

  // ------------------------------------------------------------ cloud save

  void _onProgress() {
    if (_applying || !_signedIn) return;
    _saveTimer?.cancel();
    _saveTimer = Timer(saveDelay, () => _queue(_push));
    if (earnedAchievements(progress).difference(_reported).isNotEmpty) _queue(_reportAchievements);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _signedIn) {
      _saveTimer?.cancel();
      _queue(_push);
    }
  }

  Future<void> _pull() async {
    try {
      final data = await backend.load();
      if (data == null || data.isEmpty) return;
      _applying = true;
      try {
        progress.mergeFrom(jsonDecode(data) as Map<String, dynamic>);
      } finally {
        _applying = false;
      }
    } catch (e) {
      debugPrint('Games load: $e');
    }
  }

  Future<void> _push() async {
    if (!_signedIn) return;
    try {
      await backend.save(jsonEncode(progress.toJson()));
    } catch (e) {
      debugPrint('Games save: $e');
    }
  }

  Future<void> _queue(Future<void> Function() job) {
    _work = _work.then((_) => job()).catchError((Object e) => debugPrint('Games: $e'));
    return _work;
  }

  /// Waits for queued work (tests).
  @visibleForTesting
  Future<void> idle() => _work;
}

/// Achievement keys (see [achievementTexts]) the save has earned.
Set<String> earnedAchievements(ProgressStore p) {
  bool cleared(int id) => (p.levels[id]?.stars ?? 0) & 1 == 1;
  final stars = p.totalStars;
  return {
    if (cleared(1)) 'first_swing',
    for (var w = 1; w <= 5; w++)
      if (_worldCleared(w, cleared)) 'world_$w',
    if (stars >= 150) 'stars_150',
    if (stars >= ProgressStore.goldenStars) 'stars_300',
    if (p.endlessBestDistance >= 500) 'endless_500',
    if (p.endlessBestDistance >= 1500) 'endless_1500',
    if (p.lastDailyDay >= 0) 'daily_first',
    if (p.dailyStreak >= 7) 'daily_streak_7',
  };
}

bool _worldCleared(int w, bool Function(int) cleared) {
  final info = WorldInfo.byNumber(w);
  for (var id = info.firstLevel; id <= info.lastLevel; id++) {
    if (!cleared(id)) return false;
  }
  return true;
}

/// The platform calls, behind an interface so tests can fake them.
abstract class GamesBackend {
  const GamesBackend();

  factory GamesBackend.forPlatform() {
    if (kIsWeb) return const NoGamesBackend();
    if (Platform.isAndroid && playGamesIds.enabled) {
      return const PlatformGamesBackend(playGamesIds, 'Google Play Games');
    }
    if (Platform.isIOS && gameCenterIds.enabled) {
      return const PlatformGamesBackend(gameCenterIds, 'Game Center');
    }
    return const NoGamesBackend();
  }

  bool get available;
  String get serviceName;

  /// Player name, or null when sign-in didn't happen.
  Future<String?> signIn();

  /// [value]: milliseconds for [Board.daily], the score for [Board.endless].
  Future<void> submit(Board board, int value);
  Future<int?> rank(Board board);
  Future<void> showLeaderboard(Board? board);
  Future<void> unlock(String achievement);
  Future<void> showAchievements();
  Future<String?> load();
  Future<void> save(String data);
}

class NoGamesBackend extends GamesBackend {
  const NoGamesBackend();

  @override
  bool get available => false;
  @override
  String get serviceName => Platform.isIOS ? 'Game Center' : 'Google Play Games';
  @override
  Future<String?> signIn() async => null;
  @override
  Future<void> submit(Board board, int value) async {}
  @override
  Future<int?> rank(Board board) async => null;
  @override
  Future<void> showLeaderboard(Board? board) async {}
  @override
  Future<void> unlock(String achievement) async {}
  @override
  Future<void> showAchievements() async {}
  @override
  Future<String?> load() async => null;
  @override
  Future<void> save(String data) async {}
}

/// Talks to Play Games / Game Center through the `games_services` plugin.
class PlatformGamesBackend extends GamesBackend {
  const PlatformGamesBackend(this.ids, this.serviceName);

  final PlatformGamesIds ids;
  @override
  final String serviceName;

  static const _saveName = 'progress';

  bool get _android => Platform.isAndroid;

  @override
  bool get available => true;

  String _board(Board b) => switch (b) {
    Board.daily => ids.daily,
    Board.endless => ids.endless,
  };

  @override
  Future<String?> signIn() async {
    await gs.GamesServices.signIn();
    if (!await gs.GamesServices.isSignedIn) return null;
    return await gs.Player.getPlayerName() ?? '';
  }

  @override
  Future<void> submit(Board board, int value) async {
    final id = _board(board);
    if (id.isEmpty) return;
    // Game Center's elapsed-time format counts hundredths of a second.
    final v = board == Board.daily && !_android ? (value / 10).round() : value;
    await gs.Leaderboards.submitScore(
      score: gs.Score(androidLeaderboardID: id, iOSLeaderboardID: id, value: v),
    );
  }

  @override
  Future<int?> rank(Board board) async {
    final id = _board(board);
    if (id.isEmpty) return null;
    final s = await gs.Leaderboards.getPlayerScoreObject(
      androidLeaderboardID: id,
      iOSLeaderboardID: id,
      scope: gs.PlayerScope.global,
      timeScope: board == Board.daily ? gs.TimeScope.today : gs.TimeScope.allTime,
    );
    final rank = s?.rank;
    return rank != null && rank > 0 ? rank : null;
  }

  @override
  Future<void> showLeaderboard(Board? board) async {
    final id = board == null ? '' : _board(board);
    await gs.Leaderboards.showLeaderboards(
      androidLeaderboardID: id,
      iOSLeaderboardID: id,
      timeScope: board == Board.daily ? gs.TimeScope.today : gs.TimeScope.allTime,
    );
  }

  @override
  Future<void> unlock(String achievement) async {
    final id = ids.achievements[achievement] ?? '';
    if (id.isEmpty) return;
    await gs.Achievements.unlock(
      achievement: gs.Achievement(androidID: id, iOSID: id, percentComplete: 100),
    );
  }

  @override
  Future<void> showAchievements() => gs.Achievements.showAchievements();

  @override
  Future<String?> load() => gs.SaveGame.loadGame(name: _saveName);

  @override
  Future<void> save(String data) =>
      gs.SaveGame.saveGame(data: data, name: _saveName, description: 'Floppy Swing progress');
}
