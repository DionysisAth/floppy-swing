// ignore_for_file: invalid_use_of_visible_for_testing_member
// Captures raw screens for the store listings.
//
//   flutter test tool/screenshots/store_screenshots_test.dart
//   python3 tool/screenshots/frame.py     # adds captions, writes docs/store/screenshots
import 'dart:async';
import 'dart:io';

import 'package:floppy_swing/app.dart';
import 'package:floppy_swing/game/autopilot.dart';
import 'package:floppy_swing/game/cosmetics.dart';
import 'package:floppy_swing/game/game_controller.dart';
import 'package:floppy_swing/game/skins.dart';
import 'package:floppy_swing/services/ads_service.dart';
import 'package:floppy_swing/services/analytics.dart';
import 'package:floppy_swing/services/audio_service.dart';
import 'package:floppy_swing/services/games_service.dart';
import 'package:floppy_swing/services/progress.dart';
import 'package:floppy_swing/services/purchase_service.dart';
import 'package:floppy_swing/ui/game_screen.dart';
import 'package:floppy_swing/ui/level_select_screen.dart';
import 'package:floppy_swing/ui/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers.dart';

Future<void> loadFonts() async {
  Future<void> load(String family, String path) async {
    final l = FontLoader(family)..addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
    await l.load();
  }

  await load('LilitaOne', 'assets/fonts/LilitaOne-Regular.ttf');
  await load('Fredoka', 'assets/fonts/Fredoka.ttf');
  await load('MaterialIcons', '${Platform.environment['FLUTTER_ROOT'] ?? '/opt/sdk/flutter'}'
      '/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
}

Future<void> frames(WidgetTester t, int n) async {
  for (var i = 0; i < n; i++) {
    await t.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('store screens', (tester) async {
    await tester.runAsync(loadFonts);
    // iPhone 6.9" portrait: 1290 x 2796.
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3;
    final content = await tester.runAsync(() => loadContent(rootBundle));
    final progress = ProgressStore.memory(loadEconomy());
    progress.claimLoginReward();
    for (var i = 1; i <= 43; i++) {
      progress.recordWin(i, RunResult(time: 5, targetTime: 30, coins: 3, totalCoins: 3, style: 0, revived: false));
    }
    progress.addCoins(1500);
    progress.addGems(40);
    for (final id in ['banana', 'knight', 'pirate']) {
      progress.grantItem(id);
    }
    progress.selectSkin(skinById('pirate'));
    for (final id in ['rainbow', 'fire']) {
      progress.grantItem(id);
      progress.equip(cosmeticById(id));
    }
    await tester.pumpWidget(FloppySwingApp(
      services: (child) => AppServices(
        physics: content!.physics,
        economy: content.economy,
        levels: content.levels,
        dailies: content.dailies,
        progress: progress,
        audio: AudioService(progress),
        ads: NoAdsService(),
        analytics: const Analytics(),
        games: GamesService.disabled(progress),
        purchases: NoPurchaseService(progress, instant: true),
        child: child,
      ),
    ));
    Future<void> shot(String name) =>
        expectLater(find.byType(MaterialApp), matchesGoldenFile('out/$name.png'));
    NavigatorState nav() => tester.state<NavigatorState>(find.byType(Navigator).first);
    Future<GameController> open(Widget screen) async {
      unawaited(nav().push(MaterialPageRoute<void>(builder: (_) => screen)));
      await frames(tester, 40);
      return GameScreen.debugLastController!;
    }

    await frames(tester, 30);

    // 1. Swinging through Glass City.
    var c = await open(const GameScreen(levelId: 45));
    c.autopilot = Autopilot(const AutopilotParams(releaseAngle: 0.5, regrabDelay: 0.15, minFallSpeed: 1));
    for (var i = 0; i < 60 * 3.1; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await shot('1_swing');
    nav().pop();
    await frames(tester, 20);

    // 2. The slow-motion fail replay.
    c = await open(const GameScreen(levelId: 3));
    c.autopilot = Autopilot(const AutopilotParams(releaseAngle: 0.5, regrabDelay: 0.15, minFallSpeed: 1));
    for (var i = 0; i < 60 * 1.3; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    c.autopilot = null;
    c.pointerCancelAll();
    c.sim.ragdoll.setVelocity(c.sim.ragdoll.velocity..setValues(4, 22));
    for (var i = 0; i < 60 * 3 && c.phase != GamePhase.replay; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await frames(tester, 14);
    await shot('2_fail');
    nav().pop();
    await frames(tester, 20);

    // 3. Worlds.
    await open(const LevelSelectScreen());
    await frames(tester, 20);
    await shot('3_worlds');
    nav().pop();
    await frames(tester, 20);

    // 4. Endless.
    c = await open(const GameScreen.endless(seed: 11));
    c.autopilot = Autopilot(const AutopilotParams(releaseAngle: 0.5, regrabDelay: 0.15, minFallSpeed: 1));
    for (var i = 0; i < 60 * 4.5 && c.phase == GamePhase.playing || i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await shot('4_endless');
    nav().pop();
    await frames(tester, 20);

    // 5. Shop.
    await open(const ShopScreen());
    await tester.tap(find.text('Ropes'));
    await frames(tester, 40);
    await shot('5_shop');
    tester.view.reset();
  });
}
