// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get back => 'Geri';

  @override
  String get cancel => 'İptal';

  @override
  String get settings => 'Ayarlar';

  @override
  String get leaderboards => 'Sıralamalar';

  @override
  String get leaderboard => 'Sıralama';

  @override
  String get achievements => 'Başarımlar';

  @override
  String get challengeCode => 'Meydan okuma kodu';

  @override
  String couldNotSignIn(String service) {
    return '$service hesabına giriş yapılamadı.';
  }

  @override
  String get play => 'OYNA';

  @override
  String get endless => 'SONSUZ';

  @override
  String endlessBest(int distance) {
    return 'Rekor $distance m';
  }

  @override
  String get endlessPitch => 'Ne kadar uzağa gidebilirsin?';

  @override
  String get shop => 'MAĞAZA';

  @override
  String get shopPitch => 'Kostümler, ipler ve dahası';

  @override
  String get pass => 'PASO';

  @override
  String passTier(int tier, int total) {
    return 'Kademe $tier/$total';
  }

  @override
  String get daily => 'GÜNLÜK';

  @override
  String dailyDone(int streak) {
    return 'Tamam! 🔥 $streak';
  }

  @override
  String dailyKeepStreak(int streak) {
    return '🔥 $streak serini koru';
  }

  @override
  String get dailyNew => 'Yeni görev!';

  @override
  String get challengeCodeHint => 'Arkadaşından kod veya bağlantı';

  @override
  String get playEndless => 'Sonsuz oyna';

  @override
  String get settingsTitle => 'AYARLAR';

  @override
  String get music => 'Müzik';

  @override
  String get soundEffects => 'Ses efektleri';

  @override
  String get muteAll => 'Tümünü sessize al';

  @override
  String get vibration => 'Titreşim';

  @override
  String get dailyReminders => 'Günlük Görev hatırlatıcıları';

  @override
  String get language => 'Dil';

  @override
  String get languageAuto => 'Telefonun dili';

  @override
  String get privacyOptions => 'Gizlilik seçenekleri';

  @override
  String get resetProgress => 'İlerlemeyi sıfırla';

  @override
  String get fonts => 'Yazı tipleri';

  @override
  String gamesNotSetUp(String service) {
    return 'Sıralamalar, başarımlar ve bulut kaydı $service ile gelir. Bu sürümde henüz ayarlanmadı.';
  }

  @override
  String gamesSignedIn(String service) {
    return 'Giriş yapıldı. İlerlemen $service hesabına yedekleniyor.';
  }

  @override
  String gamesSignedInAs(String name, String service) {
    return '$name olarak giriş yapıldı. İlerlemen $service hesabına yedekleniyor.';
  }

  @override
  String get gamesSignInPitch =>
      'İlerlemeni yedeklemek ve sıralamalara katılmak için giriş yap.';

  @override
  String get signIn => 'Giriş yap';

  @override
  String get resetTitle => 'İlerleme sıfırlansın mı?';

  @override
  String get resetBody =>
      'Yıldızların, paraların ve kostümlerin silinir. Bu işlem geri alınamaz.';

  @override
  String get reset => 'Sıfırla';

  @override
  String clipFailed(String error) {
    return 'Klip oluşturulamadı: $error';
  }

  @override
  String challengeShare(int distance, String link, String code) {
    return 'Floppy Swing Sonsuz modunda $distance m sallandım. Beni geçebilir misin? $link\n(Ya da menüde \"Meydan okuma kodu\"na dokunup $code yaz.)';
  }

  @override
  String get hintRevived => 'Dirildin! Sallanmak için basılı tut.';

  @override
  String get hintHold => 'Sallanmak için herhangi bir yere basılı tut!';

  @override
  String get failSpikes1 => 'Önce sivri uç.';

  @override
  String get failSpikes2 => 'Bu iz bırakır.';

  @override
  String get failSpikes3 => 'Diken: 1, Sen: 0';

  @override
  String get failSaw1 => 'Dilim dilim!';

  @override
  String get failSaw2 => 'Testereyi görmedin mi?';

  @override
  String get failSaw3 => 'Bzzzzt!';

  @override
  String get failPit1 => 'Yerçekimi yine kazandı.';

  @override
  String get failPit2 => 'Aşağı gidiyorsun!';

  @override
  String get failPit3 => 'Zemin batıyor.';

  @override
  String get failStuck1 => 'Şekerleme vakti mi?';

  @override
  String get failStuck2 => 'Yapışkan gibi kaldın.';

  @override
  String get failStuck3 => 'Biraz nefes mi alıyorsun?';

  @override
  String get tapToRetry => 'Tekrar denemek için bir yere dokun';

  @override
  String get shareFail => 'Fiyaskoyu paylaş';

  @override
  String get challengeFriend => 'Arkadaşına meydan oku';

  @override
  String get newCourse => 'Yeni parkur';

  @override
  String get skipLevel => 'Bölümü atla';

  @override
  String get revive => 'Dirilt';

  @override
  String rankWorldwide(int rank) {
    return 'Dünyada #$rank';
  }

  @override
  String get newBest => 'YENİ REKOR!';

  @override
  String meters(int distance) {
    return '$distance m';
  }

  @override
  String endlessScore(int score, int best) {
    return 'Skor $score  ·  Rekor $best';
  }

  @override
  String get newBestToday => 'Bugünün en iyi süresi!';

  @override
  String rankToday(int rank) {
    return 'Bugün #$rank';
  }

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count günlük seri',
    );
    return '$_temp0';
  }

  @override
  String dayStreakBonus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count günlük seri - bonus mücevher!',
    );
    return '$_temp0';
  }

  @override
  String get dailyClear => 'GÜNLÜK GÖREV TAMAM!';

  @override
  String get worldClear => 'DÜNYA TAMAM!';

  @override
  String get levelClear => 'BÖLÜM TAMAM!';

  @override
  String get statTime => 'Süre';

  @override
  String statTarget(String time) {
    return 'hedef ${time}s';
  }

  @override
  String get statCoins => 'Paralar';

  @override
  String get statStyle => 'Stil';

  @override
  String get statBest => 'Rekor';

  @override
  String get starFinish => 'Bitiş';

  @override
  String newStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '(+$count yıldız)',
    );
    return '$_temp0';
  }

  @override
  String worldGate(int count, String world) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$world açılması için $count yıldız daha topla!',
    );
    return '$_temp0';
  }

  @override
  String get doubleCoins => 'Paraları ikiye katla';

  @override
  String get retry => 'Tekrar';

  @override
  String get share => 'Paylaş';

  @override
  String get next => 'Sonraki';

  @override
  String get done => 'Bitti';

  @override
  String get levels => 'Bölümler';

  @override
  String get quit => 'Çık';

  @override
  String get paused => 'DURAKLATILDI';

  @override
  String get resume => 'Devam';

  @override
  String get restart => 'Baştan başla';

  @override
  String get pause => 'Duraklat';

  @override
  String zoneBanner(int number, String name) {
    return 'BÖLGE $number: $name';
  }

  @override
  String hudDaily(String name) {
    return 'GÜNLÜK: $name';
  }

  @override
  String hudStyle(int score) {
    return 'STİL $score';
  }

  @override
  String get slowMoReplay => 'AĞIR ÇEKİM TEKRAR';

  @override
  String get makingClip => 'Klibin hazırlanıyor…';

  @override
  String worldNumber(int number) {
    return 'DÜNYA $number';
  }

  @override
  String get previousWorld => 'Önceki dünya';

  @override
  String get nextWorld => 'Sonraki dünya';

  @override
  String collectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tane daha topla',
    );
    return '$_temp0';
  }

  @override
  String starsOf(int have, int need) {
    return '$have/$need yıldız';
  }

  @override
  String levelTile(int number, String name) {
    return 'Bölüm $number, $name';
  }

  @override
  String levelTileLocked(int number, String name) {
    return 'Bölüm $number, $name, kilitli';
  }

  @override
  String get dailyBonus => 'GÜNLÜK ÖDÜL';

  @override
  String get dailyBonusPitch => 'Her gün gel, daha büyük ödüller kazan!';

  @override
  String get claim => 'Al';

  @override
  String dayNumber(int day) {
    return '$day. gün';
  }

  @override
  String get seasonPassTitle => 'SEZON BİLETİ';

  @override
  String get seasonPass => 'Sezon Bileti';

  @override
  String tierNumber(int tier) {
    return 'Kademe $tier';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün kaldı',
    );
    return '$_temp0';
  }

  @override
  String get seasonComplete => 'Sezon tamamlandı!';

  @override
  String seasonXp(int xp, int perTier) {
    return '$xp / $perTier XP  ·  Bölüm, günlük görev ve Sonsuz koşuları bitirerek XP kazan';
  }

  @override
  String get unlockPremium => 'Premium\'u aç';

  @override
  String get or => 'veya';

  @override
  String get trackFree => 'ÜCRETSİZ';

  @override
  String get trackPremium => 'PREMİUM';

  @override
  String get tabSkins => 'Kostümler';

  @override
  String get tabRopes => 'İpler';

  @override
  String get tabTrails => 'İzler';

  @override
  String get tabFails => 'Fiyaskolar';

  @override
  String get tabDances => 'Danslar';

  @override
  String get tabSets => 'Setler';

  @override
  String get tabGems => 'Mücevherler';

  @override
  String get equipped => 'KUŞANILDI';

  @override
  String get use => 'Kullan';

  @override
  String get storeUnavailable =>
      'Mağazaya şu anda ulaşılamıyor. Bağlantını kontrol edip daha sonra tekrar dene.';

  @override
  String get restorePurchases => 'Satın alımları geri yükle';

  @override
  String get bestValue => 'EN AVANTAJLI';

  @override
  String plusItem(String item) {
    return '+ $item';
  }

  @override
  String purchaseThanks(String product) {
    return 'Teşekkürler! $product açıldı.';
  }

  @override
  String get storeBusy => 'Mağaza meşgul. Lütfen tekrar dene.';

  @override
  String get purchasesRestored => 'Satın alımlar geri yüklendi.';

  @override
  String get storeUnreachable => 'Mağazaya ulaşılamadı.';

  @override
  String get purchaseFailed => 'Satın alma başarısız. Ücret alınmadı.';

  @override
  String reminderStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count günlük serini koru!',
    );
    return '$_temp0';
  }

  @override
  String get reminderStreakBody =>
      'Bugünün Günlük Görevini gece yarısından önce bitir.';

  @override
  String get reminderTodayTitle => 'Bugünün Günlük Görevi seni bekliyor';

  @override
  String get reminderTodayBody =>
      'Her gün yeni bir bölüm. Git o yıldızları topla!';

  @override
  String get reminderFreshTitle => 'Yeni bir Günlük Görev geldi';

  @override
  String get reminderFreshBody =>
      'Yeni bölüm, yenecek yeni hayalet. 3 yıldızın hepsini alabilecek misin?';

  @override
  String get reminderRestlessTitle => 'Floppy sabırsızlanıyor';

  @override
  String get reminderRestlessBody =>
      'Bugünün Günlük Görevi kendi kendine sallanmayacak.';

  @override
  String get reminderTimeTitle => 'Günlük Görev zamanı!';

  @override
  String get reminderTimeBody =>
      'Hızlı bir sallanış? Serini korumak için bitir.';

  @override
  String get reminderChannelDescription =>
      'Yeni bir Günlük Görev çıktığında küçük bir hatırlatma.';

  @override
  String get shareTagline => 'Daha iyisini yapabilir misin?';

  @override
  String get shareCta => 'Floppy Swing - iOS ve Android\'de ücretsiz';

  @override
  String clipCleared(int level) {
    return '$level. bölüm tamam!';
  }

  @override
  String clipTime(int level, String time) {
    return '$level. bölüm ${time}s';
  }

  @override
  String clipSaw(int level) {
    return '$level. bölümde testereye denk geldim';
  }

  @override
  String clipSpikes(int level) {
    return '$level. bölümde dikenleri buldum';
  }

  @override
  String clipPit(int level) {
    return '$level. bölümde her şeyi ıskaladım';
  }

  @override
  String clipStuck(int level) {
    return '$level. bölümde şekerleme yaptım';
  }

  @override
  String clipLevel(int level) {
    return '$level. bölüm';
  }

  @override
  String get wordBest => 'REKOR';

  @override
  String get wordCheckpoint => 'KONTROL NOKTASI!';

  @override
  String get wordGo => 'HADİ!';

  @override
  String get wordSmash => 'ŞANGIR!';

  @override
  String get wordKaboom => 'KABUM!';

  @override
  String get wordBonk => 'BONK!';

  @override
  String get wordSaw => 'ZZZING!';

  @override
  String get wordSpikes => 'AH!';

  @override
  String get wordPit => 'AYYY!';

  @override
  String get wordStuck => 'ZZZ...';

  @override
  String get wordConfetti => 'YAŞASIN!';

  @override
  String get wordJackpot => 'BÜYÜK İKRAMİYE!';

  @override
  String get wordSqueak => 'VIIK!';

  @override
  String get styleBigSwing => 'DEV SALINIM';

  @override
  String get styleSmash => 'KIRIM';

  @override
  String get styleFlip => 'TAKLA';

  @override
  String get styleHangTime => 'HAVADA';

  @override
  String get styleCloseCall => 'KIL PAYI';

  @override
  String get world1Name => 'Oyun Parkı';

  @override
  String get world1Tagline => 'Tut. Sallan. Bırak. Bağır.';

  @override
  String get world2Name => 'Fabrika';

  @override
  String get world2Tagline => 'Raylı halkalar ve aç testereler.';

  @override
  String get world3Name => 'Cam Şehir';

  @override
  String get world3Tagline => 'Kır geç. Sek.';

  @override
  String get world4Name => 'Gökyüzü Adaları';

  @override
  String get world4Tagline => 'Rüzgârla uç. Yukarı düş.';

  @override
  String get world5Name => 'Roket Üssü';

  @override
  String get world5Tagline => 'Zeminler çöker. Roketler uçar.';

  @override
  String get skinFloppyName => 'Floppy';

  @override
  String get skinFloppyTagline => 'Orijinal erişte.';

  @override
  String get skinBananaName => 'Muz';

  @override
  String get skinBananaTagline => 'Sallanırken kayar.';

  @override
  String get skinKnightName => 'Sir Flops';

  @override
  String get skinKnightTagline => 'Ağır zırh. Sıfır zarafet.';

  @override
  String get skinAstronautName => 'Uzay Öğrencisi';

  @override
  String get skinAstronautTagline => 'Yerçekimi sadece bir öneri.';

  @override
  String get skinChickenName => 'Lastik Tavuk';

  @override
  String get skinChickenTagline => 'Çarpınca öter. Tabii ki.';

  @override
  String get skinNinjaName => 'Erişte Ninja';

  @override
  String get skinNinjaTagline => 'Sessiz. Ölümcül. Çoğunlukla sessiz.';

  @override
  String get skinPirateName => 'Kaptan Flop';

  @override
  String get skinPirateTagline => 'Yo-ho, eyvah.';

  @override
  String get skinRobotName => 'Robo-Erişte';

  @override
  String get skinRobotTagline => 'Bip. Bup. Bonk.';

  @override
  String get skinDinoName => 'Dino-Mit';

  @override
  String get skinDinoTagline => 'Minik kollar. Dev salınımlar.';

  @override
  String get skinWizardName => 'Flopdalf';

  @override
  String get skinWizardTagline => 'Geçemezsin... hay aksi.';

  @override
  String get skinGoldenName => 'Altın Flop';

  @override
  String get skinGoldenTagline => '300 yıldızın hepsini topla.';

  @override
  String get itemRopeName => 'Sadık İp';

  @override
  String get itemRopeTagline => 'Kenevir. Güvenilir. Bej.';

  @override
  String get itemChainName => 'Zincir';

  @override
  String get itemChainTagline => 'Şıkır şıkır şıkır.';

  @override
  String get itemSpaghettiName => 'Spagetti';

  @override
  String get itemSpaghettiTagline => 'Al dente. Neredeyse.';

  @override
  String get itemRainbowName => 'Gökkuşağı';

  @override
  String get itemRainbowTagline => 'Renkli salınımlar.';

  @override
  String get itemLaserName => 'Lazer';

  @override
  String get itemLaserTagline => 'Piu piu kanca.';

  @override
  String get itemSwooshName => 'Vuş';

  @override
  String get itemSwooshTagline => 'Klasik vuş.';

  @override
  String get itemSparklesName => 'Pırıltı';

  @override
  String get itemSparklesTagline => 'Her hızda muhteşem.';

  @override
  String get itemBubblesName => 'Baloncuklar';

  @override
  String get itemBubblesTagline => 'Blup blup.';

  @override
  String get itemFireName => 'Ateş';

  @override
  String get itemFireTagline => 'Çok sıcak!';

  @override
  String get itemGoldName => 'Altın Sikkeler';

  @override
  String get itemGoldTagline => 'Korsan Ganimeti sezonu.';

  @override
  String get itemCircuitName => 'Devre';

  @override
  String get itemCircuitTagline => 'Robo Kargaşa sezonu.';

  @override
  String get itemLeavesName => 'Orman Yaprakları';

  @override
  String get itemLeavesTagline => 'Dino Günleri sezonu.';

  @override
  String get itemStarsName => 'Yıldız Tozu';

  @override
  String get itemStarsTagline => 'Büyücü Haftaları sezonu.';

  @override
  String get itemClassicName => 'Kapow';

  @override
  String get itemClassicTagline => 'Yıldızlar. Bir sürü yıldız.';

  @override
  String get itemSqueakyName => 'Öten Oyuncak';

  @override
  String get itemSqueakyTagline => 'VIIIIIK.';

  @override
  String get itemConfettiName => 'Konfeti Partisi';

  @override
  String get itemConfettiTagline => 'Başarısızlık bir kutlamadır.';

  @override
  String get itemCoinpileName => 'İkramiye';

  @override
  String get itemCoinpileTagline => 'Para yığınına dönüş.';

  @override
  String get itemHopName => 'Mutlu Zıplama';

  @override
  String get itemHopTagline => 'Boing boing boing.';

  @override
  String get itemBackflipName => 'Geriye Takla';

  @override
  String get itemBackflipTagline => 'İnişi yapıştırır. Bazen.';

  @override
  String get itemSpinName => 'Hortum';

  @override
  String get itemSpinTagline => 'Viiiiiii!';

  @override
  String get itemFlailName => 'Çılgın Çırpınış';

  @override
  String get itemFlailTagline => 'Şişme reklam adamı enerjisi.';

  @override
  String get setFoodName => 'Yemek Savaşı';

  @override
  String get setHeroesName => 'Cesur Kahramanlar';

  @override
  String get setRopesName => 'İp Koleksiyoncusu';

  @override
  String get setTrailsName => 'Öncü';

  @override
  String get setFailsName => 'Efsane Fiyaskolar';

  @override
  String get setDancesName => 'Dans Pisti';

  @override
  String get seasonPirateName => 'Korsan Ganimeti';

  @override
  String get seasonRobotName => 'Robo Kargaşa';

  @override
  String get seasonDinoName => 'Dino Günleri';

  @override
  String get seasonWizardName => 'Büyücü Haftaları';

  @override
  String get productStarterPackName => 'Başlangıç Paketi';

  @override
  String get productStarterPackTagline =>
      '300 mücevher, 2.500 para ve Lazer ip. Sadece bir kez!';

  @override
  String get productRemoveAdsName => 'Reklamsız';

  @override
  String get productRemoveAdsTagline =>
      'Bölümler arasında reklam yok. Bonus videolar isteğe bağlı kalır.';

  @override
  String get productSeasonPassName => 'Premium Bilet';

  @override
  String get productSeasonPassTagline => 'Bu sezonun premium yolu.';

  @override
  String get productGemsSmallName => 'Bir Avuç Mücevher';

  @override
  String get productGemsSmallTagline => '80 mücevher';

  @override
  String get productGemsMediumName => 'Kese Dolusu Mücevher';

  @override
  String get productGemsMediumTagline => '450 mücevher (+%12 bonus)';

  @override
  String get productGemsLargeName => 'Sandık Dolusu Mücevher';

  @override
  String get productGemsLargeTagline => '1.000 mücevher (+%25 bonus)';

  @override
  String get productGemsHugeName => 'Mücevher Kasası';

  @override
  String get productGemsHugeTagline => '2.200 mücevher (+%37 bonus)';

  @override
  String get hintLevel1 =>
      'Parlayan halkayı tutmak için herhangi bir yere basılı tut. Uçmak için bırak!';

  @override
  String get hintLevel2 => 'Daha uzağa uçmak için yukarı sallanırken bırak.';

  @override
  String get hintLevel3 => 'Kırmızı acıtır. Dikenlere dokunma!';

  @override
  String get hintLevel5 => 'Yukarıda da diken var. Çok yükseğe uçma!';

  @override
  String get hintLevel6 =>
      'Yeşil pedler seni yukarı zıplatır. Büyük boşlukları geçmek için kullan.';

  @override
  String get hintLevel7 =>
      'Testereler döner. Testereler acıtır. Etraflarından sallan.';

  @override
  String get hintLevel8 =>
      'Bayraklar kontrol noktasıdır. Düşersen orada dirilirsin.';

  @override
  String get hintLevel9 => 'Bazı testereler hareket eder. Ritmi izle.';

  @override
  String get hintLevel12 => 'Yükseğe sallan ve tırmanmak için bırak.';

  @override
  String get hintLevel14 => 'Yukarı çıkan... genelde aşağı iner.';

  @override
  String get hintLevel15 => 'Hepsi bir arada. Bol şans!';

  @override
  String get hintLevel21 => 'Bazı halkalar hareket eder. Doğru anda tut!';

  @override
  String get hintLevel41 => 'Cama yeterince hızlı çarparsan kırılır. Kır geç!';

  @override
  String get hintLevel61 => 'Pervaneler seni yukarı üfler. Rüzgârla uç!';

  @override
  String get hintLevel64 =>
      'Mor bölgeler yerçekimini ters çevirir. Yukarı artık aşağı.';

  @override
  String get hintLevel81 =>
      'Ufalanan platformlar sen bastıktan kısa süre sonra düşer. Durma!';

  @override
  String get hintLevel84 => 'Roketler seni öldürmez... ama dikenler öldürür.';
}
