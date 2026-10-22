import 'dart:convert';
import 'dart:io';

import 'package:floppy_swing/app.dart';
import 'package:floppy_swing/game/autopilot.dart';
import 'package:floppy_swing/game/game_controller.dart';
import 'package:floppy_swing/game/game_words.dart';
import 'package:floppy_swing/l10n/l10n.dart';
import 'package:floppy_swing/services/ads_service.dart';
import 'package:floppy_swing/services/analytics.dart';
import 'package:floppy_swing/services/audio_service.dart';
import 'package:floppy_swing/services/games_service.dart';
import 'package:floppy_swing/services/progress.dart';
import 'package:floppy_swing/services/purchase_service.dart';
import 'package:floppy_swing/services/reminders.dart';
import 'package:floppy_swing/ui/game_screen.dart';
import 'package:floppy_swing/ui/level_select_screen.dart';
import 'package:floppy_swing/ui/season_screen.dart';
import 'package:floppy_swing/ui/settings_screen.dart';
import 'package:floppy_swing/ui/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Future<void> _loadFonts() async {
  Future<void> load(String family, String path) async {
    final l = FontLoader(family)..addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
    await l.load();
  }

  await load('LilitaOne', 'assets/fonts/LilitaOne-Regular.ttf');
  await load('Fredoka', 'assets/fonts/Fredoka.ttf');
  await load('MPLUSRounded', 'assets/fonts/MPLUSRounded1c-Bold.ttf');
  await load('MPLUSRoundedBlack', 'assets/fonts/MPLUSRounded1c-Black.ttf');
}

Future<void> _frames(WidgetTester tester, int n) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  test('English comes first: it is the fallback', () {
    expect(appLocales.first, const Locale('en'));
  });

  test('every language in the picker is translated, and the reverse', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      languageNames.keys.toSet(),
    );
  });

  test('the phone language is used when the game has it, else English', () {
    expect(resolveLocale(null, const [Locale('el', 'GR')]).languageCode, 'el');
    expect(resolveLocale(null, const [Locale('pt', 'BR')]).languageCode, 'pt');
    expect(resolveLocale(null, const [Locale('zh', 'TW')]).languageCode, 'zh');
    expect(resolveLocale(null, const [Locale('sv', 'SE'), Locale('de', 'AT')]).languageCode, 'de');
    expect(resolveLocale(null, const [Locale('sv', 'SE')]).languageCode, 'en');
    // A language picked in Settings wins.
    expect(resolveLocale('ja', const [Locale('el', 'GR')]).languageCode, 'ja');
  });

  test('the English hints match the level files', () {
    final en = lookupAppLocalizations(const Locale('en'));
    for (final level in loadLevels()) {
      expect(en.levelHint(level), level.hint, reason: 'level ${level.id}');
    }
  });

  test('every hint, name and fail line is translated', () {
    final levels = loadLevels();
    for (final locale in AppLocalizations.supportedLocales) {
      final l = lookupAppLocalizations(locale);
      for (final level in levels.where((l) => l.hint != null)) {
        expect(l.levelHint(level), isNotEmpty);
      }
      expect(l.gameWords.style('HANG TIME x3'), endsWith(' x3'));
      expect(l.purchaseThanks('X'), contains('X'));
      expect(l.worldGate(5, 'W'), allOf(contains('5'), contains('W')));
      expect(l.dayStreak(1), contains('1'));
      expect(l.daysLeft(22), contains('22'));
    }
  });

  test('capitals follow the language', () {
    expect(upper('Παιδική Χαρά', 'el'), 'ΠΑΙΔΙΚΗ ΧΑΡΑ');
    expect(upper('Gökyüzü Adaları', 'tr'), 'GÖKYÜZÜ ADALARI');
    expect(upper('Kiwi', 'tr'), 'KİWİ');
    expect(upper('Sky Islands', 'en'), 'SKY ISLANDS');
  });

  test('style tricks keep their combo count', () {
    const words = GameWords(styles: {'FLIP': 'ΤΟΥΜΠΑ'});
    expect(words.style('FLIP'), 'ΤΟΥΜΠΑ');
    expect(words.style('FLIP x2'), 'ΤΟΥΜΠΑ x2');
    expect(words.style('UNKNOWN x4'), 'UNKNOWN x4');
  });

  test('reminders are written in the given language', () {
    final el = lookupAppLocalizations(const Locale('el'));
    final plan = planReminders(DateTime(2026, 10, 1, 9), doneToday: false, streak: 4, strings: el);
    expect(plan.first.title, el.reminderStreakTitle(4));
  });

  // Opens every screen in every language at a small phone size: any text
  // that doesn't fit fails the test with an overflow error.
  final solutions = (jsonDecode(File('test/level_solutions.json').readAsStringSync()) as Map<String, dynamic>);
  final pilot = solutions['1'] as Map<String, dynamic>;
  for (final lang in languageNames.keys) {
    testWidgets('every screen fits in $lang', (tester) async {
      await tester.runAsync(_loadFonts);
      tester.view.physicalSize = const Size(1080, 2160);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final content = await tester.runAsync(() => loadContent(rootBundle));
      final progress = ProgressStore.memory(loadEconomy())..setLanguage(lang);
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
      await _frames(tester, 30);
      final l = lookupAppLocalizations(Locale(lang));
      // The login bonus, then the menu.
      expect(find.text(l.dailyBonus), findsOneWidget);
      await tester.tap(find.text(l.claim));
      await _frames(tester, 20);
      expect(find.text(l.play), findsOneWidget);

      // What overflowed where, reported together at the end.
      final problems = <String>[];
      void check(String step) {
        final e = tester.takeException();
        if (e != null) problems.add('$lang $step: ${e.toString().split('\n').first}');
      }

      check('menu');
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      Future<void> visit(Widget page, [Future<void> Function()? inside]) async {
        nav.push(MaterialPageRoute<void>(builder: (_) => page));
        await _frames(tester, 30);
        check('${page.runtimeType} open');
        await inside?.call();
        check('${page.runtimeType} inside');
        nav.pop();
        await _frames(tester, 20);
      }

      await visit(const SettingsScreen(), () async {
        expect(find.text(l.settingsTitle), findsOneWidget);
      });
      await visit(const LevelSelectScreen(), () async {
        expect(find.text(l.world1Name), findsOneWidget);
        // A locked world.
        await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
        await _frames(tester, 30);
      });
      await visit(const ShopScreen(), () async {
        for (var tab = 1; tab < 7; tab++) {
          DefaultTabController.of(tester.element(find.byType(TabBarView))).animateTo(tab);
          await _frames(tester, 30);
          check('shop tab $tab');
        }
      });
      await visit(const SeasonScreen());

      // A level: the hint, the pause menu, a fail, then a clear.
      await visit(const GameScreen(levelId: 1), () async {
        final c = GameScreen.debugLastController!;
        expect(find.text(l.hintLevel1), findsOneWidget);
        c.setPaused(true);
        await _frames(tester, 10);
        expect(find.text(l.paused), findsOneWidget);
        check('pause');
        c.setPaused(false);
        c.pointerDown();
        await _frames(tester, 30);
        c.pointerUp();
        c.sim.ragdoll.setVelocity(c.sim.ragdoll.velocity..setValues(4, 30));
        for (var i = 0; i < 400 && c.phase != GamePhase.failed; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(find.text(l.tapToRetry), findsOneWidget);
        check('fail');
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
        expect(c.phase, GamePhase.won);
        await _frames(tester, 120);
        expect(find.text(l.levelClear), findsOneWidget);
        check('win');
      });

      // An Endless run that ends.
      await visit(const GameScreen.endless(seed: 7), () async {
        final c = GameScreen.debugLastController!;
        c.pointerDown();
        await _frames(tester, 20);
        c.pointerUp();
        c.sim.ragdoll.setVelocity(c.sim.ragdoll.velocity..setValues(4, 30));
        for (var i = 0; i < 400 && c.phase != GamePhase.failed; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(find.text(l.newCourse), findsOneWidget);
        check('endless fail');
      });
      await _frames(tester, 60);
      check('end');
      expect(problems, isEmpty);
    });
  }
}
