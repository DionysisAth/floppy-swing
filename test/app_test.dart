import 'package:flame/game.dart';
import 'package:floppy_swing/app.dart';
import 'package:floppy_swing/services/ads_service.dart';
import 'package:floppy_swing/services/analytics.dart';
import 'package:floppy_swing/services/audio_service.dart';
import 'package:floppy_swing/services/progress.dart';
import 'package:floppy_swing/ui/game_screen.dart';
import 'package:floppy_swing/ui/level_select_screen.dart';
import 'package:floppy_swing/ui/shop_screen.dart';
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
          progress: progress,
          audio: audio,
          ads: NoAdsService(),
          analytics: const Analytics(),
          child: child,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
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
    await tester.tap(find.text('SKINS'));
    await frames(tester, 25);
    expect(find.byType(ShopScreen), findsOneWidget);
    expect(find.text('EQUIPPED'), findsOneWidget);
    expect(find.text('Rubber Chicken'), findsOneWidget);
  });
}
