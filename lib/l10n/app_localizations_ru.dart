// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get back => 'Назад';

  @override
  String get cancel => 'Отмена';

  @override
  String get settings => 'Настройки';

  @override
  String get leaderboards => 'Рейтинги';

  @override
  String get leaderboard => 'Рейтинг';

  @override
  String get achievements => 'Достижения';

  @override
  String get challengeCode => 'Код вызова';

  @override
  String couldNotSignIn(String service) {
    return 'Не удалось войти в $service.';
  }

  @override
  String get play => 'ИГРАТЬ';

  @override
  String get endless => 'БЕСКОНЕЧНЫЙ';

  @override
  String endlessBest(int distance) {
    return 'Рекорд $distance м';
  }

  @override
  String get endlessPitch => 'Как далеко ты сможешь?';

  @override
  String get shop => 'МАГАЗИН';

  @override
  String get shopPitch => 'Скины, верёвки и не только';

  @override
  String get pass => 'ПРОПУСК';

  @override
  String passTier(int tier, int total) {
    return 'Ранг $tier/$total';
  }

  @override
  String get daily => 'ЗАДАНИЕ ДНЯ';

  @override
  String dailyDone(int streak) {
    return 'Готово! 🔥 $streak';
  }

  @override
  String dailyKeepStreak(int streak) {
    return 'Сохрани 🔥 $streak';
  }

  @override
  String get dailyNew => 'Новое задание!';

  @override
  String get challengeCodeHint => 'Код или ссылка от друга';

  @override
  String get playEndless => 'Играть в Бесконечный';

  @override
  String get settingsTitle => 'НАСТРОЙКИ';

  @override
  String get music => 'Музыка';

  @override
  String get soundEffects => 'Звуковые эффекты';

  @override
  String get muteAll => 'Выключить всё';

  @override
  String get vibration => 'Вибрация';

  @override
  String get dailyReminders => 'Напоминания о задании дня';

  @override
  String get language => 'Язык';

  @override
  String get languageAuto => 'Язык телефона';

  @override
  String get privacyOptions => 'Настройки конфиденциальности';

  @override
  String get resetProgress => 'Сбросить прогресс';

  @override
  String get fonts => 'Шрифты';

  @override
  String gamesNotSetUp(String service) {
    return 'Рейтинги, достижения и облачные сохранения работают через $service. В этой версии они ещё не настроены.';
  }

  @override
  String gamesSignedIn(String service) {
    return 'Вход выполнен. Прогресс сохраняется в твоём аккаунте $service.';
  }

  @override
  String gamesSignedInAs(String name, String service) {
    return 'Вход выполнен: $name. Прогресс сохраняется в твоём аккаунте $service.';
  }

  @override
  String get gamesSignInPitch =>
      'Войди, чтобы сохранять прогресс и участвовать в рейтингах.';

  @override
  String get signIn => 'Войти';

  @override
  String get resetTitle => 'Сбросить прогресс?';

  @override
  String get resetBody =>
      'Твои звёзды, монеты и скины будут удалены. Это нельзя отменить.';

  @override
  String get reset => 'Сбросить';

  @override
  String clipFailed(String error) {
    return 'Не удалось создать клип: $error';
  }

  @override
  String challengeShare(int distance, String link, String code) {
    return 'Я пролетел $distance м в бесконечном режиме Floppy Swing. Сможешь побить? $link\n(Или нажми «Код вызова» в меню и введи $code.)';
  }

  @override
  String get hintRevived => 'Ты снова в игре! Держи, чтобы качаться.';

  @override
  String get hintHold => 'Держи палец где угодно, чтобы качаться!';

  @override
  String get failSpikes1 => 'Острым концом вперёд.';

  @override
  String get failSpikes2 => 'Это оставит след.';

  @override
  String get failSpikes3 => 'Шипы: 1, Ты: 0';

  @override
  String get failSaw1 => 'Нарезан ломтиками!';

  @override
  String get failSaw2 => 'Не заметил пилу?';

  @override
  String get failSaw3 => 'Бжжжжт!';

  @override
  String get failPit1 => 'Гравитация снова победила.';

  @override
  String get failPit2 => 'Вниз!';

  @override
  String get failPit3 => 'Пол колючий.';

  @override
  String get failStuck1 => 'Время вздремнуть?';

  @override
  String get failStuck2 => 'Прилип как жвачка.';

  @override
  String get failStuck3 => 'Переводишь дух?';

  @override
  String get tapToRetry => 'Нажми где угодно, чтобы повторить';

  @override
  String get shareFail => 'Поделиться провалом';

  @override
  String get challengeFriend => 'Бросить вызов другу';

  @override
  String get newCourse => 'Новая трасса';

  @override
  String get skipLevel => 'Пропустить уровень';

  @override
  String get revive => 'Ожить';

  @override
  String rankWorldwide(int rank) {
    return '#$rank в мире';
  }

  @override
  String get newBest => 'НОВЫЙ РЕКОРД!';

  @override
  String meters(int distance) {
    return '$distance м';
  }

  @override
  String endlessScore(int score, int best) {
    return 'Очки $score  ·  Рекорд $best';
  }

  @override
  String get newBestToday => 'Новое лучшее время сегодня!';

  @override
  String rankToday(int rank) {
    return '#$rank сегодня';
  }

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count дня подряд',
      many: '🔥 $count дней подряд',
      few: '🔥 $count дня подряд',
      one: '🔥 $count день подряд',
    );
    return '$_temp0';
  }

  @override
  String dayStreakBonus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count дня подряд - бонусные кристаллы!',
      many: '🔥 $count дней подряд - бонусные кристаллы!',
      few: '🔥 $count дня подряд - бонусные кристаллы!',
      one: '🔥 $count день подряд - бонусные кристаллы!',
    );
    return '$_temp0';
  }

  @override
  String get dailyClear => 'ЗАДАНИЕ ДНЯ ПРОЙДЕНО!';

  @override
  String get worldClear => 'МИР ПРОЙДЕН!';

  @override
  String get levelClear => 'УРОВЕНЬ ПРОЙДЕН!';

  @override
  String get statTime => 'Время';

  @override
  String statTarget(String time) {
    return 'цель $timeс';
  }

  @override
  String get statCoins => 'Монеты';

  @override
  String get statStyle => 'Стиль';

  @override
  String get statBest => 'Рекорд';

  @override
  String get starFinish => 'Финиш';

  @override
  String newStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '(+$count звезды)',
      many: '(+$count звёзд)',
      few: '(+$count звезды)',
      one: '(+$count звезда)',
    );
    return '$_temp0';
  }

  @override
  String worldGate(int count, String world) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Собери ещё $count звезды, чтобы открыть мир «$world»!',
      many: 'Собери ещё $count звёзд, чтобы открыть мир «$world»!',
      few: 'Собери ещё $count звезды, чтобы открыть мир «$world»!',
      one: 'Собери ещё $count звезду, чтобы открыть мир «$world»!',
    );
    return '$_temp0';
  }

  @override
  String get doubleCoins => 'Удвоить монеты';

  @override
  String get retry => 'Ещё раз';

  @override
  String get share => 'Поделиться';

  @override
  String get next => 'Дальше';

  @override
  String get done => 'Готово';

  @override
  String get levels => 'Уровни';

  @override
  String get quit => 'Выйти';

  @override
  String get paused => 'ПАУЗА';

  @override
  String get resume => 'Продолжить';

  @override
  String get restart => 'Заново';

  @override
  String get pause => 'Пауза';

  @override
  String zoneBanner(int number, String name) {
    return 'ЗОНА $number: $name';
  }

  @override
  String hudDaily(String name) {
    return 'ЗАДАНИЕ ДНЯ: $name';
  }

  @override
  String hudStyle(int score) {
    return 'СТИЛЬ $score';
  }

  @override
  String get slowMoReplay => 'ПОВТОР В ЗАМЕДЛЕНИИ';

  @override
  String get makingClip => 'Создаём твой клип…';

  @override
  String worldNumber(int number) {
    return 'МИР $number';
  }

  @override
  String get previousWorld => 'Предыдущий мир';

  @override
  String get nextWorld => 'Следующий мир';

  @override
  String collectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Собери ещё $count',
      many: 'Собери ещё $count',
      few: 'Собери ещё $count',
      one: 'Собери ещё $count',
    );
    return '$_temp0';
  }

  @override
  String starsOf(int have, int need) {
    return 'Звёзды: $have/$need';
  }

  @override
  String levelTile(int number, String name) {
    return 'Уровень $number, $name';
  }

  @override
  String levelTileLocked(int number, String name) {
    return 'Уровень $number, $name, закрыт';
  }

  @override
  String get dailyBonus => 'ЕЖЕДНЕВНЫЙ БОНУС';

  @override
  String get dailyBonusPitch => 'Заходи каждый день за наградами побольше!';

  @override
  String get claim => 'Забрать';

  @override
  String dayNumber(int day) {
    return 'День $day';
  }

  @override
  String get seasonPassTitle => 'СЕЗОННЫЙ ПРОПУСК';

  @override
  String get seasonPass => 'Сезонный пропуск';

  @override
  String tierNumber(int tier) {
    return 'Ранг $tier';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осталось $count дня',
      many: 'Осталось $count дней',
      few: 'Осталось $count дня',
      one: 'Остался $count день',
    );
    return '$_temp0';
  }

  @override
  String get seasonComplete => 'Сезон пройден!';

  @override
  String seasonXp(int xp, int perTier) {
    return '$xp / $perTier XP  ·  Получай XP за уровни, задания дня и забеги в бесконечном режиме';
  }

  @override
  String get unlockPremium => 'Открыть Премиум';

  @override
  String get or => 'или';

  @override
  String get trackFree => 'БЕСПЛАТНО';

  @override
  String get trackPremium => 'ПРЕМИУМ';

  @override
  String get tabSkins => 'Скины';

  @override
  String get tabRopes => 'Верёвки';

  @override
  String get tabTrails => 'Шлейфы';

  @override
  String get tabFails => 'Провалы';

  @override
  String get tabDances => 'Танцы';

  @override
  String get tabSets => 'Наборы';

  @override
  String get tabGems => 'Кристаллы';

  @override
  String get equipped => 'НАДЕТО';

  @override
  String get use => 'Надеть';

  @override
  String get storeUnavailable =>
      'Магазин сейчас недоступен. Проверь подключение и попробуй позже.';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get bestValue => 'ВЫГОДНЕЕ ВСЕГО';

  @override
  String plusItem(String item) {
    return '+ $item';
  }

  @override
  String purchaseThanks(String product) {
    return 'Спасибо! Открыто: $product.';
  }

  @override
  String get storeBusy => 'Магазин занят. Попробуй ещё раз.';

  @override
  String get purchasesRestored => 'Покупки восстановлены.';

  @override
  String get storeUnreachable => 'Не удалось связаться с магазином.';

  @override
  String get purchaseFailed => 'Покупка не удалась. Деньги не списаны.';

  @override
  String reminderStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сохрани серию: $count дня!',
      many: 'Сохрани серию: $count дней!',
      few: 'Сохрани серию: $count дня!',
      one: 'Сохрани серию: $count день!',
    );
    return '$_temp0';
  }

  @override
  String get reminderStreakBody =>
      'Пройди сегодняшнее задание дня до полуночи.';

  @override
  String get reminderTodayTitle => 'Задание дня ждёт тебя';

  @override
  String get reminderTodayBody =>
      'Каждый день новый уровень. Забери свои звёзды!';

  @override
  String get reminderFreshTitle => 'Новое задание дня уже здесь';

  @override
  String get reminderFreshBody =>
      'Новый уровень, новый призрак, которого надо обогнать. Соберёшь все 3 звезды?';

  @override
  String get reminderRestlessTitle => 'Флоппи заскучал';

  @override
  String get reminderRestlessBody => 'Задание дня само себя не пройдёт.';

  @override
  String get reminderTimeTitle => 'Время задания дня!';

  @override
  String get reminderTimeBody =>
      'Быстрый полёт? Пройди его, чтобы сохранить серию.';

  @override
  String get reminderChannelDescription =>
      'Напоминание, когда выходит новое задание дня.';

  @override
  String get shareTagline => 'Сможешь лучше?';

  @override
  String get shareCta => 'Floppy Swing - бесплатно на iOS и Android';

  @override
  String clipCleared(int level) {
    return 'Уровень $level пройден!';
  }

  @override
  String clipTime(int level, String time) {
    return 'Уровень $level за $timeс';
  }

  @override
  String clipSaw(int level) {
    return 'Встретил пилу на уровне $level';
  }

  @override
  String clipSpikes(int level) {
    return 'Нашёл шипы на уровне $level';
  }

  @override
  String clipPit(int level) {
    return 'Промахнулся везде на уровне $level';
  }

  @override
  String clipStuck(int level) {
    return 'Вздремнул на уровне $level';
  }

  @override
  String clipLevel(int level) {
    return 'Уровень $level';
  }

  @override
  String get wordBest => 'РЕКОРД';

  @override
  String get wordCheckpoint => 'ЧЕКПОИНТ!';

  @override
  String get wordGo => 'ВПЕРЁД!';

  @override
  String get wordSmash => 'ДЗЫНЬ!';

  @override
  String get wordKaboom => 'БАБАХ!';

  @override
  String get wordBonk => 'БОНК!';

  @override
  String get wordSaw => 'ВЖЖЖИК!';

  @override
  String get wordSpikes => 'АЙ!';

  @override
  String get wordPit => 'ОЙ-ОЙ!';

  @override
  String get wordStuck => 'ХРРР...';

  @override
  String get wordConfetti => 'УРА!';

  @override
  String get wordJackpot => 'ДЖЕКПОТ!';

  @override
  String get wordSqueak => 'ПИСК!';

  @override
  String get styleBigSwing => 'БОЛЬШОЙ ОБОРОТ';

  @override
  String get styleSmash => 'ВДРЕБЕЗГИ';

  @override
  String get styleFlip => 'САЛЬТО';

  @override
  String get styleHangTime => 'В ПОЛЁТЕ';

  @override
  String get styleCloseCall => 'НА ВОЛОСКЕ';

  @override
  String get world1Name => 'Детская площадка';

  @override
  String get world1Tagline => 'Держись. Качайся. Отпускай. Кричи.';

  @override
  String get world2Name => 'Фабрика';

  @override
  String get world2Tagline => 'Кольца на рельсах и голодные пилы.';

  @override
  String get world3Name => 'Стеклянный город';

  @override
  String get world3Tagline => 'Пробивай. Отскакивай.';

  @override
  String get world4Name => 'Небесные острова';

  @override
  String get world4Tagline => 'Лови ветер. Падай вверх.';

  @override
  String get world5Name => 'Ракетная база';

  @override
  String get world5Tagline => 'Пол рушится. Ракеты летят.';

  @override
  String get skinFloppyName => 'Флоппи';

  @override
  String get skinFloppyTagline => 'Та самая лапша.';

  @override
  String get skinBananaName => 'Банан';

  @override
  String get skinBananaTagline => 'Скользкий в полёте.';

  @override
  String get skinKnightName => 'Сэр Флопс';

  @override
  String get skinKnightTagline => 'Тяжёлые доспехи. Ноль грации.';

  @override
  String get skinAstronautName => 'Космический кадет';

  @override
  String get skinAstronautTagline => 'Гравитация - это просто совет.';

  @override
  String get skinChickenName => 'Резиновая курица';

  @override
  String get skinChickenTagline => 'Пищит при ударе. Конечно.';

  @override
  String get skinNinjaName => 'Лапша-ниндзя';

  @override
  String get skinNinjaTagline =>
      'Бесшумный. Смертоносный. В основном бесшумный.';

  @override
  String get skinPirateName => 'Капитан Флоп';

  @override
  String get skinPirateTagline => 'Йо-хо, ой-ой.';

  @override
  String get skinRobotName => 'Робо-лапша';

  @override
  String get skinRobotTagline => 'Бип. Буп. Бонк.';

  @override
  String get skinDinoName => 'Дино-мит';

  @override
  String get skinDinoTagline => 'Ручки короткие. Размах огромный.';

  @override
  String get skinWizardName => 'Флопдальф';

  @override
  String get skinWizardTagline => 'Ты не пройдёшь... упс.';

  @override
  String get skinGoldenName => 'Золотой Флоп';

  @override
  String get skinGoldenTagline => 'Собери все 300 звёзд.';

  @override
  String get itemRopeName => 'Верная верёвка';

  @override
  String get itemRopeTagline => 'Пенька. Надёжно. Бежево.';

  @override
  String get itemChainName => 'Цепь';

  @override
  String get itemChainTagline => 'Дзынь-дзынь-дзынь.';

  @override
  String get itemSpaghettiName => 'Спагетти';

  @override
  String get itemSpaghettiTagline => 'Аль денте. Почти.';

  @override
  String get itemRainbowName => 'Радуга';

  @override
  String get itemRainbowTagline => 'Качайся в цвете.';

  @override
  String get itemLaserName => 'Лазер';

  @override
  String get itemLaserTagline => 'Пиу-пиу крюк.';

  @override
  String get itemSwooshName => 'Вжух';

  @override
  String get itemSwooshTagline => 'Классический вжух.';

  @override
  String get itemSparklesName => 'Блёстки';

  @override
  String get itemSparklesTagline => 'Сказочно на любой скорости.';

  @override
  String get itemBubblesName => 'Пузыри';

  @override
  String get itemBubblesTagline => 'Буль-буль.';

  @override
  String get itemFireName => 'Огонь';

  @override
  String get itemFireTagline => 'Слишком горячо!';

  @override
  String get itemGoldName => 'Дублоны';

  @override
  String get itemGoldTagline => 'Сезон «Пиратская добыча».';

  @override
  String get itemCircuitName => 'Микросхема';

  @override
  String get itemCircuitTagline => 'Сезон «Робо-переполох».';

  @override
  String get itemLeavesName => 'Листья джунглей';

  @override
  String get itemLeavesTagline => 'Сезон «Дни динозавров».';

  @override
  String get itemStarsName => 'Звёздная пыль';

  @override
  String get itemStarsTagline => 'Сезон «Недели волшебников».';

  @override
  String get itemClassicName => 'Бац';

  @override
  String get itemClassicTagline => 'Звёзды. Много звёзд.';

  @override
  String get itemSqueakyName => 'Пищалка';

  @override
  String get itemSqueakyTagline => 'ПИИИИИСК.';

  @override
  String get itemConfettiName => 'Конфетти';

  @override
  String get itemConfettiTagline => 'Провал - это праздник.';

  @override
  String get itemCoinpileName => 'Джекпот';

  @override
  String get itemCoinpileTagline => 'Рассыпься горой монет.';

  @override
  String get itemHopName => 'Весёлый прыжок';

  @override
  String get itemHopTagline => 'Боинг-боинг-боинг.';

  @override
  String get itemBackflipName => 'Сальто назад';

  @override
  String get itemBackflipTagline => 'Идеальное приземление. Иногда.';

  @override
  String get itemSpinName => 'Торнадо';

  @override
  String get itemSpinTagline => 'Иииииии!';

  @override
  String get itemFlailName => 'Дикие махи';

  @override
  String get itemFlailTagline => 'Энергия надувного человечка.';

  @override
  String get setFoodName => 'Битва едой';

  @override
  String get setHeroesName => 'Храбрые герои';

  @override
  String get setRopesName => 'Коллекционер верёвок';

  @override
  String get setTrailsName => 'Первопроходец';

  @override
  String get setFailsName => 'Эпичные провалы';

  @override
  String get setDancesName => 'Танцпол';

  @override
  String get seasonPirateName => 'Пиратская добыча';

  @override
  String get seasonRobotName => 'Робо-переполох';

  @override
  String get seasonDinoName => 'Дни динозавров';

  @override
  String get seasonWizardName => 'Недели волшебников';

  @override
  String get productStarterPackName => 'Стартовый набор';

  @override
  String get productStarterPackTagline =>
      '300 кристаллов, 2 500 монет и верёвка Лазер. Только один раз!';

  @override
  String get productRemoveAdsName => 'Без рекламы';

  @override
  String get productRemoveAdsTagline =>
      'Никакой рекламы между уровнями. Бонусные видео остаются по желанию.';

  @override
  String get productSeasonPassName => 'Премиум-пропуск';

  @override
  String get productSeasonPassTagline => 'Премиум-линия этого сезона.';

  @override
  String get productGemsSmallName => 'Горсть кристаллов';

  @override
  String get productGemsSmallTagline => '80 кристаллов';

  @override
  String get productGemsMediumName => 'Мешок кристаллов';

  @override
  String get productGemsMediumTagline => '450 кристаллов (+12% бонус)';

  @override
  String get productGemsLargeName => 'Сундук кристаллов';

  @override
  String get productGemsLargeTagline => '1 000 кристаллов (+25% бонус)';

  @override
  String get productGemsHugeName => 'Сокровищница';

  @override
  String get productGemsHugeTagline => '2 200 кристаллов (+37% бонус)';

  @override
  String get hintLevel1 =>
      'Держи палец где угодно, чтобы схватить светящееся кольцо. Отпусти, чтобы полететь!';

  @override
  String get hintLevel2 => 'Отпускай на подъёме, чтобы улететь дальше.';

  @override
  String get hintLevel3 => 'Красное - больно. Не трогай шипы!';

  @override
  String get hintLevel5 => 'Шипы и сверху. Не взлетай слишком высоко!';

  @override
  String get hintLevel6 =>
      'Зелёные платформы подбрасывают вверх. Используй их, чтобы перелететь большие пропасти.';

  @override
  String get hintLevel7 => 'Пилы крутятся. Пилы ранят. Облетай их.';

  @override
  String get hintLevel8 => 'Флажки - это чекпоинты. Если упадёшь, оживёшь там.';

  @override
  String get hintLevel9 => 'Некоторые пилы двигаются. Следи за ритмом.';

  @override
  String get hintLevel12 => 'Раскачайся повыше и отпусти, чтобы подняться.';

  @override
  String get hintLevel14 => 'Что взлетает... обычно падает.';

  @override
  String get hintLevel15 => 'Всё и сразу. Удачи!';

  @override
  String get hintLevel21 => 'Некоторые кольца движутся. Хватай вовремя!';

  @override
  String get hintLevel41 =>
      'Стекло бьётся, если врезаться в него достаточно быстро. Пробивай!';

  @override
  String get hintLevel61 => 'Вентиляторы дуют вверх. Лови ветер!';

  @override
  String get hintLevel64 =>
      'Фиолетовые зоны переворачивают гравитацию. Верх - это новый низ.';

  @override
  String get hintLevel81 =>
      'Хрупкие платформы падают вскоре после приземления. Не останавливайся!';

  @override
  String get hintLevel84 => 'Ракеты тебя не убьют... а вот шипы - да.';
}
