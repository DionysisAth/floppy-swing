import 'dart:convert';

double _d(Map<String, dynamic> m, String key, double fallback) =>
    (m[key] as num?)?.toDouble() ?? fallback;

/// Every tunable number that shapes how swinging *feels*.
///
/// Loaded from `assets/config/physics.json` so values can be tweaked without
/// touching code. Any key missing from the JSON falls back to the default here.
class PhysicsConfig {
  const PhysicsConfig({
    this.gravity = 22.0,
    this.stepsPerSecond = 60,
    this.ropeRange = 9.0,
    this.ropeMinLength = 1.6,
    this.ropeReelFactor = 0.85,
    this.ropeReelSpeed = 5.0,
    this.swingPump = 9.0,
    this.maxSwingSpeed = 15.0,
    this.releaseBoost = 1.5,
    this.releaseLift = 2.5,
    this.groundLaunchSpeed = 12.0,
    this.lowSpeedAssist = 1.8,
    this.ropeSnapKeep = 0.85,
    this.ropeSnapMaxSpeed = 18.0,
    this.ropeSlackTakeUp = 14.0,
    this.glassBreakSpeed = 7.0,
    this.crumbleDelay = 0.7,
    this.rocketKnock = 13.0,
    this.rocketHitRadius = 0.8,
    this.assistBelowSpeed = 8.0,
    this.anchorForwardBias = 0.45,
    this.anchorBelowPenalty = 0.6,
    this.bodyDensity = 1.0,
    this.limbDensity = 2.2,
    this.jointFloppiness = 0.4,
    this.restitution = 0.35,
    this.friction = 0.5,
    this.linearDamping = 0.02,
    this.hazardKnockback = 13.0,
    this.hazardSpin = 18.0,
    this.bouncePadSpeed = 19.0,
    this.impactSoundSpeed = 5.0,
    this.stuckTime = 2.0,
    this.nearMissDistance = 0.55,
    this.pickupRadius = 0.6,
    this.checkpointRadius = 1.6,
    this.killMargin = 0.3,
  });

  factory PhysicsConfig.fromJson(Map<String, dynamic> m) => PhysicsConfig(
    gravity: _d(m, 'gravity', 22.0),
    stepsPerSecond: (m['stepsPerSecond'] as num?)?.toInt() ?? 60,
    ropeRange: _d(m, 'ropeRange', 9.0),
    ropeMinLength: _d(m, 'ropeMinLength', 1.6),
    ropeReelFactor: _d(m, 'ropeReelFactor', 0.85),
    ropeReelSpeed: _d(m, 'ropeReelSpeed', 5.0),
    swingPump: _d(m, 'swingPump', 9.0),
    maxSwingSpeed: _d(m, 'maxSwingSpeed', 15.0),
    releaseBoost: _d(m, 'releaseBoost', 1.5),
    releaseLift: _d(m, 'releaseLift', 2.5),
    groundLaunchSpeed: _d(m, 'groundLaunchSpeed', 12.0),
    lowSpeedAssist: _d(m, 'lowSpeedAssist', 1.8),
    ropeSnapKeep: _d(m, 'ropeSnapKeep', 0.85),
    ropeSnapMaxSpeed: _d(m, 'ropeSnapMaxSpeed', 18.0),
    ropeSlackTakeUp: _d(m, 'ropeSlackTakeUp', 14.0),
    glassBreakSpeed: _d(m, 'glassBreakSpeed', 7.0),
    crumbleDelay: _d(m, 'crumbleDelay', 0.7),
    rocketKnock: _d(m, 'rocketKnock', 13.0),
    rocketHitRadius: _d(m, 'rocketHitRadius', 0.8),
    assistBelowSpeed: _d(m, 'assistBelowSpeed', 8.0),
    anchorForwardBias: _d(m, 'anchorForwardBias', 0.45),
    anchorBelowPenalty: _d(m, 'anchorBelowPenalty', 0.6),
    bodyDensity: _d(m, 'bodyDensity', 1.0),
    limbDensity: _d(m, 'limbDensity', 2.2),
    jointFloppiness: _d(m, 'jointFloppiness', 0.4),
    restitution: _d(m, 'restitution', 0.35),
    friction: _d(m, 'friction', 0.5),
    linearDamping: _d(m, 'linearDamping', 0.02),
    hazardKnockback: _d(m, 'hazardKnockback', 13.0),
    hazardSpin: _d(m, 'hazardSpin', 18.0),
    bouncePadSpeed: _d(m, 'bouncePadSpeed', 19.0),
    impactSoundSpeed: _d(m, 'impactSoundSpeed', 5.0),
    stuckTime: _d(m, 'stuckTime', 2.0),
    nearMissDistance: _d(m, 'nearMissDistance', 0.55),
    pickupRadius: _d(m, 'pickupRadius', 0.6),
    checkpointRadius: _d(m, 'checkpointRadius', 1.6),
    killMargin: _d(m, 'killMargin', 0.3),
  );

  factory PhysicsConfig.parse(String json) =>
      PhysicsConfig.fromJson(jsonDecode(json) as Map<String, dynamic>);

  /// Downward acceleration in m/s². Higher = snappier, heavier swings.
  final double gravity;

  /// Fixed physics rate. The simulation always steps at 1/[stepsPerSecond].
  final int stepsPerSecond;

  /// Max distance from the character to an anchor it can grab.
  final double ropeRange;

  /// Shortest the rope will ever reel in to.
  final double ropeMinLength;

  /// On grab the rope reels in to (distance × factor), giving a little yank.
  final double ropeReelFactor;

  /// How fast (m/s) the rope reels in towards its target length.
  final double ropeReelSpeed;

  /// Tangential acceleration (m/s²) added while swinging so swings build up.
  final double swingPump;

  /// The pump stops adding energy above this speed.
  final double maxSwingSpeed;

  /// Extra speed (m/s) along the velocity direction when letting go.
  final double releaseBoost;

  /// Extra upward speed (m/s) when letting go.
  final double releaseLift;

  /// Speed (m/s) the character is slung with when grabbing while standing or
  /// lying on something (the start of every level, landings, revives). It
  /// throws them straight into a full swing instead of a slow drag.
  final double groundLaunchSpeed;

  /// Extra swing pump while moving slowly: the pump is multiplied by up to
  /// (1 + [lowSpeedAssist]) at a standstill, fading out at
  /// [assistBelowSpeed]. Gets sluggish swings going without making fast
  /// ones faster.
  final double lowSpeedAssist;
  final double assistBelowSpeed;

  /// When a slack rope snaps tight, this fraction of the character's speed is
  /// kept and redirected along the swing (instead of the physics simply
  /// deleting the outward part). Grabbing from above becomes a whip, not a
  /// stall.
  final double ropeSnapKeep;

  /// Cap on the speed a rope snap can produce.
  final double ropeSnapMaxSpeed;

  /// How fast (m/s) a slack rope takes in the extra length, so the drop
  /// before it catches is short.
  final double ropeSlackTakeUp;

  /// Glass panes shatter when hit at least this fast (m/s); slower hits
  /// just bonk off.
  final double glassBreakSpeed;

  /// Seconds between first touching a crumbling platform and it falling.
  final double crumbleDelay;

  /// Speed (m/s) a rocket blast knocks the character with.
  final double rocketKnock;

  /// How close (m) a rocket must pass to a body part to hit.
  final double rocketHitRadius;

  /// How strongly anchor picking prefers anchors in the direction of travel.
  final double anchorForwardBias;

  /// How strongly anchor picking avoids anchors below the character.
  final double anchorBelowPenalty;

  /// Density of torso and head.
  final double bodyDensity;

  /// Density of arms and legs (heavier limbs keep the rope joint stable).
  final double limbDensity;

  /// Angular damping on limbs. Lower = floppier.
  final double jointFloppiness;

  final double restitution;
  final double friction;
  final double linearDamping;

  /// Speed (m/s) a hazard launches the ragdoll away with. Deliberately silly.
  final double hazardKnockback;

  /// Spin (rad/s) added to the torso when a hazard is hit.
  final double hazardSpin;

  /// Speed a bounce pad launches the character with, along the pad normal.
  final double bouncePadSpeed;

  /// Impacts faster than this (m/s) trigger a "bonk".
  final double impactSoundSpeed;

  /// Seconds of lying still (with nothing in reach) before the run fails.
  final double stuckTime;

  /// Passing this close (m) to a hazard without touching counts as a near miss.
  final double nearMissDistance;

  /// Coin pickup radius.
  final double pickupRadius;

  /// Half-width of the column above a checkpoint flag that activates it.
  final double checkpointRadius;

  /// Distance above the level's kill line that already counts as dead.
  final double killMargin;

  double get dt => 1.0 / stepsPerSecond;
}

/// Coin rewards and item prices. Loaded from `assets/config/economy.json`.
class EconomyConfig {
  const EconomyConfig({
    this.coinValue = 2,
    this.starReward = 15,
    this.levelCompleteReward = 10,
    this.reviveCost = 60,
    this.skinPrices = const {},
    this.endlessMetresPerCoin = 10,
    this.dailyCoins = 60,
    this.dailyGems = 3,
    this.dailyStreakGems = 10,
  });

  factory EconomyConfig.fromJson(Map<String, dynamic> m) => EconomyConfig(
    coinValue: (m['coinValue'] as num?)?.toInt() ?? 2,
    starReward: (m['starReward'] as num?)?.toInt() ?? 15,
    levelCompleteReward: (m['levelCompleteReward'] as num?)?.toInt() ?? 10,
    reviveCost: (m['reviveCost'] as num?)?.toInt() ?? 60,
    endlessMetresPerCoin: (m['endlessMetresPerCoin'] as num?)?.toInt() ?? 10,
    dailyCoins: (m['dailyCoins'] as num?)?.toInt() ?? 60,
    dailyGems: (m['dailyGems'] as num?)?.toInt() ?? 3,
    dailyStreakGems: (m['dailyStreakGems'] as num?)?.toInt() ?? 10,
    skinPrices: {
      for (final e
          in ((m['skinPrices'] as Map<String, dynamic>?) ?? const {}).entries)
        e.key: (e.value as num).toInt(),
    },
  );

  factory EconomyConfig.parse(String json) =>
      EconomyConfig.fromJson(jsonDecode(json) as Map<String, dynamic>);

  /// Coins earned per in-level coin picked up.
  final int coinValue;

  /// Coins earned for each star earned for the first time.
  final int starReward;

  /// Coins earned every time a level is finished.
  final int levelCompleteReward;

  /// Coin price of a checkpoint revive.
  final int reviveCost;

  /// Skin id -> coin price. Skins not listed use the price in the catalogue.
  final Map<String, int> skinPrices;

  /// Endless pays one coin per this many metres (plus picked-up coins).
  final int endlessMetresPerCoin;

  /// First Daily Challenge clear of the day pays this many coins and gems.
  final int dailyCoins;
  final int dailyGems;

  /// Extra gems for every 7th day in a row the Daily Challenge is cleared.
  final int dailyStreakGems;
}
