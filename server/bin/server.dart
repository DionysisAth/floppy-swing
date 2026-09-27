import 'dart:io';

import 'package:floppy_server/floppy_server.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

/// Runs the server. Configuration comes from the environment:
///
///   PORT         listen port (default 8080)
///   DATA_DIR     where the database and uploaded clips live (default ./data)
///   ADMIN_TOKEN  enables /v1/admin/* for moderation and stats
Future<void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final dataDir = Directory(Platform.environment['DATA_DIR'] ?? 'data')..createSync(recursive: true);
  final adminToken = Platform.environment['ADMIN_TOKEN'];
  final store = Store.open('${dataDir.path}/floppy.db');
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(buildHandler(store, mediaDir: dataDir, adminToken: adminToken?.isEmpty ?? true ? null : adminToken));
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  server.autoCompress = true;
  stdout.writeln('Floppy Swing server on :${server.port} (data in ${dataDir.path})');
  ProcessSignal.sigterm.watch().listen((_) async {
    await server.close();
    store.close();
    exit(0);
  });
}
