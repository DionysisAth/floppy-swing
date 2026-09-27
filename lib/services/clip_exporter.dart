import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../game/game_controller.dart';
import '../game/renderer.dart';
import '../game/simulation.dart';

/// Text used on the clip's end card and in the share sheet. Put the real
/// store link here once the game is live.
abstract final class ShareText {
  static const tagline = 'Can you do better?';
  static const cta = 'Floppy Swing - free on iOS & Android';
  static const link = 'floppyswing.app';
  static const hashtags = '#FloppySwing #fail #gaming';
}

/// Turns the last few seconds of play into a vertical 9:16 MP4 with a
/// watermark, the slow-motion replay and a "Can you do better?" end card,
/// then opens the native share sheet.
///
/// Frames are rendered in Dart with the game renderer and encoded natively
/// (AVAssetWriter on iOS, MediaCodec on Android) through the
/// `floppy_swing/video` channel.
class ClipExporter {
  ClipExporter({this.width = 720, this.height = 1280, this.fps = 30});

  static const _channel = MethodChannel('floppy_swing/video');

  final int width;
  final int height;
  final int fps;

  static const _liveSeconds = 4.0;
  static const _endCardSeconds = 1.6;

  /// Builds the frame list for the clip from the controller's history.
  List<_ClipFrame> _plan(GameController c) {
    final frames = <_ClipFrame>[];
    final history = c.history.toList();
    if (history.isEmpty) return frames;
    final died = c.phase == GamePhase.dying ||
        c.phase == GamePhase.replay ||
        c.phase == GamePhase.failed;
    final end = died ? c.deathSimTime + 0.3 : math.min(history.last.s.t, (c.sim.endedAt ?? history.last.s.t) + 1.2);
    final start = math.max(history.first.s.t, end - _liveSeconds);
    final dt = 1 / fps;
    for (var t = start; t <= end; t += dt) {
      frames.add(_ClipFrame(c.frameAt(t)));
    }
    if (died) {
      // The slow-motion replay, exactly as shown in game.
      const total = GameController.replayBefore + GameController.replayAfter;
      for (var clock = 0.0; clock <= total; clock += dt * GameController.replaySlowMo) {
        frames.add(_ClipFrame(c.replayFrame(clock), slowMo: true));
      }
    }
    final endCard = (_endCardSeconds * fps).round();
    for (var i = 0; i < endCard; i++) {
      frames.add(_ClipFrame(null, endCard: i / endCard));
    }
    return frames;
  }

  /// Renders and encodes the clip, then shares it. [onProgress] gets 0..1.
  Future<void> exportAndShare(
    GameController c, {
    required String caption,
    Rect? shareOrigin,
    void Function(double progress)? onProgress,
  }) async {
    final plan = _plan(c);
    if (plan.isEmpty) return;
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${dir.path}/floppy_swing_$stamp.mp4';
    final died = c.phase != GamePhase.won;

    try {
      await _channel.invokeMethod<void>('start', {
        'path': path,
        'width': width,
        'height': height,
        'fps': fps,
      });
    } on MissingPluginException {
      await _shareStill(c, plan, caption, shareOrigin, dir.path, stamp);
      return;
    } on PlatformException catch (e) {
      debugPrint('Video encoder unavailable: $e');
      await _shareStill(c, plan, caption, shareOrigin, dir.path, stamp);
      return;
    }

    try {
      for (var i = 0; i < plan.length; i++) {
        final image = _render(c, plan[i], died: died, caption: caption);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        image.dispose();
        await _channel.invokeMethod<void>('frame', bytes!.buffer.asUint8List());
        onProgress?.call((i + 1) / plan.length);
      }
      await _channel.invokeMethod<String>('finish');
    } catch (e) {
      await _channel.invokeMethod<void>('cancel').catchError((_) {});
      rethrow;
    }

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path, mimeType: 'video/mp4')],
        text: '${ShareText.tagline} ${ShareText.hashtags}',
        sharePositionOrigin: shareOrigin,
      ),
    );
  }

  /// Fallback when there is no native encoder: share the key frame as a PNG.
  Future<void> _shareStill(
    GameController c,
    List<_ClipFrame> plan,
    String caption,
    Rect? origin,
    String dir,
    int stamp,
  ) async {
    final died = c.phase != GamePhase.won;
    final key = plan.lastWhere((f) => f.frame != null, orElse: () => plan.first);
    final image = _render(c, key, died: died, caption: caption);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final path = '$dir/floppy_swing_$stamp.png';
    await File(path).writeAsBytes(png!.buffer.asUint8List());
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path, mimeType: 'image/png')],
        text: '${ShareText.tagline} ${ShareText.hashtags}',
        sharePositionOrigin: origin,
      ),
    );
  }

  ui.Image _render(GameController c, _ClipFrame f, {required bool died, required String caption}) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width.toDouble(), height.toDouble());
    final frame = f.frame;
    if (frame == null) {
      _endCard(canvas, size, f.endCard, died: died, caption: caption);
    } else {
      c.renderer.render(canvas, size, frame, events: c.events, showTarget: false, trail: c.trailAt(frame.s.t));
      if (f.slowMo) _slowMoBadge(canvas, size);
      _watermark(canvas, size);
    }
    final picture = recorder.endRecording();
    final image = picture.toImageSync(width, height);
    picture.dispose();
    return image;
  }

  TextPainter _tp(String text, double size, Color color, {double? maxWidth}) => TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'LilitaOne',
        fontSize: size,
        color: color,
        shadows: const [Shadow(color: Color(0xFF2B1D14), offset: Offset(3, 4))],
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth ?? double.infinity);

  void _watermark(Canvas canvas, Size size) {
    final tp = _tp('FLOPPY SWING', 34, const Color(0xFFFFFFFF));
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(24, 40, tp.width + 36, tp.height + 16),
      const Radius.circular(40),
    );
    canvas.drawRRect(r, Paint()..color = const Color(0x882B1D14));
    tp.paint(canvas, Offset(42, 48));
  }

  void _slowMoBadge(Canvas canvas, Size size) {
    final tp = _tp('SLOW-MO REPLAY', 40, const Color(0xFFFFE14D));
    tp.paint(canvas, Offset((size.width - tp.width) / 2, size.height - 160));
  }

  void _endCard(Canvas canvas, Size size, double t, {required bool died, required String caption}) {
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, size.height),
        const [Color(0xFFFF8A3D), Color(0xFFFF4E8A)],
      );
    canvas.drawRect(Offset.zero & size, paint);
    final pop = t < 0.15 ? Curves.easeOutBack.transform(t / 0.15) : 1.0;
    canvas.save();
    canvas.translate(size.width / 2, size.height * 0.38);
    canvas.scale(pop);
    final title = _tp(ShareText.tagline, 92, const Color(0xFFFFFFFF), maxWidth: size.width - 80);
    title.paint(canvas, Offset(-title.width / 2, -title.height / 2));
    canvas.restore();
    final cap = _tp(caption, 44, const Color(0xFFFFE14D), maxWidth: size.width - 80);
    cap.paint(canvas, Offset((size.width - cap.width) / 2, size.height * 0.52));
    final logo = _tp('FLOPPY SWING', 78, const Color(0xFFFFFFFF));
    logo.paint(canvas, Offset((size.width - logo.width) / 2, size.height * 0.68));
    final cta = _tp('${ShareText.cta}\n${ShareText.link}', 32, const Color(0xFFFFFFFF), maxWidth: size.width - 80);
    cta.paint(canvas, Offset((size.width - cta.width) / 2, size.height * 0.8));
  }
}

class _ClipFrame {
  _ClipFrame(this.frame, {this.slowMo = false, this.endCard = 0});
  final Frame? frame;
  final bool slowMo;
  final double endCard;
}

/// Short caption for a run, used on the end card.
String clipCaption(GameController c) {
  if (c.phase == GamePhase.won) {
    final r = c.result;
    return r == null ? 'Level ${c.level.id} cleared!' : 'Level ${c.level.id} in ${r.time.toStringAsFixed(2)}s';
  }
  return switch (c.sim.deathCause) {
    DeathCause.saw => 'Met a saw on level ${c.level.id}',
    DeathCause.spikes => 'Found the spikes on level ${c.level.id}',
    DeathCause.pit => 'Missed everything on level ${c.level.id}',
    DeathCause.stuck => 'Took a nap on level ${c.level.id}',
    null => 'Level ${c.level.id}',
  };
}
