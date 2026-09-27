import 'dart:convert';
import 'dart:typed_data';

import 'package:floppy_server/floppy_server.dart' as server;
import 'package:floppy_swing/game/cosmetics.dart';
import 'package:floppy_swing/game/game_controller.dart';
import 'package:floppy_swing/services/cloud_sync.dart';
import 'package:floppy_swing/services/online_service.dart';
import 'package:floppy_swing/services/progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';
import 'online_helpers.dart';

RunResult win(double time) => RunResult(time: time, targetTime: 20, coins: 3, totalCoins: 3, style: 0, revived: false);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TestServer srv;
  final economy = loadEconomy();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    srv = TestServer();
  });
  tearDown(() => srv.close());

  test('without a server everything is off and calls fail politely', () async {
    final o = OnlineService.disabled();
    await o.start();
    expect(o.enabled, isFalse);
    expect(o.status, OnlineStatus.disabled);
    expect(() => o.leaderboard('endless'), throwsA(isA<OnlineException>()));
  });

  test('signs up once, remembers the account, and renames', () async {
    final prefs = await SharedPreferences.getInstance();
    final a = await srv.player(prefs: prefs);
    expect(a.isOnline, isTrue);
    final id = a.profile!.id;
    await a.rename('Swingmaster');
    final again = await srv.player(prefs: prefs);
    expect(again.profile!.id, id, reason: 'same token after a restart');
    expect(again.profile!.name, 'Swingmaster');
    expect(() => a.rename('x'), throwsA(isA<OnlineException>()));
  });

  test('deleting the account forgets it; the next start makes a new one', () async {
    final prefs = await SharedPreferences.getInstance();
    final a = await srv.player(prefs: prefs);
    final id = a.profile!.id;
    await a.deleteAccount();
    expect(a.profile, isNull);
    expect(prefs.getString('online_token'), isNull);
    await a.start();
    expect(a.profile!.id, isNot(id));
  });

  test('an unreachable server leaves the game offline, then recovers', () async {
    srv.down = true;
    final o = await srv.player();
    expect(o.status, OnlineStatus.offline);
    await expectLater(o.friends(), throwsA(isA<OnlineException>()));
    srv.down = false;
    await o.start();
    expect(o.isOnline, isTrue);
  });

  test('leaderboards: submit, rank, friends only', () async {
    final a = await srv.player(), b = await srv.player(), c = await srv.player();
    final day = server.serverDay(srv.now);
    final board = OnlineService.dailyBoard(day);
    await a.submitScore(board, 21.5);
    await b.submitScore(board, 19.0);
    final r = await c.submitScore(board, 30);
    expect(r, (rank: 3, total: 3));
    final lb = await a.leaderboard(board);
    expect(lb.entries.map((e) => e.value), [19.0, 21.5, 30.0]);
    expect(lb.myRank, 2);
    expect(lb.entries[1].me, isTrue);
    await a.addFriend(b.profile!.friendCode);
    final fb = await a.leaderboard(board, friends: true);
    expect(fb.entries.map((e) => e.name), [b.profile!.name, a.profile!.name]);
  });

  test('friend ghosts round-trip', () async {
    final a = await srv.player(), b = await srv.player();
    await a.addFriend(b.profile!.friendCode);
    expect((await b.friends()).single.name, a.profile!.name);
    await b.uploadGhost('L5', 9.5, Float32List.fromList([0, 1, 2, 0, 9.5, 20, -3, 0.2]));
    final ghosts = await a.friendGhosts('L5');
    expect(ghosts.single.name, b.profile!.name);
    expect(ghosts.single.samples[4], 9.5);
    await a.removeFriend(b.profile!.id);
    expect(await a.friendGhosts('L5'), isEmpty);
  });

  test('fail of the week: submit, vote, winner reward lands in the save', () async {
    final a = await srv.player(), b = await srv.player();
    final clip = Uint8List.fromList([0, 0, 0, 24, ...ascii.encode('ftypisom'), ...List.filled(100, 1)]);
    await a.submitFail(clip, 'Face, meet spikes');
    var page = await b.fails();
    expect(page.entries.single.caption, 'Face, meet spikes');
    expect(page.entries.single.url, startsWith('http://test/v1/media/fails/'));
    await b.vote(page.entries.single.id);
    page = await b.fails();
    expect(page.entries.single.votes, 1);
    expect(page.entries.single.voted, isTrue);
    expect(() => a.vote(page.entries.single.id), throwsA(isA<OnlineException>()), reason: 'own clip');

    srv.now = srv.now.add(const Duration(days: 7));
    page = await b.fails();
    expect(page.featured!.caption, 'Face, meet spikes');

    final progress = ProgressStore.memory(economy);
    final sync = CloudSync(progress, a);
    final rewards = await sync.collectRewards();
    expect(rewards.single.item, 'golden');
    expect(progress.gems, 50);
    expect(progress.ownedSkins, contains('golden'));
    expect(await sync.collectRewards(), isEmpty);
  });

  test('analytics events are batched to the server', () async {
    final a = await srv.player();
    a.track('level_start', {'level': 4});
    a.track('level_fail', {'level': 4, 'cause': 'saw'});
    await a.flushEvents();
    final stats = srv.store.stats(srv.now);
    expect((stats['levels'] as Map)['4'], containsPair('fails', 1));
  });

  group('cloud save', () {
    test('a second phone gets the first phone\'s progress via a transfer code', () async {
      final phone1 = await srv.player();
      final save1 = ProgressStore.memory(economy);
      final sync1 = CloudSync(save1, phone1, delay: Duration.zero);
      save1.recordWin(1, win(10));
      save1.addGems(7);
      save1.grantItem('laser');
      await sync1.pull();
      final code = await phone1.transferCode();

      final phone2 = await srv.player();
      final save2 = ProgressStore.memory(economy);
      save2.recordWin(2, win(12)); // Some progress of its own.
      final sync2 = CloudSync(save2, phone2, delay: Duration.zero);
      await phone2.redeemTransfer(code);
      expect(phone2.profile!.id, phone1.profile!.id);
      await sync2.accountChanged();
      expect(save2.record(1).starCount, 3);
      expect(save2.record(2).completed, isTrue, reason: 'keeps its own progress too');
      expect(save2.gems, 7);
      expect(save2.ownsItem(cosmeticById('laser')), isTrue);

      // Phone 1 syncs again and now also has phone 2's level.
      await sync1.pull();
      expect(save1.record(2).completed, isTrue);
    });

    test('two phones saving at once merge instead of overwriting', () async {
      final phone1 = await srv.player();
      final code = await phone1.transferCode();
      final phone2 = await srv.player();
      await phone2.redeemTransfer(code);
      final save1 = ProgressStore.memory(economy), save2 = ProgressStore.memory(economy);
      final sync1 = CloudSync(save1, phone1, delay: Duration.zero)..start();
      final sync2 = CloudSync(save2, phone2, delay: Duration.zero)..start();
      await sync1.idle();
      await sync2.idle();
      Future<void> settle() async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await sync1.idle();
        await sync2.idle();
      }

      save1.recordWin(3, win(9));
      await settle(); // Phone 1 uploads.
      save2.recordWin(4, win(9));
      await settle(); // Phone 2's upload conflicts, merges phone 1's copy, retries.
      await sync1.pull();
      expect(save2.record(3).completed, isTrue);
      for (final s in [save1, save2]) {
        expect(s.record(3).completed && s.record(4).completed, isTrue);
      }
    });

    test('merging keeps the best of both saves', () {
      final a = ProgressStore.memory(economy), b = ProgressStore.memory(economy);
      a.recordWin(1, win(15));
      b.recordWin(1, win(11));
      b.recordEndless(const EndlessResult(distance: 400, style: 10, coins: 1));
      a.addCoins(1000);
      b.addGems(9);
      b.grantItem('banana');
      a.mergeFrom(b.toJson());
      expect(a.record(1).bestTime, 11);
      expect(a.endlessBestDistance, 400);
      expect(a.coins, greaterThanOrEqualTo(1000));
      expect(a.gems, 9);
      expect(a.ownedSkins, contains('banana'));
    });
  });
}
