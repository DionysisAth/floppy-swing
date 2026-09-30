import 'package:floppy_swing/game/season.dart';
import 'package:floppy_swing/game/store_products.dart';
import 'package:floppy_swing/services/progress.dart';
import 'package:floppy_swing/services/purchase_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  final economy = loadEconomy();

  test('product ids are unique and valid for both stores', () {
    final ids = storeProducts.map((p) => p.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
    for (final id in ids) {
      expect(RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(id), isTrue, reason: id);
      expect(storeProductById(id), isNotNull);
    }
  });

  test('a gem pack pays out once per transaction', () {
    final p = ProgressStore.memory(economy);
    final pack = gemPacks.first;
    expect(p.deliverPurchase(pack, 'GPA.1'), isTrue);
    expect(p.gems, pack.gems);
    expect(p.deliverPurchase(pack, 'GPA.1'), isFalse, reason: 'redelivered by the store');
    expect(p.gems, pack.gems);
    expect(p.deliverPurchase(pack, 'GPA.2'), isTrue, reason: 'bought again');
    expect(p.gems, pack.gems * 2);
    expect(p.canBuyProduct(pack), isTrue);
  });

  test('once-only products: No Ads and the Starter Pack', () {
    final p = ProgressStore.memory(economy);
    expect(p.deliverPurchase(removeAds, 'a'), isTrue);
    expect(p.adsRemoved, isTrue);
    expect(p.interstitialDue, isFalse);
    expect(p.canBuyProduct(removeAds), isFalse);
    expect(p.deliverPurchase(starterPack, 'b'), isTrue);
    expect(p.gems, starterPack.gems);
    expect(p.coins, starterPack.coins);
    expect(p.ownedItems, containsAll(starterPack.items));
    // Restoring on the same device changes nothing.
    expect(p.deliverPurchase(starterPack, 'b-restored'), isFalse);
    expect(p.gems, starterPack.gems);
  });

  test('the Premium Pass can be bought with money', () {
    final p = ProgressStore.memory(economy);
    expect(p.premiumPass, isFalse);
    expect(p.deliverPurchase(seasonPassProduct, 't1'), isTrue);
    expect(p.premiumPass, isTrue);
    expect(p.canBuyProduct(seasonPassProduct), isFalse);
    // A second one in the same season is refunded as gems.
    p.deliverPurchase(seasonPassProduct, 't2');
    expect(p.gems, Season.premiumGems);
  });

  test('a reset keeps what was bought; cloud saves carry purchases', () async {
    final p = ProgressStore.memory(economy);
    p.deliverPurchase(removeAds, 'a');
    p.deliverPurchase(starterPack, 'b');
    await p.reset();
    expect(p.adsRemoved, isTrue);
    expect(p.ownedItems, containsAll(starterPack.items));
    expect(p.ownsProduct(starterPack), isTrue);
    expect(p.deliverPurchase(gemPacks.first, 'a'), isFalse, reason: 'transaction ids kept');

    final other = ProgressStore.memory(economy)..mergeFrom(p.toJson());
    expect(other.adsRemoved, isTrue);
    expect(other.ownsProduct(starterPack), isTrue);
    expect(other.ownedItems, containsAll(starterPack.items));
  });

  test('the debug store grants instantly and says thanks', () async {
    final p = ProgressStore.memory(economy);
    final store = NoPurchaseService(p, instant: true);
    await store.buy(gemPacks[1]);
    expect(p.gems, gemPacks[1].gems);
    expect(store.takeMessage(), contains('Thanks'));
    expect(store.takeMessage(), isNull);
    expect(NoPurchaseService(p).available, isFalse);
  });
}
