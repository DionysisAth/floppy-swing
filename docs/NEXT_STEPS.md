# Floppy Swing: what's left, and how to pick up

This is a handoff for the next work session. It lists everything from the
original design document (`floppy-swing-design.md`) that isn't built yet, plus
known loose ends, and how to get productive in this repo quickly.

**State when this was written:** branch `claude/loving-fermat-muip8y`,
latest test build
[test-build-10](https://github.com/DionysisAth/floppy-swing/releases/tag/test-build-10).
Everything below "Done" is in that build; everything under "Not built yet" is not.

---

## Done (for context)

- **MVP (design doc §15):** ragdoll + rope, one-touch controls, spikes, saws,
  bounce pads, instant retry, slow-mo fail replay, 9:16 share clip, coins,
  stars, style points, 5 skins, rewarded ads, checkpoints and revives.
- **Milestone 1, Worlds 2–5:** moving anchors, glass, wind fans, gravity flips,
  crumbling platforms and rockets. 100 campaign levels, all beaten by the test
  bot. Each world has its own look and music, and worlds unlock with stars.
- **Milestone 2, modes:** Endless mode (generated course, distance + style
  score, local best) and the Daily Challenge (60-level verified pool, streaks,
  local best time).
- **Milestone 3, economy and cosmetics:**
  - Gems, a 7-day login bonus, level skip and gem revives.
  - Shop with rope styles, trails, fail effects, victory dances and collections.
  - Season Pass: free and premium tracks, 4 themed seasons, each with an exclusive skin.
  - A ghost of your best run.
  - Paced interstitial ads.

---

## Not built yet

### 1. Real-money purchases (design doc §10.2–10.4, §14.4)

Nothing uses real money yet. Gems are only earned in-game. You need
**App Store Connect** and **Google Play Console** products set up before
this can be tested for real.

- Add the `in_app_purchase` plugin and a `PurchaseService` next to
  `lib/services/ads_service.dart`, with a no-op version for tests like
  `NoAdsService`.
- **Gem packs**: small, medium and large. Credit them with `ProgressStore.addGems`.
- **Starter Pack** (§10.3): a cheap, high-value one-time bundle, shown once
  after the player's first few sessions (track sessions in `ProgressStore`).
- **Remove ads**: set `ProgressStore.adsRemoved = true`, which already
  switches off interstitials. The doc also says any purchase should reduce
  interstitials, so consider easing the pacing in `interstitialDue` for payers.
- **Premium Season Pass for money.** It's currently 250 gems
  (`Season.premiumGems` in `lib/game/season.dart`). Decide whether it becomes
  money-only or both.
- **Restore purchases** button (required by Apple) in Settings.
- **Receipt validation.** Client-side is fine to start. Server-side needs a backend (see 3).

### 2. Leaderboards (design doc §8, §11, §14.4)

Daily Challenge and Endless scores are **stored on the device only**.

- Needs a backend decision (still open in design doc §17): **Game Center / Google Play Games**
  (e.g. the `games_services` plugin) or a custom backend such as Firebase.
- **Daily leaderboard**: best time per day, resetting daily. The day number is
  `dayNumber()` in `lib/services/progress.dart` and uses local time, so a global
  board needs a UTC day.
- **Endless leaderboard**: best score (`ProgressStore.endlessBest`).
- The fairness rule (§10) is already kept: no revives or pay-to-win items in
  Daily/Endless.

### 3. Cloud save (design doc §14.4)

- The whole save is one JSON blob (`ProgressStore.toJson`, prefs key
  `floppy_swing_save_v1`). Ghosts are separate keys (`ghost_L<id>`,
  `ghost_D<day>`).
- Sync it with Game Center / Play Games saved games, or with the chosen backend.
- Needs a merge rule. Suggested: take the max per field for coins and stars,
  union owned items, and prefer the newer settings.

### 4. Friend Ghosts (design doc §8)

- The ghost format already exists: a `Float32List` of (run time, x, y, angle)
  at 15 Hz, recorded in `GameController.recordedGhost` and drawn by
  `WorldRenderer.ghost`.
- Missing: friends/accounts, uploading and downloading ghosts, picking whose
  ghost to race, and drawing several ghosts with names.

### 5. Fail of the Week (design doc §9.3)

- Players submit clips; the best one is featured in-game and its player gets
  a reward (e.g. an exclusive skin or gems).
- Needs a server: upload, moderation, voting or curation, and a feed in the app.
- The clip exporter already makes the MP4 (`lib/services/clip_exporter.dart`).

### 6. Analytics backend (design doc §14.4)

- `lib/services/analytics.dart` only prints to the debug log. Events already
  fire for level start, fail (with cause and position), complete, skip,
  rewarded ads, interstitials, season rewards and clip shares.
- Plug in Firebase Analytics or similar. Add retention and purchase events
  once purchases exist.

### 7. Ads mediation (design doc §14.4, "with mediation if possible")

- The app uses only Google AdMob, with **test ad IDs**. Add mediation networks
  in AdMob, and replace the test IDs (see "Before release" below).

### 8. Launch work (design doc §16 steps 3 and 6, §1)

- **Real-device testing**: check the steady-60-FPS target on mid-range phones
  and the "fun for 10 minutes" test with friends. Nothing has been tested on a
  physical device by the developer side yet.
- **Level length check**: the doc wants 20–60 s per level for people. The bot
  finishes levels in roughly 3–27 s (about 8 s typically), so real player times
  are unknown and probably shorter than the doc wants. Use the
  analytics fail data to find levels that are too hard.
- **Store listings**: icons (still Flutter defaults), screenshots, descriptions,
  age ratings, privacy policy URL and App Privacy / Data Safety forms.
- **Release signing** (Android keystore, iOS certificates) and a **TestFlight**
  build. CI currently makes an unsigned IPA.
- Soft launch in a few countries, then global launch.

### 9. Smaller loose ends

- **Economy tuning** (open decision in §17): prices and rewards are first
  guesses. They live in `assets/config/economy.json`, `lib/game/cosmetics.dart`
  and `lib/game/season.dart`.
- **Tablet/iPad layout:** portrait phone layouts are done, but nothing has been
  tuned for tablets.
- **Seasons** are computed from the calendar in 49-day blocks starting
  1 Jan 2026, cycling through 4 themes. A server-driven season schedule would
  allow new themes without an app update.
- **Endless** is a 3 km course. A very good player could reach the end, which
  is a finish line. Making it truly endless would need adding bodies to the
  running simulation.
- **Friend challenge links** (share a Daily result or Endless seed) could reuse
  `GameScreen.endless(seed: ...)`.

---

## How to pick up in a new session

- **Read first:** `README.md` (features, layout, tuning, level format) and
  this file.
- **Branch:** keep working on `claude/loving-fermat-muip8y`, or ask which
  branch to use.
- **Flutter:** 3.47.5. In the cloud container it is at `/opt/sdk/flutter`
  (`export PATH=/opt/sdk/flutter/bin:$PATH`).
- **Checks before every push:** `flutter analyze` (must be clean) and
  `flutter test` (381 tests, about 15 s). `test/levels_test.dart` replays the
  bot's solution for every campaign and daily level.
- **Builds happen in GitHub Actions**, not locally. The container can't reach
  `dl.google.com` for the Android SDK. `.github/workflows/build.yml`:
  - builds the APK and runs the tests;
  - smoke-tests the app on an Android emulator (`tool/ci_smoke_test.sh`);
  - builds an unsigned iOS IPA;
  - publishes a `test-build-N` prerelease with both files.
  **Every push makes a release**, so push when something is ready to try.
- **Physics engine:** `third_party/forge2d` is a vendored, patched forge2d
  (fixes a ragdoll explosion bug). Don't replace it with the pub.dev version.
- **Levels:**
  - `dart run tool/gen_levels.dart` regenerates levels 16–100;
  - `dart run tool/gen_levels.dart --daily` regenerates the daily pool;
  - `dart run tool/check_levels.dart` re-verifies all levels after physics changes.
  Levels 1–15 are hand-made.
- **Everything is deterministic** (fixed 60 Hz step), which is why the bot
  checks, replays, clips and ghosts work. Keep new mechanics deterministic.
- **Screenshots for visual checks:** render frames in a throwaway test with
  `matchesGoldenFile` / `PictureRecorder` (see git history for `zz_*_test.dart`
  patterns), look at them, then delete the test.

### Before release (already listed in README "Before releasing")

- Replace the AdMob test IDs, rewarded and interstitial, in
  `lib/services/ads_service.dart`, `AndroidManifest.xml` and `ios/Runner/Info.plist`.
- Set the store link in `ShareText` (`lib/services/clip_exporter.dart`).
- Set bundle IDs, signing and icons.
