import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Server address baked in at build time with
/// `--dart-define=FLOPPY_SERVER=https://...`. Players can override it in
/// Settings (handy for testing against your own server).
const defaultServerUrl = String.fromEnvironment('FLOPPY_SERVER');

enum OnlineStatus {
  /// No server configured.
  disabled,
  connecting,
  online,

  /// Configured but unreachable right now (no signal, server down).
  offline,
}

class OnlineProfile {
  const OnlineProfile({required this.id, required this.name, required this.friendCode});

  factory OnlineProfile.fromJson(Map<String, dynamic> m) =>
      OnlineProfile(id: m['id'] as int, name: m['name'] as String, friendCode: m['friendCode'] as String);

  final int id;
  final String name;
  final String friendCode;
}

class BoardEntry {
  const BoardEntry({required this.rank, required this.name, required this.value, required this.me});
  final int rank;
  final String name;
  final double value;
  final bool me;
}

class Leaderboard {
  const Leaderboard({required this.board, required this.total, required this.entries, this.myRank, this.myValue});
  final String board;
  final int total;
  final List<BoardEntry> entries;
  final int? myRank;
  final double? myValue;
}

class Friend {
  const Friend(this.id, this.name);
  final int id;
  final String name;
}

class FriendGhost {
  const FriendGhost(this.name, this.time, this.samples);
  final String name;
  final double time;
  final Float32List samples;
}

class FailClip {
  const FailClip({
    required this.id,
    required this.name,
    required this.caption,
    required this.votes,
    required this.url,
    this.featured = false,
    this.mine = false,
    this.voted = false,
  });

  final int id;
  final String name;
  final String caption;
  final int votes;

  /// Absolute URL of the MP4.
  final String url;
  final bool featured;
  final bool mine;
  final bool voted;
}

class FailsPage {
  const FailsPage({required this.daysLeft, required this.entries, this.featured});
  final int daysLeft;
  final List<FailClip> entries;

  /// Last week's winner.
  final FailClip? featured;
}

/// A reward sent by the server (e.g. for winning Fail of the Week).
class ServerReward {
  const ServerReward({required this.id, required this.reason, this.coins = 0, this.gems = 0, this.item});
  final int id;
  final String reason;
  final int coins;
  final int gems;
  final String? item;
}

class OnlineException implements Exception {
  const OnlineException(this.message, [this.status]);
  final String message;
  final int? status;

  @override
  String toString() => message;
}

/// Talks to the Floppy Swing server: account, leaderboards, cloud save,
/// friends, ghosts, Fail of the Week, rewards and analytics.
///
/// Everything degrades gracefully: with no server configured the game is
/// fully playable, and online calls just throw [OnlineException].
class OnlineService extends ChangeNotifier {
  OnlineService({SharedPreferences? prefs, String? serverUrl, http.Client? client})
    : _prefs = prefs,
      _client = client ?? http.Client(),
      _serverUrl = _normalise(prefs?.getString(_serverKey) ?? serverUrl ?? defaultServerUrl);

  /// Not configured: every call fails fast (tests, builds without a server).
  factory OnlineService.disabled() => OnlineService(serverUrl: '');

  static const _tokenKey = 'online_token';
  static const _serverKey = 'online_server';

  final SharedPreferences? _prefs;
  final http.Client _client;
  String _serverUrl;
  String? _token;

  OnlineStatus status = OnlineStatus.disabled;
  OnlineProfile? profile;

  static String _normalise(String url) => url.trim().replaceAll(RegExp(r'/+$'), '');

  String get serverUrl => _serverUrl;
  bool get enabled => _serverUrl.isNotEmpty;
  bool get isOnline => status == OnlineStatus.online && profile != null;

  /// Signs in (registering a new anonymous player the first time).
  Future<void> start() async {
    if (!enabled) {
      status = OnlineStatus.disabled;
      notifyListeners();
      return;
    }
    status = OnlineStatus.connecting;
    notifyListeners();
    _token ??= _prefs?.getString(_tokenKey);
    try {
      if (_token != null) {
        try {
          profile = OnlineProfile.fromJson((await _call('GET', '/v1/me'))['player'] as Map<String, dynamic>);
        } on OnlineException catch (e) {
          // The server forgot us (e.g. it was reset): start a new account.
          if (e.status != 401) rethrow;
          _token = null;
        }
      }
      if (_token == null) await _register();
      status = OnlineStatus.online;
    } catch (e) {
      debugPrint('Online: $e');
      status = OnlineStatus.offline;
    }
    notifyListeners();
  }

  Future<void> _register() async {
    final r = await _call('POST', '/v1/players', body: const <String, Object?>{}, auth: false);
    _token = r['token'] as String;
    await _prefs?.setString(_tokenKey, _token!);
    profile = OnlineProfile.fromJson(r['player'] as Map<String, dynamic>);
  }

  /// Points the game at another server (Settings > Advanced). Signs in again.
  Future<void> setServer(String url) async {
    _serverUrl = _normalise(url);
    _token = null;
    profile = null;
    await _prefs?.setString(_serverKey, _serverUrl);
    await _prefs?.remove(_tokenKey);
    await start();
  }

  // ------------------------------------------------------------- plumbing

  Uri _uri(String path) => Uri.parse('$_serverUrl$path');

  Future<Map<String, dynamic>> _call(
    String method,
    String path, {
    Object? body,
    Uint8List? bytes,
    bool auth = true,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (!enabled) throw const OnlineException('Online features are off in this build.');
    final request = http.Request(method, _uri(path));
    if (auth && _token != null) request.headers['authorization'] = 'Bearer $_token';
    if (bytes != null) {
      request.headers['content-type'] = 'video/mp4';
      request.bodyBytes = bytes;
    } else if (body != null) {
      request.headers['content-type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    final http.Response response;
    try {
      response = await http.Response.fromStream(await _client.send(request).timeout(timeout));
    } on TimeoutException {
      throw const OnlineException('The server is taking too long. Check your connection.');
    } catch (e) {
      throw const OnlineException("Can't reach the server. Check your connection.");
    }
    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode >= 400) {
      final message = decoded is Map && decoded['error'] is String ? decoded['error'] as String : 'Server error';
      throw OnlineException(message, response.statusCode);
    }
    return decoded as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _authed(String method, String path, {Object? body, Uint8List? bytes}) async {
    if (profile == null) await start();
    if (profile == null) throw const OnlineException("You're offline right now.");
    return _call(method, path, body: body, bytes: bytes);
  }

  // -------------------------------------------------------------- profile

  Future<void> rename(String name) async {
    final r = await _authed('PATCH', '/v1/me', body: {'name': name});
    profile = OnlineProfile.fromJson(r['player'] as Map<String, dynamic>);
    notifyListeners();
  }

  /// Deletes the online account and everything the server holds about this
  /// player. The game keeps working offline; a fresh anonymous account is
  /// made next time it goes online.
  Future<void> deleteAccount() async {
    await _authed('DELETE', '/v1/me');
    _token = null;
    profile = null;
    await _prefs?.remove(_tokenKey);
    status = OnlineStatus.offline;
    notifyListeners();
  }

  /// A one-time code for moving this account to another device.
  Future<String> transferCode() async => (await _authed('POST', '/v1/me/transfer'))['code'] as String;

  /// Signs this device into the account that made [code].
  Future<void> redeemTransfer(String code) async {
    final r = await _call('POST', '/v1/transfer', body: {'code': code}, auth: false);
    _token = r['token'] as String;
    await _prefs?.setString(_tokenKey, _token!);
    profile = OnlineProfile.fromJson(r['player'] as Map<String, dynamic>);
    status = OnlineStatus.online;
    notifyListeners();
  }

  // --------------------------------------------------------- leaderboards

  static String dailyBoard(int day) => 'daily-$day';
  static const endlessBoard = 'endless';

  /// Submits a score; returns the player's rank and board size.
  Future<({int rank, int total})> submitScore(String board, double value) async {
    final r = await _authed('POST', '/v1/scores', body: {'board': board, 'value': value});
    return (rank: r['rank'] as int, total: r['total'] as int);
  }

  Future<Leaderboard> leaderboard(String board, {bool friends = false}) async {
    final r = friends
        ? await _authed('GET', '/v1/leaderboards/$board?friends=1')
        : await _call('GET', '/v1/leaderboards/$board', auth: true);
    final me = r['me'] as Map<String, dynamic>?;
    return Leaderboard(
      board: board,
      total: r['total'] as int,
      entries: [
        for (final e in r['entries'] as List)
          BoardEntry(
            rank: e['rank'] as int,
            name: e['name'] as String,
            value: (e['value'] as num).toDouble(),
            me: e['me'] as bool,
          ),
      ],
      myRank: me?['rank'] as int?,
      myValue: (me?['value'] as num?)?.toDouble(),
    );
  }

  // ------------------------------------------------------------ cloud save

  /// The cloud save and its revision, or null if there is none yet.
  Future<({Map<String, dynamic> data, int revision})?> loadSave() async {
    try {
      final r = await _authed('GET', '/v1/save');
      return (data: r['data'] as Map<String, dynamic>, revision: r['revision'] as int);
    } on OnlineException catch (e) {
      if (e.status == 404) return null;
      rethrow;
    }
  }

  /// Uploads a save on top of [baseRevision]. Returns the new revision, or
  /// the newer cloud copy when another device saved first.
  Future<({int? revision, Map<String, dynamic>? conflictData, int? conflictRevision})> storeSave(
    Map<String, dynamic> data,
    int baseRevision,
  ) async {
    try {
      final r = await _authed('PUT', '/v1/save', body: {'data': data, 'baseRevision': baseRevision});
      return (revision: r['revision'] as int, conflictData: null, conflictRevision: null);
    } on OnlineException catch (e) {
      if (e.status != 409) rethrow;
      final current = await loadSave();
      return (revision: null, conflictData: current?.data, conflictRevision: current?.revision);
    }
  }

  // ---------------------------------------------------------------- friends

  Future<List<Friend>> friends() async => [
    for (final f in (await _authed('GET', '/v1/friends'))['friends'] as List) Friend(f['id'] as int, f['name'] as String),
  ];

  Future<Friend> addFriend(String code) async {
    final f = (await _authed('POST', '/v1/friends', body: {'code': code}))['friend'] as Map<String, dynamic>;
    return Friend(f['id'] as int, f['name'] as String);
  }

  Future<void> removeFriend(int id) => _authed('DELETE', '/v1/friends/$id');

  // ----------------------------------------------------------------- ghosts

  Future<void> uploadGhost(String key, double time, Float32List samples) =>
      _authed('PUT', '/v1/ghosts/$key', body: {'time': time, 'data': base64Encode(samples.buffer.asUint8List())});

  Future<List<FriendGhost>> friendGhosts(String key) async => [
    for (final g in (await _authed('GET', '/v1/ghosts/$key'))['ghosts'] as List)
      FriendGhost(
        g['name'] as String,
        (g['time'] as num).toDouble(),
        Uint8List.fromList(base64Decode(g['data'] as String)).buffer.asFloat32List(),
      ),
  ];

  // ---------------------------------------------------------- fail of week

  FailClip _clip(Map<String, dynamic> m) => FailClip(
    id: m['id'] as int,
    name: m['name'] as String,
    caption: m['caption'] as String,
    votes: m['votes'] as int,
    url: '$_serverUrl${m['url']}',
    featured: m['featured'] as bool? ?? false,
    mine: m['mine'] as bool? ?? false,
    voted: m['voted'] as bool? ?? false,
  );

  Future<FailsPage> fails() async {
    final r = await _call('GET', '/v1/fails');
    final featured = r['featured'] as Map<String, dynamic>?;
    return FailsPage(
      daysLeft: r['daysLeft'] as int,
      featured: featured == null ? null : _clip(featured),
      entries: [for (final e in r['entries'] as List) _clip(e as Map<String, dynamic>)],
    );
  }

  Future<void> submitFail(Uint8List mp4, String caption) => _authed(
    'POST',
    '/v1/fails?caption=${Uri.encodeQueryComponent(caption)}',
    bytes: mp4,
  );

  Future<void> vote(int clipId) => _authed('POST', '/v1/fails/$clipId/vote');
  Future<void> report(int clipId) => _authed('POST', '/v1/fails/$clipId/report');

  // ---------------------------------------------------------------- rewards

  Future<List<ServerReward>> rewards() async => [
    for (final r in (await _authed('GET', '/v1/rewards'))['rewards'] as List)
      ServerReward(
        id: r['id'] as int,
        reason: r['reason'] as String,
        coins: (r['coins'] as num?)?.toInt() ?? 0,
        gems: (r['gems'] as num?)?.toInt() ?? 0,
        item: r['item'] as String?,
      ),
  ];

  Future<void> claimReward(int id) => _authed('POST', '/v1/rewards/$id/claim');

  // -------------------------------------------------------------- analytics

  final List<Map<String, Object?>> _events = [];
  Timer? _flushTimer;

  /// Queues an analytics event; batches go out every 30 s (or 50 events).
  void track(String name, Map<String, Object?> params) {
    if (!enabled) return;
    _events.add({'name': name, 'params': params, 'at': DateTime.now().millisecondsSinceEpoch});
    if (_events.length > 500) _events.removeRange(0, _events.length - 500);
    if (_events.length >= 50) {
      unawaited(flushEvents());
    } else {
      _flushTimer ??= Timer(const Duration(seconds: 30), () => unawaited(flushEvents()));
    }
  }

  Future<void> flushEvents() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    if (_events.isEmpty || profile == null) return;
    final batch = List.of(_events.take(200));
    try {
      await _call('POST', '/v1/events', body: {'events': batch});
      _events.removeRange(0, batch.length);
    } catch (_) {
      // Keep them for the next try.
    }
  }

  @override
  void dispose() {
    _flushTimer?.cancel();
    _client.close();
    super.dispose();
  }
}
