import 'dart:convert';

import 'package:floppy_swing/game/course_builder.dart';
import 'package:floppy_swing/game/game_controller.dart';
import 'package:floppy_swing/game/level.dart';
import 'package:floppy_swing/game/simulation.dart';
import 'package:floppy_swing/game/skins.dart';
import 'package:floppy_swing/services/progress.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

RunResult win({double time = 10, int coins = 5}) =>
    RunResult(time: time, targetTime: 12, coins: coins, totalCoins: 5, style: 0, revived: false);

void main() {
  final cfg = loadPhysics();
  final economy = loadEconomy();

  group('endless courses', () {
    test('are reproducible from their seed and differ between seeds', () {
      final a = jsonEncode(CourseBuilder.endless(7).buildEndless());
      final b = jsonEncode(CourseBuilder.endless(7).buildEndless());
      final c = jsonEncode(CourseBuilder.endless(8).buildEndless());
      expect(a, b);
      expect(a, isNot(c));
    });

    test('are long, bring in every mechanic, and keep coins off hazards', () {
      final level = Level.fromJson(CourseBuilder.endless(3).buildEndless());
      expect(level.finish.x, greaterThan(2900));
      expect(level.anchors.where((a) => a.moving), isNotEmpty);
      expect(level.glass, isNotEmpty);
      expect(level.winds, isNotEmpty);
      expect(level.flips, isNotEmpty);
      expect(level.crumbles, isNotEmpty);
      expect(level.launchers, isNotEmpty);
      expect(level.coins.length, greaterThan(100));
      for (final c in level.coins) {
        expect(level.nearHazard(c.x, c.y), isFalse);
      }
      // The first zone is plain World 1 fare.
      expect(level.glass.every((g) => g.x > CourseBuilder.zoneLength * 2), isTrue);
    });

    test('zones cycle through the worlds', () {
      expect(CourseBuilder.endlessWorld(10), 1);
      expect(CourseBuilder.endlessWorld(CourseBuilder.zoneLength + 1), 2);
      expect(CourseBuilder.endlessWorld(CourseBuilder.zoneLength * 5 + 1), 1);
    });

    test('the controller tracks distance, scores on death and never revives', () {
      final level = Level.fromJson(CourseBuilder.endless(1).buildEndless());
      final c = GameController(level: level, cfg: cfg, skin: skins.first, mode: PlayMode.endless);
      c.setViewport(390, 844);
      c.pointerDown();
      for (var i = 0; i < 60 * 1.5; i++) {
        c.tick(1 / 60);
      }
      c.pointerUp();
      expect(c.distance, greaterThan(3));
      // Hurl the character into the pit.
      c.sim.ragdoll.setVelocity(c.sim.ragdoll.velocity..setValues(0, 30));
      for (var i = 0; i < 60 * 3 && c.phase != GamePhase.failed; i++) {
        c.tick(1 / 60);
      }
      expect(c.endlessResult, isNotNull);
      expect(c.endlessResult!.distance, c.distance.floor());
      expect(c.canRevive, isFalse);
      c.retry();
      expect(c.distance, 0);
      expect(c.endlessResult, isNull);
    });
  });

  group('daily challenges', () {
    test('day numbers count local calendar days', () {
      expect(dayNumber(DateTime(2026, 1, 1, 23, 59)), 0);
      expect(dayNumber(DateTime(2026, 1, 2, 0, 1)), 1);
      expect(dayNumber(DateTime(2026, 3, 1)), 59);
    });

    test('first clear pays coins and gems, later clears only improve the record', () {
      final p = ProgressStore.memory(economy);
      final first = p.recordDaily(5, win(time: 11));
      expect(first.coins, 5 * economy.coinValue + economy.dailyCoins);
      expect(first.gems, economy.dailyGems);
      expect(p.gems, economy.dailyGems);
      final again = p.recordDaily(5, win(time: 9, coins: 0));
      expect(again.gems, 0);
      expect(again.newBest, isTrue);
      expect(p.dailyRecord(5).bestTime, 9);
      expect(p.dailyRecord(5).starCount, 3);
    });

    test('streaks grow on consecutive days, pay a bonus every 7th, and break', () {
      var now = DateTime(2026, 5, 1);
      final p = ProgressStore.memory(economy, clock: () => now);
      for (var i = 0; i < 7; i++) {
        final r = p.recordDaily(p.today, win());
        expect(p.currentDailyStreak, i + 1);
        expect(r.streakBonus, i == 6);
        now = now.add(const Duration(days: 1));
      }
      expect(p.currentDailyStreak, 7, reason: 'still alive the next day');
      now = now.add(const Duration(days: 1));
      expect(p.currentDailyStreak, 0, reason: 'a missed day breaks it');
      p.recordDaily(p.today, win());
      expect(p.currentDailyStreak, 1);
    });

    test('daily levels have a world theme and no revives', () {
      final daily = loadDailies().first;
      expect(daily.world, inInclusiveRange(1, 5));
      final c = GameController(level: daily, cfg: cfg, skin: skins.first, mode: PlayMode.daily);
      expect(c.canRevive, isFalse);
    });
  });

  test('endless runs pay per metre and pickups, and track the best', () {
    final p = ProgressStore.memory(economy);
    final r = p.recordEndless(const EndlessResult(distance: 123, style: 40, coins: 4));
    expect(r.newBest, isTrue);
    expect(r.coins, 4 * economy.coinValue + 123 ~/ economy.endlessMetresPerCoin);
    expect(p.endlessBest, 163);
    expect(p.endlessBestDistance, 123);
    expect(p.recordEndless(const EndlessResult(distance: 50, style: 0, coins: 0)).newBest, isFalse);
    expect(p.endlessBest, 163);
  });

  test('long courses can hold more than 64 coins and panes', () {
    final bits = Bits.empty.add(3).add(70).add(200);
    expect(bits[70], isTrue);
    expect(bits[71], isFalse);
    expect(bits.count, 3);
    expect(Bits.empty[1000], isFalse);
  });
}
