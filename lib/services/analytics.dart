import 'package:flutter/foundation.dart';

/// Gameplay analytics hook. The MVP just logs; plug in Firebase Analytics or
/// similar here. The events are chosen to find levels that are too hard:
/// compare `level_fail` counts and causes against `level_complete`.
class Analytics {
  const Analytics();

  void log(String event, [Map<String, Object?> params = const {}]) {
    if (kDebugMode) debugPrint('[analytics] $event $params');
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
}
