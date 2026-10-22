import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('uk'),
    Locale('zh'),
  ];

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @leaderboards.
  ///
  /// In en, this message translates to:
  /// **'Leaderboards'**
  String get leaderboards;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @challengeCode.
  ///
  /// In en, this message translates to:
  /// **'Challenge code'**
  String get challengeCode;

  /// service: "Google Play Games" or "Game Center"
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in to {service}.'**
  String couldNotSignIn(String service);

  /// Big main menu button
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get play;

  /// Endless mode button and HUD title
  ///
  /// In en, this message translates to:
  /// **'ENDLESS'**
  String get endless;

  /// Best Endless distance in metres
  ///
  /// In en, this message translates to:
  /// **'Best {distance} m'**
  String endlessBest(int distance);

  /// No description provided for @endlessPitch.
  ///
  /// In en, this message translates to:
  /// **'How far can you go?'**
  String get endlessPitch;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'SHOP'**
  String get shop;

  /// No description provided for @shopPitch.
  ///
  /// In en, this message translates to:
  /// **'Skins, ropes & more'**
  String get shopPitch;

  /// Short for Season Pass, menu button
  ///
  /// In en, this message translates to:
  /// **'PASS'**
  String get pass;

  /// No description provided for @passTier.
  ///
  /// In en, this message translates to:
  /// **'Tier {tier}/{total}'**
  String passTier(int tier, int total);

  /// Daily Challenge menu button
  ///
  /// In en, this message translates to:
  /// **'DAILY'**
  String get daily;

  /// streak = days in a row
  ///
  /// In en, this message translates to:
  /// **'Done! 🔥 {streak}'**
  String dailyDone(int streak);

  /// No description provided for @dailyKeepStreak.
  ///
  /// In en, this message translates to:
  /// **'Keep your 🔥 {streak}'**
  String dailyKeepStreak(int streak);

  /// No description provided for @dailyNew.
  ///
  /// In en, this message translates to:
  /// **'New challenge!'**
  String get dailyNew;

  /// No description provided for @challengeCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Code or link from a friend'**
  String get challengeCodeHint;

  /// No description provided for @playEndless.
  ///
  /// In en, this message translates to:
  /// **'Play Endless'**
  String get playEndless;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// No description provided for @muteAll.
  ///
  /// In en, this message translates to:
  /// **'Mute everything'**
  String get muteAll;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @dailyReminders.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge reminders'**
  String get dailyReminders;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language option that follows the phone settings
  ///
  /// In en, this message translates to:
  /// **'Phone language'**
  String get languageAuto;

  /// No description provided for @privacyOptions.
  ///
  /// In en, this message translates to:
  /// **'Privacy options'**
  String get privacyOptions;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get resetProgress;

  /// No description provided for @fonts.
  ///
  /// In en, this message translates to:
  /// **'Fonts'**
  String get fonts;

  /// No description provided for @gamesNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'Leaderboards, achievements and cloud save come with {service}. Not set up in this build yet.'**
  String gamesNotSetUp(String service);

  /// No description provided for @gamesSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in. Progress is backed up to your {service} account.'**
  String gamesSignedIn(String service);

  /// No description provided for @gamesSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}. Progress is backed up to your {service} account.'**
  String gamesSignedInAs(String name, String service);

  /// No description provided for @gamesSignInPitch.
  ///
  /// In en, this message translates to:
  /// **'Sign in to back up your progress and join the leaderboards.'**
  String get gamesSignInPitch;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset progress?'**
  String get resetTitle;

  /// No description provided for @resetBody.
  ///
  /// In en, this message translates to:
  /// **'This wipes your stars, coins and skins. It cannot be undone.'**
  String get resetBody;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @clipFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not make the clip: {error}'**
  String clipFailed(String error);

  /// No description provided for @challengeShare.
  ///
  /// In en, this message translates to:
  /// **'I swung {distance} m in Floppy Swing Endless. Can you beat me? {link}\n(Or tap \"Challenge code\" in the menu and enter {code}.)'**
  String challengeShare(int distance, String link, String code);

  /// No description provided for @hintRevived.
  ///
  /// In en, this message translates to:
  /// **'Revived! Hold to swing.'**
  String get hintRevived;

  /// No description provided for @hintHold.
  ///
  /// In en, this message translates to:
  /// **'Hold anywhere to swing!'**
  String get hintHold;

  /// No description provided for @failSpikes1.
  ///
  /// In en, this message translates to:
  /// **'Pointy end first.'**
  String get failSpikes1;

  /// No description provided for @failSpikes2.
  ///
  /// In en, this message translates to:
  /// **'That\'s gonna leave a mark.'**
  String get failSpikes2;

  /// No description provided for @failSpikes3.
  ///
  /// In en, this message translates to:
  /// **'Spike: 1, You: 0'**
  String get failSpikes3;

  /// No description provided for @failSaw1.
  ///
  /// In en, this message translates to:
  /// **'Sliced and diced!'**
  String get failSaw1;

  /// No description provided for @failSaw2.
  ///
  /// In en, this message translates to:
  /// **'Saw that coming?'**
  String get failSaw2;

  /// No description provided for @failSaw3.
  ///
  /// In en, this message translates to:
  /// **'Bzzzzt!'**
  String get failSaw3;

  /// No description provided for @failPit1.
  ///
  /// In en, this message translates to:
  /// **'Gravity wins again.'**
  String get failPit1;

  /// No description provided for @failPit2.
  ///
  /// In en, this message translates to:
  /// **'Down you go!'**
  String get failPit2;

  /// No description provided for @failPit3.
  ///
  /// In en, this message translates to:
  /// **'The floor is spiky.'**
  String get failPit3;

  /// No description provided for @failStuck1.
  ///
  /// In en, this message translates to:
  /// **'Nap time?'**
  String get failStuck1;

  /// No description provided for @failStuck2.
  ///
  /// In en, this message translates to:
  /// **'Stuck like glue.'**
  String get failStuck2;

  /// No description provided for @failStuck3.
  ///
  /// In en, this message translates to:
  /// **'Taking a breather?'**
  String get failStuck3;

  /// No description provided for @tapToRetry.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to retry'**
  String get tapToRetry;

  /// No description provided for @shareFail.
  ///
  /// In en, this message translates to:
  /// **'Share fail'**
  String get shareFail;

  /// No description provided for @challengeFriend.
  ///
  /// In en, this message translates to:
  /// **'Challenge a friend'**
  String get challengeFriend;

  /// No description provided for @newCourse.
  ///
  /// In en, this message translates to:
  /// **'New course'**
  String get newCourse;

  /// No description provided for @skipLevel.
  ///
  /// In en, this message translates to:
  /// **'Skip level'**
  String get skipLevel;

  /// No description provided for @revive.
  ///
  /// In en, this message translates to:
  /// **'Revive'**
  String get revive;

  /// No description provided for @rankWorldwide.
  ///
  /// In en, this message translates to:
  /// **'#{rank} worldwide'**
  String rankWorldwide(int rank);

  /// No description provided for @newBest.
  ///
  /// In en, this message translates to:
  /// **'NEW BEST!'**
  String get newBest;

  /// No description provided for @meters.
  ///
  /// In en, this message translates to:
  /// **'{distance} m'**
  String meters(int distance);

  /// No description provided for @endlessScore.
  ///
  /// In en, this message translates to:
  /// **'Score {score}  ·  Best {best}'**
  String endlessScore(int score, int best);

  /// No description provided for @newBestToday.
  ///
  /// In en, this message translates to:
  /// **'New best time today!'**
  String get newBestToday;

  /// No description provided for @rankToday.
  ///
  /// In en, this message translates to:
  /// **'#{rank} today'**
  String rankToday(int rank);

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{🔥 {count} day streak} other{🔥 {count} day streak}}'**
  String dayStreak(int count);

  /// No description provided for @dayStreakBonus.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{🔥 {count} day streak - bonus gems!} other{🔥 {count} day streak - bonus gems!}}'**
  String dayStreakBonus(int count);

  /// No description provided for @dailyClear.
  ///
  /// In en, this message translates to:
  /// **'DAILY CLEAR!'**
  String get dailyClear;

  /// No description provided for @worldClear.
  ///
  /// In en, this message translates to:
  /// **'WORLD CLEAR!'**
  String get worldClear;

  /// No description provided for @levelClear.
  ///
  /// In en, this message translates to:
  /// **'LEVEL CLEAR!'**
  String get levelClear;

  /// No description provided for @statTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get statTime;

  /// No description provided for @statTarget.
  ///
  /// In en, this message translates to:
  /// **'target {time}s'**
  String statTarget(String time);

  /// No description provided for @statCoins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get statCoins;

  /// No description provided for @statStyle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get statStyle;

  /// No description provided for @statBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get statBest;

  /// Label under the first star (reached the finish)
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get starFinish;

  /// No description provided for @newStars.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{(+{count} star)} other{(+{count} stars)}}'**
  String newStars(int count);

  /// No description provided for @worldGate.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Collect {count} more star to open {world}!} other{Collect {count} more stars to open {world}!}}'**
  String worldGate(int count, String world);

  /// No description provided for @doubleCoins.
  ///
  /// In en, this message translates to:
  /// **'Double coins'**
  String get doubleCoins;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @levels.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get levels;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get paused;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Endless zone banner, name is the world name in capitals
  ///
  /// In en, this message translates to:
  /// **'ZONE {number}: {name}'**
  String zoneBanner(int number, String name);

  /// No description provided for @hudDaily.
  ///
  /// In en, this message translates to:
  /// **'DAILY: {name}'**
  String hudDaily(String name);

  /// No description provided for @hudStyle.
  ///
  /// In en, this message translates to:
  /// **'STYLE {score}'**
  String hudStyle(int score);

  /// No description provided for @slowMoReplay.
  ///
  /// In en, this message translates to:
  /// **'SLOW-MO REPLAY'**
  String get slowMoReplay;

  /// No description provided for @makingClip.
  ///
  /// In en, this message translates to:
  /// **'Making your clip…'**
  String get makingClip;

  /// No description provided for @worldNumber.
  ///
  /// In en, this message translates to:
  /// **'WORLD {number}'**
  String worldNumber(int number);

  /// No description provided for @previousWorld.
  ///
  /// In en, this message translates to:
  /// **'Previous world'**
  String get previousWorld;

  /// No description provided for @nextWorld.
  ///
  /// In en, this message translates to:
  /// **'Next world'**
  String get nextWorld;

  /// Followed by a star icon
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Collect {count} more} other{Collect {count} more}}'**
  String collectMore(int count);

  /// No description provided for @starsOf.
  ///
  /// In en, this message translates to:
  /// **'{have}/{need} stars'**
  String starsOf(int have, int need);

  /// No description provided for @levelTile.
  ///
  /// In en, this message translates to:
  /// **'Level {number}, {name}'**
  String levelTile(int number, String name);

  /// No description provided for @levelTileLocked.
  ///
  /// In en, this message translates to:
  /// **'Level {number}, {name}, locked'**
  String levelTileLocked(int number, String name);

  /// No description provided for @dailyBonus.
  ///
  /// In en, this message translates to:
  /// **'DAILY BONUS'**
  String get dailyBonus;

  /// No description provided for @dailyBonusPitch.
  ///
  /// In en, this message translates to:
  /// **'Come back every day for bigger rewards!'**
  String get dailyBonusPitch;

  /// No description provided for @claim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get claim;

  /// No description provided for @dayNumber.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String dayNumber(int day);

  /// No description provided for @seasonPassTitle.
  ///
  /// In en, this message translates to:
  /// **'SEASON PASS'**
  String get seasonPassTitle;

  /// No description provided for @seasonPass.
  ///
  /// In en, this message translates to:
  /// **'Season Pass'**
  String get seasonPass;

  /// No description provided for @tierNumber.
  ///
  /// In en, this message translates to:
  /// **'Tier {tier}'**
  String tierNumber(int tier);

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} day left} other{{count} days left}}'**
  String daysLeft(int count);

  /// No description provided for @seasonComplete.
  ///
  /// In en, this message translates to:
  /// **'Season complete!'**
  String get seasonComplete;

  /// No description provided for @seasonXp.
  ///
  /// In en, this message translates to:
  /// **'{xp} / {perTier} XP  ·  Earn XP by finishing levels, dailies and Endless runs'**
  String seasonXp(int xp, int perTier);

  /// No description provided for @unlockPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium'**
  String get unlockPremium;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @trackFree.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get trackFree;

  /// No description provided for @trackPremium.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get trackPremium;

  /// No description provided for @tabSkins.
  ///
  /// In en, this message translates to:
  /// **'Skins'**
  String get tabSkins;

  /// No description provided for @tabRopes.
  ///
  /// In en, this message translates to:
  /// **'Ropes'**
  String get tabRopes;

  /// No description provided for @tabTrails.
  ///
  /// In en, this message translates to:
  /// **'Trails'**
  String get tabTrails;

  /// No description provided for @tabFails.
  ///
  /// In en, this message translates to:
  /// **'Fails'**
  String get tabFails;

  /// No description provided for @tabDances.
  ///
  /// In en, this message translates to:
  /// **'Dances'**
  String get tabDances;

  /// No description provided for @tabSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get tabSets;

  /// No description provided for @tabGems.
  ///
  /// In en, this message translates to:
  /// **'Gems'**
  String get tabGems;

  /// No description provided for @equipped.
  ///
  /// In en, this message translates to:
  /// **'EQUIPPED'**
  String get equipped;

  /// No description provided for @use.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get use;

  /// No description provided for @storeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The store can\'t be reached right now. Check your connection and try again later.'**
  String get storeUnavailable;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValue;

  /// No description provided for @plusItem.
  ///
  /// In en, this message translates to:
  /// **'+ {item}'**
  String plusItem(String item);

  /// No description provided for @purchaseThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks! {product} unlocked.'**
  String purchaseThanks(String product);

  /// No description provided for @storeBusy.
  ///
  /// In en, this message translates to:
  /// **'The store is busy. Please try again.'**
  String get storeBusy;

  /// No description provided for @purchasesRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored.'**
  String get purchasesRestored;

  /// No description provided for @storeUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the store.'**
  String get storeUnreachable;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. You have not been charged.'**
  String get purchaseFailed;

  /// No description provided for @reminderStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Keep your {count}-day streak!} other{Keep your {count}-day streak!}}'**
  String reminderStreakTitle(int count);

  /// No description provided for @reminderStreakBody.
  ///
  /// In en, this message translates to:
  /// **'Clear today\'s Daily Challenge before midnight.'**
  String get reminderStreakBody;

  /// No description provided for @reminderTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Daily Challenge is waiting'**
  String get reminderTodayTitle;

  /// No description provided for @reminderTodayBody.
  ///
  /// In en, this message translates to:
  /// **'A new level every day. Go get those stars!'**
  String get reminderTodayBody;

  /// No description provided for @reminderFreshTitle.
  ///
  /// In en, this message translates to:
  /// **'A fresh Daily Challenge is here'**
  String get reminderFreshTitle;

  /// No description provided for @reminderFreshBody.
  ///
  /// In en, this message translates to:
  /// **'New level, new ghost to beat. Can you get all 3 stars?'**
  String get reminderFreshBody;

  /// No description provided for @reminderRestlessTitle.
  ///
  /// In en, this message translates to:
  /// **'Floppy is getting restless'**
  String get reminderRestlessTitle;

  /// No description provided for @reminderRestlessBody.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Daily Challenge won\'t swing itself.'**
  String get reminderRestlessBody;

  /// No description provided for @reminderTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge time!'**
  String get reminderTimeTitle;

  /// No description provided for @reminderTimeBody.
  ///
  /// In en, this message translates to:
  /// **'One quick swing? Clear it to keep your streak going.'**
  String get reminderTimeBody;

  /// No description provided for @reminderChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'A nudge when a new Daily Challenge is out.'**
  String get reminderChannelDescription;

  /// No description provided for @shareTagline.
  ///
  /// In en, this message translates to:
  /// **'Can you do better?'**
  String get shareTagline;

  /// No description provided for @shareCta.
  ///
  /// In en, this message translates to:
  /// **'Floppy Swing - free on iOS & Android'**
  String get shareCta;

  /// No description provided for @clipCleared.
  ///
  /// In en, this message translates to:
  /// **'Level {level} cleared!'**
  String clipCleared(int level);

  /// No description provided for @clipTime.
  ///
  /// In en, this message translates to:
  /// **'Level {level} in {time}s'**
  String clipTime(int level, String time);

  /// No description provided for @clipSaw.
  ///
  /// In en, this message translates to:
  /// **'Met a saw on level {level}'**
  String clipSaw(int level);

  /// No description provided for @clipSpikes.
  ///
  /// In en, this message translates to:
  /// **'Found the spikes on level {level}'**
  String clipSpikes(int level);

  /// No description provided for @clipPit.
  ///
  /// In en, this message translates to:
  /// **'Missed everything on level {level}'**
  String clipPit(int level);

  /// No description provided for @clipStuck.
  ///
  /// In en, this message translates to:
  /// **'Took a nap on level {level}'**
  String clipStuck(int level);

  /// No description provided for @clipLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String clipLevel(int level);

  /// Flag at the best Endless distance
  ///
  /// In en, this message translates to:
  /// **'BEST'**
  String get wordBest;

  /// No description provided for @wordCheckpoint.
  ///
  /// In en, this message translates to:
  /// **'CHECKPOINT!'**
  String get wordCheckpoint;

  /// No description provided for @wordGo.
  ///
  /// In en, this message translates to:
  /// **'GO!'**
  String get wordGo;

  /// Glass breaking
  ///
  /// In en, this message translates to:
  /// **'SMASH!'**
  String get wordSmash;

  /// No description provided for @wordKaboom.
  ///
  /// In en, this message translates to:
  /// **'KABOOM!'**
  String get wordKaboom;

  /// No description provided for @wordBonk.
  ///
  /// In en, this message translates to:
  /// **'BONK!'**
  String get wordBonk;

  /// Hit a saw
  ///
  /// In en, this message translates to:
  /// **'ZZZING!'**
  String get wordSaw;

  /// Hit spikes
  ///
  /// In en, this message translates to:
  /// **'OUCH!'**
  String get wordSpikes;

  /// Fell down
  ///
  /// In en, this message translates to:
  /// **'YEOWCH!'**
  String get wordPit;

  /// Fell asleep / stuck
  ///
  /// In en, this message translates to:
  /// **'ZZZ...'**
  String get wordStuck;

  /// No description provided for @wordConfetti.
  ///
  /// In en, this message translates to:
  /// **'WHEEE!'**
  String get wordConfetti;

  /// No description provided for @wordJackpot.
  ///
  /// In en, this message translates to:
  /// **'JACKPOT!'**
  String get wordJackpot;

  /// No description provided for @wordSqueak.
  ///
  /// In en, this message translates to:
  /// **'SQUEAK!'**
  String get wordSqueak;

  /// Style trick: swung all the way round
  ///
  /// In en, this message translates to:
  /// **'BIG SWING'**
  String get styleBigSwing;

  /// Style trick: broke glass
  ///
  /// In en, this message translates to:
  /// **'SMASH'**
  String get styleSmash;

  /// Style trick: somersault
  ///
  /// In en, this message translates to:
  /// **'FLIP'**
  String get styleFlip;

  /// Style trick: long time in the air
  ///
  /// In en, this message translates to:
  /// **'HANG TIME'**
  String get styleHangTime;

  /// Style trick: near miss with a hazard
  ///
  /// In en, this message translates to:
  /// **'CLOSE CALL'**
  String get styleCloseCall;

  /// No description provided for @world1Name.
  ///
  /// In en, this message translates to:
  /// **'Playground'**
  String get world1Name;

  /// No description provided for @world1Tagline.
  ///
  /// In en, this message translates to:
  /// **'Hold. Swing. Let go. Scream.'**
  String get world1Tagline;

  /// No description provided for @world2Name.
  ///
  /// In en, this message translates to:
  /// **'Factory'**
  String get world2Name;

  /// No description provided for @world2Tagline.
  ///
  /// In en, this message translates to:
  /// **'Rings on rails and hungry saws.'**
  String get world2Tagline;

  /// No description provided for @world3Name.
  ///
  /// In en, this message translates to:
  /// **'Glass City'**
  String get world3Name;

  /// No description provided for @world3Tagline.
  ///
  /// In en, this message translates to:
  /// **'Smash through. Bounce off.'**
  String get world3Tagline;

  /// No description provided for @world4Name.
  ///
  /// In en, this message translates to:
  /// **'Sky Islands'**
  String get world4Name;

  /// No description provided for @world4Tagline.
  ///
  /// In en, this message translates to:
  /// **'Ride the wind. Fall upwards.'**
  String get world4Tagline;

  /// No description provided for @world5Name.
  ///
  /// In en, this message translates to:
  /// **'Rocket Base'**
  String get world5Name;

  /// No description provided for @world5Tagline.
  ///
  /// In en, this message translates to:
  /// **'Floors crumble. Rockets fly.'**
  String get world5Tagline;

  /// Character skin name
  ///
  /// In en, this message translates to:
  /// **'Floppy'**
  String get skinFloppyName;

  /// No description provided for @skinFloppyTagline.
  ///
  /// In en, this message translates to:
  /// **'The original noodle.'**
  String get skinFloppyTagline;

  /// Character skin name
  ///
  /// In en, this message translates to:
  /// **'Banana'**
  String get skinBananaName;

  /// No description provided for @skinBananaTagline.
  ///
  /// In en, this message translates to:
  /// **'Slippery when swung.'**
  String get skinBananaTagline;

  /// Character skin name
  ///
  /// In en, this message translates to:
  /// **'Sir Flops'**
  String get skinKnightName;

  /// No description provided for @skinKnightTagline.
  ///
  /// In en, this message translates to:
  /// **'Heavy armour. Zero grace.'**
  String get skinKnightTagline;

  /// Character skin name
  ///
  /// In en, this message translates to:
  /// **'Space Cadet'**
  String get skinAstronautName;

  /// No description provided for @skinAstronautTagline.
  ///
  /// In en, this message translates to:
  /// **'Gravity is just a suggestion.'**
  String get skinAstronautTagline;

  /// Character skin name
  ///
  /// In en, this message translates to:
  /// **'Rubber Chicken'**
  String get skinChickenName;

  /// No description provided for @skinChickenTagline.
  ///
  /// In en, this message translates to:
  /// **'Squeaks on impact. Obviously.'**
  String get skinChickenTagline;

  /// Character skin name
  ///
  /// In en, this message translates to:
  /// **'Noodle Ninja'**
  String get skinNinjaName;

  /// No description provided for @skinNinjaTagline.
  ///
  /// In en, this message translates to:
  /// **'Silent. Deadly. Mostly silent.'**
  String get skinNinjaTagline;

  /// Character skin name
  ///
  /// In en, this message translates to:
  /// **'Captain Flop'**
  String get skinPirateName;

  /// No description provided for @skinPirateTagline.
  ///
  /// In en, this message translates to:
  /// **'Yo ho, oh no.'**
  String get skinPirateTagline;

  /// Character skin name
  ///
  /// In en, this message translates to:
  /// **'Robo-Noodle'**
  String get skinRobotName;

  /// No description provided for @skinRobotTagline.
  ///
  /// In en, this message translates to:
  /// **'Beep. Boop. Bonk.'**
  String get skinRobotTagline;

  /// Character skin name
  ///
  /// In en, this message translates to:
  /// **'Dino-Mite'**
  String get skinDinoName;

  /// No description provided for @skinDinoTagline.
  ///
  /// In en, this message translates to:
  /// **'Tiny arms. Big swings.'**
  String get skinDinoTagline;

  /// Character skin name
  ///
  /// In en, this message translates to:
  /// **'Flopdalf'**
  String get skinWizardName;

  /// No description provided for @skinWizardTagline.
  ///
  /// In en, this message translates to:
  /// **'You shall not... oops.'**
  String get skinWizardTagline;

  /// Character skin name
  ///
  /// In en, this message translates to:
  /// **'Golden Flop'**
  String get skinGoldenName;

  /// No description provided for @skinGoldenTagline.
  ///
  /// In en, this message translates to:
  /// **'Collect all 300 stars.'**
  String get skinGoldenTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Trusty Rope'**
  String get itemRopeName;

  /// No description provided for @itemRopeTagline.
  ///
  /// In en, this message translates to:
  /// **'Hemp. Reliable. Beige.'**
  String get itemRopeTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Chain'**
  String get itemChainName;

  /// No description provided for @itemChainTagline.
  ///
  /// In en, this message translates to:
  /// **'Clink clink clink.'**
  String get itemChainTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Spaghetti'**
  String get itemSpaghettiName;

  /// No description provided for @itemSpaghettiTagline.
  ///
  /// In en, this message translates to:
  /// **'Al dente. Mostly.'**
  String get itemSpaghettiTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Rainbow'**
  String get itemRainbowName;

  /// No description provided for @itemRainbowTagline.
  ///
  /// In en, this message translates to:
  /// **'Taste the swing.'**
  String get itemRainbowTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Laser'**
  String get itemLaserName;

  /// No description provided for @itemLaserTagline.
  ///
  /// In en, this message translates to:
  /// **'Pew pew grapple.'**
  String get itemLaserTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Swoosh'**
  String get itemSwooshName;

  /// No description provided for @itemSwooshTagline.
  ///
  /// In en, this message translates to:
  /// **'The classic whoosh.'**
  String get itemSwooshTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Sparkles'**
  String get itemSparklesName;

  /// No description provided for @itemSparklesTagline.
  ///
  /// In en, this message translates to:
  /// **'Fabulous at any speed.'**
  String get itemSparklesTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Bubbles'**
  String get itemBubblesName;

  /// No description provided for @itemBubblesTagline.
  ///
  /// In en, this message translates to:
  /// **'Blub blub.'**
  String get itemBubblesTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get itemFireName;

  /// No description provided for @itemFireTagline.
  ///
  /// In en, this message translates to:
  /// **'Too hot to handle.'**
  String get itemFireTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Doubloons'**
  String get itemGoldName;

  /// No description provided for @itemGoldTagline.
  ///
  /// In en, this message translates to:
  /// **'Pirate Plunder season.'**
  String get itemGoldTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Circuit'**
  String get itemCircuitName;

  /// No description provided for @itemCircuitTagline.
  ///
  /// In en, this message translates to:
  /// **'Robo Rumble season.'**
  String get itemCircuitTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Jungle Leaves'**
  String get itemLeavesName;

  /// No description provided for @itemLeavesTagline.
  ///
  /// In en, this message translates to:
  /// **'Dino Days season.'**
  String get itemLeavesTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Stardust'**
  String get itemStarsName;

  /// No description provided for @itemStarsTagline.
  ///
  /// In en, this message translates to:
  /// **'Wizard Weeks season.'**
  String get itemStarsTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Kapow'**
  String get itemClassicName;

  /// No description provided for @itemClassicTagline.
  ///
  /// In en, this message translates to:
  /// **'Stars. Lots of stars.'**
  String get itemClassicTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Squeaky Toy'**
  String get itemSqueakyName;

  /// No description provided for @itemSqueakyTagline.
  ///
  /// In en, this message translates to:
  /// **'SQUEEEEAK.'**
  String get itemSqueakyTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Confetti Party'**
  String get itemConfettiName;

  /// No description provided for @itemConfettiTagline.
  ///
  /// In en, this message translates to:
  /// **'Failing is a celebration.'**
  String get itemConfettiTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Jackpot'**
  String get itemCoinpileName;

  /// No description provided for @itemCoinpileTagline.
  ///
  /// In en, this message translates to:
  /// **'Burst into a pile of coins.'**
  String get itemCoinpileTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Happy Hop'**
  String get itemHopName;

  /// No description provided for @itemHopTagline.
  ///
  /// In en, this message translates to:
  /// **'Boing boing boing.'**
  String get itemHopTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Backflip'**
  String get itemBackflipName;

  /// No description provided for @itemBackflipTagline.
  ///
  /// In en, this message translates to:
  /// **'Sticks the landing. Sometimes.'**
  String get itemBackflipTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Tornado'**
  String get itemSpinName;

  /// No description provided for @itemSpinTagline.
  ///
  /// In en, this message translates to:
  /// **'Wheeeeee!'**
  String get itemSpinTagline;

  /// Rope, trail, fail effect or dance name
  ///
  /// In en, this message translates to:
  /// **'Wacky Flail'**
  String get itemFlailName;

  /// No description provided for @itemFlailTagline.
  ///
  /// In en, this message translates to:
  /// **'Inflatable tube man energy.'**
  String get itemFlailTagline;

  /// Collection of shop items
  ///
  /// In en, this message translates to:
  /// **'Food Fight'**
  String get setFoodName;

  /// Collection of shop items
  ///
  /// In en, this message translates to:
  /// **'Brave Heroes'**
  String get setHeroesName;

  /// Collection of shop items
  ///
  /// In en, this message translates to:
  /// **'Rope Collector'**
  String get setRopesName;

  /// Collection of shop items
  ///
  /// In en, this message translates to:
  /// **'Trailblazer'**
  String get setTrailsName;

  /// Collection of shop items
  ///
  /// In en, this message translates to:
  /// **'Epic Fails'**
  String get setFailsName;

  /// Collection of shop items
  ///
  /// In en, this message translates to:
  /// **'Dance Floor'**
  String get setDancesName;

  /// Season Pass theme
  ///
  /// In en, this message translates to:
  /// **'Pirate Plunder'**
  String get seasonPirateName;

  /// Season Pass theme
  ///
  /// In en, this message translates to:
  /// **'Robo Rumble'**
  String get seasonRobotName;

  /// Season Pass theme
  ///
  /// In en, this message translates to:
  /// **'Dino Days'**
  String get seasonDinoName;

  /// Season Pass theme
  ///
  /// In en, this message translates to:
  /// **'Wizard Weeks'**
  String get seasonWizardName;

  /// No description provided for @productStarterPackName.
  ///
  /// In en, this message translates to:
  /// **'Starter Pack'**
  String get productStarterPackName;

  /// No description provided for @productStarterPackTagline.
  ///
  /// In en, this message translates to:
  /// **'300 gems, 2,500 coins and the Laser rope. Once only!'**
  String get productStarterPackTagline;

  /// No description provided for @productRemoveAdsName.
  ///
  /// In en, this message translates to:
  /// **'No Ads'**
  String get productRemoveAdsName;

  /// No description provided for @productRemoveAdsTagline.
  ///
  /// In en, this message translates to:
  /// **'No more ads between levels. Bonus videos stay optional.'**
  String get productRemoveAdsTagline;

  /// No description provided for @productSeasonPassName.
  ///
  /// In en, this message translates to:
  /// **'Premium Pass'**
  String get productSeasonPassName;

  /// No description provided for @productSeasonPassTagline.
  ///
  /// In en, this message translates to:
  /// **'This season\'s premium track.'**
  String get productSeasonPassTagline;

  /// No description provided for @productGemsSmallName.
  ///
  /// In en, this message translates to:
  /// **'Handful of Gems'**
  String get productGemsSmallName;

  /// No description provided for @productGemsSmallTagline.
  ///
  /// In en, this message translates to:
  /// **'80 gems'**
  String get productGemsSmallTagline;

  /// No description provided for @productGemsMediumName.
  ///
  /// In en, this message translates to:
  /// **'Bag of Gems'**
  String get productGemsMediumName;

  /// No description provided for @productGemsMediumTagline.
  ///
  /// In en, this message translates to:
  /// **'450 gems (+12% bonus)'**
  String get productGemsMediumTagline;

  /// No description provided for @productGemsLargeName.
  ///
  /// In en, this message translates to:
  /// **'Chest of Gems'**
  String get productGemsLargeName;

  /// No description provided for @productGemsLargeTagline.
  ///
  /// In en, this message translates to:
  /// **'1,000 gems (+25% bonus)'**
  String get productGemsLargeTagline;

  /// No description provided for @productGemsHugeName.
  ///
  /// In en, this message translates to:
  /// **'Vault of Gems'**
  String get productGemsHugeName;

  /// No description provided for @productGemsHugeTagline.
  ///
  /// In en, this message translates to:
  /// **'2,200 gems (+37% bonus)'**
  String get productGemsHugeTagline;

  /// Tutorial hint on level 1
  ///
  /// In en, this message translates to:
  /// **'Hold anywhere to grab the glowing ring. Let go to fly!'**
  String get hintLevel1;

  /// Tutorial hint on level 2
  ///
  /// In en, this message translates to:
  /// **'Let go on the up-swing to fly further.'**
  String get hintLevel2;

  /// Tutorial hint on level 3
  ///
  /// In en, this message translates to:
  /// **'Red means ouch. Don\'t touch the spikes!'**
  String get hintLevel3;

  /// Tutorial hint on level 5
  ///
  /// In en, this message translates to:
  /// **'Spikes above too. Don\'t fly too high!'**
  String get hintLevel5;

  /// Tutorial hint on level 6
  ///
  /// In en, this message translates to:
  /// **'Green pads bounce you up. Use them to cross big gaps.'**
  String get hintLevel6;

  /// Tutorial hint on level 7
  ///
  /// In en, this message translates to:
  /// **'Saws spin. Saws hurt. Swing around them.'**
  String get hintLevel7;

  /// Tutorial hint on level 8
  ///
  /// In en, this message translates to:
  /// **'Flags are checkpoints. Revive there if you fall.'**
  String get hintLevel8;

  /// Tutorial hint on level 9
  ///
  /// In en, this message translates to:
  /// **'Some saws move. Watch the rhythm.'**
  String get hintLevel9;

  /// Tutorial hint on level 12
  ///
  /// In en, this message translates to:
  /// **'Swing high and let go to climb.'**
  String get hintLevel12;

  /// Tutorial hint on level 14
  ///
  /// In en, this message translates to:
  /// **'What goes up... mostly comes down.'**
  String get hintLevel14;

  /// Tutorial hint on level 15
  ///
  /// In en, this message translates to:
  /// **'Everything at once. Good luck!'**
  String get hintLevel15;

  /// Tutorial hint on level 21
  ///
  /// In en, this message translates to:
  /// **'Some rings move. Time your grab!'**
  String get hintLevel21;

  /// Tutorial hint on level 41
  ///
  /// In en, this message translates to:
  /// **'Glass breaks if you hit it fast enough. Smash through!'**
  String get hintLevel41;

  /// Tutorial hint on level 61
  ///
  /// In en, this message translates to:
  /// **'Fans blow you upwards. Ride the wind!'**
  String get hintLevel61;

  /// Tutorial hint on level 64
  ///
  /// In en, this message translates to:
  /// **'Purple zones flip gravity. Up is the new down.'**
  String get hintLevel64;

  /// Tutorial hint on level 81
  ///
  /// In en, this message translates to:
  /// **'Crumbling platforms fall soon after you land. Keep moving!'**
  String get hintLevel81;

  /// Tutorial hint on level 84
  ///
  /// In en, this message translates to:
  /// **'Rockets won\'t kill you... but the spikes will.'**
  String get hintLevel84;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'el',
    'en',
    'es',
    'fr',
    'id',
    'it',
    'ja',
    'ko',
    'pl',
    'pt',
    'ru',
    'tr',
    'uk',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
