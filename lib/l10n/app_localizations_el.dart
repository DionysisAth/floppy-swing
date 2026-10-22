// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get back => 'Πίσω';

  @override
  String get cancel => 'Άκυρο';

  @override
  String get settings => 'Ρυθμίσεις';

  @override
  String get leaderboards => 'Κατατάξεις';

  @override
  String get leaderboard => 'Κατάταξη';

  @override
  String get achievements => 'Επιτεύγματα';

  @override
  String get challengeCode => 'Κωδικός πρόκλησης';

  @override
  String couldNotSignIn(String service) {
    return 'Δεν ήταν δυνατή η σύνδεση στο $service.';
  }

  @override
  String get play => 'ΠΑΙΞΕ';

  @override
  String get endless => 'ΑΤΕΛΕΙΩΤΟ';

  @override
  String endlessBest(int distance) {
    return 'Ρεκόρ $distance μ';
  }

  @override
  String get endlessPitch => 'Πόσο μακριά θα φτάσεις;';

  @override
  String get shop => 'ΚΑΤΑΣΤΗΜΑ';

  @override
  String get shopPitch => 'Εμφανίσεις, σχοινιά & άλλα';

  @override
  String get pass => 'PASS';

  @override
  String passTier(int tier, int total) {
    return 'Βαθμίδα $tier/$total';
  }

  @override
  String get daily => 'ΗΜΕΡΗΣΙΑ';

  @override
  String dailyDone(int streak) {
    return 'Έγινε! 🔥 $streak';
  }

  @override
  String dailyKeepStreak(int streak) {
    return 'Κράτα το 🔥 $streak';
  }

  @override
  String get dailyNew => 'Νέα πρόκληση!';

  @override
  String get challengeCodeHint => 'Κωδικός ή σύνδεσμος από φίλο';

  @override
  String get playEndless => 'Παίξε Ατελείωτο';

  @override
  String get settingsTitle => 'ΡΥΘΜΙΣΕΙΣ';

  @override
  String get music => 'Μουσική';

  @override
  String get soundEffects => 'Ηχητικά εφέ';

  @override
  String get muteAll => 'Σίγαση όλων';

  @override
  String get vibration => 'Δόνηση';

  @override
  String get dailyReminders => 'Υπενθυμίσεις Ημερήσιας Πρόκλησης';

  @override
  String get language => 'Γλώσσα';

  @override
  String get languageAuto => 'Γλώσσα κινητού';

  @override
  String get privacyOptions => 'Επιλογές απορρήτου';

  @override
  String get resetProgress => 'Επαναφορά προόδου';

  @override
  String get fonts => 'Γραμματοσειρές';

  @override
  String gamesNotSetUp(String service) {
    return 'Οι κατατάξεις, τα επιτεύγματα και η αποθήκευση στο cloud έρχονται με το $service. Δεν έχουν ρυθμιστεί ακόμα σε αυτή την έκδοση.';
  }

  @override
  String gamesSignedIn(String service) {
    return 'Συνδέθηκες. Η πρόοδός σου αποθηκεύεται στον λογαριασμό σου στο $service.';
  }

  @override
  String gamesSignedInAs(String name, String service) {
    return 'Συνδέθηκες ως $name. Η πρόοδός σου αποθηκεύεται στον λογαριασμό σου στο $service.';
  }

  @override
  String get gamesSignInPitch =>
      'Συνδέσου για να κρατάς αντίγραφο της προόδου σου και να μπεις στις κατατάξεις.';

  @override
  String get signIn => 'Σύνδεση';

  @override
  String get resetTitle => 'Επαναφορά προόδου;';

  @override
  String get resetBody =>
      'Θα σβηστούν τα αστέρια, τα νομίσματα και οι εμφανίσεις σου. Δεν αναιρείται.';

  @override
  String get reset => 'Επαναφορά';

  @override
  String clipFailed(String error) {
    return 'Δεν ήταν δυνατή η δημιουργία του βίντεο: $error';
  }

  @override
  String challengeShare(int distance, String link, String code) {
    return 'Έφτασα $distance μ στο Ατελείωτο του Floppy Swing. Μπορείς να με ξεπεράσεις; $link\n(Ή πάτα «Κωδικός πρόκλησης» στο μενού και γράψε $code.)';
  }

  @override
  String get hintRevived => 'Ξαναζωντάνεψες! Κράτα πατημένο για κούνια.';

  @override
  String get hintHold => 'Κράτα πατημένο οπουδήποτε για κούνια!';

  @override
  String get failSpikes1 => 'Με τη μύτη πρώτα.';

  @override
  String get failSpikes2 => 'Αυτό θα αφήσει σημάδι.';

  @override
  String get failSpikes3 => 'Αγκάθια: 1, Εσύ: 0';

  @override
  String get failSaw1 => 'Έγινες φέτες!';

  @override
  String get failSaw2 => 'Δεν το είδες να έρχεται;';

  @override
  String get failSaw3 => 'Μπζζζζτ!';

  @override
  String get failPit1 => 'Η βαρύτητα κερδίζει ξανά.';

  @override
  String get failPit2 => 'Κάτω πας!';

  @override
  String get failPit3 => 'Το πάτωμα τσιμπάει.';

  @override
  String get failStuck1 => 'Ώρα για υπνάκο;';

  @override
  String get failStuck2 => 'Κόλλησες σαν βεντούζα.';

  @override
  String get failStuck3 => 'Παίρνεις μια ανάσα;';

  @override
  String get tapToRetry => 'Πάτα οπουδήποτε για νέα προσπάθεια';

  @override
  String get shareFail => 'Μοιράσου τη γκάφα';

  @override
  String get challengeFriend => 'Προκάλεσε έναν φίλο';

  @override
  String get newCourse => 'Νέα διαδρομή';

  @override
  String get skipLevel => 'Παράλειψη πίστας';

  @override
  String get revive => 'Αναβίωση';

  @override
  String rankWorldwide(int rank) {
    return '#$rank παγκοσμίως';
  }

  @override
  String get newBest => 'ΝΕΟ ΡΕΚΟΡ!';

  @override
  String meters(int distance) {
    return '$distance μ';
  }

  @override
  String endlessScore(int score, int best) {
    return 'Σκορ $score  ·  Ρεκόρ $best';
  }

  @override
  String get newBestToday => 'Νέος καλύτερος χρόνος σήμερα!';

  @override
  String rankToday(int rank) {
    return '#$rank σήμερα';
  }

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count μέρες σερί',
      one: '🔥 $count μέρα σερί',
    );
    return '$_temp0';
  }

  @override
  String dayStreakBonus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count μέρες σερί - μπόνους πετράδια!',
      one: '🔥 $count μέρα σερί - μπόνους πετράδια!',
    );
    return '$_temp0';
  }

  @override
  String get dailyClear => 'Η ΠΡΟΚΛΗΣΗ ΠΕΡΑΣΤΗΚΕ!';

  @override
  String get worldClear => 'Ο ΚΟΣΜΟΣ ΠΕΡΑΣΤΗΚΕ!';

  @override
  String get levelClear => 'Η ΠΙΣΤΑ ΠΕΡΑΣΤΗΚΕ!';

  @override
  String get statTime => 'Χρόνος';

  @override
  String statTarget(String time) {
    return 'στόχος ${time}s';
  }

  @override
  String get statCoins => 'Νομίσματα';

  @override
  String get statStyle => 'Στιλ';

  @override
  String get statBest => 'Ρεκόρ';

  @override
  String get starFinish => 'Τερματισμός';

  @override
  String newStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '(+$count αστέρια)',
      one: '(+$count αστέρι)',
    );
    return '$_temp0';
  }

  @override
  String worldGate(int count, String world) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Μάζεψε ακόμα $count αστέρια για να ανοίξει ο κόσμος $world!',
      one: 'Μάζεψε ακόμα $count αστέρι για να ανοίξει ο κόσμος $world!',
    );
    return '$_temp0';
  }

  @override
  String get doubleCoins => 'Διπλά νομίσματα';

  @override
  String get retry => 'Ξανά';

  @override
  String get share => 'Κοινοποίηση';

  @override
  String get next => 'Επόμενη';

  @override
  String get done => 'Τέλος';

  @override
  String get levels => 'Πίστες';

  @override
  String get quit => 'Έξοδος';

  @override
  String get paused => 'ΠΑΥΣΗ';

  @override
  String get resume => 'Συνέχεια';

  @override
  String get restart => 'Από την αρχή';

  @override
  String get pause => 'Παύση';

  @override
  String zoneBanner(int number, String name) {
    return 'ΖΩΝΗ $number: $name';
  }

  @override
  String hudDaily(String name) {
    return 'ΗΜΕΡΗΣΙΑ: $name';
  }

  @override
  String hudStyle(int score) {
    return 'ΣΤΙΛ $score';
  }

  @override
  String get slowMoReplay => 'ΑΡΓΗ ΚΙΝΗΣΗ';

  @override
  String get makingClip => 'Φτιάχνουμε το βίντεό σου…';

  @override
  String worldNumber(int number) {
    return 'ΚΟΣΜΟΣ $number';
  }

  @override
  String get previousWorld => 'Προηγούμενος κόσμος';

  @override
  String get nextWorld => 'Επόμενος κόσμος';

  @override
  String collectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Μάζεψε ακόμα $count',
      one: 'Μάζεψε ακόμα $count',
    );
    return '$_temp0';
  }

  @override
  String starsOf(int have, int need) {
    return '$have/$need αστέρια';
  }

  @override
  String levelTile(int number, String name) {
    return 'Πίστα $number, $name';
  }

  @override
  String levelTileLocked(int number, String name) {
    return 'Πίστα $number, $name, κλειδωμένη';
  }

  @override
  String get dailyBonus => 'ΗΜΕΡΗΣΙΟ ΔΩΡΟ';

  @override
  String get dailyBonusPitch => 'Έλα κάθε μέρα για ακόμα μεγαλύτερα δώρα!';

  @override
  String get claim => 'Πάρ\' το';

  @override
  String dayNumber(int day) {
    return 'Μέρα $day';
  }

  @override
  String get seasonPassTitle => 'SEASON PASS';

  @override
  String get seasonPass => 'Season Pass';

  @override
  String tierNumber(int tier) {
    return 'Βαθμίδα $tier';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Μένουν $count μέρες',
      one: 'Μένει $count μέρα',
    );
    return '$_temp0';
  }

  @override
  String get seasonComplete => 'Η σεζόν ολοκληρώθηκε!';

  @override
  String seasonXp(int xp, int perTier) {
    return '$xp / $perTier XP  ·  Κέρδισε XP περνώντας πίστες, ημερήσιες προκλήσεις και διαδρομές στο Ατελείωτο';
  }

  @override
  String get unlockPremium => 'Ξεκλείδωσε το Premium';

  @override
  String get or => 'ή';

  @override
  String get trackFree => 'ΔΩΡΕΑΝ';

  @override
  String get trackPremium => 'PREMIUM';

  @override
  String get tabSkins => 'Εμφανίσεις';

  @override
  String get tabRopes => 'Σχοινιά';

  @override
  String get tabTrails => 'Ίχνη';

  @override
  String get tabFails => 'Γκάφες';

  @override
  String get tabDances => 'Χοροί';

  @override
  String get tabSets => 'Σετ';

  @override
  String get tabGems => 'Πετράδια';

  @override
  String get equipped => 'ΣΕ ΧΡΗΣΗ';

  @override
  String get use => 'Χρήση';

  @override
  String get storeUnavailable =>
      'Το κατάστημα δεν είναι διαθέσιμο αυτή τη στιγμή. Έλεγξε τη σύνδεσή σου και δοκίμασε ξανά αργότερα.';

  @override
  String get restorePurchases => 'Επαναφορά αγορών';

  @override
  String get bestValue => 'ΚΑΛΥΤΕΡΗ ΤΙΜΗ';

  @override
  String plusItem(String item) {
    return '+ $item';
  }

  @override
  String purchaseThanks(String product) {
    return 'Ευχαριστούμε! Ξεκλείδωσες: $product.';
  }

  @override
  String get storeBusy => 'Το κατάστημα είναι απασχολημένο. Δοκίμασε ξανά.';

  @override
  String get purchasesRestored => 'Οι αγορές σου επανήλθαν.';

  @override
  String get storeUnreachable => 'Δεν ήταν δυνατή η σύνδεση με το κατάστημα.';

  @override
  String get purchaseFailed => 'Η αγορά απέτυχε. Δεν χρεώθηκες.';

  @override
  String reminderStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Κράτα το σερί $count ημερών!',
      one: 'Κράτα το σερί $count ημέρας!',
    );
    return '$_temp0';
  }

  @override
  String get reminderStreakBody =>
      'Πέρασε τη σημερινή Ημερήσια Πρόκληση πριν τα μεσάνυχτα.';

  @override
  String get reminderTodayTitle => 'Η σημερινή Ημερήσια Πρόκληση σε περιμένει';

  @override
  String get reminderTodayBody =>
      'Νέα πίστα κάθε μέρα. Πήγαινε να μαζέψεις τα αστέρια!';

  @override
  String get reminderFreshTitle => 'Ήρθε νέα Ημερήσια Πρόκληση';

  @override
  String get reminderFreshBody =>
      'Νέα πίστα, νέο φάντασμα να νικήσεις. Θα πάρεις και τα 3 αστέρια;';

  @override
  String get reminderRestlessTitle => 'Ο Floppy ανυπομονεί';

  @override
  String get reminderRestlessBody =>
      'Η σημερινή Ημερήσια Πρόκληση δεν θα παιχτεί μόνη της.';

  @override
  String get reminderTimeTitle => 'Ώρα για την Ημερήσια Πρόκληση!';

  @override
  String get reminderTimeBody =>
      'Μια γρήγορη κούνια; Πέρασέ τη για να κρατήσεις το σερί σου.';

  @override
  String get reminderChannelDescription =>
      'Μια υπενθύμιση όταν βγαίνει νέα Ημερήσια Πρόκληση.';

  @override
  String get shareTagline => 'Μπορείς καλύτερα;';

  @override
  String get shareCta => 'Floppy Swing - δωρεάν σε iOS & Android';

  @override
  String clipCleared(int level) {
    return 'Πέρασα την πίστα $level!';
  }

  @override
  String clipTime(int level, String time) {
    return 'Πίστα $level σε ${time}s';
  }

  @override
  String clipSaw(int level) {
    return 'Βρήκα ένα πριόνι στην πίστα $level';
  }

  @override
  String clipSpikes(int level) {
    return 'Βρήκα τα αγκάθια στην πίστα $level';
  }

  @override
  String clipPit(int level) {
    return 'Τα αστόχησα όλα στην πίστα $level';
  }

  @override
  String clipStuck(int level) {
    return 'Πήρα έναν υπνάκο στην πίστα $level';
  }

  @override
  String clipLevel(int level) {
    return 'Πίστα $level';
  }

  @override
  String get wordBest => 'ΡΕΚΟΡ';

  @override
  String get wordCheckpoint => 'ΣΗΜΕΙΟ ΕΛΕΓΧΟΥ!';

  @override
  String get wordGo => 'ΠΑΜΕ!';

  @override
  String get wordSmash => 'ΚΡΑΚ!';

  @override
  String get wordKaboom => 'ΚΑΜΠΟΥΜ!';

  @override
  String get wordBonk => 'ΜΠΟΝΚ!';

  @override
  String get wordSaw => 'ΖΖΖΙΝΓΚ!';

  @override
  String get wordSpikes => 'ΑΟΥΤΣ!';

  @override
  String get wordPit => 'ΩΩΩΧ!';

  @override
  String get wordStuck => 'ΖΖΖ...';

  @override
  String get wordConfetti => 'ΓΙΟΥΧΟΥ!';

  @override
  String get wordJackpot => 'ΤΖΑΚΠΟΤ!';

  @override
  String get wordSqueak => 'ΣΚΟΥΙΚ!';

  @override
  String get styleBigSwing => 'ΜΕΓΑΛΗ ΚΟΥΝΙΑ';

  @override
  String get styleSmash => 'ΣΠΑΣΙΜΟ';

  @override
  String get styleFlip => 'ΤΟΥΜΠΑ';

  @override
  String get styleHangTime => 'ΣΤΟΝ ΑΕΡΑ';

  @override
  String get styleCloseCall => 'ΠΑΡΑ ΤΡΙΧΑ';

  @override
  String get world1Name => 'Παιδική Χαρά';

  @override
  String get world1Tagline => 'Κράτα. Κουνήσου. Άφησε. Ούρλιαξε.';

  @override
  String get world2Name => 'Εργοστάσιο';

  @override
  String get world2Tagline => 'Κρίκοι σε ράγες και πεινασμένα πριόνια.';

  @override
  String get world3Name => 'Γυάλινη Πόλη';

  @override
  String get world3Tagline => 'Σπάσε τα. Αναπήδησε.';

  @override
  String get world4Name => 'Ουράνια Νησιά';

  @override
  String get world4Tagline => 'Πέτα με τον αέρα. Πέσε προς τα πάνω.';

  @override
  String get world5Name => 'Βάση Πυραύλων';

  @override
  String get world5Tagline => 'Τα πατώματα γκρεμίζονται. Οι πύραυλοι πετάνε.';

  @override
  String get skinFloppyName => 'Floppy';

  @override
  String get skinFloppyTagline => 'Το αυθεντικό μακαρόνι.';

  @override
  String get skinBananaName => 'Μπανάνα';

  @override
  String get skinBananaTagline => 'Γλιστράει στις κούνιες.';

  @override
  String get skinKnightName => 'Σερ Φλοπ';

  @override
  String get skinKnightTagline => 'Βαριά πανοπλία. Μηδέν χάρη.';

  @override
  String get skinAstronautName => 'Μικρός Αστροναύτης';

  @override
  String get skinAstronautTagline => 'Η βαρύτητα είναι απλώς πρόταση.';

  @override
  String get skinChickenName => 'Λαστιχένιο Κοτόπουλο';

  @override
  String get skinChickenTagline => 'Τσιρίζει σε κάθε χτύπημα. Προφανώς.';

  @override
  String get skinNinjaName => 'Νίντζα Μακαρόνι';

  @override
  String get skinNinjaTagline => 'Αθόρυβος. Θανατηφόρος. Κυρίως αθόρυβος.';

  @override
  String get skinPirateName => 'Καπετάν Φλοπ';

  @override
  String get skinPirateTagline => 'Γιο χο, ωχ όχι.';

  @override
  String get skinRobotName => 'Ρομπο-Μακαρόνι';

  @override
  String get skinRobotTagline => 'Μπιπ. Μπουπ. Μπονκ.';

  @override
  String get skinDinoName => 'Δεινο-Δύναμη';

  @override
  String get skinDinoTagline => 'Μικρά χεράκια. Μεγάλες κούνιες.';

  @override
  String get skinWizardName => 'Φλόπνταλφ';

  @override
  String get skinWizardTagline => 'Δεν θα περάσεις... ουπς.';

  @override
  String get skinGoldenName => 'Χρυσός Φλοπ';

  @override
  String get skinGoldenTagline => 'Μάζεψε και τα 300 αστέρια.';

  @override
  String get itemRopeName => 'Πιστό Σχοινί';

  @override
  String get itemRopeTagline => 'Κάνναβη. Αξιόπιστο. Μπεζ.';

  @override
  String get itemChainName => 'Αλυσίδα';

  @override
  String get itemChainTagline => 'Κλινκ κλινκ κλινκ.';

  @override
  String get itemSpaghettiName => 'Σπαγγέτι';

  @override
  String get itemSpaghettiTagline => 'Al dente. Σχεδόν.';

  @override
  String get itemRainbowName => 'Ουράνιο Τόξο';

  @override
  String get itemRainbowTagline => 'Γεύσου την κούνια.';

  @override
  String get itemLaserName => 'Λέιζερ';

  @override
  String get itemLaserTagline => 'Πιου πιου γάντζος.';

  @override
  String get itemSwooshName => 'Φσσστ';

  @override
  String get itemSwooshTagline => 'Το κλασικό φσσσ.';

  @override
  String get itemSparklesName => 'Λάμψεις';

  @override
  String get itemSparklesTagline => 'Εντυπωσιακό σε κάθε ταχύτητα.';

  @override
  String get itemBubblesName => 'Φούσκες';

  @override
  String get itemBubblesTagline => 'Μπλουμπ μπλουμπ.';

  @override
  String get itemFireName => 'Φωτιά';

  @override
  String get itemFireTagline => 'Καίει!';

  @override
  String get itemGoldName => 'Δουβλόνια';

  @override
  String get itemGoldTagline => 'Σεζόν Πειρατικός Θησαυρός.';

  @override
  String get itemCircuitName => 'Κύκλωμα';

  @override
  String get itemCircuitTagline => 'Σεζόν Ρομπο-Χαμός.';

  @override
  String get itemLeavesName => 'Φύλλα Ζούγκλας';

  @override
  String get itemLeavesTagline => 'Σεζόν Μέρες Δεινοσαύρων.';

  @override
  String get itemStarsName => 'Αστερόσκονη';

  @override
  String get itemStarsTagline => 'Σεζόν Εβδομάδες Μάγων.';

  @override
  String get itemClassicName => 'Κα-πάου';

  @override
  String get itemClassicTagline => 'Αστέρια. Πολλά αστέρια.';

  @override
  String get itemSqueakyName => 'Παιχνίδι που Τσιρίζει';

  @override
  String get itemSqueakyTagline => 'ΣΚΟΥΙΙΙΙΚ.';

  @override
  String get itemConfettiName => 'Πάρτι Κομφετί';

  @override
  String get itemConfettiTagline => 'Η αποτυχία είναι γιορτή.';

  @override
  String get itemCoinpileName => 'Τζακπότ';

  @override
  String get itemCoinpileTagline => 'Σκάσε σε ένα σωρό νομίσματα.';

  @override
  String get itemHopName => 'Χαρούμενο Χοπ';

  @override
  String get itemHopTagline => 'Μπόινγκ μπόινγκ μπόινγκ.';

  @override
  String get itemBackflipName => 'Πίσω Τούμπα';

  @override
  String get itemBackflipTagline => 'Προσγειώνεται τέλεια. Μερικές φορές.';

  @override
  String get itemSpinName => 'Σβούρα';

  @override
  String get itemSpinTagline => 'Γιουουουου!';

  @override
  String get itemFlailName => 'Τρελό Κούνημα';

  @override
  String get itemFlailTagline => 'Σαν φουσκωτό ανθρωπάκι σε βενζινάδικο.';

  @override
  String get setFoodName => 'Μάχη Φαγητού';

  @override
  String get setHeroesName => 'Γενναίοι Ήρωες';

  @override
  String get setRopesName => 'Συλλέκτης Σχοινιών';

  @override
  String get setTrailsName => 'Πρωτοπόρος';

  @override
  String get setFailsName => 'Επικές Γκάφες';

  @override
  String get setDancesName => 'Πίστα Χορού';

  @override
  String get seasonPirateName => 'Πειρατικός Θησαυρός';

  @override
  String get seasonRobotName => 'Ρομπο-Χαμός';

  @override
  String get seasonDinoName => 'Μέρες Δεινοσαύρων';

  @override
  String get seasonWizardName => 'Εβδομάδες Μάγων';

  @override
  String get productStarterPackName => 'Πακέτο Εκκίνησης';

  @override
  String get productStarterPackTagline =>
      '300 πετράδια, 2.500 νομίσματα και το σχοινί Λέιζερ. Μόνο μία φορά!';

  @override
  String get productRemoveAdsName => 'Χωρίς Διαφημίσεις';

  @override
  String get productRemoveAdsTagline =>
      'Τέλος οι διαφημίσεις ανάμεσα στις πίστες. Τα βίντεο μπόνους μένουν προαιρετικά.';

  @override
  String get productSeasonPassName => 'Premium Pass';

  @override
  String get productSeasonPassTagline => 'Η premium διαδρομή αυτής της σεζόν.';

  @override
  String get productGemsSmallName => 'Χούφτα Πετράδια';

  @override
  String get productGemsSmallTagline => '80 πετράδια';

  @override
  String get productGemsMediumName => 'Σακούλα Πετράδια';

  @override
  String get productGemsMediumTagline => '450 πετράδια (+12% μπόνους)';

  @override
  String get productGemsLargeName => 'Σεντούκι Πετράδια';

  @override
  String get productGemsLargeTagline => '1.000 πετράδια (+25% μπόνους)';

  @override
  String get productGemsHugeName => 'Θησαυροφυλάκιο';

  @override
  String get productGemsHugeTagline => '2.200 πετράδια (+37% μπόνους)';

  @override
  String get hintLevel1 =>
      'Κράτα πατημένο οπουδήποτε για να πιάσεις τον κρίκο που λάμπει. Άφησε για να πετάξεις!';

  @override
  String get hintLevel2 =>
      'Άφησε όσο η κούνια ανεβαίνει για να πετάξεις πιο μακριά.';

  @override
  String get hintLevel3 => 'Το κόκκινο πονάει. Μην ακουμπήσεις τα αγκάθια!';

  @override
  String get hintLevel5 => 'Αγκάθια και από πάνω. Μην πετάξεις πολύ ψηλά!';

  @override
  String get hintLevel6 =>
      'Τα πράσινα τραμπολίνα σε πετάνε ψηλά. Πέρνα με αυτά τα μεγάλα κενά.';

  @override
  String get hintLevel7 =>
      'Τα πριόνια γυρίζουν. Τα πριόνια πονάνε. Πέρνα γύρω τους.';

  @override
  String get hintLevel8 =>
      'Οι σημαίες είναι σημεία ελέγχου. Αν πέσεις, ξαναζωντανεύεις εκεί.';

  @override
  String get hintLevel9 => 'Μερικά πριόνια κινούνται. Πρόσεξε τον ρυθμό.';

  @override
  String get hintLevel12 => 'Κουνήσου ψηλά και άφησε για να ανέβεις.';

  @override
  String get hintLevel14 => 'Ό,τι ανεβαίνει... συνήθως κατεβαίνει.';

  @override
  String get hintLevel15 => 'Όλα μαζί. Καλή τύχη!';

  @override
  String get hintLevel21 =>
      'Μερικοί κρίκοι κινούνται. Πιάσ\' τους την κατάλληλη στιγμή!';

  @override
  String get hintLevel41 =>
      'Το γυαλί σπάει αν το χτυπήσεις αρκετά γρήγορα. Πέρνα από μέσα!';

  @override
  String get hintLevel61 =>
      'Οι ανεμιστήρες σε σπρώχνουν προς τα πάνω. Πέτα με τον αέρα!';

  @override
  String get hintLevel64 =>
      'Οι μωβ ζώνες αντιστρέφουν τη βαρύτητα. Το πάνω είναι το νέο κάτω.';

  @override
  String get hintLevel81 =>
      'Οι πλατφόρμες που θρυμματίζονται πέφτουν λίγο αφού πατήσεις. Μη σταματάς!';

  @override
  String get hintLevel84 =>
      'Οι πύραυλοι δεν σε σκοτώνουν... τα αγκάθια όμως ναι.';
}
