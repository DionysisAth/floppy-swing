// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get back => 'Wstecz';

  @override
  String get cancel => 'Anuluj';

  @override
  String get settings => 'Ustawienia';

  @override
  String get leaderboards => 'Rankingi';

  @override
  String get leaderboard => 'Ranking';

  @override
  String get achievements => 'Osiągnięcia';

  @override
  String get challengeCode => 'Kod wyzwania';

  @override
  String couldNotSignIn(String service) {
    return 'Nie udało się zalogować do $service.';
  }

  @override
  String get play => 'GRAJ';

  @override
  String get endless => 'BEZ KOŃCA';

  @override
  String endlessBest(int distance) {
    return 'Rekord $distance m';
  }

  @override
  String get endlessPitch => 'Jak daleko dotrzesz?';

  @override
  String get shop => 'SKLEP';

  @override
  String get shopPitch => 'Skórki, liny i więcej';

  @override
  String get pass => 'KARNET';

  @override
  String passTier(int tier, int total) {
    return 'Poziom $tier/$total';
  }

  @override
  String get daily => 'CODZIENNE';

  @override
  String dailyDone(int streak) {
    return 'Gotowe! 🔥 $streak';
  }

  @override
  String dailyKeepStreak(int streak) {
    return 'Utrzymaj 🔥 $streak';
  }

  @override
  String get dailyNew => 'Nowe wyzwanie!';

  @override
  String get challengeCodeHint => 'Kod lub link od znajomego';

  @override
  String get playEndless => 'Graj w Bez końca';

  @override
  String get settingsTitle => 'USTAWIENIA';

  @override
  String get music => 'Muzyka';

  @override
  String get soundEffects => 'Efekty dźwiękowe';

  @override
  String get muteAll => 'Wycisz wszystko';

  @override
  String get vibration => 'Wibracje';

  @override
  String get dailyReminders => 'Przypomnienia o Codziennym wyzwaniu';

  @override
  String get language => 'Język';

  @override
  String get languageAuto => 'Język telefonu';

  @override
  String get privacyOptions => 'Opcje prywatności';

  @override
  String get resetProgress => 'Zresetuj postępy';

  @override
  String get fonts => 'Czcionki';

  @override
  String gamesNotSetUp(String service) {
    return 'Rankingi, osiągnięcia i zapis w chmurze działają z $service. W tej wersji nie są jeszcze skonfigurowane.';
  }

  @override
  String gamesSignedIn(String service) {
    return 'Zalogowano. Postępy są zapisywane na Twoim koncie $service.';
  }

  @override
  String gamesSignedInAs(String name, String service) {
    return 'Zalogowano jako $name. Postępy są zapisywane na Twoim koncie $service.';
  }

  @override
  String get gamesSignInPitch =>
      'Zaloguj się, aby zapisywać postępy i walczyć w rankingach.';

  @override
  String get signIn => 'Zaloguj się';

  @override
  String get resetTitle => 'Zresetować postępy?';

  @override
  String get resetBody =>
      'Stracisz gwiazdki, monety i skórki. Tego nie da się cofnąć.';

  @override
  String get reset => 'Resetuj';

  @override
  String clipFailed(String error) {
    return 'Nie udało się utworzyć klipu: $error';
  }

  @override
  String challengeShare(int distance, String link, String code) {
    return 'Przeleciałem $distance m w trybie Bez końca w Floppy Swing. Pobijesz mnie? $link\n(Albo stuknij „Kod wyzwania” w menu i wpisz $code.)';
  }

  @override
  String get hintRevived => 'Wskrzeszono! Przytrzymaj, aby się huśtać.';

  @override
  String get hintHold => 'Przytrzymaj gdziekolwiek, aby się huśtać!';

  @override
  String get failSpikes1 => 'Ostrym końcem naprzód.';

  @override
  String get failSpikes2 => 'To zostawi ślad.';

  @override
  String get failSpikes3 => 'Kolce: 1, Ty: 0';

  @override
  String get failSaw1 => 'Pokrojony w plasterki!';

  @override
  String get failSaw2 => 'Nie widziałeś tej piły?';

  @override
  String get failSaw3 => 'Bzzzzt!';

  @override
  String get failPit1 => 'Grawitacja znów wygrywa.';

  @override
  String get failPit2 => 'Leci w dół!';

  @override
  String get failPit3 => 'Podłoga kłuje.';

  @override
  String get failStuck1 => 'Czas na drzemkę?';

  @override
  String get failStuck2 => 'Przyklejony jak guma.';

  @override
  String get failStuck3 => 'Chwila oddechu?';

  @override
  String get tapToRetry => 'Stuknij gdziekolwiek, aby spróbować ponownie';

  @override
  String get shareFail => 'Udostępnij wpadkę';

  @override
  String get challengeFriend => 'Wyzwij znajomego';

  @override
  String get newCourse => 'Nowa trasa';

  @override
  String get skipLevel => 'Pomiń poziom';

  @override
  String get revive => 'Wskrześ';

  @override
  String rankWorldwide(int rank) {
    return '#$rank na świecie';
  }

  @override
  String get newBest => 'NOWY REKORD!';

  @override
  String meters(int distance) {
    return '$distance m';
  }

  @override
  String endlessScore(int score, int best) {
    return 'Wynik $score  ·  Rekord $best';
  }

  @override
  String get newBestToday => 'Nowy najlepszy czas dzisiaj!';

  @override
  String rankToday(int rank) {
    return '#$rank dzisiaj';
  }

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count dnia z rzędu',
      many: '🔥 $count dni z rzędu',
      few: '🔥 $count dni z rzędu',
      one: '🔥 $count dzień z rzędu',
    );
    return '$_temp0';
  }

  @override
  String dayStreakBonus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count dnia z rzędu - bonusowe klejnoty!',
      many: '🔥 $count dni z rzędu - bonusowe klejnoty!',
      few: '🔥 $count dni z rzędu - bonusowe klejnoty!',
      one: '🔥 $count dzień z rzędu - bonusowe klejnoty!',
    );
    return '$_temp0';
  }

  @override
  String get dailyClear => 'WYZWANIE ZALICZONE!';

  @override
  String get worldClear => 'ŚWIAT UKOŃCZONY!';

  @override
  String get levelClear => 'POZIOM ZALICZONY!';

  @override
  String get statTime => 'Czas';

  @override
  String statTarget(String time) {
    return 'cel ${time}s';
  }

  @override
  String get statCoins => 'Monety';

  @override
  String get statStyle => 'Styl';

  @override
  String get statBest => 'Rekord';

  @override
  String get starFinish => 'Meta';

  @override
  String newStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '(+$count gwiazdki)',
      many: '(+$count gwiazdek)',
      few: '(+$count gwiazdki)',
      one: '(+$count gwiazdka)',
    );
    return '$_temp0';
  }

  @override
  String worldGate(int count, String world) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zbierz jeszcze $count gwiazdki, aby otworzyć: $world!',
      many: 'Zbierz jeszcze $count gwiazdek, aby otworzyć: $world!',
      few: 'Zbierz jeszcze $count gwiazdki, aby otworzyć: $world!',
      one: 'Zbierz jeszcze $count gwiazdkę, aby otworzyć: $world!',
    );
    return '$_temp0';
  }

  @override
  String get doubleCoins => 'Podwój monety';

  @override
  String get retry => 'Jeszcze raz';

  @override
  String get share => 'Udostępnij';

  @override
  String get next => 'Dalej';

  @override
  String get done => 'Gotowe';

  @override
  String get levels => 'Poziomy';

  @override
  String get quit => 'Wyjdź';

  @override
  String get paused => 'PAUZA';

  @override
  String get resume => 'Wznów';

  @override
  String get restart => 'Od nowa';

  @override
  String get pause => 'Pauza';

  @override
  String zoneBanner(int number, String name) {
    return 'STREFA $number: $name';
  }

  @override
  String hudDaily(String name) {
    return 'CODZIENNE: $name';
  }

  @override
  String hudStyle(int score) {
    return 'STYL $score';
  }

  @override
  String get slowMoReplay => 'POWTÓRKA W ZWOLNIENIU';

  @override
  String get makingClip => 'Tworzymy Twój klip…';

  @override
  String worldNumber(int number) {
    return 'ŚWIAT $number';
  }

  @override
  String get previousWorld => 'Poprzedni świat';

  @override
  String get nextWorld => 'Następny świat';

  @override
  String collectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zbierz jeszcze $count',
      many: 'Zbierz jeszcze $count',
      few: 'Zbierz jeszcze $count',
      one: 'Zbierz jeszcze $count',
    );
    return '$_temp0';
  }

  @override
  String starsOf(int have, int need) {
    return '$have/$need gwiazdek';
  }

  @override
  String levelTile(int number, String name) {
    return 'Poziom $number, $name';
  }

  @override
  String levelTileLocked(int number, String name) {
    return 'Poziom $number, $name, zablokowany';
  }

  @override
  String get dailyBonus => 'DZIENNA NAGRODA';

  @override
  String get dailyBonusPitch => 'Wracaj codziennie po coraz większe nagrody!';

  @override
  String get claim => 'Odbierz';

  @override
  String dayNumber(int day) {
    return 'Dzień $day';
  }

  @override
  String get seasonPassTitle => 'KARNET SEZONOWY';

  @override
  String get seasonPass => 'Karnet sezonowy';

  @override
  String tierNumber(int tier) {
    return 'Poziom $tier';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zostało $count dnia',
      many: 'Zostało $count dni',
      few: 'Zostały $count dni',
      one: 'Został $count dzień',
    );
    return '$_temp0';
  }

  @override
  String get seasonComplete => 'Sezon ukończony!';

  @override
  String seasonXp(int xp, int perTier) {
    return '$xp / $perTier PD  ·  Zdobywaj PD, kończąc poziomy, codzienne wyzwania i biegi w trybie Bez końca';
  }

  @override
  String get unlockPremium => 'Odblokuj Premium';

  @override
  String get or => 'lub';

  @override
  String get trackFree => 'DARMOWE';

  @override
  String get trackPremium => 'PREMIUM';

  @override
  String get tabSkins => 'Skórki';

  @override
  String get tabRopes => 'Liny';

  @override
  String get tabTrails => 'Smugi';

  @override
  String get tabFails => 'Wpadki';

  @override
  String get tabDances => 'Tańce';

  @override
  String get tabSets => 'Zestawy';

  @override
  String get tabGems => 'Klejnoty';

  @override
  String get equipped => 'ZAŁOŻONE';

  @override
  String get use => 'Użyj';

  @override
  String get storeUnavailable =>
      'Sklep jest teraz niedostępny. Sprawdź połączenie i spróbuj później.';

  @override
  String get restorePurchases => 'Przywróć zakupy';

  @override
  String get bestValue => 'NAJLEPSZA OFERTA';

  @override
  String plusItem(String item) {
    return '+ $item';
  }

  @override
  String purchaseThanks(String product) {
    return 'Dzięki! Odblokowano: $product.';
  }

  @override
  String get storeBusy => 'Sklep jest zajęty. Spróbuj ponownie.';

  @override
  String get purchasesRestored => 'Zakupy przywrócone.';

  @override
  String get storeUnreachable => 'Nie udało się połączyć ze sklepem.';

  @override
  String get purchaseFailed => 'Zakup nie powiódł się. Nie pobrano opłaty.';

  @override
  String reminderStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Utrzymaj serię: $count dnia!',
      many: 'Utrzymaj serię: $count dni!',
      few: 'Utrzymaj serię: $count dni!',
      one: 'Utrzymaj serię: $count dzień!',
    );
    return '$_temp0';
  }

  @override
  String get reminderStreakBody =>
      'Ukończ dzisiejsze Codzienne wyzwanie przed północą.';

  @override
  String get reminderTodayTitle => 'Dzisiejsze Codzienne wyzwanie czeka';

  @override
  String get reminderTodayBody =>
      'Nowy poziom każdego dnia. Zgarnij te gwiazdki!';

  @override
  String get reminderFreshTitle => 'Nowe Codzienne wyzwanie już jest';

  @override
  String get reminderFreshBody =>
      'Nowy poziom, nowy duch do pokonania. Zdobędziesz wszystkie 3 gwiazdki?';

  @override
  String get reminderRestlessTitle => 'Floppy się niecierpliwi';

  @override
  String get reminderRestlessBody =>
      'Dzisiejsze Codzienne wyzwanie samo się nie przehuśta.';

  @override
  String get reminderTimeTitle => 'Czas na Codzienne wyzwanie!';

  @override
  String get reminderTimeBody =>
      'Szybkie huśtnięcie? Ukończ je, aby utrzymać serię.';

  @override
  String get reminderChannelDescription =>
      'Przypomnienie, gdy pojawi się nowe Codzienne wyzwanie.';

  @override
  String get shareTagline => 'Dasz radę lepiej?';

  @override
  String get shareCta => 'Floppy Swing - za darmo na iOS i Androida';

  @override
  String clipCleared(int level) {
    return 'Poziom $level zaliczony!';
  }

  @override
  String clipTime(int level, String time) {
    return 'Poziom $level w ${time}s';
  }

  @override
  String clipSaw(int level) {
    return 'Spotkałem piłę na poziomie $level';
  }

  @override
  String clipSpikes(int level) {
    return 'Znalazłem kolce na poziomie $level';
  }

  @override
  String clipPit(int level) {
    return 'Wszystko spudłowane na poziomie $level';
  }

  @override
  String clipStuck(int level) {
    return 'Drzemka na poziomie $level';
  }

  @override
  String clipLevel(int level) {
    return 'Poziom $level';
  }

  @override
  String get wordBest => 'REKORD';

  @override
  String get wordCheckpoint => 'PUNKT KONTROLNY!';

  @override
  String get wordGo => 'START!';

  @override
  String get wordSmash => 'BRZDĘK!';

  @override
  String get wordKaboom => 'KABUM!';

  @override
  String get wordBonk => 'BONK!';

  @override
  String get wordSaw => 'ZZZING!';

  @override
  String get wordSpikes => 'AUĆ!';

  @override
  String get wordPit => 'AŁAAA!';

  @override
  String get wordStuck => 'ZZZ...';

  @override
  String get wordConfetti => 'JUPI!';

  @override
  String get wordJackpot => 'JACKPOT!';

  @override
  String get wordSqueak => 'PISK!';

  @override
  String get styleBigSwing => 'WIELKI ZAMACH';

  @override
  String get styleSmash => 'ROZBICIE';

  @override
  String get styleFlip => 'SALTO';

  @override
  String get styleHangTime => 'W POWIETRZU';

  @override
  String get styleCloseCall => 'O WŁOS';

  @override
  String get world1Name => 'Plac zabaw';

  @override
  String get world1Tagline => 'Trzymaj. Huśtaj. Puść. Krzycz.';

  @override
  String get world2Name => 'Fabryka';

  @override
  String get world2Tagline => 'Kółka na szynach i głodne piły.';

  @override
  String get world3Name => 'Szklane Miasto';

  @override
  String get world3Tagline => 'Przebij się. Odbij się.';

  @override
  String get world4Name => 'Niebiańskie Wyspy';

  @override
  String get world4Tagline => 'Ujeżdżaj wiatr. Spadaj w górę.';

  @override
  String get world5Name => 'Baza Rakietowa';

  @override
  String get world5Tagline => 'Podłogi się kruszą. Rakiety latają.';

  @override
  String get skinFloppyName => 'Floppy';

  @override
  String get skinFloppyTagline => 'Oryginalny makaron.';

  @override
  String get skinBananaName => 'Banan';

  @override
  String get skinBananaTagline => 'Śliski przy huśtaniu.';

  @override
  String get skinKnightName => 'Sir Flops';

  @override
  String get skinKnightTagline => 'Ciężka zbroja. Zero gracji.';

  @override
  String get skinAstronautName => 'Kosmiczny Kadet';

  @override
  String get skinAstronautTagline => 'Grawitacja to tylko sugestia.';

  @override
  String get skinChickenName => 'Gumowy Kurczak';

  @override
  String get skinChickenTagline => 'Piszczy przy uderzeniu. Oczywiście.';

  @override
  String get skinNinjaName => 'Makaronowy Ninja';

  @override
  String get skinNinjaTagline => 'Cichy. Zabójczy. Zwykle cichy.';

  @override
  String get skinPirateName => 'Kapitan Flop';

  @override
  String get skinPirateTagline => 'Jo-ho, o nie.';

  @override
  String get skinRobotName => 'Robo-Makaron';

  @override
  String get skinRobotTagline => 'Bip. Bup. Bonk.';

  @override
  String get skinDinoName => 'Dino-Mit';

  @override
  String get skinDinoTagline => 'Małe rączki. Wielkie zamachy.';

  @override
  String get skinWizardName => 'Flopdalf';

  @override
  String get skinWizardTagline => 'Nie przejdziesz... ups.';

  @override
  String get skinGoldenName => 'Złoty Flop';

  @override
  String get skinGoldenTagline => 'Zbierz wszystkie 300 gwiazdek.';

  @override
  String get itemRopeName => 'Wierna Lina';

  @override
  String get itemRopeTagline => 'Konopie. Niezawodna. Beżowa.';

  @override
  String get itemChainName => 'Łańcuch';

  @override
  String get itemChainTagline => 'Brzęk brzęk brzęk.';

  @override
  String get itemSpaghettiName => 'Spaghetti';

  @override
  String get itemSpaghettiTagline => 'Al dente. Prawie.';

  @override
  String get itemRainbowName => 'Tęcza';

  @override
  String get itemRainbowTagline => 'Huśtaj się w kolorach.';

  @override
  String get itemLaserName => 'Laser';

  @override
  String get itemLaserTagline => 'Hak piu piu.';

  @override
  String get itemSwooshName => 'Śmig';

  @override
  String get itemSwooshTagline => 'Klasyczne śmignięcie.';

  @override
  String get itemSparklesName => 'Iskierki';

  @override
  String get itemSparklesTagline => 'Bajeczne przy każdej prędkości.';

  @override
  String get itemBubblesName => 'Bańki';

  @override
  String get itemBubblesTagline => 'Blub blub.';

  @override
  String get itemFireName => 'Ogień';

  @override
  String get itemFireTagline => 'Za gorąco!';

  @override
  String get itemGoldName => 'Dublony';

  @override
  String get itemGoldTagline => 'Sezon Piracki Łup.';

  @override
  String get itemCircuitName => 'Obwód';

  @override
  String get itemCircuitTagline => 'Sezon Robo-Rozróba.';

  @override
  String get itemLeavesName => 'Liście Dżungli';

  @override
  String get itemLeavesTagline => 'Sezon Dni Dinozaurów.';

  @override
  String get itemStarsName => 'Gwiezdny Pył';

  @override
  String get itemStarsTagline => 'Sezon Tygodnie Czarodziejów.';

  @override
  String get itemClassicName => 'Kapow';

  @override
  String get itemClassicTagline => 'Gwiazdki. Mnóstwo gwiazdek.';

  @override
  String get itemSqueakyName => 'Piszcząca Zabawka';

  @override
  String get itemSqueakyTagline => 'PIIIIISK.';

  @override
  String get itemConfettiName => 'Konfetti';

  @override
  String get itemConfettiTagline => 'Porażka to święto.';

  @override
  String get itemCoinpileName => 'Jackpot';

  @override
  String get itemCoinpileTagline => 'Wybuchnij stosem monet.';

  @override
  String get itemHopName => 'Wesoły Podskok';

  @override
  String get itemHopTagline => 'Boing boing boing.';

  @override
  String get itemBackflipName => 'Salto w tył';

  @override
  String get itemBackflipTagline => 'Ląduje idealnie. Czasami.';

  @override
  String get itemSpinName => 'Tornado';

  @override
  String get itemSpinTagline => 'Iiiiiiha!';

  @override
  String get itemFlailName => 'Szalone Machanie';

  @override
  String get itemFlailTagline => 'Energia dmuchanego ludzika.';

  @override
  String get setFoodName => 'Bitwa na Jedzenie';

  @override
  String get setHeroesName => 'Dzielni Bohaterowie';

  @override
  String get setRopesName => 'Kolekcjoner Lin';

  @override
  String get setTrailsName => 'Pionier';

  @override
  String get setFailsName => 'Epickie Wpadki';

  @override
  String get setDancesName => 'Parkiet';

  @override
  String get seasonPirateName => 'Piracki Łup';

  @override
  String get seasonRobotName => 'Robo-Rozróba';

  @override
  String get seasonDinoName => 'Dni Dinozaurów';

  @override
  String get seasonWizardName => 'Tygodnie Czarodziejów';

  @override
  String get productStarterPackName => 'Pakiet Startowy';

  @override
  String get productStarterPackTagline =>
      '300 klejnotów, 2500 monet i lina Laser. Tylko raz!';

  @override
  String get productRemoveAdsName => 'Bez Reklam';

  @override
  String get productRemoveAdsTagline =>
      'Koniec reklam między poziomami. Filmy z bonusami zostają opcjonalne.';

  @override
  String get productSeasonPassName => 'Karnet Premium';

  @override
  String get productSeasonPassTagline => 'Ścieżka premium tego sezonu.';

  @override
  String get productGemsSmallName => 'Garść Klejnotów';

  @override
  String get productGemsSmallTagline => '80 klejnotów';

  @override
  String get productGemsMediumName => 'Worek Klejnotów';

  @override
  String get productGemsMediumTagline => '450 klejnotów (+12% bonusu)';

  @override
  String get productGemsLargeName => 'Skrzynia Klejnotów';

  @override
  String get productGemsLargeTagline => '1000 klejnotów (+25% bonusu)';

  @override
  String get productGemsHugeName => 'Skarbiec Klejnotów';

  @override
  String get productGemsHugeTagline => '2200 klejnotów (+37% bonusu)';

  @override
  String get hintLevel1 =>
      'Przytrzymaj gdziekolwiek, aby złapać świecące kółko. Puść, aby polecieć!';

  @override
  String get hintLevel2 =>
      'Puść, gdy huśtawka idzie w górę, aby polecieć dalej.';

  @override
  String get hintLevel3 => 'Czerwone boli. Nie dotykaj kolców!';

  @override
  String get hintLevel5 => 'Kolce są też u góry. Nie lataj za wysoko!';

  @override
  String get hintLevel6 =>
      'Zielone podkładki wybijają cię w górę. Używaj ich na dużych przepaściach.';

  @override
  String get hintLevel7 => 'Piły się kręcą. Piły bolą. Omijaj je.';

  @override
  String get hintLevel8 =>
      'Flagi to punkty kontrolne. Jeśli spadniesz, odrodzisz się tam.';

  @override
  String get hintLevel9 => 'Niektóre piły się ruszają. Obserwuj rytm.';

  @override
  String get hintLevel12 => 'Rozhuśtaj się wysoko i puść, aby się wspiąć.';

  @override
  String get hintLevel14 => 'Co idzie w górę... zwykle spada.';

  @override
  String get hintLevel15 => 'Wszystko naraz. Powodzenia!';

  @override
  String get hintLevel21 =>
      'Niektóre kółka się ruszają. Złap w odpowiednim momencie!';

  @override
  String get hintLevel41 =>
      'Szkło pęka, jeśli uderzysz wystarczająco szybko. Przebij się!';

  @override
  String get hintLevel61 => 'Wiatraki dmuchają cię w górę. Ujeżdżaj wiatr!';

  @override
  String get hintLevel64 =>
      'Fioletowe strefy odwracają grawitację. Góra to nowy dół.';

  @override
  String get hintLevel81 =>
      'Kruszące się platformy spadają chwilę po wylądowaniu. Nie zatrzymuj się!';

  @override
  String get hintLevel84 => 'Rakiety cię nie zabiją... ale kolce tak.';
}
