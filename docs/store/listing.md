# Store listing (draft)

Copy for App Store Connect and Google Play Console. Screenshots are in
`docs/store/screenshots/` (`ios_*` are 1290×2796 for the 6.9" iPhone slot,
`android_*` are 1080×1920). Regenerate them with
`flutter test tool/screenshots/store_screenshots_test.dart` then
`python3 tool/screenshots/frame.py`.

## Name

**Floppy Swing** (App Store name up to 30 characters, Play title up to 30)

## Subtitle (App Store, 30 characters)

Swing. Fly. Faceplant.

## Short description (Google Play, 80 characters)

One-thumb ragdoll swinging. Hold to grab, let go to fly, laugh at every fail.

## Promotional text (App Store, 170 characters)

New: leaderboards and achievements! Race the world in the Daily Challenge, collect all 300 stars for the Golden Flop skin.

## Description

Hold anywhere to fire your rope at the glowing ring. Let go to fly. That's
it - and it's harder than it looks.

Floppy Swing is a one-thumb physics game starring a gloriously floppy
ragdoll. Nail the timing and you'll soar through saw blades, smash through
glass and ride the wind. Miss it and you'll faceplant into a wall of spikes,
replayed in glorious slow motion.

- **100 levels in 5 worlds** - Playground, Factory, Glass City, Sky Islands
  and Rocket Base, each with a new twist: moving rings, breakable glass, wind
  fans, gravity flips, crumbling floors and rockets that knock you flying.
- **Instant retry** - fail and you're back in under half a second.
- **Slow-mo fail replays** - every crash is a highlight. Share the clip in one
  tap, ready for TikTok, Reels and Shorts.
- **Endless mode** - one course that never ends. How far can you go?
- **Daily Challenge** - a new level every day, with leaderboards and streaks.
- **Race your own ghost**, climb the Google Play Games / Game Center
  leaderboards and unlock achievements. Your progress is backed up to the
  cloud.
- **Challenge a friend** - send your Endless course code and see who swings
  further.
- **Look fabulous** - skins, rope styles, trails, fail effects and victory
  dances. Everything is cosmetic: no pay-to-win.
- **Season Pass** - themed seasons with free and premium reward tracks.

Free to play. Contains optional ads and optional in-app purchases (gems,
Starter Pack, No Ads, Premium Pass).

## Keywords (App Store, 100 characters)

ragdoll,swing,rope,physics,grapple,fail,funny,one tap,casual,arcade,stickman,parkour,obstacle

## Category

Games > Arcade (secondary: Games > Casual)

## Age rating

- Apple: 9+ (Infrequent/Mild Cartoon or Fantasy Violence). No user-generated
  content inside the game (clips are shared through the system share sheet).
- Google (IARC questionnaire): cartoon violence, no blood; no user
  interaction inside the game beyond Play Games leaderboards.
- Both stores: answer **yes** to "in-app purchases" and "contains ads".

## In-app products

Create these in Play Console (Monetize > Products > In-app products) and App
Store Connect (In-App Purchases) with exactly these product ids. Prices are
suggestions; the game shows whatever the store says.

| Product id | Type (Play / Apple) | Name | Grants | Price |
|---|---|---|---|---|
| `starter_pack` | one-time / Non-Consumable | Starter Pack | 300 gems, 2,500 coins, Laser rope | $2.99 |
| `remove_ads` | one-time / Non-Consumable | No Ads | no interstitial ads | $2.99 |
| `season_pass` | one-time, consumable / Consumable | Premium Pass | this season's premium track | $4.99 |
| `gems_small` | consumable / Consumable | Handful of Gems | 80 gems | $0.99 |
| `gems_medium` | consumable / Consumable | Bag of Gems | 450 gems | $4.99 |
| `gems_large` | consumable / Consumable | Chest of Gems | 1,000 gems | $9.99 |
| `gems_huge` | consumable / Consumable | Vault of Gems | 2,200 gems | $19.99 |

On Google Play every in-app product is a "one-time product"; the game consumes
the consumable ones itself. The catalogue is in `lib/game/store_products.dart`.

## What's new (first release)

Hello, world! Swing through 100 levels, the Daily Challenge and Endless mode,
then climb the leaderboards and hunt achievements.

## Contact and URLs

- Contact email (public): chris96skan@gmail.com
- Website: https://github.com/DionysisAth/floppy-swing
- Privacy policy URL: https://github.com/DionysisAth/floppy-swing/blob/main/docs/privacy-policy.md
