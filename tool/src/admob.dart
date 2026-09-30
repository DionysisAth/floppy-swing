import 'dart:convert';

const admobXcconfigPath = 'ios/Flutter/AdMob.xcconfig';

/// Google's test app id for iOS, used until a real one is set.
const testIosAdmobAppId = 'ca-app-pub-3940256099942544~1458002511';

/// The iOS app id in an `admob.json`, or the test id when it's empty.
String iosAdmobAppId(String json) {
  final ios = (jsonDecode(json) as Map<String, dynamic>)['ios'] as Map<String, dynamic>?;
  final id = ((ios?['appId'] as String?) ?? '').trim();
  return id.isEmpty ? testIosAdmobAppId : id;
}

String admobXcconfig(String appId) =>
    '// Generated from assets/config/admob.json by tool/sync_admob.dart.\n'
    'ADMOB_APP_ID = $appId\n';
