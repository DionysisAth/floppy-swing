// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get back => 'Retour';

  @override
  String get cancel => 'Annuler';

  @override
  String get settings => 'Paramètres';

  @override
  String get leaderboards => 'Classements';

  @override
  String get leaderboard => 'Classement';

  @override
  String get achievements => 'Succès';

  @override
  String get challengeCode => 'Code défi';

  @override
  String couldNotSignIn(String service) {
    return 'Connexion à $service impossible.';
  }

  @override
  String get play => 'JOUER';

  @override
  String get endless => 'INFINI';

  @override
  String endlessBest(int distance) {
    return 'Record $distance m';
  }

  @override
  String get endlessPitch => 'Jusqu\'où iras-tu ?';

  @override
  String get shop => 'BOUTIQUE';

  @override
  String get shopPitch => 'Skins, cordes et plus';

  @override
  String get pass => 'PASSE';

  @override
  String passTier(int tier, int total) {
    return 'Palier $tier/$total';
  }

  @override
  String get daily => 'DÉFI DU JOUR';

  @override
  String dailyDone(int streak) {
    return 'Fait ! 🔥 $streak';
  }

  @override
  String dailyKeepStreak(int streak) {
    return 'Garde ta 🔥 $streak';
  }

  @override
  String get dailyNew => 'Nouveau défi !';

  @override
  String get challengeCodeHint => 'Code ou lien d\'un ami';

  @override
  String get playEndless => 'Jouer en Infini';

  @override
  String get settingsTitle => 'PARAMÈTRES';

  @override
  String get music => 'Musique';

  @override
  String get soundEffects => 'Effets sonores';

  @override
  String get muteAll => 'Tout couper';

  @override
  String get vibration => 'Vibrations';

  @override
  String get dailyReminders => 'Rappels du Défi du jour';

  @override
  String get language => 'Langue';

  @override
  String get languageAuto => 'Langue du téléphone';

  @override
  String get privacyOptions => 'Options de confidentialité';

  @override
  String get resetProgress => 'Réinitialiser la progression';

  @override
  String get fonts => 'Polices';

  @override
  String gamesNotSetUp(String service) {
    return 'Les classements, les succès et la sauvegarde cloud arrivent avec $service. Pas encore configurés dans cette version.';
  }

  @override
  String gamesSignedIn(String service) {
    return 'Connecté. Ta progression est sauvegardée sur ton compte $service.';
  }

  @override
  String gamesSignedInAs(String name, String service) {
    return 'Connecté en tant que $name. Ta progression est sauvegardée sur ton compte $service.';
  }

  @override
  String get gamesSignInPitch =>
      'Connecte-toi pour sauvegarder ta progression et entrer dans les classements.';

  @override
  String get signIn => 'Se connecter';

  @override
  String get resetTitle => 'Réinitialiser la progression ?';

  @override
  String get resetBody =>
      'Tes étoiles, pièces et skins seront effacés. C\'est irréversible.';

  @override
  String get reset => 'Réinitialiser';

  @override
  String clipFailed(String error) {
    return 'Impossible de créer le clip : $error';
  }

  @override
  String challengeShare(int distance, String link, String code) {
    return 'J\'ai parcouru $distance m dans Floppy Swing Infini. Tu peux me battre ? $link\n(Ou touche « Code défi » dans le menu et entre $code.)';
  }

  @override
  String get hintRevived => 'Ressuscité ! Maintiens pour te balancer.';

  @override
  String get hintHold => 'Maintiens n\'importe où pour te balancer !';

  @override
  String get failSpikes1 => 'La pointe en premier.';

  @override
  String get failSpikes2 => 'Ça va laisser des traces.';

  @override
  String get failSpikes3 => 'Piques : 1, Toi : 0';

  @override
  String get failSaw1 => 'Coupé en rondelles !';

  @override
  String get failSaw2 => 'Tu l\'as pas vue venir ?';

  @override
  String get failSaw3 => 'Bzzzzt !';

  @override
  String get failPit1 => 'La gravité gagne encore.';

  @override
  String get failPit2 => 'Et ça tombe !';

  @override
  String get failPit3 => 'Le sol pique.';

  @override
  String get failStuck1 => 'C\'est l\'heure de la sieste ?';

  @override
  String get failStuck2 => 'Collé comme un chewing-gum.';

  @override
  String get failStuck3 => 'Une petite pause ?';

  @override
  String get tapToRetry => 'Touche n\'importe où pour réessayer';

  @override
  String get shareFail => 'Partager le fail';

  @override
  String get challengeFriend => 'Défier un ami';

  @override
  String get newCourse => 'Nouveau parcours';

  @override
  String get skipLevel => 'Passer le niveau';

  @override
  String get revive => 'Revivre';

  @override
  String rankWorldwide(int rank) {
    return '#$rank mondial';
  }

  @override
  String get newBest => 'NOUVEAU RECORD !';

  @override
  String meters(int distance) {
    return '$distance m';
  }

  @override
  String endlessScore(int score, int best) {
    return 'Score $score  ·  Record $best';
  }

  @override
  String get newBestToday => 'Nouveau meilleur temps aujourd\'hui !';

  @override
  String rankToday(int rank) {
    return '#$rank aujourd\'hui';
  }

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count jours d\'affilée',
      one: '🔥 $count jour d\'affilée',
    );
    return '$_temp0';
  }

  @override
  String dayStreakBonus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count jours d\'affilée - gemmes bonus !',
      one: '🔥 $count jour d\'affilée - gemmes bonus !',
    );
    return '$_temp0';
  }

  @override
  String get dailyClear => 'DÉFI RÉUSSI !';

  @override
  String get worldClear => 'MONDE TERMINÉ !';

  @override
  String get levelClear => 'NIVEAU RÉUSSI !';

  @override
  String get statTime => 'Temps';

  @override
  String statTarget(String time) {
    return 'objectif ${time}s';
  }

  @override
  String get statCoins => 'Pièces';

  @override
  String get statStyle => 'Style';

  @override
  String get statBest => 'Record';

  @override
  String get starFinish => 'Arrivée';

  @override
  String newStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '(+$count étoiles)',
      one: '(+$count étoile)',
    );
    return '$_temp0';
  }

  @override
  String worldGate(int count, String world) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Récupère encore $count étoiles pour ouvrir $world !',
      one: 'Récupère encore $count étoile pour ouvrir $world !',
    );
    return '$_temp0';
  }

  @override
  String get doubleCoins => 'Doubler les pièces';

  @override
  String get retry => 'Réessayer';

  @override
  String get share => 'Partager';

  @override
  String get next => 'Suivant';

  @override
  String get done => 'Terminé';

  @override
  String get levels => 'Niveaux';

  @override
  String get quit => 'Quitter';

  @override
  String get paused => 'PAUSE';

  @override
  String get resume => 'Reprendre';

  @override
  String get restart => 'Recommencer';

  @override
  String get pause => 'Pause';

  @override
  String zoneBanner(int number, String name) {
    return 'ZONE $number : $name';
  }

  @override
  String hudDaily(String name) {
    return 'DÉFI : $name';
  }

  @override
  String hudStyle(int score) {
    return 'STYLE $score';
  }

  @override
  String get slowMoReplay => 'RALENTI';

  @override
  String get makingClip => 'Création de ton clip…';

  @override
  String worldNumber(int number) {
    return 'MONDE $number';
  }

  @override
  String get previousWorld => 'Monde précédent';

  @override
  String get nextWorld => 'Monde suivant';

  @override
  String collectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encore $count',
      one: 'Encore $count',
    );
    return '$_temp0';
  }

  @override
  String starsOf(int have, int need) {
    return '$have/$need étoiles';
  }

  @override
  String levelTile(int number, String name) {
    return 'Niveau $number, $name';
  }

  @override
  String levelTileLocked(int number, String name) {
    return 'Niveau $number, $name, verrouillé';
  }

  @override
  String get dailyBonus => 'BONUS DU JOUR';

  @override
  String get dailyBonusPitch =>
      'Reviens chaque jour pour de plus grosses récompenses !';

  @override
  String get claim => 'Récupérer';

  @override
  String dayNumber(int day) {
    return 'Jour $day';
  }

  @override
  String get seasonPassTitle => 'PASSE DE SAISON';

  @override
  String get seasonPass => 'Passe de saison';

  @override
  String tierNumber(int tier) {
    return 'Palier $tier';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours restants',
      one: '$count jour restant',
    );
    return '$_temp0';
  }

  @override
  String get seasonComplete => 'Saison terminée !';

  @override
  String seasonXp(int xp, int perTier) {
    return '$xp / $perTier XP  ·  Gagne de l\'XP en finissant des niveaux, des défis du jour et des parties Infini';
  }

  @override
  String get unlockPremium => 'Débloquer Premium';

  @override
  String get or => 'ou';

  @override
  String get trackFree => 'GRATUIT';

  @override
  String get trackPremium => 'PREMIUM';

  @override
  String get tabSkins => 'Skins';

  @override
  String get tabRopes => 'Cordes';

  @override
  String get tabTrails => 'Traînées';

  @override
  String get tabFails => 'Fails';

  @override
  String get tabDances => 'Danses';

  @override
  String get tabSets => 'Collections';

  @override
  String get tabGems => 'Gemmes';

  @override
  String get equipped => 'ÉQUIPÉ';

  @override
  String get use => 'Utiliser';

  @override
  String get storeUnavailable =>
      'La boutique est inaccessible pour le moment. Vérifie ta connexion et réessaie plus tard.';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get bestValue => 'MEILLEURE OFFRE';

  @override
  String plusItem(String item) {
    return '+ $item';
  }

  @override
  String purchaseThanks(String product) {
    return 'Merci ! $product débloqué.';
  }

  @override
  String get storeBusy => 'La boutique est occupée. Réessaie.';

  @override
  String get purchasesRestored => 'Achats restaurés.';

  @override
  String get storeUnreachable => 'Impossible de joindre la boutique.';

  @override
  String get purchaseFailed => 'L\'achat a échoué. Tu n\'as pas été débité.';

  @override
  String reminderStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Garde ta série de $count jours !',
      one: 'Garde ta série de $count jour !',
    );
    return '$_temp0';
  }

  @override
  String get reminderStreakBody => 'Termine le Défi du jour avant minuit.';

  @override
  String get reminderTodayTitle => 'Le Défi du jour t\'attend';

  @override
  String get reminderTodayBody =>
      'Un nouveau niveau chaque jour. Va chercher ces étoiles !';

  @override
  String get reminderFreshTitle => 'Un nouveau Défi du jour est arrivé';

  @override
  String get reminderFreshBody =>
      'Nouveau niveau, nouveau fantôme à battre. Tu auras les 3 étoiles ?';

  @override
  String get reminderRestlessTitle => 'Floppy s\'impatiente';

  @override
  String get reminderRestlessBody =>
      'Le Défi du jour ne va pas se balancer tout seul.';

  @override
  String get reminderTimeTitle => 'C\'est l\'heure du Défi du jour !';

  @override
  String get reminderTimeBody =>
      'Un petit balancement ? Réussis-le pour garder ta série.';

  @override
  String get reminderChannelDescription =>
      'Un petit rappel quand un nouveau Défi du jour est disponible.';

  @override
  String get shareTagline => 'Tu peux faire mieux ?';

  @override
  String get shareCta => 'Floppy Swing - gratuit sur iOS et Android';

  @override
  String clipCleared(int level) {
    return 'Niveau $level réussi !';
  }

  @override
  String clipTime(int level, String time) {
    return 'Niveau $level en ${time}s';
  }

  @override
  String clipSaw(int level) {
    return 'J\'ai croisé une scie au niveau $level';
  }

  @override
  String clipSpikes(int level) {
    return 'J\'ai trouvé les piques au niveau $level';
  }

  @override
  String clipPit(int level) {
    return 'J\'ai tout raté au niveau $level';
  }

  @override
  String clipStuck(int level) {
    return 'J\'ai fait la sieste au niveau $level';
  }

  @override
  String clipLevel(int level) {
    return 'Niveau $level';
  }

  @override
  String get wordBest => 'RECORD';

  @override
  String get wordCheckpoint => 'CHECKPOINT !';

  @override
  String get wordGo => 'GO !';

  @override
  String get wordSmash => 'CRAC !';

  @override
  String get wordKaboom => 'KABOUM !';

  @override
  String get wordBonk => 'BONK !';

  @override
  String get wordSaw => 'ZZZING !';

  @override
  String get wordSpikes => 'AÏE !';

  @override
  String get wordPit => 'OUILLE !';

  @override
  String get wordStuck => 'ZZZ...';

  @override
  String get wordConfetti => 'YOUPI !';

  @override
  String get wordJackpot => 'JACKPOT !';

  @override
  String get wordSqueak => 'COUIC !';

  @override
  String get styleBigSwing => 'GRAND TOUR';

  @override
  String get styleSmash => 'FRACAS';

  @override
  String get styleFlip => 'SALTO';

  @override
  String get styleHangTime => 'EN L\'AIR';

  @override
  String get styleCloseCall => 'DE JUSTESSE';

  @override
  String get world1Name => 'Aire de jeux';

  @override
  String get world1Tagline => 'Tiens. Balance. Lâche. Hurle.';

  @override
  String get world2Name => 'Usine';

  @override
  String get world2Tagline => 'Anneaux sur rails et scies affamées.';

  @override
  String get world3Name => 'Cité de verre';

  @override
  String get world3Tagline => 'Fonce dedans. Rebondis.';

  @override
  String get world4Name => 'Îles célestes';

  @override
  String get world4Tagline => 'Surfe sur le vent. Tombe vers le haut.';

  @override
  String get world5Name => 'Base de fusées';

  @override
  String get world5Tagline => 'Les sols s\'effondrent. Les fusées volent.';

  @override
  String get skinFloppyName => 'Floppy';

  @override
  String get skinFloppyTagline => 'La nouille originale.';

  @override
  String get skinBananaName => 'Banane';

  @override
  String get skinBananaTagline => 'Glissante en plein swing.';

  @override
  String get skinKnightName => 'Sir Flops';

  @override
  String get skinKnightTagline => 'Armure lourde. Zéro grâce.';

  @override
  String get skinAstronautName => 'Cadet de l\'espace';

  @override
  String get skinAstronautTagline => 'La gravité n\'est qu\'une suggestion.';

  @override
  String get skinChickenName => 'Poulet en caoutchouc';

  @override
  String get skinChickenTagline => 'Couine à l\'impact. Évidemment.';

  @override
  String get skinNinjaName => 'Ninja nouille';

  @override
  String get skinNinjaTagline => 'Silencieux. Mortel. Surtout silencieux.';

  @override
  String get skinPirateName => 'Capitaine Flop';

  @override
  String get skinPirateTagline => 'Yo-ho, oh non.';

  @override
  String get skinRobotName => 'Robo-nouille';

  @override
  String get skinRobotTagline => 'Bip. Boup. Bonk.';

  @override
  String get skinDinoName => 'Dino-mite';

  @override
  String get skinDinoTagline => 'Petits bras. Grands swings.';

  @override
  String get skinWizardName => 'Flopdalf';

  @override
  String get skinWizardTagline => 'Vous ne passerez pas... oups.';

  @override
  String get skinGoldenName => 'Flop doré';

  @override
  String get skinGoldenTagline => 'Récupère les 300 étoiles.';

  @override
  String get itemRopeName => 'Corde fidèle';

  @override
  String get itemRopeTagline => 'Chanvre. Fiable. Beige.';

  @override
  String get itemChainName => 'Chaîne';

  @override
  String get itemChainTagline => 'Cling cling cling.';

  @override
  String get itemSpaghettiName => 'Spaghetti';

  @override
  String get itemSpaghettiTagline => 'Al dente. Presque.';

  @override
  String get itemRainbowName => 'Arc-en-ciel';

  @override
  String get itemRainbowTagline => 'Le swing en couleurs.';

  @override
  String get itemLaserName => 'Laser';

  @override
  String get itemLaserTagline => 'Grappin piou piou.';

  @override
  String get itemSwooshName => 'Whoosh';

  @override
  String get itemSwooshTagline => 'Le whoosh classique.';

  @override
  String get itemSparklesName => 'Paillettes';

  @override
  String get itemSparklesTagline => 'Fabuleux à toute vitesse.';

  @override
  String get itemBubblesName => 'Bulles';

  @override
  String get itemBubblesTagline => 'Blub blub.';

  @override
  String get itemFireName => 'Feu';

  @override
  String get itemFireTagline => 'Trop chaud pour toi.';

  @override
  String get itemGoldName => 'Doublons';

  @override
  String get itemGoldTagline => 'Saison Butin pirate.';

  @override
  String get itemCircuitName => 'Circuit';

  @override
  String get itemCircuitTagline => 'Saison Robo-bagarre.';

  @override
  String get itemLeavesName => 'Feuilles de jungle';

  @override
  String get itemLeavesTagline => 'Saison Jours de dinos.';

  @override
  String get itemStarsName => 'Poussière d\'étoiles';

  @override
  String get itemStarsTagline => 'Saison Semaines des sorciers.';

  @override
  String get itemClassicName => 'Kapow';

  @override
  String get itemClassicTagline => 'Des étoiles. Plein d\'étoiles.';

  @override
  String get itemSqueakyName => 'Jouet qui couine';

  @override
  String get itemSqueakyTagline => 'COUIIIIIC.';

  @override
  String get itemConfettiName => 'Fête confettis';

  @override
  String get itemConfettiTagline => 'Rater, c\'est la fête.';

  @override
  String get itemCoinpileName => 'Jackpot';

  @override
  String get itemCoinpileTagline => 'Explose en tas de pièces.';

  @override
  String get itemHopName => 'Petit saut joyeux';

  @override
  String get itemHopTagline => 'Boing boing boing.';

  @override
  String get itemBackflipName => 'Salto arrière';

  @override
  String get itemBackflipTagline => 'Atterrissage parfait. Parfois.';

  @override
  String get itemSpinName => 'Tornade';

  @override
  String get itemSpinTagline => 'Wiiiiii !';

  @override
  String get itemFlailName => 'Gesticulation';

  @override
  String get itemFlailTagline => 'L\'énergie du bonhomme gonflable.';

  @override
  String get setFoodName => 'Bataille de bouffe';

  @override
  String get setHeroesName => 'Héros courageux';

  @override
  String get setRopesName => 'Collectionneur de cordes';

  @override
  String get setTrailsName => 'Pionnier';

  @override
  String get setFailsName => 'Fails épiques';

  @override
  String get setDancesName => 'Piste de danse';

  @override
  String get seasonPirateName => 'Butin pirate';

  @override
  String get seasonRobotName => 'Robo-bagarre';

  @override
  String get seasonDinoName => 'Jours de dinos';

  @override
  String get seasonWizardName => 'Semaines des sorciers';

  @override
  String get productStarterPackName => 'Pack de départ';

  @override
  String get productStarterPackTagline =>
      '300 gemmes, 2 500 pièces et la corde Laser. Une seule fois !';

  @override
  String get productRemoveAdsName => 'Sans pub';

  @override
  String get productRemoveAdsTagline =>
      'Plus de pubs entre les niveaux. Les vidéos bonus restent facultatives.';

  @override
  String get productSeasonPassName => 'Passe Premium';

  @override
  String get productSeasonPassTagline => 'La piste premium de cette saison.';

  @override
  String get productGemsSmallName => 'Poignée de gemmes';

  @override
  String get productGemsSmallTagline => '80 gemmes';

  @override
  String get productGemsMediumName => 'Sac de gemmes';

  @override
  String get productGemsMediumTagline => '450 gemmes (+12 % bonus)';

  @override
  String get productGemsLargeName => 'Coffre de gemmes';

  @override
  String get productGemsLargeTagline => '1 000 gemmes (+25 % bonus)';

  @override
  String get productGemsHugeName => 'Trésor de gemmes';

  @override
  String get productGemsHugeTagline => '2 200 gemmes (+37 % bonus)';

  @override
  String get hintLevel1 =>
      'Maintiens n\'importe où pour attraper l\'anneau lumineux. Lâche pour t\'envoler !';

  @override
  String get hintLevel2 => 'Lâche pendant la montée pour voler plus loin.';

  @override
  String get hintLevel3 => 'Rouge, ça fait mal. Ne touche pas les piques !';

  @override
  String get hintLevel5 => 'Des piques en haut aussi. Ne vole pas trop haut !';

  @override
  String get hintLevel6 =>
      'Les tremplins verts te propulsent. Utilise-les pour franchir les grands trous.';

  @override
  String get hintLevel7 =>
      'Les scies tournent. Les scies font mal. Contourne-les.';

  @override
  String get hintLevel8 =>
      'Les drapeaux sont des checkpoints. Si tu tombes, tu repars de là.';

  @override
  String get hintLevel9 => 'Certaines scies bougent. Observe le rythme.';

  @override
  String get hintLevel12 => 'Balance-toi haut et lâche pour grimper.';

  @override
  String get hintLevel14 => 'Tout ce qui monte... redescend en général.';

  @override
  String get hintLevel15 => 'Tout à la fois. Bonne chance !';

  @override
  String get hintLevel21 =>
      'Certains anneaux bougent. Attrape-les au bon moment !';

  @override
  String get hintLevel41 =>
      'Le verre se brise si tu le frappes assez vite. Fonce dedans !';

  @override
  String get hintLevel61 =>
      'Les ventilateurs te soufflent vers le haut. Surfe sur le vent !';

  @override
  String get hintLevel64 =>
      'Les zones violettes inversent la gravité. Le haut est le nouveau bas.';

  @override
  String get hintLevel81 =>
      'Les plateformes friables tombent peu après ton atterrissage. Ne t\'arrête pas !';

  @override
  String get hintLevel84 =>
      'Les fusées ne te tuent pas... mais les piques, si.';
}
