// ignore_for_file: invalid_use_of_visible_for_testing_member
// Records the gameplay for the store promo video: the real app, played by the
// autopilot, captured at 1080x1920 and 30 fps and piped into ffmpeg. Every
// game sound is logged with its time so the mix matches the picture.
//
//   FFMPEG=/path/to/ffmpeg flutter test tool/store/promo_video_test.dart
//   python3 tool/store/make_promo_video.py      # titles, captions, music, sfx
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:floppy_swing/app.dart';
import 'package:floppy_swing/game/autopilot.dart';
import 'package:floppy_swing/game/cosmetics.dart';
import 'package:floppy_swing/game/game_controller.dart';
import 'package:floppy_swing/game/simulation.dart';
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

const fps = 30;
const width = 1080, height = 1920;
const dpr = 2.625;

/// Logs the sounds the game would play (mirrors AudioService.onEvent).
class SoundLog implements GameFeedback {
  final List<Map<String, Object>> sounds = [];
  double now = 0;

  void play(String file, [double volume = 1]) => sounds.add({'t': now, 'file': file, 'volume': volume});

  @override
  void onEvent(SimEvent e, Skin skin, Loadout look) {
    switch (e.kind) {
      case EventKind.grab:
        play('thwip.wav');
      case EventKind.launch:
        play('whoosh.wav');
        play('boing.wav', 0.5);
      case EventKind.release:
        play('whoosh.wav', 0.7);
      case EventKind.coin:
        play('coin.wav', 0.8);
      case EventKind.checkpoint:
        play('ding.wav');
      case EventKind.bounce:
        play('boing.wav');
      case EventKind.bonk:
        play(e.value > 11 ? 'bonk_big.wav' : 'bonk.wav', (e.value / 12).clamp(0.4, 1.0));
      case EventKind.death:
        if (DeathCause.values[e.value.toInt()] == DeathCause.saw) play('zing.wav');
        play('${skin.failSound}.wav');
        play('yelp.wav', 0.8);
      case EventKind.finish:
        play('win.wav');
      case EventKind.style:
        play('pop.wav', 0.7);
      case EventKind.shatter:
        play('shatter.wav');
      case EventKind.crumble:
        play('crumble.wav', e.label == 'fall' ? 1.0 : 0.5);
      case EventKind.rocket:
        play('rocket.wav', 0.6);
      case EventKind.boom:
        play('boom.wav', e.label == 'hit' ? 1.0 : 0.5);
      case EventKind.flip:
        play('flip.wav', 0.7);
      case EventKind.miss:
        break;
    }
  }

  @override
  void onReplayStart(Skin skin, Loadout look) {
    play('slowmo.wav', 0.8);
    sounds.add({'t': now + 0.75, 'file': '${skin.failSound}.wav', 'volume': 0.8});
  }
}

void main() {
  testWidgets('promo video', (tester) async {
    final ffmpeg = Platform.environment['FFMPEG'] ?? 'ffmpeg';
    await tester.runAsync(loadFonts);
    tester.view.physicalSize = const Size(width * 1.0, height * 1.0);
    tester.view.devicePixelRatio = dpr;
    final content = await tester.runAsync(() => loadContent(rootBundle));
    final progress = ProgressStore.memory(loadEconomy());
    progress.claimLoginReward();
    for (var i = 1; i <= 90; i++) {
      progress.recordWin(i, RunResult(time: 5, targetTime: 30, coins: 3, totalCoins: 3, style: 0, revived: false));
    }
    progress.addCoins(2400);
    progress.addGems(120);
    for (final id in ['banana', 'knight', 'ninja', 'pirate']) {
      progress.grantItem(id);
    }
    progress.selectSkin(skinById('floppy'));
    for (final id in ['rainbow', 'fire']) {
      progress.grantItem(id);
      progress.equip(cosmeticById(id));
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

    Directory('tool/store/out').createSync(recursive: true);
    final encoder = await tester.runAsync(
      () => Process.start(ffmpeg, [
        '-y', '-loglevel', 'error', //
        '-f', 'rawvideo', '-pix_fmt', 'rgba', '-s', '${width}x$height', '-r', '$fps', '-i', '-',
        '-c:v', 'libx264', '-preset', 'medium', '-crf', '17', '-pix_fmt', 'yuv420p',
        'tool/store/out/gameplay.mp4',
      ]),
    );
    unawaited(encoder!.stderr.transform(utf8.decoder).forEach(stderr.write));
    final log = SoundLog();
    final segments = <Map<String, Object>>[];
    var frame = 0;

    Future<void> capture() async {
      final ro = tester.renderObject(find.byType(MaterialApp));
      RenderObject boundary = ro;
      while (!boundary.isRepaintBoundary) {
        boundary = boundary.parent!;
      }
      await tester.runAsync(() async {
        final layer = boundary.debugLayer! as OffsetLayer;
        // The root boundary is already in physical pixels.
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

    NavigatorState nav() => tester.state<NavigatorState>(find.byType(Navigator).first);
    Future<GameController> open(Widget screen, {AutopilotParams? pilot}) async {
      unawaited(nav().push(MaterialPageRoute<void>(builder: (_) => screen)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final c = GameScreen.debugLastController!;
      c.feedback = log;
      if (pilot != null) c.autopilot = Autopilot(pilot, startDelay: 0.3);
      return c;
    }

    Future<void> close() async {
      nav().pop();
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    void mark(String caption) => segments.add({'t': frame / fps, 'caption': caption});

    await tester.pump(const Duration(milliseconds: 500));

    // 15 s in all (TikTok / Reels / Shorts): about 12.5 s of play here,
    // plus the title and end cards added by make_promo_video.py.

    // 1. First Swing: the slingshot start and a couple of swings.
    mark('HOLD TO SWING');
    var c = await open(
      const GameScreen(levelId: 1),
      pilot: const AutopilotParams(releaseAngle: 0.5, regrabDelay: 0.15, minFallSpeed: -2),
    );
    await record(3.5);
    await close();

    // 2. Glass City: smash through glass.
    mark('SMASH THROUGH 5 WORLDS');
    c = await open(
      const GameScreen(levelId: 45),
      pilot: const AutopilotParams(releaseAngle: 0.2, regrabDelay: 0.35, minFallSpeed: 1),
    );
    await record(3);
    await close();

    // 3. A fail, replayed in slow motion.
    mark('FAILS ARE FUNNY');
    c = await open(
      const GameScreen(levelId: 3),
      pilot: const AutopilotParams(releaseAngle: 0.5, regrabDelay: 0.15, minFallSpeed: 1),
    );
    await record(1.2);
    c.autopilot = null;
    c.pointerCancelAll();
    c.sim.ragdoll.setVelocity(c.sim.ragdoll.velocity..setValues(4, 22));
    await record(3.3, until: () => c.phase == GamePhase.replay && c.phaseAge > 1.5);
    await close();

    // 4. Rocket Base.
    mark('DODGE ROCKETS');
    c = await open(
      const GameScreen(levelId: 86),
      pilot: const AutopilotParams(releaseAngle: 0.35, regrabDelay: 0.05, minFallSpeed: -2),
    );
    await record(12.5 - frame / fps);
    mark('');

    await tester.runAsync(() async {
      await encoder.stdin.close();
      final code = await encoder.exitCode;
      if (code != 0) throw StateError('ffmpeg exited with $code');
    });
    File('tool/store/out/gameplay.json').writeAsStringSync(
      const JsonEncoder.withIndent(' ').convert({
        'fps': fps,
        'frames': frame,
        'segments': segments,
        'sounds': log.sounds,
      }),
    );
    // Let the game screen's own timers finish before the test ends.
    await close();
    await tester.pump(const Duration(seconds: 3));
    tester.view.reset();
  }, timeout: const Timeout(Duration(minutes: 30)));
}
