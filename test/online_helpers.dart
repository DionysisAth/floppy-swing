import 'dart:io';

import 'package:floppy_server/floppy_server.dart' as server;
import 'package:floppy_swing/services/online_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelf/shelf.dart' as shelf;

/// Routes the app's HTTP calls straight into the real server handler.
class TestServer {
  TestServer() {
    media = Directory.systemTemp.createTempSync('floppy_test_media');
    handler = server.buildHandler(store, mediaDir: media, adminToken: 'adm', clock: () => now);
  }

  final store = server.Store.memory();
  late final Directory media;
  late final shelf.Handler handler;
  DateTime now = DateTime.utc(2026, 10, 1, 12);
  bool down = false;

  http.Client client() => MockClient((req) async {
    if (down) throw const SocketException('down');
    final r = await handler(shelf.Request(req.method, req.url, body: req.bodyBytes, headers: req.headers));
    final bytes = await r.read().expand((c) => c).toList();
    return http.Response.bytes(bytes, r.statusCode, headers: r.headers);
  });

  Future<OnlineService> player({SharedPreferences? prefs}) async {
    final o = OnlineService(prefs: prefs, serverUrl: 'http://test', client: client());
    await o.start();
    return o;
  }

  void close() {
    store.close();
    media.deleteSync(recursive: true);
  }
}

