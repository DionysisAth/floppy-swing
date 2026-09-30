import 'dart:io';

import 'package:floppy_swing/services/ads_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/src/admob.dart';

void main() {
  const json = '''{
    "android": {"appId": "ca-app-pub-1~1", "rewarded": "ca-app-pub-1/10", "interstitial": ""},
    "ios": {"appId": "ca-app-pub-1~2", "rewarded": "ca-app-pub-1/20", "interstitial": "ca-app-pub-1/21"},
    "testDevices": ["ABC"]
  }''';

  test('store builds use the configured ad units, falling back to test ids', () {
    final c = AdConfig.parse(json, realAds: true);
    expect(c.rewarded(ios: false), 'ca-app-pub-1/10');
    expect(c.interstitial(ios: false), AdConfig.testAndroidInterstitial);
    expect(c.rewarded(ios: true), 'ca-app-pub-1/20');
    expect(c.interstitial(ios: true), 'ca-app-pub-1/21');
    expect(c.testDevices, ['ABC']);
  });

  test('test builds always use test ads', () {
    final c = AdConfig.parse(json, realAds: false);
    expect(c.rewarded(ios: false), AdConfig.testAndroidRewarded);
    expect(c.rewarded(ios: true), AdConfig.testIosRewarded);
    expect(c.interstitial(ios: true), AdConfig.testIosInterstitial);
  });

  test('the shipped admob.json parses and iOS is in sync with it', () {
    final raw = File('assets/config/admob.json').readAsStringSync();
    AdConfig.parse(raw);
    expect(
      File(admobXcconfigPath).readAsStringSync(),
      admobXcconfig(iosAdmobAppId(raw)),
      reason: 'run `dart run tool/sync_admob.dart`',
    );
  });
}
