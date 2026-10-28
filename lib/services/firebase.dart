import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'analytics.dart';

/// Event names Firebase logs by itself and won't take from the app.
const _reserved = {'session_start', 'first_open', 'screen_view', 'user_engagement', 'app_update'};

/// Starts Firebase and returns [Analytics] that also send every gameplay
/// event to Firebase Analytics. Android only for now (iOS needs its own
/// GoogleService-Info.plist); elsewhere, or if Firebase fails to start,
/// events only go to the debug log.
Future<Analytics> startAnalytics() async {
  if (kIsWeb || !Platform.isAndroid) return const Analytics();
  try {
    // Reads android/app/google-services.json (built into the app).
    await Firebase.initializeApp().timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('Firebase failed to start: $e');
    return const Analytics();
  }
  final firebase = FirebaseAnalytics.instance;
  return Analytics(
    sink: (event, params) {
      if (_reserved.contains(event)) return;
      unawaited(
        firebase
            .logEvent(name: event, parameters: firebaseParams(params))
            .catchError((Object e) => debugPrint('Analytics: $e')),
      );
    },
  );
}

/// Firebase takes only numbers and strings (up to 100 characters) as
/// event parameters.
@visibleForTesting
Map<String, Object> firebaseParams(Map<String, Object?> params) => {
  for (final e in params.entries)
    if (e.value != null)
      e.key: switch (e.value) {
        final bool b => b ? 1 : 0,
        final num n => n,
        final v => v.toString().length > 100 ? v.toString().substring(0, 100) : v.toString(),
      },
};
