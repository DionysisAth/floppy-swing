// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get back => 'Назад';

  @override
  String get cancel => 'Скасувати';

  @override
  String get settings => 'Налаштування';

  @override
  String get leaderboards => 'Рейтинги';

  @override
  String get leaderboard => 'Рейтинг';

  @override
  String get achievements => 'Досягнення';

  @override
  String get challengeCode => 'Код виклику';

  @override
  String couldNotSignIn(String service) {
    return 'Не вдалося увійти в $service.';
  }

  @override
  String get play => 'ГРАТИ';

  @override
  String get endless => 'НЕСКІНЧЕННИЙ';

  @override
  String endlessBest(int distance) {
    return 'Рекорд $distance м';
  }

  @override
  String get endlessPitch => 'Як далеко ти зможеш?';

  @override
  String get shop => 'КРАМНИЦЯ';

  @override
  String get shopPitch => 'Скіни, мотузки та інше';

  @override
  String get pass => 'ПРОПУСК';

  @override
  String passTier(int tier, int total) {
    return 'Ранг $tier/$total';
  }

  @override
  String get daily => 'ЗАВДАННЯ ДНЯ';

  @override
  String dailyDone(int streak) {
    return 'Готово! 🔥 $streak';
  }

  @override
  String dailyKeepStreak(int streak) {
    return 'Збережи 🔥 $streak';
  }

  @override
  String get dailyNew => 'Нове завдання!';

  @override
  String get challengeCodeHint => 'Код або посилання від друга';

  @override
  String get playEndless => 'Грати в Нескінченний';

  @override
  String get settingsTitle => 'НАЛАШТУВАННЯ';

  @override
  String get music => 'Музика';

  @override
  String get soundEffects => 'Звукові ефекти';

  @override
  String get muteAll => 'Вимкнути все';

  @override
  String get vibration => 'Вібрація';

  @override
  String get dailyReminders => 'Нагадування про завдання дня';

  @override
  String get language => 'Мова';

  @override
  String get languageAuto => 'Мова телефона';

  @override
  String get privacyOptions => 'Налаштування конфіденційності';

  @override
  String get resetProgress => 'Скинути прогрес';

  @override
  String get fonts => 'Шрифти';

  @override
  String gamesNotSetUp(String service) {
    return 'Рейтинги, досягнення та хмарні збереження працюють через $service. У цій версії їх ще не налаштовано.';
  }

  @override
  String gamesSignedIn(String service) {
    return 'Вхід виконано. Прогрес зберігається у твоєму обліковому записі $service.';
  }

  @override
  String gamesSignedInAs(String name, String service) {
    return 'Вхід виконано: $name. Прогрес зберігається у твоєму обліковому записі $service.';
  }

  @override
  String get gamesSignInPitch =>
      'Увійди, щоб зберігати прогрес і брати участь у рейтингах.';

  @override
  String get signIn => 'Увійти';

  @override
  String get resetTitle => 'Скинути прогрес?';

  @override
  String get resetBody =>
      'Твої зірки, монети та скіни буде видалено. Це не можна скасувати.';

  @override
  String get reset => 'Скинути';

  @override
  String clipFailed(String error) {
    return 'Не вдалося створити кліп: $error';
  }

  @override
  String challengeShare(int distance, String link, String code) {
    return 'Я пролетів $distance м у нескінченному режимі Floppy Swing. Зможеш побити? $link\n(Або натисни «Код виклику» в меню і введи $code.)';
  }

  @override
  String get hintRevived => 'Ти знову в грі! Тримай, щоб гойдатися.';

  @override
  String get hintHold => 'Тримай палець будь-де, щоб гойдатися!';

  @override
  String get failSpikes1 => 'Гострим кінцем уперед.';

  @override
  String get failSpikes2 => 'Це залишить слід.';

  @override
  String get failSpikes3 => 'Шипи: 1, Ти: 0';

  @override
  String get failSaw1 => 'Нарізано скибочками!';

  @override
  String get failSaw2 => 'Не помітив пилку?';

  @override
  String get failSaw3 => 'Бжжжжт!';

  @override
  String get failPit1 => 'Гравітація знову перемогла.';

  @override
  String get failPit2 => 'Униз!';

  @override
  String get failPit3 => 'Підлога колюча.';

  @override
  String get failStuck1 => 'Час подрімати?';

  @override
  String get failStuck2 => 'Прилип, як жуйка.';

  @override
  String get failStuck3 => 'Переводиш подих?';

  @override
  String get tapToRetry => 'Торкнися будь-де, щоб повторити';

  @override
  String get shareFail => 'Поділитися провалом';

  @override
  String get challengeFriend => 'Кинути виклик другу';

  @override
  String get newCourse => 'Нова траса';

  @override
  String get skipLevel => 'Пропустити рівень';

  @override
  String get revive => 'Ожити';

  @override
  String rankWorldwide(int rank) {
    return '#$rank у світі';
  }

  @override
  String get newBest => 'НОВИЙ РЕКОРД!';

  @override
  String meters(int distance) {
    return '$distance м';
  }

  @override
  String endlessScore(int score, int best) {
    return 'Очки $score  ·  Рекорд $best';
  }

  @override
  String get newBestToday => 'Новий найкращий час сьогодні!';

  @override
  String rankToday(int rank) {
    return '#$rank сьогодні';
  }

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count дня поспіль',
      many: '🔥 $count днів поспіль',
      few: '🔥 $count дні поспіль',
      one: '🔥 $count день поспіль',
    );
    return '$_temp0';
  }

  @override
  String dayStreakBonus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count дня поспіль - бонусні кристали!',
      many: '🔥 $count днів поспіль - бонусні кристали!',
      few: '🔥 $count дні поспіль - бонусні кристали!',
      one: '🔥 $count день поспіль - бонусні кристали!',
    );
    return '$_temp0';
  }

  @override
  String get dailyClear => 'ЗАВДАННЯ ДНЯ ПРОЙДЕНО!';

  @override
  String get worldClear => 'СВІТ ПРОЙДЕНО!';

  @override
  String get levelClear => 'РІВЕНЬ ПРОЙДЕНО!';

  @override
  String get statTime => 'Час';

  @override
  String statTarget(String time) {
    return 'ціль $timeс';
  }

  @override
  String get statCoins => 'Монети';

  @override
  String get statStyle => 'Стиль';

  @override
  String get statBest => 'Рекорд';

  @override
  String get starFinish => 'Фініш';

  @override
  String newStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '(+$count зірки)',
      many: '(+$count зірок)',
      few: '(+$count зірки)',
      one: '(+$count зірка)',
    );
    return '$_temp0';
  }

  @override
  String worldGate(int count, String world) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Збери ще $count зірки, щоб відкрити світ «$world»!',
      many: 'Збери ще $count зірок, щоб відкрити світ «$world»!',
      few: 'Збери ще $count зірки, щоб відкрити світ «$world»!',
      one: 'Збери ще $count зірку, щоб відкрити світ «$world»!',
    );
    return '$_temp0';
  }

  @override
  String get doubleCoins => 'Подвоїти монети';

  @override
  String get retry => 'Ще раз';

  @override
  String get share => 'Поділитися';

  @override
  String get next => 'Далі';

  @override
  String get done => 'Готово';

  @override
  String get levels => 'Рівні';

  @override
  String get quit => 'Вийти';

  @override
  String get paused => 'ПАУЗА';

  @override
  String get resume => 'Продовжити';

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
    return 'ЗАВДАННЯ ДНЯ: $name';
  }

  @override
  String hudStyle(int score) {
    return 'СТИЛЬ $score';
  }

  @override
  String get slowMoReplay => 'ПОВТОР В УПОВІЛЬНЕННІ';

  @override
  String get makingClip => 'Створюємо твій кліп…';

  @override
  String worldNumber(int number) {
    return 'СВІТ $number';
  }

  @override
  String get previousWorld => 'Попередній світ';

  @override
  String get nextWorld => 'Наступний світ';

  @override
  String collectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Збери ще $count',
      many: 'Збери ще $count',
      few: 'Збери ще $count',
      one: 'Збери ще $count',
    );
    return '$_temp0';
  }

  @override
  String starsOf(int have, int need) {
    return 'Зірки: $have/$need';
  }

  @override
  String levelTile(int number, String name) {
    return 'Рівень $number, $name';
  }

  @override
  String levelTileLocked(int number, String name) {
    return 'Рівень $number, $name, закрито';
  }

  @override
  String get dailyBonus => 'ЩОДЕННИЙ БОНУС';

  @override
  String get dailyBonusPitch => 'Заходь щодня по більші нагороди!';

  @override
  String get claim => 'Забрати';

  @override
  String dayNumber(int day) {
    return 'День $day';
  }

  @override
  String get seasonPassTitle => 'СЕЗОННИЙ ПРОПУСК';

  @override
  String get seasonPass => 'Сезонний пропуск';

  @override
  String tierNumber(int tier) {
    return 'Ранг $tier';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Залишилося $count дня',
      many: 'Залишилося $count днів',
      few: 'Залишилося $count дні',
      one: 'Залишився $count день',
    );
    return '$_temp0';
  }

  @override
  String get seasonComplete => 'Сезон пройдено!';

  @override
  String seasonXp(int xp, int perTier) {
    return '$xp / $perTier XP  ·  Отримуй XP за рівні, завдання дня та забіги в нескінченному режимі';
  }

  @override
  String get unlockPremium => 'Відкрити Преміум';

  @override
  String get or => 'або';

  @override
  String get trackFree => 'БЕЗКОШТОВНО';

  @override
  String get trackPremium => 'ПРЕМІУМ';

  @override
  String get tabSkins => 'Скіни';

  @override
  String get tabRopes => 'Мотузки';

  @override
  String get tabTrails => 'Шлейфи';

  @override
  String get tabFails => 'Провали';

  @override
  String get tabDances => 'Танці';

  @override
  String get tabSets => 'Набори';

  @override
  String get tabGems => 'Кристали';

  @override
  String get equipped => 'ВДЯГНЕНО';

  @override
  String get use => 'Вдягти';

  @override
  String get storeUnavailable =>
      'Крамниця зараз недоступна. Перевір з\'єднання і спробуй пізніше.';

  @override
  String get restorePurchases => 'Відновити покупки';

  @override
  String get bestValue => 'НАЙВИГІДНІШЕ';

  @override
  String plusItem(String item) {
    return '+ $item';
  }

  @override
  String purchaseThanks(String product) {
    return 'Дякуємо! Відкрито: $product.';
  }

  @override
  String get storeBusy => 'Крамниця зайнята. Спробуй ще раз.';

  @override
  String get purchasesRestored => 'Покупки відновлено.';

  @override
  String get storeUnreachable => 'Не вдалося зв\'язатися з крамницею.';

  @override
  String get purchaseFailed => 'Покупка не вдалася. Кошти не списано.';

  @override
  String reminderStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Збережи серію: $count дня!',
      many: 'Збережи серію: $count днів!',
      few: 'Збережи серію: $count дні!',
      one: 'Збережи серію: $count день!',
    );
    return '$_temp0';
  }

  @override
  String get reminderStreakBody =>
      'Пройди сьогоднішнє завдання дня до півночі.';

  @override
  String get reminderTodayTitle => 'Завдання дня чекає на тебе';

  @override
  String get reminderTodayBody => 'Щодня новий рівень. Забери свої зірки!';

  @override
  String get reminderFreshTitle => 'Нове завдання дня вже тут';

  @override
  String get reminderFreshBody =>
      'Новий рівень, новий привид, якого треба обігнати. Збереш усі 3 зірки?';

  @override
  String get reminderRestlessTitle => 'Флоппі занудьгував';

  @override
  String get reminderRestlessBody => 'Завдання дня саме себе не пройде.';

  @override
  String get reminderTimeTitle => 'Час для завдання дня!';

  @override
  String get reminderTimeBody =>
      'Швидкий політ? Пройди його, щоб зберегти серію.';

  @override
  String get reminderChannelDescription =>
      'Нагадування, коли виходить нове завдання дня.';

  @override
  String get shareTagline => 'Зможеш краще?';

  @override
  String get shareCta => 'Floppy Swing - безкоштовно на iOS та Android';

  @override
  String clipCleared(int level) {
    return 'Рівень $level пройдено!';
  }

  @override
  String clipTime(int level, String time) {
    return 'Рівень $level за $timeс';
  }

  @override
  String clipSaw(int level) {
    return 'Зустрів пилку на рівні $level';
  }

  @override
  String clipSpikes(int level) {
    return 'Знайшов шипи на рівні $level';
  }

  @override
  String clipPit(int level) {
    return 'Промахнувся всюди на рівні $level';
  }

  @override
  String clipStuck(int level) {
    return 'Подрімав на рівні $level';
  }

  @override
  String clipLevel(int level) {
    return 'Рівень $level';
  }

  @override
  String get wordBest => 'РЕКОРД';

  @override
  String get wordCheckpoint => 'ЧЕКПОЙНТ!';

  @override
  String get wordGo => 'ВПЕРЕД!';

  @override
  String get wordSmash => 'ДЗЕНЬ!';

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
  String get styleBigSwing => 'ВЕЛИКИЙ ОБЕРТ';

  @override
  String get styleSmash => 'ВЩЕНТ';

  @override
  String get styleFlip => 'САЛЬТО';

  @override
  String get styleHangTime => 'У ПОЛЬОТІ';

  @override
  String get styleCloseCall => 'НА ВОЛОСИНІ';

  @override
  String get world1Name => 'Дитячий майданчик';

  @override
  String get world1Tagline => 'Тримайся. Гойдайся. Відпускай. Кричи.';

  @override
  String get world2Name => 'Фабрика';

  @override
  String get world2Tagline => 'Кільця на рейках і голодні пилки.';

  @override
  String get world3Name => 'Скляне місто';

  @override
  String get world3Tagline => 'Пробивай. Відскакуй.';

  @override
  String get world4Name => 'Небесні острови';

  @override
  String get world4Tagline => 'Лови вітер. Падай угору.';

  @override
  String get world5Name => 'Ракетна база';

  @override
  String get world5Tagline => 'Підлога руйнується. Ракети летять.';

  @override
  String get skinFloppyName => 'Флоппі';

  @override
  String get skinFloppyTagline => 'Та сама локшина.';

  @override
  String get skinBananaName => 'Банан';

  @override
  String get skinBananaTagline => 'Слизький у польоті.';

  @override
  String get skinKnightName => 'Сер Флопс';

  @override
  String get skinKnightTagline => 'Важкі обладунки. Нуль грації.';

  @override
  String get skinAstronautName => 'Космічний кадет';

  @override
  String get skinAstronautTagline => 'Гравітація - це лише порада.';

  @override
  String get skinChickenName => 'Гумова курка';

  @override
  String get skinChickenTagline => 'Пищить при ударі. Звісно.';

  @override
  String get skinNinjaName => 'Локшина-ніндзя';

  @override
  String get skinNinjaTagline =>
      'Безшумний. Смертоносний. Здебільшого безшумний.';

  @override
  String get skinPirateName => 'Капітан Флоп';

  @override
  String get skinPirateTagline => 'Йо-хо, ой-ой.';

  @override
  String get skinRobotName => 'Робо-локшина';

  @override
  String get skinRobotTagline => 'Біп. Буп. Бонк.';

  @override
  String get skinDinoName => 'Діно-міт';

  @override
  String get skinDinoTagline => 'Рученята короткі. Розмах величезний.';

  @override
  String get skinWizardName => 'Флопдальф';

  @override
  String get skinWizardTagline => 'Ти не пройдеш... ой.';

  @override
  String get skinGoldenName => 'Золотий Флоп';

  @override
  String get skinGoldenTagline => 'Збери всі 300 зірок.';

  @override
  String get itemRopeName => 'Вірна мотузка';

  @override
  String get itemRopeTagline => 'Коноплі. Надійно. Бежево.';

  @override
  String get itemChainName => 'Ланцюг';

  @override
  String get itemChainTagline => 'Дзень-дзень-дзень.';

  @override
  String get itemSpaghettiName => 'Спагеті';

  @override
  String get itemSpaghettiTagline => 'Аль денте. Майже.';

  @override
  String get itemRainbowName => 'Веселка';

  @override
  String get itemRainbowTagline => 'Гойдайся в кольорі.';

  @override
  String get itemLaserName => 'Лазер';

  @override
  String get itemLaserTagline => 'Піу-піу гак.';

  @override
  String get itemSwooshName => 'Вжух';

  @override
  String get itemSwooshTagline => 'Класичний вжух.';

  @override
  String get itemSparklesName => 'Блискітки';

  @override
  String get itemSparklesTagline => 'Казково на будь-якій швидкості.';

  @override
  String get itemBubblesName => 'Бульбашки';

  @override
  String get itemBubblesTagline => 'Буль-буль.';

  @override
  String get itemFireName => 'Вогонь';

  @override
  String get itemFireTagline => 'Надто гаряче!';

  @override
  String get itemGoldName => 'Дублони';

  @override
  String get itemGoldTagline => 'Сезон «Піратська здобич».';

  @override
  String get itemCircuitName => 'Мікросхема';

  @override
  String get itemCircuitTagline => 'Сезон «Робо-переполох».';

  @override
  String get itemLeavesName => 'Листя джунглів';

  @override
  String get itemLeavesTagline => 'Сезон «Дні динозаврів».';

  @override
  String get itemStarsName => 'Зоряний пил';

  @override
  String get itemStarsTagline => 'Сезон «Тижні чарівників».';

  @override
  String get itemClassicName => 'Бац';

  @override
  String get itemClassicTagline => 'Зірки. Багато зірок.';

  @override
  String get itemSqueakyName => 'Пищалка';

  @override
  String get itemSqueakyTagline => 'ПІІІІІСК.';

  @override
  String get itemConfettiName => 'Конфеті';

  @override
  String get itemConfettiTagline => 'Провал - це свято.';

  @override
  String get itemCoinpileName => 'Джекпот';

  @override
  String get itemCoinpileTagline => 'Розсипся горою монет.';

  @override
  String get itemHopName => 'Веселий стрибок';

  @override
  String get itemHopTagline => 'Боїнг-боїнг-боїнг.';

  @override
  String get itemBackflipName => 'Сальто назад';

  @override
  String get itemBackflipTagline => 'Ідеальне приземлення. Іноді.';

  @override
  String get itemSpinName => 'Торнадо';

  @override
  String get itemSpinTagline => 'Іііііііі!';

  @override
  String get itemFlailName => 'Дикі махи';

  @override
  String get itemFlailTagline => 'Енергія надувного чоловічка.';

  @override
  String get setFoodName => 'Битва їжею';

  @override
  String get setHeroesName => 'Хоробрі герої';

  @override
  String get setRopesName => 'Колекціонер мотузок';

  @override
  String get setTrailsName => 'Першопроходець';

  @override
  String get setFailsName => 'Епічні провали';

  @override
  String get setDancesName => 'Танцпол';

  @override
  String get seasonPirateName => 'Піратська здобич';

  @override
  String get seasonRobotName => 'Робо-переполох';

  @override
  String get seasonDinoName => 'Дні динозаврів';

  @override
  String get seasonWizardName => 'Тижні чарівників';

  @override
  String get productStarterPackName => 'Стартовий набір';

  @override
  String get productStarterPackTagline =>
      '300 кристалів, 2 500 монет і мотузка Лазер. Лише один раз!';

  @override
  String get productRemoveAdsName => 'Без реклами';

  @override
  String get productRemoveAdsTagline =>
      'Жодної реклами між рівнями. Бонусні відео лишаються за бажанням.';

  @override
  String get productSeasonPassName => 'Преміум-пропуск';

  @override
  String get productSeasonPassTagline => 'Преміум-лінія цього сезону.';

  @override
  String get productGemsSmallName => 'Жменя кристалів';

  @override
  String get productGemsSmallTagline => '80 кристалів';

  @override
  String get productGemsMediumName => 'Мішечок кристалів';

  @override
  String get productGemsMediumTagline => '450 кристалів (+12% бонус)';

  @override
  String get productGemsLargeName => 'Скриня кристалів';

  @override
  String get productGemsLargeTagline => '1 000 кристалів (+25% бонус)';

  @override
  String get productGemsHugeName => 'Скарбниця';

  @override
  String get productGemsHugeTagline => '2 200 кристалів (+37% бонус)';

  @override
  String get hintLevel1 =>
      'Тримай палець будь-де, щоб схопити кільце, що світиться. Відпусти, щоб полетіти!';

  @override
  String get hintLevel2 => 'Відпускай на підйомі, щоб полетіти далі.';

  @override
  String get hintLevel3 => 'Червоне - боляче. Не торкайся шипів!';

  @override
  String get hintLevel5 => 'Шипи і згори. Не злітай надто високо!';

  @override
  String get hintLevel6 =>
      'Зелені платформи підкидають угору. Використовуй їх, щоб перелетіти великі прірви.';

  @override
  String get hintLevel7 => 'Пилки крутяться. Пилки ранять. Облітай їх.';

  @override
  String get hintLevel8 => 'Прапорці - це чекпойнти. Якщо впадеш, оживеш там.';

  @override
  String get hintLevel9 => 'Деякі пилки рухаються. Стеж за ритмом.';

  @override
  String get hintLevel12 => 'Розгойдайся вище і відпусти, щоб піднятися.';

  @override
  String get hintLevel14 => 'Що злітає... зазвичай падає.';

  @override
  String get hintLevel15 => 'Усе й одразу. Удачі!';

  @override
  String get hintLevel21 => 'Деякі кільця рухаються. Хапай вчасно!';

  @override
  String get hintLevel41 =>
      'Скло б\'ється, якщо врізатися в нього досить швидко. Пробивай!';

  @override
  String get hintLevel61 => 'Вентилятори дмуть угору. Лови вітер!';

  @override
  String get hintLevel64 =>
      'Фіолетові зони перевертають гравітацію. Верх - це новий низ.';

  @override
  String get hintLevel81 =>
      'Крихкі платформи падають невдовзі після приземлення. Не зупиняйся!';

  @override
  String get hintLevel84 => 'Ракети тебе не вб\'ють... а от шипи - так.';
}
