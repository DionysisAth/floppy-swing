import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/widgets.dart';

import '../game/cosmetics.dart';
import '../game/game_words.dart';
import '../game/level.dart';
import '../game/season.dart';
import '../game/simulation.dart' show DeathCause;
import '../game/skins.dart';
import '../game/store_products.dart';
import '../game/worlds.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

/// The languages the game is translated into, with their own names for the
/// language picker. English first: it's the fallback for everything else.
const languageNames = {
  'en': 'English',
  'el': 'Ελληνικά',
  'de': 'Deutsch',
  'es': 'Español',
  'fr': 'Français',
  'id': 'Bahasa Indonesia',
  'it': 'Italiano',
  'pl': 'Polski',
  'pt': 'Português',
  'tr': 'Türkçe',
  'ru': 'Русский',
  'uk': 'Українська',
  'ja': '日本語',
  'ko': '한국어',
  'zh': '中文',
};

/// [AppLocalizations.supportedLocales] with English first, so a phone in a
/// language the game doesn't have gets English (the first one is the
/// fallback).
final appLocales = [for (final code in languageNames.keys) Locale(code)];

/// The language the game shows: the one picked in Settings ([code]), or the
/// phone's first language the game has, or English.
Locale resolveLocale(String? code, [List<Locale>? system]) {
  if (code != null && languageNames.containsKey(code)) return Locale(code);
  return basicLocaleListResolution(system ?? PlatformDispatcher.instance.locales, appLocales);
}

/// Strings for [code] (see [resolveLocale]) where there's no BuildContext,
/// such as notifications.
AppLocalizations stringsFor(String? code) => lookupAppLocalizations(resolveLocale(code));

extension L10nContext on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this);
}

/// Capitals the way [localeName] writes them: Greek drops accents in
/// capitals, Turkish dots its capital i.
String upper(String s, String localeName) {
  final lang = localeName.split(RegExp('[_-]')).first;
  if (lang == 'tr') s = s.replaceAll('i', 'İ');
  if (lang == 'el') {
    const plain = {
      'ά': 'α', 'έ': 'ε', 'ή': 'η', 'ί': 'ι', 'ό': 'ο', 'ύ': 'υ', 'ώ': 'ω', 'ΐ': 'ϊ', 'ΰ': 'ϋ', //
      'Ά': 'Α', 'Έ': 'Ε', 'Ή': 'Η', 'Ί': 'Ι', 'Ό': 'Ο', 'Ύ': 'Υ', 'Ώ': 'Ω',
    };
    s = s.split('').map((c) => plain[c] ?? c).join();
  }
  return s.toUpperCase();
}

extension GameStrings on AppLocalizations {
  String worldName(WorldInfo w) => switch (w.number) {
    1 => world1Name,
    2 => world2Name,
    3 => world3Name,
    4 => world4Name,
    5 => world5Name,
    _ => w.name,
  };

  String worldTagline(WorldInfo w) => switch (w.number) {
    1 => world1Tagline,
    2 => world2Tagline,
    3 => world3Tagline,
    4 => world4Tagline,
    5 => world5Tagline,
    _ => w.tagline,
  };

  String skinName(Skin s) => switch (s.id) {
    'floppy' => skinFloppyName,
    'banana' => skinBananaName,
    'knight' => skinKnightName,
    'astronaut' => skinAstronautName,
    'chicken' => skinChickenName,
    'ninja' => skinNinjaName,
    'pirate' => skinPirateName,
    'robot' => skinRobotName,
    'dino' => skinDinoName,
    'wizard' => skinWizardName,
    'golden' => skinGoldenName,
    _ => s.name,
  };

  String skinTagline(Skin s) => switch (s.id) {
    'floppy' => skinFloppyTagline,
    'banana' => skinBananaTagline,
    'knight' => skinKnightTagline,
    'astronaut' => skinAstronautTagline,
    'chicken' => skinChickenTagline,
    'ninja' => skinNinjaTagline,
    'pirate' => skinPirateTagline,
    'robot' => skinRobotTagline,
    'dino' => skinDinoTagline,
    'wizard' => skinWizardTagline,
    'golden' => skinGoldenTagline,
    _ => s.tagline,
  };

  String itemName(Cosmetic c) => switch (c.id) {
    'rope' => itemRopeName,
    'chain' => itemChainName,
    'spaghetti' => itemSpaghettiName,
    'rainbow' => itemRainbowName,
    'laser' => itemLaserName,
    'swoosh' => itemSwooshName,
    'sparkles' => itemSparklesName,
    'bubbles' => itemBubblesName,
    'fire' => itemFireName,
    'gold' => itemGoldName,
    'circuit' => itemCircuitName,
    'leaves' => itemLeavesName,
    'stars' => itemStarsName,
    'classic' => itemClassicName,
    'squeaky' => itemSqueakyName,
    'confetti' => itemConfettiName,
    'coinpile' => itemCoinpileName,
    'hop' => itemHopName,
    'backflip' => itemBackflipName,
    'spin' => itemSpinName,
    'flail' => itemFlailName,
    _ => c.name,
  };

  String itemTagline(Cosmetic c) => switch (c.id) {
    'rope' => itemRopeTagline,
    'chain' => itemChainTagline,
    'spaghetti' => itemSpaghettiTagline,
    'rainbow' => itemRainbowTagline,
    'laser' => itemLaserTagline,
    'swoosh' => itemSwooshTagline,
    'sparkles' => itemSparklesTagline,
    'bubbles' => itemBubblesTagline,
    'fire' => itemFireTagline,
    'gold' => itemGoldTagline,
    'circuit' => itemCircuitTagline,
    'leaves' => itemLeavesTagline,
    'stars' => itemStarsTagline,
    'classic' => itemClassicTagline,
    'squeaky' => itemSqueakyTagline,
    'confetti' => itemConfettiTagline,
    'coinpile' => itemCoinpileTagline,
    'hop' => itemHopTagline,
    'backflip' => itemBackflipTagline,
    'spin' => itemSpinTagline,
    'flail' => itemFlailTagline,
    _ => c.tagline,
  };

  /// Name of a skin or cosmetic by id.
  String anyItemName(String id) =>
      skins.any((s) => s.id == id) ? skinName(skinById(id)) : itemName(cosmeticById(id));

  String collectionName(Collection c) => switch (c.id) {
    'food' => setFoodName,
    'heroes' => setHeroesName,
    'ropes' => setRopesName,
    'trails' => setTrailsName,
    'fails' => setFailsName,
    'dances' => setDancesName,
    _ => c.name,
  };

  String seasonName(SeasonTheme t) => switch (t.skin) {
    'pirate' => seasonPirateName,
    'robot' => seasonRobotName,
    'dino' => seasonDinoName,
    'wizard' => seasonWizardName,
    _ => t.name,
  };

  String productName(StoreProduct p) => switch (p.id) {
    'starter_pack' => productStarterPackName,
    'remove_ads' => productRemoveAdsName,
    'season_pass' => productSeasonPassName,
    'gems_small' => productGemsSmallName,
    'gems_medium' => productGemsMediumName,
    'gems_large' => productGemsLargeName,
    'gems_huge' => productGemsHugeName,
    _ => p.name,
  };

  String productTagline(StoreProduct p) => switch (p.id) {
    'starter_pack' => productStarterPackTagline,
    'remove_ads' => productRemoveAdsTagline,
    'season_pass' => productSeasonPassTagline,
    'gems_small' => productGemsSmallTagline,
    'gems_medium' => productGemsMediumTagline,
    'gems_large' => productGemsLargeTagline,
    'gems_huge' => productGemsHugeTagline,
    _ => p.tagline,
  };

  /// A campaign level's tutorial hint (null if it has none).
  String? levelHint(Level level) {
    if (level.hint == null) return null;
    return switch (level.id) {
      1 => hintLevel1,
      2 => hintLevel2,
      3 => hintLevel3,
      5 => hintLevel5,
      6 => hintLevel6,
      7 => hintLevel7,
      8 => hintLevel8,
      9 => hintLevel9,
      12 => hintLevel12,
      14 => hintLevel14,
      15 => hintLevel15,
      21 => hintLevel21,
      41 => hintLevel41,
      61 => hintLevel61,
      64 => hintLevel64,
      81 => hintLevel81,
      84 => hintLevel84,
      _ => level.hint,
    };
  }

  /// Jokes shown after a fail, by what got you.
  List<String> failLines(DeathCause cause) => switch (cause) {
    DeathCause.spikes => [failSpikes1, failSpikes2, failSpikes3],
    DeathCause.saw => [failSaw1, failSaw2, failSaw3],
    DeathCause.pit => [failPit1, failPit2, failPit3],
    DeathCause.stuck => [failStuck1, failStuck2, failStuck3],
  };

  GameWords get gameWords => GameWords(
    best: wordBest,
    checkpoint: wordCheckpoint,
    go: wordGo,
    smash: wordSmash,
    kaboom: wordKaboom,
    bonk: wordBonk,
    saw: wordSaw,
    spikes: wordSpikes,
    pit: wordPit,
    stuck: wordStuck,
    confetti: wordConfetti,
    jackpot: wordJackpot,
    squeak: wordSqueak,
    styles: {
      'BIG SWING': styleBigSwing,
      'SMASH': styleSmash,
      'FLIP': styleFlip,
      'HANG TIME': styleHangTime,
      'CLOSE CALL': styleCloseCall,
    },
  );
}
