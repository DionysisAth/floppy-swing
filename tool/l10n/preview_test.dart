// ignore_for_file: invalid_use_of_visible_for_testing_member
// Screenshots of the main screens in one or more languages, for checking
// translations by eye (1080x2160, a 360dp-wide phone):
//
//   LANGS=el,de flutter test tool/l10n/preview_test.dart
//
// Writes tool/l10n/out/<lang>/*.png (all languages if LANGS is unset).
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:floppy_swing/app.dart';
import 'package:floppy_swing/game/autopilot.dart';
import 'package:floppy_swing/game/game_controller.dart';
import 'package:floppy_swing/l10n/l10n.dart';
import 'package:floppy_swing/services/ads_service.dart';
import 'package:floppy_swing/services/analytics.dart';
import 'package:floppy_swing/services/audio_service.dart';
import 'package:floppy_swing/services/games_service.dart';
import 'package:floppy_swing/services/progress.dart';
import 'package:floppy_swing/services/purchase_service.dart';
import 'package:floppy_swing/ui/game_screen.dart';
import 'package:floppy_swing/ui/level_select_screen.dart';
import 'package:floppy_swing/ui/season_screen.dart';
import 'package:floppy_swing/ui/settings_screen.dart';
import 'package:floppy_swing/ui/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers.dart';
import '../screenshots/store_screenshots_test.dart' show loadFonts;

void main() {
  final wanted = Platform.environment['LANGS']?.split(',') ?? languageNames.keys.toList();
  final pilot = (jsonDecode(File('test/level_solutions.json').readAsStringSync()) as Map<String, dynamic>)['1']
      as Map<String, dynamic>;
  for (final lang in wanted) {
    testWidgets('preview $lang', (tester) async {
      await tester.runAsync(loadFonts);
      tester.view.physicalSize = const Size(1080, 2160);
      tester.view.devicePixelRatio = 3;
      final content = await tester.runAsync(() => loadContent(rootBundle));
      final progress = ProgressStore.memory(loadEconomy())
        ..setLanguage(lang)
        ..claimLoginReward()
        ..addCoins(800)
        ..addGems(60);
      await tester.pumpWidget(
        FloppySwingApp(
          services: (child) => AppServices(
            physics: content!.physics,
            economy: content.economy,
            levels: content.levels,
            dailies: content.dailies,
            progress: progress,
            audio: AudioService(progress),
            ads: NoAdsService(grantRewards: true),
            analytics: const Analytics(),
            games: GamesService.disabled(progress),
            purchases: NoPurchaseService(progress, instant: true),
            child: child,
          ),
        ),
      );
      final dir = 'tool/l10n/out/$lang';
      Directory(dir).createSync(recursive: true);

      Future<void> run(double seconds) async {
        for (var i = 0; i < (seconds * 60).round(); i++) {
          await tester.pump(const Duration(microseconds: 16667));
        }
      }

      Future<void> shot(String name) async {
        RenderObject boundary = tester.renderObject(find.byType(MaterialApp));
        while (!boundary.isRepaintBoundary) {
          boundary = boundary.parent!;
        }
        await tester.runAsync(() async {
          final image = await (boundary.debugLayer! as OffsetLayer).toImage(boundary.paintBounds);
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          image.dispose();
          File('$dir/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
        });
      }

      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      Future<GameController?> open(Widget page) async {
        nav.push(MaterialPageRoute<void>(builder: (_) => page));
        await run(0.6);
        return page is GameScreen ? GameScreen.debugLastController : null;
      }

      Future<void> close() async {
        nav.pop();
        await run(0.4);
      }

      await run(0.6);
      await shot('1_menu');
      await open(const SettingsScreen());
      await shot('2_settings');
      await close();
      await open(const LevelSelectScreen());
      await shot('3_levels');
      await close();
      await open(const ShopScreen());
      await shot('4_shop');
      await close();
      await open(const SeasonScreen());
      await shot('5_season');
      await close();

      final c = (await open(const GameScreen(levelId: 1)))!;
      await shot('6_hint');
      c.pointerDown();
      await run(0.5);
      c.pointerUp();
      c.sim.ragdoll.setVelocity(c.sim.ragdoll.velocity..setValues(4, 30));
      for (var i = 0; i < 400 && c.phase != GamePhase.failed; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await run(0.3);
      await shot('7_fail');
      c.retry();
      c.autopilot = Autopilot(
        AutopilotParams(
          releaseAngle: (pilot['releaseAngle'] as num).toDouble(),
          regrabDelay: (pilot['regrabDelay'] as num).toDouble(),
          minFallSpeed: (pilot['minFallSpeed'] as num).toDouble(),
        ),
      );
      for (var i = 0; i < 60 * 30 && c.phase != GamePhase.won; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await run(2.5);
      await shot('8_win');
      await close();
      await run(2);
      tester.view.reset();
    }, timeout: const Timeout(Duration(minutes: 5)));
  }
}
