import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/config.dart';
import '../game/cosmetics.dart';
import '../game/game_controller.dart';
import '../game/season.dart';
import '../game/skins.dart';
import '../game/worlds.dart';

class LevelRecord {
  LevelRecord({
    this.stars = 0,
    this.bestTime,
    this.bestStyle = 0,
    this.skipped = false,
  });

  factory LevelRecord.fromJson(Map<String, dynamic> m) => LevelRecord(
    stars: (m['stars'] as num?)?.toInt() ?? 0,
    bestTime: (m['bestTime'] as num?)?.toDouble(),
    bestStyle: (m['bestStyle'] as num?)?.toInt() ?? 0,
    skipped: (m['skipped'] as bool?) ?? false,
  );

  /// Bit mask of earned stars (see [RunResult.starMask]).
  int stars;
  double? bestTime;
  int bestStyle;

  /// Skipped with gems: counts as done for unlocking, earns no stars.
  bool skipped;

  bool get completed => stars & 1 == 1 || skipped;
  int get starCount => (stars & 1) + ((stars >> 1) & 1) + ((stars >> 2) & 1);

  Map<String, dynamic> toJson() => {
    'stars': stars,
    if (bestTime != null) 'bestTime': bestTime,
    'bestStyle': bestStyle,
    if (skipped) 'skipped': true,
  };
}

/// Days since 1 Jan 2026 in local time: the Daily Challenge and login
/// reward calendar.
int dayNumber(DateTime t) =>
    DateTime.utc(t.year, t.month, t.day).difference(DateTime.utc(2026)).inDays;

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
  const ModeReward({
    this.coins = 0,
    this.gems = 0,
    this.newBest = false,
    this.streakBonus = false,
  });
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
  ProgressStore.memory(this.economy, {this.clock = DateTime.now})
    : _prefs = null;

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

  /// Login calendar: day of the streak (1-based) and the last claim.
  int loginStreak = 0;
  int lastLoginDay = -1;

  /// Season Pass state for season [_seasonIndex]; reset when a new season
  /// starts.
  int _seasonIndex = -1;
  int _seasonXp = 0;
  bool _premiumPass = false;
  final Set<int> _claimedFree = {};
  final Set<int> _claimedPremium = {};
  final Map<int, LevelRecord> levels = {};
  final Set<String> ownedSkins = {'floppy'};
  String selectedSkin = 'floppy';

  /// Owned ropes, trails, fail effects and dances (free ones always count).
  final Set<String> ownedItems = {};

  /// Equipped cosmetic id per [CosmeticKind] name.
  final Map<String, String> equipped = {};

  /// Collections whose gem bonus has been claimed.
  final Set<String> claimedCollections = {};
  double musicVolume = 0.6;
  double sfxVolume = 1.0;
  bool haptics = true;

  /// Levels finished since the last interstitial.
  int levelsSinceAd = 0;

  /// Set by a future "Remove ads" purchase: no interstitials at all.
  bool adsRemoved = false;

  DateTime? _lastInterstitial;

  void _fromJson(Map<String, dynamic> m) {
    coins = (m['coins'] as num?)?.toInt() ?? 0;
    gems = (m['gems'] as num?)?.toInt() ?? 0;
    endlessBest = (m['endlessBest'] as num?)?.toInt() ?? 0;
    endlessBestDistance = (m['endlessBestDistance'] as num?)?.toInt() ?? 0;
    for (final e in ((m['dailies'] as Map<String, dynamic>?) ?? {}).entries) {
      dailies[int.parse(e.key)] = DailyRecord.fromJson(
        e.value as Map<String, dynamic>,
      );
    }
    dailyStreak = (m['dailyStreak'] as num?)?.toInt() ?? 0;
    lastDailyDay = (m['lastDailyDay'] as num?)?.toInt() ?? -1;
    loginStreak = (m['loginStreak'] as num?)?.toInt() ?? 0;
    lastLoginDay = (m['lastLoginDay'] as num?)?.toInt() ?? -1;
    _seasonIndex = (m['seasonIndex'] as num?)?.toInt() ?? -1;
    _seasonXp = (m['seasonXp'] as num?)?.toInt() ?? 0;
    _premiumPass = (m['premiumPass'] as bool?) ?? false;
    _claimedFree
      ..clear()
      ..addAll(
        ((m['claimedFree'] as List?) ?? const []).cast<num>().map(
          (n) => n.toInt(),
        ),
      );
    _claimedPremium
      ..clear()
      ..addAll(
        ((m['claimedPremium'] as List?) ?? const []).cast<num>().map(
          (n) => n.toInt(),
        ),
      );
    for (final e in ((m['levels'] as Map<String, dynamic>?) ?? {}).entries) {
      levels[int.parse(e.key)] = LevelRecord.fromJson(
        e.value as Map<String, dynamic>,
      );
    }
    ownedSkins.addAll(((m['ownedSkins'] as List?) ?? const []).cast<String>());
    ownedItems.addAll(((m['ownedItems'] as List?) ?? const []).cast<String>());
    equipped.addAll(
      ((m['equipped'] as Map<String, dynamic>?) ?? const {})
          .cast<String, String>(),
    );
    claimedCollections.addAll(
      ((m['claimedCollections'] as List?) ?? const []).cast<String>(),
    );
    selectedSkin = (m['selectedSkin'] as String?) ?? 'floppy';
    if (!ownedSkins.contains(selectedSkin)) selectedSkin = 'floppy';
    musicVolume = (m['musicVolume'] as num?)?.toDouble() ?? 0.6;
    sfxVolume = (m['sfxVolume'] as num?)?.toDouble() ?? 1.0;
    haptics = (m['haptics'] as bool?) ?? true;
    levelsSinceAd = (m['levelsSinceAd'] as num?)?.toInt() ?? 0;
    adsRemoved = (m['adsRemoved'] as bool?) ?? false;
  }

  Map<String, dynamic> toJson() => {
    'coins': coins,
    'gems': gems,
    'endlessBest': endlessBest,
    'endlessBestDistance': endlessBestDistance,
    'dailies': {for (final e in dailies.entries) '${e.key}': e.value.toJson()},
    'dailyStreak': dailyStreak,
    'lastDailyDay': lastDailyDay,
    'loginStreak': loginStreak,
    'lastLoginDay': lastLoginDay,
    'seasonIndex': _seasonIndex,
    'seasonXp': _seasonXp,
    'premiumPass': _premiumPass,
    'claimedFree': _claimedFree.toList(),
    'claimedPremium': _claimedPremium.toList(),
    'levels': {for (final e in levels.entries) '${e.key}': e.value.toJson()},
    'ownedSkins': ownedSkins.toList(),
    'ownedItems': ownedItems.toList(),
    'equipped': equipped,
    'claimedCollections': claimedCollections.toList(),
    'selectedSkin': selectedSkin,
    'musicVolume': musicVolume,
    'sfxVolume': sfxVolume,
    'haptics': haptics,
    'levelsSinceAd': levelsSinceAd,
    'adsRemoved': adsRemoved,
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
  bool isWorldUnlocked(int n) =>
      totalStars >= WorldInfo.byNumber(n).starsNeeded;

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
    _syncSeason();
    _seasonXp += Season.xpForWin(newStars);
    _save();
    return reward;
  }

  // ---------------------------------------------------------------- modes

  /// Pays out an Endless run and records a new best.
  ModeReward recordEndless(EndlessResult r) {
    final newBest = r.score > endlessBest;
    if (newBest) endlessBest = r.score;
    if (r.distance > endlessBestDistance) endlessBestDistance = r.distance;
    final earned =
        r.coins * economy.coinValue +
        r.distance ~/ economy.endlessMetresPerCoin;
    coins += earned;
    _syncSeason();
    _seasonXp += Season.xpForEndless(r.distance);
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
    _syncSeason();
    _seasonXp += first ? Season.xpDailyFirstClear : Season.xpDailyReplay;
    // Keep a month of history.
    for (final old in dailies.keys.where((d) => d < day - 30).toList()) {
      dailies.remove(old);
      _ghosts.remove('D$old');
      unawaited(_prefs?.remove('ghost_D$old'));
    }
    _save();
    return ModeReward(
      coins: earned,
      gems: gemsEarned,
      newBest: newBest && !first,
      streakBonus: streakBonus,
    );
  }

  // ----------------------------------------------------------- season pass

  int get seasonIndex => Season.indexFor(today);

  /// Starts afresh when the calendar has moved into a new season.
  void _syncSeason() {
    if (_seasonIndex == seasonIndex) return;
    _seasonIndex = seasonIndex;
    _seasonXp = 0;
    _premiumPass = false;
    _claimedFree.clear();
    _claimedPremium.clear();
  }

  int get seasonXp {
    _syncSeason();
    return _seasonXp;
  }

  bool get premiumPass {
    _syncSeason();
    return _premiumPass;
  }

  /// Tiers reached this season (0..[Season.tiers]).
  int get seasonTier => (seasonXp ~/ Season.xpPerTier).clamp(0, Season.tiers);

  bool seasonClaimed(int tier, {required bool premium}) {
    _syncSeason();
    return (premium ? _claimedPremium : _claimedFree).contains(tier);
  }

  bool canClaimSeason(int tier, {required bool premium}) =>
      tier <= seasonTier &&
      (!premium || premiumPass) &&
      !seasonClaimed(tier, premium: premium);

  /// Number of rewards waiting to be claimed (for the menu badge).
  int get seasonRewardsReady => [
    for (var t = 1; t <= Season.tiers; t++) ...[
      canClaimSeason(t, premium: false),
      canClaimSeason(t, premium: true),
    ],
  ].where((ready) => ready).length;

  void addSeasonXp(int xp) {
    _syncSeason();
    _seasonXp += xp;
    _save();
  }

  SeasonReward? claimSeason(int tier, {required bool premium}) {
    if (!canClaimSeason(tier, premium: premium)) return null;
    final r = Season.reward(seasonIndex, tier, premium: premium);
    (premium ? _claimedPremium : _claimedFree).add(tier);
    coins += r.coins;
    gems += r.gems;
    final item = r.item;
    if (item != null) grantItem(item);
    _save();
    return r;
  }

  bool unlockPremiumPass() {
    if (premiumPass || !spendGems(Season.premiumGems)) return false;
    _premiumPass = true;
    _save();
    return true;
  }

  // --------------------------------------------------------- login reward

  /// Whether today's login reward is waiting to be claimed.
  bool get loginRewardReady =>
      lastLoginDay != today && economy.loginRewards.isNotEmpty;

  /// Streak day (1-based) today's claim would be.
  int get nextLoginDay => lastLoginDay == today - 1
      ? loginStreak % economy.loginRewards.length + 1
      : 1;

  /// Claims today's login reward, returning it (or null if already claimed).
  ({int coins, int gems})? claimLoginReward() {
    if (!loginRewardReady) return null;
    loginStreak = nextLoginDay;
    lastLoginDay = today;
    final r = economy.loginRewards[loginStreak - 1];
    coins += r.coins;
    gems += r.gems;
    _syncSeason();
    _seasonXp += Season.xpLogin;
    _save();
    return r;
  }

  // ---------------------------------------------------------------- ghosts

  final Map<String, Float32List> _ghosts = {};

  /// The saved best-run ghost for [key] (`L<id>` or `D<day>`).
  Float32List? ghostFor(String key) {
    final cached = _ghosts[key];
    if (cached != null) return cached;
    final raw = _prefs?.getString('ghost_$key');
    if (raw == null) return null;
    try {
      return _ghosts[key] = Uint8List.fromList(base64Decode(raw)).buffer
          .asFloat32List();
    } catch (_) {
      return null;
    }
  }

  /// Ghosts are stored apart from the main save (they're comparatively big).
  void saveGhost(String key, Float32List samples) {
    _ghosts[key] = samples;
    unawaited(
      _prefs?.setString(
        'ghost_$key',
        base64Encode(samples.buffer.asUint8List()),
      ),
    );
  }

  // --------------------------------------------------------- interstitials

  /// Whether to show an interstitial now. Only asked when leaving a won
  /// level, so an ad never follows a fail.
  bool get interstitialDue {
    if (adsRemoved || levelsSinceAd < economy.interstitialEvery) return false;
    if (!record(economy.interstitialFromLevel).completed) return false;
    final last = _lastInterstitial;
    return last == null ||
        clock().difference(last).inSeconds >= economy.interstitialMinSeconds;
  }

  void interstitialShown() {
    levelsSinceAd = 0;
    _lastInterstitial = clock();
    _save();
  }

  // ------------------------------------------------------- skips, revives

  /// Skips a campaign level for gems. It then counts as done (the next one
  /// unlocks) but earns nothing.
  bool skipLevel(int id) {
    if (record(id).completed || !spendGems(economy.skipGems)) return false;
    levels.putIfAbsent(id, LevelRecord.new).skipped = true;
    _save();
    return true;
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
    if (skin.exclusive) return false;
    if (!spend(priceOf(skin))) return false;
    ownedSkins.add(skin.id);
    selectedSkin = skin.id;
    _save();
    return true;
  }

  // ------------------------------------------------------------ cosmetics

  bool ownsItem(Cosmetic c) => c.free || ownedItems.contains(c.id);

  /// Whether a skin or cosmetic id is owned (for collections).
  bool owns(String id) {
    if (skins.any((s) => s.id == id)) return ownedSkins.contains(id);
    final c = cosmetics.where((c) => c.id == id).firstOrNull;
    return c != null && ownsItem(c);
  }

  bool canAfford(Cosmetic c) => c.gems > 0 ? gems >= c.gems : coins >= c.coins;

  /// Buys and equips [c] with coins or gems. Exclusives can't be bought.
  bool buyItem(Cosmetic c) {
    if (ownsItem(c)) return true;
    if (c.exclusive || !canAfford(c)) return false;
    if (c.gems > 0) {
      gems -= c.gems;
    } else {
      coins -= c.coins;
    }
    ownedItems.add(c.id);
    equipped[c.kind.name] = c.id;
    _save();
    return true;
  }

  /// Gives an item for free (Season Pass rewards).
  void grantItem(String id) {
    if (skins.any((s) => s.id == id)) {
      ownedSkins.add(id);
    } else {
      ownedItems.add(id);
    }
    _save();
  }

  void equip(Cosmetic c) {
    if (!ownsItem(c)) return;
    equipped[c.kind.name] = c.id;
    _save();
  }

  String equippedId(CosmeticKind kind) {
    final id = equipped[kind.name];
    return id != null && ownsItem(cosmeticById(id))
        ? id
        : defaultCosmetic(kind);
  }

  Loadout get loadout => Loadout(
    rope: equippedId(CosmeticKind.rope),
    trail: equippedId(CosmeticKind.trail),
    failEffect: equippedId(CosmeticKind.failEffect),
    dance: equippedId(CosmeticKind.dance),
  );

  bool collectionComplete(Collection c) => c.items.every(owns);

  /// Claims a completed collection's gem bonus (once).
  bool claimCollection(Collection c) {
    if (claimedCollections.contains(c.id) || !collectionComplete(c)) {
      return false;
    }
    claimedCollections.add(c.id);
    gems += c.gems;
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
    ownedItems.clear();
    equipped.clear();
    claimedCollections.clear();
    ownedSkins
      ..clear()
      ..add('floppy');
    _fromJson({
      'musicVolume': musicVolume,
      'sfxVolume': sfxVolume,
      'haptics': haptics,
    });
    await _save();
  }
}
