import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'services/ads_service.dart';
import 'services/analytics.dart';
import 'services/audio_service.dart';
import 'services/games_service.dart';
import 'services/progress.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final content = await loadContent(rootBundle);
  final progress = await ProgressStore.load(content.economy);
  final audio = AudioService(progress);
  await audio.init();

  final analytics = const Analytics()..sessionStart();
  // Play Games / Game Center sign-in happens in the background; the game
  // never waits for it.
  final games = GamesService(progress);
  unawaited(games.start());

  final mobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  final AdsService ads = mobile ? GoogleAdsService() : NoAdsService(grantRewards: kDebugMode);
  // Consent + ad loading happens in the background; the game never waits.
  unawaited(ads.init().catchError((Object e) => debugPrint('Ads init failed: $e')));

  runApp(
    FloppySwingApp(
      services: (child) => AppServices(
        physics: content.physics,
        economy: content.economy,
        levels: content.levels,
        dailies: content.dailies,
        progress: progress,
        audio: audio,
        ads: ads,
        analytics: analytics,
        games: games,
        child: child,
      ),
    ),
  );
}
