import 'dart:convert';

import 'package:floppy_swing/game/game_controller.dart';
import 'package:floppy_swing/services/games_ids.dart';
import 'package:floppy_swing/services/games_service.dart';
import 'package:floppy_swing/services/progress.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

RunResult perfect() => const RunResult(time: 5, targetTime: 12, coins: 5, totalCoins: 5, style: 0, revived: false);

/// Records what the game asked Play Games / Game Center to do.
class FakeBackend extends GamesBackend {
  bool allowSignIn = true;
  String? cloud;
  final submitted = <(Board, int)>[];
  final unlocked = <String>[];
  final shown = <Board?>[];
  int saves = 0;

  @override
  bool get available => true;
  @override
  String get serviceName => 'Fake Games';
  @override
  Future<String?> signIn() async => allowSignIn ? 'Tester' : null;
  @override
  Future<void> submit(Board board, int value) async => submitted.add((board, value));
  @override
  Future<int?> rank(Board board) async => 7;
  @override
  Future<void> showLeaderboard(Board? board) async => shown.add(board);
  @override
  Future<void> unlock(String achievement) async => unlocked.add(achievement);
  @override
  Future<void> showAchievements() async {}
  @override
  Future<String?> load() async => cloud;
  @override
  Future<void> save(String data) async {
    saves++;
    cloud = data;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('disabled service does nothing', () async {
    final games = GamesService.disabled(ProgressStore.memory(loadEconomy()));
    await games.start();
    expect(games.available, isFalse);
    expect(games.signedIn, isFalse);
    expect(await games.showLeaderboard(), isFalse);
    expect(await games.submitDaily(12.3), isNull);
  });

  test('sign-in merges the cloud save, then backs up and reports achievements', () async {
    final economy = loadEconomy();
    // Another phone cleared all of World 1.
    final other = ProgressStore.memory(economy);
    for (var id = 1; id <= 20; id++) {
      other.recordWin(id, perfect());
    }
    other.endlessBest = 900;
    final backend = FakeBackend()..cloud = jsonEncode(other.toJson());

    final progress = ProgressStore.memory(economy);
    final games = GamesService(progress, backend: backend, saveDelay: Duration.zero);
    await games.start();
    await games.idle();

    expect(games.signedIn, isTrue);
    expect(games.playerName, 'Tester');
    expect(progress.record(20).starCount, 3);
    expect(progress.totalStars, 60);
    expect(backend.unlocked, containsAll(['first_swing', 'world_1']));
    expect(backend.unlocked, isNot(contains('world_2')));
    expect(backend.submitted, contains((Board.endless, 900)));
    expect(backend.saves, 1);
    expect((jsonDecode(backend.cloud!) as Map)['levels'], hasLength(20));

    // New progress is saved and new achievements are reported once.
    progress.recordEndless(const EndlessResult(distance: 600, style: 400, coins: 0));
    await Future<void>.delayed(Duration.zero);
    await games.idle();
    expect(backend.saves, 2);
    expect(backend.unlocked.where((a) => a == 'endless_500'), hasLength(1));
    expect(backend.unlocked.where((a) => a == 'first_swing'), hasLength(1));
    games.dispose();
  });

  test('scores go out in the right units and bring back a rank', () async {
    final backend = FakeBackend();
    final games = GamesService(ProgressStore.memory(loadEconomy()), backend: backend);
    expect(await games.submitDaily(12.345), isNull, reason: 'not signed in yet');
    expect(await games.signIn(), isTrue);
    await games.idle();
    expect(await games.submitDaily(12.345), 7);
    expect(await games.submitEndless(4200), 7);
    expect(backend.submitted, containsAllInOrder([(Board.daily, 12345), (Board.endless, 4200)]));
    expect(await games.showLeaderboard(Board.daily), isTrue);
    expect(backend.shown, [Board.daily]);
    games.dispose();
  });

  test('a refused sign-in keeps everything off', () async {
    final backend = FakeBackend()..allowSignIn = false;
    final games = GamesService(ProgressStore.memory(loadEconomy()), backend: backend);
    await games.start();
    expect(games.signedIn, isFalse);
    expect(await games.showAchievements(), isFalse);
    expect(backend.saves, 0);
    games.dispose();
  });

  test('every achievement has ids and texts on both platforms', () {
    for (final key in achievementTexts.keys) {
      expect(playGamesIds.achievements, contains(key));
      expect(gameCenterIds.achievements, contains(key));
    }
    final progress = ProgressStore.memory(loadEconomy());
    expect(earnedAchievements(progress), isEmpty);
    for (var id = 1; id <= 100; id++) {
      progress.recordWin(id, perfect());
    }
    expect(earnedAchievements(progress), containsAll(['first_swing', 'world_1', 'world_5', 'stars_150', 'stars_300']));
  });

  test('collecting all 300 stars unlocks the Golden Flop', () {
    final progress = ProgressStore.memory(loadEconomy());
    for (var id = 1; id < 100; id++) {
      expect(progress.recordWin(id, perfect()).unlockedGolden, isFalse);
    }
    expect(progress.ownedSkins, isNot(contains('golden')));
    expect(progress.recordWin(100, perfect()).unlockedGolden, isTrue);
    expect(progress.ownedSkins, contains('golden'));
    expect(progress.recordWin(100, perfect()).unlockedGolden, isFalse);
  });
}
