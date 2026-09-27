import 'dart:convert';

import 'package:floppy_server/floppy_server.dart' as server;
import 'package:floppy_swing/app.dart';
import 'package:floppy_swing/services/ads_service.dart';
import 'package:floppy_swing/services/analytics.dart';
import 'package:floppy_swing/services/audio_service.dart';
import 'package:floppy_swing/services/cloud_sync.dart';
import 'package:floppy_swing/services/online_service.dart';
import 'package:floppy_swing/services/progress.dart';
import 'package:floppy_swing/ui/fails_screen.dart';
import 'package:floppy_swing/ui/friends_screen.dart';
import 'package:floppy_swing/ui/leaderboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';
import 'online_helpers.dart';

Future<void> frames(WidgetTester tester, int n) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('leaderboards, friends, Fail of the Week and settings work against a live server', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final srv = TestServer();
    addTearDown(srv.close);
    final progress = ProgressStore.memory(loadEconomy());
    final day = progress.today;
    srv.now = DateTime.now().toUtc();

    final setup = await tester.runAsync(() async {
      final rival = await srv.player();
      await rival.rename('Rival');
      await rival.submitScore(OnlineService.dailyBoard(day), 14.2);
      await rival.submitScore(OnlineService.endlessBoard, 777);
      await rival.submitFail(
        Uint8List.fromList([0, 0, 0, 24, ...ascii.encode('ftypisom'), ...List.filled(64, 1)]),
        'Spikes 1, Rival 0',
      );
      final me = await srv.player();
      await me.rename('Tester');
      final content = await loadContent(rootBundle);
      return (rival: rival, me: me, content: content);
    });
    final me = setup!.me;
    final content = setup.content;

    await tester.pumpWidget(
      FloppySwingApp(
        services: (child) => AppServices(
          physics: content.physics,
          economy: content.economy,
          levels: content.levels,
          dailies: content.dailies,
          progress: progress,
          audio: AudioService(progress),
          ads: NoAdsService(),
          analytics: const Analytics(),
          online: me,
          cloud: CloudSync(progress, me),
          child: child,
        ),
      ),
    );
    await frames(tester, 30);
    await tester.tap(find.text('Claim'));
    await frames(tester, 20);

    // Leaderboards.
    await tester.tap(find.bySemanticsLabel('Leaderboards'));
    await frames(tester, 30);
    expect(find.byType(LeaderboardScreen), findsOneWidget);
    expect(find.text('Rival'), findsOneWidget);
    expect(find.text('14.20s'), findsOneWidget);
    await tester.tap(find.text('Endless'));
    await frames(tester, 30);
    expect(find.text('777'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await frames(tester, 25);

    // Friends: add the rival by code.
    await tester.tap(find.bySemanticsLabel('Friends'));
    await frames(tester, 30);
    expect(find.byType(FriendsScreen), findsOneWidget);
    expect(find.text(me.profile!.friendCode), findsOneWidget);
    expect(find.text('No friends yet. Share your code!'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, setup.rival.profile!.friendCode);
    await tester.tap(find.text('Add'));
    await frames(tester, 30);
    expect(find.text('Rival'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await frames(tester, 25);

    // Fail of the Week: the rival's clip, which we can vote for.
    await tester.tap(find.bySemanticsLabel('Fail of the Week'));
    await frames(tester, 30);
    expect(find.byType(FailsScreen), findsOneWidget);
    expect(find.text('Spikes 1, Rival 0'), findsOneWidget);
    await tester.tap(find.byTooltip('Vote'));
    await frames(tester, 30);
    expect(find.byTooltip('Voted'), findsOneWidget);
    final clips = srv.store.fails(week: server.serverWeek(srv.now));
    expect(clips.single.votes, 1);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await frames(tester, 25);

    // Settings shows the account.
    await tester.tap(find.bySemanticsLabel('Settings'));
    await frames(tester, 30);
    expect(find.text('Online as Tester'), findsOneWidget);
  });
}
