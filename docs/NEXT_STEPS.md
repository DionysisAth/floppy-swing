# Floppy Swing: what's left, and how to pick up

A handoff for the next work session: what's built, what's left (mostly
account setup), and how to get productive in this repo quickly.

**State:** branch `claude/loving-fermat-muip8y`. Every push makes a
`test-build-N` release (APK + unsigned IPA).

## Done

- **MVP:** ragdoll + rope, one-touch controls, spikes/saws/pads, instant
  retry, slow-mo fail replay, 9:16 share clip, coins, stars, style points,
  skins, rewarded ads, checkpoints and revives.
- **Worlds 2–5:** moving anchors, glass, wind, gravity flips, crumbling
  platforms, rockets; 100 bot-verified levels; world themes and music; star gates.
- **Modes:** Endless (generated 3 km course) and the Daily Challenge (pool of 60).
- **Economy and cosmetics:** gems, login calendar, level skip, gem revives,
  shop (ropes, trails, fail effects, dances, collections), Season Pass,
  best-run ghost, paced interstitials.
- **Online, with no server of our own:** Google Play Games / Game Center
  sign-in, Daily and Endless leaderboards (native UI, including friends),
  12 achievements, cloud save via Saved Games with merge
  (`lib/services/games_service.dart`, `docs/GAMES_SERVICES.md`). Endless
  challenge codes. Golden Flop skin for all 300 stars. (An earlier custom
  game server with friends, friend ghosts and Fail of the Week was removed
  at the owner's request: nothing here needs a VPS.)
- **Launch prep:** app icon and splash, Android release signing via
  `key.properties` or CI secrets (plus an `.aab`), tablet layouts, store
  listing draft, privacy policy draft, store screenshots, release guide.
- **Money:** in-app purchases with no server (gem packs, Starter Pack,
  No Ads, Premium Pass for money, restore; `purchase_service.dart`,
  `store_products.dart`), and real ads from one config file
  (`assets/config/admob.json`; test builds always serve test ads, the store
  bundle real ones).
- **Retention:** Daily Challenge reminder notifications (local, no server)
  and `floppyswing://challenge/<code>` links for Endless challenges.

## What's left

### Needs the owner's accounts (not code)

Step by step in `docs/RELEASING.md`:

- **AdMob:** create the apps and ad units, paste the ids into
  `assets/config/admob.json`, run `dart run tool/sync_admob.dart`, set up the
  GDPR and IDFA messages, publish `app-ads.txt`.
- **In-app products:** create the 7 products (ids in `docs/store/listing.md`)
  in Play Console and App Store Connect; payments profile / Paid Apps
  agreement, banking and tax.
- **Play Games / Game Center setup** (`docs/GAMES_SERVICES.md`): create the
  leaderboards and achievements in the consoles, paste the ids into
  `lib/services/games_ids.dart` and `res/values/games-ids.xml`, set
  `enabled: true`. Until then the buttons are hidden.
- **Store submissions:**
  - Play Console / App Store Connect apps and TestFlight;
  - upload key secrets (then CI attaches a signed `.aab` with real ads);
  - fill in the brackets in `docs/privacy-policy.md` and host it (GitHub
    Pages: Settings > Pages > deploy from branch, folder `/docs`, gives
    `https://<user>.github.io/<repo>/privacy-policy`);
  - Data safety / App Privacy forms.
- **Real-device testing:** the 60 FPS target on mid-range phones, the "fun for
  10 minutes" test, and real players' level times. Plug a free analytics SDK
  (e.g. Firebase Analytics, which needs your Firebase project's config files)
  into `Analytics.sink` to see level completion rates after a soft launch.

### Possible improvements

- **Truly endless Endless:** the course is 3 km, which at the top difficulty
  is several minutes of perfect play. Longer courses cost CPU because the
  simulation loops over every element each step. A proper fix is a spatial
  window in `Simulation` (only process elements near the player), then
  streaming more segments in.
- **Remote seasons and events** (new Season Pass themes without an app
  update): the calendar is fixed in `lib/game/season.dart` today. Firebase
  Remote Config (free) could drive it.
- **https challenge links** that open the app from any messenger (custom
  `floppyswing://` links aren't clickable everywhere): needs a website for
  Android App Links (`assetlinks.json`) and iOS Universal Links
  (`apple-app-site-association`).
- **Ad mediation** in AdMob for higher fill and eCPM (adapter plugins).
- **Server-side receipt checks** if cheating on purchases ever matters.

## How to pick up in a new session

- **Read first:** `README.md`, this file, `docs/RELEASING.md`,
  `docs/GAMES_SERVICES.md`.
- **Flutter:** 3.47.5 (install it in the cloud container if it's missing).
- **Checks before every push:**
  - `flutter analyze` (clean);
  - `flutter test` (~20 s). Includes every level's bot replay.
- **Builds run in GitHub Actions** (`.github/workflows/build.yml`; the
  container can't download the Android SDK):
  - Android build + tests;
  - emulator smoke test;
  - unsigned iOS build;
  - `test-build-N` prerelease.
- **Physics:** `third_party/forge2d` is a vendored, patched forge2d. Keep it.
- **Levels:**
  - `dart run tool/gen_levels.dart` (16–100);
  - `--daily` (daily pool);
  - `dart run tool/check_levels.dart` re-verifies after physics changes.
  The simulation is deterministic (fixed 60 Hz), which is what makes bot
  checks, replays, clips and ghosts work.
- **Visual checks:** render frames or screens in a throwaway test with
  `matchesGoldenFile`, look at them, delete the test. `tool/screenshots/` shows
  the pattern.
