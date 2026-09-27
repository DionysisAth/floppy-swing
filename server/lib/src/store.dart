import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

/// Days since 1 Jan 2026 (UTC): the server's calendar for Daily boards and
/// Fail of the Week.
int serverDay(DateTime t) => t.toUtc().difference(DateTime.utc(2026)).inDays;

/// Fail of the Week runs Monday..Sunday-ish blocks of 7 server days.
int serverWeek(DateTime t) => serverDay(t) ~/ 7;

class Player {
  const Player(this.id, this.name, this.friendCode);
  final int id;
  final String name;
  final String friendCode;

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'friendCode': friendCode};
}

class LeaderboardEntry {
  const LeaderboardEntry(this.rank, this.playerId, this.name, this.value);
  final int rank;
  final int playerId;
  final String name;
  final double value;
}

class FailEntry {
  const FailEntry(this.id, this.playerId, this.name, this.caption, this.votes, this.week, this.featured);
  final int id;
  final int playerId;
  final String name;
  final String caption;
  final int votes;
  final int week;
  final bool featured;
}

/// All persistent state, in one SQLite database.
class Store {
  Store(this.db, {Random? random}) : _random = random ?? Random.secure() {
    _migrate();
  }

  factory Store.open(String path) => Store(sqlite3.open(path));
  factory Store.memory({Random? random}) => Store(sqlite3.openInMemory(), random: random);

  final Database db;
  final Random _random;

  void _migrate() {
    db.execute('PRAGMA journal_mode=WAL');
    db.execute('PRAGMA foreign_keys=ON');
    db.execute('''
      CREATE TABLE IF NOT EXISTS players(
        id INTEGER PRIMARY KEY AUTOINCREMENT, token TEXT UNIQUE NOT NULL, name TEXT NOT NULL,
        friend_code TEXT UNIQUE NOT NULL, created_at INTEGER NOT NULL, last_seen INTEGER NOT NULL);
      CREATE TABLE IF NOT EXISTS transfer_codes(
        code TEXT PRIMARY KEY, player_id INTEGER NOT NULL REFERENCES players(id), expires_at INTEGER NOT NULL);
      CREATE TABLE IF NOT EXISTS scores(
        board TEXT NOT NULL, player_id INTEGER NOT NULL REFERENCES players(id), value REAL NOT NULL,
        updated_at INTEGER NOT NULL, PRIMARY KEY(board, player_id));
      CREATE INDEX IF NOT EXISTS scores_board ON scores(board, value);
      CREATE TABLE IF NOT EXISTS saves(
        player_id INTEGER PRIMARY KEY REFERENCES players(id), data TEXT NOT NULL,
        revision INTEGER NOT NULL, updated_at INTEGER NOT NULL);
      CREATE TABLE IF NOT EXISTS friends(
        player_id INTEGER NOT NULL REFERENCES players(id), friend_id INTEGER NOT NULL REFERENCES players(id),
        PRIMARY KEY(player_id, friend_id));
      CREATE TABLE IF NOT EXISTS ghosts(
        key TEXT NOT NULL, player_id INTEGER NOT NULL REFERENCES players(id), time REAL NOT NULL,
        data BLOB NOT NULL, updated_at INTEGER NOT NULL, PRIMARY KEY(key, player_id));
      CREATE TABLE IF NOT EXISTS fails(
        id INTEGER PRIMARY KEY, player_id INTEGER NOT NULL REFERENCES players(id), week INTEGER NOT NULL,
        caption TEXT NOT NULL, created_at INTEGER NOT NULL,
        hidden INTEGER NOT NULL DEFAULT 0, featured INTEGER NOT NULL DEFAULT 0);
      CREATE INDEX IF NOT EXISTS fails_week ON fails(week);
      CREATE TABLE IF NOT EXISTS votes(
        fail_id INTEGER NOT NULL REFERENCES fails(id), player_id INTEGER NOT NULL REFERENCES players(id),
        PRIMARY KEY(fail_id, player_id));
      CREATE TABLE IF NOT EXISTS reports(
        fail_id INTEGER NOT NULL REFERENCES fails(id), player_id INTEGER NOT NULL REFERENCES players(id),
        PRIMARY KEY(fail_id, player_id));
      CREATE TABLE IF NOT EXISTS rewards(
        id INTEGER PRIMARY KEY, player_id INTEGER NOT NULL REFERENCES players(id), reason TEXT NOT NULL,
        payload TEXT NOT NULL, created_at INTEGER NOT NULL, claimed INTEGER NOT NULL DEFAULT 0);
      CREATE TABLE IF NOT EXISTS events(
        id INTEGER PRIMARY KEY, player_id INTEGER NOT NULL, name TEXT NOT NULL, params TEXT NOT NULL,
        day INTEGER NOT NULL, at INTEGER NOT NULL);
      CREATE INDEX IF NOT EXISTS events_name ON events(name);
    ''');
  }

  // --------------------------------------------------------------- players

  static const _codeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  String _code(int length) => List.generate(length, (_) => _codeAlphabet[_random.nextInt(_codeAlphabet.length)]).join();

  String _token() => List.generate(32, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();

  /// Keeps names short, printable and free of markup.
  static String? cleanName(String raw) {
    final name = raw.replaceAll(RegExp(r'[^A-Za-z0-9 _\-.]'), '').trim().replaceAll(RegExp(r'\s+'), ' ');
    return name.length < 3 || name.length > 16 ? null : name;
  }

  ({Player player, String token}) createPlayer(String? name, DateTime now) {
    final token = _token();
    final clean = name == null ? null : cleanName(name);
    final display = clean ?? 'Flopper${1000 + _random.nextInt(9000)}';
    for (;;) {
      final code = _code(6);
      try {
        db.execute(
          'INSERT INTO players(token, name, friend_code, created_at, last_seen) VALUES (?, ?, ?, ?, ?)',
          [token, display, code, now.millisecondsSinceEpoch, now.millisecondsSinceEpoch],
        );
        return (player: Player(db.lastInsertRowId, display, code), token: token);
      } on SqliteException catch (e) {
        if (!e.message.contains('UNIQUE')) rethrow;
      }
    }
  }

  Player? playerByToken(String token, DateTime now) {
    final rows = db.select('SELECT id, name, friend_code FROM players WHERE token = ?', [token]);
    if (rows.isEmpty) return null;
    final r = rows.first;
    db.execute('UPDATE players SET last_seen = ? WHERE id = ?', [now.millisecondsSinceEpoch, r['id']]);
    return Player(r['id'] as int, r['name'] as String, r['friend_code'] as String);
  }

  Player? playerById(int id) {
    final rows = db.select('SELECT id, name, friend_code FROM players WHERE id = ?', [id]);
    if (rows.isEmpty) return null;
    final r = rows.first;
    return Player(r['id'] as int, r['name'] as String, r['friend_code'] as String);
  }

  bool rename(int playerId, String name) {
    final clean = cleanName(name);
    if (clean == null) return false;
    db.execute('UPDATE players SET name = ? WHERE id = ?', [clean, playerId]);
    return true;
  }

  /// A one-time code (valid a day) that signs another device into this account.
  String transferCode(int playerId, DateTime now) {
    db.execute('DELETE FROM transfer_codes WHERE player_id = ? OR expires_at < ?', [playerId, now.millisecondsSinceEpoch]);
    final code = _code(8);
    db.execute('INSERT INTO transfer_codes VALUES (?, ?, ?)', [
      code,
      playerId,
      now.add(const Duration(days: 1)).millisecondsSinceEpoch,
    ]);
    return code;
  }

  /// Redeems a transfer code: returns the account's token (and player).
  ({Player player, String token})? redeemTransfer(String code, DateTime now) {
    final rows = db.select(
      'SELECT player_id FROM transfer_codes WHERE code = ? AND expires_at >= ?',
      [code.toUpperCase().trim(), now.millisecondsSinceEpoch],
    );
    if (rows.isEmpty) return null;
    final id = rows.first['player_id'] as int;
    db.execute('DELETE FROM transfer_codes WHERE code = ?', [code.toUpperCase().trim()]);
    final token = db.select('SELECT token FROM players WHERE id = ?', [id]).first['token'] as String;
    return (player: playerById(id)!, token: token);
  }

  /// Deletes a player and everything about them. Returns their clip ids so
  /// the caller can remove the files.
  List<int> deletePlayer(int playerId) {
    final clips = [for (final r in db.select('SELECT id FROM fails WHERE player_id = ?', [playerId])) r['id'] as int];
    db.execute('BEGIN');
    try {
      for (final id in clips) {
        db.execute('DELETE FROM votes WHERE fail_id = ?', [id]);
        db.execute('DELETE FROM reports WHERE fail_id = ?', [id]);
      }
      for (final sql in [
        'DELETE FROM fails WHERE player_id = ?',
        'DELETE FROM votes WHERE player_id = ?',
        'DELETE FROM reports WHERE player_id = ?',
        'DELETE FROM scores WHERE player_id = ?',
        'DELETE FROM saves WHERE player_id = ?',
        'DELETE FROM ghosts WHERE player_id = ?',
        'DELETE FROM rewards WHERE player_id = ?',
        'DELETE FROM events WHERE player_id = ?',
        'DELETE FROM transfer_codes WHERE player_id = ?',
      ]) {
        db.execute(sql, [playerId]);
      }
      db.execute('DELETE FROM friends WHERE player_id = ? OR friend_id = ?', [playerId, playerId]);
      db.execute('DELETE FROM players WHERE id = ?', [playerId]);
      db.execute('COMMIT');
    } catch (_) {
      db.execute('ROLLBACK');
      rethrow;
    }
    return clips;
  }

  // ----------------------------------------------------------- leaderboards

  /// Daily boards rank the lowest time; everything else the highest score.
  static bool lowerIsBetter(String board) => board.startsWith('daily-');

  /// Keeps the player's best. Returns true if it improved.
  bool submitScore(String board, int playerId, double value, DateTime now) {
    final low = lowerIsBetter(board);
    final rows = db.select('SELECT value FROM scores WHERE board = ? AND player_id = ?', [board, playerId]);
    if (rows.isNotEmpty) {
      final old = (rows.first['value'] as num).toDouble();
      if (low ? value >= old : value <= old) return false;
    }
    db.execute(
      'INSERT OR REPLACE INTO scores(board, player_id, value, updated_at) VALUES (?, ?, ?, ?)',
      [board, playerId, value, now.millisecondsSinceEpoch],
    );
    return true;
  }

  /// Top [limit] entries, optionally only [playerId] and their friends.
  List<LeaderboardEntry> leaderboard(String board, {int limit = 50, int? friendsOf}) {
    final order = lowerIsBetter(board) ? 'ASC' : 'DESC';
    final filter = friendsOf == null
        ? ''
        : 'AND (s.player_id = $friendsOf OR s.player_id IN (SELECT friend_id FROM friends WHERE player_id = $friendsOf))';
    final rows = db.select(
      'SELECT s.player_id, p.name, s.value FROM scores s JOIN players p ON p.id = s.player_id '
      'WHERE s.board = ? $filter ORDER BY s.value $order, s.updated_at ASC LIMIT ?',
      [board, limit],
    );
    var rank = 0;
    return [
      for (final r in rows) LeaderboardEntry(++rank, r['player_id'] as int, r['name'] as String, (r['value'] as num).toDouble()),
    ];
  }

  /// The player's rank on [board] (1 = best), or null without a score.
  ({int rank, double value})? rankOf(String board, int playerId) {
    final rows = db.select('SELECT value, updated_at FROM scores WHERE board = ? AND player_id = ?', [board, playerId]);
    if (rows.isEmpty) return null;
    final value = (rows.first['value'] as num).toDouble();
    final at = rows.first['updated_at'] as int;
    final cmp = lowerIsBetter(board) ? '<' : '>';
    final better = db.select(
      'SELECT COUNT(*) n FROM scores WHERE board = ? AND (value $cmp ? OR (value = ? AND updated_at < ?))',
      [board, value, value, at],
    ).first['n'] as int;
    return (rank: better + 1, value: value);
  }

  int boardSize(String board) =>
      db.select('SELECT COUNT(*) n FROM scores WHERE board = ?', [board]).first['n'] as int;

  // ------------------------------------------------------------------ saves

  ({String data, int revision})? loadSave(int playerId) {
    final rows = db.select('SELECT data, revision FROM saves WHERE player_id = ?', [playerId]);
    if (rows.isEmpty) return null;
    return (data: rows.first['data'] as String, revision: rows.first['revision'] as int);
  }

  /// Stores [data] if [baseRevision] matches the stored one (optimistic
  /// locking). Returns the new revision, or null on a conflict.
  int? storeSave(int playerId, String data, int baseRevision, DateTime now) {
    final current = loadSave(playerId)?.revision ?? 0;
    if (baseRevision != current) return null;
    final next = current + 1;
    db.execute(
      'INSERT OR REPLACE INTO saves(player_id, data, revision, updated_at) VALUES (?, ?, ?, ?)',
      [playerId, data, next, now.millisecondsSinceEpoch],
    );
    return next;
  }

  // ---------------------------------------------------------------- friends

  /// Adds a two-way friendship by friend code. Returns the friend.
  Player? addFriend(int playerId, String friendCode) {
    final rows = db.select('SELECT id FROM players WHERE friend_code = ?', [friendCode.toUpperCase().trim()]);
    if (rows.isEmpty) return null;
    final friendId = rows.first['id'] as int;
    if (friendId == playerId) return null;
    db.execute('INSERT OR IGNORE INTO friends VALUES (?, ?)', [playerId, friendId]);
    db.execute('INSERT OR IGNORE INTO friends VALUES (?, ?)', [friendId, playerId]);
    return playerById(friendId);
  }

  void removeFriend(int playerId, int friendId) {
    db.execute('DELETE FROM friends WHERE (player_id = ? AND friend_id = ?) OR (player_id = ? AND friend_id = ?)', [
      playerId,
      friendId,
      friendId,
      playerId,
    ]);
  }

  List<Player> friendsOf(int playerId) => [
    for (final r in db.select(
      'SELECT p.id, p.name, p.friend_code FROM friends f JOIN players p ON p.id = f.friend_id '
      'WHERE f.player_id = ? ORDER BY p.name',
      [playerId],
    ))
      Player(r['id'] as int, r['name'] as String, r['friend_code'] as String),
  ];

  // ----------------------------------------------------------------- ghosts

  /// Stores a best-run ghost if it's faster than the stored one.
  bool storeGhost(String key, int playerId, double time, Uint8List data, DateTime now) {
    final rows = db.select('SELECT time FROM ghosts WHERE key = ? AND player_id = ?', [key, playerId]);
    if (rows.isNotEmpty && (rows.first['time'] as num).toDouble() <= time) return false;
    db.execute(
      'INSERT OR REPLACE INTO ghosts(key, player_id, time, data, updated_at) VALUES (?, ?, ?, ?, ?)',
      [key, playerId, time, data, now.millisecondsSinceEpoch],
    );
    return true;
  }

  /// Friends' ghosts for [key], fastest first.
  List<({int playerId, String name, double time, Uint8List data})> friendGhosts(String key, int playerId, {int limit = 3}) => [
    for (final r in db.select(
      'SELECT g.player_id, p.name, g.time, g.data FROM ghosts g JOIN players p ON p.id = g.player_id '
      'WHERE g.key = ? AND g.player_id IN (SELECT friend_id FROM friends WHERE player_id = ?) '
      'ORDER BY g.time ASC LIMIT ?',
      [key, playerId, limit],
    ))
      (
        playerId: r['player_id'] as int,
        name: r['name'] as String,
        time: (r['time'] as num).toDouble(),
        data: r['data'] as Uint8List,
      ),
  ];

  // ---------------------------------------------------------- fail of week

  static const maxFailsPerWeek = 3;
  static const reportsToHide = 3;

  /// Registers a clip; the caller stores the file under the returned id.
  int? createFail(int playerId, String caption, DateTime now) {
    final week = serverWeek(now);
    final count = db.select('SELECT COUNT(*) n FROM fails WHERE player_id = ? AND week = ?', [playerId, week]).first['n'] as int;
    if (count >= maxFailsPerWeek) return null;
    final text = caption.replaceAll(RegExp(r'[\u0000-\u001f<>]'), '').trim();
    db.execute('INSERT INTO fails(player_id, week, caption, created_at) VALUES (?, ?, ?, ?)', [
      playerId,
      week,
      text.length > 80 ? text.substring(0, 80) : text,
      now.millisecondsSinceEpoch,
    ]);
    return db.lastInsertRowId;
  }

  void deleteFail(int id) {
    db.execute('DELETE FROM votes WHERE fail_id = ?', [id]);
    db.execute('DELETE FROM reports WHERE fail_id = ?', [id]);
    db.execute('DELETE FROM fails WHERE id = ?', [id]);
  }

  List<FailEntry> fails({required int week, bool includeHidden = false}) => [
    for (final r in db.select(
      'SELECT f.id, f.player_id, p.name, f.caption, f.week, f.featured, '
      '(SELECT COUNT(*) FROM votes v WHERE v.fail_id = f.id) votes '
      'FROM fails f JOIN players p ON p.id = f.player_id '
      'WHERE f.week = ? ${includeHidden ? '' : 'AND f.hidden = 0'} ORDER BY votes DESC, f.created_at ASC',
      [week],
    ))
      FailEntry(
        r['id'] as int,
        r['player_id'] as int,
        r['name'] as String,
        r['caption'] as String,
        r['votes'] as int,
        r['week'] as int,
        (r['featured'] as int) == 1,
      ),
  ];

  bool failVisible(int id) =>
      db.select('SELECT 1 FROM fails WHERE id = ? AND hidden = 0', [id]).isNotEmpty;

  /// One vote per player per clip, only for the current week's clips.
  bool vote(int failId, int playerId, DateTime now) {
    final rows = db.select('SELECT week, player_id FROM fails WHERE id = ? AND hidden = 0', [failId]);
    if (rows.isEmpty || rows.first['week'] != serverWeek(now) || rows.first['player_id'] == playerId) return false;
    db.execute('INSERT OR IGNORE INTO votes VALUES (?, ?)', [failId, playerId]);
    return db.updatedRows > 0;
  }

  /// Players can flag clips; enough flags hide one until a moderator looks.
  void report(int failId, int playerId) {
    db.execute('INSERT OR IGNORE INTO reports VALUES (?, ?)', [failId, playerId]);
    final n = db.select('SELECT COUNT(*) n FROM reports WHERE fail_id = ?', [failId]).first['n'] as int;
    if (n >= reportsToHide) setHidden(failId, true);
  }

  void setHidden(int failId, bool hidden) =>
      db.execute('UPDATE fails SET hidden = ? WHERE id = ?', [hidden ? 1 : 0, failId]);

  /// The featured clip of [week]: a moderator's pick, else (once the week is
  /// over) the most voted one. Picking a winner rewards its player once.
  FailEntry? featured(int week, DateTime now) {
    final picked = fails(week: week).where((f) => f.featured).toList();
    if (picked.isNotEmpty) return picked.first;
    if (week >= serverWeek(now)) return null;
    final entries = fails(week: week);
    if (entries.isEmpty) return null;
    feature(entries.first.id, now);
    return fails(week: week).firstWhere((f) => f.featured);
  }

  /// Makes [failId] its week's winner and rewards the player.
  void feature(int failId, DateTime now) {
    final rows = db.select('SELECT week, player_id, featured FROM fails WHERE id = ?', [failId]);
    if (rows.isEmpty) return;
    final week = rows.first['week'] as int;
    db.execute('UPDATE fails SET featured = 0 WHERE week = ?', [week]);
    db.execute('UPDATE fails SET featured = 1, hidden = 0 WHERE id = ?', [failId]);
    final playerId = rows.first['player_id'] as int;
    final reason = 'fail-of-week-$week';
    final already = db.select('SELECT 1 FROM rewards WHERE reason = ?', [reason]).isNotEmpty;
    if (!already) grant(playerId, reason, {'gems': 50, 'item': 'golden'}, now);
  }

  // ---------------------------------------------------------------- rewards

  void grant(int playerId, String reason, Map<String, Object?> payload, DateTime now) {
    db.execute('INSERT INTO rewards(player_id, reason, payload, created_at) VALUES (?, ?, ?, ?)', [
      playerId,
      reason,
      jsonEncode(payload),
      now.millisecondsSinceEpoch,
    ]);
  }

  List<({int id, String reason, Map<String, Object?> payload})> pendingRewards(int playerId) => [
    for (final r in db.select('SELECT id, reason, payload FROM rewards WHERE player_id = ? AND claimed = 0', [playerId]))
      (id: r['id'] as int, reason: r['reason'] as String, payload: jsonDecode(r['payload'] as String) as Map<String, Object?>),
  ];

  Map<String, Object?>? claimReward(int id, int playerId) {
    final rows = db.select('SELECT payload FROM rewards WHERE id = ? AND player_id = ? AND claimed = 0', [id, playerId]);
    if (rows.isEmpty) return null;
    db.execute('UPDATE rewards SET claimed = 1 WHERE id = ?', [id]);
    return jsonDecode(rows.first['payload'] as String) as Map<String, Object?>;
  }

  // -------------------------------------------------------------- analytics

  void logEvents(int playerId, List<({String name, Map<String, Object?> params, DateTime at})> events) {
    final stmt = db.prepare('INSERT INTO events(player_id, name, params, day, at) VALUES (?, ?, ?, ?, ?)');
    try {
      db.execute('BEGIN');
      for (final e in events) {
        stmt.execute([playerId, e.name, jsonEncode(e.params), serverDay(e.at), e.at.millisecondsSinceEpoch]);
      }
      db.execute('COMMIT');
    } catch (_) {
      db.execute('ROLLBACK');
      rethrow;
    } finally {
      stmt.dispose();
    }
  }

  /// Numbers for tuning: players, retention, and a per-level funnel that
  /// shows which levels are too hard.
  Map<String, Object?> stats(DateTime now) {
    final today = serverDay(now);
    int count(String sql, [List<Object?> args = const []]) => db.select(sql, args).first['n'] as int;
    double retention(int dayN) {
      // Players who joined at least dayN days ago and were active dayN days after joining.
      final cohort = db.select(
        'SELECT p.id, CAST((p.created_at / 86400000) AS INTEGER) joined FROM players p WHERE p.created_at <= ?',
        [now.subtract(Duration(days: dayN)).millisecondsSinceEpoch],
      );
      if (cohort.isEmpty) return 0;
      var back = 0;
      for (final r in cohort) {
        final joined = serverDay(DateTime.fromMillisecondsSinceEpoch((r['joined'] as int) * 86400000, isUtc: true));
        final seen = db.select('SELECT 1 FROM events WHERE player_id = ? AND day = ? LIMIT 1', [r['id'], joined + dayN]);
        if (seen.isNotEmpty) back++;
      }
      return back / cohort.length;
    }

    final levels = <String, Map<String, Object?>>{};
    for (final r in db.select(
      "SELECT json_extract(params, '\$.level') level, name, COUNT(*) n FROM events "
      "WHERE name IN ('level_start', 'level_fail', 'level_complete', 'level_skipped') GROUP BY level, name",
    )) {
      final level = '${r['level']}';
      final entry = levels.putIfAbsent(level, () => {'starts': 0, 'fails': 0, 'completes': 0, 'skips': 0});
      final key = switch (r['name']) {
        'level_start' => 'starts',
        'level_fail' => 'fails',
        'level_complete' => 'completes',
        _ => 'skips',
      };
      entry[key] = r['n'];
    }
    for (final e in levels.values) {
      final starts = e['starts'] as int;
      e['completionRate'] = starts == 0 ? null : (e['completes'] as int) / starts;
    }
    final causes = <String, int>{
      for (final r in db.select(
        "SELECT json_extract(params, '\$.cause') cause, COUNT(*) n FROM events WHERE name = 'level_fail' GROUP BY cause",
      ))
        '${r['cause']}': r['n'] as int,
    };
    return {
      'players': count('SELECT COUNT(*) n FROM players'),
      'activeToday': count('SELECT COUNT(DISTINCT player_id) n FROM events WHERE day = ?', [today]),
      'retentionD1': retention(1),
      'retentionD7': retention(7),
      'levels': levels,
      'deathCauses': causes,
      'clipsShared': count("SELECT COUNT(*) n FROM events WHERE name = 'clip_shared'"),
      'failSubmissionsThisWeek': count('SELECT COUNT(*) n FROM fails WHERE week = ?', [serverWeek(now)]),
    };
  }

  void close() => db.dispose();
}
