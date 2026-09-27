import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'level.dart';
import 'ragdoll.dart';
import 'simulation.dart';
import 'skins.dart';

/// Camera: centre point and visible width, all in meters.
class Cam {
  const Cam(this.x, this.y, this.w);
  final double x;
  final double y;
  final double w;

  Cam lerp(Cam o, double t) =>
      Cam(x + (o.x - x) * t, y + (o.y - y) * t, w + (o.w - w) * t);
}

/// One recorded frame: the simulation snapshot plus where the camera was.
class Frame {
  const Frame(this.s, this.cam);
  final Snapshot s;
  final Cam cam;
}

abstract final class Palette {
  static const skyTop = Color(0xFF7CC8FF);
  static const skyBottom = Color(0xFFFFF1CF);
  static const hillFar = Color(0xFFA8E07A);
  static const hillNear = Color(0xFF79C956);
  static const dirt = Color(0xFF8A5A33);
  static const dirtDark = Color(0xFF5E3B1F);
  static const grass = Color(0xFF5BC236);
  static const ink = Color(0xFF2B1D14);
  static const danger = Color(0xFFE63B2E);
  static const dangerDark = Color(0xFF9E1D14);
  static const dangerLight = Color(0xFFFF7A45);
  static const saw = Color(0xFFFF5E2B);
  static const pad = Color(0xFF2FBF71);
  static const padTop = Color(0xFFB6FF5C);
  static const anchor = Color(0xFF2D9CFF);
  static const anchorGlow = Color(0xFFFFE14D);
  static const coin = Color(0xFFFFD23F);
  static const coinEdge = Color(0xFFE09A00);
  static const rope = Color(0xFF7A5528);
  static const white = Color(0xFFFFFFFF);
}

/// Draws a level and a [Frame] onto a canvas. Stateless apart from caches, so
/// the same renderer draws live play, slow-motion replays and exported clips.
class WorldRenderer {
  WorldRenderer(this.level, this.skin) : _extent = level.extent;

  final Level level;
  Skin skin;
  final ({double minX, double maxX, double minY}) _extent;
  final Map<String, TextPainter> _textCache = {};

  final Paint _fill = Paint()..isAntiAlias = true;
  final Paint _stroke = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  /// Renders everything. [time] is the simulation time used for effects and
  /// [wallTime] drives purely cosmetic animation (pulsing, coin spin).
  void render(
    Canvas canvas,
    Size size,
    Frame frame, {
    required List<SimEvent> events,
    double? wallTime,
    bool showTarget = true,
  }) {
    final s = frame.s;
    final cam = frame.cam;
    final time = s.t;
    final wt = wallTime ?? time;
    final scale = size.width / cam.w;

    _drawBackground(canvas, size, cam, scale);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    canvas.translate(-cam.x, -cam.y);
    final halfH = size.height / scale / 2;
    final view = Rect.fromLTRB(
      cam.x - cam.w / 2 - 2,
      cam.y - halfH - 2,
      cam.x + cam.w / 2 + 2,
      cam.y + halfH + 2,
    );

    _drawPit(canvas, view);
    _drawFinish(canvas, view, wt);
    for (var i = 0; i < level.checkpoints.length; i++) {
      _drawCheckpoint(canvas, view, level.checkpoints[i], s.checkpointReached(i), wt);
    }
    for (final p in level.platforms) {
      if (_visible(view, p.x, p.y, math.max(p.w, p.h))) _drawPlatform(canvas, p);
    }
    for (final sp in level.spikes) {
      if (_visible(view, sp.x, sp.y, math.max(sp.w, sp.h))) _drawSpikes(canvas, sp);
    }
    for (var i = 0; i < level.pads.length; i++) {
      final p = level.pads[i];
      if (_visible(view, p.x, p.y, p.w)) _drawPad(canvas, p, _padSquash(events, i, time));
    }
    for (var i = 0; i < level.saws.length; i++) {
      final x = s.saws[i * 3], y = s.saws[i * 3 + 1], a = s.saws[i * 3 + 2];
      if (_visible(view, x, y, level.saws[i].r * 2)) {
        _drawSaw(canvas, x, y, level.saws[i].r, a);
      }
    }
    for (var i = 0; i < level.anchors.length; i++) {
      final a = level.anchors[i];
      if (!_visible(view, a.x, a.y, 2)) continue;
      _drawAnchor(
        canvas,
        a,
        attached: s.ropeAnchor == i,
        target: showTarget && s.targetAnchor == i,
        grabFlash: _since(events, EventKind.grab, time, i.toDouble()),
        wt: wt,
      );
    }
    for (var i = 0; i < level.coins.length; i++) {
      if (s.coinTaken(i)) continue;
      final c = level.coins[i];
      if (_visible(view, c.x, c.y, 1)) _drawCoin(canvas, c.x, c.y, wt * 4 + i * 0.7);
    }

    if (s.ropeAnchor >= 0) _drawRope(canvas, s);
    drawRagdoll(canvas, s, skin, wt);
    _drawEffects(canvas, events, time);
    canvas.restore();
  }

  bool _visible(Rect view, double x, double y, double size) =>
      x + size > view.left &&
      x - size < view.right &&
      y + size > view.top &&
      y - size < view.bottom;

  // ------------------------------------------------------------ background

  void _drawBackground(Canvas canvas, Size size, Cam cam, double scale) {
    final rect = Offset.zero & size;
    _fill.shader = ui.Gradient.linear(
      Offset.zero,
      Offset(0, size.height),
      const [Palette.skyTop, Palette.skyBottom],
    );
    canvas.drawRect(rect, _fill);
    _fill.shader = null;

    // Clouds drift slowly with parallax.
    _fill.color = const Color(0xE6FFFFFF);
    final cloudPx = scale * 0.8;
    for (var i = 0; i < 6; i++) {
      final wx = i * 23.0 + (i.isEven ? 5 : 0);
      var x = (wx - cam.x * 0.15) * cloudPx;
      final period = 6 * 23.0 * cloudPx;
      x = ((x % period) + period) % period - 3 * cloudPx;
      final y = size.height * (0.1 + 0.07 * (i % 3)) - (cam.y * 0.05) * cloudPx;
      _cloud(canvas, Offset(x, y), cloudPx * (1.4 + (i % 2) * 0.6));
    }

    // Two layers of rolling hills.
    _hills(canvas, size, cam, scale, 0.25, 0.72, Palette.hillFar, 9, 1.8);
    _hills(canvas, size, cam, scale, 0.45, 0.8, Palette.hillNear, 6, 1.3);
  }

  void _cloud(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(c, r, _fill);
    canvas.drawCircle(c + Offset(r * 0.9, r * 0.2), r * 0.8, _fill);
    canvas.drawCircle(c + Offset(-r * 0.9, r * 0.25), r * 0.7, _fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(c.dx - r * 1.55, c.dy - r * 0.2, c.dx + r * 1.65, c.dy + r * 0.8), Radius.circular(r * 0.5)),
      _fill,
    );
  }

  void _hills(
    Canvas canvas,
    Size size,
    Cam cam,
    double scale,
    double parallax,
    double baseFrac,
    Color color,
    double wavelength,
    double amp,
  ) {
    final path = Path()..moveTo(0, size.height);
    final base = size.height * baseFrac - cam.y * parallax * scale * 0.2;
    for (var px = 0.0; px <= size.width + 8; px += 8) {
      final wx = cam.x * parallax + (px - size.width / 2) / scale;
      final h = math.sin(wx / wavelength) * amp + math.sin(wx / (wavelength * 0.43) + 1.3) * amp * 0.4;
      path.lineTo(px, base - h * scale);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    _fill.color = color;
    canvas.drawPath(path, _fill);
  }

  // ------------------------------------------------------------ level parts

  void _drawPit(Canvas canvas, Rect view) {
    final y = level.killY;
    if (y - 1 > view.bottom) return;
    final left = math.max(view.left, _extent.minX - 30);
    final right = math.min(view.right, _extent.maxX + 30);
    if (right <= left) return;
    _fill.color = Palette.dangerDark;
    canvas.drawRect(Rect.fromLTRB(left, y, right, view.bottom + 10), _fill);
    const w = 0.7;
    final start = (left / w).floor() * w;
    final teeth = Path();
    for (var x = start; x < right; x += w) {
      teeth
        ..moveTo(x, y + 0.05)
        ..lineTo(x + w / 2, y - 0.75)
        ..lineTo(x + w, y + 0.05);
    }
    _fill.color = Palette.danger;
    canvas.drawPath(teeth, _fill);
    _stroke
      ..color = Palette.dangerDark
      ..strokeWidth = 0.06;
    canvas.drawPath(teeth, _stroke);
  }

  void _withBox(Canvas canvas, Box b, void Function() draw) {
    canvas.save();
    canvas.translate(b.x, b.y);
    canvas.rotate(b.angle);
    draw();
    canvas.restore();
  }

  void _drawPlatform(Canvas canvas, Box b) {
    _withBox(canvas, b, () {
      final r = Rect.fromCenter(center: Offset.zero, width: b.w, height: b.h);
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(0.25));
      _fill.color = Palette.dirt;
      canvas.drawRRect(rr, _fill);
      // Speckles.
      _fill.color = Palette.dirtDark;
      for (var i = 0; i < (b.w * b.h).clamp(1, 40); i++) {
        final fx = ((i * 0.618) % 1.0) - 0.5, fy = ((i * 0.37) % 1.0) - 0.5;
        canvas.drawCircle(Offset(fx * b.w * 0.85, fy * b.h * 0.7 + 0.1), 0.07, _fill);
      }
      // Grass cap.
      final grass = RRect.fromRectAndRadius(
        Rect.fromLTRB(r.left - 0.05, r.top - 0.05, r.right + 0.05, r.top + math.min(0.35, b.h * 0.45)),
        const Radius.circular(0.2),
      );
      _fill.color = Palette.grass;
      canvas.drawRRect(grass, _fill);
      _stroke
        ..color = Palette.ink
        ..strokeWidth = 0.08;
      canvas.drawRRect(rr, _stroke);
    });
  }

  void _drawSpikes(Canvas canvas, Box b) {
    _withBox(canvas, b, () {
      const tooth = 0.55, height = 0.45;
      final core = Rect.fromCenter(center: Offset.zero, width: b.w, height: b.h);
      final teeth = Path();
      void edge(Offset a, Offset c, Offset outward) {
        final len = (c - a).distance;
        final n = math.max(1, (len / tooth).round());
        for (var i = 0; i < n; i++) {
          final p0 = Offset.lerp(a, c, i / n)!;
          final p1 = Offset.lerp(a, c, (i + 1) / n)!;
          final mid = Offset.lerp(p0, p1, 0.5)! + outward * height;
          teeth
            ..moveTo(p0.dx, p0.dy)
            ..lineTo(mid.dx, mid.dy)
            ..lineTo(p1.dx, p1.dy)
            ..close();
        }
      }

      edge(core.topLeft, core.topRight, const Offset(0, -1));
      edge(core.bottomRight, core.bottomLeft, const Offset(0, 1));
      edge(core.topRight, core.bottomRight, const Offset(1, 0));
      edge(core.bottomLeft, core.topLeft, const Offset(-1, 0));
      _fill.color = Palette.dangerLight;
      canvas.drawPath(teeth, _fill);
      _stroke
        ..color = Palette.dangerDark
        ..strokeWidth = 0.06;
      canvas.drawPath(teeth, _stroke);
      final rr = RRect.fromRectAndRadius(core, const Radius.circular(0.12));
      _fill.color = Palette.danger;
      canvas.drawRRect(rr, _fill);
      // Warning stripes.
      canvas.save();
      canvas.clipRRect(rr);
      _fill.color = Palette.dangerDark.withValues(alpha: 0.35);
      for (var x = -b.w / 2 - b.h; x < b.w / 2 + b.h; x += 0.8) {
        canvas.drawPath(
          Path()
            ..moveTo(x, b.h / 2)
            ..lineTo(x + 0.35, b.h / 2)
            ..lineTo(x + 0.35 + b.h, -b.h / 2)
            ..lineTo(x + b.h, -b.h / 2)
            ..close(),
          _fill,
        );
      }
      canvas.restore();
      canvas.drawRRect(rr, _stroke);
    });
  }

  double _padSquash(List<SimEvent> events, int index, double time) {
    final since = _since(events, EventKind.bounce, time, index.toDouble());
    if (since == null || since > 0.35) return 0;
    return math.sin(since / 0.35 * math.pi) * (1 - since / 0.35);
  }

  void _drawPad(Canvas canvas, Box b, double squash) {
    _withBox(canvas, b, () {
      final base = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, b.h * 0.15), width: b.w, height: b.h * 0.7),
        const Radius.circular(0.15),
      );
      _fill.color = Palette.pad;
      canvas.drawRRect(base, _fill);
      // Spring zig-zag, stretched on bounce.
      final lift = 0.25 + squash * 0.7;
      final spring = Path()..moveTo(-b.w * 0.3, -b.h * 0.2);
      for (var i = 1; i <= 6; i++) {
        spring.lineTo((i.isEven ? -0.3 : 0.3) * b.w, -b.h * 0.2 - lift * i / 6);
      }
      _stroke
        ..color = const Color(0xFF1C6B40)
        ..strokeWidth = 0.1;
      canvas.drawPath(spring, _stroke);
      final top = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -b.h * 0.2 - lift - 0.12), width: b.w * (1 + squash * 0.15), height: 0.28),
        const Radius.circular(0.14),
      );
      _fill.color = Palette.padTop;
      canvas.drawRRect(top, _fill);
      _stroke
        ..color = Palette.ink
        ..strokeWidth = 0.07;
      canvas.drawRRect(top, _stroke);
      canvas.drawRRect(base, _stroke);
      // Up arrow hint.
      _fill.color = const Color(0xCCFFFFFF);
      canvas.drawPath(
        Path()
          ..moveTo(0, -0.05)
          ..lineTo(0.25, 0.25)
          ..lineTo(-0.25, 0.25)
          ..close(),
        _fill,
      );
    });
  }

  void _drawSaw(Canvas canvas, double x, double y, double r, double angle) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    const teeth = 14;
    final path = Path();
    for (var i = 0; i < teeth; i++) {
      final a0 = i / teeth * math.pi * 2;
      final a1 = (i + 0.55) / teeth * math.pi * 2;
      final a2 = (i + 1) / teeth * math.pi * 2;
      final p0 = Offset(math.cos(a0), math.sin(a0)) * r * 0.82;
      final p1 = Offset(math.cos(a1), math.sin(a1)) * r;
      final p2 = Offset(math.cos(a2), math.sin(a2)) * r * 0.82;
      if (i == 0) path.moveTo(p0.dx, p0.dy);
      path
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy);
    }
    path.close();
    _fill.color = Palette.saw;
    canvas.drawPath(path, _fill);
    _stroke
      ..color = Palette.dangerDark
      ..strokeWidth = 0.07;
    canvas.drawPath(path, _stroke);
    _fill.color = const Color(0xFFFFB38A);
    canvas.drawCircle(Offset.zero, r * 0.55, _fill);
    _fill.color = const Color(0xFFDDDDDD);
    canvas.drawCircle(Offset.zero, r * 0.25, _fill);
    canvas.drawCircle(Offset.zero, r * 0.25, _stroke);
    _stroke.strokeWidth = 0.05;
    for (var i = 0; i < 3; i++) {
      final a = i * math.pi * 2 / 3;
      canvas.drawLine(
        Offset(math.cos(a), math.sin(a)) * r * 0.28,
        Offset(math.cos(a), math.sin(a)) * r * 0.52,
        _stroke,
      );
    }
    canvas.restore();
  }

  void _drawAnchor(
    Canvas canvas,
    P a, {
    required bool attached,
    required bool target,
    required double? grabFlash,
    required double wt,
  }) {
    final c = Offset(a.x, a.y);
    if (target) {
      final pulse = 0.5 + 0.5 * math.sin(wt * 8);
      _fill.color = Palette.anchorGlow.withValues(alpha: 0.35 + 0.25 * pulse);
      canvas.drawCircle(c, 0.75 + 0.15 * pulse, _fill);
    }
    if (grabFlash != null && grabFlash < 0.25) {
      _stroke
        ..color = Palette.white.withValues(alpha: 1 - grabFlash / 0.25)
        ..strokeWidth = 0.12;
      canvas.drawCircle(c, 0.5 + grabFlash * 4, _stroke);
    }
    _fill.color = attached ? Palette.anchorGlow : Palette.white;
    canvas.drawCircle(c, 0.42, _fill);
    _stroke
      ..color = Palette.anchor
      ..strokeWidth = 0.16;
    canvas.drawCircle(c, 0.42, _stroke);
    _fill.color = Palette.anchor;
    canvas.drawCircle(c, 0.14, _fill);
  }

  void _drawCoin(Canvas canvas, double x, double y, double phase) {
    final sx = math.cos(phase).abs() * 0.85 + 0.15;
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(sx, 1);
    _fill.color = Palette.coin;
    canvas.drawCircle(Offset.zero, 0.36, _fill);
    _stroke
      ..color = Palette.coinEdge
      ..strokeWidth = 0.08;
    canvas.drawCircle(Offset.zero, 0.36, _stroke);
    canvas.drawCircle(Offset.zero, 0.2, _stroke);
    canvas.restore();
  }

  void _drawCheckpoint(Canvas canvas, Rect view, P c, bool reached, double wt) {
    if (!_visible(view, c.x, c.y, 4)) return;
    _stroke
      ..color = const Color(0xFF5A5A5A)
      ..strokeWidth = 0.14;
    canvas.drawLine(Offset(c.x, c.y), Offset(c.x, c.y - 3.2), _stroke);
    final wave = math.sin(wt * 5) * 0.12;
    final flag = Path()
      ..moveTo(c.x, c.y - 3.2)
      ..quadraticBezierTo(c.x + 0.8, c.y - 3.2 + wave, c.x + 1.6, c.y - 2.9)
      ..quadraticBezierTo(c.x + 0.8, c.y - 2.6 - wave, c.x, c.y - 2.3)
      ..close();
    _fill.color = reached ? const Color(0xFF38D66B) : const Color(0xFFBBBBBB);
    canvas.drawPath(flag, _fill);
    _stroke
      ..color = Palette.ink
      ..strokeWidth = 0.06;
    canvas.drawPath(flag, _stroke);
  }

  void _drawFinish(Canvas canvas, Rect view, double wt) {
    final f = level.finish;
    if (!_visible(view, f.x, f.y, math.max(f.w, f.h))) return;
    final left = f.x - f.w / 2, right = f.x + f.w / 2;
    final top = f.y - f.h / 2, bottom = f.y + f.h / 2;
    _fill.color = const Color(0x33FFFFFF);
    canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), _fill);
    _stroke
      ..color = const Color(0xFF444444)
      ..strokeWidth = 0.18;
    canvas.drawLine(Offset(left, bottom), Offset(left, top - 0.4), _stroke);
    canvas.drawLine(Offset(right, bottom), Offset(right, top - 0.4), _stroke);
    // Checkered banner.
    final bannerTop = top - 0.4, bannerH = 1.0;
    const cells = 10;
    final cw = f.w / cells;
    for (var i = 0; i < cells; i++) {
      for (var j = 0; j < 2; j++) {
        _fill.color = (i + j).isEven ? Palette.ink : Palette.white;
        final wave = math.sin(wt * 3 + i * 0.6) * 0.08;
        canvas.drawRect(
          Rect.fromLTWH(left + i * cw, bannerTop + j * bannerH / 2 + wave, cw + 0.01, bannerH / 2),
          _fill,
        );
      }
    }
  }

  // --------------------------------------------------------------- ragdoll

  void _drawRope(Canvas canvas, Snapshot s) {
    final a = level.anchors[s.ropeAnchor];
    final hand = handPosition(s);
    final dx = a.x - hand.dx, dy = a.y - hand.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final slack = math.max(0.0, s.ropeLength - dist);
    final sag = math.min(2.0, math.sqrt(slack * dist) * 0.5);
    final mid = Offset((a.x + hand.dx) / 2, (a.y + hand.dy) / 2 + sag);
    final path = Path()
      ..moveTo(hand.dx, hand.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, a.x, a.y);
    _stroke
      ..color = Palette.ink
      ..strokeWidth = 0.16;
    canvas.drawPath(path, _stroke);
    _stroke
      ..color = Palette.rope
      ..strokeWidth = 0.09;
    canvas.drawPath(path, _stroke);
  }

  static Offset handPosition(Snapshot s) {
    const i = Part.ropeHand;
    final a = s.pa(i);
    final hh = partSpecs[i].hh;
    return Offset(s.px(i) - math.sin(a) * hh, s.py(i) + math.cos(a) * hh);
  }

  /// Draws the ragdoll from a snapshot. Public so the shop can preview skins.
  void drawRagdoll(Canvas canvas, Snapshot s, Skin skin, double wt) {
    final dead = s.status == SimStatus.dead;
    final speed = math.sqrt(s.vx * s.vx + s.vy * s.vy);
    Color shade(Color c) => Color.lerp(c, const Color(0xFF000000), 0.18)!;

    void limb(int i, Color c, {bool back = false}) {
      final spec = partSpecs[i];
      canvas.save();
      canvas.translate(s.px(i), s.py(i));
      canvas.rotate(s.pa(i));
      final rr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: spec.hw * 2, height: spec.hh * 2 + spec.hw * 0.6),
        Radius.circular(spec.hw),
      );
      _fill.color = back ? shade(c) : c;
      canvas.drawRRect(rr, _fill);
      _stroke
        ..color = skin.outline
        ..strokeWidth = 0.05;
      canvas.drawRRect(rr, _stroke);
      // Shoes / gloves on the far end of lower limbs.
      if (i == Part.lowerLegBack || i == Part.lowerLegFront) {
        _fill.color = back ? shade(skin.shoes) : skin.shoes;
        final shoe = RRect.fromRectAndRadius(
          Rect.fromLTWH(-spec.hw * 1.1, spec.hh - 0.08, spec.hw * 3.0, 0.2),
          const Radius.circular(0.1),
        );
        canvas.drawRRect(shoe, _fill);
        canvas.drawRRect(shoe, _stroke);
      }
      canvas.restore();
    }

    limb(Part.upperArmBack, skin.sleeves, back: true);
    limb(Part.lowerArmBack, skin.skin, back: true);
    limb(Part.upperLegBack, skin.pants, back: true);
    limb(Part.lowerLegBack, skin.pants, back: true);
    _drawTorso(canvas, s, skin);
    limb(Part.upperLegFront, skin.pants);
    limb(Part.lowerLegFront, skin.pants);
    _drawHead(canvas, s, skin, dead: dead, speed: speed, wt: wt);
    limb(Part.upperArmFront, skin.sleeves);
    limb(Part.lowerArmFront, skin.skin);
  }

  void _drawTorso(Canvas canvas, Snapshot s, Skin skin) {
    const i = Part.torso;
    final spec = partSpecs[i];
    canvas.save();
    canvas.translate(s.px(i), s.py(i));
    canvas.rotate(s.pa(i));
    final rr = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: spec.hw * 2.1, height: spec.hh * 2.1),
      const Radius.circular(0.16),
    );
    _fill.color = skin.shirt;
    canvas.drawRRect(rr, _fill);
    // Belt.
    _fill.color = skin.pants;
    canvas.drawRect(Rect.fromLTRB(-spec.hw * 1.05, spec.hh * 0.62, spec.hw * 1.05, spec.hh * 1.05), _fill);
    switch (skin.accessory) {
      case Accessory.astronaut:
        _fill.color = const Color(0xFFB0BCC8);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(-spec.hw * 1.6, -spec.hh * 0.7, spec.hw * 0.6, spec.hh), const Radius.circular(0.06)),
          _fill,
        );
        _fill.color = const Color(0xFFFF4D4D);
        canvas.drawCircle(Offset(spec.hw * 0.35, -spec.hh * 0.35), 0.06, _fill);
      case Accessory.knight:
        _stroke
          ..color = const Color(0xFF6E7A86)
          ..strokeWidth = 0.04;
        canvas.drawLine(Offset(0, -spec.hh), Offset(0, spec.hh * 0.6), _stroke);
      case Accessory.ninja:
        _fill.color = const Color(0xFFE63946);
        canvas.drawRect(Rect.fromLTRB(-spec.hw * 1.05, spec.hh * 0.45, spec.hw * 1.05, spec.hh * 0.62), _fill);
      case Accessory.hair:
      case Accessory.banana:
      case Accessory.chicken:
        break;
    }
    _stroke
      ..color = skin.outline
      ..strokeWidth = 0.05;
    canvas.drawRRect(rr, _stroke);
    canvas.restore();
  }

  void _drawHead(
    Canvas canvas,
    Snapshot s,
    Skin skin, {
    required bool dead,
    required double speed,
    required double wt,
  }) {
    const i = Part.head;
    final r = partSpecs[i].hw;
    canvas.save();
    canvas.translate(s.px(i), s.py(i));
    canvas.rotate(s.pa(i));
    final headAngle = s.pa(i);

    // Behind-head accessories.
    if (skin.accessory == Accessory.ninja) {
      _stroke
        ..color = const Color(0xFFE63946)
        ..strokeWidth = 0.07;
      final flap = math.sin(wt * 14) * 0.08;
      canvas.drawLine(Offset(-r * 0.9, -r * 0.2), Offset(-r * 2.1, -r * 0.1 + flap), _stroke);
      canvas.drawLine(Offset(-r * 0.9, -r * 0.1), Offset(-r * 1.9, r * 0.3 - flap), _stroke);
    }

    _fill.color = skin.skin;
    canvas.drawCircle(Offset.zero, r, _fill);
    _stroke
      ..color = skin.outline
      ..strokeWidth = 0.05;
    canvas.drawCircle(Offset.zero, r, _stroke);

    switch (skin.accessory) {
      case Accessory.hair:
        _fill.color = const Color(0xFF6B3E1E);
        canvas.drawPath(
          Path()
            ..moveTo(-r * 0.9, -r * 0.35)
            ..quadraticBezierTo(-r * 0.2, -r * 1.5, r * 0.8, -r * 0.55)
            ..quadraticBezierTo(r * 0.2, -r * 0.8, -r * 0.9, -r * 0.35),
          _fill,
        );
      case Accessory.banana:
        _fill.color = const Color(0xFF6B4A1E);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(-r * 0.15, -r * 1.45, r * 0.3, r * 0.6), const Radius.circular(0.04)),
          _fill,
        );
      case Accessory.chicken:
        _fill.color = const Color(0xFFE63946);
        for (var k = 0; k < 3; k++) {
          canvas.drawCircle(Offset(-r * 0.35 + k * r * 0.35, -r * 1.0 - (k == 1 ? 0.06 : 0)), r * 0.24, _fill);
        }
        canvas.drawCircle(Offset(r * 0.8, r * 0.55), r * 0.18, _fill);
      case Accessory.ninja:
        _fill.color = const Color(0xFFFFD2A8);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(-r * 0.2, -r * 0.45, r * 1.15, r * 0.45), Radius.circular(r * 0.2)),
          _fill,
        );
        _fill.color = const Color(0xFFE63946);
        canvas.drawRect(Rect.fromLTRB(-r, -r * 0.75, r, -r * 0.5), _fill);
      case Accessory.knight:
      case Accessory.astronaut:
        break;
    }

    _drawFace(canvas, s, r, headAngle, dead: dead, speed: speed, skin: skin);

    switch (skin.accessory) {
      case Accessory.knight:
        _fill.color = const Color(0xFFC3CCD5);
        final helmet = Path()
          ..addArc(Rect.fromCircle(center: Offset.zero, radius: r * 1.08), math.pi, math.pi)
          ..lineTo(r * 1.08, r * 0.1)
          ..lineTo(-r * 1.08, r * 0.1)
          ..close();
        canvas.drawPath(helmet, _fill);
        _stroke.color = skin.outline;
        canvas.drawPath(helmet, _stroke);
        _fill.color = const Color(0xFF2B2D42);
        canvas.drawRect(Rect.fromLTRB(-r * 0.1, -r * 0.3, r * 0.95, -r * 0.12), _fill);
        _fill.color = const Color(0xFFE63946);
        canvas.drawPath(
          Path()
            ..moveTo(-r * 0.2, -r * 1.05)
            ..quadraticBezierTo(-r * 1.4, -r * 1.9, -r * 1.3, -r * 0.6)
            ..quadraticBezierTo(-r * 0.9, -r * 1.2, -r * 0.2, -r * 1.05),
          _fill,
        );
      case Accessory.astronaut:
        _fill.color = const Color(0x5599DDFF);
        canvas.drawCircle(Offset.zero, r * 1.35, _fill);
        _stroke
          ..color = const Color(0xFFDDE6EE)
          ..strokeWidth = 0.08;
        canvas.drawCircle(Offset.zero, r * 1.35, _stroke);
        _fill.color = const Color(0xAAFFFFFF);
        canvas.drawCircle(Offset(-r * 0.5, -r * 0.7), r * 0.18, _fill);
      case Accessory.chicken:
        _fill.color = const Color(0xFFFF9F1C);
        canvas.drawPath(
          Path()
            ..moveTo(r * 0.85, r * 0.0)
            ..lineTo(r * 1.5, r * 0.18)
            ..lineTo(r * 0.85, r * 0.36)
            ..close(),
          _fill,
        );
      case Accessory.hair:
      case Accessory.banana:
      case Accessory.ninja:
        break;
    }
    canvas.restore();
  }

  void _drawFace(
    Canvas canvas,
    Snapshot s,
    double r,
    double headAngle, {
    required bool dead,
    required double speed,
    required Skin skin,
  }) {
    final eyeY = -r * 0.15;
    final eyes = [Offset(r * 0.15, eyeY), Offset(r * 0.55, eyeY)];
    final ink = skin.accessory == Accessory.ninja ? const Color(0xFF14151C) : Palette.ink;
    if (dead) {
      _stroke
        ..color = ink
        ..strokeWidth = 0.045;
      for (final e in eyes) {
        const d = 0.07;
        canvas.drawLine(e + const Offset(-d, -d), e + const Offset(d, d), _stroke);
        canvas.drawLine(e + const Offset(-d, d), e + const Offset(d, -d), _stroke);
      }
      // Tongue out.
      _fill.color = const Color(0xFFFF6B8A);
      canvas.drawOval(Rect.fromCenter(center: Offset(r * 0.45, r * 0.5), width: r * 0.3, height: r * 0.4), _fill);
      canvas.drawLine(Offset(r * 0.2, r * 0.38), Offset(r * 0.7, r * 0.38), _stroke);
      return;
    }
    // Pupils look along the velocity (in head space).
    var lx = 0.0, ly = 0.0;
    if (speed > 0.5) {
      final c = math.cos(-headAngle), sn = math.sin(-headAngle);
      lx = (s.vx * c - s.vy * sn) / speed * 0.04;
      ly = (s.vx * sn + s.vy * c) / speed * 0.04;
    }
    for (final e in eyes) {
      _fill.color = Palette.white;
      canvas.drawCircle(e, r * 0.2, _fill);
      _stroke
        ..color = ink
        ..strokeWidth = 0.03;
      canvas.drawCircle(e, r * 0.2, _stroke);
      _fill.color = ink;
      canvas.drawCircle(e + Offset(lx, ly), r * 0.09, _fill);
    }
    _fill.color = ink;
    if (speed > 9) {
      // Screaming.
      canvas.drawOval(Rect.fromCenter(center: Offset(r * 0.4, r * 0.45), width: r * 0.35, height: r * 0.45), _fill);
    } else {
      _stroke
        ..color = ink
        ..strokeWidth = 0.04;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(r * 0.38, r * 0.25), width: r * 0.6, height: r * 0.4),
        0.2,
        math.pi - 0.4,
        false,
        _stroke,
      );
    }
  }

  // --------------------------------------------------------------- effects

  /// Seconds since the latest event of [kind] (optionally matching [value]).
  double? _since(List<SimEvent> events, EventKind kind, double time, [double? value]) {
    for (var i = events.length - 1; i >= 0; i--) {
      final e = events[i];
      if (e.t > time) continue;
      if (time - e.t > 2) return null;
      if (e.kind == kind && (value == null || e.value == value)) return time - e.t;
    }
    return null;
  }

  void _drawEffects(Canvas canvas, List<SimEvent> events, double time) {
    for (var idx = events.length - 1; idx >= 0; idx--) {
      final e = events[idx];
      if (e.t > time) continue;
      final age = time - e.t;
      if (age > 1.6) break;
      switch (e.kind) {
        case EventKind.coin:
          if (age < 0.4) _sparkle(canvas, e.x, e.y, age / 0.4, Palette.coin, idx);
        case EventKind.bonk:
          if (age < 0.6) _dizzyStars(canvas, e.x, e.y, age / 0.6, idx);
          if (e.value > 11 && age < 0.5) _comicText(canvas, 'BONK!', e.x, e.y - 1.2, age / 0.5, 0.9);
        case EventKind.bounce:
          if (age < 0.3) {
            _stroke
              ..color = Palette.padTop.withValues(alpha: 1 - age / 0.3)
              ..strokeWidth = 0.12;
            canvas.drawCircle(Offset(e.x, e.y - 0.5), 0.5 + age * 6, _stroke);
          }
        case EventKind.death:
          if (age < 0.8) {
            _burst(canvas, e.x, e.y, age / 0.8, idx);
            _comicText(canvas, _deathWord(e.value.toInt()), e.x, e.y - 1.6, age / 0.8, 1.3);
          }
        case EventKind.style:
          if (age < 1.2) {
            final t = age / 1.2;
            _floatText(canvas, '${e.label}  +${e.value.toInt()}', e.x, e.y - 1.8 - t * 1.5, t, const Color(0xFFFFE14D));
          }
        case EventKind.checkpoint:
          if (age < 1.2) {
            _floatText(canvas, 'CHECKPOINT!', e.x, e.y - 4.2 - age, age / 1.2, const Color(0xFF38D66B));
          }
        case EventKind.miss:
          if (age < 0.3) {
            _stroke
              ..color = Palette.white.withValues(alpha: 1 - age / 0.3)
              ..strokeWidth = 0.06;
            canvas.drawCircle(Offset(e.x, e.y), 0.2 + age * 3, _stroke);
          }
        case EventKind.finish:
          if (age < 1.6) _confetti(canvas, e.x, e.y, age, idx);
        case EventKind.grab:
        case EventKind.release:
          break;
      }
    }
  }

  static String _deathWord(int cause) => switch (DeathCause.values[cause]) {
    DeathCause.saw => 'ZZZING!',
    DeathCause.spikes => 'OUCH!',
    DeathCause.pit => 'YEOWCH!',
    DeathCause.stuck => 'ZZZ...',
  };

  double _rand(int seed, int k) {
    final v = math.sin(seed * 12.9898 + k * 78.233) * 43758.5453;
    return v - v.floorToDouble();
  }

  void _sparkle(Canvas canvas, double x, double y, double t, Color color, int seed) {
    _fill.color = color.withValues(alpha: 1 - t);
    for (var k = 0; k < 6; k++) {
      final a = k / 6 * math.pi * 2 + _rand(seed, k);
      final d = 0.3 + t * 1.2;
      canvas.drawCircle(Offset(x + math.cos(a) * d, y + math.sin(a) * d), 0.12 * (1 - t) + 0.03, _fill);
    }
  }

  void _dizzyStars(Canvas canvas, double x, double y, double t, int seed) {
    for (var k = 0; k < 3; k++) {
      final a = t * math.pi * 3 + k * math.pi * 2 / 3;
      _star(canvas, x + math.cos(a) * 0.6, y - 0.4 + math.sin(a) * 0.25, 0.18 * (1 - t * 0.5),
          const Color(0xFFFFE14D).withValues(alpha: 1 - t));
    }
  }

  void _star(Canvas canvas, double x, double y, double r, Color color) {
    final path = Path();
    for (var k = 0; k < 10; k++) {
      final a = -math.pi / 2 + k * math.pi / 5;
      final rr = k.isEven ? r : r * 0.45;
      final p = Offset(x + math.cos(a) * rr, y + math.sin(a) * rr);
      k == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    _fill.color = color;
    canvas.drawPath(path, _fill);
  }

  void _burst(Canvas canvas, double x, double y, double t, int seed) {
    const colors = [Color(0xFFFFE14D), Color(0xFFFF5E2B), Color(0xFFFFFFFF), Color(0xFF2D9CFF)];
    for (var k = 0; k < 12; k++) {
      final a = k / 12 * math.pi * 2 + _rand(seed, k) * 0.5;
      final d = 0.4 + t * (2 + _rand(seed, k + 20) * 2);
      _star(
        canvas,
        x + math.cos(a) * d,
        y + math.sin(a) * d + t * t * 1.5,
        0.22 * (1 - t) + 0.05,
        colors[k % colors.length].withValues(alpha: 1 - t),
      );
    }
  }

  void _confetti(Canvas canvas, double x, double y, double age, int seed) {
    const colors = [Color(0xFFFF5E8A), Color(0xFFFFE14D), Color(0xFF2D9CFF), Color(0xFF38D66B), Color(0xFFB36BFF)];
    for (var k = 0; k < 40; k++) {
      final vx = (_rand(seed, k) - 0.5) * 12;
      final vy = -6 - _rand(seed, k + 50) * 8;
      final px = x + vx * age;
      final py = y + vy * age + 9 * age * age;
      _fill.color = colors[k % colors.length].withValues(alpha: (1 - age / 1.6).clamp(0, 1));
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(age * 10 + k);
      canvas.drawRect(const Rect.fromLTWH(-0.12, -0.06, 0.24, 0.12), _fill);
      canvas.restore();
    }
  }

  TextPainter _text(String text, Color color, double size) {
    final key = '$text|${color.toARGB32()}|$size';
    return _textCache.putIfAbsent(key, () {
      if (_textCache.length > 64) {
        for (final tp in _textCache.values) {
          tp.dispose();
        }
        _textCache.clear();
      }
      return TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: 'LilitaOne',
            fontSize: size,
            color: color,
            shadows: const [Shadow(color: Palette.ink, offset: Offset(0.05, 0.07), blurRadius: 0)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    });
  }

  void _floatText(Canvas canvas, String text, double x, double y, double t, Color color) {
    final alpha = t < 0.7 ? 1.0 : 1 - (t - 0.7) / 0.3;
    // Alpha is quantised so the text layout cache stays small.
    final q = (alpha.clamp(0.0, 1.0) * 8).round() / 8;
    final tp = _text(text, color.withValues(alpha: q), 0.7);
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _comicText(Canvas canvas, String text, double x, double y, double t, double size) {
    final pop = t < 0.15 ? t / 0.15 * 1.25 : (t < 0.3 ? 1.25 - (t - 0.15) / 0.15 * 0.25 : 1.0);
    final alpha = t < 0.75 ? 1.0 : 1 - (t - 0.75) / 0.25;
    final tp = _text(text, const Color(0xFFFFE14D), size);
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(pop);
    canvas.rotate(-0.12);
    // Speech-burst behind the word.
    final w = tp.width * 0.75 + 0.4, h = tp.height * 0.75 + 0.3;
    final burst = Path();
    for (var k = 0; k < 16; k++) {
      final a = k / 16 * math.pi * 2;
      final rr = k.isEven ? 1.0 : 0.78;
      final p = Offset(math.cos(a) * w * rr, math.sin(a) * h * rr);
      k == 0 ? burst.moveTo(p.dx, p.dy) : burst.lineTo(p.dx, p.dy);
    }
    burst.close();
    _fill.color = Palette.danger.withValues(alpha: alpha.clamp(0, 1));
    canvas.drawPath(burst, _fill);
    _stroke
      ..color = Palette.ink.withValues(alpha: alpha.clamp(0, 1))
      ..strokeWidth = 0.06;
    canvas.drawPath(burst, _stroke);
    if (alpha > 0.05) tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }
}
