# Floppy Swing game server

A small Dart server (shelf + SQLite) behind the game's online features:

- anonymous player accounts (bearer tokens), display names;
- leaderboards: `daily-<day>` (lowest time) and `endless` (highest score);
- cloud saves with revisions, and one-time codes to move to a new phone;
- two-way friends by friend code, and best-run ghosts shared with friends;
- Fail of the Week: clip upload (MP4, max 8 MB, 3 per player per week),
  voting, reporting (3 reports hide a clip), weekly winner with a reward
  (50 gems + the Golden Flop skin), moderation;
- server-side rewards the game claims on startup;
- analytics events and an admin stats endpoint (per-level funnel, death
  causes, D1/D7 retention);
- account deletion (`DELETE /v1/me`), as the App Store requires.

Everything lives in one SQLite file plus a folder of clips under `DATA_DIR`.

## Run it

```bash
cd server
dart pub get
dart test                                   # the API tests
DATA_DIR=data ADMIN_TOKEN=change-me dart run bin/server.dart
```

Or with Docker:

```bash
docker build -t floppy-server server/
docker run -p 8080:8080 -v floppy-data:/data -e ADMIN_TOKEN=change-me floppy-server
```

| Env var | Default | |
|---|---|---|
| `PORT` | 8080 | Listen port |
| `DATA_DIR` | `data` (`/data` in Docker) | Database and uploaded clips. Put it on a persistent volume. |
| `ADMIN_TOKEN` | unset | Enables `/v1/admin/*`. Use a long random string. |

## Deploy

Any host that runs a Docker container with a persistent disk works, for
example Fly.io (`fly launch` in `server/`, then `fly volumes create data` and
mount it at `/data`), Render (a Docker web service with a disk at `/data`),
or a small VPS. Serve it over **HTTPS**: Android and iOS block plain HTTP by
default.

Then point the app at it:

- **CI builds:** set the repository variable `FLOPPY_SERVER_URL` (GitHub >
  Settings > Secrets and variables > Actions > Variables) to e.g.
  `https://floppy.example.com`. The workflow passes it to
  `--dart-define=FLOPPY_SERVER=...`.
- **Local builds:** `flutter run --dart-define=FLOPPY_SERVER=https://...`.
- **Testing:** players can also set a server in Settings > Online.

## Moderation and stats

```bash
TOKEN=change-me
curl -H "Authorization: Bearer $TOKEN" https://SERVER/v1/admin/stats
curl -H "Authorization: Bearer $TOKEN" https://SERVER/v1/admin/fails          # this week, incl. hidden
curl -X POST -H "Authorization: Bearer $TOKEN" https://SERVER/v1/admin/fails/42/hide     # or unhide, feature, delete
```

A week's winner is picked automatically once the week is over (most votes;
`feature` overrides it).

## Backups

Copy `floppy.db` (use `sqlite3 floppy.db ".backup backup.db"` while running)
and the `fails/` folder.

## Scaling notes

SQLite comfortably handles a soft launch. The retention stat walks the
players table, so for a large player base move it to a scheduled job. There is
no rate limiting beyond the per-week clip limit; put the server behind a proxy
with rate limits (e.g. Cloudflare) before a big launch.
