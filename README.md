# Floppy Swing

A one-thumb, physics-based ragdoll grappling game for **iOS and Android**,
built from one Flutter codebase. Hold anywhere to fire the rope at the
highlighted ring, let go to fly. Fails are replayed in slow motion and can be
shared as vertical clips.

| Menu | Levels | Swinging | Slow-mo fail | Level clear | Skins |
|---|---|---|---|---|---|
| ![](docs/screenshots/1_menu.png) | ![](docs/screenshots/2_levels.png) | ![](docs/screenshots/4_swinging.png) | ![](docs/screenshots/7_replay.png) | ![](docs/screenshots/9_won.png) | ![](docs/screenshots/6_shop.png) |

This covers the whole design document except real-money purchases and real
ad accounts: the MVP, Worlds 2–5, Endless mode, the Daily Challenge, the
economy and cosmetics, and the online features (leaderboards, achievements,
cloud save) through Google Play Games and Game Center, which are free and
need no server of your own. See `docs/NEXT_STEPS.md` for what's left and
`docs/RELEASING.md` for getting it into the stores.

## What's in the game

- **Slingshot start:** the first grab of a run (even if you press before the character has landed) and any grab from the ground fling the character straight into a full-speed swing, and slow swings get extra pump until they're moving.
- **Flowing swings:** a press picks the next ring ahead rather than one you've already flown past, and grabbing a ring right next to you gives a slack rope, so you swoop down under it into a full swing instead of whipping round it.
- **Themed worlds:** each world has its own backdrop (hills, factory skyline, city, floating islands, rocket base), its own soundtrack, and a sky that drifts across its 20 levels (e.g. morning to sunset, day to night). Plus a motion trail, speed lines, dust puffs and screen shake.
- **One-touch controls:** hold to grab the nearest ring in range (it glows), release to let go.
- **Floppy 2D ragdoll**, 10 parts on limited revolute joints, with a rope (max-length joint) on the front hand.
- **Obstacles:** spikes, spinning saws (static and moving), bounce pads, plus a spike pit.
- **100 levels in 5 worlds**, each with a finish, coins, a target time, and checkpoints on longer levels:
  - World 1 **Playground**: spikes, saws and bounce pads.
  - World 2 **Factory** (15 stars): rings that ride on rails, and moving saws.
  - World 3 **Glass City** (40 stars): glass that smashes when you hit it fast enough, and pads.
  - World 4 **Sky Islands** (70 stars): wind fans that blow you up or along, and zones that flip gravity.
  - World 5 **Rocket Base** (100 stars): platforms that crumble after you touch them, and rockets that knock you flying.
- **Endless mode:** one generated 3 km course per run. Every 180 m a new zone brings in the next world's mechanics, look (cross-faded) and music, and difficulty keeps rising. Score is distance plus style, a flag marks your best distance, and there are no revives. Tap to retry the same course, or ask for a new one.
- **Daily Challenge:** a new bot-verified level every day (a pool of 60, themed on each world in turn). The first clear of the day pays coins and gems, clearing it on consecutive days builds a streak (bonus gems every 7th day), and your best time per day is kept. No revives, so scores stay fair.
- **World select:** swipe between worlds. A world opens when you have its stars and have finished the world before it.
- **Instant retry:** tap during or after a fail to restart. There are no menus in between, and rebuilding the physics world takes about 1–2 ms.
- **Slow-motion fail replay:** a zoomed 0.4× replay with a comic burst and a second helping of the fail sound. Tap to skip.
- **Share clip:** a 720×1280 (9:16) MP4 of the last few seconds plus the slow-mo replay, with a watermark and a "Can you do better?" end card, shared through the native share sheet.
- **Stars** (finish, target time, all coins), **coins**, and **style points** (flips, close calls, hang time, big swings, combos).
- **Shop:** 6 skins (1 free, 5 for coins, each with its own fail sound), plus rope styles (chain, spaghetti, rainbow, laser), trails (sparkles, bubbles, fire), fail effects (squeaky toy, confetti, a jackpot of coins) and victory dances (backflip, tornado, wacky flail), all with live previews. Everything is cosmetic.
- **Collections:** own every item in a set (e.g. all ropes) to claim a gem bonus.
- **Gems:** the premium currency, earned for now from the daily bonus, daily challenges, collections and the Season Pass. They buy premium cosmetics, revives, the premium pass, and level skips.
- **Daily bonus:** a 7-day login calendar with coins and gems; missing a day restarts it.
- **Season Pass:** 7-week themed seasons (Pirate Plunder, Robo Rumble, Dino Days, Wizard Weeks) with 20 tiers of XP from finishing levels, dailies, Endless runs and logging in. The free track has coins, gems and an exclusive trail; the premium track (250 gems for now) has more, topped by an exclusive skin.
- **Ghost:** your best run on each level and daily is saved and replayed as a see-through ghost to race.
- **Google Play Games / Game Center** (free, hosted by Google and Apple, no server of our own): automatic sign-in; Daily Challenge (best time today) and Endless leaderboards in the platform's own UI, which also has friends and weekly/all-time tabs, with your rank after each run; 12 achievements; and cloud save (the progress is stored as a saved game and merged in on sign-in, so a new phone picks up where you left off). Switched on per platform in `lib/services/games_ids.dart`; see `docs/GAMES_SERVICES.md`. The game is fully playable without it.
- **Endless challenge codes:** share your course's code; a friend enters it from the menu to play the same course.
- **Golden Flop:** an exclusive skin for collecting all 300 stars.
- **Level skip:** after 5 attempts at a campaign level you can skip it for gems. It unlocks the next level but earns no stars.
- **Ads:** rewarded videos to revive at a checkpoint and to double coins. Interstitials only show when leaving a won level, at most every 3 wins and 2 minutes, never before level 8, and never after a fail. A "remove ads" flag is ready for when purchases exist.
- Menu with an attract-mode demo (the autopilot plays level 1), world and level select, shop, Season Pass, settings (music and SFX volume, mute, vibration, privacy options, reset).
- Generated sound effects and an upbeat but soft music loop per world (bouncy bass, off-beat plucks, a light groove; `tool/gen_audio.py`), plus haptics.

## Tech choices (the doc's open decisions)

| Decision | Choice | Why |
|---|---|---|
| Engine | **Flutter + Flame + Forge2D** | The owner already knows Flutter. Box2D physics, first-party plugins for ads, sharing and IAP, one codebase for both stores. |
| Rope | **Rope (max-distance) joint**, drawn as a sagging curve | Stable and tunable, and still looks floppy. The hand–anchor link can go slack, and the ragdoll limbs supply the floppiness. |
| Backend | **Google Play Games + Game Center** (`games_services` plugin) | Free and hosted by the platforms: no server or VPS to run. Leaderboards, friends and achievements use their native UI; progress is one JSON blob (`ProgressStore`) stored as a saved game and merged across devices. |
| Economy | `assets/config/economy.json` | 2 coins per coin picked up, +10 per finish, +15 per new star, skins 150–800, revive 60. |
| Art | Procedural vector drawing | No asset pipeline needed to test the fun. Skins are colour sets plus accessories in `lib/game/skins.dart`. |

### About the physics engine (important)

`forge2d` 0.15+ replaced its Dart engine with native Box2D v3 built through
native-asset hooks. That route is newer and riskier for mobile builds, so this
project uses the mature pure-Dart **forge2d 0.14.2+1**, **vendored in
`third_party/forge2d` with bug fixes**. Its revolute joint solved its mass
matrix wrongly, and a ragdoll exploded on its very first physics step. See
`third_party/forge2d/PATCHES.md`.

## Project layout

```
lib/
  game/            Pure game logic (no widgets)
    simulation.dart   Headless, deterministic physics sim: rope, hazards, pickups, style
    ragdoll.dart      Ragdoll body parts and joints
    level.dart        Level model / JSON format
    course_builder.dart  Segment-based course generator (campaign, daily, endless)
    cosmetics.dart    Ropes, trails, fail effects, dances, collections
    season.dart       Season Pass themes, tiers and rewards
    worlds.dart       World names, star gates, colours
    config.dart       Physics + economy config (loaded from JSON)
    game_controller.dart  Fixed-step loop, camera, phases, retry, replay, revive
    renderer.dart     Draws a frame (used for live play, replays and clip export)
    renderer_worlds.dart  World 2-5 themes, backdrops and mechanic art
    renderer_cosmetics.dart  Rope, trail and fail-effect styles
    autopilot.dart    Bot player (level verification + menu demo)
    skins.dart        Skin catalogue
    floppy_game.dart  Thin Flame wrapper
  services/        Progress/save, audio+haptics, ads (UMP consent), clip export, analytics,
                   games_service + games_ids (Play Games / Game Center)
  ui/              Screens and widgets
assets/
  config/physics.json   <- tune the feel here
  config/economy.json
  levels/level_XXX.json  1-15 hand-made, 16-100 generated
  daily/daily_XXX.json   Daily Challenge pool
  audio/, fonts/
android/.../VideoEncoderPlugin.kt   MediaCodec MP4 encoder for clips
ios/Runner/AppDelegate.swift        AVAssetWriter MP4 encoder for clips
docs/
  NEXT_STEPS.md      What's left
  RELEASING.md       Signing, stores
  GAMES_SERVICES.md  Setting up Play Games and Game Center
  privacy-policy.md  Draft privacy policy
  store/             Store listing copy and screenshots
tool/
  icon/               Renders the app icon and splash logo from the game
  screenshots/        Captures and frames store screenshots
  check_levels.dart   Proves every level is beatable (and can auto-place coins)
  swing_feel.dart     Measures how swinging feels to a human-like player
  gen_levels.dart     Generates levels 16-100 from a seed per level
  death_map.dart      Shows where the bot dies on a level
  gen_audio.py        Synthesises all sounds and music
```

## Running

```bash
flutter pub get
flutter run            # on a connected iPhone/Android device or simulator
flutter test           # physics, levels, economy, game services and UI tests
flutter analyze
```

iOS needs Xcode (deployment target 15.0) and Android needs the Android SDK
(minSdk 24). Both use the standard `flutter build ipa` / `flutter build appbundle`.

## Tuning the feel

All swing physics live in `assets/config/physics.json`: gravity, rope range
and reel-in, swing pump, release boost, knockback strength, bounce pad speed,
floppiness and more. Each field is documented in `lib/game/config.dart`. Hot
restart picks up changes.

After changing physics or levels, re-verify the levels:

```bash
dart run tool/swing_feel.dart              # how swings feel to a human-like player
dart run tool/check_levels.dart --fix      # make sure every level (and daily) can still
                                           # be three-starred, touching as little as possible
dart run tool/check_levels.dart            # search + write test/level_solutions.json
dart run tool/check_levels.dart --balance  # also re-place coins along a proven path
                                           # and reset each level's target time
flutter test test/levels_test.dart
```

`--fix` keeps each level's layout. It keeps the stored bot settings if they
still collect every coin inside the target time, else looks for new ones,
and only re-places a level's coins and target time when nothing else works.

Levels 16–100 come from `tool/gen_levels.dart`. It builds each level from
segments (gaps, saw corridors, glass walls, wind shafts, rocket gaps...) seeded
by the level id, with difficulty ramping through each world. It keeps a layout
only if the bot finishes it at least 3 ways and one of those runs actually uses
the world's mechanic; the coin trail then follows that run.

```bash
dart run tool/gen_levels.dart          # regenerate 16-100
dart run tool/gen_levels.dart 42 43    # just these ids
dart run tool/gen_levels.dart --daily  # regenerate the Daily Challenge pool
```

Regenerating overwrites hand edits to those files.

## Level format

Meters with **y pointing down**. Boxes are `[centerX, centerY, width, height, angleDeg?]`.

```json
{
  "id": 3, "name": "Pointy Bits", "targetTime": 12.5, "hint": "optional tutorial text",
  "start": [3.5, -2], "killY": 6,
  "finish": [59, -3, 5, 7],
  "platforms": [[3, 0, 5, 1]],
  "anchors": [[5, -8], [14, -8.5]],
  "spikes": [[9.5, 3, 2, 6]],
  "saws": [{"x": 18.5, "y": 0, "r": 1.2, "to": [18.5, -7], "period": 3.2}],
  "pads": [[24, 1.2, 3.5, 0.6, 15]],
  "coins": [[9.3, -1.9]],
  "checkpoints": [[50, 0.5]]
}
```

Worlds 2–5 add:

```json
{
  "anchors": [[5, -8], [9, -8, 15, -8, 3, 0.25]],
  "glass": [[20, -3, 0.4, 6]],
  "winds": [[30, 0, 3, 10, 0, 35]],
  "flips": [[40, -4, 5, 6]],
  "crumbles": [[50, 0, 4, 0.8]],
  "rockets": [{"x": 60, "y": 5, "angle": -90, "speed": 9, "period": 3, "phase": 0, "range": 22}]
}
```

- A moving anchor is `[x, y, toX, toY, periodSeconds, phase]` and ping-pongs between the two points.
- Winds are `[cx, cy, w, h, angleDeg, strength]`, where angle 0 blows up.
- Rocket angles are in degrees; -90 fires straight up.
- `"world": 3` themes a level outside the campaign (daily levels) like that world.

Rules the tests enforce: the first anchor must be reachable from the start
platform, and every checkpoint needs an anchor in reach, because revives spawn
there.

## Before releasing

See **`docs/RELEASING.md`**: set up Play Games and Game Center
(`docs/GAMES_SERVICES.md`), replace the AdMob test ids, set up signing (CI signs and builds a Play bundle when the upload key
secrets are set), and fill in the store listing (`docs/store/listing.md`)
and privacy policy (`docs/privacy-policy.md`).

All prices and rewards (coins, gems, login calendar, ad pacing) are in
`assets/config/economy.json`; cosmetic prices are in
`lib/game/cosmetics.dart` and Season Pass rewards in `lib/game/season.dart`.

## Not built (by choice)

Real-money purchases (gem packs, Starter Pack, "Remove ads", buying the
premium pass with money) and real ad accounts. See `docs/NEXT_STEPS.md`.
