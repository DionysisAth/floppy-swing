// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get back => 'Voltar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get settings => 'Configurações';

  @override
  String get leaderboards => 'Rankings';

  @override
  String get leaderboard => 'Ranking';

  @override
  String get achievements => 'Conquistas';

  @override
  String get challengeCode => 'Código de desafio';

  @override
  String couldNotSignIn(String service) {
    return 'Não foi possível entrar no $service.';
  }

  @override
  String get play => 'JOGAR';

  @override
  String get endless => 'INFINITO';

  @override
  String endlessBest(int distance) {
    return 'Recorde $distance m';
  }

  @override
  String get endlessPitch => 'Até onde você vai?';

  @override
  String get shop => 'LOJA';

  @override
  String get shopPitch => 'Skins, cordas e mais';

  @override
  String get pass => 'PASSE';

  @override
  String passTier(int tier, int total) {
    return 'Nível $tier/$total';
  }

  @override
  String get daily => 'DIÁRIO';

  @override
  String dailyDone(int streak) {
    return 'Feito! 🔥 $streak';
  }

  @override
  String dailyKeepStreak(int streak) {
    return 'Mantenha seu 🔥 $streak';
  }

  @override
  String get dailyNew => 'Novo desafio!';

  @override
  String get challengeCodeHint => 'Código ou link de um amigo';

  @override
  String get playEndless => 'Jogar Infinito';

  @override
  String get settingsTitle => 'CONFIGURAÇÕES';

  @override
  String get music => 'Música';

  @override
  String get soundEffects => 'Efeitos sonoros';

  @override
  String get muteAll => 'Silenciar tudo';

  @override
  String get vibration => 'Vibração';

  @override
  String get dailyReminders => 'Lembretes do Desafio Diário';

  @override
  String get language => 'Idioma';

  @override
  String get languageAuto => 'Idioma do celular';

  @override
  String get privacyOptions => 'Opções de privacidade';

  @override
  String get resetProgress => 'Apagar progresso';

  @override
  String get fonts => 'Fontes';

  @override
  String gamesNotSetUp(String service) {
    return 'Rankings, conquistas e salvamento na nuvem vêm com o $service. Ainda não configurados nesta versão.';
  }

  @override
  String gamesSignedIn(String service) {
    return 'Conectado. Seu progresso fica salvo na sua conta do $service.';
  }

  @override
  String gamesSignedInAs(String name, String service) {
    return 'Conectado como $name. Seu progresso fica salvo na sua conta do $service.';
  }

  @override
  String get gamesSignInPitch =>
      'Entre para salvar seu progresso e participar dos rankings.';

  @override
  String get signIn => 'Entrar';

  @override
  String get resetTitle => 'Apagar progresso?';

  @override
  String get resetBody =>
      'Isso apaga suas estrelas, moedas e skins. Não dá para desfazer.';

  @override
  String get reset => 'Apagar';

  @override
  String clipFailed(String error) {
    return 'Não foi possível criar o clipe: $error';
  }

  @override
  String challengeShare(int distance, String link, String code) {
    return 'Balancei $distance m no Floppy Swing Infinito. Consegue me vencer? $link\n(Ou toque em \"Código de desafio\" no menu e digite $code.)';
  }

  @override
  String get hintRevived => 'Reviveu! Segure para balançar.';

  @override
  String get hintHold => 'Segure em qualquer lugar para balançar!';

  @override
  String get failSpikes1 => 'De ponta.';

  @override
  String get failSpikes2 => 'Isso vai deixar marca.';

  @override
  String get failSpikes3 => 'Espinhos: 1, Você: 0';

  @override
  String get failSaw1 => 'Fatiado!';

  @override
  String get failSaw2 => 'Não viu essa vindo?';

  @override
  String get failSaw3 => 'Bzzzzt!';

  @override
  String get failPit1 => 'A gravidade venceu de novo.';

  @override
  String get failPit2 => 'Lá vai você!';

  @override
  String get failPit3 => 'O chão espeta.';

  @override
  String get failStuck1 => 'Hora da soneca?';

  @override
  String get failStuck2 => 'Grudado que nem chiclete.';

  @override
  String get failStuck3 => 'Tomando um fôlego?';

  @override
  String get tapToRetry => 'Toque em qualquer lugar para tentar de novo';

  @override
  String get shareFail => 'Compartilhar falha';

  @override
  String get challengeFriend => 'Desafiar um amigo';

  @override
  String get newCourse => 'Novo percurso';

  @override
  String get skipLevel => 'Pular fase';

  @override
  String get revive => 'Reviver';

  @override
  String rankWorldwide(int rank) {
    return '#$rank no mundo';
  }

  @override
  String get newBest => 'NOVO RECORDE!';

  @override
  String meters(int distance) {
    return '$distance m';
  }

  @override
  String endlessScore(int score, int best) {
    return 'Pontos $score  ·  Recorde $best';
  }

  @override
  String get newBestToday => 'Novo melhor tempo hoje!';

  @override
  String rankToday(int rank) {
    return '#$rank hoje';
  }

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count dias seguidos',
      one: '🔥 $count dia seguido',
    );
    return '$_temp0';
  }

  @override
  String dayStreakBonus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count dias seguidos - gemas bônus!',
      one: '🔥 $count dia seguido - gemas bônus!',
    );
    return '$_temp0';
  }

  @override
  String get dailyClear => 'DESAFIO CONCLUÍDO!';

  @override
  String get worldClear => 'MUNDO CONCLUÍDO!';

  @override
  String get levelClear => 'FASE CONCLUÍDA!';

  @override
  String get statTime => 'Tempo';

  @override
  String statTarget(String time) {
    return 'meta ${time}s';
  }

  @override
  String get statCoins => 'Moedas';

  @override
  String get statStyle => 'Estilo';

  @override
  String get statBest => 'Recorde';

  @override
  String get starFinish => 'Chegada';

  @override
  String newStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '(+$count estrelas)',
      one: '(+$count estrela)',
    );
    return '$_temp0';
  }

  @override
  String worldGate(int count, String world) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pegue mais $count estrelas para abrir $world!',
      one: 'Pegue mais $count estrela para abrir $world!',
    );
    return '$_temp0';
  }

  @override
  String get doubleCoins => 'Dobrar moedas';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get share => 'Compartilhar';

  @override
  String get next => 'Próxima';

  @override
  String get done => 'Pronto';

  @override
  String get levels => 'Fases';

  @override
  String get quit => 'Sair';

  @override
  String get paused => 'PAUSADO';

  @override
  String get resume => 'Continuar';

  @override
  String get restart => 'Recomeçar';

  @override
  String get pause => 'Pausar';

  @override
  String zoneBanner(int number, String name) {
    return 'ZONA $number: $name';
  }

  @override
  String hudDaily(String name) {
    return 'DIÁRIO: $name';
  }

  @override
  String hudStyle(int score) {
    return 'ESTILO $score';
  }

  @override
  String get slowMoReplay => 'REPLAY EM CÂMERA LENTA';

  @override
  String get makingClip => 'Criando seu clipe…';

  @override
  String worldNumber(int number) {
    return 'MUNDO $number';
  }

  @override
  String get previousWorld => 'Mundo anterior';

  @override
  String get nextWorld => 'Próximo mundo';

  @override
  String collectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pegue mais $count',
      one: 'Pegue mais $count',
    );
    return '$_temp0';
  }

  @override
  String starsOf(int have, int need) {
    return '$have/$need estrelas';
  }

  @override
  String levelTile(int number, String name) {
    return 'Fase $number, $name';
  }

  @override
  String levelTileLocked(int number, String name) {
    return 'Fase $number, $name, bloqueada';
  }

  @override
  String get dailyBonus => 'BÔNUS DIÁRIO';

  @override
  String get dailyBonusPitch => 'Volte todo dia para ganhar prêmios maiores!';

  @override
  String get claim => 'Pegar';

  @override
  String dayNumber(int day) {
    return 'Dia $day';
  }

  @override
  String get seasonPassTitle => 'PASSE DE TEMPORADA';

  @override
  String get seasonPass => 'Passe de temporada';

  @override
  String tierNumber(int tier) {
    return 'Nível $tier';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count dias',
      one: 'Falta $count dia',
    );
    return '$_temp0';
  }

  @override
  String get seasonComplete => 'Temporada completa!';

  @override
  String seasonXp(int xp, int perTier) {
    return '$xp / $perTier XP  ·  Ganhe XP terminando fases, desafios diários e partidas do Infinito';
  }

  @override
  String get unlockPremium => 'Liberar Premium';

  @override
  String get or => 'ou';

  @override
  String get trackFree => 'GRÁTIS';

  @override
  String get trackPremium => 'PREMIUM';

  @override
  String get tabSkins => 'Skins';

  @override
  String get tabRopes => 'Cordas';

  @override
  String get tabTrails => 'Rastros';

  @override
  String get tabFails => 'Falhas';

  @override
  String get tabDances => 'Danças';

  @override
  String get tabSets => 'Coleções';

  @override
  String get tabGems => 'Gemas';

  @override
  String get equipped => 'EQUIPADO';

  @override
  String get use => 'Usar';

  @override
  String get storeUnavailable =>
      'Não foi possível acessar a loja agora. Verifique sua conexão e tente mais tarde.';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get bestValue => 'MELHOR OFERTA';

  @override
  String plusItem(String item) {
    return '+ $item';
  }

  @override
  String purchaseThanks(String product) {
    return 'Valeu! $product liberado.';
  }

  @override
  String get storeBusy => 'A loja está ocupada. Tente de novo.';

  @override
  String get purchasesRestored => 'Compras restauradas.';

  @override
  String get storeUnreachable => 'Não foi possível acessar a loja.';

  @override
  String get purchaseFailed => 'A compra falhou. Nada foi cobrado.';

  @override
  String reminderStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mantenha sua sequência de $count dias!',
      one: 'Mantenha sua sequência de $count dia!',
    );
    return '$_temp0';
  }

  @override
  String get reminderStreakBody =>
      'Conclua o Desafio Diário de hoje antes da meia-noite.';

  @override
  String get reminderTodayTitle => 'O Desafio Diário de hoje está esperando';

  @override
  String get reminderTodayBody =>
      'Uma fase nova todo dia. Vá pegar essas estrelas!';

  @override
  String get reminderFreshTitle => 'Chegou um novo Desafio Diário';

  @override
  String get reminderFreshBody =>
      'Fase nova, fantasma novo para vencer. Você pega as 3 estrelas?';

  @override
  String get reminderRestlessTitle => 'O Floppy está ficando impaciente';

  @override
  String get reminderRestlessBody =>
      'O Desafio Diário de hoje não vai se balançar sozinho.';

  @override
  String get reminderTimeTitle => 'Hora do Desafio Diário!';

  @override
  String get reminderTimeBody =>
      'Um balanço rapidinho? Conclua para manter sua sequência.';

  @override
  String get reminderChannelDescription =>
      'Um aviso quando sai um novo Desafio Diário.';

  @override
  String get shareTagline => 'Consegue fazer melhor?';

  @override
  String get shareCta => 'Floppy Swing - grátis no iOS e Android';

  @override
  String clipCleared(int level) {
    return 'Fase $level concluída!';
  }

  @override
  String clipTime(int level, String time) {
    return 'Fase $level em ${time}s';
  }

  @override
  String clipSaw(int level) {
    return 'Encontrei uma serra na fase $level';
  }

  @override
  String clipSpikes(int level) {
    return 'Achei os espinhos na fase $level';
  }

  @override
  String clipPit(int level) {
    return 'Errei tudo na fase $level';
  }

  @override
  String clipStuck(int level) {
    return 'Tirei uma soneca na fase $level';
  }

  @override
  String clipLevel(int level) {
    return 'Fase $level';
  }

  @override
  String get wordBest => 'RECORDE';

  @override
  String get wordCheckpoint => 'CHECKPOINT!';

  @override
  String get wordGo => 'VAI!';

  @override
  String get wordSmash => 'CRASH!';

  @override
  String get wordKaboom => 'KABUM!';

  @override
  String get wordBonk => 'BONK!';

  @override
  String get wordSaw => 'ZZZING!';

  @override
  String get wordSpikes => 'AI!';

  @override
  String get wordPit => 'AIAIAI!';

  @override
  String get wordStuck => 'ZZZ...';

  @override
  String get wordConfetti => 'UHUUU!';

  @override
  String get wordJackpot => 'JACKPOT!';

  @override
  String get wordSqueak => 'QUIIC!';

  @override
  String get styleBigSwing => 'SUPERGIRO';

  @override
  String get styleSmash => 'QUEBRADEIRA';

  @override
  String get styleFlip => 'CAMBALHOTA';

  @override
  String get styleHangTime => 'NO AR';

  @override
  String get styleCloseCall => 'POR UM TRIZ';

  @override
  String get world1Name => 'Parquinho';

  @override
  String get world1Tagline => 'Segure. Balance. Solte. Grite.';

  @override
  String get world2Name => 'Fábrica';

  @override
  String get world2Tagline => 'Argolas em trilhos e serras famintas.';

  @override
  String get world3Name => 'Cidade de Vidro';

  @override
  String get world3Tagline => 'Quebre tudo. Quique.';

  @override
  String get world4Name => 'Ilhas do Céu';

  @override
  String get world4Tagline => 'Surfe no vento. Caia para cima.';

  @override
  String get world5Name => 'Base de Foguetes';

  @override
  String get world5Tagline => 'O chão desmorona. Foguetes voam.';

  @override
  String get skinFloppyName => 'Floppy';

  @override
  String get skinFloppyTagline => 'O macarrão original.';

  @override
  String get skinBananaName => 'Banana';

  @override
  String get skinBananaTagline => 'Escorregadia no balanço.';

  @override
  String get skinKnightName => 'Sir Flops';

  @override
  String get skinKnightTagline => 'Armadura pesada. Zero elegância.';

  @override
  String get skinAstronautName => 'Cadete Espacial';

  @override
  String get skinAstronautTagline => 'A gravidade é só uma sugestão.';

  @override
  String get skinChickenName => 'Frango de Borracha';

  @override
  String get skinChickenTagline => 'Apita no impacto. Óbvio.';

  @override
  String get skinNinjaName => 'Ninja Macarrão';

  @override
  String get skinNinjaTagline => 'Silencioso. Mortal. Quase sempre silencioso.';

  @override
  String get skinPirateName => 'Capitão Flop';

  @override
  String get skinPirateTagline => 'Io-hô, ah não.';

  @override
  String get skinRobotName => 'Robô-Macarrão';

  @override
  String get skinRobotTagline => 'Bip. Bup. Bonk.';

  @override
  String get skinDinoName => 'Dino-Mite';

  @override
  String get skinDinoTagline => 'Bracinhos curtos. Balanços enormes.';

  @override
  String get skinWizardName => 'Flopdalf';

  @override
  String get skinWizardTagline => 'Você não passará... ops.';

  @override
  String get skinGoldenName => 'Flop Dourado';

  @override
  String get skinGoldenTagline => 'Pegue todas as 300 estrelas.';

  @override
  String get itemRopeName => 'Corda Fiel';

  @override
  String get itemRopeTagline => 'Cânhamo. Confiável. Bege.';

  @override
  String get itemChainName => 'Corrente';

  @override
  String get itemChainTagline => 'Clinc clinc clinc.';

  @override
  String get itemSpaghettiName => 'Espaguete';

  @override
  String get itemSpaghettiTagline => 'Al dente. Quase.';

  @override
  String get itemRainbowName => 'Arco-íris';

  @override
  String get itemRainbowTagline => 'Balance em cores.';

  @override
  String get itemLaserName => 'Laser';

  @override
  String get itemLaserTagline => 'Gancho piu piu.';

  @override
  String get itemSwooshName => 'Vush';

  @override
  String get itemSwooshTagline => 'O clássico vush.';

  @override
  String get itemSparklesName => 'Brilhos';

  @override
  String get itemSparklesTagline => 'Fabuloso em qualquer velocidade.';

  @override
  String get itemBubblesName => 'Bolhas';

  @override
  String get itemBubblesTagline => 'Blub blub.';

  @override
  String get itemFireName => 'Fogo';

  @override
  String get itemFireTagline => 'Quente demais.';

  @override
  String get itemGoldName => 'Dobrões';

  @override
  String get itemGoldTagline => 'Temporada Tesouro Pirata.';

  @override
  String get itemCircuitName => 'Circuito';

  @override
  String get itemCircuitTagline => 'Temporada Robô-Bagunça.';

  @override
  String get itemLeavesName => 'Folhas da Selva';

  @override
  String get itemLeavesTagline => 'Temporada Dias de Dino.';

  @override
  String get itemStarsName => 'Poeira Estelar';

  @override
  String get itemStarsTagline => 'Temporada Semanas dos Magos.';

  @override
  String get itemClassicName => 'Kapow';

  @override
  String get itemClassicTagline => 'Estrelas. Muitas estrelas.';

  @override
  String get itemSqueakyName => 'Brinquedo de Apito';

  @override
  String get itemSqueakyTagline => 'QUIIIIIC.';

  @override
  String get itemConfettiName => 'Festa de Confete';

  @override
  String get itemConfettiTagline => 'Falhar é uma festa.';

  @override
  String get itemCoinpileName => 'Jackpot';

  @override
  String get itemCoinpileTagline => 'Exploda num monte de moedas.';

  @override
  String get itemHopName => 'Pulinho Feliz';

  @override
  String get itemHopTagline => 'Boing boing boing.';

  @override
  String get itemBackflipName => 'Mortal para trás';

  @override
  String get itemBackflipTagline => 'Crava a aterrissagem. Às vezes.';

  @override
  String get itemSpinName => 'Tornado';

  @override
  String get itemSpinTagline => 'Uiiiiii!';

  @override
  String get itemFlailName => 'Dança Maluca';

  @override
  String get itemFlailTagline => 'Energia de boneco de posto.';

  @override
  String get setFoodName => 'Guerra de Comida';

  @override
  String get setHeroesName => 'Heróis Corajosos';

  @override
  String get setRopesName => 'Colecionador de Cordas';

  @override
  String get setTrailsName => 'Desbravador';

  @override
  String get setFailsName => 'Falhas Épicas';

  @override
  String get setDancesName => 'Pista de Dança';

  @override
  String get seasonPirateName => 'Tesouro Pirata';

  @override
  String get seasonRobotName => 'Robô-Bagunça';

  @override
  String get seasonDinoName => 'Dias de Dino';

  @override
  String get seasonWizardName => 'Semanas dos Magos';

  @override
  String get productStarterPackName => 'Pacote Inicial';

  @override
  String get productStarterPackTagline =>
      '300 gemas, 2.500 moedas e a corda Laser. Só uma vez!';

  @override
  String get productRemoveAdsName => 'Sem Anúncios';

  @override
  String get productRemoveAdsTagline =>
      'Chega de anúncios entre as fases. Os vídeos bônus continuam opcionais.';

  @override
  String get productSeasonPassName => 'Passe Premium';

  @override
  String get productSeasonPassTagline => 'A trilha premium desta temporada.';

  @override
  String get productGemsSmallName => 'Punhado de Gemas';

  @override
  String get productGemsSmallTagline => '80 gemas';

  @override
  String get productGemsMediumName => 'Saco de Gemas';

  @override
  String get productGemsMediumTagline => '450 gemas (+12% de bônus)';

  @override
  String get productGemsLargeName => 'Baú de Gemas';

  @override
  String get productGemsLargeTagline => '1.000 gemas (+25% de bônus)';

  @override
  String get productGemsHugeName => 'Cofre de Gemas';

  @override
  String get productGemsHugeTagline => '2.200 gemas (+37% de bônus)';

  @override
  String get hintLevel1 =>
      'Segure em qualquer lugar para agarrar a argola brilhante. Solte para voar!';

  @override
  String get hintLevel2 => 'Solte na subida do balanço para voar mais longe.';

  @override
  String get hintLevel3 => 'Vermelho dói. Não encoste nos espinhos!';

  @override
  String get hintLevel5 => 'Espinhos em cima também. Não voe alto demais!';

  @override
  String get hintLevel6 =>
      'Os blocos verdes te jogam para cima. Use-os para atravessar buracos grandes.';

  @override
  String get hintLevel7 => 'Serras giram. Serras machucam. Desvie delas.';

  @override
  String get hintLevel8 =>
      'Bandeiras são checkpoints. Se cair, você revive ali.';

  @override
  String get hintLevel9 => 'Algumas serras se mexem. Preste atenção no ritmo.';

  @override
  String get hintLevel12 => 'Balance alto e solte para subir.';

  @override
  String get hintLevel14 => 'Tudo que sobe... geralmente desce.';

  @override
  String get hintLevel15 => 'Tudo de uma vez. Boa sorte!';

  @override
  String get hintLevel21 => 'Algumas argolas se mexem. Agarre na hora certa!';

  @override
  String get hintLevel41 =>
      'O vidro quebra se você bater rápido o bastante. Atravesse!';

  @override
  String get hintLevel61 => 'Ventiladores te sopram para cima. Surfe no vento!';

  @override
  String get hintLevel64 =>
      'Zonas roxas invertem a gravidade. Cima é o novo baixo.';

  @override
  String get hintLevel81 =>
      'Plataformas que desmoronam caem logo depois que você pisa. Não pare!';

  @override
  String get hintLevel84 => 'Foguetes não te matam... mas os espinhos sim.';
}
