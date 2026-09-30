import 'dart:typed_data';

import 'package:floppy_swing/game/cosmetics.dart';
import 'package:floppy_swing/game/game_controller.dart';
import 'package:floppy_swing/game/season.dart';
import 'package:floppy_swing/game/skins.dart';
import 'package:floppy_swing/services/progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

RunResult result({double time = 10, int coins = 5, int total = 5}) => RunResult(
  time: time,
  targetTime: 12,
  coins: coins,
  totalCoins: total,
  style: 100,
  revived: false,
);

void main() {
  final economy = loadEconomy();

  test('levels unlock in order', () {
    final p = ProgressStore.memory(economy);
    expect(p.isUnlocked(1), isTrue);
    expect(p.isUnlocked(2), isFalse);
    p.recordWin(1, result(time: 50, coins: 0));
    expect(p.isUnlocked(2), isTrue);
    expect(p.isUnlocked(3), isFalse);
  });

  test('new worlds also need enough stars', () {
    final p = ProgressStore.memory(economy);
    for (var id = 1; id <= 20; id++) {
      p.recordWin(id, result(time: 50, coins: 0)); // One star each.
    }
    expect(p.totalStars, 20);
    expect(p.isWorldUnlocked(2), isTrue, reason: 'world 2 needs 15 stars');
    expect(p.isUnlocked(21), isTrue);
    for (var id = 21; id <= 40; id++) {
      p.recordWin(id, result(time: 50, coins: 0));
    }
    expect(p.totalStars, 40);
    expect(p.isUnlocked(41), isTrue);
    for (var id = 41; id <= 60; id++) {
      p.recordWin(id, result(time: 50, coins: 0));
    }
    expect(p.isUnlocked(61), isFalse, reason: 'world 4 needs 70 stars, only 60');
    expect(p.worldStars(3), 20);
    p.recordWin(1, result());
    for (var id = 2; id <= 5; id++) {
      p.recordWin(id, result());
    }
    expect(p.totalStars, 70);
    expect(p.isUnlocked(61), isTrue);
  });

  test('rewards pay for pickups, completion and only new stars', () {
    final p = ProgressStore.memory(economy);
    final first = p.recordWin(1, result(time: 50, coins: 2));
    expect(first.newStars, 1); // Finished, but slow and missed coins.
    expect(first.total, 2 * economy.coinValue + economy.levelCompleteReward + economy.starReward);
    expect(p.coins, first.total);

    final second = p.recordWin(1, result());
    expect(second.newStars, 2);
    expect(p.record(1).starCount, 3);
    expect(p.record(1).bestTime, 10);

    final third = p.recordWin(1, result(time: 11));
    expect(third.newStars, 0);
    expect(p.record(1).bestTime, 10, reason: 'best time only improves');
    expect(p.totalStars, 3);
  });

  test('skins can be bought, equipped and are not free', () {
    final p = ProgressStore.memory(economy);
    final banana = skinById('banana');
    expect(p.buySkin(banana), isFalse);
    p.addCoins(p.priceOf(banana));
    expect(p.buySkin(banana), isTrue);
    expect(p.coins, 0);
    expect(p.selectedSkin, 'banana');
    p.selectSkin(skinById('floppy'));
    expect(p.selectedSkin, 'floppy');
    p.selectSkin(skinById('ninja')); // Not owned: ignored.
    expect(p.selectedSkin, 'floppy');
  });

  test('catalogue has the MVP skins with prices, plus season exclusives', () {
    expect(skins.first.price, 0);
    final shop = skins.where((s) => !s.exclusive).toList();
    expect(shop.where((s) => s.price > 0), hasLength(5));
    for (final s in shop.skip(1)) {
      expect(economy.skinPrices[s.id], isNotNull);
    }
    for (final t in seasonThemes) {
      expect(skinById(t.skin).exclusive, isTrue);
      expect(cosmeticById(t.trail).exclusive, isTrue);
    }
    final p = ProgressStore.memory(economy)..addCoins(10000);
    expect(p.buySkin(skinById('pirate')), isFalse, reason: 'exclusives are never sold');
  });

  test('cosmetics can be bought with coins or gems, equipped, and form a loadout', () {
    final p = ProgressStore.memory(economy);
    expect(p.loadout.rope, 'rope');
    final chain = cosmeticById('chain'), laser = cosmeticById('laser');
    expect(p.buyItem(chain), isFalse, reason: 'no coins yet');
    p.addCoins(chain.coins);
    expect(p.buyItem(chain), isTrue);
    expect(p.coins, 0);
    expect(p.loadout.rope, 'chain', reason: 'buying equips');
    p.addGems(laser.gems);
    expect(p.buyItem(laser), isTrue);
    expect(p.gems, 0);
    p.equip(chain);
    expect(p.loadout.rope, 'chain');
    p.equip(cosmeticById('fire'));
    expect(p.loadout.trail, 'swoosh', reason: 'cannot equip what you do not own');
    expect(p.buyItem(cosmeticById('gold')), isFalse, reason: 'season exclusive');
  });

  test('collections pay their gem bonus once when complete', () {
    final p = ProgressStore.memory(economy);
    final food = collections.firstWhere((c) => c.id == 'food');
    expect(p.claimCollection(food), isFalse);
    p.grantItem('banana');
    p.grantItem('chicken');
    expect(p.collectionComplete(food), isTrue);
    expect(p.claimCollection(food), isTrue);
    expect(p.gems, food.gems);
    expect(p.claimCollection(food), isFalse);
  });

  test('login rewards follow a 7-day calendar and reset after a missed day', () {
    var now = DateTime(2026, 6, 1, 9);
    final p = ProgressStore.memory(economy, clock: () => now);
    expect(p.loginRewardReady, isTrue);
    final first = p.claimLoginReward()!;
    expect(first, economy.loginRewards[0]);
    expect(p.loginRewardReady, isFalse);
    expect(p.claimLoginReward(), isNull);
    for (var d = 2; d <= 8; d++) {
      now = now.add(const Duration(days: 1));
      expect(p.nextLoginDay, (d - 1) % 7 + 1);
      p.claimLoginReward();
    }
    now = now.add(const Duration(days: 2));
    expect(p.nextLoginDay, 1, reason: 'missed a day');
  });

  test('a stuck level can be skipped with gems; it unlocks the next one but earns nothing', () {
    final p = ProgressStore.memory(economy);
    p.recordWin(1, result());
    expect(p.skipLevel(2), isFalse, reason: 'no gems');
    p.addGems(economy.skipGems);
    expect(p.skipLevel(2), isTrue);
    expect(p.isUnlocked(3), isTrue);
    expect(p.record(2).starCount, 0);
    expect(p.totalStars, 3);
    expect(p.gems, 0);
  });

  test('season pass: XP from play, tier rewards, premium track, fresh start each season', () {
    var now = DateTime(2026, 1, 5);
    final p = ProgressStore.memory(economy, clock: () => now);
    expect(p.seasonTier, 0);
    p.recordWin(1, result()); // 3 new stars.
    expect(p.seasonXp, Season.xpForWin(3));
    p.addSeasonXp(Season.xpPerTier * 10);
    expect(p.seasonTier, 10);
    expect(p.canClaimSeason(10, premium: false), isTrue);
    expect(p.canClaimSeason(11, premium: false), isFalse);
    final trail = p.claimSeason(10, premium: false)!;
    expect(trail.item, Season.theme(p.seasonIndex).trail);
    expect(p.owns(trail.item!), isTrue);
    expect(p.claimSeason(10, premium: false), isNull);
    expect(p.canClaimSeason(1, premium: true), isFalse, reason: 'premium locked');
    expect(p.unlockPremiumPass(), isFalse);
    p.addGems(Season.premiumGems);
    expect(p.unlockPremiumPass(), isTrue);
    p.addSeasonXp(Season.xpPerTier * 20);
    final skin = p.claimSeason(Season.tiers, premium: true)!;
    expect(p.ownedSkins, contains(skin.item));
    expect(p.seasonRewardsReady, greaterThan(0));
    // Next season: XP, premium and claims reset; the rewards you got stay.
    now = now.add(const Duration(days: Season.days));
    expect(p.seasonXp, 0);
    expect(p.premiumPass, isFalse);
    expect(p.canClaimSeason(10, premium: false), isFalse);
    expect(p.ownedSkins, contains(skin.item));
  });

  test('interstitials wait for enough wins, progress and time', () {
    var now = DateTime(2026, 6, 1, 9);
    final p = ProgressStore.memory(economy, clock: () => now);
    for (var i = 1; i < economy.interstitialFromLevel; i++) {
      p.recordWin(i, result());
    }
    expect(p.interstitialDue, isFalse, reason: 'new players never see one');
    p.recordWin(economy.interstitialFromLevel, result());
    expect(p.interstitialDue, isTrue);
    p.interstitialShown();
    expect(p.interstitialDue, isFalse);
    for (var i = 0; i < economy.interstitialEvery; i++) {
      p.recordWin(1, result());
    }
    expect(p.interstitialDue, isFalse, reason: 'too soon');
    now = now.add(Duration(seconds: economy.interstitialMinSeconds));
    expect(p.interstitialDue, isTrue);
    p.adsRemoved = true;
    expect(p.interstitialDue, isFalse);
  });

  test('progress survives a save/load round trip', () async {
    SharedPreferences.setMockInitialValues({});
    final p = await ProgressStore.load(economy);
    p.recordWin(1, result());
    p.addCoins(500);
    p.buySkin(skinById('knight'));
    p.setSfxVolume(0.3);
    p.addGems(60);
    p.buyItem(cosmeticById('laser'));
    p.recordDaily(p.today, result());
    p.recordEndless(const EndlessResult(distance: 321, style: 5, coins: 2));
    p.claimLoginReward();
    p.saveGhost('L1', Float32List.fromList([0, 1, 2, 3, 0.5, 2, 3, 4]));
    await Future<void>.delayed(Duration.zero);
    final q = await ProgressStore.load(economy);
    expect(q.gems, p.gems);
    expect(q.loadout.rope, 'laser');
    expect(q.dailyRecord(q.today).completed, isTrue);
    expect(q.endlessBestDistance, 321);
    expect(q.loginRewardReady, isFalse);
    expect(q.seasonXp, p.seasonXp);
    expect(q.ghostFor('L1'), [0, 1, 2, 3, 0.5, 2, 3, 4]);
    expect(q.coins, p.coins);
    expect(q.record(1).starCount, 3);
    expect(q.ownedSkins, contains('knight'));
    expect(q.selectedSkin, 'knight');
    expect(q.sfxVolume, 0.3);
  });
}
