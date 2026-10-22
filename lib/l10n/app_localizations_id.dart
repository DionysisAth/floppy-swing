// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get back => 'Kembali';

  @override
  String get cancel => 'Batal';

  @override
  String get settings => 'Pengaturan';

  @override
  String get leaderboards => 'Papan peringkat';

  @override
  String get leaderboard => 'Peringkat';

  @override
  String get achievements => 'Pencapaian';

  @override
  String get challengeCode => 'Kode tantangan';

  @override
  String couldNotSignIn(String service) {
    return 'Tidak bisa masuk ke $service.';
  }

  @override
  String get play => 'MAIN';

  @override
  String get endless => 'TANPA AKHIR';

  @override
  String endlessBest(int distance) {
    return 'Rekor $distance m';
  }

  @override
  String get endlessPitch => 'Seberapa jauh kamu bisa?';

  @override
  String get shop => 'TOKO';

  @override
  String get shopPitch => 'Skin, tali & lainnya';

  @override
  String get pass => 'PASS';

  @override
  String passTier(int tier, int total) {
    return 'Tingkat $tier/$total';
  }

  @override
  String get daily => 'HARIAN';

  @override
  String dailyDone(int streak) {
    return 'Selesai! 🔥 $streak';
  }

  @override
  String dailyKeepStreak(int streak) {
    return 'Jaga 🔥 $streak';
  }

  @override
  String get dailyNew => 'Tantangan baru!';

  @override
  String get challengeCodeHint => 'Kode atau tautan dari teman';

  @override
  String get playEndless => 'Main Tanpa Akhir';

  @override
  String get settingsTitle => 'PENGATURAN';

  @override
  String get music => 'Musik';

  @override
  String get soundEffects => 'Efek suara';

  @override
  String get muteAll => 'Bisukan semua';

  @override
  String get vibration => 'Getar';

  @override
  String get dailyReminders => 'Pengingat Tantangan Harian';

  @override
  String get language => 'Bahasa';

  @override
  String get languageAuto => 'Bahasa ponsel';

  @override
  String get privacyOptions => 'Opsi privasi';

  @override
  String get resetProgress => 'Reset progres';

  @override
  String get fonts => 'Font';

  @override
  String gamesNotSetUp(String service) {
    return 'Papan peringkat, pencapaian, dan simpanan cloud tersedia lewat $service. Belum diatur di versi ini.';
  }

  @override
  String gamesSignedIn(String service) {
    return 'Sudah masuk. Progresmu dicadangkan ke akun $service.';
  }

  @override
  String gamesSignedInAs(String name, String service) {
    return 'Masuk sebagai $name. Progresmu dicadangkan ke akun $service.';
  }

  @override
  String get gamesSignInPitch =>
      'Masuk untuk mencadangkan progres dan ikut papan peringkat.';

  @override
  String get signIn => 'Masuk';

  @override
  String get resetTitle => 'Reset progres?';

  @override
  String get resetBody =>
      'Bintang, koin, dan skin kamu akan dihapus. Tidak bisa dibatalkan.';

  @override
  String get reset => 'Reset';

  @override
  String clipFailed(String error) {
    return 'Gagal membuat klip: $error';
  }

  @override
  String challengeShare(int distance, String link, String code) {
    return 'Aku berayun $distance m di Floppy Swing Tanpa Akhir. Bisa kalahkan aku? $link\n(Atau ketuk \"Kode tantangan\" di menu dan masukkan $code.)';
  }

  @override
  String get hintRevived => 'Hidup lagi! Tahan untuk berayun.';

  @override
  String get hintHold => 'Tahan di mana saja untuk berayun!';

  @override
  String get failSpikes1 => 'Ujung runcing duluan.';

  @override
  String get failSpikes2 => 'Itu bakal berbekas.';

  @override
  String get failSpikes3 => 'Duri: 1, Kamu: 0';

  @override
  String get failSaw1 => 'Diiris tipis-tipis!';

  @override
  String get failSaw2 => 'Nggak lihat gergajinya?';

  @override
  String get failSaw3 => 'Bzzzzt!';

  @override
  String get failPit1 => 'Gravitasi menang lagi.';

  @override
  String get failPit2 => 'Jatuh deh!';

  @override
  String get failPit3 => 'Lantainya berduri.';

  @override
  String get failStuck1 => 'Waktunya tidur siang?';

  @override
  String get failStuck2 => 'Lengket kayak lem.';

  @override
  String get failStuck3 => 'Lagi tarik napas?';

  @override
  String get tapToRetry => 'Ketuk di mana saja untuk coba lagi';

  @override
  String get shareFail => 'Bagikan gagal';

  @override
  String get challengeFriend => 'Tantang teman';

  @override
  String get newCourse => 'Lintasan baru';

  @override
  String get skipLevel => 'Lewati level';

  @override
  String get revive => 'Hidupkan';

  @override
  String rankWorldwide(int rank) {
    return '#$rank sedunia';
  }

  @override
  String get newBest => 'REKOR BARU!';

  @override
  String meters(int distance) {
    return '$distance m';
  }

  @override
  String endlessScore(int score, int best) {
    return 'Skor $score  ·  Rekor $best';
  }

  @override
  String get newBestToday => 'Waktu terbaik baru hari ini!';

  @override
  String rankToday(int rank) {
    return '#$rank hari ini';
  }

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count hari berturut-turut',
    );
    return '$_temp0';
  }

  @override
  String dayStreakBonus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count hari berturut-turut - bonus permata!',
    );
    return '$_temp0';
  }

  @override
  String get dailyClear => 'TANTANGAN SELESAI!';

  @override
  String get worldClear => 'DUNIA SELESAI!';

  @override
  String get levelClear => 'LEVEL SELESAI!';

  @override
  String get statTime => 'Waktu';

  @override
  String statTarget(String time) {
    return 'target ${time}d';
  }

  @override
  String get statCoins => 'Koin';

  @override
  String get statStyle => 'Gaya';

  @override
  String get statBest => 'Rekor';

  @override
  String get starFinish => 'Finis';

  @override
  String newStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '(+$count bintang)',
    );
    return '$_temp0';
  }

  @override
  String worldGate(int count, String world) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kumpulkan $count bintang lagi untuk membuka $world!',
    );
    return '$_temp0';
  }

  @override
  String get doubleCoins => 'Gandakan koin';

  @override
  String get retry => 'Ulangi';

  @override
  String get share => 'Bagikan';

  @override
  String get next => 'Lanjut';

  @override
  String get done => 'Selesai';

  @override
  String get levels => 'Level';

  @override
  String get quit => 'Keluar';

  @override
  String get paused => 'JEDA';

  @override
  String get resume => 'Lanjutkan';

  @override
  String get restart => 'Mulai ulang';

  @override
  String get pause => 'Jeda';

  @override
  String zoneBanner(int number, String name) {
    return 'ZONA $number: $name';
  }

  @override
  String hudDaily(String name) {
    return 'HARIAN: $name';
  }

  @override
  String hudStyle(int score) {
    return 'GAYA $score';
  }

  @override
  String get slowMoReplay => 'TAYANGAN ULANG LAMBAT';

  @override
  String get makingClip => 'Membuat klipmu…';

  @override
  String worldNumber(int number) {
    return 'DUNIA $number';
  }

  @override
  String get previousWorld => 'Dunia sebelumnya';

  @override
  String get nextWorld => 'Dunia berikutnya';

  @override
  String collectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kumpulkan $count lagi',
    );
    return '$_temp0';
  }

  @override
  String starsOf(int have, int need) {
    return '$have/$need bintang';
  }

  @override
  String levelTile(int number, String name) {
    return 'Level $number, $name';
  }

  @override
  String levelTileLocked(int number, String name) {
    return 'Level $number, $name, terkunci';
  }

  @override
  String get dailyBonus => 'BONUS HARIAN';

  @override
  String get dailyBonusPitch =>
      'Datang setiap hari untuk hadiah yang lebih besar!';

  @override
  String get claim => 'Ambil';

  @override
  String dayNumber(int day) {
    return 'Hari $day';
  }

  @override
  String get seasonPassTitle => 'SEASON PASS';

  @override
  String get seasonPass => 'Season Pass';

  @override
  String tierNumber(int tier) {
    return 'Tingkat $tier';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hari lagi',
    );
    return '$_temp0';
  }

  @override
  String get seasonComplete => 'Musim selesai!';

  @override
  String seasonXp(int xp, int perTier) {
    return '$xp / $perTier XP  ·  Dapatkan XP dengan menyelesaikan level, tantangan harian, dan lari Tanpa Akhir';
  }

  @override
  String get unlockPremium => 'Buka Premium';

  @override
  String get or => 'atau';

  @override
  String get trackFree => 'GRATIS';

  @override
  String get trackPremium => 'PREMIUM';

  @override
  String get tabSkins => 'Skin';

  @override
  String get tabRopes => 'Tali';

  @override
  String get tabTrails => 'Jejak';

  @override
  String get tabFails => 'Gagal';

  @override
  String get tabDances => 'Tarian';

  @override
  String get tabSets => 'Set';

  @override
  String get tabGems => 'Permata';

  @override
  String get equipped => 'DIPAKAI';

  @override
  String get use => 'Pakai';

  @override
  String get storeUnavailable =>
      'Toko sedang tidak bisa dijangkau. Cek koneksimu dan coba lagi nanti.';

  @override
  String get restorePurchases => 'Pulihkan pembelian';

  @override
  String get bestValue => 'PALING HEMAT';

  @override
  String plusItem(String item) {
    return '+ $item';
  }

  @override
  String purchaseThanks(String product) {
    return 'Terima kasih! $product terbuka.';
  }

  @override
  String get storeBusy => 'Toko sedang sibuk. Silakan coba lagi.';

  @override
  String get purchasesRestored => 'Pembelian dipulihkan.';

  @override
  String get storeUnreachable => 'Tidak bisa menjangkau toko.';

  @override
  String get purchaseFailed => 'Pembelian gagal. Kamu tidak dikenai biaya.';

  @override
  String reminderStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Jaga rentetan $count harimu!',
    );
    return '$_temp0';
  }

  @override
  String get reminderStreakBody =>
      'Selesaikan Tantangan Harian hari ini sebelum tengah malam.';

  @override
  String get reminderTodayTitle => 'Tantangan Harian hari ini menunggumu';

  @override
  String get reminderTodayBody =>
      'Level baru setiap hari. Ayo kumpulkan bintangnya!';

  @override
  String get reminderFreshTitle => 'Tantangan Harian baru sudah tiba';

  @override
  String get reminderFreshBody =>
      'Level baru, hantu baru untuk dikalahkan. Bisa dapat 3 bintang?';

  @override
  String get reminderRestlessTitle => 'Floppy mulai gelisah';

  @override
  String get reminderRestlessBody =>
      'Tantangan Harian hari ini tidak akan berayun sendiri.';

  @override
  String get reminderTimeTitle => 'Waktunya Tantangan Harian!';

  @override
  String get reminderTimeBody =>
      'Berayun sebentar? Selesaikan untuk menjaga rentetanmu.';

  @override
  String get reminderChannelDescription =>
      'Pengingat saat Tantangan Harian baru keluar.';

  @override
  String get shareTagline => 'Bisa lebih baik?';

  @override
  String get shareCta => 'Floppy Swing - gratis di iOS & Android';

  @override
  String clipCleared(int level) {
    return 'Level $level selesai!';
  }

  @override
  String clipTime(int level, String time) {
    return 'Level $level dalam ${time}d';
  }

  @override
  String clipSaw(int level) {
    return 'Ketemu gergaji di level $level';
  }

  @override
  String clipSpikes(int level) {
    return 'Menemukan duri di level $level';
  }

  @override
  String clipPit(int level) {
    return 'Meleset semua di level $level';
  }

  @override
  String clipStuck(int level) {
    return 'Tidur siang di level $level';
  }

  @override
  String clipLevel(int level) {
    return 'Level $level';
  }

  @override
  String get wordBest => 'REKOR';

  @override
  String get wordCheckpoint => 'CHECKPOINT!';

  @override
  String get wordGo => 'AYO!';

  @override
  String get wordSmash => 'PRANG!';

  @override
  String get wordKaboom => 'KABOOM!';

  @override
  String get wordBonk => 'BONK!';

  @override
  String get wordSaw => 'ZZZING!';

  @override
  String get wordSpikes => 'ADUH!';

  @override
  String get wordPit => 'WADUH!';

  @override
  String get wordStuck => 'ZZZ...';

  @override
  String get wordConfetti => 'HORE!';

  @override
  String get wordJackpot => 'JACKPOT!';

  @override
  String get wordSqueak => 'CIIIT!';

  @override
  String get styleBigSwing => 'AYUNAN BESAR';

  @override
  String get styleSmash => 'PECAH';

  @override
  String get styleFlip => 'SALTO';

  @override
  String get styleHangTime => 'MELAYANG';

  @override
  String get styleCloseCall => 'NYARIS';

  @override
  String get world1Name => 'Taman Bermain';

  @override
  String get world1Tagline => 'Tahan. Ayun. Lepas. Teriak.';

  @override
  String get world2Name => 'Pabrik';

  @override
  String get world2Tagline => 'Cincin di rel dan gergaji kelaparan.';

  @override
  String get world3Name => 'Kota Kaca';

  @override
  String get world3Tagline => 'Tabrak tembus. Memantul.';

  @override
  String get world4Name => 'Pulau Langit';

  @override
  String get world4Tagline => 'Tunggangi angin. Jatuh ke atas.';

  @override
  String get world5Name => 'Pangkalan Roket';

  @override
  String get world5Tagline => 'Lantai runtuh. Roket terbang.';

  @override
  String get skinFloppyName => 'Floppy';

  @override
  String get skinFloppyTagline => 'Mi yang asli.';

  @override
  String get skinBananaName => 'Pisang';

  @override
  String get skinBananaTagline => 'Licin saat berayun.';

  @override
  String get skinKnightName => 'Sir Flops';

  @override
  String get skinKnightTagline => 'Baju zirah berat. Nol keanggunan.';

  @override
  String get skinAstronautName => 'Kadet Antariksa';

  @override
  String get skinAstronautTagline => 'Gravitasi cuma saran.';

  @override
  String get skinChickenName => 'Ayam Karet';

  @override
  String get skinChickenTagline => 'Mencicit saat menabrak. Jelas.';

  @override
  String get skinNinjaName => 'Ninja Mi';

  @override
  String get skinNinjaTagline => 'Senyap. Mematikan. Biasanya senyap.';

  @override
  String get skinPirateName => 'Kapten Flop';

  @override
  String get skinPirateTagline => 'Yo ho, oh tidak.';

  @override
  String get skinRobotName => 'Robo-Mi';

  @override
  String get skinRobotTagline => 'Bip. Bup. Bonk.';

  @override
  String get skinDinoName => 'Dino-Mit';

  @override
  String get skinDinoTagline => 'Lengan mungil. Ayunan besar.';

  @override
  String get skinWizardName => 'Flopdalf';

  @override
  String get skinWizardTagline => 'Kamu tidak boleh lewat... ups.';

  @override
  String get skinGoldenName => 'Flop Emas';

  @override
  String get skinGoldenTagline => 'Kumpulkan semua 300 bintang.';

  @override
  String get itemRopeName => 'Tali Setia';

  @override
  String get itemRopeTagline => 'Rami. Andal. Krem.';

  @override
  String get itemChainName => 'Rantai';

  @override
  String get itemChainTagline => 'Klinting klinting klinting.';

  @override
  String get itemSpaghettiName => 'Spageti';

  @override
  String get itemSpaghettiTagline => 'Al dente. Hampir.';

  @override
  String get itemRainbowName => 'Pelangi';

  @override
  String get itemRainbowTagline => 'Berayun penuh warna.';

  @override
  String get itemLaserName => 'Laser';

  @override
  String get itemLaserTagline => 'Kait piu piu.';

  @override
  String get itemSwooshName => 'Wus';

  @override
  String get itemSwooshTagline => 'Wus klasik.';

  @override
  String get itemSparklesName => 'Kilauan';

  @override
  String get itemSparklesTagline => 'Keren di kecepatan apa pun.';

  @override
  String get itemBubblesName => 'Gelembung';

  @override
  String get itemBubblesTagline => 'Blub blub.';

  @override
  String get itemFireName => 'Api';

  @override
  String get itemFireTagline => 'Terlalu panas!';

  @override
  String get itemGoldName => 'Doubloon';

  @override
  String get itemGoldTagline => 'Musim Harta Bajak Laut.';

  @override
  String get itemCircuitName => 'Sirkuit';

  @override
  String get itemCircuitTagline => 'Musim Robo Ricuh.';

  @override
  String get itemLeavesName => 'Daun Hutan';

  @override
  String get itemLeavesTagline => 'Musim Hari Dino.';

  @override
  String get itemStarsName => 'Debu Bintang';

  @override
  String get itemStarsTagline => 'Musim Pekan Penyihir.';

  @override
  String get itemClassicName => 'Kapow';

  @override
  String get itemClassicTagline => 'Bintang. Banyak bintang.';

  @override
  String get itemSqueakyName => 'Mainan Mencicit';

  @override
  String get itemSqueakyTagline => 'CIIIIIT.';

  @override
  String get itemConfettiName => 'Pesta Konfeti';

  @override
  String get itemConfettiTagline => 'Gagal itu perayaan.';

  @override
  String get itemCoinpileName => 'Jackpot';

  @override
  String get itemCoinpileTagline => 'Meledak jadi tumpukan koin.';

  @override
  String get itemHopName => 'Lompat Gembira';

  @override
  String get itemHopTagline => 'Boing boing boing.';

  @override
  String get itemBackflipName => 'Salto Belakang';

  @override
  String get itemBackflipTagline => 'Mendarat mulus. Kadang-kadang.';

  @override
  String get itemSpinName => 'Tornado';

  @override
  String get itemSpinTagline => 'Wiiiiii!';

  @override
  String get itemFlailName => 'Goyang Heboh';

  @override
  String get itemFlailTagline => 'Energi boneka balon tiup.';

  @override
  String get setFoodName => 'Perang Makanan';

  @override
  String get setHeroesName => 'Pahlawan Pemberani';

  @override
  String get setRopesName => 'Kolektor Tali';

  @override
  String get setTrailsName => 'Perintis';

  @override
  String get setFailsName => 'Gagal Epik';

  @override
  String get setDancesName => 'Lantai Dansa';

  @override
  String get seasonPirateName => 'Harta Bajak Laut';

  @override
  String get seasonRobotName => 'Robo Ricuh';

  @override
  String get seasonDinoName => 'Hari Dino';

  @override
  String get seasonWizardName => 'Pekan Penyihir';

  @override
  String get productStarterPackName => 'Paket Pemula';

  @override
  String get productStarterPackTagline =>
      '300 permata, 2.500 koin, dan tali Laser. Hanya sekali!';

  @override
  String get productRemoveAdsName => 'Tanpa Iklan';

  @override
  String get productRemoveAdsTagline =>
      'Tidak ada lagi iklan antar level. Video bonus tetap opsional.';

  @override
  String get productSeasonPassName => 'Premium Pass';

  @override
  String get productSeasonPassTagline => 'Jalur premium musim ini.';

  @override
  String get productGemsSmallName => 'Segenggam Permata';

  @override
  String get productGemsSmallTagline => '80 permata';

  @override
  String get productGemsMediumName => 'Sekantong Permata';

  @override
  String get productGemsMediumTagline => '450 permata (+12% bonus)';

  @override
  String get productGemsLargeName => 'Peti Permata';

  @override
  String get productGemsLargeTagline => '1.000 permata (+25% bonus)';

  @override
  String get productGemsHugeName => 'Brankas Permata';

  @override
  String get productGemsHugeTagline => '2.200 permata (+37% bonus)';

  @override
  String get hintLevel1 =>
      'Tahan di mana saja untuk meraih cincin bercahaya. Lepas untuk terbang!';

  @override
  String get hintLevel2 => 'Lepas saat ayunan naik untuk terbang lebih jauh.';

  @override
  String get hintLevel3 => 'Merah artinya sakit. Jangan sentuh durinya!';

  @override
  String get hintLevel5 =>
      'Ada duri di atas juga. Jangan terbang terlalu tinggi!';

  @override
  String get hintLevel6 =>
      'Bantalan hijau memantulkanmu ke atas. Pakai untuk melewati celah besar.';

  @override
  String get hintLevel7 =>
      'Gergaji berputar. Gergaji menyakitkan. Berayunlah mengitarinya.';

  @override
  String get hintLevel8 =>
      'Bendera adalah checkpoint. Kalau jatuh, kamu hidup lagi di sana.';

  @override
  String get hintLevel9 => 'Beberapa gergaji bergerak. Perhatikan iramanya.';

  @override
  String get hintLevel12 => 'Berayun tinggi lalu lepas untuk naik.';

  @override
  String get hintLevel14 => 'Yang naik... biasanya turun.';

  @override
  String get hintLevel15 => 'Semuanya sekaligus. Semoga beruntung!';

  @override
  String get hintLevel21 =>
      'Beberapa cincin bergerak. Raih di saat yang tepat!';

  @override
  String get hintLevel41 =>
      'Kaca pecah kalau kamu menabraknya cukup cepat. Tabrak tembus!';

  @override
  String get hintLevel61 => 'Kipas meniupmu ke atas. Tunggangi anginnya!';

  @override
  String get hintLevel64 =>
      'Zona ungu membalik gravitasi. Atas adalah bawah yang baru.';

  @override
  String get hintLevel81 =>
      'Platform rapuh jatuh tak lama setelah kamu mendarat. Terus bergerak!';

  @override
  String get hintLevel84 => 'Roket tidak akan membunuhmu... tapi durinya iya.';
}
