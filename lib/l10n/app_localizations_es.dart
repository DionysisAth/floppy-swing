// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get back => 'Atrás';

  @override
  String get cancel => 'Cancelar';

  @override
  String get settings => 'Ajustes';

  @override
  String get leaderboards => 'Clasificaciones';

  @override
  String get leaderboard => 'Clasificación';

  @override
  String get achievements => 'Logros';

  @override
  String get challengeCode => 'Código de reto';

  @override
  String couldNotSignIn(String service) {
    return 'No se pudo iniciar sesión en $service.';
  }

  @override
  String get play => 'JUGAR';

  @override
  String get endless => 'INFINITO';

  @override
  String endlessBest(int distance) {
    return 'Récord $distance m';
  }

  @override
  String get endlessPitch => '¿Hasta dónde llegarás?';

  @override
  String get shop => 'TIENDA';

  @override
  String get shopPitch => 'Skins, cuerdas y más';

  @override
  String get pass => 'PASE';

  @override
  String passTier(int tier, int total) {
    return 'Rango $tier/$total';
  }

  @override
  String get daily => 'DIARIO';

  @override
  String dailyDone(int streak) {
    return '¡Hecho! 🔥 $streak';
  }

  @override
  String dailyKeepStreak(int streak) {
    return 'Mantén tu 🔥 $streak';
  }

  @override
  String get dailyNew => '¡Nuevo reto!';

  @override
  String get challengeCodeHint => 'Código o enlace de un amigo';

  @override
  String get playEndless => 'Jugar Infinito';

  @override
  String get settingsTitle => 'AJUSTES';

  @override
  String get music => 'Música';

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get muteAll => 'Silenciar todo';

  @override
  String get vibration => 'Vibración';

  @override
  String get dailyReminders => 'Recordatorios del Reto Diario';

  @override
  String get language => 'Idioma';

  @override
  String get languageAuto => 'Idioma del teléfono';

  @override
  String get privacyOptions => 'Opciones de privacidad';

  @override
  String get resetProgress => 'Borrar progreso';

  @override
  String get fonts => 'Fuentes';

  @override
  String gamesNotSetUp(String service) {
    return 'Las clasificaciones, los logros y el guardado en la nube vienen con $service. Aún no están configurados en esta versión.';
  }

  @override
  String gamesSignedIn(String service) {
    return 'Sesión iniciada. Tu progreso se guarda en tu cuenta de $service.';
  }

  @override
  String gamesSignedInAs(String name, String service) {
    return 'Sesión iniciada como $name. Tu progreso se guarda en tu cuenta de $service.';
  }

  @override
  String get gamesSignInPitch =>
      'Inicia sesión para guardar tu progreso y entrar en las clasificaciones.';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get resetTitle => '¿Borrar progreso?';

  @override
  String get resetBody =>
      'Se borrarán tus estrellas, monedas y skins. No se puede deshacer.';

  @override
  String get reset => 'Borrar';

  @override
  String clipFailed(String error) {
    return 'No se pudo crear el clip: $error';
  }

  @override
  String challengeShare(int distance, String link, String code) {
    return 'Me balanceé $distance m en Floppy Swing Infinito. ¿Puedes superarme? $link\n(O toca \"Código de reto\" en el menú y escribe $code.)';
  }

  @override
  String get hintRevived => '¡Reanimado! Mantén pulsado para balancearte.';

  @override
  String get hintHold => '¡Mantén pulsado en cualquier sitio para balancearte!';

  @override
  String get failSpikes1 => 'De punta.';

  @override
  String get failSpikes2 => 'Eso va a dejar marca.';

  @override
  String get failSpikes3 => 'Pinchos: 1, Tú: 0';

  @override
  String get failSaw1 => '¡En rodajitas!';

  @override
  String get failSaw2 => '¿No lo viste venir?';

  @override
  String get failSaw3 => '¡Bzzzzt!';

  @override
  String get failPit1 => 'La gravedad gana otra vez.';

  @override
  String get failPit2 => '¡Para abajo!';

  @override
  String get failPit3 => 'El suelo pincha.';

  @override
  String get failStuck1 => '¿Hora de la siesta?';

  @override
  String get failStuck2 => 'Pegado como chicle.';

  @override
  String get failStuck3 => '¿Tomando aire?';

  @override
  String get tapToRetry => 'Toca en cualquier sitio para reintentar';

  @override
  String get shareFail => 'Compartir fallo';

  @override
  String get challengeFriend => 'Reta a un amigo';

  @override
  String get newCourse => 'Nuevo recorrido';

  @override
  String get skipLevel => 'Saltar nivel';

  @override
  String get revive => 'Revivir';

  @override
  String rankWorldwide(int rank) {
    return '#$rank mundial';
  }

  @override
  String get newBest => '¡NUEVO RÉCORD!';

  @override
  String meters(int distance) {
    return '$distance m';
  }

  @override
  String endlessScore(int score, int best) {
    return 'Puntos $score  ·  Récord $best';
  }

  @override
  String get newBestToday => '¡Nuevo mejor tiempo hoy!';

  @override
  String rankToday(int rank) {
    return '#$rank hoy';
  }

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 Racha de $count días',
      one: '🔥 Racha de $count día',
    );
    return '$_temp0';
  }

  @override
  String dayStreakBonus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 Racha de $count días - ¡gemas extra!',
      one: '🔥 Racha de $count día - ¡gemas extra!',
    );
    return '$_temp0';
  }

  @override
  String get dailyClear => '¡RETO SUPERADO!';

  @override
  String get worldClear => '¡MUNDO SUPERADO!';

  @override
  String get levelClear => '¡NIVEL SUPERADO!';

  @override
  String get statTime => 'Tiempo';

  @override
  String statTarget(String time) {
    return 'objetivo ${time}s';
  }

  @override
  String get statCoins => 'Monedas';

  @override
  String get statStyle => 'Estilo';

  @override
  String get statBest => 'Récord';

  @override
  String get starFinish => 'Meta';

  @override
  String newStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '(+$count estrellas)',
      one: '(+$count estrella)',
    );
    return '$_temp0';
  }

  @override
  String worldGate(int count, String world) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¡Consigue $count estrellas más para abrir $world!',
      one: '¡Consigue $count estrella más para abrir $world!',
    );
    return '$_temp0';
  }

  @override
  String get doubleCoins => 'Doblar monedas';

  @override
  String get retry => 'Reintentar';

  @override
  String get share => 'Compartir';

  @override
  String get next => 'Siguiente';

  @override
  String get done => 'Listo';

  @override
  String get levels => 'Niveles';

  @override
  String get quit => 'Salir';

  @override
  String get paused => 'PAUSA';

  @override
  String get resume => 'Continuar';

  @override
  String get restart => 'Reiniciar';

  @override
  String get pause => 'Pausa';

  @override
  String zoneBanner(int number, String name) {
    return 'ZONA $number: $name';
  }

  @override
  String hudDaily(String name) {
    return 'DIARIO: $name';
  }

  @override
  String hudStyle(int score) {
    return 'ESTILO $score';
  }

  @override
  String get slowMoReplay => 'REPETICIÓN A CÁMARA LENTA';

  @override
  String get makingClip => 'Creando tu clip…';

  @override
  String worldNumber(int number) {
    return 'MUNDO $number';
  }

  @override
  String get previousWorld => 'Mundo anterior';

  @override
  String get nextWorld => 'Mundo siguiente';

  @override
  String collectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Consigue $count más',
      one: 'Consigue $count más',
    );
    return '$_temp0';
  }

  @override
  String starsOf(int have, int need) {
    return '$have/$need estrellas';
  }

  @override
  String levelTile(int number, String name) {
    return 'Nivel $number, $name';
  }

  @override
  String levelTileLocked(int number, String name) {
    return 'Nivel $number, $name, bloqueado';
  }

  @override
  String get dailyBonus => 'PREMIO DIARIO';

  @override
  String get dailyBonusPitch =>
      '¡Vuelve cada día para ganar premios más grandes!';

  @override
  String get claim => 'Recoger';

  @override
  String dayNumber(int day) {
    return 'Día $day';
  }

  @override
  String get seasonPassTitle => 'PASE DE TEMPORADA';

  @override
  String get seasonPass => 'Pase de temporada';

  @override
  String tierNumber(int tier) {
    return 'Rango $tier';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count días',
      one: 'Queda $count día',
    );
    return '$_temp0';
  }

  @override
  String get seasonComplete => '¡Temporada completada!';

  @override
  String seasonXp(int xp, int perTier) {
    return '$xp / $perTier XP  ·  Gana XP completando niveles, retos diarios y partidas de Infinito';
  }

  @override
  String get unlockPremium => 'Desbloquear Premium';

  @override
  String get or => 'o';

  @override
  String get trackFree => 'GRATIS';

  @override
  String get trackPremium => 'PREMIUM';

  @override
  String get tabSkins => 'Skins';

  @override
  String get tabRopes => 'Cuerdas';

  @override
  String get tabTrails => 'Estelas';

  @override
  String get tabFails => 'Fallos';

  @override
  String get tabDances => 'Bailes';

  @override
  String get tabSets => 'Colecciones';

  @override
  String get tabGems => 'Gemas';

  @override
  String get equipped => 'EQUIPADO';

  @override
  String get use => 'Usar';

  @override
  String get storeUnavailable =>
      'No se puede acceder a la tienda ahora. Revisa tu conexión e inténtalo más tarde.';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get bestValue => 'MEJOR OFERTA';

  @override
  String plusItem(String item) {
    return '+ $item';
  }

  @override
  String purchaseThanks(String product) {
    return '¡Gracias! $product desbloqueado.';
  }

  @override
  String get storeBusy => 'La tienda está ocupada. Inténtalo de nuevo.';

  @override
  String get purchasesRestored => 'Compras restauradas.';

  @override
  String get storeUnreachable => 'No se pudo acceder a la tienda.';

  @override
  String get purchaseFailed => 'La compra falló. No se te ha cobrado nada.';

  @override
  String reminderStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¡Mantén tu racha de $count días!',
      one: '¡Mantén tu racha de $count día!',
    );
    return '$_temp0';
  }

  @override
  String get reminderStreakBody =>
      'Supera el Reto Diario de hoy antes de medianoche.';

  @override
  String get reminderTodayTitle => 'El Reto Diario de hoy te espera';

  @override
  String get reminderTodayBody =>
      'Un nivel nuevo cada día. ¡Ve a por esas estrellas!';

  @override
  String get reminderFreshTitle => 'Ya está aquí un nuevo Reto Diario';

  @override
  String get reminderFreshBody =>
      'Nivel nuevo, fantasma nuevo al que ganar. ¿Conseguirás las 3 estrellas?';

  @override
  String get reminderRestlessTitle => 'Floppy se está impacientando';

  @override
  String get reminderRestlessBody =>
      'El Reto Diario de hoy no se va a balancear solo.';

  @override
  String get reminderTimeTitle => '¡Hora del Reto Diario!';

  @override
  String get reminderTimeBody =>
      '¿Un balanceo rápido? Supéralo para mantener tu racha.';

  @override
  String get reminderChannelDescription =>
      'Un aviso cuando sale un nuevo Reto Diario.';

  @override
  String get shareTagline => '¿Puedes hacerlo mejor?';

  @override
  String get shareCta => 'Floppy Swing - gratis en iOS y Android';

  @override
  String clipCleared(int level) {
    return '¡Nivel $level superado!';
  }

  @override
  String clipTime(int level, String time) {
    return 'Nivel $level en ${time}s';
  }

  @override
  String clipSaw(int level) {
    return 'Me encontré una sierra en el nivel $level';
  }

  @override
  String clipSpikes(int level) {
    return 'Encontré los pinchos en el nivel $level';
  }

  @override
  String clipPit(int level) {
    return 'Fallé todo en el nivel $level';
  }

  @override
  String clipStuck(int level) {
    return 'Me eché una siesta en el nivel $level';
  }

  @override
  String clipLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String get wordBest => 'RÉCORD';

  @override
  String get wordCheckpoint => '¡PUNTO DE CONTROL!';

  @override
  String get wordGo => '¡YA!';

  @override
  String get wordSmash => '¡CRASH!';

  @override
  String get wordKaboom => '¡KABUM!';

  @override
  String get wordBonk => '¡BONK!';

  @override
  String get wordSaw => '¡ZZZING!';

  @override
  String get wordSpikes => '¡AY!';

  @override
  String get wordPit => '¡AYAYAY!';

  @override
  String get wordStuck => 'ZZZ...';

  @override
  String get wordConfetti => '¡YUJUU!';

  @override
  String get wordJackpot => '¡PREMIO!';

  @override
  String get wordSqueak => '¡ÑIIIC!';

  @override
  String get styleBigSwing => 'SUPERBALANCEO';

  @override
  String get styleSmash => 'CRISTALAZO';

  @override
  String get styleFlip => 'VOLTERETA';

  @override
  String get styleHangTime => 'EN EL AIRE';

  @override
  String get styleCloseCall => 'POR LOS PELOS';

  @override
  String get world1Name => 'Parque';

  @override
  String get world1Tagline => 'Agarra. Balancéate. Suelta. Grita.';

  @override
  String get world2Name => 'Fábrica';

  @override
  String get world2Tagline => 'Anillas sobre raíles y sierras hambrientas.';

  @override
  String get world3Name => 'Ciudad de Cristal';

  @override
  String get world3Tagline => 'Rómpelo todo. Rebota.';

  @override
  String get world4Name => 'Islas del Cielo';

  @override
  String get world4Tagline => 'Surfea el viento. Cae hacia arriba.';

  @override
  String get world5Name => 'Base de Cohetes';

  @override
  String get world5Tagline => 'Los suelos se desmoronan. Los cohetes vuelan.';

  @override
  String get skinFloppyName => 'Floppy';

  @override
  String get skinFloppyTagline => 'El fideo original.';

  @override
  String get skinBananaName => 'Plátano';

  @override
  String get skinBananaTagline => 'Resbala al balancearse.';

  @override
  String get skinKnightName => 'Sir Flops';

  @override
  String get skinKnightTagline => 'Armadura pesada. Cero elegancia.';

  @override
  String get skinAstronautName => 'Cadete Espacial';

  @override
  String get skinAstronautTagline => 'La gravedad es solo una sugerencia.';

  @override
  String get skinChickenName => 'Pollo de Goma';

  @override
  String get skinChickenTagline => 'Chilla al chocar. Obviamente.';

  @override
  String get skinNinjaName => 'Ninja Fideo';

  @override
  String get skinNinjaTagline => 'Silencioso. Letal. Casi siempre silencioso.';

  @override
  String get skinPirateName => 'Capitán Flop';

  @override
  String get skinPirateTagline => 'Yo-ho, oh no.';

  @override
  String get skinRobotName => 'Robo-Fideo';

  @override
  String get skinRobotTagline => 'Bip. Bup. Bonk.';

  @override
  String get skinDinoName => 'Dino-Mita';

  @override
  String get skinDinoTagline => 'Bracitos cortos. Balanceos enormes.';

  @override
  String get skinWizardName => 'Flopdalf';

  @override
  String get skinWizardTagline => 'No puedes pasar... ups.';

  @override
  String get skinGoldenName => 'Flop Dorado';

  @override
  String get skinGoldenTagline => 'Consigue las 300 estrellas.';

  @override
  String get itemRopeName => 'Cuerda Fiel';

  @override
  String get itemRopeTagline => 'Cáñamo. Fiable. Beige.';

  @override
  String get itemChainName => 'Cadena';

  @override
  String get itemChainTagline => 'Clinc clinc clinc.';

  @override
  String get itemSpaghettiName => 'Espagueti';

  @override
  String get itemSpaghettiTagline => 'Al dente. Casi.';

  @override
  String get itemRainbowName => 'Arcoíris';

  @override
  String get itemRainbowTagline => 'Balancéate en colores.';

  @override
  String get itemLaserName => 'Láser';

  @override
  String get itemLaserTagline => 'Gancho piu piu.';

  @override
  String get itemSwooshName => 'Zum';

  @override
  String get itemSwooshTagline => 'El clásico zum.';

  @override
  String get itemSparklesName => 'Destellos';

  @override
  String get itemSparklesTagline => 'Fabuloso a cualquier velocidad.';

  @override
  String get itemBubblesName => 'Burbujas';

  @override
  String get itemBubblesTagline => 'Blub blub.';

  @override
  String get itemFireName => 'Fuego';

  @override
  String get itemFireTagline => 'Quema demasiado.';

  @override
  String get itemGoldName => 'Doblones';

  @override
  String get itemGoldTagline => 'Temporada Botín Pirata.';

  @override
  String get itemCircuitName => 'Circuito';

  @override
  String get itemCircuitTagline => 'Temporada Robo-Jaleo.';

  @override
  String get itemLeavesName => 'Hojas de Selva';

  @override
  String get itemLeavesTagline => 'Temporada Días de Dinos.';

  @override
  String get itemStarsName => 'Polvo de Estrellas';

  @override
  String get itemStarsTagline => 'Temporada Semanas de Magos.';

  @override
  String get itemClassicName => 'Kapow';

  @override
  String get itemClassicTagline => 'Estrellas. Muchas estrellas.';

  @override
  String get itemSqueakyName => 'Juguete Chillón';

  @override
  String get itemSqueakyTagline => 'ÑIIIIIC.';

  @override
  String get itemConfettiName => 'Fiesta de Confeti';

  @override
  String get itemConfettiTagline => 'Fallar es una celebración.';

  @override
  String get itemCoinpileName => 'Premio Gordo';

  @override
  String get itemCoinpileTagline => 'Revienta en un montón de monedas.';

  @override
  String get itemHopName => 'Saltito Feliz';

  @override
  String get itemHopTagline => 'Boing boing boing.';

  @override
  String get itemBackflipName => 'Mortal hacia atrás';

  @override
  String get itemBackflipTagline => 'Clava el aterrizaje. A veces.';

  @override
  String get itemSpinName => 'Tornado';

  @override
  String get itemSpinTagline => '¡Uiiiiii!';

  @override
  String get itemFlailName => 'Baile Loco';

  @override
  String get itemFlailTagline => 'Energía de muñeco hinchable.';

  @override
  String get setFoodName => 'Guerra de Comida';

  @override
  String get setHeroesName => 'Héroes Valientes';

  @override
  String get setRopesName => 'Coleccionista de Cuerdas';

  @override
  String get setTrailsName => 'Pionero';

  @override
  String get setFailsName => 'Fallos Épicos';

  @override
  String get setDancesName => 'Pista de Baile';

  @override
  String get seasonPirateName => 'Botín Pirata';

  @override
  String get seasonRobotName => 'Robo-Jaleo';

  @override
  String get seasonDinoName => 'Días de Dinos';

  @override
  String get seasonWizardName => 'Semanas de Magos';

  @override
  String get productStarterPackName => 'Pack de Inicio';

  @override
  String get productStarterPackTagline =>
      '300 gemas, 2500 monedas y la cuerda Láser. ¡Solo una vez!';

  @override
  String get productRemoveAdsName => 'Sin Anuncios';

  @override
  String get productRemoveAdsTagline =>
      'Se acabaron los anuncios entre niveles. Los vídeos de premio siguen siendo opcionales.';

  @override
  String get productSeasonPassName => 'Pase Premium';

  @override
  String get productSeasonPassTagline => 'La línea premium de esta temporada.';

  @override
  String get productGemsSmallName => 'Puñado de Gemas';

  @override
  String get productGemsSmallTagline => '80 gemas';

  @override
  String get productGemsMediumName => 'Bolsa de Gemas';

  @override
  String get productGemsMediumTagline => '450 gemas (+12 % extra)';

  @override
  String get productGemsLargeName => 'Cofre de Gemas';

  @override
  String get productGemsLargeTagline => '1000 gemas (+25 % extra)';

  @override
  String get productGemsHugeName => 'Cámara de Gemas';

  @override
  String get productGemsHugeTagline => '2200 gemas (+37 % extra)';

  @override
  String get hintLevel1 =>
      'Mantén pulsado en cualquier sitio para agarrar la anilla brillante. ¡Suelta para volar!';

  @override
  String get hintLevel2 =>
      'Suelta cuando subas en el balanceo para volar más lejos.';

  @override
  String get hintLevel3 => 'Rojo significa ¡ay! ¡No toques los pinchos!';

  @override
  String get hintLevel5 =>
      'También hay pinchos arriba. ¡No vueles demasiado alto!';

  @override
  String get hintLevel6 =>
      'Las plataformas verdes te lanzan hacia arriba. Úsalas para cruzar huecos grandes.';

  @override
  String get hintLevel7 =>
      'Las sierras giran. Las sierras duelen. Pasa a su alrededor.';

  @override
  String get hintLevel8 =>
      'Las banderas son puntos de control. Si caes, revives allí.';

  @override
  String get hintLevel9 => 'Algunas sierras se mueven. Fíjate en el ritmo.';

  @override
  String get hintLevel12 => 'Balancéate alto y suelta para subir.';

  @override
  String get hintLevel14 => 'Todo lo que sube... casi siempre baja.';

  @override
  String get hintLevel15 => 'Todo a la vez. ¡Suerte!';

  @override
  String get hintLevel21 =>
      'Algunas anillas se mueven. ¡Agárralas en el momento justo!';

  @override
  String get hintLevel41 =>
      'El cristal se rompe si lo golpeas lo bastante rápido. ¡Atraviésalo!';

  @override
  String get hintLevel61 =>
      'Los ventiladores te empujan hacia arriba. ¡Surfea el viento!';

  @override
  String get hintLevel64 =>
      'Las zonas moradas invierten la gravedad. Arriba es el nuevo abajo.';

  @override
  String get hintLevel81 =>
      'Las plataformas que se desmoronan caen poco después de que aterrices. ¡No te pares!';

  @override
  String get hintLevel84 => 'Los cohetes no te matan... pero los pinchos sí.';
}
