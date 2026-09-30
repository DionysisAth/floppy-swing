/// Real-money products. The ids must match the products created in Play
/// Console and App Store Connect (see docs/RELEASING.md); prices come from
/// the store, and [fallbackPrice] is only shown if the store can't be
/// reached.
enum ProductType {
  /// Can be bought again and again (gem packs, the Season Pass).
  consumable,

  /// Bought once, kept forever and restorable (Starter Pack, Remove Ads).
  nonConsumable,
}

class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.name,
    required this.tagline,
    required this.type,
    required this.fallbackPrice,
    this.gems = 0,
    this.coins = 0,
    this.items = const [],
    this.removesAds = false,
    this.premiumPass = false,
    this.bestValue = false,
  });

  final String id;
  final String name;
  final String tagline;
  final ProductType type;
  final String fallbackPrice;
  final int gems;
  final int coins;

  /// Skins or cosmetics granted.
  final List<String> items;

  /// No more interstitials (rewarded ads stay, they're optional).
  final bool removesAds;

  /// Unlocks the current season's premium track.
  final bool premiumPass;

  /// Highlighted in the shop.
  final bool bestValue;

  bool get consumable => type == ProductType.consumable;
}

const starterPack = StoreProduct(
  id: 'starter_pack',
  name: 'Starter Pack',
  tagline: '300 gems, 2,500 coins and the Laser rope. Once only!',
  type: ProductType.nonConsumable,
  fallbackPrice: r'$2.99',
  gems: 300,
  coins: 2500,
  items: ['laser'],
);

const removeAds = StoreProduct(
  id: 'remove_ads',
  name: 'No Ads',
  tagline: 'No more ads between levels. Bonus videos stay optional.',
  type: ProductType.nonConsumable,
  fallbackPrice: r'$2.99',
  removesAds: true,
);

const seasonPassProduct = StoreProduct(
  id: 'season_pass',
  name: 'Premium Pass',
  tagline: "This season's premium track.",
  type: ProductType.consumable,
  fallbackPrice: r'$4.99',
  premiumPass: true,
);

const gemPacks = [
  StoreProduct(
    id: 'gems_small',
    name: 'Handful of Gems',
    tagline: '80 gems',
    type: ProductType.consumable,
    fallbackPrice: r'$0.99',
    gems: 80,
  ),
  StoreProduct(
    id: 'gems_medium',
    name: 'Bag of Gems',
    tagline: '450 gems (+12% bonus)',
    type: ProductType.consumable,
    fallbackPrice: r'$4.99',
    gems: 450,
  ),
  StoreProduct(
    id: 'gems_large',
    name: 'Chest of Gems',
    tagline: '1,000 gems (+25% bonus)',
    type: ProductType.consumable,
    fallbackPrice: r'$9.99',
    gems: 1000,
    bestValue: true,
  ),
  StoreProduct(
    id: 'gems_huge',
    name: 'Vault of Gems',
    tagline: '2,200 gems (+37% bonus)',
    type: ProductType.consumable,
    fallbackPrice: r'$19.99',
    gems: 2200,
  ),
];

const storeProducts = [starterPack, removeAds, seasonPassProduct, ...gemPacks];

StoreProduct? storeProductById(String id) {
  for (final p in storeProducts) {
    if (p.id == id) return p;
  }
  return null;
}
