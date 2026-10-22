// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get back => '뒤로';

  @override
  String get cancel => '취소';

  @override
  String get settings => '설정';

  @override
  String get leaderboards => '리더보드';

  @override
  String get leaderboard => '리더보드';

  @override
  String get achievements => '업적';

  @override
  String get challengeCode => '도전 코드';

  @override
  String couldNotSignIn(String service) {
    return '$service에 로그인하지 못했어요.';
  }

  @override
  String get play => '플레이';

  @override
  String get endless => '무한 모드';

  @override
  String endlessBest(int distance) {
    return '최고 $distance m';
  }

  @override
  String get endlessPitch => '얼마나 멀리 갈 수 있을까?';

  @override
  String get shop => '상점';

  @override
  String get shopPitch => '스킨, 로프 등';

  @override
  String get pass => '패스';

  @override
  String passTier(int tier, int total) {
    return '티어 $tier/$total';
  }

  @override
  String get daily => '일일 도전';

  @override
  String dailyDone(int streak) {
    return '완료! 🔥 $streak';
  }

  @override
  String dailyKeepStreak(int streak) {
    return '🔥 $streak 이어가기';
  }

  @override
  String get dailyNew => '새 도전!';

  @override
  String get challengeCodeHint => '친구가 보낸 코드나 링크';

  @override
  String get playEndless => '무한 모드 플레이';

  @override
  String get settingsTitle => '설정';

  @override
  String get music => '음악';

  @override
  String get soundEffects => '효과음';

  @override
  String get muteAll => '모두 음소거';

  @override
  String get vibration => '진동';

  @override
  String get dailyReminders => '일일 도전 알림';

  @override
  String get language => '언어';

  @override
  String get languageAuto => '휴대폰 언어';

  @override
  String get privacyOptions => '개인정보 옵션';

  @override
  String get resetProgress => '진행 상황 초기화';

  @override
  String get fonts => '글꼴';

  @override
  String gamesNotSetUp(String service) {
    return '리더보드, 업적, 클라우드 저장은 $service와 함께 제공돼요. 이 버전에서는 아직 설정되지 않았어요.';
  }

  @override
  String gamesSignedIn(String service) {
    return '로그인됨. 진행 상황이 $service 계정에 백업돼요.';
  }

  @override
  String gamesSignedInAs(String name, String service) {
    return '$name(으)로 로그인됨. 진행 상황이 $service 계정에 백업돼요.';
  }

  @override
  String get gamesSignInPitch => '로그인하면 진행 상황을 백업하고 리더보드에 참여할 수 있어요.';

  @override
  String get signIn => '로그인';

  @override
  String get resetTitle => '진행 상황을 초기화할까요?';

  @override
  String get resetBody => '별, 코인, 스킨이 모두 지워져요. 되돌릴 수 없어요.';

  @override
  String get reset => '초기화';

  @override
  String clipFailed(String error) {
    return '클립을 만들지 못했어요: $error';
  }

  @override
  String challengeShare(int distance, String link, String code) {
    return 'Floppy Swing 무한 모드에서 $distance m 날아갔어! 이길 수 있어? $link\n(메뉴에서 \"도전 코드\"를 누르고 $code를 입력해도 돼.)';
  }

  @override
  String get hintRevived => '부활! 길게 눌러 스윙하세요.';

  @override
  String get hintHold => '아무 곳이나 길게 눌러 스윙!';

  @override
  String get failSpikes1 => '뾰족한 쪽부터.';

  @override
  String get failSpikes2 => '멍 좀 들겠는데.';

  @override
  String get failSpikes3 => '가시: 1, 나: 0';

  @override
  String get failSaw1 => '송송 썰렸다!';

  @override
  String get failSaw2 => '톱날 못 봤어?';

  @override
  String get failSaw3 => '위이잉!';

  @override
  String get failPit1 => '이번에도 중력 승.';

  @override
  String get failPit2 => '아래로 슝!';

  @override
  String get failPit3 => '바닥이 따가워.';

  @override
  String get failStuck1 => '낮잠 시간?';

  @override
  String get failStuck2 => '풀처럼 딱 붙었네.';

  @override
  String get failStuck3 => '잠깐 숨 고르는 중?';

  @override
  String get tapToRetry => '아무 곳이나 탭해서 다시 하기';

  @override
  String get shareFail => '실패 공유';

  @override
  String get challengeFriend => '친구에게 도전';

  @override
  String get newCourse => '새 코스';

  @override
  String get skipLevel => '레벨 건너뛰기';

  @override
  String get revive => '부활';

  @override
  String rankWorldwide(int rank) {
    return '세계 #$rank';
  }

  @override
  String get newBest => '신기록!';

  @override
  String meters(int distance) {
    return '$distance m';
  }

  @override
  String endlessScore(int score, int best) {
    return '점수 $score  ·  최고 $best';
  }

  @override
  String get newBestToday => '오늘의 최고 기록 경신!';

  @override
  String rankToday(int rank) {
    return '오늘 #$rank';
  }

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count일 연속',
    );
    return '$_temp0';
  }

  @override
  String dayStreakBonus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count일 연속 - 보너스 보석!',
    );
    return '$_temp0';
  }

  @override
  String get dailyClear => '일일 도전 클리어!';

  @override
  String get worldClear => '월드 클리어!';

  @override
  String get levelClear => '레벨 클리어!';

  @override
  String get statTime => '시간';

  @override
  String statTarget(String time) {
    return '목표 $time초';
  }

  @override
  String get statCoins => '코인';

  @override
  String get statStyle => '스타일';

  @override
  String get statBest => '최고';

  @override
  String get starFinish => '완주';

  @override
  String newStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '(+별 $count개)',
    );
    return '$_temp0';
  }

  @override
  String worldGate(int count, String world) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '별을 $count개 더 모으면 $world이(가) 열려요!',
    );
    return '$_temp0';
  }

  @override
  String get doubleCoins => '코인 2배';

  @override
  String get retry => '다시 하기';

  @override
  String get share => '공유';

  @override
  String get next => '다음';

  @override
  String get done => '완료';

  @override
  String get levels => '레벨';

  @override
  String get quit => '나가기';

  @override
  String get paused => '일시 정지';

  @override
  String get resume => '계속하기';

  @override
  String get restart => '처음부터';

  @override
  String get pause => '일시 정지';

  @override
  String zoneBanner(int number, String name) {
    return '구역 $number: $name';
  }

  @override
  String hudDaily(String name) {
    return '일일 도전: $name';
  }

  @override
  String hudStyle(int score) {
    return '스타일 $score';
  }

  @override
  String get slowMoReplay => '슬로모션 리플레이';

  @override
  String get makingClip => '클립 만드는 중…';

  @override
  String worldNumber(int number) {
    return '월드 $number';
  }

  @override
  String get previousWorld => '이전 월드';

  @override
  String get nextWorld => '다음 월드';

  @override
  String collectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 더 모으기',
    );
    return '$_temp0';
  }

  @override
  String starsOf(int have, int need) {
    return '별 $have/$need';
  }

  @override
  String levelTile(int number, String name) {
    return '레벨 $number, $name';
  }

  @override
  String levelTileLocked(int number, String name) {
    return '레벨 $number, $name, 잠김';
  }

  @override
  String get dailyBonus => '출석 보상';

  @override
  String get dailyBonusPitch => '매일 오면 보상이 점점 커져요!';

  @override
  String get claim => '받기';

  @override
  String dayNumber(int day) {
    return '$day일차';
  }

  @override
  String get seasonPassTitle => '시즌 패스';

  @override
  String get seasonPass => '시즌 패스';

  @override
  String tierNumber(int tier) {
    return '티어 $tier';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count일 남음',
    );
    return '$_temp0';
  }

  @override
  String get seasonComplete => '시즌 완료!';

  @override
  String seasonXp(int xp, int perTier) {
    return '$xp / $perTier XP  ·  레벨, 일일 도전, 무한 모드를 완료해 XP를 모으세요';
  }

  @override
  String get unlockPremium => '프리미엄 잠금 해제';

  @override
  String get or => '또는';

  @override
  String get trackFree => '무료';

  @override
  String get trackPremium => '프리미엄';

  @override
  String get tabSkins => '스킨';

  @override
  String get tabRopes => '로프';

  @override
  String get tabTrails => '궤적';

  @override
  String get tabFails => '실패 효과';

  @override
  String get tabDances => '춤';

  @override
  String get tabSets => '세트';

  @override
  String get tabGems => '보석';

  @override
  String get equipped => '장착됨';

  @override
  String get use => '사용';

  @override
  String get storeUnavailable => '지금은 상점에 연결할 수 없어요. 연결을 확인하고 나중에 다시 시도해 주세요.';

  @override
  String get restorePurchases => '구매 복원';

  @override
  String get bestValue => '최고 가성비';

  @override
  String plusItem(String item) {
    return '+ $item';
  }

  @override
  String purchaseThanks(String product) {
    return '고마워요! $product 잠금 해제.';
  }

  @override
  String get storeBusy => '상점이 혼잡해요. 다시 시도해 주세요.';

  @override
  String get purchasesRestored => '구매를 복원했어요.';

  @override
  String get storeUnreachable => '상점에 연결하지 못했어요.';

  @override
  String get purchaseFailed => '구매에 실패했어요. 요금은 청구되지 않았어요.';

  @override
  String reminderStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count일 연속 기록을 이어가세요!',
    );
    return '$_temp0';
  }

  @override
  String get reminderStreakBody => '자정 전에 오늘의 일일 도전을 클리어하세요.';

  @override
  String get reminderTodayTitle => '오늘의 일일 도전이 기다리고 있어요';

  @override
  String get reminderTodayBody => '매일 새로운 레벨. 별을 모으러 가요!';

  @override
  String get reminderFreshTitle => '새 일일 도전이 도착했어요';

  @override
  String get reminderFreshBody => '새 레벨, 새 고스트와 대결! 별 3개 모두 받을 수 있을까요?';

  @override
  String get reminderRestlessTitle => 'Floppy가 몸이 근질근질해요';

  @override
  String get reminderRestlessBody => '오늘의 일일 도전은 저절로 스윙하지 않아요.';

  @override
  String get reminderTimeTitle => '일일 도전 시간!';

  @override
  String get reminderTimeBody => '잠깐 스윙할래요? 클리어하고 연속 기록을 이어가세요.';

  @override
  String get reminderChannelDescription => '새 일일 도전이 나오면 알려 드려요.';

  @override
  String get shareTagline => '더 잘할 수 있어?';

  @override
  String get shareCta => 'Floppy Swing - iOS & Android에서 무료';

  @override
  String clipCleared(int level) {
    return '레벨 $level 클리어!';
  }

  @override
  String clipTime(int level, String time) {
    return '레벨 $level을(를) $time초에';
  }

  @override
  String clipSaw(int level) {
    return '레벨 $level에서 톱날을 만났어';
  }

  @override
  String clipSpikes(int level) {
    return '레벨 $level에서 가시를 찾았어';
  }

  @override
  String clipPit(int level) {
    return '레벨 $level에서 다 놓쳤어';
  }

  @override
  String clipStuck(int level) {
    return '레벨 $level에서 낮잠 잤어';
  }

  @override
  String clipLevel(int level) {
    return '레벨 $level';
  }

  @override
  String get wordBest => '최고';

  @override
  String get wordCheckpoint => '체크포인트!';

  @override
  String get wordGo => '출발!';

  @override
  String get wordSmash => '와장창!';

  @override
  String get wordKaboom => '콰광!';

  @override
  String get wordBonk => '쿵!';

  @override
  String get wordSaw => '위이잉!';

  @override
  String get wordSpikes => '아야!';

  @override
  String get wordPit => '으악!';

  @override
  String get wordStuck => 'ZZZ...';

  @override
  String get wordConfetti => '야호!';

  @override
  String get wordJackpot => '잭팟!';

  @override
  String get wordSqueak => '삑!';

  @override
  String get styleBigSwing => '대회전';

  @override
  String get styleSmash => '유리 깨기';

  @override
  String get styleFlip => '공중제비';

  @override
  String get styleHangTime => '체공';

  @override
  String get styleCloseCall => '아슬아슬';

  @override
  String get world1Name => '놀이터';

  @override
  String get world1Tagline => '잡고. 흔들고. 놓고. 소리 질러.';

  @override
  String get world2Name => '공장';

  @override
  String get world2Tagline => '레일 위의 링과 배고픈 톱날.';

  @override
  String get world3Name => '유리 도시';

  @override
  String get world3Tagline => '뚫고 지나가. 튕겨 나와.';

  @override
  String get world4Name => '하늘 섬';

  @override
  String get world4Tagline => '바람을 타. 위로 떨어져.';

  @override
  String get world5Name => '로켓 기지';

  @override
  String get world5Tagline => '바닥은 무너지고 로켓은 날아.';

  @override
  String get skinFloppyName => '플로피';

  @override
  String get skinFloppyTagline => '원조 흐물이.';

  @override
  String get skinBananaName => '바나나';

  @override
  String get skinBananaTagline => '스윙할 때 미끌.';

  @override
  String get skinKnightName => '플롭스 경';

  @override
  String get skinKnightTagline => '무거운 갑옷. 우아함 제로.';

  @override
  String get skinAstronautName => '우주 생도';

  @override
  String get skinAstronautTagline => '중력은 그냥 제안일 뿐.';

  @override
  String get skinChickenName => '고무 치킨';

  @override
  String get skinChickenTagline => '부딪히면 삑. 당연하지.';

  @override
  String get skinNinjaName => '국수 닌자';

  @override
  String get skinNinjaTagline => '조용하고. 치명적이고. 대체로 조용함.';

  @override
  String get skinPirateName => '플롭 선장';

  @override
  String get skinPirateTagline => '요호, 오 노.';

  @override
  String get skinRobotName => '로보 국수';

  @override
  String get skinRobotTagline => '삐. 뽀. 쿵.';

  @override
  String get skinDinoName => '다이노마이트';

  @override
  String get skinDinoTagline => '짧은 팔. 큰 스윙.';

  @override
  String get skinWizardName => '플롭달프';

  @override
  String get skinWizardTagline => '너는 지나갈 수 없다... 앗.';

  @override
  String get skinGoldenName => '황금 플롭';

  @override
  String get skinGoldenTagline => '별 300개를 모두 모으세요.';

  @override
  String get itemRopeName => '믿음직한 로프';

  @override
  String get itemRopeTagline => '삼베. 튼튼. 베이지.';

  @override
  String get itemChainName => '쇠사슬';

  @override
  String get itemChainTagline => '철컹 철컹 철컹.';

  @override
  String get itemSpaghettiName => '스파게티';

  @override
  String get itemSpaghettiTagline => '알 덴테. 아마도.';

  @override
  String get itemRainbowName => '무지개';

  @override
  String get itemRainbowTagline => '무지갯빛 스윙.';

  @override
  String get itemLaserName => '레이저';

  @override
  String get itemLaserTagline => '퓽퓽 갈고리.';

  @override
  String get itemSwooshName => '휙';

  @override
  String get itemSwooshTagline => '클래식한 휙.';

  @override
  String get itemSparklesName => '반짝이';

  @override
  String get itemSparklesTagline => '어떤 속도에서도 화려하게.';

  @override
  String get itemBubblesName => '비눗방울';

  @override
  String get itemBubblesTagline => '보글보글.';

  @override
  String get itemFireName => '불꽃';

  @override
  String get itemFireTagline => '너무 뜨거워!';

  @override
  String get itemGoldName => '금화';

  @override
  String get itemGoldTagline => '해적의 보물 시즌.';

  @override
  String get itemCircuitName => '회로';

  @override
  String get itemCircuitTagline => '로보 대소동 시즌.';

  @override
  String get itemLeavesName => '정글 잎사귀';

  @override
  String get itemLeavesTagline => '공룡의 날들 시즌.';

  @override
  String get itemStarsName => '별가루';

  @override
  String get itemStarsTagline => '마법사 주간 시즌.';

  @override
  String get itemClassicName => '콰광';

  @override
  String get itemClassicTagline => '별. 별이 잔뜩.';

  @override
  String get itemSqueakyName => '삑삑이 장난감';

  @override
  String get itemSqueakyTagline => '삐이이이익.';

  @override
  String get itemConfettiName => '꽃가루 파티';

  @override
  String get itemConfettiTagline => '실패는 축하할 일.';

  @override
  String get itemCoinpileName => '잭팟';

  @override
  String get itemCoinpileTagline => '코인 더미로 펑!';

  @override
  String get itemHopName => '행복한 깡총';

  @override
  String get itemHopTagline => '보잉 보잉 보잉.';

  @override
  String get itemBackflipName => '백플립';

  @override
  String get itemBackflipTagline => '착지 완벽. 가끔은.';

  @override
  String get itemSpinName => '토네이도';

  @override
  String get itemSpinTagline => '우와아아아!';

  @override
  String get itemFlailName => '허우적 댄스';

  @override
  String get itemFlailTagline => '풍선 인형 에너지.';

  @override
  String get setFoodName => '음식 대전';

  @override
  String get setHeroesName => '용감한 영웅들';

  @override
  String get setRopesName => '로프 수집가';

  @override
  String get setTrailsName => '궤적 개척자';

  @override
  String get setFailsName => '전설의 실패';

  @override
  String get setDancesName => '댄스 플로어';

  @override
  String get seasonPirateName => '해적의 보물';

  @override
  String get seasonRobotName => '로보 대소동';

  @override
  String get seasonDinoName => '공룡의 날들';

  @override
  String get seasonWizardName => '마법사 주간';

  @override
  String get productStarterPackName => '스타터 팩';

  @override
  String get productStarterPackTagline => '보석 300개, 코인 2,500개, 레이저 로프. 단 한 번!';

  @override
  String get productRemoveAdsName => '광고 제거';

  @override
  String get productRemoveAdsTagline => '레벨 사이 광고가 사라져요. 보너스 영상은 계속 선택 사항이에요.';

  @override
  String get productSeasonPassName => '프리미엄 패스';

  @override
  String get productSeasonPassTagline => '이번 시즌의 프리미엄 트랙.';

  @override
  String get productGemsSmallName => '보석 한 줌';

  @override
  String get productGemsSmallTagline => '보석 80개';

  @override
  String get productGemsMediumName => '보석 주머니';

  @override
  String get productGemsMediumTagline => '보석 450개 (+12% 보너스)';

  @override
  String get productGemsLargeName => '보석 상자';

  @override
  String get productGemsLargeTagline => '보석 1,000개 (+25% 보너스)';

  @override
  String get productGemsHugeName => '보석 금고';

  @override
  String get productGemsHugeTagline => '보석 2,200개 (+37% 보너스)';

  @override
  String get hintLevel1 => '아무 곳이나 길게 눌러 빛나는 링을 잡으세요. 손을 떼면 날아가요!';

  @override
  String get hintLevel2 => '위로 올라갈 때 손을 떼면 더 멀리 날아가요.';

  @override
  String get hintLevel3 => '빨간색은 아파요. 가시를 건드리지 마세요!';

  @override
  String get hintLevel5 => '위에도 가시가 있어요. 너무 높이 날지 마세요!';

  @override
  String get hintLevel6 => '초록 패드는 위로 튕겨 줘요. 큰 틈을 건널 때 쓰세요.';

  @override
  String get hintLevel7 => '톱날은 돌아요. 톱날은 아파요. 피해서 스윙하세요.';

  @override
  String get hintLevel8 => '깃발은 체크포인트예요. 떨어지면 거기서 부활해요.';

  @override
  String get hintLevel9 => '움직이는 톱날도 있어요. 리듬을 잘 보세요.';

  @override
  String get hintLevel12 => '높이 흔들다가 손을 떼면 위로 올라가요.';

  @override
  String get hintLevel14 => '올라간 건... 대개 내려와요.';

  @override
  String get hintLevel15 => '전부 한꺼번에. 행운을 빌어요!';

  @override
  String get hintLevel21 => '움직이는 링도 있어요. 타이밍 맞춰 잡으세요!';

  @override
  String get hintLevel41 => '유리는 충분히 빠르게 부딪히면 깨져요. 뚫고 지나가세요!';

  @override
  String get hintLevel61 => '선풍기가 위로 날려 줘요. 바람을 타세요!';

  @override
  String get hintLevel64 => '보라색 구역은 중력을 뒤집어요. 위가 새로운 아래예요.';

  @override
  String get hintLevel81 => '무너지는 발판은 착지하고 곧 떨어져요. 계속 움직이세요!';

  @override
  String get hintLevel84 => '로켓에 맞아도 안 죽어요... 하지만 가시는 달라요.';
}
