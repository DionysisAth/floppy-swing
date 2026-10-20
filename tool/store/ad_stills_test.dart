// ignore_for_file: invalid_use_of_visible_for_testing_member
// Captures clean in-game stills (no captions) for ads and social posts: the
// real app at 1080x1920, played by the autopilot through every world.
//
//   flutter test tool/store/ad_stills_test.dart
//   python3 tool/store/make_ad_pack.py      # picks, frames and zips them
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

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
import 'package:floppy_swing/ui/season_screen.dart';
import 'package:floppy_swing/ui/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers.dart';
import '../screenshots/store_screenshots_test.dart' show loadFonts;

const width = 1080, height = 1920;
const out = 'tool/store/out/stills';

void main() {
  testWidgets('ad stills', (tester) async {
    await tester.runAsync(loadFonts);
    tester.view.physicalSize = const Size(width * 1.0, height * 1.0);
    tester.view.devicePixelRatio = 2.625;
    final content = await tester.runAsync(() => loadContent(rootBundle));
    final solutions = (jsonDecode(File('test/level_solutions.json').readAsStringSync()) as Map<String, dynamic>).map(
      (k, v) => MapEntry(
        int.parse(k),
        AutopilotParams(
          releaseAngle: (v['releaseAngle'] as num).toDouble(),
          regrabDelay: (v['regrabDelay'] as num).toDouble(),
          minFallSpeed: (v['minFallSpeed'] as num).toDouble(),
        ),
      ),
    );
    final progress = ProgressStore.memory(loadEconomy());
    progress.claimLoginReward();
    for (var i = 1; i <= 90; i++) {
      progress.recordWin(i, RunResult(time: 5, targetTime: 30, coins: 3, totalCoins: 3, style: 0, revived: false));
    }
    progress.addCoins(2400);
    progress.addGems(120);
    for (final id in ['banana', 'knight', 'ninja', 'pirate', 'astronaut', 'wizard', 'dino', 'robot', 'chicken']) {
      progress.grantItem(id);
    }
    for (final id in ['rainbow', 'laser', 'chain', 'fire', 'sparkles', 'stars', 'gold']) {
      progress.grantItem(id);
    }
    await tester.pumpWidget(
      FloppySwingApp(
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
      ),
    );
    Directory(out).createSync(recursive: true);

    Future<void> shot(String name) async {
      RenderObject boundary = tester.renderObject(find.byType(MaterialApp));
      while (!boundary.isRepaintBoundary) {
        boundary = boundary.parent!;
      }
      await tester.runAsync(() async {
        final layer = boundary.debugLayer! as OffsetLayer;
        final image = await layer.toImage(boundary.paintBounds);
        if (image.width != width || image.height != height) {
          throw StateError('captured ${image.width}x${image.height}, expected ${width}x$height');
        }
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        File('$out/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
      });
    }

    Future<void> run(double seconds) async {
      for (var i = 0; i < (seconds * 60).round(); i++) {
        await tester.pump(const Duration(microseconds: 16667));
      }
    }

    NavigatorState nav() => tester.state<NavigatorState>(find.byType(Navigator).first);
    Future<GameController?> open(Widget screen) async {
      unawaited(nav().push(MaterialPageRoute<void>(builder: (_) => screen)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      return screen is GameScreen ? GameScreen.debugLastController : null;
    }

    Future<void> close() async {
      nav().pop();
      await run(0.4);
    }

    void dressUp(String skin, String rope, String trail) {
      progress.selectSkin(skinById(skin));
      progress.equip(cosmeticById(rope));
      progress.equip(cosmeticById(trail));
    }

    await run(0.6);
    await shot('menu');

    // Two levels from each world, a few moments from each.
    const plan = [
      (2, 'floppy', 'rainbow', 'fire'),
      (14, 'banana', 'rope', 'sparkles'),
      (24, 'robot', 'chain', 'gold'),
      (33, 'knight', 'chain', 'fire'),
      (45, 'ninja', 'laser', 'stars'),
      (52, 'pirate', 'rainbow', 'sparkles'),
      (64, 'astronaut', 'laser', 'stars'),
      (75, 'wizard', 'rainbow', 'sparkles'),
      (86, 'dino', 'laser', 'fire'),
      (96, 'floppy', 'rainbow', 'gold'),
    ];
    for (final (level, skin, rope, trail) in plan) {
      dressUp(skin, rope, trail);
      final c = (await open(GameScreen(levelId: level)))!;
      // The default start delay, as in the level verification runs.
      c.autopilot = Autopilot(solutions[level]!);
      var t = 0.0;
      for (final at in [1.9, 2.9, 3.9, 5.1, 6.3]) {
        await run(at - t);
        t = at;
        if (c.phase != GamePhase.playing) break;
        await shot('level_${level}_${at.toStringAsFixed(1)}');
      }
      await close();
    }

    // A fail and its slow-motion replay.
    dressUp('chicken', 'rainbow', 'fire');
    var c = (await open(const GameScreen(levelId: 3)))!;
    c.autopilot = Autopilot(solutions[3]!, startDelay: 0.3);
    await run(1.2);
    c.autopilot = null;
    c.pointerCancelAll();
    c.sim.ragdoll.setVelocity(c.sim.ragdoll.velocity..setValues(4, 22));
    for (var i = 0; i < 60 * 3 && c.phase != GamePhase.replay; i++) {
      await tester.pump(const Duration(microseconds: 16667));
    }
    for (final k in [0, 1, 2, 3]) {
      await run(0.25);
      await shot('fail_replay_$k');
    }
    await close();

    // Endless.
    dressUp('pirate', 'laser', 'stars');
    c = (await open(const GameScreen.endless(seed: 11)))!;
    c.autopilot = Autopilot(
      const AutopilotParams(releaseAngle: 0.5, regrabDelay: 0.15, minFallSpeed: 1),
      startDelay: 0.3,
    );
    for (final at in [2.0, 4.0, 6.0]) {
      await run(2.0);
      if (c.phase != GamePhase.playing) break;
      await shot('endless_${at.toStringAsFixed(0)}');
    }
    await close();

    // A level clear.
    dressUp('wizard', 'rainbow', 'sparkles');
    c = (await open(const GameScreen(levelId: 1)))!;
    c.autopilot = Autopilot(solutions[1]!);
    for (var i = 0; i < 60 * 20 && (c.phase == GamePhase.ready || c.phase == GamePhase.playing); i++) {
      await tester.pump(const Duration(microseconds: 16667));
    }
    await run(1.6);
    await shot('level_clear');
    await close();

    // Menus.
    dressUp('knight', 'rainbow', 'fire');
    await open(const LevelSelectScreen());
    await run(0.5);
    await shot('worlds');
    await close();
    await open(const ShopScreen());
    await run(0.6);
    await shot('shop_skins');
    await tester.tap(find.text('Ropes'));
    await run(0.6);
    await shot('shop_ropes');
    await close();
    await open(const SeasonScreen());
    await run(0.6);
    await shot('season_pass');
    await close();

    await run(3);
    tester.view.reset();
  }, timeout: const Timeout(Duration(minutes: 20)));
}
