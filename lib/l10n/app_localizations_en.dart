// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get settings => 'Settings';

  @override
  String get leaderboards => 'Leaderboards';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get achievements => 'Achievements';

  @override
  String get challengeCode => 'Challenge code';

  @override
  String couldNotSignIn(String service) {
    return 'Couldn\'t sign in to $service.';
  }

  @override
  String get play => 'PLAY';

  @override
  String get endless => 'ENDLESS';

  @override
  String endlessBest(int distance) {
    return 'Best $distance m';
  }

  @override
  String get endlessPitch => 'How far can you go?';

  @override
  String get shop => 'SHOP';

  @override
  String get shopPitch => 'Skins, ropes & more';

  @override
  String get pass => 'PASS';

  @override
  String passTier(int tier, int total) {
    return 'Tier $tier/$total';
  }

  @override
  String get daily => 'DAILY';

  @override
  String dailyDone(int streak) {
    return 'Done! 🔥 $streak';
  }

  @override
  String dailyKeepStreak(int streak) {
    return 'Keep your 🔥 $streak';
  }

  @override
  String get dailyNew => 'New challenge!';

  @override
  String get challengeCodeHint => 'Code or link from a friend';

  @override
  String get playEndless => 'Play Endless';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get music => 'Music';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get muteAll => 'Mute everything';

  @override
  String get vibration => 'Vibration';

  @override
  String get dailyReminders => 'Daily Challenge reminders';

  @override
  String get language => 'Language';

  @override
  String get languageAuto => 'Phone language';

  @override
  String get privacyOptions => 'Privacy options';

  @override
  String get resetProgress => 'Reset progress';

  @override
  String get fonts => 'Fonts';

  @override
  String gamesNotSetUp(String service) {
    return 'Leaderboards, achievements and cloud save come with $service. Not set up in this build yet.';
  }

  @override
  String gamesSignedIn(String service) {
    return 'Signed in. Progress is backed up to your $service account.';
  }

  @override
  String gamesSignedInAs(String name, String service) {
    return 'Signed in as $name. Progress is backed up to your $service account.';
  }

  @override
  String get gamesSignInPitch =>
      'Sign in to back up your progress and join the leaderboards.';

  @override
  String get signIn => 'Sign in';

  @override
  String get resetTitle => 'Reset progress?';

  @override
  String get resetBody =>
      'This wipes your stars, coins and skins. It cannot be undone.';

  @override
  String get reset => 'Reset';

  @override
  String clipFailed(String error) {
    return 'Could not make the clip: $error';
  }

  @override
  String challengeShare(int distance, String link, String code) {
    return 'I swung $distance m in Floppy Swing Endless. Can you beat me? $link\n(Or tap \"Challenge code\" in the menu and enter $code.)';
  }

  @override
  String get hintRevived => 'Revived! Hold to swing.';

  @override
  String get hintHold => 'Hold anywhere to swing!';

  @override
  String get failSpikes1 => 'Pointy end first.';

  @override
  String get failSpikes2 => 'That\'s gonna leave a mark.';

  @override
  String get failSpikes3 => 'Spike: 1, You: 0';

  @override
  String get failSaw1 => 'Sliced and diced!';

  @override
  String get failSaw2 => 'Saw that coming?';

  @override
  String get failSaw3 => 'Bzzzzt!';

  @override
  String get failPit1 => 'Gravity wins again.';

  @override
  String get failPit2 => 'Down you go!';

  @override
  String get failPit3 => 'The floor is spiky.';

  @override
  String get failStuck1 => 'Nap time?';

  @override
  String get failStuck2 => 'Stuck like glue.';

  @override
  String get failStuck3 => 'Taking a breather?';

  @override
  String get tapToRetry => 'Tap anywhere to retry';

  @override
  String get shareFail => 'Share fail';

  @override
  String get challengeFriend => 'Challenge a friend';

  @override
  String get newCourse => 'New course';

  @override
  String get skipLevel => 'Skip level';

  @override
  String get revive => 'Revive';

  @override
  String rankWorldwide(int rank) {
    return '#$rank worldwide';
  }

  @override
  String get newBest => 'NEW BEST!';

  @override
  String meters(int distance) {
    return '$distance m';
  }

  @override
  String endlessScore(int score, int best) {
    return 'Score $score  ·  Best $best';
  }

  @override
  String get newBestToday => 'New best time today!';

  @override
  String rankToday(int rank) {
    return '#$rank today';
  }

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count day streak',
      one: '🔥 $count day streak',
    );
    return '$_temp0';
  }

  @override
  String dayStreakBonus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count day streak - bonus gems!',
      one: '🔥 $count day streak - bonus gems!',
    );
    return '$_temp0';
  }

  @override
  String get dailyClear => 'DAILY CLEAR!';

  @override
  String get worldClear => 'WORLD CLEAR!';

  @override
  String get levelClear => 'LEVEL CLEAR!';

  @override
  String get statTime => 'Time';

  @override
  String statTarget(String time) {
    return 'target ${time}s';
  }

  @override
  String get statCoins => 'Coins';

  @override
  String get statStyle => 'Style';

  @override
  String get statBest => 'Best';

  @override
  String get starFinish => 'Finish';

  @override
  String newStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '(+$count stars)',
      one: '(+$count star)',
    );
    return '$_temp0';
  }

  @override
  String worldGate(int count, String world) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Collect $count more stars to open $world!',
      one: 'Collect $count more star to open $world!',
    );
    return '$_temp0';
  }

  @override
  String get doubleCoins => 'Double coins';

  @override
  String get retry => 'Retry';

  @override
  String get share => 'Share';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get levels => 'Levels';

  @override
  String get quit => 'Quit';

  @override
  String get paused => 'PAUSED';

  @override
  String get resume => 'Resume';

  @override
  String get restart => 'Restart';

  @override
  String get pause => 'Pause';

  @override
  String zoneBanner(int number, String name) {
    return 'ZONE $number: $name';
  }

  @override
  String hudDaily(String name) {
    return 'DAILY: $name';
  }

  @override
  String hudStyle(int score) {
    return 'STYLE $score';
  }

  @override
  String get slowMoReplay => 'SLOW-MO REPLAY';

  @override
  String get makingClip => 'Making your clip…';

  @override
  String worldNumber(int number) {
    return 'WORLD $number';
  }

  @override
  String get previousWorld => 'Previous world';

  @override
  String get nextWorld => 'Next world';

  @override
  String collectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Collect $count more',
      one: 'Collect $count more',
    );
    return '$_temp0';
  }

  @override
  String starsOf(int have, int need) {
    return '$have/$need stars';
  }

  @override
  String levelTile(int number, String name) {
    return 'Level $number, $name';
  }

  @override
  String levelTileLocked(int number, String name) {
    return 'Level $number, $name, locked';
  }

  @override
  String get dailyBonus => 'DAILY BONUS';

  @override
  String get dailyBonusPitch => 'Come back every day for bigger rewards!';

  @override
  String get claim => 'Claim';

  @override
  String dayNumber(int day) {
    return 'Day $day';
  }

  @override
  String get seasonPassTitle => 'SEASON PASS';

  @override
  String get seasonPass => 'Season Pass';

  @override
  String tierNumber(int tier) {
    return 'Tier $tier';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '$count day left',
    );
    return '$_temp0';
  }

  @override
  String get seasonComplete => 'Season complete!';

  @override
  String seasonXp(int xp, int perTier) {
    return '$xp / $perTier XP  ·  Earn XP by finishing levels, dailies and Endless runs';
  }

  @override
  String get unlockPremium => 'Unlock Premium';

  @override
  String get or => 'or';

  @override
  String get trackFree => 'FREE';

  @override
  String get trackPremium => 'PREMIUM';

  @override
  String get tabSkins => 'Skins';

  @override
  String get tabRopes => 'Ropes';

  @override
  String get tabTrails => 'Trails';

  @override
  String get tabFails => 'Fails';

  @override
  String get tabDances => 'Dances';

  @override
  String get tabSets => 'Sets';

  @override
  String get tabGems => 'Gems';

  @override
  String get equipped => 'EQUIPPED';

  @override
  String get use => 'Use';

  @override
  String get storeUnavailable =>
      'The store can\'t be reached right now. Check your connection and try again later.';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get bestValue => 'BEST VALUE';

  @override
  String plusItem(String item) {
    return '+ $item';
  }

  @override
  String purchaseThanks(String product) {
    return 'Thanks! $product unlocked.';
  }

  @override
  String get storeBusy => 'The store is busy. Please try again.';

  @override
  String get purchasesRestored => 'Purchases restored.';

  @override
  String get storeUnreachable => 'Couldn\'t reach the store.';

  @override
  String get purchaseFailed => 'Purchase failed. You have not been charged.';

  @override
  String reminderStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Keep your $count-day streak!',
      one: 'Keep your $count-day streak!',
    );
    return '$_temp0';
  }

  @override
  String get reminderStreakBody =>
      'Clear today\'s Daily Challenge before midnight.';

  @override
  String get reminderTodayTitle => 'Today\'s Daily Challenge is waiting';

  @override
  String get reminderTodayBody => 'A new level every day. Go get those stars!';

  @override
  String get reminderFreshTitle => 'A fresh Daily Challenge is here';

  @override
  String get reminderFreshBody =>
      'New level, new ghost to beat. Can you get all 3 stars?';

  @override
  String get reminderRestlessTitle => 'Floppy is getting restless';

  @override
  String get reminderRestlessBody =>
      'Today\'s Daily Challenge won\'t swing itself.';

  @override
  String get reminderTimeTitle => 'Daily Challenge time!';

  @override
  String get reminderTimeBody =>
      'One quick swing? Clear it to keep your streak going.';

  @override
  String get reminderChannelDescription =>
      'A nudge when a new Daily Challenge is out.';

  @override
  String get shareTagline => 'Can you do better?';

  @override
  String get shareCta => 'Floppy Swing - free on iOS & Android';

  @override
  String clipCleared(int level) {
    return 'Level $level cleared!';
  }

  @override
  String clipTime(int level, String time) {
    return 'Level $level in ${time}s';
  }

  @override
  String clipSaw(int level) {
    return 'Met a saw on level $level';
  }

  @override
  String clipSpikes(int level) {
    return 'Found the spikes on level $level';
  }

  @override
  String clipPit(int level) {
    return 'Missed everything on level $level';
  }

  @override
  String clipStuck(int level) {
    return 'Took a nap on level $level';
  }

  @override
  String clipLevel(int level) {
    return 'Level $level';
  }

  @override
  String get wordBest => 'BEST';

  @override
  String get wordCheckpoint => 'CHECKPOINT!';

  @override
  String get wordGo => 'GO!';

  @override
  String get wordSmash => 'SMASH!';

  @override
  String get wordKaboom => 'KABOOM!';

  @override
  String get wordBonk => 'BONK!';

  @override
  String get wordSaw => 'ZZZING!';

  @override
  String get wordSpikes => 'OUCH!';

  @override
  String get wordPit => 'YEOWCH!';

  @override
  String get wordStuck => 'ZZZ...';

  @override
  String get wordConfetti => 'WHEEE!';

  @override
  String get wordJackpot => 'JACKPOT!';

  @override
  String get wordSqueak => 'SQUEAK!';

  @override
  String get styleBigSwing => 'BIG SWING';

  @override
  String get styleSmash => 'SMASH';

  @override
  String get styleFlip => 'FLIP';

  @override
  String get styleHangTime => 'HANG TIME';

  @override
  String get styleCloseCall => 'CLOSE CALL';

  @override
  String get world1Name => 'Playground';

  @override
  String get world1Tagline => 'Hold. Swing. Let go. Scream.';

  @override
  String get world2Name => 'Factory';

  @override
  String get world2Tagline => 'Rings on rails and hungry saws.';

  @override
  String get world3Name => 'Glass City';

  @override
  String get world3Tagline => 'Smash through. Bounce off.';

  @override
  String get world4Name => 'Sky Islands';

  @override
  String get world4Tagline => 'Ride the wind. Fall upwards.';

  @override
  String get world5Name => 'Rocket Base';

  @override
  String get world5Tagline => 'Floors crumble. Rockets fly.';

  @override
  String get skinFloppyName => 'Floppy';

  @override
  String get skinFloppyTagline => 'The original noodle.';

  @override
  String get skinBananaName => 'Banana';

  @override
  String get skinBananaTagline => 'Slippery when swung.';

  @override
  String get skinKnightName => 'Sir Flops';

  @override
  String get skinKnightTagline => 'Heavy armour. Zero grace.';

  @override
  String get skinAstronautName => 'Space Cadet';

  @override
  String get skinAstronautTagline => 'Gravity is just a suggestion.';

  @override
  String get skinChickenName => 'Rubber Chicken';

  @override
  String get skinChickenTagline => 'Squeaks on impact. Obviously.';

  @override
  String get skinNinjaName => 'Noodle Ninja';

  @override
  String get skinNinjaTagline => 'Silent. Deadly. Mostly silent.';

  @override
  String get skinPirateName => 'Captain Flop';

  @override
  String get skinPirateTagline => 'Yo ho, oh no.';

  @override
  String get skinRobotName => 'Robo-Noodle';

  @override
  String get skinRobotTagline => 'Beep. Boop. Bonk.';

  @override
  String get skinDinoName => 'Dino-Mite';

  @override
  String get skinDinoTagline => 'Tiny arms. Big swings.';

  @override
  String get skinWizardName => 'Flopdalf';

  @override
  String get skinWizardTagline => 'You shall not... oops.';

  @override
  String get skinGoldenName => 'Golden Flop';

  @override
  String get skinGoldenTagline => 'Collect all 300 stars.';

  @override
  String get itemRopeName => 'Trusty Rope';

  @override
  String get itemRopeTagline => 'Hemp. Reliable. Beige.';

  @override
  String get itemChainName => 'Chain';

  @override
  String get itemChainTagline => 'Clink clink clink.';

  @override
  String get itemSpaghettiName => 'Spaghetti';

  @override
  String get itemSpaghettiTagline => 'Al dente. Mostly.';

  @override
  String get itemRainbowName => 'Rainbow';

  @override
  String get itemRainbowTagline => 'Taste the swing.';

  @override
  String get itemLaserName => 'Laser';

  @override
  String get itemLaserTagline => 'Pew pew grapple.';

  @override
  String get itemSwooshName => 'Swoosh';

  @override
  String get itemSwooshTagline => 'The classic whoosh.';

  @override
  String get itemSparklesName => 'Sparkles';

  @override
  String get itemSparklesTagline => 'Fabulous at any speed.';

  @override
  String get itemBubblesName => 'Bubbles';

  @override
  String get itemBubblesTagline => 'Blub blub.';

  @override
  String get itemFireName => 'Fire';

  @override
  String get itemFireTagline => 'Too hot to handle.';

  @override
  String get itemGoldName => 'Doubloons';

  @override
  String get itemGoldTagline => 'Pirate Plunder season.';

  @override
  String get itemCircuitName => 'Circuit';

  @override
  String get itemCircuitTagline => 'Robo Rumble season.';

  @override
  String get itemLeavesName => 'Jungle Leaves';

  @override
  String get itemLeavesTagline => 'Dino Days season.';

  @override
  String get itemStarsName => 'Stardust';

  @override
  String get itemStarsTagline => 'Wizard Weeks season.';

  @override
  String get itemClassicName => 'Kapow';

  @override
  String get itemClassicTagline => 'Stars. Lots of stars.';

  @override
  String get itemSqueakyName => 'Squeaky Toy';

  @override
  String get itemSqueakyTagline => 'SQUEEEEAK.';

  @override
  String get itemConfettiName => 'Confetti Party';

  @override
  String get itemConfettiTagline => 'Failing is a celebration.';

  @override
  String get itemCoinpileName => 'Jackpot';

  @override
  String get itemCoinpileTagline => 'Burst into a pile of coins.';

  @override
  String get itemHopName => 'Happy Hop';

  @override
  String get itemHopTagline => 'Boing boing boing.';

  @override
  String get itemBackflipName => 'Backflip';

  @override
  String get itemBackflipTagline => 'Sticks the landing. Sometimes.';

  @override
  String get itemSpinName => 'Tornado';

  @override
  String get itemSpinTagline => 'Wheeeeee!';

  @override
  String get itemFlailName => 'Wacky Flail';

  @override
  String get itemFlailTagline => 'Inflatable tube man energy.';

  @override
  String get setFoodName => 'Food Fight';

  @override
  String get setHeroesName => 'Brave Heroes';

  @override
  String get setRopesName => 'Rope Collector';

  @override
  String get setTrailsName => 'Trailblazer';

  @override
  String get setFailsName => 'Epic Fails';

  @override
  String get setDancesName => 'Dance Floor';

  @override
  String get seasonPirateName => 'Pirate Plunder';

  @override
  String get seasonRobotName => 'Robo Rumble';

  @override
  String get seasonDinoName => 'Dino Days';

  @override
  String get seasonWizardName => 'Wizard Weeks';

  @override
  String get productStarterPackName => 'Starter Pack';

  @override
  String get productStarterPackTagline =>
      '300 gems, 2,500 coins and the Laser rope. Once only!';

  @override
  String get productRemoveAdsName => 'No Ads';

  @override
  String get productRemoveAdsTagline =>
      'No more ads between levels. Bonus videos stay optional.';

  @override
  String get productSeasonPassName => 'Premium Pass';

  @override
  String get productSeasonPassTagline => 'This season\'s premium track.';

  @override
  String get productGemsSmallName => 'Handful of Gems';

  @override
  String get productGemsSmallTagline => '80 gems';

  @override
  String get productGemsMediumName => 'Bag of Gems';

  @override
  String get productGemsMediumTagline => '450 gems (+12% bonus)';

  @override
  String get productGemsLargeName => 'Chest of Gems';

  @override
  String get productGemsLargeTagline => '1,000 gems (+25% bonus)';

  @override
  String get productGemsHugeName => 'Vault of Gems';

  @override
  String get productGemsHugeTagline => '2,200 gems (+37% bonus)';

  @override
  String get hintLevel1 =>
      'Hold anywhere to grab the glowing ring. Let go to fly!';

  @override
  String get hintLevel2 => 'Let go on the up-swing to fly further.';

  @override
  String get hintLevel3 => 'Red means ouch. Don\'t touch the spikes!';

  @override
  String get hintLevel5 => 'Spikes above too. Don\'t fly too high!';

  @override
  String get hintLevel6 =>
      'Green pads bounce you up. Use them to cross big gaps.';

  @override
  String get hintLevel7 => 'Saws spin. Saws hurt. Swing around them.';

  @override
  String get hintLevel8 => 'Flags are checkpoints. Revive there if you fall.';

  @override
  String get hintLevel9 => 'Some saws move. Watch the rhythm.';

  @override
  String get hintLevel12 => 'Swing high and let go to climb.';

  @override
  String get hintLevel14 => 'What goes up... mostly comes down.';

  @override
  String get hintLevel15 => 'Everything at once. Good luck!';

  @override
  String get hintLevel21 => 'Some rings move. Time your grab!';

  @override
  String get hintLevel41 =>
      'Glass breaks if you hit it fast enough. Smash through!';

  @override
  String get hintLevel61 => 'Fans blow you upwards. Ride the wind!';

  @override
  String get hintLevel64 => 'Purple zones flip gravity. Up is the new down.';

  @override
  String get hintLevel81 =>
      'Crumbling platforms fall soon after you land. Keep moving!';

  @override
  String get hintLevel84 => 'Rockets won\'t kill you... but the spikes will.';
}
