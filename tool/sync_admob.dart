// ignore_for_file: avoid_print
// Copies the iOS AdMob app id from assets/config/admob.json into
// ios/Flutter/AdMob.xcconfig, where Info.plist picks it up. (Android reads
// the JSON directly in build.gradle.kts.) Run after changing the app ids:
//
//   dart run tool/sync_admob.dart
import 'dart:io';

import 'src/admob.dart';

void main() {
  final id = iosAdmobAppId(File('assets/config/admob.json').readAsStringSync());
  File(admobXcconfigPath).writeAsStringSync(admobXcconfig(id));
  print('iOS AdMob app id: $id');
}
