/// Leaderboard and achievement ids for the platform game services: Google
/// Play Games on Android, Game Center on iOS. Both are free and hosted by
/// Google and Apple, so the game needs no server of its own.
///
/// A platform stays switched off (the app never calls its SDK and hides the
/// buttons) until [PlatformGamesIds.enabled] is true. docs/GAMES_SERVICES.md
/// walks through creating the ids in Play Console and App Store Connect.
library;

/// Achievements: key, title and description. Create them in the consoles
/// with these texts, then copy each console id into the maps below.
const achievementTexts = <String, (String, String)>{
  'first_swing': ('First Swing', 'Clear level 1.'),
  'world_1': ('Park Life', 'Clear every level in World 1.'),
  'world_2': ('Factory Reset', 'Clear every level in World 2.'),
  'world_3': ('City Slicker', 'Clear every level in World 3.'),
  'world_4': ('Head in the Clouds', 'Clear every level in World 4.'),
  'world_5': ('Base Jumper', 'Clear every level in World 5.'),
  'stars_150': ('Star Collector', 'Collect 150 stars.'),
  'stars_300': ('Golden Flop', 'Collect all 300 stars.'),
  'endless_500': ('Long Haul', 'Swing 500 m in one Endless run.'),
  'endless_1500': ('Marathon Flopper', 'Swing 1500 m in one Endless run.'),
  'daily_first': ('Daily Flopper', 'Clear a Daily Challenge.'),
  'daily_streak_7': ('Week of Flops', 'Clear the Daily Challenge 7 days in a row.'),
};

class PlatformGamesIds {
  const PlatformGamesIds({
    required this.enabled,
    required this.daily,
    required this.endless,
    required this.achievements,
  });

  /// Turn on once the ids below (and, on Android, the project id in
  /// android/app/src/main/res/values/games-ids.xml) are real.
  final bool enabled;

  /// Daily Challenge leaderboard: best time today, lower is better.
  /// Android: format "Time", order "Smaller is better" (value in ms).
  /// iOS: recurring daily leaderboard, format "Elapsed time - to the
  /// hundredth of a second", sort "Low to high" (value in hundredths).
  final String daily;

  /// Endless leaderboard: best score, higher is better (plain number).
  final String endless;

  /// Achievement key (see [achievementTexts]) -> console id.
  final Map<String, String> achievements;
}

/// Google Play Games (Android). Play Console makes ids like `CgkI...`.
const playGamesIds = PlatformGamesIds(
  enabled: false,
  daily: '',
  endless: '',
  achievements: {
    'first_swing': '',
    'world_1': '',
    'world_2': '',
    'world_3': '',
    'world_4': '',
    'world_5': '',
    'stars_150': '',
    'stars_300': '',
    'endless_500': '',
    'endless_1500': '',
    'daily_first': '',
    'daily_streak_7': '',
  },
);

/// Game Center (iOS). You pick these ids in App Store Connect; using the
/// suggested ones means nothing here needs to change.
const gameCenterIds = PlatformGamesIds(
  enabled: false,
  daily: 'daily_time',
  endless: 'endless_score',
  achievements: {
    'first_swing': 'first_swing',
    'world_1': 'world_1',
    'world_2': 'world_2',
    'world_3': 'world_3',
    'world_4': 'world_4',
    'world_5': 'world_5',
    'stars_150': 'stars_150',
    'stars_300': 'stars_300',
    'endless_500': 'endless_500',
    'endless_1500': 'endless_1500',
    'daily_first': 'daily_first',
    'daily_streak_7': 'daily_streak_7',
  },
);
