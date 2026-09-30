import 'package:flame/game.dart';
import 'package:floppy_swing/app.dart';
import 'package:floppy_swing/services/ads_service.dart';
import 'package:floppy_swing/services/analytics.dart';
import 'package:floppy_swing/services/audio_service.dart';
import 'package:floppy_swing/services/games_service.dart';
import 'package:floppy_swing/services/progress.dart';
import 'package:floppy_swing/services/purchase_service.dart';
import 'package:floppy_swing/ui/game_screen.dart';
import 'package:floppy_swing/ui/level_select_screen.dart';
import 'package:floppy_swing/game/store_products.dart';
import 'package:floppy_swing/ui/shop_screen.dart';
import 'package:floppy_swing/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Pumps [n] frames (the game animates forever, so pumpAndSettle can't).
Future<void> frames(WidgetTester tester, int n) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('boots to the menu, opens levels, plays level 1 and the shop', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final content = await tester.runAsync(() => loadContent(rootBundle));
    final progress = ProgressStore.memory(loadEconomy());
    // Audio is never initialised in tests, so every call is a silent no-op.
    final audio = AudioService(progress);

    await tester.pumpWidget(
      FloppySwingApp(
        services: (child) => AppServices(
          physics: content!.physics,
          economy: content.economy,
          levels: content.levels,
          dailies: content.dailies,
          progress: progress,
          audio: audio,
          ads: NoAdsService(),
          analytics: const Analytics(),
          games: GamesService.disabled(progress),
          purchases: NoPurchaseService(progress, instant: true),
          child: child,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    // Daily login bonus comes first.
    expect(find.text('DAILY BONUS'), findsOneWidget);
    final coinsBefore = progress.coins;
    await tester.tap(find.text('Claim'));
    await frames(tester, 20);
    expect(find.text('DAILY BONUS'), findsNothing);
    expect(progress.coins, greaterThan(coinsBefore));
    expect(find.text('FLOPPY'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is GameWidget), findsOneWidget, reason: 'attract-mode demo');

    await tester.tap(find.text('PLAY'));
    await frames(tester, 25);
    expect(find.byType(LevelSelectScreen), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('World 1'.toUpperCase()), findsOneWidget);
    expect(find.text('Playground'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsNWidgets(19), reason: 'rest of world 1 locked');

    await tester.tap(find.text('1'));
    await frames(tester, 25);
    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.textContaining('First Swing'), findsOneWidget);
    expect(find.textContaining('Hold anywhere'), findsOneWidget);

    // Hold to swing, let go.
    final g = await tester.startGesture(const Offset(200, 500));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await g.up();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.textContaining('Hold anywhere'), findsNothing);

    // Pause and leave.
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await frames(tester, 5);
    expect(find.text('PAUSED'), findsOneWidget);
    await tester.tap(find.text('Levels'));
    await frames(tester, 25);
    expect(find.byType(LevelSelectScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await frames(tester, 25);

    // Endless and the Daily Challenge open from the menu and quit back.
    for (final mode in ['ENDLESS', 'DAILY']) {
      await tester.tap(find.text(mode));
      await frames(tester, 25);
      expect(find.byType(GameScreen), findsOneWidget, reason: mode);
      expect(find.textContaining(mode == 'ENDLESS' ? 'ENDLESS' : 'DAILY:'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.pause_rounded));
      await frames(tester, 5);
      await tester.tap(find.text('Quit'));
      await frames(tester, 25);
      expect(find.text('PLAY'), findsOneWidget);
    }

    await tester.tap(find.text('SHOP'));
    await frames(tester, 25);
    expect(find.byType(ShopScreen), findsOneWidget);
    expect(find.text('EQUIPPED'), findsOneWidget);
    expect(find.text('Rubber Chicken'), findsOneWidget);

    // Tapping the gem counter opens the gem store (the test store grants
    // instantly).
    await tester.tap(find.byType(GemBadge).first);
    await frames(tester, 25);
    expect(find.text('Starter Pack'), findsOneWidget);
    final gemsBefore = progress.gems;
    await tester.tap(find.text(starterPack.fallbackPrice).first);
    await frames(tester, 10);
    expect(progress.gems, gemsBefore + starterPack.gems);
    expect(find.text('Starter Pack'), findsNothing, reason: 'once only');
    expect(find.textContaining('Thanks'), findsOneWidget);
  });
}
