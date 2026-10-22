// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get back => '戻る';

  @override
  String get cancel => 'キャンセル';

  @override
  String get settings => '設定';

  @override
  String get leaderboards => 'ランキング';

  @override
  String get leaderboard => 'ランキング';

  @override
  String get achievements => '実績';

  @override
  String get challengeCode => 'チャレンジコード';

  @override
  String couldNotSignIn(String service) {
    return '$serviceにサインインできませんでした。';
  }

  @override
  String get play => 'プレイ';

  @override
  String get endless => 'エンドレス';

  @override
  String endlessBest(int distance) {
    return 'ベスト $distance m';
  }

  @override
  String get endlessPitch => 'どこまで行ける？';

  @override
  String get shop => 'ショップ';

  @override
  String get shopPitch => 'スキン、ロープなど';

  @override
  String get pass => 'パス';

  @override
  String passTier(int tier, int total) {
    return 'ランク $tier/$total';
  }

  @override
  String get daily => 'デイリー';

  @override
  String dailyDone(int streak) {
    return 'クリア！🔥 $streak';
  }

  @override
  String dailyKeepStreak(int streak) {
    return '🔥 $streak をキープ';
  }

  @override
  String get dailyNew => '新しいチャレンジ！';

  @override
  String get challengeCodeHint => '友だちのコードかリンク';

  @override
  String get playEndless => 'エンドレスで遊ぶ';

  @override
  String get settingsTitle => '設定';

  @override
  String get music => '音楽';

  @override
  String get soundEffects => '効果音';

  @override
  String get muteAll => 'すべてミュート';

  @override
  String get vibration => 'バイブレーション';

  @override
  String get dailyReminders => 'デイリーチャレンジのお知らせ';

  @override
  String get language => '言語';

  @override
  String get languageAuto => '端末の言語';

  @override
  String get privacyOptions => 'プライバシー設定';

  @override
  String get resetProgress => '進行状況をリセット';

  @override
  String get fonts => 'フォント';

  @override
  String gamesNotSetUp(String service) {
    return 'ランキング、実績、クラウドセーブは$serviceで利用できます。このバージョンではまだ設定されていません。';
  }

  @override
  String gamesSignedIn(String service) {
    return 'サインイン済み。進行状況は$serviceアカウントにバックアップされます。';
  }

  @override
  String gamesSignedInAs(String name, String service) {
    return '$nameとしてサインイン中。進行状況は$serviceアカウントにバックアップされます。';
  }

  @override
  String get gamesSignInPitch => 'サインインすると進行状況をバックアップでき、ランキングにも参加できます。';

  @override
  String get signIn => 'サインイン';

  @override
  String get resetTitle => '進行状況をリセットしますか？';

  @override
  String get resetBody => 'スター、コイン、スキンがすべて消えます。元に戻せません。';

  @override
  String get reset => 'リセット';

  @override
  String clipFailed(String error) {
    return 'クリップを作成できませんでした: $error';
  }

  @override
  String challengeShare(int distance, String link, String code) {
    return 'Floppy Swingのエンドレスで$distance m飛んだよ。超えられる？ $link\n(メニューの「チャレンジコード」から $code を入力してもOK)';
  }

  @override
  String get hintRevived => '復活！長押しでスイング。';

  @override
  String get hintHold => 'どこでも長押しでスイング！';

  @override
  String get failSpikes1 => 'とがった方から突っ込んだ。';

  @override
  String get failSpikes2 => 'これはアザになるね。';

  @override
  String get failSpikes3 => 'トゲ: 1、キミ: 0';

  @override
  String get failSaw1 => 'みじん切り！';

  @override
  String get failSaw2 => 'ノコギリ、見えてた？';

  @override
  String get failSaw3 => 'ビィィィン！';

  @override
  String get failPit1 => 'またしても重力の勝ち。';

  @override
  String get failPit2 => 'まっさかさま！';

  @override
  String get failPit3 => '床はトゲトゲ。';

  @override
  String get failStuck1 => 'お昼寝タイム？';

  @override
  String get failStuck2 => 'のりみたいにくっついた。';

  @override
  String get failStuck3 => 'ひと休み中？';

  @override
  String get tapToRetry => 'どこでもタップでリトライ';

  @override
  String get shareFail => '失敗をシェア';

  @override
  String get challengeFriend => '友だちに挑戦';

  @override
  String get newCourse => '新しいコース';

  @override
  String get skipLevel => 'レベルをスキップ';

  @override
  String get revive => '復活';

  @override
  String rankWorldwide(int rank) {
    return '世界 #$rank';
  }

  @override
  String get newBest => '新記録！';

  @override
  String meters(int distance) {
    return '$distance m';
  }

  @override
  String endlessScore(int score, int best) {
    return 'スコア $score  ·  ベスト $best';
  }

  @override
  String get newBestToday => '今日のベストタイム更新！';

  @override
  String rankToday(int rank) {
    return '今日 #$rank';
  }

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count日連続',
    );
    return '$_temp0';
  }

  @override
  String dayStreakBonus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count日連続 - ボーナスジェム！',
    );
    return '$_temp0';
  }

  @override
  String get dailyClear => 'デイリークリア！';

  @override
  String get worldClear => 'ワールドクリア！';

  @override
  String get levelClear => 'レベルクリア！';

  @override
  String get statTime => 'タイム';

  @override
  String statTarget(String time) {
    return '目標 $time秒';
  }

  @override
  String get statCoins => 'コイン';

  @override
  String get statStyle => 'スタイル';

  @override
  String get statBest => 'ベスト';

  @override
  String get starFinish => 'ゴール';

  @override
  String newStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '(+$count スター)',
    );
    return '$_temp0';
  }

  @override
  String worldGate(int count, String world) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'あとスター$count個で$worldが開きます！',
    );
    return '$_temp0';
  }

  @override
  String get doubleCoins => 'コイン2倍';

  @override
  String get retry => 'リトライ';

  @override
  String get share => 'シェア';

  @override
  String get next => '次へ';

  @override
  String get done => '完了';

  @override
  String get levels => 'レベル';

  @override
  String get quit => 'やめる';

  @override
  String get paused => '一時停止';

  @override
  String get resume => '再開';

  @override
  String get restart => '最初から';

  @override
  String get pause => '一時停止';

  @override
  String zoneBanner(int number, String name) {
    return 'ゾーン$number: $name';
  }

  @override
  String hudDaily(String name) {
    return 'デイリー: $name';
  }

  @override
  String hudStyle(int score) {
    return 'スタイル $score';
  }

  @override
  String get slowMoReplay => 'スローモーションリプレイ';

  @override
  String get makingClip => 'クリップを作成中…';

  @override
  String worldNumber(int number) {
    return 'ワールド $number';
  }

  @override
  String get previousWorld => '前のワールド';

  @override
  String get nextWorld => '次のワールド';

  @override
  String collectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'あと$count個集めよう',
    );
    return '$_temp0';
  }

  @override
  String starsOf(int have, int need) {
    return 'スター $have/$need';
  }

  @override
  String levelTile(int number, String name) {
    return 'レベル$number、$name';
  }

  @override
  String levelTileLocked(int number, String name) {
    return 'レベル$number、$name、ロック中';
  }

  @override
  String get dailyBonus => 'ログインボーナス';

  @override
  String get dailyBonusPitch => '毎日来ると報酬がどんどん豪華に！';

  @override
  String get claim => '受け取る';

  @override
  String dayNumber(int day) {
    return '$day日目';
  }

  @override
  String get seasonPassTitle => 'シーズンパス';

  @override
  String get seasonPass => 'シーズンパス';

  @override
  String tierNumber(int tier) {
    return 'ランク $tier';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '残り$count日',
    );
    return '$_temp0';
  }

  @override
  String get seasonComplete => 'シーズン完了！';

  @override
  String seasonXp(int xp, int perTier) {
    return '$xp / $perTier XP  ·  レベル、デイリー、エンドレスをクリアしてXPを獲得';
  }

  @override
  String get unlockPremium => 'プレミアムを解放';

  @override
  String get or => 'または';

  @override
  String get trackFree => '無料';

  @override
  String get trackPremium => 'プレミアム';

  @override
  String get tabSkins => 'スキン';

  @override
  String get tabRopes => 'ロープ';

  @override
  String get tabTrails => '軌跡';

  @override
  String get tabFails => '失敗演出';

  @override
  String get tabDances => 'ダンス';

  @override
  String get tabSets => 'セット';

  @override
  String get tabGems => 'ジェム';

  @override
  String get equipped => '装備中';

  @override
  String get use => '使う';

  @override
  String get storeUnavailable => '現在ストアに接続できません。接続を確認して、しばらくしてからもう一度お試しください。';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get bestValue => 'いちばんお得';

  @override
  String plusItem(String item) {
    return '+ $item';
  }

  @override
  String purchaseThanks(String product) {
    return 'ありがとう！$productを解放しました。';
  }

  @override
  String get storeBusy => 'ストアが混み合っています。もう一度お試しください。';

  @override
  String get purchasesRestored => '購入を復元しました。';

  @override
  String get storeUnreachable => 'ストアに接続できませんでした。';

  @override
  String get purchaseFailed => '購入に失敗しました。料金は発生していません。';

  @override
  String reminderStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日連続をキープしよう！',
    );
    return '$_temp0';
  }

  @override
  String get reminderStreakBody => '今日のデイリーチャレンジを0時までにクリアしよう。';

  @override
  String get reminderTodayTitle => '今日のデイリーチャレンジが待ってるよ';

  @override
  String get reminderTodayBody => '毎日新しいレベル。スターを取りに行こう！';

  @override
  String get reminderFreshTitle => '新しいデイリーチャレンジが登場';

  @override
  String get reminderFreshBody => '新レベル、新しいゴーストに勝てるかな？スター3つ取れる？';

  @override
  String get reminderRestlessTitle => 'Floppyがうずうずしてる';

  @override
  String get reminderRestlessBody => '今日のデイリーチャレンジは勝手にはスイングしないよ。';

  @override
  String get reminderTimeTitle => 'デイリーチャレンジの時間！';

  @override
  String get reminderTimeBody => 'ちょっとだけスイング？クリアして連続記録をキープしよう。';

  @override
  String get reminderChannelDescription => '新しいデイリーチャレンジが出たときのお知らせ。';

  @override
  String get shareTagline => 'もっとうまくできる？';

  @override
  String get shareCta => 'Floppy Swing - iOS & Androidで無料';

  @override
  String clipCleared(int level) {
    return 'レベル$levelクリア！';
  }

  @override
  String clipTime(int level, String time) {
    return 'レベル$levelを$time秒で';
  }

  @override
  String clipSaw(int level) {
    return 'レベル$levelでノコギリに遭遇';
  }

  @override
  String clipSpikes(int level) {
    return 'レベル$levelでトゲを発見';
  }

  @override
  String clipPit(int level) {
    return 'レベル$levelで全部ミス';
  }

  @override
  String clipStuck(int level) {
    return 'レベル$levelでお昼寝';
  }

  @override
  String clipLevel(int level) {
    return 'レベル$level';
  }

  @override
  String get wordBest => 'ベスト';

  @override
  String get wordCheckpoint => 'チェックポイント！';

  @override
  String get wordGo => 'ゴー！';

  @override
  String get wordSmash => 'ガシャーン！';

  @override
  String get wordKaboom => 'ドカーン！';

  @override
  String get wordBonk => 'ゴンッ！';

  @override
  String get wordSaw => 'ギュイーン！';

  @override
  String get wordSpikes => 'イタッ！';

  @override
  String get wordPit => 'うわぁ！';

  @override
  String get wordStuck => 'ZZZ…';

  @override
  String get wordConfetti => 'ワーイ！';

  @override
  String get wordJackpot => '大当たり！';

  @override
  String get wordSqueak => 'キュッ！';

  @override
  String get styleBigSwing => '大回転';

  @override
  String get styleSmash => 'ガラス割り';

  @override
  String get styleFlip => '宙返り';

  @override
  String get styleHangTime => '滞空';

  @override
  String get styleCloseCall => 'ギリギリ';

  @override
  String get world1Name => '公園';

  @override
  String get world1Tagline => 'つかむ。振る。はなす。叫ぶ。';

  @override
  String get world2Name => '工場';

  @override
  String get world2Tagline => 'レールの上のリングと腹ペコのノコギリ。';

  @override
  String get world3Name => 'ガラスの街';

  @override
  String get world3Tagline => '突き破れ。跳ね返れ。';

  @override
  String get world4Name => '空の島';

  @override
  String get world4Tagline => '風に乗れ。上に落ちろ。';

  @override
  String get world5Name => 'ロケット基地';

  @override
  String get world5Tagline => '床は崩れ、ロケットが飛ぶ。';

  @override
  String get skinFloppyName => 'フロッピー';

  @override
  String get skinFloppyTagline => '元祖ふにゃふにゃ。';

  @override
  String get skinBananaName => 'バナナ';

  @override
  String get skinBananaTagline => 'スイングでつるっと。';

  @override
  String get skinKnightName => 'フロップス卿';

  @override
  String get skinKnightTagline => '重い鎧。優雅さゼロ。';

  @override
  String get skinAstronautName => '宇宙訓練生';

  @override
  String get skinAstronautTagline => '重力なんてただの提案。';

  @override
  String get skinChickenName => 'ゴムのニワトリ';

  @override
  String get skinChickenTagline => 'ぶつかると鳴く。当然。';

  @override
  String get skinNinjaName => 'めん忍者';

  @override
  String get skinNinjaTagline => '静か。危険。だいたい静か。';

  @override
  String get skinPirateName => 'フロップ船長';

  @override
  String get skinPirateTagline => 'ヨーホー、オーノー。';

  @override
  String get skinRobotName => 'ロボめん';

  @override
  String get skinRobotTagline => 'ピッ。ポッ。ゴンッ。';

  @override
  String get skinDinoName => 'ダイナ・マイト';

  @override
  String get skinDinoTagline => '腕は短く、スイングは大きく。';

  @override
  String get skinWizardName => 'フロップダルフ';

  @override
  String get skinWizardTagline => 'ここは通さん…おっと。';

  @override
  String get skinGoldenName => 'ゴールデン・フロップ';

  @override
  String get skinGoldenTagline => 'スター300個を全部集めよう。';

  @override
  String get itemRopeName => '頼れるロープ';

  @override
  String get itemRopeTagline => '麻。丈夫。ベージュ。';

  @override
  String get itemChainName => 'チェーン';

  @override
  String get itemChainTagline => 'チャリンチャリン。';

  @override
  String get itemSpaghettiName => 'スパゲッティ';

  @override
  String get itemSpaghettiTagline => 'アルデンテ。たぶん。';

  @override
  String get itemRainbowName => 'レインボー';

  @override
  String get itemRainbowTagline => '虹色スイング。';

  @override
  String get itemLaserName => 'レーザー';

  @override
  String get itemLaserTagline => 'ピュンピュンフック。';

  @override
  String get itemSwooshName => 'ヒュン';

  @override
  String get itemSwooshTagline => '定番のヒュン。';

  @override
  String get itemSparklesName => 'キラキラ';

  @override
  String get itemSparklesTagline => 'どんなスピードでも華やか。';

  @override
  String get itemBubblesName => 'あわあわ';

  @override
  String get itemBubblesTagline => 'ぶくぶく。';

  @override
  String get itemFireName => 'ファイア';

  @override
  String get itemFireTagline => 'アツすぎ注意。';

  @override
  String get itemGoldName => '金貨';

  @override
  String get itemGoldTagline => '海賊のお宝シーズン。';

  @override
  String get itemCircuitName => '回路';

  @override
  String get itemCircuitTagline => 'ロボ大騒動シーズン。';

  @override
  String get itemLeavesName => 'ジャングルの葉';

  @override
  String get itemLeavesTagline => '恐竜デイズシーズン。';

  @override
  String get itemStarsName => '星くず';

  @override
  String get itemStarsTagline => '魔法使いウィークシーズン。';

  @override
  String get itemClassicName => 'バシッ';

  @override
  String get itemClassicTagline => '星。星がいっぱい。';

  @override
  String get itemSqueakyName => 'ピコピコおもちゃ';

  @override
  String get itemSqueakyTagline => 'キュウウウッ。';

  @override
  String get itemConfettiName => '紙ふぶきパーティー';

  @override
  String get itemConfettiTagline => '失敗はお祝いだ。';

  @override
  String get itemCoinpileName => '大当たり';

  @override
  String get itemCoinpileTagline => 'コインの山にはじけ飛ぶ。';

  @override
  String get itemHopName => 'ハッピーホップ';

  @override
  String get itemHopTagline => 'ぴょんぴょんぴょん。';

  @override
  String get itemBackflipName => 'バク宙';

  @override
  String get itemBackflipTagline => '着地はバッチリ。ときどき。';

  @override
  String get itemSpinName => 'トルネード';

  @override
  String get itemSpinTagline => 'ひゃっほーい！';

  @override
  String get itemFlailName => 'ジタバタダンス';

  @override
  String get itemFlailTagline => 'エアダンサー人形のノリ。';

  @override
  String get setFoodName => 'フードファイト';

  @override
  String get setHeroesName => '勇敢なヒーロー';

  @override
  String get setRopesName => 'ロープコレクター';

  @override
  String get setTrailsName => '軌跡マニア';

  @override
  String get setFailsName => '伝説の失敗';

  @override
  String get setDancesName => 'ダンスフロア';

  @override
  String get seasonPirateName => '海賊のお宝';

  @override
  String get seasonRobotName => 'ロボ大騒動';

  @override
  String get seasonDinoName => '恐竜デイズ';

  @override
  String get seasonWizardName => '魔法使いウィーク';

  @override
  String get productStarterPackName => 'スターターパック';

  @override
  String get productStarterPackTagline => 'ジェム300個、コイン2,500枚、レーザーロープ。1回限り！';

  @override
  String get productRemoveAdsName => '広告なし';

  @override
  String get productRemoveAdsTagline => 'レベル間の広告がなくなります。ボーナス動画は任意のまま。';

  @override
  String get productSeasonPassName => 'プレミアムパス';

  @override
  String get productSeasonPassTagline => '今シーズンのプレミアムトラック。';

  @override
  String get productGemsSmallName => 'ひとつかみのジェム';

  @override
  String get productGemsSmallTagline => 'ジェム80個';

  @override
  String get productGemsMediumName => 'ジェムの袋';

  @override
  String get productGemsMediumTagline => 'ジェム450個 (+12%ボーナス)';

  @override
  String get productGemsLargeName => 'ジェムの宝箱';

  @override
  String get productGemsLargeTagline => 'ジェム1,000個 (+25%ボーナス)';

  @override
  String get productGemsHugeName => 'ジェムの金庫';

  @override
  String get productGemsHugeTagline => 'ジェム2,200個 (+37%ボーナス)';

  @override
  String get hintLevel1 => 'どこでも長押しで光るリングをつかもう。はなすと飛ぶよ！';

  @override
  String get hintLevel2 => '振り上がるときにはなすと遠くまで飛べる。';

  @override
  String get hintLevel3 => '赤は痛い。トゲにさわらないで！';

  @override
  String get hintLevel5 => '上にもトゲ。高く飛びすぎないで！';

  @override
  String get hintLevel6 => '緑のパッドで上に跳ねる。大きなすき間を越えよう。';

  @override
  String get hintLevel7 => 'ノコギリは回る。ノコギリは痛い。よけてスイング。';

  @override
  String get hintLevel8 => '旗はチェックポイント。落ちてもそこから復活できる。';

  @override
  String get hintLevel9 => '動くノコギリもある。リズムを見よう。';

  @override
  String get hintLevel12 => '高く振ってはなすと上に登れる。';

  @override
  String get hintLevel14 => '上がったものは…だいたい落ちてくる。';

  @override
  String get hintLevel15 => '全部まとめて。がんばって！';

  @override
  String get hintLevel21 => '動くリングもある。タイミングよくつかもう！';

  @override
  String get hintLevel41 => 'ガラスは速くぶつかれば割れる。突き破れ！';

  @override
  String get hintLevel61 => '扇風機で上に吹き飛ばされる。風に乗れ！';

  @override
  String get hintLevel64 => '紫のゾーンは重力が逆さま。上が新しい下。';

  @override
  String get hintLevel81 => '崩れる足場は着地してすぐ落ちる。止まらないで！';

  @override
  String get hintLevel84 => 'ロケットでは死なない…でもトゲではやられる。';
}
