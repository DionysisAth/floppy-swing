/// Season Pass: 7-week themed seasons with a free and a premium reward
/// track, levelled up with XP from playing.
class SeasonTheme {
  const SeasonTheme({required this.name, required this.skin, required this.trail});
  final String name;

  /// Exclusive skin at the top of the premium track.
  final String skin;

  /// Exclusive trail halfway up the free track.
  final String trail;
}

const seasonThemes = [
  SeasonTheme(name: 'Pirate Plunder', skin: 'pirate', trail: 'gold'),
  SeasonTheme(name: 'Robo Rumble', skin: 'robot', trail: 'circuit'),
  SeasonTheme(name: 'Dino Days', skin: 'dino', trail: 'leaves'),
  SeasonTheme(name: 'Wizard Weeks', skin: 'wizard', trail: 'stars'),
];

/// One reward on a track.
class SeasonReward {
  const SeasonReward({this.coins = 0, this.gems = 0, this.item});
  final int coins;
  final int gems;

  /// Skin or cosmetic id.
  final String? item;
}

abstract final class Season {
  static const days = 49;
  static const tiers = 20;
  static const xpPerTier = 100;

  /// Gem price of the premium track (until real-money purchases exist).
  static const premiumGems = 250;

  /// Season number for a [dayNumber].
  static int indexFor(int day) => day ~/ days;

  static SeasonTheme theme(int index) => seasonThemes[index % seasonThemes.length];

  static int daysLeft(int day) => days - day % days;

  /// Reward for reaching [tier] (1-based) on the free or premium track.
  static SeasonReward reward(int index, int tier, {required bool premium}) {
    final theme = Season.theme(index);
    if (premium) {
      if (tier == tiers) return SeasonReward(item: theme.skin);
      if (tier == 10) return const SeasonReward(gems: 25);
      if (tier % 5 == 0) return const SeasonReward(gems: 15);
      return SeasonReward(coins: 100 + 20 * tier);
    }
    if (tier == 10) return SeasonReward(item: theme.trail);
    if (tier == tiers) return const SeasonReward(gems: 15);
    if (tier % 5 == 0) return const SeasonReward(gems: 5);
    return SeasonReward(coins: 40 + 10 * tier);
  }

  /// XP for playing, by activity.
  static int xpForWin(int newStars) => 20 + 10 * newStars;
  static const xpDailyFirstClear = 60;
  static const xpDailyReplay = 10;
  static const xpLogin = 20;
  static int xpForEndless(int distance) => (distance ~/ 10).clamp(0, 60);
}
