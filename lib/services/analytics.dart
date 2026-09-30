import 'package:flutter/foundation.dart';

/// Gameplay analytics. Events go to the debug log, and to [sink] when one is
/// plugged in (e.g. a free analytics SDK such as Firebase Analytics). The
/// events are chosen to find levels that are too hard: compare `level_fail`
/// counts and causes against `level_complete`.
class Analytics {
  const Analytics({this.sink});

  /// Where events go besides the debug log.
  final void Function(String event, Map<String, Object?> params)? sink;

  void log(String event, [Map<String, Object?> params = const {}]) {
    if (kDebugMode) debugPrint('[analytics] $event $params');
    sink?.call(event, params);
  }

  void levelStart(int level, int attempt) =>
      log('level_start', {'level': level, 'attempt': attempt});

  void levelFail(int level, String cause, double x, double time) => log('level_fail', {
    'level': level,
    'cause': cause,
    'x': x.round(),
    'time': time.toStringAsFixed(1),
  });

  void levelComplete(int level, double time, int stars, int attempts) => log('level_complete', {
    'level': level,
    'time': time.toStringAsFixed(2),
    'stars': stars,
    'attempts': attempts,
  });

  void adRewarded(String placement) => log('ad_rewarded', {'placement': placement});
  void clipShared(String kind) => log('clip_shared', {'kind': kind});
  void skinBought(String id) => log('skin_bought', {'id': id});
  void levelSkipped(int level) => log('level_skipped', {'level': level});
  void interstitialShown(int levelsSinceLast) => log('interstitial', {'levels': levelsSinceLast});
  void seasonReward(int tier, bool premium) => log('season_reward', {'tier': tier, 'premium': premium});
  void sessionStart() => log('session_start');
  void modeStart(String mode) => log('mode_start', {'mode': mode});
  void endlessRun(int distance, int score) => log('endless_run', {'distance': distance, 'score': score});
  void dailyComplete(int day, double time) => log('daily_complete', {'day': day, 'time': time.toStringAsFixed(2)});
  void purchaseStarted(String product) => log('purchase_started', {'product': product});
  void itemBought(String id, String currency) => log('item_bought', {'id': id, 'currency': currency});
}
