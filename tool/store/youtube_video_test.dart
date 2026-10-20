// ignore_for_file: invalid_use_of_visible_for_testing_member
// Records the gameplay for the ~30 s landscape trailer (YouTube and the
// Google Play promo video): the real app at 1080x1920 and 30 fps, played by
// the autopilot through all five worlds, piped into ffmpeg. Every game sound
// is logged with its time so the mix matches the picture.
//
//   FFMPEG=/path/to/ffmpeg flutter test tool/store/youtube_video_test.dart
//   python3 tool/store/make_youtube_video.py    # landscape layout, titles, music
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:floppy_swing/app.dart';
import 'package:floppy_swing/game/autopilot.dart';
import 'package:floppy_swing/game/cosmetics.dart';
import 'package:floppy_swing/game/game_controller.dart';
import 'package:floppy_swing/game/skins.dart';
import 'package:floppy_swing/services/ads_service.dart';
import 'package:floppy_swing/services/analytics.dart';
import 'package:floppy_swing/services/audio_service.dart';
import 'package:floppy_swing/services/games_service.dart';
import 'package:floppy_swing/services/progress.dart';
import 'package:floppy_swing/services/purchase_service.dart';
import 'package:floppy_swing/ui/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers.dart';
import '../screenshots/store_screenshots_test.dart' show loadFonts;
import 'promo_video_test.dart' show SoundLog;

const fps = 30;
const width = 1080, height = 1920;
const out = 'tool/store/out/youtube';

void main() {
  testWidgets('youtube trailer gameplay', (tester) async {
    final ffmpeg = Platform.environment['FFMPEG'] ?? 'ffmpeg';
    await tester.runAsync(loadFonts);
    tester.view.physicalSize = const Size(width * 1.0, height * 1.0);
    tester.view.devicePixelRatio = 2.625;
    final content = await tester.runAsync(() => loadContent(rootBundle));
    final solutions = (jsonDecode(File('test/level_solutions.json').readAsStringSync()) as Map<String, dynamic>).map(
      (k, v) => MapEntry(
        int.parse(k),
        AutopilotParams(
          releaseAngle: (v['releaseAngle'] as num).toDouble(),
          regrabDelay: (v['regrabDelay'] as num).toDouble(),
          minFallSpeed: (v['minFallSpeed'] as num).toDouble(),
        ),
      ),
    );
    final progress = ProgressStore.memory(loadEconomy());
    progress.claimLoginReward();
    for (var i = 1; i <= 90; i++) {
      progress.recordWin(i, RunResult(time: 5, targetTime: 30, coins: 3, totalCoins: 3, style: 0, revived: false));
    }
    progress.addCoins(2400);
    progress.addGems(120);
    for (final id in ['banana', 'knight', 'ninja', 'pirate', 'astronaut', 'wizard', 'dino', 'robot', 'chicken']) {
      progress.grantItem(id);
    }
    for (final id in ['rainbow', 'laser', 'chain', 'fire', 'sparkles', 'stars', 'gold']) {
      progress.grantItem(id);
    }
    await tester.pumpWidget(
      FloppySwingApp(
        services: (child) => AppServices(
          physics: content!.physics,
          economy: content.economy,
          levels: content.levels,
          dailies: content.dailies,
          progress: progress,
          audio: AudioService(progress),
          ads: NoAdsService(),
          analytics: const Analytics(),
          games: GamesService.disabled(progress),
          purchases: NoPurchaseService(progress, instant: true),
          child: child,
        ),
      ),
    );

    Directory(out).createSync(recursive: true);
    final encoder = await tester.runAsync(
      () => Process.start(ffmpeg, [
        '-y', '-loglevel', 'error', //
        '-f', 'rawvideo', '-pix_fmt', 'rgba', '-s', '${width}x$height', '-r', '$fps', '-i', '-',
        '-c:v', 'libx264', '-preset', 'medium', '-crf', '16', '-pix_fmt', 'yuv420p',
        '$out/gameplay.mp4',
      ]),
    );
    unawaited(encoder!.stderr.transform(utf8.decoder).forEach(stderr.write));
    final log = SoundLog();
    final segments = <Map<String, Object>>[];
    var frame = 0;

    Future<void> capture() async {
      RenderObject boundary = tester.renderObject(find.byType(MaterialApp));
      while (!boundary.isRepaintBoundary) {
        boundary = boundary.parent!;
      }
      await tester.runAsync(() async {
        final layer = boundary.debugLayer! as OffsetLayer;
        final image = await layer.toImage(boundary.paintBounds);
        if (image.width != width || image.height != height) {
          throw StateError('captured ${image.width}x${image.height}, expected ${width}x$height');
        }
        final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        image.dispose();
        encoder.stdin.add(bytes!.buffer.asUint8List());
        await encoder.stdin.flush();
      });
    }

    /// Records [seconds] of whatever is on screen, or until [until].
    Future<void> record(double seconds, {bool Function()? until}) async {
      final frames = (seconds * fps).round();
      for (var i = 0; i < frames; i++) {
        log.now = frame / fps;
        await tester.pump(const Duration(microseconds: 1000000 ~/ fps));
        await capture();
        frame++;
        if (until != null && until()) break;
      }
    }

    /// Advances without recording (skips the idle start of a level).
    Future<void> skip(double seconds) async {
      for (var i = 0; i < (seconds * fps).round(); i++) {
        await tester.pump(const Duration(microseconds: 1000000 ~/ fps));
      }
    }

    NavigatorState nav() => tester.state<NavigatorState>(find.byType(Navigator).first);
    Future<GameController> open(Widget screen, {AutopilotParams? pilot}) async {
      unawaited(nav().push(MaterialPageRoute<void>(builder: (_) => screen)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final c = GameScreen.debugLastController!;
      c.feedback = log;
      // The default start delay, as in the level verification runs.
      if (pilot != null) c.autopilot = Autopilot(pilot);
      return c;
    }

    Future<void> close() async {
      nav().pop();
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    void mark(String caption, String sub, int world) =>
        segments.add({'t': frame / fps, 'caption': caption, 'sub': sub, 'world': world});

    void dressUp(String skin, String rope, String trail) {
      progress.selectSkin(skinById(skin));
      progress.equip(cosmeticById(rope));
      progress.equip(cosmeticById(trail));
    }

    /// Plays [level] with its verified autopilot for [seconds] of footage.
    Future<void> level(int level, double seconds, {double idle = 0.8}) async {
      await open(GameScreen(levelId: level), pilot: solutions[level]);
      await skip(idle);
      await record(seconds);
      await close();
    }

    await tester.pump(const Duration(milliseconds: 500));

    // 1. Playground: the slingshot start.
    dressUp('floppy', 'rainbow', 'fire');
    mark('HOLD TO SWING', 'Let go to fly', 1);
    await level(2, 3.6, idle: 0.6);

    // 2. Factory.
    dressUp('robot', 'chain', 'gold');
    mark('DODGE THE SAWS', 'World 2: Factory', 2);
    await level(24, 3.8);

    // 3. Glass City.
    dressUp('ninja', 'laser', 'stars');
    mark('SMASH THE GLASS', 'World 3: Glass City', 3);
    await level(45, 4.2);

    // 4. A fail, replayed in slow motion.
    dressUp('chicken', 'rainbow', 'fire');
    mark('FAILS ARE FUNNY', 'Every crash in slow-mo', 1);
    var c = await open(const GameScreen(levelId: 3), pilot: solutions[3]);
    await skip(0.8);
    await record(1.0);
    c.autopilot = null;
    c.pointerCancelAll();
    c.sim.ragdoll.setVelocity(c.sim.ragdoll.velocity..setValues(4, 22));
    await record(3.4, until: () => c.phase == GamePhase.replay && c.phaseAge > 1.6);
    await close();

    // 5. Sky Islands.
    dressUp('wizard', 'rainbow', 'sparkles');
    mark('RIDE THE WIND', 'World 4: Sky Islands', 4);
    await level(75, 3.8);

    // 6. Rocket Base.
    dressUp('dino', 'laser', 'fire');
    mark('DODGE ROCKETS', 'World 5: Rocket Base', 5);
    await level(86, 4.0);

    // 7. A clear: 100 levels.
    dressUp('pirate', 'rainbow', 'gold');
    mark('100 LEVELS', '5 wild worlds', 1);
    c = await open(const GameScreen(levelId: 1), pilot: solutions[1]);
    await skip(0.8);
    await record(6, until: () => c.phase == GamePhase.won && c.phaseAge > 1.8);
    mark('', '', 0);

    await tester.runAsync(() async {
      await encoder.stdin.close();
      final code = await encoder.exitCode;
      if (code != 0) throw StateError('ffmpeg exited with $code');
    });
    File('$out/gameplay.json').writeAsStringSync(
      const JsonEncoder.withIndent(' ')
          .convert({'fps': fps, 'frames': frame, 'segments': segments, 'sounds': log.sounds}),
    );
    await close();
    await tester.pump(const Duration(seconds: 3));
    tester.view.reset();
  }, timeout: const Timeout(Duration(minutes: 30)));
}
