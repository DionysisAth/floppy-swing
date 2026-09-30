/// Cosmetic items other than skins: rope styles, trails, fail effects and
/// victory dances. Everything here is purely visual (no pay-to-win).
enum CosmeticKind {
  rope('Ropes'),
  trail('Trails'),
  failEffect('Fails'),
  dance('Dances');

  const CosmeticKind(this.title);
  final String title;
}

class Cosmetic {
  const Cosmetic({
    required this.id,
    required this.kind,
    required this.name,
    required this.tagline,
    this.coins = 0,
    this.gems = 0,
    this.exclusive = false,
  });

  final String id;
  final CosmeticKind kind;
  final String name;
  final String tagline;

  /// Price in coins, or in [gems] when that is set. Both 0 = free.
  final int coins;
  final int gems;

  /// Only from the Season Pass.
  final bool exclusive;

  bool get free => coins == 0 && gems == 0 && !exclusive;
}

const cosmetics = <Cosmetic>[
  // Ropes.
  Cosmetic(id: 'rope', kind: CosmeticKind.rope, name: 'Trusty Rope', tagline: 'Hemp. Reliable. Beige.'),
  Cosmetic(id: 'chain', kind: CosmeticKind.rope, name: 'Chain', tagline: 'Clink clink clink.', coins: 250),
  Cosmetic(id: 'spaghetti', kind: CosmeticKind.rope, name: 'Spaghetti', tagline: 'Al dente. Mostly.', coins: 300),
  Cosmetic(id: 'rainbow', kind: CosmeticKind.rope, name: 'Rainbow', tagline: 'Taste the swing.', coins: 450),
  Cosmetic(id: 'laser', kind: CosmeticKind.rope, name: 'Laser', tagline: 'Pew pew grapple.', gems: 40),
  // Trails.
  Cosmetic(id: 'swoosh', kind: CosmeticKind.trail, name: 'Swoosh', tagline: 'The classic whoosh.'),
  Cosmetic(id: 'sparkles', kind: CosmeticKind.trail, name: 'Sparkles', tagline: 'Fabulous at any speed.', coins: 300),
  Cosmetic(id: 'bubbles', kind: CosmeticKind.trail, name: 'Bubbles', tagline: 'Blub blub.', coins: 350),
  Cosmetic(id: 'fire', kind: CosmeticKind.trail, name: 'Fire', tagline: 'Too hot to handle.', coins: 450),
  Cosmetic(id: 'gold', kind: CosmeticKind.trail, name: 'Doubloons', tagline: 'Pirate Plunder season.', exclusive: true),
  Cosmetic(id: 'circuit', kind: CosmeticKind.trail, name: 'Circuit', tagline: 'Robo Rumble season.', exclusive: true),
  Cosmetic(id: 'leaves', kind: CosmeticKind.trail, name: 'Jungle Leaves', tagline: 'Dino Days season.', exclusive: true),
  Cosmetic(id: 'stars', kind: CosmeticKind.trail, name: 'Stardust', tagline: 'Wizard Weeks season.', exclusive: true),
  // Fail effects: fails get shared, so these are the fun ones.
  Cosmetic(id: 'classic', kind: CosmeticKind.failEffect, name: 'Kapow', tagline: 'Stars. Lots of stars.'),
  Cosmetic(id: 'squeaky', kind: CosmeticKind.failEffect, name: 'Squeaky Toy', tagline: 'SQUEEEEAK.', coins: 300),
  Cosmetic(id: 'confetti', kind: CosmeticKind.failEffect, name: 'Confetti Party', tagline: 'Failing is a celebration.', coins: 400),
  Cosmetic(id: 'coinpile', kind: CosmeticKind.failEffect, name: 'Jackpot', tagline: 'Burst into a pile of coins.', gems: 30),
  // Victory dances, played when you finish.
  Cosmetic(id: 'hop', kind: CosmeticKind.dance, name: 'Happy Hop', tagline: 'Boing boing boing.'),
  Cosmetic(id: 'backflip', kind: CosmeticKind.dance, name: 'Backflip', tagline: 'Sticks the landing. Sometimes.', coins: 350),
  Cosmetic(id: 'spin', kind: CosmeticKind.dance, name: 'Tornado', tagline: 'Wheeeeee!', coins: 400),
  Cosmetic(id: 'flail', kind: CosmeticKind.dance, name: 'Wacky Flail', tagline: 'Inflatable tube man energy.', gems: 25),
];

Cosmetic cosmeticById(String id) => cosmetics.firstWhere((c) => c.id == id, orElse: () => cosmetics.first);

/// The default (free) item of each kind.
String defaultCosmetic(CosmeticKind kind) => cosmetics.firstWhere((c) => c.kind == kind).id;

/// Everything the player has equipped besides the skin.
class Loadout {
  const Loadout({
    this.rope = 'rope',
    this.trail = 'swoosh',
    this.failEffect = 'classic',
    this.dance = 'hop',
  });

  final String rope;
  final String trail;
  final String failEffect;
  final String dance;

  String of(CosmeticKind kind) => switch (kind) {
    CosmeticKind.rope => rope,
    CosmeticKind.trail => trail,
    CosmeticKind.failEffect => failEffect,
    CosmeticKind.dance => dance,
  };
}

/// A set of items that pays a gem bonus once all are owned.
class Collection {
  const Collection({required this.id, required this.name, required this.items, required this.gems});
  final String id;
  final String name;

  /// Skin or cosmetic ids.
  final List<String> items;
  final int gems;
}

const collections = <Collection>[
  Collection(id: 'food', name: 'Food Fight', items: ['banana', 'chicken'], gems: 15),
  Collection(id: 'heroes', name: 'Brave Heroes', items: ['knight', 'ninja', 'astronaut'], gems: 30),
  Collection(id: 'ropes', name: 'Rope Collector', items: ['chain', 'spaghetti', 'rainbow', 'laser'], gems: 30),
  Collection(id: 'trails', name: 'Trailblazer', items: ['sparkles', 'bubbles', 'fire'], gems: 20),
  Collection(id: 'fails', name: 'Epic Fails', items: ['squeaky', 'confetti', 'coinpile'], gems: 25),
  Collection(id: 'dances', name: 'Dance Floor', items: ['backflip', 'spin', 'flail'], gems: 25),
];
