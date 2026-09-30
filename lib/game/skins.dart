import 'dart:ui';

/// Extra decoration drawn on top of the basic ragdoll.
enum Accessory { hair, banana, knight, astronaut, chicken, ninja, pirate, robot, dino, wizard, crown }

/// A character skin: colours for each body part plus an accessory.
class Skin {
  const Skin({
    required this.id,
    required this.name,
    required this.price,
    required this.tagline,
    required this.shirt,
    required this.pants,
    required this.skin,
    required this.shoes,
    required this.sleeves,
    required this.accessory,
    this.outline = const Color(0xFF2B1D14),
    this.failSound = 'bonk',
    this.exclusive = false,
  });

  final String id;
  final String name;

  /// Coin price (0 = free). Can be overridden by `economy.json`.
  final int price;
  final String tagline;
  final Color shirt;
  final Color pants;
  final Color skin;
  final Color shoes;
  final Color sleeves;
  final Accessory accessory;
  final Color outline;

  /// Sound played on the fail impact (fails are what get shared!).
  final String failSound;

  /// Only from the Season Pass (never sold for coins).
  final bool exclusive;
}

const skins = <Skin>[
  Skin(
    id: 'floppy',
    name: 'Floppy',
    price: 0,
    tagline: 'The original noodle.',
    shirt: Color(0xFFFF8A3D),
    pants: Color(0xFF3D6DFF),
    skin: Color(0xFFFFD2A8),
    shoes: Color(0xFF3B2A1A),
    sleeves: Color(0xFFFF8A3D),
    accessory: Accessory.hair,
  ),
  Skin(
    id: 'banana',
    name: 'Banana',
    price: 150,
    tagline: 'Slippery when swung.',
    shirt: Color(0xFFFFE135),
    pants: Color(0xFFF5D000),
    skin: Color(0xFFFFE97A),
    shoes: Color(0xFF6B4A1E),
    sleeves: Color(0xFFFFE135),
    accessory: Accessory.banana,
    failSound: 'squeak',
  ),
  Skin(
    id: 'knight',
    name: 'Sir Flops',
    price: 300,
    tagline: 'Heavy armour. Zero grace.',
    shirt: Color(0xFFB8C2CC),
    pants: Color(0xFF8C98A4),
    skin: Color(0xFFD5DDE5),
    shoes: Color(0xFF59636E),
    sleeves: Color(0xFFA7B2BD),
    accessory: Accessory.knight,
    failSound: 'clang',
  ),
  Skin(
    id: 'astronaut',
    name: 'Space Cadet',
    price: 450,
    tagline: 'Gravity is just a suggestion.',
    shirt: Color(0xFFF4F6F8),
    pants: Color(0xFFE3E8ED),
    skin: Color(0xFFFFD2A8),
    shoes: Color(0xFF8795A1),
    sleeves: Color(0xFFF4F6F8),
    accessory: Accessory.astronaut,
    failSound: 'whistle',
  ),
  Skin(
    id: 'chicken',
    name: 'Rubber Chicken',
    price: 600,
    tagline: 'Squeaks on impact. Obviously.',
    shirt: Color(0xFFFFF3C4),
    pants: Color(0xFFFFEAA0),
    skin: Color(0xFFFFF3C4),
    shoes: Color(0xFFFF9F1C),
    sleeves: Color(0xFFFFF3C4),
    accessory: Accessory.chicken,
    failSound: 'squeak',
  ),
  Skin(
    id: 'ninja',
    name: 'Noodle Ninja',
    price: 800,
    tagline: 'Silent. Deadly. Mostly silent.',
    shirt: Color(0xFF2B2D42),
    pants: Color(0xFF22232F),
    skin: Color(0xFF2B2D42),
    shoes: Color(0xFF14151C),
    sleeves: Color(0xFF2B2D42),
    accessory: Accessory.ninja,
    outline: Color(0xFF0B0B10),
  ),
  // Season Pass exclusives.
  Skin(
    id: 'pirate',
    name: 'Captain Flop',
    price: 0,
    tagline: 'Yo ho, oh no.',
    shirt: Color(0xFFF4F1E8),
    pants: Color(0xFF3B3355),
    skin: Color(0xFFE8B98E),
    shoes: Color(0xFF3B2A1A),
    sleeves: Color(0xFFF4F1E8),
    accessory: Accessory.pirate,
    failSound: 'yelp',
    exclusive: true,
  ),
  Skin(
    id: 'robot',
    name: 'Robo-Noodle',
    price: 0,
    tagline: 'Beep. Boop. Bonk.',
    shirt: Color(0xFF9AA8B8),
    pants: Color(0xFF6E7C8C),
    skin: Color(0xFFC9D3DD),
    shoes: Color(0xFF4A5563),
    sleeves: Color(0xFF9AA8B8),
    accessory: Accessory.robot,
    failSound: 'clang',
    exclusive: true,
  ),
  Skin(
    id: 'dino',
    name: 'Dino-Mite',
    price: 0,
    tagline: 'Tiny arms. Big swings.',
    shirt: Color(0xFF6BCB4E),
    pants: Color(0xFF4FA83A),
    skin: Color(0xFF7FD95F),
    shoes: Color(0xFF3E8A2C),
    sleeves: Color(0xFF6BCB4E),
    accessory: Accessory.dino,
    failSound: 'squeak',
    exclusive: true,
  ),
  Skin(
    id: 'wizard',
    name: 'Flopdalf',
    price: 0,
    tagline: 'You shall not... oops.',
    shirt: Color(0xFF6A4BC4),
    pants: Color(0xFF503796),
    skin: Color(0xFFFFD2A8),
    shoes: Color(0xFF3B2A1A),
    sleeves: Color(0xFF6A4BC4),
    accessory: Accessory.wizard,
    failSound: 'whistle',
    exclusive: true,
  ),
  // Unlocked by collecting every star (ProgressStore.goldenStars).
  Skin(
    id: 'golden',
    name: 'Golden Flop',
    price: 0,
    tagline: 'Collect all 300 stars.',
    shirt: Color(0xFFFFC21A),
    pants: Color(0xFFE0A200),
    skin: Color(0xFFFFD86B),
    shoes: Color(0xFFB07A00),
    sleeves: Color(0xFFFFC21A),
    accessory: Accessory.crown,
    failSound: 'win',
    exclusive: true,
  ),
];

Skin skinById(String id) =>
    skins.firstWhere((s) => s.id == id, orElse: () => skins.first);
