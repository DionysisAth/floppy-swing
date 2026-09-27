import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:floppy_server/floppy_server.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

/// A tiny client around the in-process handler.
class Api {
  Api(this.handler);
  final Handler handler;

  Future<(int, dynamic)> call(String method, String path, {Object? body, String? token, List<int>? bytes}) async {
    final r = await handler(Request(
      method,
      Uri.parse('http://localhost$path'),
      body: bytes ?? (body == null ? null : jsonEncode(body)),
      headers: {'authorization': ?(token == null ? null : 'Bearer $token')},
    ));
    final text = await r.readAsString();
    dynamic decoded;
    try {
      decoded = text.isEmpty ? null : jsonDecode(text);
    } on FormatException {
      decoded = text;
    }
    return (r.statusCode, decoded);
  }

  Future<({int id, String token, String code})> register([String? name]) async {
    final (status, b) = await call('POST', '/v1/players', body: {'name': ?name});
    expect(status, 200);
    return (id: b['player']['id'] as int, token: b['token'] as String, code: b['player']['friendCode'] as String);
  }
}

/// A minimal valid-looking MP4 header.
List<int> mp4([int size = 64]) => [0, 0, 0, 24, ...ascii.encode('ftypisom'), ...List.filled(size, 7)];

void main() {
  late Store store;
  late Api api;
  late Directory media;
  var now = DateTime.utc(2026, 9, 30, 12);

  setUp(() {
    now = DateTime.utc(2026, 9, 30, 12);
    store = Store.memory();
    media = Directory.systemTemp.createTempSync('floppy_media');
    api = Api(buildHandler(store, mediaDir: media, adminToken: 'admin-secret', clock: () => now));
  });

  tearDown(() {
    store.close();
    media.deleteSync(recursive: true);
  });

  test('players register, rename with clean names, and need their token', () async {
    final a = await api.register('Ann <b>');
    var (status, body) = await api.call('GET', '/v1/me', token: a.token);
    expect(status, 200);
    expect(body['player']['name'], 'Ann b');
    (status, body) = await api.call('PATCH', '/v1/me', token: a.token, body: {'name': 'x'});
    expect(status, 400);
    (status, body) = await api.call('PATCH', '/v1/me', token: a.token, body: {'name': 'Swingy'});
    expect(body['player']['name'], 'Swingy');
    (status, _) = await api.call('GET', '/v1/me', token: 'nope');
    expect(status, 401);
    final b = await api.register();
    expect((await api.call('GET', '/v1/me', token: b.token)).$2['player']['name'], startsWith('Flopper'));
  });

  test('a transfer code signs another device into the same account once', () async {
    final a = await api.register('Ann');
    final (_, t) = await api.call('POST', '/v1/me/transfer', token: a.token);
    final code = t['code'] as String;
    var (status, body) = await api.call('POST', '/v1/transfer', body: {'code': code.toLowerCase()});
    expect(status, 200);
    expect(body['player']['id'], a.id);
    expect(body['token'], a.token);
    (status, _) = await api.call('POST', '/v1/transfer', body: {'code': code});
    expect(status, 404, reason: 'single use');
    final (_, t2) = await api.call('POST', '/v1/me/transfer', token: a.token);
    now = now.add(const Duration(days: 2));
    (status, _) = await api.call('POST', '/v1/transfer', body: {'code': t2['code']});
    expect(status, 404, reason: 'expired');
  });

  test('daily boards rank lowest time, endless highest score, keeping each best', () async {
    final a = await api.register('Ann'), b = await api.register('Bob'), c = await api.register('Cat');
    final day = serverDay(now);
    Future<dynamic> submit(String token, String board, num value) async =>
        (await api.call('POST', '/v1/scores', token: token, body: {'board': board, 'value': value})).$2;
    await submit(a.token, 'daily-$day', 20.5);
    await submit(b.token, 'daily-$day', 18.0);
    final r = await submit(c.token, 'daily-$day', 25.0);
    expect(r['rank'], 3);
    expect((await submit(a.token, 'daily-$day', 30))['improved'], isFalse);
    expect((await submit(a.token, 'daily-$day', 17))['rank'], 1);

    await submit(a.token, 'endless', 500);
    await submit(b.token, 'endless', 900);
    final (_, board) = await api.call('GET', '/v1/leaderboards/endless', token: a.token);
    expect([for (final e in board['entries']) e['name']], ['Bob', 'Ann']);
    expect(board['me'], {'rank': 2, 'value': 500.0});
    expect(board['entries'][1]['me'], isTrue);

    final (_, daily) = await api.call('GET', '/v1/leaderboards/daily-$day');
    expect([for (final e in daily['entries']) e['value']], [17.0, 18.0, 25.0]);
    expect(daily['me'], isNull);
  });

  test('scores are sanity checked', () async {
    final a = await api.register();
    Future<int> submit(String board, num value) async =>
        (await api.call('POST', '/v1/scores', token: a.token, body: {'board': board, 'value': value})).$1;
    expect(await submit('daily-${serverDay(now) - 5}', 20), 400, reason: 'old daily');
    expect(await submit('daily-${serverDay(now)}', 0.5), 400, reason: 'impossible time');
    expect(await submit('endless', -1), 400);
    expect(await submit('cheats', 1), 400);
    expect(await submit('daily-${serverDay(now) + 1}', 20), 200, reason: 'time zones ahead');
  });

  test('friends see each other on friend boards and race each other\'s ghosts', () async {
    final a = await api.register('Ann'), b = await api.register('Bob'), c = await api.register('Cat');
    var (status, body) = await api.call('POST', '/v1/friends', token: a.token, body: {'code': b.code.toLowerCase()});
    expect(status, 200);
    expect(body['friend']['name'], 'Bob');
    (status, _) = await api.call('POST', '/v1/friends', token: a.token, body: {'code': a.code});
    expect(status, 404, reason: 'not yourself');
    final (_, bFriends) = await api.call('GET', '/v1/friends', token: b.token);
    expect([for (final f in bFriends['friends']) f['name']], ['Ann'], reason: 'two-way');

    for (final (p, v) in [(a, 100), (b, 200), (c, 300)]) {
      await api.call('POST', '/v1/scores', token: p.token, body: {'board': 'endless', 'value': v});
    }
    final (_, fb) = await api.call('GET', '/v1/leaderboards/endless?friends=1', token: a.token);
    expect([for (final e in fb['entries']) e['name']], ['Bob', 'Ann']);

    String ghost(double t) => base64Encode(Float32List.fromList([0, 1, 2, 3, t, 2, 3, 4]).buffer.asUint8List());
    (status, body) = await api.call('PUT', '/v1/ghosts/L7', token: b.token, body: {'time': 12.5, 'data': ghost(12.5)});
    expect(body['stored'], isTrue);
    (_, body) = await api.call('PUT', '/v1/ghosts/L7', token: b.token, body: {'time': 14.0, 'data': ghost(14)});
    expect(body['stored'], isFalse, reason: 'only faster runs replace a ghost');
    await api.call('PUT', '/v1/ghosts/L7', token: c.token, body: {'time': 9.0, 'data': ghost(9)});
    (_, body) = await api.call('GET', '/v1/ghosts/L7', token: a.token);
    expect([for (final g in body['ghosts']) g['name']], ['Bob'], reason: 'friends only');
    final floats = Uint8List.fromList(base64Decode(body['ghosts'][0]['data'] as String)).buffer.asFloat32List();
    expect(floats[4], 12.5);
    (status, _) = await api.call('PUT', '/v1/ghosts/../../etc', token: a.token, body: {'time': 1, 'data': ghost(1)});
    expect(status, isNot(200));

    await api.call('DELETE', '/v1/friends/${b.id}', token: a.token);
    expect((await api.call('GET', '/v1/friends', token: b.token)).$2['friends'], isEmpty);
  });

  test('cloud saves use revisions so two devices cannot silently overwrite each other', () async {
    final a = await api.register();
    var (status, body) = await api.call('GET', '/v1/save', token: a.token);
    expect(status, 404);
    (status, body) = await api.call('PUT', '/v1/save', token: a.token, body: {'data': {'coins': 5}, 'baseRevision': 0});
    expect(body['revision'], 1);
    (status, body) = await api.call('PUT', '/v1/save', token: a.token, body: {'data': {'coins': 9}, 'baseRevision': 0});
    expect(status, 409);
    expect(body['data'], {'coins': 5});
    expect(body['revision'], 1);
    (status, body) = await api.call('PUT', '/v1/save', token: a.token, body: {'data': {'coins': 9}, 'baseRevision': 1});
    expect(body['revision'], 2);
    (_, body) = await api.call('GET', '/v1/save', token: a.token);
    expect(body, {'data': {'coins': 9}, 'revision': 2});
  });

  group('fail of the week', () {
    test('clips upload, get votes, and the weekly winner is rewarded once', () async {
      final a = await api.register('Ann'), b = await api.register('Bob'), c = await api.register('Cat');
      var (status, body) = await api.call('POST', '/v1/fails?caption=Faceplant', token: a.token, bytes: mp4());
      expect(status, 200);
      final aClip = body['id'] as int;
      (status, body) = await api.call('POST', '/v1/fails', token: b.token, bytes: mp4());
      final bClip = body['id'] as int;
      (status, _) = await api.call('POST', '/v1/fails', token: c.token, bytes: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
      expect(status, 400, reason: 'not an mp4');

      expect((await api.call('POST', '/v1/fails/$aClip/vote', token: a.token)).$1, 400, reason: 'no self votes');
      expect((await api.call('POST', '/v1/fails/$aClip/vote', token: b.token)).$1, 200);
      expect((await api.call('POST', '/v1/fails/$aClip/vote', token: b.token)).$1, 400, reason: 'once');
      await api.call('POST', '/v1/fails/$aClip/vote', token: c.token);
      await api.call('POST', '/v1/fails/$bClip/vote', token: c.token);

      (_, body) = await api.call('GET', '/v1/fails', token: c.token);
      expect([for (final e in body['entries']) e['votes']], [2, 1]);
      expect(body['entries'][0]['caption'], 'Faceplant');
      expect(body['entries'][0]['voted'], isTrue);
      expect(body['featured'], isNull);

      final (clipStatus, _) = await api.call('GET', '/v1/media/fails/$aClip.mp4');
      expect(clipStatus, 200);

      // Next week: last week's top clip is featured and its player rewarded.
      now = now.add(const Duration(days: 7));
      (_, body) = await api.call('GET', '/v1/fails', token: c.token);
      expect(body['featured']['id'], aClip);
      expect(body['entries'], isEmpty);
      expect((await api.call('POST', '/v1/fails/$bClip/vote', token: a.token)).$1, 400, reason: 'voting closed');
      (_, body) = await api.call('GET', '/v1/rewards', token: a.token);
      expect(body['rewards'], hasLength(1));
      expect(body['rewards'][0]['item'], 'golden');
      final rewardId = body['rewards'][0]['id'];
      (status, body) = await api.call('POST', '/v1/rewards/$rewardId/claim', token: a.token);
      expect(body['gems'], 50);
      (status, _) = await api.call('POST', '/v1/rewards/$rewardId/claim', token: a.token);
      expect(status, 404);
      await api.call('GET', '/v1/fails', token: c.token);
      expect((await api.call('GET', '/v1/rewards', token: a.token)).$2['rewards'], isEmpty, reason: 'rewarded once');
    });

    test('each player can send three clips a week', () async {
      final a = await api.register();
      for (var i = 0; i < 3; i++) {
        expect((await api.call('POST', '/v1/fails', token: a.token, bytes: mp4())).$1, 200);
      }
      expect((await api.call('POST', '/v1/fails', token: a.token, bytes: mp4())).$1, 429);
    });

    test('clips that get reported enough are hidden until a moderator decides', () async {
      final a = await api.register();
      final (_, body) = await api.call('POST', '/v1/fails', token: a.token, bytes: mp4());
      final id = body['id'];
      for (var i = 0; i < Store.reportsToHide; i++) {
        final p = await api.register();
        await api.call('POST', '/v1/fails/$id/report', token: p.token);
      }
      expect((await api.call('GET', '/v1/fails')).$2['entries'], isEmpty);
      expect((await api.call('GET', '/v1/media/fails/$id.mp4')).$1, 404);
      expect((await api.call('GET', '/v1/admin/fails', token: 'admin-secret')).$2['entries'], hasLength(1));
      await api.call('POST', '/v1/admin/fails/$id/unhide', token: 'admin-secret');
      expect((await api.call('GET', '/v1/fails')).$2['entries'], hasLength(1));
      await api.call('POST', '/v1/admin/fails/$id/delete', token: 'admin-secret');
      expect((await api.call('GET', '/v1/admin/fails', token: 'admin-secret')).$2['entries'], isEmpty);
    });

    test('oversized clips are refused', () async {
      final a = await api.register();
      final (status, _) = await api.call('POST', '/v1/fails', token: a.token, bytes: mp4(maxClipBytes + 10));
      expect(status, 413);
    });
  });

  test('analytics events feed the admin stats; admin routes need the token', () async {
    final a = await api.register(), b = await api.register();
    Map<String, Object?> e(String name, Map<String, Object?> params) =>
        {'name': name, 'params': params, 'at': now.millisecondsSinceEpoch};
    await api.call('POST', '/v1/events', token: a.token, body: {
      'events': [
        e('level_start', {'level': 3}),
        e('level_fail', {'level': 3, 'cause': 'spikes'}),
        e('level_start', {'level': 3}),
        e('level_complete', {'level': 3}),
      ],
    });
    await api.call('POST', '/v1/events', token: b.token, body: {
      'events': [e('level_start', {'level': 3}), e('level_fail', {'level': 3, 'cause': 'saw'})],
    });
    expect((await api.call('GET', '/v1/admin/stats')).$1, 403);
    expect((await api.call('GET', '/v1/admin/stats', token: 'nope')).$1, 403);
    final (status, stats) = await api.call('GET', '/v1/admin/stats', token: 'admin-secret');
    expect(status, 200);
    expect(stats['players'], 2);
    expect(stats['activeToday'], 2);
    expect(stats['levels']['3'], {'starts': 3, 'fails': 2, 'completes': 1, 'skips': 0, 'completionRate': 1 / 3});
    expect(stats['deathCauses'], {'spikes': 1, 'saw': 1});
  });

  test('bad JSON is a 400, not a crash', () async {
    final r = await api.handler(Request('POST', Uri.parse('http://localhost/v1/players'), body: '{nope'));
    expect(r.statusCode, 400);
  });
}
