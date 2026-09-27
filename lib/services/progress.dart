import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/config.dart';
import '../game/game_controller.dart';
import '../game/skins.dart';
import '../game/worlds.dart';

class LevelRecord {
  LevelRecord({this.stars = 0, this.bestTime, this.bestStyle = 0});

  factory LevelRecord.fromJson(Map<String, dynamic> m) => LevelRecord(
    stars: (m['stars'] as num?)?.toInt() ?? 0,
    bestTime: (m['bestTime'] as num?)?.toDouble(),
    bestStyle: (m['bestStyle'] as num?)?.toInt() ?? 0,
  );

  /// Bit mask of earned stars (see [RunResult.starMask]).
  int stars;
  double? bestTime;
  int bestStyle;

  bool get completed => stars & 1 == 1;
  int get starCount => (stars & 1) + ((stars >> 1) & 1) + ((stars >> 2) & 1);

  Map<String, dynamic> toJson() => {
    'stars': stars,
    if (bestTime != null) 'bestTime': bestTime,
    'bestStyle': bestStyle,
  };
}

/// Days since 1 Jan 2026 in local time: the Daily Challenge and login
/// reward calendar.
int dayNumber(DateTime t) => DateTime.utc(t.year, t.month, t.day).difference(DateTime.utc(2026)).inDays;

/// Best Daily Challenge result for one day.
class DailyRecord {
  DailyRecord({this.stars = 0, this.bestTime});

  factory DailyRecord.fromJson(Map<String, dynamic> m) => DailyRecord(
    stars: (m['stars'] as num?)?.toInt() ?? 0,
    bestTime: (m['bestTime'] as num?)?.toDouble(),
  );

  int stars;
  double? bestTime;

  bool get completed => stars & 1 == 1;
  int get starCount => (stars & 1) + ((stars >> 1) & 1) + ((stars >> 2) & 1);

  Map<String, dynamic> toJson() => {'stars': stars, 'bestTime': ?bestTime};
}

/// What an Endless run or a Daily Challenge clear paid out.
class ModeReward {
  const ModeReward({this.coins = 0, this.gems = 0, this.newBest = false, this.streakBonus = false});
  final int coins;
  final int gems;
  final bool newBest;
  final bool streakBonus;
}

/// What a finished level paid out.
class LevelReward {
  const LevelReward({
    required this.pickups,
    required this.completion,
    required this.newStars,
    required this.starBonus,
  });

  final int pickups;
  final int completion;
  final int newStars;
  final int starBonus;

  int get total => pickups + completion + starBonus;
}

/// Everything saved on the device: coins, level stars, skins and settings.
///
/// Stored as one JSON blob in shared preferences. Cloud save can later sync
/// the same blob.
class ProgressStore extends ChangeNotifier {
  ProgressStore._(this._prefs, this.economy, this.clock);

  /// In-memory store for tests.
  @visibleForTesting
  ProgressStore.memory(this.economy, {this.clock = DateTime.now}) : _prefs = null;

  static const _key = 'floppy_swing_save_v1';

  static Future<ProgressStore> load(EconomyConfig economy) async {
    final prefs = await SharedPreferences.getInstance();
    final store = ProgressStore._(prefs, economy, DateTime.now);
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        store._fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Corrupt save ignored: $e');
      }
    }
    return store;
  }

  final SharedPreferences? _prefs;
  final EconomyConfig economy;

  /// Wall clock (injectable for tests).
  final DateTime Function() clock;

  int get today => dayNumber(clock());

  int coins = 0;

  /// Premium currency. Earned in small amounts for now; real-money packs
  /// come with the online/store milestone.
  int gems = 0;

  int endlessBest = 0;
  int endlessBestDistance = 0;

  /// Daily Challenge results by [dayNumber] (only recent days are kept).
  final Map<int, DailyRecord> dailies = {};

  /// Consecutive days with a Daily Challenge clear, ending at [lastDailyDay].
  int dailyStreak = 0;
  int lastDailyDay = -1;
  final Map<int, LevelRecord> levels = {};
  final Set<String> ownedSkins = {'floppy'};
  String selectedSkin = 'floppy';
  double musicVolume = 0.6;
  double sfxVolume = 1.0;
  bool haptics = true;

  /// Levels finished since the last interstitial-eligible moment. Reserved
  /// for when interstitials are added (never shown right after a fail).
  int levelsSinceAd = 0;

  void _fromJson(Map<String, dynamic> m) {
    coins = (m['coins'] as num?)?.toInt() ?? 0;
    gems = (m['gems'] as num?)?.toInt() ?? 0;
    endlessBest = (m['endlessBest'] as num?)?.toInt() ?? 0;
    endlessBestDistance = (m['endlessBestDistance'] as num?)?.toInt() ?? 0;
    for (final e in ((m['dailies'] as Map<String, dynamic>?) ?? {}).entries) {
      dailies[int.parse(e.key)] = DailyRecord.fromJson(e.value as Map<String, dynamic>);
    }
    dailyStreak = (m['dailyStreak'] as num?)?.toInt() ?? 0;
    lastDailyDay = (m['lastDailyDay'] as num?)?.toInt() ?? -1;
    for (final e in ((m['levels'] as Map<String, dynamic>?) ?? {}).entries) {
      levels[int.parse(e.key)] = LevelRecord.fromJson(e.value as Map<String, dynamic>);
    }
    ownedSkins.addAll(((m['ownedSkins'] as List?) ?? const []).cast<String>());
    selectedSkin = (m['selectedSkin'] as String?) ?? 'floppy';
    if (!ownedSkins.contains(selectedSkin)) selectedSkin = 'floppy';
    musicVolume = (m['musicVolume'] as num?)?.toDouble() ?? 0.6;
    sfxVolume = (m['sfxVolume'] as num?)?.toDouble() ?? 1.0;
    haptics = (m['haptics'] as bool?) ?? true;
    levelsSinceAd = (m['levelsSinceAd'] as num?)?.toInt() ?? 0;
  }

  Map<String, dynamic> toJson() => {
    'coins': coins,
    'gems': gems,
    'endlessBest': endlessBest,
    'endlessBestDistance': endlessBestDistance,
    'dailies': {for (final e in dailies.entries) '${e.key}': e.value.toJson()},
    'dailyStreak': dailyStreak,
    'lastDailyDay': lastDailyDay,
    'levels': {for (final e in levels.entries) '${e.key}': e.value.toJson()},
    'ownedSkins': ownedSkins.toList(),
    'selectedSkin': selectedSkin,
    'musicVolume': musicVolume,
    'sfxVolume': sfxVolume,
    'haptics': haptics,
    'levelsSinceAd': levelsSinceAd,
  };

  Future<void> _save() async {
    notifyListeners();
    await _prefs?.setString(_key, jsonEncode(toJson()));
  }

  // --------------------------------------------------------------- levels

  LevelRecord record(int id) => levels[id] ?? LevelRecord();

  /// Level 1 is always open; every other level opens when the previous one
  /// is finished, and the first level of a world also needs its world open.
  bool isUnlocked(int id) {
    if (id <= 1) return true;
    if (!record(id - 1).completed) return false;
    return isWorldUnlocked(WorldInfo.ofLevel(id));
  }

  /// Whether the player has collected enough stars for world [n].
  bool isWorldUnlocked(int n) => totalStars >= WorldInfo.byNumber(n).starsNeeded;

  /// Stars in world [n].
  int worldStars(int n) {
    final w = WorldInfo.byNumber(n);
    var total = 0;
    for (var id = w.firstLevel; id <= w.lastLevel; id++) {
      total += record(id).starCount;
    }
    return total;
  }

  int get totalStars => levels.values.fold(0, (s, r) => s + r.starCount);

  /// Applies a finished run: best records, star bonuses and coins.
  LevelReward recordWin(int levelId, RunResult r) {
    final rec = levels.putIfAbsent(levelId, LevelRecord.new);
    final before = rec.starCount;
    rec.stars |= r.starMask;
    if (rec.bestTime == null || r.time < rec.bestTime!) rec.bestTime = r.time;
    if (r.style > rec.bestStyle) rec.bestStyle = r.style;
    final newStars = rec.starCount - before;
    final reward = LevelReward(
      pickups: r.coins * economy.coinValue,
      completion: economy.levelCompleteReward,
      newStars: newStars,
      starBonus: newStars * economy.starReward,
    );
    coins += reward.total;
    levelsSinceAd++;
    _save();
    return reward;
  }

  // ---------------------------------------------------------------- modes

  /// Pays out an Endless run and records a new best.
  ModeReward recordEndless(EndlessResult r) {
    final newBest = r.score > endlessBest;
    if (newBest) endlessBest = r.score;
    if (r.distance > endlessBestDistance) endlessBestDistance = r.distance;
    final earned = r.coins * economy.coinValue + r.distance ~/ economy.endlessMetresPerCoin;
    coins += earned;
    _save();
    return ModeReward(coins: earned, newBest: newBest);
  }

  DailyRecord dailyRecord(int day) => dailies[day] ?? DailyRecord();

  /// The streak as shown today: broken if yesterday was missed.
  int get currentDailyStreak => lastDailyDay >= today - 1 ? dailyStreak : 0;

  /// Records a Daily Challenge clear on [day]. The first clear of the day
  /// pays coins and gems, and keeps the streak going.
  ModeReward recordDaily(int day, RunResult r) {
    final rec = dailies.putIfAbsent(day, DailyRecord.new);
    final first = !rec.completed;
    final newBest = rec.bestTime == null || r.time < rec.bestTime!;
    rec.stars |= r.starMask;
    if (newBest) rec.bestTime = r.time;
    var earned = r.coins * economy.coinValue;
    var gemsEarned = 0;
    var streakBonus = false;
    if (first) {
      dailyStreak = lastDailyDay == day - 1 ? dailyStreak + 1 : 1;
      lastDailyDay = day;
      earned += economy.dailyCoins;
      gemsEarned = economy.dailyGems;
      if (dailyStreak % 7 == 0) {
        gemsEarned += economy.dailyStreakGems;
        streakBonus = true;
      }
    }
    coins += earned;
    gems += gemsEarned;
    // Keep a month of history.
    dailies.removeWhere((d, _) => d < day - 30);
    _save();
    return ModeReward(coins: earned, gems: gemsEarned, newBest: newBest && !first, streakBonus: streakBonus);
  }

  // -------------------------------------------------------------- economy

  void addGems(int amount) {
    gems += amount;
    _save();
  }

  bool spendGems(int amount) {
    if (gems < amount) return false;
    gems -= amount;
    _save();
    return true;
  }

  void addCoins(int amount) {
    coins += amount;
    _save();
  }

  bool spend(int amount) {
    if (coins < amount) return false;
    coins -= amount;
    _save();
    return true;
  }

  int priceOf(Skin skin) => economy.skinPrices[skin.id] ?? skin.price;

  bool buySkin(Skin skin) {
    if (ownedSkins.contains(skin.id)) return true;
    if (!spend(priceOf(skin))) return false;
    ownedSkins.add(skin.id);
    selectedSkin = skin.id;
    _save();
    return true;
  }

  void selectSkin(Skin skin) {
    if (!ownedSkins.contains(skin.id)) return;
    selectedSkin = skin.id;
    _save();
  }

  // ------------------------------------------------------------- settings

  void setMusicVolume(double v) {
    musicVolume = v;
    _save();
  }

  void setSfxVolume(double v) {
    sfxVolume = v;
    _save();
  }

  void setHaptics(bool v) {
    haptics = v;
    _save();
  }

  /// Wipes progress, keeping settings.
  Future<void> reset() async {
    levels.clear();
    dailies.clear();
    ownedSkins
      ..clear()
      ..add('floppy');
    _fromJson({'musicVolume': musicVolume, 'sfxVolume': sfxVolume, 'haptics': haptics});
    await _save();
  }
}
