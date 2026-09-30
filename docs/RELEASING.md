# Releasing Floppy Swing

Test builds are made by GitHub Actions on every push (see
`.github/workflows/build.yml`). This is what's left to do for the stores.

## 1. Play Games and Game Center (free, no server)

Leaderboards, achievements and cloud save run on Google Play Games (Android)
and Game Center (iOS). Set them up in Play Console and App Store Connect and
fill in `lib/services/games_ids.dart` as described in
**`docs/GAMES_SERVICES.md`**. Until then builds are fully playable and the
leaderboard/achievement buttons are hidden.

## 2. Ads (your AdMob account)

All AdMob ids live in **one file, `assets/config/admob.json`**. Empty values
mean Google's test ids.

1. In AdMob (https://admob.google.com) add two apps, Floppy Swing for Android
   and for iOS (you can link them to the store listings later).
2. In each app create two ad units: **Rewarded** (revives, double coins) and
   **Interstitial** (between levels).
3. Paste the ids into `assets/config/admob.json`:
   ```json
   "android": { "appId": "ca-app-pub-XXXX~AAAA", "rewarded": "ca-app-pub-XXXX/BBBB", "interstitial": "ca-app-pub-XXXX/CCCC" },
   "ios":     { "appId": "ca-app-pub-XXXX~DDDD", "rewarded": "ca-app-pub-XXXX/EEEE", "interstitial": "ca-app-pub-XXXX/FFFF" }
   ```
   then run `dart run tool/sync_admob.dart` (copies the iOS app id to
   `ios/Flutter/AdMob.xcconfig`; Android reads the JSON when building, and CI
   runs the sync too). `flutter test` checks the two agree.
4. **Test builds never serve real ads.** Real ads (your ad units and, on
   Android, your app id) are switched on only by
   `--dart-define=REAL_ADS=true`, which CI passes when building the Play Store
   bundle (`FloppySwing.aab`). The `FloppySwing.apk` test builds keep Google's
   test ads, so you can't click your own ads by accident (AdMob bans accounts
   for that). To see real ads on your own phone safely, add its id to
   `testDevices` in the same file (AdMob logs it on the first ad request), or
   register it in AdMob under Settings > Test devices.
5. In AdMob, **Privacy & messaging**: create a **GDPR** message (EU/UK
   consent) and an **IDFA explainer** (iOS). The app already shows them
   through Google's UMP SDK, and Settings > Privacy options reopens them.
6. **app-ads.txt**: AdMob asks for a file at `https://<your developer
   website>/app-ads.txt` with the line it gives you. Put the same website in
   both store listings. (A GitHub Pages user site,
   `https://<user>.github.io`, works if that's your listed website.)
7. Optional, more revenue later: mediation (AppLovin, Unity, ...) is set up in
   AdMob, and each network needs its adapter plugin added to the app.
8. iOS: `ios/Runner/Info.plist` lists Google's SKAdNetwork id. AdMob's docs
   have a longer list of partner ids you can paste into `SKAdNetworkItems`.

## 2b. In-app purchases (gem packs, Starter Pack, No Ads, Premium Pass)

The code is done (`lib/services/purchase_service.dart`, catalogue in
`lib/game/store_products.dart`). There is no server: the store's confirmation
is paid out on the device, recorded by transaction id so nothing is paid
twice, and synced through the cloud save. What's needed in the consoles:

- **Google Play:** set up a payments profile (Play Console > Setup > Payments
  profile). Upload one build first (Play only lets you add products to an app
  that has a build with billing, e.g. `FloppySwing.aab` on internal testing),
  then create the 7 products in Monetize > Products > In-app products with the
  ids in `docs/store/listing.md`, and activate them. Add your Google account
  under Settings > License testing to buy without being charged.
- **App Store:** sign the Paid Apps agreement and fill in banking and tax
  (App Store Connect > Business). Create the same 7 product ids under your
  app > In-App Purchases (Consumable / Non-Consumable as in the table), each
  with a screenshot of the shop for review. Test with a Sandbox account
  (Users and Access > Sandbox).
- Until the products exist the shop shows "The store can't be reached" and
  the buy buttons are greyed out; everything else works.
- The Gems tab has **Restore purchases** (Apple requires it); reinstalls also
  restore automatically on Android.

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
   (see `docs/privacy-policy.md`: gameplay data and Play Games profile
   through Google, device IDs through AdMob), and the content rating.

## 3b. Publishing to Google Play from GitHub

`.github/workflows/play.yml` ("Publish to Google Play", run by hand from the
Actions tab) builds the signed store bundle with real ads, uploads the store
listing (text in `docs/store/play/listing_en-US.json`, icon, feature graphic,
screenshots) and puts the bundle on a track. It needs these repository
secrets: the four upload key secrets above plus `PLAY_SERVICE_ACCOUNT_JSON`
(the whole JSON key of a Google Cloud service account that has been invited in
Play Console > Users and permissions). Never commit that key.

- Until the app has been approved once, Google only accepts **draft**
  releases: the workflow leaves a draft on the track, and you press
  "Send for review" in Play Console after finishing the App content forms
  (privacy policy URL, ads, content rating, target audience, data safety).
- New personal developer accounts must run a **closed test with at least 12
  testers for 14 days** before production is unlocked; run the workflow with
  track `alpha` (closed testing) for that.
- The same script works locally:
  `PLAY_SERVICE_ACCOUNT=key.json python3 tool/store/play_publish.py listing`.

Store graphics: `docs/store/play/` (512 px icon, 1024x500 feature graphic,
made by `tool/store/feature_art_test.dart` + `make_store_assets.py`). The 15 s
9:16 promo video (TikTok / Reels / Shorts, and the Play listing via a YouTube
link) is made by `tool/store/promo_video_test.dart` + `make_promo_video.py`.

## 4. iOS (App Store / TestFlight)

1. Apple Developer account, then in Xcode open `ios/Runner.xcworkspace`, set
   your Team and bundle ID (`com.floppyswing.floppySwing` by default), and
   let Xcode manage signing.
2. `dart run tool/sync_admob.dart && flutter build ipa --release --dart-define=REAL_ADS=true`
3. Upload `build/ios/ipa/*.ipa` with Xcode's Organizer or Transporter, and
   add testers in TestFlight.
4. App Store Connect: fill in the listing, App Privacy (same as Data safety
   above), age rating and screenshots from `docs/store/`.
   - The game has no accounts of its own (Game Center is Apple's), so
     App Review's account-deletion rule doesn't apply.

## 5. Store assets

- Icons are already in place. Re-render with
  `flutter test tool/icon/icon_test.dart && python3 tool/icon/make_icons.py`.
- Screenshots: `docs/store/screenshots/` (see `docs/store/listing.md`).
- Privacy policy: host `docs/privacy-policy.md` somewhere public (e.g. GitHub
  Pages) after filling in the bracketed parts.

## 6. Version numbers

`version:` in `pubspec.yaml` (`1.0.0+2` means version 1.0.0, build 2) is the
version name. Each store upload needs a higher build number; CI builds use the
workflow run number, which always goes up. Bump the version name (e.g.
`1.0.1`) for each public release.

## 7. Soft launch

Release in a few smaller countries first, watch Play Console / App Store
Connect statistics (retention, crashes) and, if you plug a free analytics SDK
into `Analytics.sink` (e.g. Firebase Analytics), level completion rates and
death causes, tune `assets/config/*.json` and
the levels, then go global.
