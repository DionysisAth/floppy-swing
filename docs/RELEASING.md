# Releasing Floppy Swing

Test builds are made by GitHub Actions on every push (see
`.github/workflows/build.yml`). This is what's left to do for the stores.

## 1. Game server

Deploy `server/` (see `server/README.md`) and set the repository variable
`FLOPPY_SERVER_URL`. Without it, builds are fully playable offline and online
features show as off.

## 2. Ads (your AdMob account)

Replace Google's test IDs:

- `lib/services/ads_service.dart` (`AdIds.rewarded`, `AdIds.interstitial`);
- the app IDs in `android/app/src/main/AndroidManifest.xml`
  (`com.google.android.gms.ads.APPLICATION_ID`) and `ios/Runner/Info.plist`
  (`GADApplicationIdentifier`);
- in AdMob, set up the GDPR message and the iOS IDFA explainer under Privacy &
  messaging. The app already shows them through UMP.

## 3. Android (Google Play)

1. Create an upload key once:
   `keytool -genkey -v -keystore upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. For local release builds, create `android/key.properties` (ignored by git):
   ```
   storeFile=../upload.jks
   storePassword=...
   keyAlias=upload
   keyPassword=...
   ```
3. For CI, add these repository **secrets**:
   - `ANDROID_KEYSTORE_BASE64`: `base64 -w0 upload.jks`
   - `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`

   CI then signs the APK with it and also attaches `FloppySwing.aab` to each
   release.
4. In Play Console, create the app (package `com.floppyswing.floppy_swing`, or
   change `applicationId` in `android/app/build.gradle.kts` first), turn on
   Play App Signing, and upload the `.aab` to an internal testing track.
5. Fill in the listing from `docs/store/listing.md`, the Data safety form
   (see `docs/privacy-policy.md`: player ID, name, gameplay data, user
   content (clips), device IDs through AdMob), and the content rating.

## 4. iOS (App Store / TestFlight)

1. Apple Developer account, then in Xcode open `ios/Runner.xcworkspace`, set
   your Team and bundle ID (`com.floppyswing.floppySwing` by default), and
   let Xcode manage signing.
2. `flutter build ipa --release --dart-define=FLOPPY_SERVER=https://...`
3. Upload `build/ios/ipa/*.ipa` with Xcode's Organizer or Transporter, and
   add testers in TestFlight.
4. App Store Connect: fill in the listing, App Privacy (same as Data safety
   above), age rating and screenshots from `docs/store/`.
   - Account deletion is in Settings > Online (required by App Review).
   - User-generated content (Fail of the Week) has reporting and hiding,
     which App Review asks about.

## 5. Store assets

- Icons are already in place. Re-render with
  `flutter test tool/icon/icon_test.dart && python3 tool/icon/make_icons.py`.
- Screenshots: `docs/store/screenshots/` (see `docs/store/listing.md`).
- Privacy policy: host `docs/privacy-policy.md` somewhere public (e.g. GitHub
  Pages) after filling in the bracketed parts.

## 6. Version numbers

Bump `version:` in `pubspec.yaml` (`1.0.0+1` means version 1.0.0, build 1);
each store upload needs a higher build number.

## 7. Soft launch

Release in a few smaller countries first, watch `/v1/admin/stats` (level
completion rates, death causes, retention), tune `assets/config/*.json` and
the levels, then go global.
