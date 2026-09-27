# Floppy Swing: what's left, and how to pick up

A handoff for the next work session: what from the original design document
(`floppy-swing-design.md`) isn't built, known loose ends, and how to get
productive in this repo quickly.

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
- **Online (game server in `server/`):** accounts, Daily/Endless leaderboards
  (everyone/friends), cloud save with merge and device transfer, friends,
  friend ghosts, Endless challenge codes, Fail of the Week (upload, vote,
  report, weekly winner + Golden Flop reward, moderation), analytics with an
  admin stats endpoint, account deletion.
- **Launch prep:** app icon and splash, Android release signing via
  `key.properties` or CI secrets (plus an `.aab`), tablet layouts, store
  listing draft, privacy policy draft, store screenshots, release guide.

## Not built yet

### Left out on purpose (the owner asked to skip these)

1. **Real-money purchases** (design doc §10.2–10.4): gem packs, Starter Pack,
   "Remove ads" (the flag `ProgressStore.adsRemoved` already switches off
   interstitials), premium Season Pass for money (it's 250 gems now,
   `Season.premiumGems`), restore purchases. Use the `in_app_purchase`
   plugin with a `PurchaseService` next to `ads_service.dart`; for
   server-side receipt checks add an endpoint to `server/`.
2. **Real ads:** replace AdMob test ids (see `docs/RELEASING.md`), and add
   mediation networks in AdMob.

### Needs the owner's accounts (not code)

- **Deploy the game server** (`server/README.md`) and set the GitHub repository
  variable `FLOPPY_SERVER_URL`. Until then, builds show online features as
  off (Settings > Online also lets testers enter a server address).
- **Store submissions:**
  - Play Console / App Store Connect apps and TestFlight;
  - upload key secrets;
  - fill in the brackets in `docs/privacy-policy.md` and host it;
  - Data safety / App Privacy forms.
- **Real-device testing:** the 60 FPS target on mid-range phones, the "fun for
  10 minutes" test, and real players' level times (the bot finishes levels in
  3–27 s; the doc wants 20–60 s for people). Use `/v1/admin/stats` after a
  soft launch to find levels that are too hard or too quick.

### Possible improvements

- **Truly endless Endless:** the course is 3 km, which at the top difficulty
  is several minutes of perfect play. Longer courses cost CPU because the
  simulation loops over every element each step. A proper fix is a spatial
  window in `Simulation` (only process elements near the player), then
  streaming more segments in.
- **Server-driven seasons and events** (new Season Pass themes without an app
  update): the calendar is fixed in `lib/game/season.dart` today.
- **Push notifications** (daily reminder, "your fail won").
- **Rate limiting / abuse protection** on the server before a large launch
  (see `server/README.md`).
- **Deep links** for challenge codes and friend codes (they're typed in today).

## How to pick up in a new session

- **Read first:** `README.md`, this file, `docs/RELEASING.md`,
  `server/README.md`.
- **Flutter:** 3.47.5. In the cloud container it is at `/opt/sdk/flutter`
  (`export PATH=/opt/sdk/flutter/bin:$PATH`).
- **Checks before every push:**
  - `flutter analyze` (clean);
  - `flutter test` (about 395 tests, ~20 s). Includes every level's bot replay
    and client tests that run the real server code in-process, so it needs
    libsqlite3;
  - `(cd server && dart analyze && dart test)`.
- **Builds run in GitHub Actions** (`.github/workflows/build.yml`; the
  container can't download the Android SDK):
  - server tests;
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
