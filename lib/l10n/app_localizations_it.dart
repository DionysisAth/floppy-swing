// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get back => 'Indietro';

  @override
  String get cancel => 'Annulla';

  @override
  String get settings => 'Impostazioni';

  @override
  String get leaderboards => 'Classifiche';

  @override
  String get leaderboard => 'Classifica';

  @override
  String get achievements => 'Obiettivi';

  @override
  String get challengeCode => 'Codice sfida';

  @override
  String couldNotSignIn(String service) {
    return 'Impossibile accedere a $service.';
  }

  @override
  String get play => 'GIOCA';

  @override
  String get endless => 'INFINITA';

  @override
  String endlessBest(int distance) {
    return 'Record $distance m';
  }

  @override
  String get endlessPitch => 'Fin dove arriverai?';

  @override
  String get shop => 'NEGOZIO';

  @override
  String get shopPitch => 'Skin, corde e altro';

  @override
  String get pass => 'PASS';

  @override
  String passTier(int tier, int total) {
    return 'Grado $tier/$total';
  }

  @override
  String get daily => 'GIORNALIERA';

  @override
  String dailyDone(int streak) {
    return 'Fatto! 🔥 $streak';
  }

  @override
  String dailyKeepStreak(int streak) {
    return 'Tieni la 🔥 $streak';
  }

  @override
  String get dailyNew => 'Nuova sfida!';

  @override
  String get challengeCodeHint => 'Codice o link di un amico';

  @override
  String get playEndless => 'Gioca Infinita';

  @override
  String get settingsTitle => 'IMPOSTAZIONI';

  @override
  String get music => 'Musica';

  @override
  String get soundEffects => 'Effetti sonori';

  @override
  String get muteAll => 'Silenzia tutto';

  @override
  String get vibration => 'Vibrazione';

  @override
  String get dailyReminders => 'Promemoria della Sfida giornaliera';

  @override
  String get language => 'Lingua';

  @override
  String get languageAuto => 'Lingua del telefono';

  @override
  String get privacyOptions => 'Opzioni privacy';

  @override
  String get resetProgress => 'Azzera i progressi';

  @override
  String get fonts => 'Caratteri';

  @override
  String gamesNotSetUp(String service) {
    return 'Classifiche, obiettivi e salvataggio nel cloud arrivano con $service. Non ancora configurati in questa versione.';
  }

  @override
  String gamesSignedIn(String service) {
    return 'Accesso effettuato. I tuoi progressi sono salvati nel tuo account $service.';
  }

  @override
  String gamesSignedInAs(String name, String service) {
    return 'Accesso effettuato come $name. I tuoi progressi sono salvati nel tuo account $service.';
  }

  @override
  String get gamesSignInPitch =>
      'Accedi per salvare i tuoi progressi ed entrare nelle classifiche.';

  @override
  String get signIn => 'Accedi';

  @override
  String get resetTitle => 'Azzerare i progressi?';

  @override
  String get resetBody =>
      'Perderai stelle, monete e skin. Non si può annullare.';

  @override
  String get reset => 'Azzera';

  @override
  String clipFailed(String error) {
    return 'Impossibile creare la clip: $error';
  }

  @override
  String challengeShare(int distance, String link, String code) {
    return 'Ho fatto $distance m in Floppy Swing modalità Infinita. Riesci a battermi? $link\n(Oppure tocca \"Codice sfida\" nel menu e inserisci $code.)';
  }

  @override
  String get hintRevived => 'Rianimato! Tieni premuto per dondolare.';

  @override
  String get hintHold => 'Tieni premuto ovunque per dondolare!';

  @override
  String get failSpikes1 => 'Di punta.';

  @override
  String get failSpikes2 => 'Questo lascerà il segno.';

  @override
  String get failSpikes3 => 'Spuntoni: 1, Tu: 0';

  @override
  String get failSaw1 => 'Affettato a dovere!';

  @override
  String get failSaw2 => 'Non l\'hai vista arrivare?';

  @override
  String get failSaw3 => 'Bzzzzt!';

  @override
  String get failPit1 => 'La gravità vince ancora.';

  @override
  String get failPit2 => 'Giù di sotto!';

  @override
  String get failPit3 => 'Il pavimento punge.';

  @override
  String get failStuck1 => 'Pisolino?';

  @override
  String get failStuck2 => 'Attaccato come colla.';

  @override
  String get failStuck3 => 'Ti prendi una pausa?';

  @override
  String get tapToRetry => 'Tocca ovunque per riprovare';

  @override
  String get shareFail => 'Condividi il fail';

  @override
  String get challengeFriend => 'Sfida un amico';

  @override
  String get newCourse => 'Nuovo percorso';

  @override
  String get skipLevel => 'Salta livello';

  @override
  String get revive => 'Rianima';

  @override
  String rankWorldwide(int rank) {
    return '#$rank nel mondo';
  }

  @override
  String get newBest => 'NUOVO RECORD!';

  @override
  String meters(int distance) {
    return '$distance m';
  }

  @override
  String endlessScore(int score, int best) {
    return 'Punti $score  ·  Record $best';
  }

  @override
  String get newBestToday => 'Nuovo miglior tempo di oggi!';

  @override
  String rankToday(int rank) {
    return '#$rank oggi';
  }

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count giorni di fila',
      one: '🔥 $count giorno di fila',
    );
    return '$_temp0';
  }

  @override
  String dayStreakBonus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count giorni di fila - gemme bonus!',
      one: '🔥 $count giorno di fila - gemme bonus!',
    );
    return '$_temp0';
  }

  @override
  String get dailyClear => 'SFIDA SUPERATA!';

  @override
  String get worldClear => 'MONDO COMPLETATO!';

  @override
  String get levelClear => 'LIVELLO SUPERATO!';

  @override
  String get statTime => 'Tempo';

  @override
  String statTarget(String time) {
    return 'obiettivo ${time}s';
  }

  @override
  String get statCoins => 'Monete';

  @override
  String get statStyle => 'Stile';

  @override
  String get statBest => 'Record';

  @override
  String get starFinish => 'Traguardo';

  @override
  String newStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '(+$count stelle)',
      one: '(+$count stella)',
    );
    return '$_temp0';
  }

  @override
  String worldGate(int count, String world) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Raccogli ancora $count stelle per aprire $world!',
      one: 'Raccogli ancora $count stella per aprire $world!',
    );
    return '$_temp0';
  }

  @override
  String get doubleCoins => 'Raddoppia le monete';

  @override
  String get retry => 'Riprova';

  @override
  String get share => 'Condividi';

  @override
  String get next => 'Avanti';

  @override
  String get done => 'Fine';

  @override
  String get levels => 'Livelli';

  @override
  String get quit => 'Esci';

  @override
  String get paused => 'PAUSA';

  @override
  String get resume => 'Riprendi';

  @override
  String get restart => 'Ricomincia';

  @override
  String get pause => 'Pausa';

  @override
  String zoneBanner(int number, String name) {
    return 'ZONA $number: $name';
  }

  @override
  String hudDaily(String name) {
    return 'GIORNALIERA: $name';
  }

  @override
  String hudStyle(int score) {
    return 'STILE $score';
  }

  @override
  String get slowMoReplay => 'REPLAY AL RALLENTATORE';

  @override
  String get makingClip => 'Sto creando la tua clip…';

  @override
  String worldNumber(int number) {
    return 'MONDO $number';
  }

  @override
  String get previousWorld => 'Mondo precedente';

  @override
  String get nextWorld => 'Mondo successivo';

  @override
  String collectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Raccogline ancora $count',
      one: 'Raccogline ancora $count',
    );
    return '$_temp0';
  }

  @override
  String starsOf(int have, int need) {
    return '$have/$need stelle';
  }

  @override
  String levelTile(int number, String name) {
    return 'Livello $number, $name';
  }

  @override
  String levelTileLocked(int number, String name) {
    return 'Livello $number, $name, bloccato';
  }

  @override
  String get dailyBonus => 'BONUS GIORNALIERO';

  @override
  String get dailyBonusPitch =>
      'Torna ogni giorno per premi sempre più grandi!';

  @override
  String get claim => 'Riscatta';

  @override
  String dayNumber(int day) {
    return 'Giorno $day';
  }

  @override
  String get seasonPassTitle => 'PASS STAGIONALE';

  @override
  String get seasonPass => 'Pass stagionale';

  @override
  String tierNumber(int tier) {
    return 'Grado $tier';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mancano $count giorni',
      one: 'Manca $count giorno',
    );
    return '$_temp0';
  }

  @override
  String get seasonComplete => 'Stagione completata!';

  @override
  String seasonXp(int xp, int perTier) {
    return '$xp / $perTier XP  ·  Guadagna XP completando livelli, sfide giornaliere e partite in Infinita';
  }

  @override
  String get unlockPremium => 'Sblocca Premium';

  @override
  String get or => 'oppure';

  @override
  String get trackFree => 'GRATIS';

  @override
  String get trackPremium => 'PREMIUM';

  @override
  String get tabSkins => 'Skin';

  @override
  String get tabRopes => 'Corde';

  @override
  String get tabTrails => 'Scie';

  @override
  String get tabFails => 'Fail';

  @override
  String get tabDances => 'Balli';

  @override
  String get tabSets => 'Set';

  @override
  String get tabGems => 'Gemme';

  @override
  String get equipped => 'IN USO';

  @override
  String get use => 'Usa';

  @override
  String get storeUnavailable =>
      'Il negozio non è raggiungibile al momento. Controlla la connessione e riprova più tardi.';

  @override
  String get restorePurchases => 'Ripristina acquisti';

  @override
  String get bestValue => 'PIÙ CONVENIENTE';

  @override
  String plusItem(String item) {
    return '+ $item';
  }

  @override
  String purchaseThanks(String product) {
    return 'Grazie! $product sbloccato.';
  }

  @override
  String get storeBusy => 'Il negozio è occupato. Riprova.';

  @override
  String get purchasesRestored => 'Acquisti ripristinati.';

  @override
  String get storeUnreachable => 'Impossibile raggiungere il negozio.';

  @override
  String get purchaseFailed =>
      'Acquisto non riuscito. Non ti è stato addebitato nulla.';

  @override
  String reminderStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tieni viva la serie di $count giorni!',
      one: 'Tieni viva la serie di $count giorno!',
    );
    return '$_temp0';
  }

  @override
  String get reminderStreakBody =>
      'Supera la Sfida giornaliera di oggi prima di mezzanotte.';

  @override
  String get reminderTodayTitle => 'La Sfida giornaliera di oggi ti aspetta';

  @override
  String get reminderTodayBody =>
      'Un nuovo livello ogni giorno. Vai a prenderti quelle stelle!';

  @override
  String get reminderFreshTitle => 'È arrivata una nuova Sfida giornaliera';

  @override
  String get reminderFreshBody =>
      'Nuovo livello, nuovo fantasma da battere. Prenderai tutte e 3 le stelle?';

  @override
  String get reminderRestlessTitle => 'Floppy si sta spazientendo';

  @override
  String get reminderRestlessBody =>
      'La Sfida giornaliera di oggi non si gioca da sola.';

  @override
  String get reminderTimeTitle => 'È l\'ora della Sfida giornaliera!';

  @override
  String get reminderTimeBody =>
      'Una dondolata veloce? Superala per tenere viva la serie.';

  @override
  String get reminderChannelDescription =>
      'Un avviso quando esce una nuova Sfida giornaliera.';

  @override
  String get shareTagline => 'Sai fare di meglio?';

  @override
  String get shareCta => 'Floppy Swing - gratis su iOS e Android';

  @override
  String clipCleared(int level) {
    return 'Livello $level superato!';
  }

  @override
  String clipTime(int level, String time) {
    return 'Livello $level in ${time}s';
  }

  @override
  String clipSaw(int level) {
    return 'Ho incontrato una sega al livello $level';
  }

  @override
  String clipSpikes(int level) {
    return 'Ho trovato gli spuntoni al livello $level';
  }

  @override
  String clipPit(int level) {
    return 'Ho mancato tutto al livello $level';
  }

  @override
  String clipStuck(int level) {
    return 'Ho fatto un pisolino al livello $level';
  }

  @override
  String clipLevel(int level) {
    return 'Livello $level';
  }

  @override
  String get wordBest => 'RECORD';

  @override
  String get wordCheckpoint => 'CHECKPOINT!';

  @override
  String get wordGo => 'VIA!';

  @override
  String get wordSmash => 'CRASH!';

  @override
  String get wordKaboom => 'KABOOM!';

  @override
  String get wordBonk => 'BONK!';

  @override
  String get wordSaw => 'ZZZING!';

  @override
  String get wordSpikes => 'AHIA!';

  @override
  String get wordPit => 'AHIAAA!';

  @override
  String get wordStuck => 'ZZZ...';

  @override
  String get wordConfetti => 'EVVAI!';

  @override
  String get wordJackpot => 'JACKPOT!';

  @override
  String get wordSqueak => 'SQUIT!';

  @override
  String get styleBigSwing => 'SUPER GIRO';

  @override
  String get styleSmash => 'SFONDAMENTO';

  @override
  String get styleFlip => 'CAPRIOLA';

  @override
  String get styleHangTime => 'IN VOLO';

  @override
  String get styleCloseCall => 'PER UN PELO';

  @override
  String get world1Name => 'Parco giochi';

  @override
  String get world1Tagline => 'Tieni. Dondola. Lascia. Urla.';

  @override
  String get world2Name => 'Fabbrica';

  @override
  String get world2Tagline => 'Anelli su binari e seghe affamate.';

  @override
  String get world3Name => 'Città di vetro';

  @override
  String get world3Tagline => 'Sfonda. Rimbalza.';

  @override
  String get world4Name => 'Isole del cielo';

  @override
  String get world4Tagline => 'Cavalca il vento. Cadi verso l\'alto.';

  @override
  String get world5Name => 'Base missilistica';

  @override
  String get world5Tagline => 'I pavimenti crollano. I razzi volano.';

  @override
  String get skinFloppyName => 'Floppy';

  @override
  String get skinFloppyTagline => 'Lo spaghetto originale.';

  @override
  String get skinBananaName => 'Banana';

  @override
  String get skinBananaTagline => 'Scivolosa quando dondola.';

  @override
  String get skinKnightName => 'Sir Flops';

  @override
  String get skinKnightTagline => 'Armatura pesante. Grazia zero.';

  @override
  String get skinAstronautName => 'Cadetto spaziale';

  @override
  String get skinAstronautTagline => 'La gravità è solo un suggerimento.';

  @override
  String get skinChickenName => 'Pollo di gomma';

  @override
  String get skinChickenTagline => 'Squittisce all\'impatto. Ovviamente.';

  @override
  String get skinNinjaName => 'Ninja spaghetto';

  @override
  String get skinNinjaTagline => 'Silenzioso. Letale. Quasi sempre silenzioso.';

  @override
  String get skinPirateName => 'Capitan Flop';

  @override
  String get skinPirateTagline => 'Yo-ho, oh no.';

  @override
  String get skinRobotName => 'Robo-spaghetto';

  @override
  String get skinRobotTagline => 'Bip. Bup. Bonk.';

  @override
  String get skinDinoName => 'Dino-mite';

  @override
  String get skinDinoTagline => 'Braccine corte. Grandi dondolate.';

  @override
  String get skinWizardName => 'Flopdalf';

  @override
  String get skinWizardTagline => 'Tu non puoi passare... ops.';

  @override
  String get skinGoldenName => 'Flop d\'oro';

  @override
  String get skinGoldenTagline => 'Raccogli tutte le 300 stelle.';

  @override
  String get itemRopeName => 'Corda fidata';

  @override
  String get itemRopeTagline => 'Canapa. Affidabile. Beige.';

  @override
  String get itemChainName => 'Catena';

  @override
  String get itemChainTagline => 'Clink clink clink.';

  @override
  String get itemSpaghettiName => 'Spaghetto';

  @override
  String get itemSpaghettiTagline => 'Al dente. Quasi.';

  @override
  String get itemRainbowName => 'Arcobaleno';

  @override
  String get itemRainbowTagline => 'Dondola a colori.';

  @override
  String get itemLaserName => 'Laser';

  @override
  String get itemLaserTagline => 'Rampino piu piu.';

  @override
  String get itemSwooshName => 'Swoosh';

  @override
  String get itemSwooshTagline => 'Il classico fruscio.';

  @override
  String get itemSparklesName => 'Scintille';

  @override
  String get itemSparklesTagline => 'Favoloso a ogni velocità.';

  @override
  String get itemBubblesName => 'Bolle';

  @override
  String get itemBubblesTagline => 'Blub blub.';

  @override
  String get itemFireName => 'Fuoco';

  @override
  String get itemFireTagline => 'Troppo caldo da gestire.';

  @override
  String get itemGoldName => 'Dobloni';

  @override
  String get itemGoldTagline => 'Stagione Bottino pirata.';

  @override
  String get itemCircuitName => 'Circuito';

  @override
  String get itemCircuitTagline => 'Stagione Robo-rissa.';

  @override
  String get itemLeavesName => 'Foglie della giungla';

  @override
  String get itemLeavesTagline => 'Stagione Giorni dei dino.';

  @override
  String get itemStarsName => 'Polvere di stelle';

  @override
  String get itemStarsTagline => 'Stagione Settimane dei maghi.';

  @override
  String get itemClassicName => 'Kapow';

  @override
  String get itemClassicTagline => 'Stelle. Tante stelle.';

  @override
  String get itemSqueakyName => 'Giocattolo che squittisce';

  @override
  String get itemSqueakyTagline => 'SQUIIIIIT.';

  @override
  String get itemConfettiName => 'Festa coriandoli';

  @override
  String get itemConfettiTagline => 'Fallire è una festa.';

  @override
  String get itemCoinpileName => 'Jackpot';

  @override
  String get itemCoinpileTagline => 'Esplodi in un mucchio di monete.';

  @override
  String get itemHopName => 'Saltello felice';

  @override
  String get itemHopTagline => 'Boing boing boing.';

  @override
  String get itemBackflipName => 'Salto all\'indietro';

  @override
  String get itemBackflipTagline => 'Atterraggio perfetto. A volte.';

  @override
  String get itemSpinName => 'Tornado';

  @override
  String get itemSpinTagline => 'Uiiiiii!';

  @override
  String get itemFlailName => 'Agitazione folle';

  @override
  String get itemFlailTagline => 'Energia da pupazzo gonfiabile.';

  @override
  String get setFoodName => 'Battaglia di cibo';

  @override
  String get setHeroesName => 'Eroi coraggiosi';

  @override
  String get setRopesName => 'Collezionista di corde';

  @override
  String get setTrailsName => 'Pioniere';

  @override
  String get setFailsName => 'Fail epici';

  @override
  String get setDancesName => 'Pista da ballo';

  @override
  String get seasonPirateName => 'Bottino pirata';

  @override
  String get seasonRobotName => 'Robo-rissa';

  @override
  String get seasonDinoName => 'Giorni dei dino';

  @override
  String get seasonWizardName => 'Settimane dei maghi';

  @override
  String get productStarterPackName => 'Pacchetto iniziale';

  @override
  String get productStarterPackTagline =>
      '300 gemme, 2.500 monete e la corda Laser. Una volta sola!';

  @override
  String get productRemoveAdsName => 'Niente pubblicità';

  @override
  String get productRemoveAdsTagline =>
      'Basta pubblicità tra i livelli. I video bonus restano facoltativi.';

  @override
  String get productSeasonPassName => 'Pass Premium';

  @override
  String get productSeasonPassTagline =>
      'Il percorso premium di questa stagione.';

  @override
  String get productGemsSmallName => 'Manciata di gemme';

  @override
  String get productGemsSmallTagline => '80 gemme';

  @override
  String get productGemsMediumName => 'Sacchetto di gemme';

  @override
  String get productGemsMediumTagline => '450 gemme (+12% bonus)';

  @override
  String get productGemsLargeName => 'Forziere di gemme';

  @override
  String get productGemsLargeTagline => '1.000 gemme (+25% bonus)';

  @override
  String get productGemsHugeName => 'Caveau di gemme';

  @override
  String get productGemsHugeTagline => '2.200 gemme (+37% bonus)';

  @override
  String get hintLevel1 =>
      'Tieni premuto ovunque per afferrare l\'anello luminoso. Lascia per volare!';

  @override
  String get hintLevel2 => 'Lascia mentre sali per volare più lontano.';

  @override
  String get hintLevel3 => 'Rosso vuol dire ahia. Non toccare gli spuntoni!';

  @override
  String get hintLevel5 => 'Spuntoni anche sopra. Non volare troppo in alto!';

  @override
  String get hintLevel6 =>
      'I trampolini verdi ti lanciano in alto. Usali per superare i grandi vuoti.';

  @override
  String get hintLevel7 =>
      'Le seghe girano. Le seghe fanno male. Passa intorno.';

  @override
  String get hintLevel8 =>
      'Le bandiere sono checkpoint. Se cadi, riparti da lì.';

  @override
  String get hintLevel9 => 'Alcune seghe si muovono. Osserva il ritmo.';

  @override
  String get hintLevel12 => 'Dondola in alto e lascia per salire.';

  @override
  String get hintLevel14 => 'Ciò che sale... di solito scende.';

  @override
  String get hintLevel15 => 'Tutto insieme. Buona fortuna!';

  @override
  String get hintLevel21 =>
      'Alcuni anelli si muovono. Afferrali al momento giusto!';

  @override
  String get hintLevel41 =>
      'Il vetro si rompe se lo colpisci abbastanza veloce. Sfondalo!';

  @override
  String get hintLevel61 =>
      'I ventilatori ti spingono in alto. Cavalca il vento!';

  @override
  String get hintLevel64 =>
      'Le zone viola invertono la gravità. Su è il nuovo giù.';

  @override
  String get hintLevel81 =>
      'Le piattaforme friabili cadono poco dopo che ci atterri. Non fermarti!';

  @override
  String get hintLevel84 => 'I razzi non ti uccidono... ma gli spuntoni sì.';
}
