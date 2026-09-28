# Leaderboards, achievements and cloud save

Floppy Swing uses the platforms' own free game services. There is no server
or VPS to run or pay for:

| | Android | iOS |
|---|---|---|
| Service | Google Play Games Services | Game Center |
| Cost | Free (with your Play Console account) | Free (with your Apple Developer account) |
| Sign-in | Automatic | Automatic (Game Center banner) |
| Leaderboards | Daily Challenge time, Endless score | same |
| Friends | Built into the Play Games leaderboard UI | Built into Game Center |
| Achievements | 12 (see `achievementTexts`) | same |
| Cloud save | Saved Games | Saved Games (iCloud) |

Code: `lib/services/games_service.dart` (logic) and
`lib/services/games_ids.dart` (your ids). Each platform stays switched off,
with its buttons hidden, until you set `enabled: true` there, so test builds
work before any of this is done.

## Android: Google Play Games

1. In Play Console, open your app, then **Grow users > Play Games Services >
   Setup and management > Configuration**. Choose "No, my game doesn't use
   Google APIs" and create the project.
2. **Credentials:** add an Android credential for package
   `com.floppyswing.floppy_swing` with the SHA-1 of your **app signing key**
   (Play Console > Test and release > App integrity) and, for sideloaded test
   builds, of your upload key too.
3. **Saved Games:** turn it on in the Play Games Services properties.
4. **Leaderboards:**
   - "Daily Challenge": format **Time** (milliseconds), ordering **Smaller is
     better**. The game shows its "today" tab.
   - "Endless": format **Numeric**, ordering **Larger is better**.
5. **Achievements:** create the 12 from `achievementTexts` in
   `lib/services/games_ids.dart` (title and description are there). An
   icon is required for each; the store screenshots or icon work.
6. Copy the ids:
   - the project id into `android/app/src/main/res/values/games-ids.xml`
     (`game_services_project_id`; Play Console's "Get resources" shows it);
   - the leaderboard and achievement ids (`CgkI...`) into `playGamesIds` in
     `lib/services/games_ids.dart`, and set `enabled: true`.
7. Add testers under Play Games Services > **Testers** until you publish the
   Play Games configuration (it has its own Publish button).

## iOS: Game Center

1. In Xcode, Runner target > **Signing & Capabilities** > add **Game Center**
   (and **iCloud** with iCloud Documents for Saved Games).
2. In App Store Connect, open the app > **Services > Game Center**:
   - Leaderboard **`daily_time`**: recurring, resets daily, format
     **Elapsed time - to the hundredth of a second**, sort **Low to High**.
   - Leaderboard **`endless_score`**: classic, format **Integer**, sort
     **High to Low**.
   - The 12 achievements with the ids in `gameCenterIds` (e.g.
     `first_swing`), 100 points spread however you like.
3. Set `enabled: true` in `gameCenterIds`. If you picked different ids, put
   them there.
4. Add the leaderboards and achievements to the app version before
   submitting ("Game Center" section of the version page).

## How it behaves

- On launch the game signs in quietly. On success it merges the cloud save
  into the local one (`ProgressStore.mergeFrom`: stars, records and owned
  items are combined, currencies take the higher value), uploads the result,
  posts your best Endless score and today's Daily time, and unlocks any
  achievements you've earned.
- After that, progress is saved to the cloud 10 seconds after it changes and
  whenever the app goes to the background.
- After a Daily clear or an Endless run the score is posted and your rank
  shown ("#12 today"). Tapping it opens the platform leaderboard.
- The menu's trophy and medal buttons and Settings open the leaderboards and
  achievements.
- If sign-in fails or is refused, the game keeps working offline; the
  buttons try signing in again.
