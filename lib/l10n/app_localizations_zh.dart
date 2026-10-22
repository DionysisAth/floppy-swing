// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get back => '返回';

  @override
  String get cancel => '取消';

  @override
  String get settings => '设置';

  @override
  String get leaderboards => '排行榜';

  @override
  String get leaderboard => '排行榜';

  @override
  String get achievements => '成就';

  @override
  String get challengeCode => '挑战码';

  @override
  String couldNotSignIn(String service) {
    return '无法登录$service。';
  }

  @override
  String get play => '开始';

  @override
  String get endless => '无尽模式';

  @override
  String endlessBest(int distance) {
    return '最佳 $distance 米';
  }

  @override
  String get endlessPitch => '你能飞多远？';

  @override
  String get shop => '商店';

  @override
  String get shopPitch => '皮肤、绳子等';

  @override
  String get pass => '通行证';

  @override
  String passTier(int tier, int total) {
    return '等级 $tier/$total';
  }

  @override
  String get daily => '每日挑战';

  @override
  String dailyDone(int streak) {
    return '完成！🔥 $streak';
  }

  @override
  String dailyKeepStreak(int streak) {
    return '保持 🔥 $streak';
  }

  @override
  String get dailyNew => '新挑战！';

  @override
  String get challengeCodeHint => '好友分享的挑战码或链接';

  @override
  String get playEndless => '玩无尽模式';

  @override
  String get settingsTitle => '设置';

  @override
  String get music => '音乐';

  @override
  String get soundEffects => '音效';

  @override
  String get muteAll => '全部静音';

  @override
  String get vibration => '振动';

  @override
  String get dailyReminders => '每日挑战提醒';

  @override
  String get language => '语言';

  @override
  String get languageAuto => '手机语言';

  @override
  String get privacyOptions => '隐私选项';

  @override
  String get resetProgress => '重置进度';

  @override
  String get fonts => '字体';

  @override
  String gamesNotSetUp(String service) {
    return '排行榜、成就和云存档由$service提供。此版本尚未设置。';
  }

  @override
  String gamesSignedIn(String service) {
    return '已登录。进度会备份到你的$service账号。';
  }

  @override
  String gamesSignedInAs(String name, String service) {
    return '已登录为$name。进度会备份到你的$service账号。';
  }

  @override
  String get gamesSignInPitch => '登录即可备份进度并参与排行榜。';

  @override
  String get signIn => '登录';

  @override
  String get resetTitle => '重置进度？';

  @override
  String get resetBody => '你的星星、金币和皮肤将被清除，且无法恢复。';

  @override
  String get reset => '重置';

  @override
  String clipFailed(String error) {
    return '无法生成视频片段：$error';
  }

  @override
  String challengeShare(int distance, String link, String code) {
    return '我在 Floppy Swing 无尽模式里荡了 $distance 米。你能超过我吗？$link\n（也可以在菜单里点“挑战码”，输入 $code。）';
  }

  @override
  String get hintRevived => '复活了！按住即可摆荡。';

  @override
  String get hintHold => '按住屏幕任意处开始摆荡！';

  @override
  String get failSpikes1 => '尖的那头先着地。';

  @override
  String get failSpikes2 => '这下要留印子了。';

  @override
  String get failSpikes3 => '尖刺 1 : 0 你';

  @override
  String get failSaw1 => '切成片了！';

  @override
  String get failSaw2 => '没看到锯子吗？';

  @override
  String get failSaw3 => '嗡嗡嗡！';

  @override
  String get failPit1 => '重力又赢了。';

  @override
  String get failPit2 => '掉下去喽！';

  @override
  String get failPit3 => '地板扎人。';

  @override
  String get failStuck1 => '午睡时间？';

  @override
  String get failStuck2 => '粘得像胶水。';

  @override
  String get failStuck3 => '歇口气？';

  @override
  String get tapToRetry => '点击任意处重试';

  @override
  String get shareFail => '分享失误';

  @override
  String get challengeFriend => '挑战好友';

  @override
  String get newCourse => '新赛道';

  @override
  String get skipLevel => '跳过关卡';

  @override
  String get revive => '复活';

  @override
  String rankWorldwide(int rank) {
    return '全球第 $rank 名';
  }

  @override
  String get newBest => '新纪录！';

  @override
  String meters(int distance) {
    return '$distance 米';
  }

  @override
  String endlessScore(int score, int best) {
    return '得分 $score  ·  最佳 $best';
  }

  @override
  String get newBestToday => '今日最佳用时！';

  @override
  String rankToday(int rank) {
    return '今日第 $rank 名';
  }

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 连续 $count 天',
    );
    return '$_temp0';
  }

  @override
  String dayStreakBonus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 连续 $count 天 - 额外宝石！',
    );
    return '$_temp0';
  }

  @override
  String get dailyClear => '每日挑战完成！';

  @override
  String get worldClear => '世界通关！';

  @override
  String get levelClear => '关卡完成！';

  @override
  String get statTime => '用时';

  @override
  String statTarget(String time) {
    return '目标 $time秒';
  }

  @override
  String get statCoins => '金币';

  @override
  String get statStyle => '花式';

  @override
  String get statBest => '最佳';

  @override
  String get starFinish => '到达终点';

  @override
  String newStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '（+$count 颗星）',
    );
    return '$_temp0';
  }

  @override
  String worldGate(int count, String world) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '再收集 $count 颗星即可开启$world！',
    );
    return '$_temp0';
  }

  @override
  String get doubleCoins => '金币翻倍';

  @override
  String get retry => '重试';

  @override
  String get share => '分享';

  @override
  String get next => '下一关';

  @override
  String get done => '完成';

  @override
  String get levels => '关卡';

  @override
  String get quit => '退出';

  @override
  String get paused => '已暂停';

  @override
  String get resume => '继续';

  @override
  String get restart => '重新开始';

  @override
  String get pause => '暂停';

  @override
  String zoneBanner(int number, String name) {
    return '区域 $number：$name';
  }

  @override
  String hudDaily(String name) {
    return '每日：$name';
  }

  @override
  String hudStyle(int score) {
    return '花式 $score';
  }

  @override
  String get slowMoReplay => '慢动作回放';

  @override
  String get makingClip => '正在生成视频片段…';

  @override
  String worldNumber(int number) {
    return '世界 $number';
  }

  @override
  String get previousWorld => '上一个世界';

  @override
  String get nextWorld => '下一个世界';

  @override
  String collectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '还需收集 $count 颗',
    );
    return '$_temp0';
  }

  @override
  String starsOf(int have, int need) {
    return '$have/$need 颗星';
  }

  @override
  String levelTile(int number, String name) {
    return '第 $number 关，$name';
  }

  @override
  String levelTileLocked(int number, String name) {
    return '第 $number 关，$name，未解锁';
  }

  @override
  String get dailyBonus => '每日奖励';

  @override
  String get dailyBonusPitch => '每天回来，奖励越来越多！';

  @override
  String get claim => '领取';

  @override
  String dayNumber(int day) {
    return '第 $day 天';
  }

  @override
  String get seasonPassTitle => '赛季通行证';

  @override
  String get seasonPass => '赛季通行证';

  @override
  String tierNumber(int tier) {
    return '等级 $tier';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '剩余 $count 天',
    );
    return '$_temp0';
  }

  @override
  String get seasonComplete => '赛季完成！';

  @override
  String seasonXp(int xp, int perTier) {
    return '$xp / $perTier 经验  ·  完成关卡、每日挑战和无尽模式即可获得经验';
  }

  @override
  String get unlockPremium => '解锁高级版';

  @override
  String get or => '或';

  @override
  String get trackFree => '免费';

  @override
  String get trackPremium => '高级';

  @override
  String get tabSkins => '皮肤';

  @override
  String get tabRopes => '绳子';

  @override
  String get tabTrails => '拖尾';

  @override
  String get tabFails => '失误特效';

  @override
  String get tabDances => '舞蹈';

  @override
  String get tabSets => '套装';

  @override
  String get tabGems => '宝石';

  @override
  String get equipped => '已装备';

  @override
  String get use => '使用';

  @override
  String get storeUnavailable => '暂时无法连接商店。请检查网络后稍后再试。';

  @override
  String get restorePurchases => '恢复购买';

  @override
  String get bestValue => '最超值';

  @override
  String plusItem(String item) {
    return '+ $item';
  }

  @override
  String purchaseThanks(String product) {
    return '谢谢！已解锁$product。';
  }

  @override
  String get storeBusy => '商店繁忙，请重试。';

  @override
  String get purchasesRestored => '已恢复购买。';

  @override
  String get storeUnreachable => '无法连接商店。';

  @override
  String get purchaseFailed => '购买失败，未扣费。';

  @override
  String reminderStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '保持你的 $count 天连胜！',
    );
    return '$_temp0';
  }

  @override
  String get reminderStreakBody => '午夜前完成今天的每日挑战。';

  @override
  String get reminderTodayTitle => '今天的每日挑战在等你';

  @override
  String get reminderTodayBody => '每天一个新关卡。快去拿星星吧！';

  @override
  String get reminderFreshTitle => '新的每日挑战来了';

  @override
  String get reminderFreshBody => '新关卡，新幽灵等你打败。你能拿到全部 3 颗星吗？';

  @override
  String get reminderRestlessTitle => 'Floppy 坐不住了';

  @override
  String get reminderRestlessBody => '今天的每日挑战可不会自己荡过去。';

  @override
  String get reminderTimeTitle => '每日挑战时间到！';

  @override
  String get reminderTimeBody => '来荡一下？完成它就能保持连胜。';

  @override
  String get reminderChannelDescription => '新的每日挑战上线时提醒你。';

  @override
  String get shareTagline => '你能做得更好吗？';

  @override
  String get shareCta => 'Floppy Swing - iOS 和 Android 免费下载';

  @override
  String clipCleared(int level) {
    return '第 $level 关完成！';
  }

  @override
  String clipTime(int level, String time) {
    return '第 $level 关用时 $time秒';
  }

  @override
  String clipSaw(int level) {
    return '在第 $level 关撞上了锯子';
  }

  @override
  String clipSpikes(int level) {
    return '在第 $level 关找到了尖刺';
  }

  @override
  String clipPit(int level) {
    return '在第 $level 关全部落空';
  }

  @override
  String clipStuck(int level) {
    return '在第 $level 关睡着了';
  }

  @override
  String clipLevel(int level) {
    return '第 $level 关';
  }

  @override
  String get wordBest => '最佳';

  @override
  String get wordCheckpoint => '检查点！';

  @override
  String get wordGo => '出发！';

  @override
  String get wordSmash => '哗啦！';

  @override
  String get wordKaboom => '轰隆！';

  @override
  String get wordBonk => '咚！';

  @override
  String get wordSaw => '嗡——！';

  @override
  String get wordSpikes => '哎哟！';

  @override
  String get wordPit => '啊啊啊！';

  @override
  String get wordStuck => 'ZZZ...';

  @override
  String get wordConfetti => '耶！';

  @override
  String get wordJackpot => '大奖！';

  @override
  String get wordSqueak => '吱！';

  @override
  String get styleBigSwing => '大回环';

  @override
  String get styleSmash => '破窗';

  @override
  String get styleFlip => '空翻';

  @override
  String get styleHangTime => '滞空';

  @override
  String get styleCloseCall => '惊险擦过';

  @override
  String get world1Name => '游乐场';

  @override
  String get world1Tagline => '按住。摆荡。松手。尖叫。';

  @override
  String get world2Name => '工厂';

  @override
  String get world2Tagline => '轨道上的圆环和饥饿的锯子。';

  @override
  String get world3Name => '玻璃城';

  @override
  String get world3Tagline => '撞穿过去。弹开。';

  @override
  String get world4Name => '天空群岛';

  @override
  String get world4Tagline => '乘风而行。向上坠落。';

  @override
  String get world5Name => '火箭基地';

  @override
  String get world5Tagline => '地板崩塌。火箭横飞。';

  @override
  String get skinFloppyName => '软趴趴';

  @override
  String get skinFloppyTagline => '最初的面条人。';

  @override
  String get skinBananaName => '香蕉';

  @override
  String get skinBananaTagline => '摆荡时很滑。';

  @override
  String get skinKnightName => '趴趴爵士';

  @override
  String get skinKnightTagline => '盔甲很重。毫无优雅。';

  @override
  String get skinAstronautName => '太空学员';

  @override
  String get skinAstronautTagline => '重力只是个建议。';

  @override
  String get skinChickenName => '橡皮鸡';

  @override
  String get skinChickenTagline => '一撞就叫。那当然。';

  @override
  String get skinNinjaName => '面条忍者';

  @override
  String get skinNinjaTagline => '无声。致命。大多数时候无声。';

  @override
  String get skinPirateName => '趴趴船长';

  @override
  String get skinPirateTagline => '哟吼，哦不。';

  @override
  String get skinRobotName => '机器面条';

  @override
  String get skinRobotTagline => '哔。啵。咚。';

  @override
  String get skinDinoName => '恐龙炸弹';

  @override
  String get skinDinoTagline => '小短手。大摆荡。';

  @override
  String get skinWizardName => '趴道夫';

  @override
  String get skinWizardTagline => '你不能过去……哎呀。';

  @override
  String get skinGoldenName => '黄金趴趴';

  @override
  String get skinGoldenTagline => '收集全部 300 颗星。';

  @override
  String get itemRopeName => '靠谱麻绳';

  @override
  String get itemRopeTagline => '麻质。可靠。米色。';

  @override
  String get itemChainName => '铁链';

  @override
  String get itemChainTagline => '叮当叮当叮当。';

  @override
  String get itemSpaghettiName => '意大利面';

  @override
  String get itemSpaghettiTagline => '有嚼劲。大概吧。';

  @override
  String get itemRainbowName => '彩虹';

  @override
  String get itemRainbowTagline => '彩色摆荡。';

  @override
  String get itemLaserName => '激光';

  @override
  String get itemLaserTagline => '咻咻抓钩。';

  @override
  String get itemSwooshName => '嗖嗖';

  @override
  String get itemSwooshTagline => '经典的嗖一声。';

  @override
  String get itemSparklesName => '闪闪';

  @override
  String get itemSparklesTagline => '任何速度都闪亮。';

  @override
  String get itemBubblesName => '泡泡';

  @override
  String get itemBubblesTagline => '咕噜咕噜。';

  @override
  String get itemFireName => '火焰';

  @override
  String get itemFireTagline => '烫手！';

  @override
  String get itemGoldName => '金币雨';

  @override
  String get itemGoldTagline => '海盗宝藏赛季。';

  @override
  String get itemCircuitName => '电路';

  @override
  String get itemCircuitTagline => '机器人大乱斗赛季。';

  @override
  String get itemLeavesName => '丛林树叶';

  @override
  String get itemLeavesTagline => '恐龙时光赛季。';

  @override
  String get itemStarsName => '星尘';

  @override
  String get itemStarsTagline => '巫师周赛季。';

  @override
  String get itemClassicName => '砰';

  @override
  String get itemClassicTagline => '星星。好多星星。';

  @override
  String get itemSqueakyName => '吱吱玩具';

  @override
  String get itemSqueakyTagline => '吱——————。';

  @override
  String get itemConfettiName => '彩纸派对';

  @override
  String get itemConfettiTagline => '失败也值得庆祝。';

  @override
  String get itemCoinpileName => '大奖';

  @override
  String get itemCoinpileTagline => '炸成一堆金币。';

  @override
  String get itemHopName => '开心跳跳';

  @override
  String get itemHopTagline => '蹦蹦蹦。';

  @override
  String get itemBackflipName => '后空翻';

  @override
  String get itemBackflipTagline => '完美落地。偶尔。';

  @override
  String get itemSpinName => '龙卷风';

  @override
  String get itemSpinTagline => '呜呼——！';

  @override
  String get itemFlailName => '疯狂乱舞';

  @override
  String get itemFlailTagline => '充气人偶的气场。';

  @override
  String get setFoodName => '食物大战';

  @override
  String get setHeroesName => '勇敢英雄';

  @override
  String get setRopesName => '绳子收藏家';

  @override
  String get setTrailsName => '开路先锋';

  @override
  String get setFailsName => '史诗失误';

  @override
  String get setDancesName => '舞池';

  @override
  String get seasonPirateName => '海盗宝藏';

  @override
  String get seasonRobotName => '机器人大乱斗';

  @override
  String get seasonDinoName => '恐龙时光';

  @override
  String get seasonWizardName => '巫师周';

  @override
  String get productStarterPackName => '新手礼包';

  @override
  String get productStarterPackTagline => '300 宝石、2,500 金币和激光绳。限购一次！';

  @override
  String get productRemoveAdsName => '去除广告';

  @override
  String get productRemoveAdsTagline => '关卡之间不再有广告。奖励视频仍可自选。';

  @override
  String get productSeasonPassName => '高级通行证';

  @override
  String get productSeasonPassTagline => '本赛季的高级奖励线。';

  @override
  String get productGemsSmallName => '一把宝石';

  @override
  String get productGemsSmallTagline => '80 宝石';

  @override
  String get productGemsMediumName => '一袋宝石';

  @override
  String get productGemsMediumTagline => '450 宝石（+12% 赠送）';

  @override
  String get productGemsLargeName => '一箱宝石';

  @override
  String get productGemsLargeTagline => '1,000 宝石（+25% 赠送）';

  @override
  String get productGemsHugeName => '宝石金库';

  @override
  String get productGemsHugeTagline => '2,200 宝石（+37% 赠送）';

  @override
  String get hintLevel1 => '按住任意处抓住发光的圆环。松手就能飞出去！';

  @override
  String get hintLevel2 => '在向上摆时松手，能飞得更远。';

  @override
  String get hintLevel3 => '红色代表疼。别碰尖刺！';

  @override
  String get hintLevel5 => '上面也有尖刺。别飞太高！';

  @override
  String get hintLevel6 => '绿色弹垫会把你弹上去。用它们跨越大缺口。';

  @override
  String get hintLevel7 => '锯子会转。锯子会疼。绕开它们摆荡。';

  @override
  String get hintLevel8 => '旗子是检查点。掉下去会在那里复活。';

  @override
  String get hintLevel9 => '有些锯子会移动。注意节奏。';

  @override
  String get hintLevel12 => '荡高一点再松手，就能往上爬。';

  @override
  String get hintLevel14 => '上去的……多半会掉下来。';

  @override
  String get hintLevel15 => '全部一起来。祝你好运！';

  @override
  String get hintLevel21 => '有些圆环会移动。看准时机抓住！';

  @override
  String get hintLevel41 => '撞得够快玻璃就会碎。冲过去！';

  @override
  String get hintLevel61 => '风扇会把你往上吹。乘风而行！';

  @override
  String get hintLevel64 => '紫色区域会翻转重力。上就是新的下。';

  @override
  String get hintLevel81 => '易碎平台在你落地后很快就会掉落。别停下！';

  @override
  String get hintLevel84 => '火箭不会要你的命……但尖刺会。';
}
