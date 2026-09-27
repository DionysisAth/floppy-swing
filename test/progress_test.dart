import 'package:floppy_swing/game/game_controller.dart';
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

  test('catalogue has the MVP skins with increasing prices', () {
    expect(skins.first.price, 0);
    expect(skins.where((s) => s.price > 0), hasLength(5));
    for (var i = 1; i < skins.length; i++) {
      expect(economy.skinPrices[skins[i].id], isNotNull);
    }
  });

  test('progress survives a save/load round trip', () async {
    SharedPreferences.setMockInitialValues({});
    final p = await ProgressStore.load(economy);
    p.recordWin(1, result());
    p.addCoins(500);
    p.buySkin(skinById('knight'));
    p.setSfxVolume(0.3);
    await Future<void>.delayed(Duration.zero);
    final q = await ProgressStore.load(economy);
    expect(q.coins, p.coins);
    expect(q.record(1).starCount, 3);
    expect(q.ownedSkins, contains('knight'));
    expect(q.selectedSkin, 'knight');
    expect(q.sfxVolume, 0.3);
  });
}
