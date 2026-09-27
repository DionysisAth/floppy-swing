import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'store.dart';

/// Largest Fail of the Week clip accepted (the app exports ~2-4 MB).
const maxClipBytes = 8 * 1024 * 1024;

/// Largest ghost accepted (a minute at 15 Hz is ~15 KB).
const maxGhostBytes = 64 * 1024;

/// Builds the HTTP API.
///
/// Players authenticate with the bearer token they got when registering.
/// Admin routes need [adminToken] (disabled when null).
Handler buildHandler(
  Store store, {
  required Directory mediaDir,
  String? adminToken,
  DateTime Function() clock = DateTime.now,
}) {
  final router = Router();
  final clips = Directory('${mediaDir.path}/fails')..createSync(recursive: true);
  File clipFile(int id) => File('${clips.path}/$id.mp4');

  Response json(Object? body, {int status = 200}) =>
      Response(status, body: jsonEncode(body), headers: {'content-type': 'application/json'});
  Response error(int status, String message) => json({'error': message}, status: status);

  Future<Map<String, Object?>> body(Request r) async {
    final text = await r.readAsString();
    if (text.isEmpty) return {};
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, Object?>) throw const FormatException('expected a JSON object');
    return decoded;
  }

  String? bearer(Request r) {
    final h = r.headers['authorization'];
    return h != null && h.startsWith('Bearer ') ? h.substring(7).trim() : null;
  }

  // Wraps a handler that needs a signed-in player.
  Handler authed(FutureOr<Response> Function(Request r, Player me) inner) => (r) async {
    final token = bearer(r);
    final me = token == null ? null : store.playerByToken(token, clock());
    if (me == null) return error(401, 'sign in first');
    return inner(r, me);
  };

  Handler admin(FutureOr<Response> Function(Request r) inner) => (r) async {
    if (adminToken == null || bearer(r) != adminToken) return error(403, 'admin only');
    return inner(r);
  };

  Map<String, Object?> failJson(FailEntry f, {int? me}) => {
    'id': f.id,
    'name': f.name,
    'caption': f.caption,
    'votes': f.votes,
    'week': f.week,
    'featured': f.featured,
    'mine': me == f.playerId,
    'url': '/v1/media/fails/${f.id}.mp4',
  };

  // ------------------------------------------------------------- players

  router.get('/healthz', (Request r) => Response.ok('ok'));

  router.post('/v1/players', (Request r) async {
    final b = await body(r);
    final created = store.createPlayer(b['name'] as String?, clock());
    return json({'player': created.player.toJson(), 'token': created.token});
  });

  router.get('/v1/me', authed((r, me) => json({'player': me.toJson()})));

  router.patch('/v1/me', authed((r, me) async {
    final name = (await body(r))['name'];
    if (name is! String || !store.rename(me.id, name)) return error(400, 'names are 3-16 letters or digits');
    return json({'player': store.playerById(me.id)!.toJson()});
  }));

  // Account deletion (required by the App Store for apps that make accounts).
  router.delete('/v1/me', authed((r, me) {
    for (final id in store.deletePlayer(me.id)) {
      final f = clipFile(id);
      if (f.existsSync()) f.deleteSync();
    }
    return json({'deleted': true});
  }));

  router.post('/v1/me/transfer', authed((r, me) => json({'code': store.transferCode(me.id, clock()), 'validHours': 24})));

  router.post('/v1/transfer', (Request r) async {
    final code = (await body(r))['code'];
    final result = code is String ? store.redeemTransfer(code, clock()) : null;
    if (result == null) return error(404, 'that code is wrong or expired');
    return json({'player': result.player.toJson(), 'token': result.token});
  });

  // -------------------------------------------------------- leaderboards

  String? checkScore(String board, num value) {
    final now = clock();
    if (board == 'endless') return value >= 0 && value <= 200000 ? null : 'score out of range';
    final daily = RegExp(r'^daily-(\d+)$').firstMatch(board);
    if (daily != null) {
      final day = int.parse(daily.group(1)!);
      // Allow a day either side for time zones.
      if ((day - serverDay(now)).abs() > 1) return 'that daily is closed';
      return value >= 2 && value <= 600 ? null : 'time out of range';
    }
    return 'unknown board';
  }

  router.post('/v1/scores', authed((r, me) async {
    final b = await body(r);
    final board = b['board'], value = b['value'];
    if (board is! String || value is! num) return error(400, 'board and value required');
    final problem = checkScore(board, value);
    if (problem != null) return error(400, problem);
    final improved = store.submitScore(board, me.id, value.toDouble(), clock());
    final rank = store.rankOf(board, me.id)!;
    return json({'improved': improved, 'rank': rank.rank, 'best': rank.value, 'total': store.boardSize(board)});
  }));

  router.get('/v1/leaderboards/<board>', (Request r, String board) async {
    final token = bearer(r);
    final me = token == null ? null : store.playerByToken(token, clock());
    final friends = r.url.queryParameters['friends'] == '1';
    if (friends && me == null) return error(401, 'sign in first');
    final limit = (int.tryParse(r.url.queryParameters['limit'] ?? '') ?? 50).clamp(1, 100);
    final entries = store.leaderboard(board, limit: limit, friendsOf: friends ? me!.id : null);
    final mine = me == null ? null : store.rankOf(board, me.id);
    return json({
      'board': board,
      'total': store.boardSize(board),
      'entries': [
        for (final e in entries) {'rank': e.rank, 'name': e.name, 'value': e.value, 'me': e.playerId == me?.id},
      ],
      'me': mine == null ? null : {'rank': mine.rank, 'value': mine.value},
    });
  });

  // ---------------------------------------------------------- cloud save

  router.get('/v1/save', authed((r, me) {
    final save = store.loadSave(me.id);
    if (save == null) return error(404, 'no save yet');
    return json({'data': jsonDecode(save.data), 'revision': save.revision});
  }));

  router.put('/v1/save', authed((r, me) async {
    final b = await body(r);
    final data = b['data'], base = b['baseRevision'];
    if (data is! Map || base is! int) return error(400, 'data and baseRevision required');
    final encoded = jsonEncode(data);
    if (encoded.length > 512 * 1024) return error(413, 'save too big');
    final revision = store.storeSave(me.id, encoded, base, clock());
    if (revision == null) {
      final current = store.loadSave(me.id)!;
      return json({'error': 'conflict', 'data': jsonDecode(current.data), 'revision': current.revision}, status: 409);
    }
    return json({'revision': revision});
  }));

  // ------------------------------------------------------------- friends

  router.get('/v1/friends', authed((r, me) => json({
    'friends': [for (final f in store.friendsOf(me.id)) {'id': f.id, 'name': f.name}],
  })));

  router.post('/v1/friends', authed((r, me) async {
    final code = (await body(r))['code'];
    final friend = code is String ? store.addFriend(me.id, code) : null;
    if (friend == null) return error(404, 'no player with that code');
    return json({'friend': {'id': friend.id, 'name': friend.name}});
  }));

  router.delete('/v1/friends/<id|[0-9]+>', (Request r, String id) {
    return authed((r, me) {
      store.removeFriend(me.id, int.parse(id));
      return json({'ok': true});
    })(r);
  });

  // -------------------------------------------------------------- ghosts

  final ghostKey = RegExp(r'^(L\d{1,3}|D\d{1,6})$');

  router.put('/v1/ghosts/<key>', (Request r, String key) {
    return authed((r, me) async {
      if (!ghostKey.hasMatch(key)) return error(400, 'bad ghost key');
      final b = await body(r);
      final time = b['time'], data = b['data'];
      if (time is! num || data is! String) return error(400, 'time and data required');
      final bytes = base64Decode(data);
      if (bytes.isEmpty || bytes.length > maxGhostBytes || bytes.length % 16 != 0) return error(400, 'bad ghost');
      return json({'stored': store.storeGhost(key, me.id, time.toDouble(), bytes, clock())});
    })(r);
  });

  router.get('/v1/ghosts/<key>', (Request r, String key) {
    return authed((r, me) {
      if (!ghostKey.hasMatch(key)) return error(400, 'bad ghost key');
      return json({
        'ghosts': [
          for (final g in store.friendGhosts(key, me.id))
            {'name': g.name, 'time': g.time, 'data': base64Encode(g.data)},
        ],
      });
    })(r);
  });

  // ------------------------------------------------------- fail of week

  router.post('/v1/fails', authed((r, me) async {
    final length = r.contentLength;
    if (length != null && length > maxClipBytes) return error(413, 'clip too big');
    final builder = BytesBuilder(copy: false);
    await for (final chunk in r.read()) {
      builder.add(chunk);
      if (builder.length > maxClipBytes) return error(413, 'clip too big');
    }
    final bytes = builder.takeBytes();
    // An MP4 starts with a box whose type is 'ftyp'.
    if (bytes.length < 12 || ascii.decode(bytes.sublist(4, 8), allowInvalid: true) != 'ftyp') {
      return error(400, 'not an mp4 clip');
    }
    final id = store.createFail(me.id, r.url.queryParameters['caption'] ?? '', clock());
    if (id == null) return error(429, 'you can send ${Store.maxFailsPerWeek} clips a week');
    await clipFile(id).writeAsBytes(bytes, flush: true);
    return json({'id': id});
  }));

  router.get('/v1/fails', (Request r) {
    final token = bearer(r);
    final me = token == null ? null : store.playerByToken(token, clock());
    final week = serverWeek(clock());
    final featured = store.featured(week - 1, clock());
    Set<int> voted = {};
    if (me != null) {
      voted = {
        for (final row in store.db.select('SELECT fail_id FROM votes WHERE player_id = ?', [me.id])) row['fail_id'] as int,
      };
    }
    final daysLeft = 7 - serverDay(clock()) % 7;
    return json({
      'week': week,
      'daysLeft': daysLeft,
      'featured': featured == null ? null : failJson(featured, me: me?.id),
      'entries': [
        for (final f in store.fails(week: week)) {...failJson(f, me: me?.id), 'voted': voted.contains(f.id)},
      ],
    });
  });

  router.post('/v1/fails/<id|[0-9]+>/vote', (Request r, String id) {
    return authed((r, me) {
      if (!store.vote(int.parse(id), me.id, clock())) return error(400, 'cannot vote for that clip');
      return json({'ok': true});
    })(r);
  });

  router.post('/v1/fails/<id|[0-9]+>/report', (Request r, String id) {
    return authed((r, me) {
      store.report(int.parse(id), me.id);
      return json({'ok': true});
    })(r);
  });

  router.get('/v1/media/fails/<file>', (Request r, String file) async {
    final id = int.tryParse(file.replaceAll('.mp4', ''));
    if (id == null || !store.failVisible(id)) return error(404, 'not found');
    final f = clipFile(id);
    if (!f.existsSync()) return error(404, 'not found');
    return Response.ok(
      f.openRead(),
      headers: {
        'content-type': 'video/mp4',
        'content-length': '${f.lengthSync()}',
        'cache-control': 'public, max-age=86400',
      },
    );
  });

  // ------------------------------------------------------------- rewards

  router.get('/v1/rewards', authed((r, me) => json({
    'rewards': [
      for (final g in store.pendingRewards(me.id)) {'id': g.id, 'reason': g.reason, ...g.payload},
    ],
  })));

  router.post('/v1/rewards/<id|[0-9]+>/claim', (Request r, String id) {
    return authed((r, me) {
      final payload = store.claimReward(int.parse(id), me.id);
      if (payload == null) return error(404, 'nothing to claim');
      return json(payload);
    })(r);
  });

  // ----------------------------------------------------------- analytics

  router.post('/v1/events', authed((r, me) async {
    final list = (await body(r))['events'];
    if (list is! List || list.length > 200) return error(400, 'events: up to 200 per batch');
    final now = clock();
    final events = <({String name, Map<String, Object?> params, DateTime at})>[];
    for (final e in list) {
      if (e is! Map) continue;
      final name = e['name'], params = e['params'] ?? const {}, at = e['at'];
      if (name is! String || params is! Map) continue;
      var time = at is int ? DateTime.fromMillisecondsSinceEpoch(at, isUtc: true) : now;
      if (time.isAfter(now) || now.difference(time).inDays > 7) time = now;
      events.add((name: name, params: params.cast<String, Object?>(), at: time));
    }
    store.logEvents(me.id, events);
    return json({'stored': events.length});
  }));

  // --------------------------------------------------------------- admin

  router.get('/v1/admin/stats', admin((r) => json(store.stats(clock()))));

  router.get('/v1/admin/fails', admin((r) {
    final week = int.tryParse(r.url.queryParameters['week'] ?? '') ?? serverWeek(clock());
    return json({
      'week': week,
      'entries': [for (final f in store.fails(week: week, includeHidden: true)) failJson(f)],
    });
  }));

  router.post('/v1/admin/fails/<id|[0-9]+>/<action>', (Request r, String id, String action) {
    return admin((r) {
      final failId = int.parse(id);
      switch (action) {
        case 'hide':
          store.setHidden(failId, true);
        case 'unhide':
          store.setHidden(failId, false);
        case 'feature':
          store.feature(failId, clock());
        case 'delete':
          store.deleteFail(failId);
          final f = clipFile(failId);
          if (f.existsSync()) f.deleteSync();
        default:
          return error(400, 'unknown action');
      }
      return json({'ok': true});
    })(r);
  });

  return const Pipeline().addMiddleware(_errors()).addHandler(router.call);
}

/// Turns bad input into 400s instead of 500s.
Middleware _errors() => (inner) => (request) async {
  try {
    return await inner(request);
  } on FormatException catch (e) {
    return Response(400, body: jsonEncode({'error': 'bad request: ${e.message}'}), headers: {'content-type': 'application/json'});
  }
};
