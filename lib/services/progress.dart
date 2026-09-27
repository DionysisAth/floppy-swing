import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/config.dart';
import '../game/game_controller.dart';
import '../game/skins.dart';

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
  ProgressStore._(this._prefs, this.economy);

  /// In-memory store for tests.
  @visibleForTesting
  ProgressStore.memory(this.economy) : _prefs = null;

  static const _key = 'floppy_swing_save_v1';

  static Future<ProgressStore> load(EconomyConfig economy) async {
    final prefs = await SharedPreferences.getInstance();
    final store = ProgressStore._(prefs, economy);
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

  int coins = 0;
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
  /// is finished.
  bool isUnlocked(int id) => id <= 1 || record(id - 1).completed;

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

  // -------------------------------------------------------------- economy

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

  Future<void> reset() async {
    coins = 0;
    levels.clear();
    ownedSkins
      ..clear()
      ..add('floppy');
    selectedSkin = 'floppy';
    levelsSinceAd = 0;
    await _save();
  }
}
