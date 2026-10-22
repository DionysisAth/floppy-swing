// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get back => 'Zurück';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get leaderboards => 'Bestenlisten';

  @override
  String get leaderboard => 'Bestenliste';

  @override
  String get achievements => 'Erfolge';

  @override
  String get challengeCode => 'Herausforderungscode';

  @override
  String couldNotSignIn(String service) {
    return 'Anmeldung bei $service fehlgeschlagen.';
  }

  @override
  String get play => 'SPIELEN';

  @override
  String get endless => 'ENDLOS';

  @override
  String endlessBest(int distance) {
    return 'Rekord $distance m';
  }

  @override
  String get endlessPitch => 'Wie weit kommst du?';

  @override
  String get shop => 'SHOP';

  @override
  String get shopPitch => 'Skins, Seile & mehr';

  @override
  String get pass => 'PASS';

  @override
  String passTier(int tier, int total) {
    return 'Stufe $tier/$total';
  }

  @override
  String get daily => 'TÄGLICH';

  @override
  String dailyDone(int streak) {
    return 'Geschafft! 🔥 $streak';
  }

  @override
  String dailyKeepStreak(int streak) {
    return 'Halte deine 🔥 $streak';
  }

  @override
  String get dailyNew => 'Neue Herausforderung!';

  @override
  String get challengeCodeHint => 'Code oder Link von Freunden';

  @override
  String get playEndless => 'Endlos spielen';

  @override
  String get settingsTitle => 'EINSTELLUNGEN';

  @override
  String get music => 'Musik';

  @override
  String get soundEffects => 'Soundeffekte';

  @override
  String get muteAll => 'Alles stumm';

  @override
  String get vibration => 'Vibration';

  @override
  String get dailyReminders => 'Erinnerungen an die Tagesherausforderung';

  @override
  String get language => 'Sprache';

  @override
  String get languageAuto => 'Sprache des Handys';

  @override
  String get privacyOptions => 'Datenschutzoptionen';

  @override
  String get resetProgress => 'Fortschritt zurücksetzen';

  @override
  String get fonts => 'Schriften';

  @override
  String gamesNotSetUp(String service) {
    return 'Bestenlisten, Erfolge und Cloud-Speicherung gibt es mit $service. In dieser Version noch nicht eingerichtet.';
  }

  @override
  String gamesSignedIn(String service) {
    return 'Angemeldet. Dein Fortschritt wird in deinem $service-Konto gesichert.';
  }

  @override
  String gamesSignedInAs(String name, String service) {
    return 'Angemeldet als $name. Dein Fortschritt wird in deinem $service-Konto gesichert.';
  }

  @override
  String get gamesSignInPitch =>
      'Melde dich an, um deinen Fortschritt zu sichern und in den Bestenlisten mitzuspielen.';

  @override
  String get signIn => 'Anmelden';

  @override
  String get resetTitle => 'Fortschritt zurücksetzen?';

  @override
  String get resetBody =>
      'Deine Sterne, Münzen und Skins werden gelöscht. Das kann nicht rückgängig gemacht werden.';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String clipFailed(String error) {
    return 'Clip konnte nicht erstellt werden: $error';
  }

  @override
  String challengeShare(int distance, String link, String code) {
    return 'Ich bin in Floppy Swing Endlos $distance m weit geschwungen. Schaffst du mehr? $link\n(Oder tippe im Menü auf „Herausforderungscode“ und gib $code ein.)';
  }

  @override
  String get hintRevived => 'Wiederbelebt! Halten zum Schwingen.';

  @override
  String get hintHold => 'Irgendwo gedrückt halten zum Schwingen!';

  @override
  String get failSpikes1 => 'Spitze voraus.';

  @override
  String get failSpikes2 => 'Das gibt blaue Flecken.';

  @override
  String get failSpikes3 => 'Stachel: 1, Du: 0';

  @override
  String get failSaw1 => 'In Scheiben geschnitten!';

  @override
  String get failSaw2 => 'Hast du das kommen sehen?';

  @override
  String get failSaw3 => 'Bzzzzt!';

  @override
  String get failPit1 => 'Die Schwerkraft gewinnt schon wieder.';

  @override
  String get failPit2 => 'Ab nach unten!';

  @override
  String get failPit3 => 'Der Boden ist stachelig.';

  @override
  String get failStuck1 => 'Nickerchen?';

  @override
  String get failStuck2 => 'Klebt wie Kaugummi.';

  @override
  String get failStuck3 => 'Kurze Verschnaufpause?';

  @override
  String get tapToRetry => 'Irgendwo tippen für neuen Versuch';

  @override
  String get shareFail => 'Fail teilen';

  @override
  String get challengeFriend => 'Freunde herausfordern';

  @override
  String get newCourse => 'Neue Strecke';

  @override
  String get skipLevel => 'Level überspringen';

  @override
  String get revive => 'Wiederbeleben';

  @override
  String rankWorldwide(int rank) {
    return '#$rank weltweit';
  }

  @override
  String get newBest => 'NEUER REKORD!';

  @override
  String meters(int distance) {
    return '$distance m';
  }

  @override
  String endlessScore(int score, int best) {
    return 'Punkte $score  ·  Rekord $best';
  }

  @override
  String get newBestToday => 'Neue Bestzeit heute!';

  @override
  String rankToday(int rank) {
    return '#$rank heute';
  }

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count Tage in Folge',
      one: '🔥 $count Tag in Folge',
    );
    return '$_temp0';
  }

  @override
  String dayStreakBonus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count Tage in Folge - Bonus-Edelsteine!',
      one: '🔥 $count Tag in Folge - Bonus-Edelsteine!',
    );
    return '$_temp0';
  }

  @override
  String get dailyClear => 'TAGESZIEL GESCHAFFT!';

  @override
  String get worldClear => 'WELT GESCHAFFT!';

  @override
  String get levelClear => 'LEVEL GESCHAFFT!';

  @override
  String get statTime => 'Zeit';

  @override
  String statTarget(String time) {
    return 'Ziel ${time}s';
  }

  @override
  String get statCoins => 'Münzen';

  @override
  String get statStyle => 'Stil';

  @override
  String get statBest => 'Rekord';

  @override
  String get starFinish => 'Ziel';

  @override
  String newStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '(+$count Sterne)',
      one: '(+$count Stern)',
    );
    return '$_temp0';
  }

  @override
  String worldGate(int count, String world) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sammle noch $count Sterne, um $world zu öffnen!',
      one: 'Sammle noch $count Stern, um $world zu öffnen!',
    );
    return '$_temp0';
  }

  @override
  String get doubleCoins => 'Doppelte Münzen';

  @override
  String get retry => 'Nochmal';

  @override
  String get share => 'Teilen';

  @override
  String get next => 'Weiter';

  @override
  String get done => 'Fertig';

  @override
  String get levels => 'Level';

  @override
  String get quit => 'Beenden';

  @override
  String get paused => 'PAUSE';

  @override
  String get resume => 'Weiter';

  @override
  String get restart => 'Neustart';

  @override
  String get pause => 'Pause';

  @override
  String zoneBanner(int number, String name) {
    return 'ZONE $number: $name';
  }

  @override
  String hudDaily(String name) {
    return 'TÄGLICH: $name';
  }

  @override
  String hudStyle(int score) {
    return 'STIL $score';
  }

  @override
  String get slowMoReplay => 'ZEITLUPE';

  @override
  String get makingClip => 'Dein Clip wird erstellt…';

  @override
  String worldNumber(int number) {
    return 'WELT $number';
  }

  @override
  String get previousWorld => 'Vorherige Welt';

  @override
  String get nextWorld => 'Nächste Welt';

  @override
  String collectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sammle noch $count',
      one: 'Sammle noch $count',
    );
    return '$_temp0';
  }

  @override
  String starsOf(int have, int need) {
    return '$have/$need Sterne';
  }

  @override
  String levelTile(int number, String name) {
    return 'Level $number, $name';
  }

  @override
  String levelTileLocked(int number, String name) {
    return 'Level $number, $name, gesperrt';
  }

  @override
  String get dailyBonus => 'TAGESBONUS';

  @override
  String get dailyBonusPitch =>
      'Komm jeden Tag wieder für größere Belohnungen!';

  @override
  String get claim => 'Abholen';

  @override
  String dayNumber(int day) {
    return 'Tag $day';
  }

  @override
  String get seasonPassTitle => 'SAISONPASS';

  @override
  String get seasonPass => 'Saisonpass';

  @override
  String tierNumber(int tier) {
    return 'Stufe $tier';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Tage',
      one: 'Noch $count Tag',
    );
    return '$_temp0';
  }

  @override
  String get seasonComplete => 'Saison abgeschlossen!';

  @override
  String seasonXp(int xp, int perTier) {
    return '$xp / $perTier EP  ·  Sammle EP mit Levels, Tagesherausforderungen und Endlos-Läufen';
  }

  @override
  String get unlockPremium => 'Premium freischalten';

  @override
  String get or => 'oder';

  @override
  String get trackFree => 'GRATIS';

  @override
  String get trackPremium => 'PREMIUM';

  @override
  String get tabSkins => 'Skins';

  @override
  String get tabRopes => 'Seile';

  @override
  String get tabTrails => 'Spuren';

  @override
  String get tabFails => 'Fails';

  @override
  String get tabDances => 'Tänze';

  @override
  String get tabSets => 'Sets';

  @override
  String get tabGems => 'Edelsteine';

  @override
  String get equipped => 'AUSGERÜSTET';

  @override
  String get use => 'Nutzen';

  @override
  String get storeUnavailable =>
      'Der Store ist gerade nicht erreichbar. Prüfe deine Verbindung und versuche es später erneut.';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get bestValue => 'BESTES ANGEBOT';

  @override
  String plusItem(String item) {
    return '+ $item';
  }

  @override
  String purchaseThanks(String product) {
    return 'Danke! $product freigeschaltet.';
  }

  @override
  String get storeBusy =>
      'Der Store ist ausgelastet. Bitte versuche es erneut.';

  @override
  String get purchasesRestored => 'Käufe wiederhergestellt.';

  @override
  String get storeUnreachable => 'Store nicht erreichbar.';

  @override
  String get purchaseFailed =>
      'Kauf fehlgeschlagen. Dir wurde nichts berechnet.';

  @override
  String reminderStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Halte deine Serie von $count Tagen!',
      one: 'Halte deine Serie von $count Tag!',
    );
    return '$_temp0';
  }

  @override
  String get reminderStreakBody =>
      'Schaffe die heutige Tagesherausforderung vor Mitternacht.';

  @override
  String get reminderTodayTitle => 'Die heutige Tagesherausforderung wartet';

  @override
  String get reminderTodayBody =>
      'Jeden Tag ein neues Level. Hol dir die Sterne!';

  @override
  String get reminderFreshTitle => 'Eine neue Tagesherausforderung ist da';

  @override
  String get reminderFreshBody =>
      'Neues Level, neuer Geist zum Schlagen. Holst du alle 3 Sterne?';

  @override
  String get reminderRestlessTitle => 'Floppy wird ungeduldig';

  @override
  String get reminderRestlessBody =>
      'Die heutige Tagesherausforderung schwingt nicht von allein.';

  @override
  String get reminderTimeTitle => 'Zeit für die Tagesherausforderung!';

  @override
  String get reminderTimeBody =>
      'Kurz mal schwingen? Schaffe sie, um deine Serie zu halten.';

  @override
  String get reminderChannelDescription =>
      'Ein Hinweis, wenn eine neue Tagesherausforderung da ist.';

  @override
  String get shareTagline => 'Kannst du es besser?';

  @override
  String get shareCta => 'Floppy Swing - gratis für iOS & Android';

  @override
  String clipCleared(int level) {
    return 'Level $level geschafft!';
  }

  @override
  String clipTime(int level, String time) {
    return 'Level $level in ${time}s';
  }

  @override
  String clipSaw(int level) {
    return 'Traf eine Säge in Level $level';
  }

  @override
  String clipSpikes(int level) {
    return 'Fand die Stacheln in Level $level';
  }

  @override
  String clipPit(int level) {
    return 'Alles verfehlt in Level $level';
  }

  @override
  String clipStuck(int level) {
    return 'Nickerchen in Level $level';
  }

  @override
  String clipLevel(int level) {
    return 'Level $level';
  }

  @override
  String get wordBest => 'REKORD';

  @override
  String get wordCheckpoint => 'CHECKPOINT!';

  @override
  String get wordGo => 'LOS!';

  @override
  String get wordSmash => 'KLIRR!';

  @override
  String get wordKaboom => 'KABUMM!';

  @override
  String get wordBonk => 'BONK!';

  @override
  String get wordSaw => 'ZZZING!';

  @override
  String get wordSpikes => 'AUTSCH!';

  @override
  String get wordPit => 'AUWEIA!';

  @override
  String get wordStuck => 'ZZZ...';

  @override
  String get wordConfetti => 'JUHUU!';

  @override
  String get wordJackpot => 'JACKPOT!';

  @override
  String get wordSqueak => 'QUIETSCH!';

  @override
  String get styleBigSwing => 'RIESENSCHWUNG';

  @override
  String get styleSmash => 'SCHERBEN';

  @override
  String get styleFlip => 'SALTO';

  @override
  String get styleHangTime => 'FLUGZEIT';

  @override
  String get styleCloseCall => 'KNAPP!';

  @override
  String get world1Name => 'Spielplatz';

  @override
  String get world1Tagline => 'Halten. Schwingen. Loslassen. Schreien.';

  @override
  String get world2Name => 'Fabrik';

  @override
  String get world2Tagline => 'Ringe auf Schienen und hungrige Sägen.';

  @override
  String get world3Name => 'Glasstadt';

  @override
  String get world3Tagline => 'Durchbrechen. Abprallen.';

  @override
  String get world4Name => 'Himmelsinseln';

  @override
  String get world4Tagline => 'Reite den Wind. Fall nach oben.';

  @override
  String get world5Name => 'Raketenbasis';

  @override
  String get world5Tagline => 'Böden bröckeln. Raketen fliegen.';

  @override
  String get skinFloppyName => 'Floppy';

  @override
  String get skinFloppyTagline => 'Die Original-Nudel.';

  @override
  String get skinBananaName => 'Banane';

  @override
  String get skinBananaTagline => 'Rutschig beim Schwingen.';

  @override
  String get skinKnightName => 'Sir Flops';

  @override
  String get skinKnightTagline => 'Schwere Rüstung. Null Anmut.';

  @override
  String get skinAstronautName => 'Weltraumkadett';

  @override
  String get skinAstronautTagline => 'Schwerkraft ist nur ein Vorschlag.';

  @override
  String get skinChickenName => 'Gummihuhn';

  @override
  String get skinChickenTagline => 'Quietscht beim Aufprall. Natürlich.';

  @override
  String get skinNinjaName => 'Nudel-Ninja';

  @override
  String get skinNinjaTagline => 'Lautlos. Tödlich. Meistens lautlos.';

  @override
  String get skinPirateName => 'Käpt\'n Flop';

  @override
  String get skinPirateTagline => 'Yo-ho, oh nein.';

  @override
  String get skinRobotName => 'Robo-Nudel';

  @override
  String get skinRobotTagline => 'Piep. Boop. Bonk.';

  @override
  String get skinDinoName => 'Dino-Mit';

  @override
  String get skinDinoTagline => 'Kleine Arme. Großer Schwung.';

  @override
  String get skinWizardName => 'Flopdalf';

  @override
  String get skinWizardTagline => 'Du kommst nicht vorbei... hoppla.';

  @override
  String get skinGoldenName => 'Goldener Flop';

  @override
  String get skinGoldenTagline => 'Sammle alle 300 Sterne.';

  @override
  String get itemRopeName => 'Treues Seil';

  @override
  String get itemRopeTagline => 'Hanf. Zuverlässig. Beige.';

  @override
  String get itemChainName => 'Kette';

  @override
  String get itemChainTagline => 'Klirr klirr klirr.';

  @override
  String get itemSpaghettiName => 'Spaghetti';

  @override
  String get itemSpaghettiTagline => 'Al dente. Meistens.';

  @override
  String get itemRainbowName => 'Regenbogen';

  @override
  String get itemRainbowTagline => 'Schwing den Regenbogen.';

  @override
  String get itemLaserName => 'Laser';

  @override
  String get itemLaserTagline => 'Piu-piu-Enterhaken.';

  @override
  String get itemSwooshName => 'Wusch';

  @override
  String get itemSwooshTagline => 'Das klassische Wusch.';

  @override
  String get itemSparklesName => 'Glitzer';

  @override
  String get itemSparklesTagline => 'Fabelhaft bei jedem Tempo.';

  @override
  String get itemBubblesName => 'Blasen';

  @override
  String get itemBubblesTagline => 'Blubb blubb.';

  @override
  String get itemFireName => 'Feuer';

  @override
  String get itemFireTagline => 'Zu heiß zum Anfassen.';

  @override
  String get itemGoldName => 'Dublonen';

  @override
  String get itemGoldTagline => 'Saison Piratenbeute.';

  @override
  String get itemCircuitName => 'Schaltkreis';

  @override
  String get itemCircuitTagline => 'Saison Robo-Rummel.';

  @override
  String get itemLeavesName => 'Dschungelblätter';

  @override
  String get itemLeavesTagline => 'Saison Dino-Tage.';

  @override
  String get itemStarsName => 'Sternenstaub';

  @override
  String get itemStarsTagline => 'Saison Zauberwochen.';

  @override
  String get itemClassicName => 'Kawumm';

  @override
  String get itemClassicTagline => 'Sterne. Viele Sterne.';

  @override
  String get itemSqueakyName => 'Quietschespielzeug';

  @override
  String get itemSqueakyTagline => 'QUIIIIETSCH.';

  @override
  String get itemConfettiName => 'Konfettiparty';

  @override
  String get itemConfettiTagline => 'Scheitern ist ein Fest.';

  @override
  String get itemCoinpileName => 'Jackpot';

  @override
  String get itemCoinpileTagline => 'Zerplatze in einen Haufen Münzen.';

  @override
  String get itemHopName => 'Freudenhüpfer';

  @override
  String get itemHopTagline => 'Boing boing boing.';

  @override
  String get itemBackflipName => 'Rückwärtssalto';

  @override
  String get itemBackflipTagline => 'Steht die Landung. Manchmal.';

  @override
  String get itemSpinName => 'Tornado';

  @override
  String get itemSpinTagline => 'Wiiiiiee!';

  @override
  String get itemFlailName => 'Wildes Zappeln';

  @override
  String get itemFlailTagline => 'Wie ein aufblasbarer Werbemann.';

  @override
  String get setFoodName => 'Essensschlacht';

  @override
  String get setHeroesName => 'Tapfere Helden';

  @override
  String get setRopesName => 'Seilsammler';

  @override
  String get setTrailsName => 'Spurenleger';

  @override
  String get setFailsName => 'Epische Fails';

  @override
  String get setDancesName => 'Tanzfläche';

  @override
  String get seasonPirateName => 'Piratenbeute';

  @override
  String get seasonRobotName => 'Robo-Rummel';

  @override
  String get seasonDinoName => 'Dino-Tage';

  @override
  String get seasonWizardName => 'Zauberwochen';

  @override
  String get productStarterPackName => 'Starterpaket';

  @override
  String get productStarterPackTagline =>
      '300 Edelsteine, 2.500 Münzen und das Laserseil. Nur einmal!';

  @override
  String get productRemoveAdsName => 'Keine Werbung';

  @override
  String get productRemoveAdsTagline =>
      'Keine Werbung mehr zwischen Levels. Bonusvideos bleiben freiwillig.';

  @override
  String get productSeasonPassName => 'Premium-Pass';

  @override
  String get productSeasonPassTagline => 'Die Premium-Leiste dieser Saison.';

  @override
  String get productGemsSmallName => 'Handvoll Edelsteine';

  @override
  String get productGemsSmallTagline => '80 Edelsteine';

  @override
  String get productGemsMediumName => 'Beutel Edelsteine';

  @override
  String get productGemsMediumTagline => '450 Edelsteine (+12 % Bonus)';

  @override
  String get productGemsLargeName => 'Truhe Edelsteine';

  @override
  String get productGemsLargeTagline => '1.000 Edelsteine (+25 % Bonus)';

  @override
  String get productGemsHugeName => 'Tresor Edelsteine';

  @override
  String get productGemsHugeTagline => '2.200 Edelsteine (+37 % Bonus)';

  @override
  String get hintLevel1 =>
      'Halte irgendwo gedrückt, um den leuchtenden Ring zu greifen. Lass los, um zu fliegen!';

  @override
  String get hintLevel2 =>
      'Lass beim Aufwärtsschwung los, um weiter zu fliegen.';

  @override
  String get hintLevel3 => 'Rot heißt autsch. Berühre die Stacheln nicht!';

  @override
  String get hintLevel5 => 'Auch oben Stacheln. Flieg nicht zu hoch!';

  @override
  String get hintLevel6 =>
      'Grüne Polster katapultieren dich nach oben. Nutze sie für große Lücken.';

  @override
  String get hintLevel7 =>
      'Sägen drehen sich. Sägen tun weh. Schwing um sie herum.';

  @override
  String get hintLevel8 =>
      'Flaggen sind Checkpoints. Fällst du, geht es dort weiter.';

  @override
  String get hintLevel9 => 'Manche Sägen bewegen sich. Achte auf den Rhythmus.';

  @override
  String get hintLevel12 => 'Schwing hoch und lass los, um aufzusteigen.';

  @override
  String get hintLevel14 => 'Was hochgeht... kommt meistens wieder runter.';

  @override
  String get hintLevel15 => 'Alles auf einmal. Viel Glück!';

  @override
  String get hintLevel21 =>
      'Manche Ringe bewegen sich. Greif im richtigen Moment!';

  @override
  String get hintLevel41 =>
      'Glas bricht, wenn du schnell genug dagegen knallst. Durch damit!';

  @override
  String get hintLevel61 =>
      'Ventilatoren pusten dich nach oben. Reite den Wind!';

  @override
  String get hintLevel64 =>
      'Lila Zonen drehen die Schwerkraft um. Oben ist das neue Unten.';

  @override
  String get hintLevel81 =>
      'Bröckelnde Plattformen fallen kurz nach der Landung. Bleib in Bewegung!';

  @override
  String get hintLevel84 =>
      'Raketen tun dir nichts... aber die Stacheln schon.';
}
