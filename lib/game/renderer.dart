import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'cosmetics.dart';
import 'course_builder.dart';
import 'level.dart';
import 'ragdoll.dart';
import 'simulation.dart';
import 'skins.dart';

part 'renderer_cosmetics.dart';
part 'renderer_worlds.dart';

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

/// Colours for a level's sky and scenery. Levels drift from a bright
/// morning, through golden afternoon, to sunset as the world progresses.
class WorldTheme {
  const WorldTheme({
    required this.skyTop,
    required this.skyMid,
    required this.skyBottom,
    required this.sun,
    required this.sunGlow,
    required this.mountain,
    required this.hillFar,
    required this.hillFarDark,
    required this.hillNear,
    required this.hillNearDark,
    required this.tree,
    required this.cloud,
    required this.cloudShade,
    required this.sunX,
    required this.sunY,
    this.backdrop = Backdrop.hills,
  });

  final Color skyTop;
  final Color skyMid;
  final Color skyBottom;
  final Color sun;
  final Color sunGlow;
  final Color mountain;
  final Color hillFar;
  final Color hillFarDark;
  final Color hillNear;
  final Color hillNearDark;
  final Color tree;
  final Color cloud;
  final Color cloudShade;

  /// Sun position as a fraction of the screen.
  final double sunX;
  final double sunY;

  /// Scenery drawn behind the level.
  final Backdrop backdrop;

  static const morning = WorldTheme(
    skyTop: Color(0xFF4FAEF7),
    skyMid: Color(0xFF9CD6FF),
    skyBottom: Color(0xFFFFF3D2),
    sun: Color(0xFFFFF7CF),
    sunGlow: Color(0x80FFF1A8),
    mountain: Color(0xFFB4D2EA),
    hillFar: Color(0xFFA9E27E),
    hillFarDark: Color(0xFF85C763),
    hillNear: Color(0xFF74CA52),
    hillNearDark: Color(0xFF4DA53A),
    tree: Color(0xFF3C9A3F),
    cloud: Color(0xFFFFFFFF),
    cloudShade: Color(0xFFD3E5F6),
    sunX: 0.8,
    sunY: 0.15,
  );

  static const golden = WorldTheme(
    skyTop: Color(0xFF5E9FEA),
    skyMid: Color(0xFFFFCF93),
    skyBottom: Color(0xFFFFEAC6),
    sun: Color(0xFFFFE594),
    sunGlow: Color(0x88FFC46A),
    mountain: Color(0xFFD4B6C6),
    hillFar: Color(0xFFC8D97C),
    hillFarDark: Color(0xFFA1BF5E),
    hillNear: Color(0xFF8DC254),
    hillNearDark: Color(0xFF5E9A3C),
    tree: Color(0xFF4A8936),
    cloud: Color(0xFFFFF7EC),
    cloudShade: Color(0xFFF2CDB4),
    sunX: 0.76,
    sunY: 0.24,
  );

  static const sunset = WorldTheme(
    skyTop: Color(0xFF3D3A8C),
    skyMid: Color(0xFFEE7099),
    skyBottom: Color(0xFFFFC27A),
    sun: Color(0xFFFFD783),
    sunGlow: Color(0x99FF985A),
    mountain: Color(0xFF8C6A9C),
    hillFar: Color(0xFF7F8F6A),
    hillFarDark: Color(0xFF5F6F50),
    hillNear: Color(0xFF5B8049),
    hillNearDark: Color(0xFF3C5A33),
    tree: Color(0xFF2F4A2C),
    cloud: Color(0xFFFFD9D0),
    cloudShade: Color(0xFFD98CA2),
    sunX: 0.7,
    sunY: 0.33,
  );

  static WorldTheme lerp(WorldTheme a, WorldTheme b, double t) {
    Color c(Color x, Color y) => Color.lerp(x, y, t)!;
    double d(double x, double y) => x + (y - x) * t;
    return WorldTheme(
      skyTop: c(a.skyTop, b.skyTop),
      skyMid: c(a.skyMid, b.skyMid),
      skyBottom: c(a.skyBottom, b.skyBottom),
      sun: c(a.sun, b.sun),
      sunGlow: c(a.sunGlow, b.sunGlow),
      mountain: c(a.mountain, b.mountain),
      hillFar: c(a.hillFar, b.hillFar),
      hillFarDark: c(a.hillFarDark, b.hillFarDark),
      hillNear: c(a.hillNear, b.hillNear),
      hillNearDark: c(a.hillNearDark, b.hillNearDark),
      tree: c(a.tree, b.tree),
      cloud: c(a.cloud, b.cloud),
      cloudShade: c(a.cloudShade, b.cloudShade),
      sunX: d(a.sunX, b.sunX),
      sunY: d(a.sunY, b.sunY),
      backdrop: a.backdrop,
    );
  }

  /// Theme for campaign level [id]; anything below 1 gets the morning.
  /// Each world of 20 levels drifts between its own keyframes.
  static WorldTheme forLevel(int id) {
    if (id < 1) return morning;
    return forWorld((id - 1) ~/ 20 + 1, ((id - 1) % 20) / 19);
  }

  /// Theme [t] of the way (0-1) through [world].
  static WorldTheme forWorld(int world, double t) {
    return switch (world) {
      1 =>
        t < 0.5
            ? lerp(morning, golden, t * 2)
            : lerp(golden, sunset, (t - 0.5) * 2),
      2 => lerp(WorldThemes.factoryStart, WorldThemes.factoryEnd, t),
      3 => lerp(WorldThemes.cityStart, WorldThemes.cityEnd, t),
      4 => lerp(WorldThemes.skyStart, WorldThemes.skyEnd, t),
      _ => lerp(WorldThemes.baseStart, WorldThemes.baseEnd, t),
    };
  }
}

/// Draws a level and a [Frame] onto a canvas. Stateless apart from caches, so
/// the same renderer draws live play, slow-motion replays and exported clips.
class WorldRenderer {
  WorldRenderer(this.level, this.skin, {this.endless = false})
    : _extent = level.extent,
      theme = level.worldOverride != null
          ? WorldTheme.forWorld(level.world, 0.5)
          : WorldTheme.forLevel(level.id);

  final Level level;

  /// Endless courses change look zone by zone as the camera moves.
  final bool endless;
  WorldTheme theme;

  /// Equipped rope, trail and fail effect.
  Loadout look = const Loadout();

  /// The next zone's theme, faded in over the end of an endless zone.
  WorldTheme? _nextTheme;
  double _nextFade = 0;

  /// World x of the player's best Endless distance, marked with a flag.
  double? bestX;

  /// Best run's torso path, (run time, x, y, angle) per sample, drawn as a
  /// see-through ghost to race against.
  Float32List? ghost;
  Skin skin;
  final ({double minX, double maxX, double minY}) _extent;
  final Map<String, TextPainter> _textCache = {};

  final Paint _fill = Paint()..isAntiAlias = true;

  /// Paint colour to use with gradients: a paint's alpha also scales its
  /// shader, so leftover translucency from a previous draw would fade them.
  static const _opaque = Color(0xFFFFFFFF);
  final Paint _stroke = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  /// Renders everything. [time] is the simulation time used for effects and
  /// [wallTime] drives purely cosmetic animation (pulsing, coin spin, clouds).
  /// [trail] is the torso's recent path (world space, oldest first) for the
  /// motion trail.
  void render(
    Canvas canvas,
    Size size,
    Frame frame, {
    required List<SimEvent> events,
    double? wallTime,
    bool showTarget = true,
    List<Offset>? trail,
  }) {
    final s = frame.s;
    final cam = frame.cam;
    final time = s.t;
    final wt = wallTime ?? time;
    final scale = size.width / cam.w;

    if (endless) _updateEndlessTheme(cam.x);
    _drawBackground(canvas, size, cam, scale, wt);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    final shake = _shake(events, time);
    canvas.translate(-cam.x + shake.dx, -cam.y + shake.dy);
    final halfH = size.height / scale / 2;
    final view = Rect.fromLTRB(
      cam.x - cam.w / 2 - 2,
      cam.y - halfH - 2,
      cam.x + cam.w / 2 + 2,
      cam.y + halfH + 2,
    );

    _drawPit(canvas, view);
    _drawFinish(canvas, view, wt);
    final best = bestX;
    if (best != null && _visible(view, best, 0, 3)) _drawBestFlag(canvas, best, wt);
    for (var i = 0; i < level.checkpoints.length; i++) {
      _drawCheckpoint(
        canvas,
        view,
        level.checkpoints[i],
        s.checkpointReached(i),
        wt,
      );
    }
    for (final w in level.winds) {
      final b = w.box;
      if (_visible(view, b.x, b.y, math.max(b.w, b.h))) {
        _drawWind(canvas, w, wt);
      }
    }
    for (final b in level.flips) {
      if (_visible(view, b.x, b.y, math.max(b.w, b.h))) {
        _drawFlipZone(canvas, b, wt);
      }
    }
    for (final a in level.anchors) {
      if (a.moving) _drawRail(canvas, a);
    }
    for (final p in level.platforms) {
      if (_visible(view, p.x, p.y, math.max(p.w, p.h))) {
        if (theme.backdrop == Backdrop.hills) {
          _drawPlatform(canvas, p);
        } else {
          _drawSlab(canvas, p);
        }
      }
    }
    for (var i = 0; i < level.crumbles.length && s.crumbles.isNotEmpty; i++) {
      final b = level.crumbles[i];
      final x = s.crumbles[i * 3], y = s.crumbles[i * 3 + 1];
      if (_visible(view, x, y, math.max(b.w, b.h))) {
        _drawCrumble(canvas, i, s, events, time, wt);
      }
    }
    for (var i = 0; i < level.glass.length; i++) {
      final g = level.glass[i];
      if (!s.glassIsBroken(i) && _visible(view, g.x, g.y, math.max(g.w, g.h))) {
        _drawGlass(canvas, g, wt);
      }
    }
    for (final sp in level.spikes) {
      if (_visible(view, sp.x, sp.y, math.max(sp.w, sp.h))) {
        _drawSpikes(canvas, sp);
      }
    }
    for (var i = 0; i < level.pads.length; i++) {
      final p = level.pads[i];
      if (_visible(view, p.x, p.y, p.w)) {
        _drawPad(canvas, p, _padSquash(events, i, time));
      }
    }
    for (var i = 0; i < level.saws.length; i++) {
      final x = s.saws[i * 3], y = s.saws[i * 3 + 1], a = s.saws[i * 3 + 2];
      if (_visible(view, x, y, level.saws[i].r * 2)) {
        _drawSaw(canvas, x, y, level.saws[i].r, a);
      }
    }
    _drawRockets(canvas, view, s, wt);
    for (var i = 0; i < level.anchors.length; i++) {
      final a = _anchorPos(s, i);
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
      if (_visible(view, c.x, c.y, 1)) _drawCoin(canvas, c.x, c.y, wt, i);
    }

    if (trail != null && trail.length > 2) drawTrailStyled(canvas, trail, wt, look.trail);
    if (s.ropeAnchor >= 0) _drawRope(canvas, s, events, time, wt);
    final g = ghost;
    if (g != null && g.length >= 8 && s.runTime > 0) _drawGhost(canvas, g, s.runTime);
    drawRagdoll(canvas, s, skin, wt);
    _drawEffects(canvas, events, time);
    canvas.restore();

    _drawSpeedLines(canvas, size, s, wt);
    _drawVignette(canvas, size);
  }

  void _drawGhost(Canvas canvas, Float32List g, double t) {
    const tint = Palette.white;
    final n = g.length ~/ 4;
    if (t > g[(n - 1) * 4] + 1.5) return;
    // Binary search for the sample pair around t.
    var lo = 0, hi = n - 1;
    while (hi - lo > 1) {
      final mid = (lo + hi) >> 1;
      if (g[mid * 4] <= t) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    final t0 = g[lo * 4], t1 = g[hi * 4];
    final f = t1 > t0 ? ((t - t0) / (t1 - t0)).clamp(0.0, 1.0) : 1.0;
    double at(int k) => g[lo * 4 + k] + (g[hi * 4 + k] - g[lo * 4 + k]) * f;
    final x = at(1), y = at(2), a = at(3);
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(a);
    _fill.color = tint.withValues(alpha: 0.4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 0.5, height: 0.9), const Radius.circular(0.25)),
      _fill,
    );
    canvas.drawCircle(const Offset(0, -0.8), 0.34, _fill);
    _stroke
      ..color = tint.withValues(alpha: 0.6)
      ..strokeWidth = 0.05;
    canvas.drawCircle(const Offset(0, -0.8), 0.34, _stroke);
    // Arms and legs as simple strokes.
    _stroke
      ..color = tint.withValues(alpha: 0.4)
      ..strokeWidth = 0.16;
    canvas.drawLine(const Offset(0, -0.3), const Offset(0.45, 0.1), _stroke);
    canvas.drawLine(const Offset(0, -0.3), const Offset(-0.45, 0.1), _stroke);
    canvas.drawLine(const Offset(0.1, 0.4), const Offset(0.2, 1.1), _stroke);
    canvas.drawLine(const Offset(-0.1, 0.4), const Offset(-0.2, 1.1), _stroke);
    canvas.restore();
  }

  /// Where anchor [i] is in [s] (snapshots built by hand may not carry
  /// anchor positions; those fall back to the level's layout).
  P _anchorPos(Snapshot s, int i) =>
      s.anchors.length >= (i + 1) * 2 ? P(s.ax(i), s.ay(i)) : level.anchors[i];

  bool _visible(Rect view, double x, double y, double size) =>
      x + size > view.left &&
      x - size < view.right &&
      y + size > view.top &&
      y - size < view.bottom;

  /// Camera shake from recent impacts (world metres). A pure function of the
  /// event log, so replays and exported clips shake exactly the same way.
  Offset _shake(List<SimEvent> events, double time) {
    var amp = 0.0;
    var seed = 0;
    for (var i = events.length - 1; i >= 0; i--) {
      final e = events[i];
      if (e.t > time) continue;
      final age = time - e.t;
      if (age > 0.5) break;
      final strength = switch (e.kind) {
        EventKind.death => 0.45,
        EventKind.bonk => e.value > 11 ? 0.18 : 0.0,
        EventKind.bounce => 0.12,
        EventKind.launch => 0.14,
        EventKind.shatter => 0.16,
        EventKind.boom => e.label == 'hit' ? 0.4 : 0.1,
        _ => 0.0,
      };
      if (strength > 0) {
        amp += strength * math.exp(-age * 9);
        seed = i;
      }
    }
    if (amp < 0.005) return Offset.zero;
    return Offset(
      math.sin(time * 71 + seed) * amp,
      math.cos(time * 53 + seed * 3) * amp,
    );
  }

  // ------------------------------------------------------------ background

  void _updateEndlessTheme(double x) {
    const zone = CourseBuilder.zoneLength, fade = 30.0;
    final into = x % zone;
    theme = WorldTheme.forWorld(CourseBuilder.endlessWorld(x), into / zone);
    final left = zone - into;
    if (left < fade) {
      _nextTheme = WorldTheme.forWorld(CourseBuilder.endlessWorld(x + left + 1), 0);
      _nextFade = 1 - left / fade;
    } else {
      _nextTheme = null;
    }
  }

  void _drawBackground(
    Canvas canvas,
    Size size,
    Cam cam,
    double scale,
    double wt,
  ) {
    _drawScenery(canvas, size, cam, scale, wt);
    final next = _nextTheme;
    if (next == null || _nextFade <= 0) return;
    // Cross-fade into the next endless zone.
    canvas.saveLayer(
      Offset.zero & size,
      Paint()..color = Color.fromRGBO(0, 0, 0, _nextFade.clamp(0.0, 1.0)),
    );
    final current = theme;
    theme = next;
    _drawScenery(canvas, size, cam, scale, wt);
    theme = current;
    canvas.restore();
  }

  void _drawBestFlag(Canvas canvas, double x, double wt) {
    _stroke
      ..color = Palette.ink
      ..strokeWidth = 0.14;
    canvas.drawLine(Offset(x, level.killY), Offset(x, -13), _stroke);
    final wave = math.sin(wt * 4) * 0.15;
    _fill.color = const Color(0xFFFFD23F);
    canvas.drawPath(
      Path()
        ..moveTo(x, -13)
        ..lineTo(x + 2.4, -12.4 + wave)
        ..lineTo(x, -11.6)
        ..close(),
      _fill,
    );
    _comicText(canvas, 'BEST', x + 1.1, -14, 0.5, 0.55);
  }

  void _drawScenery(
    Canvas canvas,
    Size size,
    Cam cam,
    double scale,
    double wt,
  ) {
    final rect = Offset.zero & size;
    _fill.color = _opaque;
    _fill.shader = ui.Gradient.linear(
      Offset.zero,
      Offset(0, size.height),
      [theme.skyTop, theme.skyMid, theme.skyBottom],
      const [0, 0.55, 1],
    );
    canvas.drawRect(rect, _fill);
    _fill.shader = null;
    _drawStars(canvas, size, wt);

    // Sun with a soft glow.
    final sun = Offset(
      size.width * theme.sunX - cam.x * 0.01 * scale,
      size.height * theme.sunY,
    );
    final glowR = size.width * 0.45;
    _fill.color = _opaque;
    _fill.shader = ui.Gradient.radial(sun, glowR, [
      theme.sunGlow,
      theme.sunGlow.withValues(alpha: 0),
    ]);
    canvas.drawCircle(sun, glowR, _fill);
    _fill.shader = null;
    _fill.color = theme.sun;
    canvas.drawCircle(sun, size.width * 0.075, _fill);

    // Clouds drift with the wind and a little parallax.
    final cloudPx = scale * 0.8;
    final period = 6 * 23.0 * cloudPx;
    for (var i = 0; i < 6; i++) {
      final wx = i * 23.0 + (i.isEven ? 5 : 0);
      var x = (wx - cam.x * 0.15 - wt * 0.35) * cloudPx;
      x = ((x % period) + period) % period - 3 * cloudPx;
      final y =
          size.height * (0.08 + 0.08 * (i % 3)) - (cam.y * 0.05) * cloudPx;
      _cloud(canvas, Offset(x, y), cloudPx * (1.3 + (i % 3) * 0.35));
    }

    if (theme.backdrop != Backdrop.hills) {
      _drawWorldBackdrop(canvas, size, cam, scale, wt);
      return;
    }
    _mountains(canvas, size, cam, scale);
    _hills(
      canvas,
      size,
      cam,
      scale,
      0.25,
      0.7,
      theme.hillFar,
      theme.hillFarDark,
      9,
      1.8,
      trees: false,
    );
    _hills(
      canvas,
      size,
      cam,
      scale,
      0.45,
      0.8,
      theme.hillNear,
      theme.hillNearDark,
      6,
      1.3,
      trees: true,
    );
  }

  void _cloud(Canvas canvas, Offset c, double r) {
    void puffs(Offset o) {
      canvas.drawCircle(c + o, r, _fill);
      canvas.drawCircle(c + o + Offset(r * 0.95, r * 0.25), r * 0.78, _fill);
      canvas.drawCircle(c + o + Offset(-r * 0.95, r * 0.3), r * 0.66, _fill);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            c.dx + o.dx - r * 1.55,
            c.dy + o.dy - r * 0.1,
            c.dx + o.dx + r * 1.7,
            c.dy + o.dy + r * 0.8,
          ),
          Radius.circular(r * 0.45),
        ),
        _fill,
      );
    }

    _fill.color = theme.cloudShade.withValues(alpha: 0.85);
    puffs(Offset(0, r * 0.18));
    _fill.color = theme.cloud.withValues(alpha: 0.95);
    puffs(Offset.zero);
  }

  void _mountains(Canvas canvas, Size size, Cam cam, double scale) {
    const parallax = 0.08;
    final base = size.height * 0.62 - cam.y * parallax * scale * 0.2;
    final path = Path()..moveTo(0, size.height);
    for (var px = 0.0; px <= size.width + 12; px += 12) {
      final wx = cam.x * parallax + (px - size.width / 2) / scale;
      // Sum of triangle waves makes a jagged ridge.
      double tri(double v) => 1 - ((v % 2) - 1).abs() * 1.0;
      final h =
          tri(wx / 5.5) * 3.2 +
          tri(wx / 3.1 + 0.7) * 1.6 +
          tri(wx / 1.7 + 0.2) * 0.5;
      path.lineTo(px, base - h * scale * 0.55);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    _fill.color = _opaque;
    _fill.shader = ui.Gradient.linear(
      Offset(0, base - 4 * scale),
      Offset(0, base + 2 * scale),
      [theme.mountain, Color.lerp(theme.mountain, theme.skyBottom, 0.6)!],
    );
    canvas.drawPath(path, _fill);
    _fill.shader = null;
  }

  void _hills(
    Canvas canvas,
    Size size,
    Cam cam,
    double scale,
    double parallax,
    double baseFrac,
    Color color,
    Color dark,
    double wavelength,
    double amp, {
    required bool trees,
  }) {
    final base = size.height * baseFrac - cam.y * parallax * scale * 0.2;
    double heightAt(double wx) =>
        math.sin(wx / wavelength) * amp +
        math.sin(wx / (wavelength * 0.43) + 1.3) * amp * 0.4;
    double wxAt(double px) => cam.x * parallax + (px - size.width / 2) / scale;
    double pxAt(double wx) => (wx - cam.x * parallax) * scale + size.width / 2;

    if (trees) {
      // Lollipop trees standing on the ridge.
      const spacing = 3.7;
      final first = (wxAt(-40) / spacing).floor();
      final last = (wxAt(size.width + 40) / spacing).ceil();
      for (var n = first; n <= last; n++) {
        if (_rand(n, 3) < 0.45) continue;
        final wx = n * spacing + _rand(n, 5) * 1.5;
        final px = pxAt(wx);
        final py = base - heightAt(wx) * scale + 2;
        final h = (0.9 + _rand(n, 7) * 0.8) * scale;
        _fill.color = Color.lerp(theme.tree, const Color(0xFF3B2A1A), 0.5)!;
        canvas.drawRect(
          Rect.fromLTWH(px - h * 0.06, py - h * 0.55, h * 0.12, h * 0.6),
          _fill,
        );
        _fill.color = theme.tree;
        canvas.drawCircle(Offset(px, py - h * 0.75), h * 0.36, _fill);
        canvas.drawCircle(Offset(px - h * 0.2, py - h * 0.6), h * 0.26, _fill);
        _fill.color = Color.lerp(theme.tree, Palette.white, 0.18)!;
        canvas.drawCircle(Offset(px - h * 0.1, py - h * 0.88), h * 0.14, _fill);
      }
    }

    final path = Path()..moveTo(0, size.height);
    for (var px = 0.0; px <= size.width + 8; px += 8) {
      path.lineTo(px, base - heightAt(wxAt(px)) * scale);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    _fill.color = _opaque;
    _fill.shader = ui.Gradient.linear(
      Offset(0, base - amp * scale),
      Offset(0, base + amp * scale * 3),
      [color, dark],
    );
    canvas.drawPath(path, _fill);
    _fill.shader = null;
  }

  void _drawSpeedLines(Canvas canvas, Size size, Snapshot s, double wt) {
    final speed = math.sqrt(s.vx * s.vx + s.vy * s.vy);
    if (speed < 11 || s.status != SimStatus.running) return;
    final strength = ((speed - 11) / 6).clamp(0.0, 1.0);
    final dir = Offset(s.vx, s.vy) / speed;
    _stroke
      ..color = Palette.white.withValues(alpha: 0.35 * strength)
      ..strokeWidth = 2.5;
    final centre = size.center(Offset.zero);
    for (var k = 0; k < 10; k++) {
      final seed = (wt * 12).floor() + k * 7;
      final ang = _rand(seed, 1) * math.pi * 2;
      final dist = size.shortestSide * (0.35 + _rand(seed, 2) * 0.35);
      final p = centre + Offset(math.cos(ang), math.sin(ang)) * dist;
      final len = size.shortestSide * (0.08 + 0.12 * strength);
      canvas.drawLine(p, p - dir * len, _stroke);
    }
  }

  void _drawVignette(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    _fill.color = _opaque;
    _fill.shader = ui.Gradient.radial(
      size.center(Offset.zero),
      size.longestSide * 0.75,
      const [Color(0x00000000), Color(0x00000000), Color(0x40201020)],
      const [0, 0.6, 1],
    );
    canvas.drawRect(rect, _fill);
    _fill.shader = null;
  }

  // ------------------------------------------------------------ level parts

  void _drawPit(Canvas canvas, Rect view) {
    final y = level.killY;
    if (y - 1 > view.bottom) return;
    final left = math.max(view.left, _extent.minX - 30);
    final right = math.min(view.right, _extent.maxX + 30);
    if (right <= left) return;
    _fill.color = _opaque;
    _fill.shader = ui.Gradient.linear(
      Offset(0, y - 0.3),
      Offset(0, y + 6),
      const [Color(0xFFE2472F), Color(0xFF8E1A12), Color(0xFF4A0B08)],
      const [0, 0.35, 1],
    );
    canvas.drawRect(
      Rect.fromLTRB(left, y - 0.05, right, view.bottom + 10),
      _fill,
    );
    // Heat glow above the spikes.
    _fill.color = _opaque;
    _fill.shader = ui.Gradient.linear(Offset(0, y - 1.6), Offset(0, y), const [
      Color(0x00FF7A45),
      Color(0x55FF7A45),
    ]);
    canvas.drawRect(Rect.fromLTRB(left, y - 1.6, right, y), _fill);
    _fill.shader = null;
    const w = 0.7;
    final start = (left / w).floor() * w;
    final lit = Path(), shade = Path();
    for (var x = start; x < right; x += w) {
      lit
        ..moveTo(x, y + 0.05)
        ..lineTo(x + w / 2, y - 0.8)
        ..lineTo(x + w / 2, y + 0.05)
        ..close();
      shade
        ..moveTo(x + w / 2, y + 0.05)
        ..lineTo(x + w / 2, y - 0.8)
        ..lineTo(x + w, y + 0.05)
        ..close();
    }
    _fill.color = const Color(0xFFFF8A5C);
    canvas.drawPath(lit, _fill);
    _fill.color = const Color(0xFFC9301F);
    canvas.drawPath(shade, _fill);
  }

  void _drawPlatform(Canvas canvas, Box b) {
    _withBox(canvas, b, () {
      final r = Rect.fromCenter(center: Offset.zero, width: b.w, height: b.h);
      // Soft drop shadow.
      _fill.color = const Color(0x2A000000);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          r.shift(const Offset(0.15, 0.3)),
          const Radius.circular(0.3),
        ),
        _fill,
      );
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(0.28));
      _fill.color = _opaque;
      _fill.shader = ui.Gradient.linear(
        Offset(0, r.top),
        Offset(0, r.bottom),
        const [Color(0xFFA7713F), Color(0xFF7A4E2A), Color(0xFF5C391E)],
        const [0, 0.5, 1],
      );
      canvas.drawRRect(rr, _fill);
      _fill.shader = null;
      // Pebbles.
      for (var i = 0; i < (b.w * b.h * 1.5).clamp(2, 40); i++) {
        final fx = ((i * 0.618 + 0.13) % 1.0) - 0.5,
            fy = ((i * 0.377 + 0.3) % 1.0) - 0.5;
        _fill.color = i.isEven
            ? const Color(0x33FFE2B8)
            : const Color(0x33000000);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(fx * b.w * 0.85, fy * b.h * 0.6 + b.h * 0.12),
            width: 0.2,
            height: 0.12,
          ),
          _fill,
        );
      }
      // Grass cap with a scalloped edge and little tufts.
      final grassH = math.min(0.42, b.h * 0.45);
      final grass = Path()..moveTo(r.left - 0.06, r.top + grassH);
      const bump = 0.4;
      final n = math.max(2, (b.w / bump).round());
      for (var i = 0; i <= n; i++) {
        final x = r.left - 0.06 + (b.w + 0.12) * i / n;
        grass.lineTo(x, r.top + grassH + (i.isEven ? 0.09 : -0.02));
      }
      grass
        ..lineTo(r.right + 0.06, r.top + 0.15)
        ..quadraticBezierTo(
          r.right + 0.06,
          r.top - 0.06,
          r.right - 0.15,
          r.top - 0.06,
        )
        ..lineTo(r.left + 0.15, r.top - 0.06)
        ..quadraticBezierTo(
          r.left - 0.06,
          r.top - 0.06,
          r.left - 0.06,
          r.top + 0.15,
        )
        ..close();
      _fill.color = const Color(0xFF4DAE2E);
      canvas.drawPath(grass, _fill);
      _fill.color = const Color(0xFF7DDB4A);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            r.left + 0.05,
            r.top - 0.04,
            r.right - 0.05,
            r.top + grassH * 0.45,
          ),
          const Radius.circular(0.12),
        ),
        _fill,
      );
      // Tufts and flowers along the top.
      final tufts = Path();
      for (var i = 0; i < (b.w / 0.55).floor(); i++) {
        final x = r.left + 0.3 + i * 0.55 + ((i * 0.37) % 0.2);
        tufts
          ..moveTo(x - 0.08, r.top)
          ..lineTo(x - 0.03, r.top - 0.2)
          ..lineTo(x + 0.02, r.top)
          ..lineTo(x + 0.07, r.top - 0.16)
          ..lineTo(x + 0.11, r.top)
          ..close();
        if (i % 3 == 1) {
          _fill.color = i % 2 == 0
              ? const Color(0xFFFFFFFF)
              : const Color(0xFFFF8FB8);
          canvas.drawCircle(Offset(x + 0.2, r.top - 0.1), 0.07, _fill);
          _fill.color = const Color(0xFFFFD23F);
          canvas.drawCircle(Offset(x + 0.2, r.top - 0.1), 0.03, _fill);
        }
      }
      _fill.color = const Color(0xFF5CC236);
      canvas.drawPath(tufts, _fill);
      _stroke
        ..color = const Color(0xCC3B2412)
        ..strokeWidth = 0.07;
      canvas.drawRRect(rr, _stroke);
    });
  }

  void _drawSpikes(Canvas canvas, Box b) {
    _withBox(canvas, b, () {
      const tooth = 0.55, height = 0.48;
      final core = Rect.fromCenter(
        center: Offset.zero,
        width: b.w,
        height: b.h,
      );
      final lit = Path(), shade = Path();
      void edge(Offset a, Offset c, Offset outward) {
        final len = (c - a).distance;
        final n = math.max(1, (len / tooth).round());
        for (var i = 0; i < n; i++) {
          final p0 = Offset.lerp(a, c, i / n)!;
          final p1 = Offset.lerp(a, c, (i + 1) / n)!;
          final base = Offset.lerp(p0, p1, 0.5)!;
          final tip = base + outward * height;
          lit
            ..moveTo(p0.dx, p0.dy)
            ..lineTo(tip.dx, tip.dy)
            ..lineTo(base.dx, base.dy)
            ..close();
          shade
            ..moveTo(base.dx, base.dy)
            ..lineTo(tip.dx, tip.dy)
            ..lineTo(p1.dx, p1.dy)
            ..close();
        }
      }

      edge(core.topLeft, core.topRight, const Offset(0, -1));
      edge(core.bottomRight, core.bottomLeft, const Offset(0, 1));
      edge(core.topRight, core.bottomRight, const Offset(1, 0));
      edge(core.bottomLeft, core.topLeft, const Offset(-1, 0));
      _fill.color = const Color(0xFFFFB08A);
      canvas.drawPath(lit, _fill);
      _fill.color = const Color(0xFFE0452F);
      canvas.drawPath(shade, _fill);
      final rr = RRect.fromRectAndRadius(core, const Radius.circular(0.14));
      _fill.color = _opaque;
      _fill.shader = ui.Gradient.linear(
        core.topLeft,
        core.bottomRight,
        const [Color(0xFFFF6A4A), Color(0xFFD12F22), Color(0xFF9E1D14)],
        const [0, 0.5, 1],
      );
      canvas.drawRRect(rr, _fill);
      _fill.shader = null;
      // Hazard stripes.
      canvas.save();
      canvas.clipRRect(rr);
      _fill.color = const Color(0x33000000);
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
      _stroke
        ..color = const Color(0xAA6E120C)
        ..strokeWidth = 0.06;
      canvas.drawRRect(rr, _stroke);
      // Rivets.
      _fill.color = const Color(0xFFFFC7B0);
      for (final dx in [-1.0, 1.0]) {
        for (final dy in [-1.0, 1.0]) {
          if (b.w < 0.8 || b.h < 0.8) continue;
          canvas.drawCircle(
            Offset(dx * (b.w / 2 - 0.2), dy * (b.h / 2 - 0.2)),
            0.06,
            _fill,
          );
        }
      }
    });
  }

  void _drawSaw(Canvas canvas, double x, double y, double r, double angle) {
    canvas.save();
    canvas.translate(x, y);
    // Motion blur halo.
    _fill.color = const Color(0x33FF5E2B);
    canvas.drawCircle(Offset.zero, r * 1.08, _fill);
    canvas.rotate(angle);
    const teeth = 16;
    final path = Path();
    for (var i = 0; i < teeth; i++) {
      final a0 = i / teeth * math.pi * 2;
      final a1 = (i + 0.6) / teeth * math.pi * 2;
      final a2 = (i + 1) / teeth * math.pi * 2;
      final p0 = Offset(math.cos(a0), math.sin(a0)) * r * 0.8;
      final p1 = Offset(math.cos(a1), math.sin(a1)) * r;
      final p2 = Offset(math.cos(a2), math.sin(a2)) * r * 0.8;
      if (i == 0) path.moveTo(p0.dx, p0.dy);
      path
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy);
    }
    path.close();
    _fill.color = _opaque;
    _fill.shader = ui.Gradient.radial(
      Offset.zero,
      r,
      const [Color(0xFFFF9A5C), Color(0xFFFF5E2B), Color(0xFFC7301A)],
      const [0.3, 0.7, 1],
    );
    canvas.drawPath(path, _fill);
    _fill.shader = null;
    _stroke
      ..color = const Color(0xCC7A140C)
      ..strokeWidth = 0.06;
    canvas.drawPath(path, _stroke);
    // Metal disc with a shiny hub.
    _fill.color = _opaque;
    _fill.shader = ui.Gradient.linear(Offset(-r, -r), Offset(r, r), const [
      Color(0xFFF2F4F7),
      Color(0xFFA9B1BB),
    ]);
    canvas.drawCircle(Offset.zero, r * 0.55, _fill);
    _fill.shader = null;
    _stroke
      ..color = const Color(0xFF7D8793)
      ..strokeWidth = 0.05;
    for (var i = 0; i < 3; i++) {
      final a = i * math.pi * 2 / 3;
      canvas.drawLine(
        Offset(math.cos(a), math.sin(a)) * r * 0.2,
        Offset(math.cos(a), math.sin(a)) * r * 0.48,
        _stroke,
      );
    }
    _fill.color = const Color(0xFF5E6873);
    canvas.drawCircle(Offset.zero, r * 0.15, _fill);
    canvas.restore();
    // Specular glint (does not spin).
    _stroke
      ..color = const Color(0x99FFFFFF)
      ..strokeWidth = 0.08;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(x, y), radius: r * 0.42),
      -2.6,
      1.0,
      false,
      _stroke,
    );
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
    // Soft halo so rings read as "grab me" against any sky.
    _fill.color = _opaque;
    _fill.shader = ui.Gradient.radial(c, 1.0, [
      (target ? Palette.anchorGlow : const Color(0xFFBFE3FF)).withValues(
        alpha: target ? 0.7 : 0.45,
      ),
      const Color(0x00FFFFFF),
    ]);
    canvas.drawCircle(c, 1.0, _fill);
    _fill.shader = null;
    if (target) {
      final pulse = 0.5 + 0.5 * math.sin(wt * 8);
      _stroke
        ..color = Palette.anchorGlow.withValues(alpha: 0.9)
        ..strokeWidth = 0.08;
      canvas.drawCircle(c, 0.72 + 0.12 * pulse, _stroke);
      // Rotating dashes.
      for (var k = 0; k < 4; k++) {
        final start = wt * 2.5 + k * math.pi / 2;
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: 0.95 + 0.1 * pulse),
          start,
          0.6,
          false,
          _stroke,
        );
      }
    }
    if (grabFlash != null && grabFlash < 0.3) {
      final t = grabFlash / 0.3;
      _stroke
        ..color = Palette.white.withValues(alpha: 1 - t)
        ..strokeWidth = 0.14 * (1 - t) + 0.02;
      canvas.drawCircle(c, 0.5 + t * 1.4, _stroke);
    }
    _fill.color = _opaque;
    _fill.shader = ui.Gradient.linear(
      c + const Offset(0, -0.45),
      c + const Offset(0, 0.45),
      attached
          ? const [Color(0xFFFFF3A0), Color(0xFFFFB820)]
          : const [Color(0xFF7CC8FF), Color(0xFF1C6FD1)],
    );
    _stroke
      ..color = _opaque
      ..shader = _fill.shader
      ..strokeWidth = 0.2;
    canvas.drawCircle(c, 0.4, _stroke);
    _stroke.shader = null;
    _fill.shader = null;
    _fill.color = attached ? const Color(0xFFFFE14D) : const Color(0xFFF4FAFF);
    canvas.drawCircle(c, 0.26, _fill);
    _fill.color = attached ? const Color(0xFFFFB820) : const Color(0xFF2D9CFF);
    canvas.drawCircle(c, 0.12, _fill);
    _stroke
      ..color = const Color(0xCCFFFFFF)
      ..strokeWidth = 0.06;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: 0.42),
      -2.5,
      1.1,
      false,
      _stroke,
    );
  }

  void _drawCoin(Canvas canvas, double x, double y, double wt, int i) {
    final bob = math.sin(wt * 2.4 + i * 0.9) * 0.08;
    final c = Offset(x, y + bob);
    _fill.color = _opaque;
    _fill.shader = ui.Gradient.radial(c, 0.75, const [
      Color(0x66FFE27A),
      Color(0x00FFE27A),
    ]);
    canvas.drawCircle(c, 0.75, _fill);
    _fill.shader = null;
    final sx = math.cos(wt * 3 + i * 0.7).abs() * 0.8 + 0.2;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(sx, 1);
    _fill.color = const Color(0xFFD08A00);
    canvas.drawCircle(const Offset(0.05, 0.03), 0.37, _fill);
    _fill.color = _opaque;
    _fill.shader = ui.Gradient.radial(
      const Offset(-0.1, -0.12),
      0.45,
      const [Color(0xFFFFF4B0), Color(0xFFFFD23F), Color(0xFFF2A900)],
      const [0, 0.5, 1],
    );
    canvas.drawCircle(Offset.zero, 0.36, _fill);
    _fill.shader = null;
    _stroke
      ..color = const Color(0xFFE09A00)
      ..strokeWidth = 0.05;
    canvas.drawCircle(Offset.zero, 0.24, _stroke);
    _star(canvas, 0, 0, 0.14, const Color(0xFFFFF4B0));
    canvas.restore();
    // Occasional glint.
    final g = (wt * 0.7 + i * 0.37) % 1.0;
    if (g < 0.12) {
      final t = g / 0.12;
      _stroke
        ..color = Palette.white.withValues(alpha: math.sin(t * math.pi))
        ..strokeWidth = 0.05;
      final d = 0.3 * math.sin(t * math.pi);
      canvas.drawLine(
        c + Offset(-d, 0) + const Offset(0.18, -0.18),
        c + Offset(d, 0) + const Offset(0.18, -0.18),
        _stroke,
      );
      canvas.drawLine(
        c + Offset(0, -d) + const Offset(0.18, -0.18),
        c + Offset(0, d) + const Offset(0.18, -0.18),
        _stroke,
      );
    }
  }

  void _drawFinish(Canvas canvas, Rect view, double wt) {
    final f = level.finish;
    if (!_visible(view, f.x, f.y, math.max(f.w, f.h))) return;
    final left = f.x - f.w / 2, right = f.x + f.w / 2;
    final top = f.y - f.h / 2, bottom = f.y + f.h / 2;
    // Golden light inside the gate.
    _fill.color = _opaque;
    _fill.shader = ui.Gradient.linear(Offset(0, top), Offset(0, bottom), const [
      Color(0x00FFE14D),
      Color(0x55FFE14D),
    ]);
    canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), _fill);
    _fill.shader = null;
    _stroke
      ..color = const Color(0xFF4A4A55)
      ..strokeWidth = 0.22;
    canvas.drawLine(Offset(left, bottom), Offset(left, top - 0.5), _stroke);
    canvas.drawLine(Offset(right, bottom), Offset(right, top - 0.5), _stroke);
    _fill.color = const Color(0xFFFFD23F);
    canvas.drawCircle(Offset(left, top - 0.55), 0.2, _fill);
    canvas.drawCircle(Offset(right, top - 0.55), 0.2, _fill);
    // Checkered banner.
    final bannerTop = top - 0.4, bannerH = 1.0;
    const cells = 10;
    final cw = f.w / cells;
    for (var i = 0; i < cells; i++) {
      for (var j = 0; j < 2; j++) {
        _fill.color = (i + j).isEven ? Palette.ink : Palette.white;
        final wave = math.sin(wt * 3 + i * 0.6) * 0.08;
        canvas.drawRect(
          Rect.fromLTWH(
            left + i * cw,
            bannerTop + j * bannerH / 2 + wave,
            cw + 0.01,
            bannerH / 2,
          ),
          _fill,
        );
      }
    }
    // Bunting under the banner.
    const colors = [
      Color(0xFFFF4E8A),
      Color(0xFFFFD23F),
      Color(0xFF2D9CFF),
      Color(0xFF38D66B),
    ];
    final flags = (f.w / 0.6).floor();
    for (var i = 0; i < flags; i++) {
      final x0 = left + i * f.w / flags;
      final x1 = x0 + f.w / flags;
      final sag = math.sin((i + 0.5) / flags * math.pi) * 0.35;
      final y0 = bannerTop + bannerH + sag;
      _fill.color = colors[i % colors.length];
      canvas.drawPath(
        Path()
          ..moveTo(x0, y0)
          ..lineTo(x1, y0)
          ..lineTo((x0 + x1) / 2, y0 + 0.45 + math.sin(wt * 4 + i) * 0.05)
          ..close(),
        _fill,
      );
    }
  }

  /// Faded ribbon along the torso's recent path.
  void _withBox(Canvas canvas, Box b, void Function() draw) {
    canvas.save();
    canvas.translate(b.x, b.y);
    canvas.rotate(b.angle);
    draw();
    canvas.restore();
  }

  double _padSquash(List<SimEvent> events, int index, double time) {
    final since = _since(events, EventKind.bounce, time, index.toDouble());
    if (since == null || since > 0.35) return 0;
    return math.sin(since / 0.35 * math.pi) * (1 - since / 0.35);
  }

  void _drawPad(Canvas canvas, Box b, double squash) {
    _withBox(canvas, b, () {
      final base = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, b.h * 0.15),
          width: b.w,
          height: b.h * 0.7,
        ),
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
        Rect.fromCenter(
          center: Offset(0, -b.h * 0.2 - lift - 0.12),
          width: b.w * (1 + squash * 0.15),
          height: 0.28,
        ),
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

  // --------------------------------------------------------------- ragdoll

  void _drawRope(
    Canvas canvas,
    Snapshot s,
    List<SimEvent> events,
    double time,
    double wt,
  ) {
    final a = _anchorPos(s, s.ropeAnchor);
    final hand = handPosition(s);
    final anchor = Offset(a.x, a.y);
    // The rope shoots out over the first few frames after a grab.
    final since = _since(events, EventKind.grab, time, s.ropeAnchor.toDouble());
    if (since != null && since < 0.09) {
      final tip = Offset.lerp(hand, anchor, (since / 0.09).clamp(0.15, 1.0))!;
      drawRopeStyled(canvas, hand, Offset.lerp(hand, tip, 0.5)!, tip, wt, look.rope);
      _star(canvas, tip.dx, tip.dy, 0.3, Palette.white);
      return;
    }
    final dx = a.x - hand.dx, dy = a.y - hand.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final slack = math.max(0.0, s.ropeLength - dist);
    final sag = math.min(2.0, math.sqrt(slack * dist) * 0.5);
    final mid = Offset((a.x + hand.dx) / 2, (a.y + hand.dy) / 2 + sag);
    drawRopeStyled(canvas, hand, mid, anchor, wt, look.rope);
  }

  static Offset handPosition(Snapshot s) {
    const i = Part.ropeHand;
    final a = s.pa(i);
    final hh = partSpecs[i].hh;
    return Offset(s.px(i) - math.sin(a) * hh, s.py(i) + math.cos(a) * hh);
  }

  /// Draws the ragdoll from a snapshot. Public so the shop can preview skins.
  ///
  /// Limbs are drawn "rubber hose" style: one smooth, bendy stroke through
  /// each shoulder/elbow/hand (or hip/knee/ankle) instead of separate
  /// capsules, with round hands and chunky shoes.
  void drawRagdoll(Canvas canvas, Snapshot s, Skin skin, double wt) {
    final dead = s.status == SimStatus.dead;
    final speed = math.sqrt(s.vx * s.vx + s.vy * s.vy);
    Color shade(Color c) => Color.lerp(c, const Color(0xFF000000), 0.2)!;

    // Ends of a part along its long axis: -1 = near joint, +1 = far end.
    Offset end(int i, double sign) {
      final a = s.pa(i), hh = partSpecs[i].hh;
      return Offset(s.px(i) - math.sin(a) * hh * sign, s.py(i) + math.cos(a) * hh * sign);
    }

    void hose(int upper, int lower, Color top, Color bottom, double width, {required bool back, required bool leg}) {
      final a = end(upper, -1);
      final bend = Offset.lerp(end(upper, 1), end(lower, -1), 0.5)!;
      final c = end(lower, 1);
      final topColor = back ? shade(top) : top;
      final bottomColor = back ? shade(bottom) : bottom;
      _stroke
        ..color = skin.outline
        ..strokeWidth = width + 0.08
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(bend.dx, bend.dy)
          ..lineTo(c.dx, c.dy),
        _stroke,
      );
      _stroke
        ..color = topColor
        ..strokeWidth = width;
      canvas.drawLine(a, bend, _stroke);
      _stroke.color = bottomColor;
      canvas.drawLine(bend, c, _stroke);
      // A soft highlight down the limb for a bit of roundness.
      _stroke
        ..color = Color.lerp(topColor, Palette.white, 0.35)!.withValues(alpha: 0.55)
        ..strokeWidth = width * 0.25;
      final side = Offset(-(bend - a).dy, (bend - a).dx);
      final n = side.distance == 0 ? Offset.zero : side / side.distance * width * 0.22;
      canvas.drawLine(a - n, bend - n, _stroke);

      final angle = s.pa(lower);
      if (leg) {
        // Shoe pointing the way the character faces.
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(angle);
        final shoe = RRect.fromRectAndCorners(
          const Rect.fromLTRB(-0.11, -0.09, 0.27, 0.11),
          topLeft: const Radius.circular(0.08),
          topRight: const Radius.circular(0.1),
          bottomRight: const Radius.circular(0.06),
          bottomLeft: const Radius.circular(0.05),
        );
        _fill.color = back ? shade(skin.shoes) : skin.shoes;
        canvas.drawRRect(shoe, _fill);
        _fill.color = Color.lerp(skin.shoes, Palette.white, 0.55)!;
        canvas.drawRect(const Rect.fromLTRB(-0.1, 0.06, 0.26, 0.11), _fill);
        _stroke
          ..color = skin.outline
          ..strokeWidth = 0.045;
        canvas.drawRRect(shoe, _stroke);
        canvas.restore();
      } else {
        final hand = back ? shade(skin.skin) : skin.skin;
        _fill.color = hand;
        canvas.drawCircle(c, width * 0.72, _fill);
        _stroke
          ..color = skin.outline
          ..strokeWidth = 0.04;
        canvas.drawCircle(c, width * 0.72, _stroke);
      }
    }

    hose(Part.upperArmBack, Part.lowerArmBack, skin.sleeves, skin.skin, 0.14, back: true, leg: false);
    hose(Part.upperLegBack, Part.lowerLegBack, skin.pants, skin.pants, 0.19, back: true, leg: true);
    // Neck, tucked under the head.
    final neckBase = end(Part.torso, -1);
    final headCentre = Offset(s.px(Part.head), s.py(Part.head));
    _stroke
      ..color = skin.outline
      ..strokeWidth = 0.19;
    canvas.drawLine(neckBase, Offset.lerp(neckBase, headCentre, 0.6)!, _stroke);
    _stroke
      ..color = shade(skin.skin)
      ..strokeWidth = 0.11;
    canvas.drawLine(neckBase, Offset.lerp(neckBase, headCentre, 0.6)!, _stroke);
    _drawTorso(canvas, s, skin);
    hose(Part.upperLegFront, Part.lowerLegFront, skin.pants, skin.pants, 0.19, back: false, leg: true);
    // The front arm goes under the head so a raised arm never hides the face.
    hose(Part.upperArmFront, Part.lowerArmFront, skin.sleeves, skin.skin, 0.14, back: false, leg: false);
    _drawHead(canvas, s, skin, dead: dead, speed: speed, wt: wt);
  }

  void _drawTorso(Canvas canvas, Snapshot s, Skin skin) {
    const i = Part.torso;
    final spec = partSpecs[i];
    canvas.save();
    canvas.translate(s.px(i), s.py(i));
    canvas.rotate(s.pa(i));
    // A soft bean shape, a little wider at the hips.
    final w = spec.hw * 1.08, h = spec.hh * 1.06;
    final body = Path()
      ..moveTo(0, -h)
      ..cubicTo(w * 0.9, -h, w * 1.0, -h * 0.25, w * 1.02, h * 0.4)
      ..cubicTo(w * 1.02, h * 1.02, w * 0.45, h * 1.02, 0, h)
      ..cubicTo(-w * 0.45, h * 1.02, -w * 1.02, h * 1.02, -w * 1.02, h * 0.4)
      ..cubicTo(-w * 1.0, -h * 0.25, -w * 0.9, -h, 0, -h)
      ..close();
    _fill.color = WorldRenderer._opaque;
    _fill.shader = ui.Gradient.linear(Offset(-w, -h), Offset(w, h), [
      Color.lerp(skin.shirt, Palette.white, 0.22)!,
      skin.shirt,
      Color.lerp(skin.shirt, const Color(0xFF000000), 0.18)!,
    ], const [0, 0.45, 1]);
    canvas.drawPath(body, _fill);
    _fill.shader = null;
    canvas.save();
    canvas.clipPath(body);
    // Belt with a little buckle.
    _fill.color = skin.pants;
    canvas.drawRect(Rect.fromLTRB(-w * 1.1, h * 0.6, w * 1.1, h * 1.1), _fill);
    _fill.color = Color.lerp(skin.pants, const Color(0xFF000000), 0.25)!;
    canvas.drawRect(Rect.fromLTRB(-w * 1.1, h * 0.6, w * 1.1, h * 0.66), _fill);
    _fill.color = const Color(0xFFFFD23F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.22, h * 0.63, w * 0.55, h * 0.86), const Radius.circular(0.02)),
      _fill,
    );
    canvas.restore();
    // Collar.
    _stroke
      ..color = Color.lerp(skin.shirt, const Color(0xFF000000), 0.3)!
      ..strokeWidth = 0.035;
    canvas.drawArc(Rect.fromCenter(center: Offset(0, -h), width: w * 0.9, height: h * 0.35), 0.3, math.pi - 0.6, false, _stroke);
    switch (skin.accessory) {
      case Accessory.astronaut:
        _fill.color = const Color(0xFFB0BCC8);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              -spec.hw * 1.6,
              -spec.hh * 0.7,
              spec.hw * 0.6,
              spec.hh,
            ),
            const Radius.circular(0.06),
          ),
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
        canvas.drawRect(
          Rect.fromLTRB(
            -spec.hw * 1.05,
            spec.hh * 0.45,
            spec.hw * 1.05,
            spec.hh * 0.62,
          ),
          _fill,
        );
      case Accessory.pirate:
        // Stripy shirt and a red sash.
        _fill.color = const Color(0xFF2E4A8C);
        for (var k = 0; k < 3; k++) {
          final y = -spec.hh * 0.7 + k * spec.hh * 0.45;
          canvas.drawRect(Rect.fromLTRB(-spec.hw, y, spec.hw, y + spec.hh * 0.16), _fill);
        }
        _fill.color = const Color(0xFFE63946);
        canvas.drawRect(Rect.fromLTRB(-spec.hw * 1.05, spec.hh * 0.4, spec.hw * 1.05, spec.hh * 0.62), _fill);
      case Accessory.robot:
        _fill.color = const Color(0xFF4A5563);
        final panel = Rect.fromCenter(center: Offset(0, -spec.hh * 0.1), width: spec.hw * 1.1, height: spec.hh * 0.7);
        canvas.drawRRect(RRect.fromRectAndRadius(panel, const Radius.circular(0.04)), _fill);
        _fill.color = const Color(0xFF38D66B);
        canvas.drawCircle(panel.center + Offset(-spec.hw * 0.25, 0), 0.045, _fill);
        _fill.color = const Color(0xFFFFD23F);
        canvas.drawCircle(panel.center + Offset(spec.hw * 0.25, 0), 0.045, _fill);
      case Accessory.dino:
        _fill.color = const Color(0xFFD8F5B8);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(spec.hw * 0.3, spec.hh * 0.05), width: spec.hw * 0.9, height: spec.hh * 1.3),
          _fill,
        );
      case Accessory.wizard:
        _fill.color = const Color(0xFFFFD23F);
        for (final o in [Offset(-spec.hw * 0.3, -spec.hh * 0.4), Offset(spec.hw * 0.35, spec.hh * 0.1)]) {
          _star(canvas, o.dx, o.dy, 0.07, const Color(0xFFFFD23F));
        }
      case Accessory.hair:
      case Accessory.banana:
      case Accessory.chicken:
      case Accessory.crown:
        break;
    }
    _stroke
      ..color = skin.outline
      ..strokeWidth = 0.05;
    canvas.drawPath(body, _stroke);
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
    // Drawn a bit bigger than its physics circle: cute, readable faces.
    canvas.scale(1.18);
    final headAngle = s.pa(i);

    // Behind-head accessories.
    if (skin.accessory == Accessory.dino) {
      _fill.color = const Color(0xFF3E8A2C);
      for (var k = 0; k < 4; k++) {
        final a = -2.6 + k * 0.45;
        final base = Offset(math.cos(a), math.sin(a)) * r * 0.9;
        final tip = Offset(math.cos(a), math.sin(a)) * r * 1.45;
        final side = Offset(-math.sin(a), math.cos(a)) * r * 0.2;
        canvas.drawPath(
          Path()
            ..moveTo(base.dx - side.dx, base.dy - side.dy)
            ..lineTo(tip.dx, tip.dy)
            ..lineTo(base.dx + side.dx, base.dy + side.dy)
            ..close(),
          _fill,
        );
      }
    }
    if (skin.accessory == Accessory.pirate) {
      // Bandana knot tails.
      _fill.color = const Color(0xFFE63946);
      final flap = math.sin(wt * 12) * 0.05;
      canvas.drawOval(Rect.fromCenter(center: Offset(-r * 1.15, -r * 0.35 + flap), width: r * 0.6, height: r * 0.3), _fill);
    }
    if (skin.accessory == Accessory.ninja) {
      _stroke
        ..color = const Color(0xFFE63946)
        ..strokeWidth = 0.07;
      final flap = math.sin(wt * 14) * 0.08;
      canvas.drawLine(
        Offset(-r * 0.9, -r * 0.2),
        Offset(-r * 2.1, -r * 0.1 + flap),
        _stroke,
      );
      canvas.drawLine(
        Offset(-r * 0.9, -r * 0.1),
        Offset(-r * 1.9, r * 0.3 - flap),
        _stroke,
      );
    }

    _fill.color = WorldRenderer._opaque;
    _fill.shader = ui.Gradient.radial(Offset(r * 0.1, -r * 0.35), r * 1.25, [
      Color.lerp(skin.skin, Palette.white, 0.28)!,
      skin.skin,
      Color.lerp(skin.skin, const Color(0xFF000000), 0.14)!,
    ], const [0, 0.55, 1]);
    canvas.drawCircle(Offset.zero, r, _fill);
    _fill.shader = null;
    _stroke
      ..color = skin.outline
      ..strokeWidth = 0.045;
    canvas.drawCircle(Offset.zero, r, _stroke);
    const earred = {Accessory.hair, Accessory.pirate, Accessory.wizard, Accessory.crown};
    if (earred.contains(skin.accessory)) {
      final ear = Rect.fromCenter(center: Offset(-r * 0.32, r * 0.08), width: r * 0.3, height: r * 0.38);
      _fill.color = Color.lerp(skin.skin, const Color(0xFF000000), 0.06)!;
      canvas.drawOval(ear, _fill);
      _stroke
        ..color = Color.lerp(skin.skin, const Color(0xFF000000), 0.4)!
        ..strokeWidth = 0.03;
      canvas.drawArc(ear.deflate(r * 0.05), -1.2, 3.4, false, _stroke);
    }

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
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-r * 0.15, -r * 1.45, r * 0.3, r * 0.6),
            const Radius.circular(0.04),
          ),
          _fill,
        );
      case Accessory.chicken:
        _fill.color = const Color(0xFFE63946);
        for (var k = 0; k < 3; k++) {
          canvas.drawCircle(
            Offset(-r * 0.35 + k * r * 0.35, -r * 1.0 - (k == 1 ? 0.06 : 0)),
            r * 0.24,
            _fill,
          );
        }
        canvas.drawCircle(Offset(r * 0.8, r * 0.55), r * 0.18, _fill);
      case Accessory.ninja:
        _fill.color = const Color(0xFFFFD2A8);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-r * 0.2, -r * 0.45, r * 1.15, r * 0.45),
            Radius.circular(r * 0.2),
          ),
          _fill,
        );
        _fill.color = const Color(0xFFE63946);
        canvas.drawRect(Rect.fromLTRB(-r, -r * 0.75, r, -r * 0.5), _fill);
      case Accessory.pirate:
        _fill.color = const Color(0xFFE63946);
        canvas.drawPath(
          Path()
            ..addArc(Rect.fromCircle(center: Offset.zero, radius: r * 1.02), math.pi * 1.05, math.pi * 0.95)
            ..lineTo(r, -r * 0.3)
            ..lineTo(-r, -r * 0.3)
            ..close(),
          _fill,
        );
        _fill.color = Palette.white;
        canvas.drawCircle(Offset(-r * 0.2, -r * 0.7), r * 0.08, _fill);
        canvas.drawCircle(Offset(r * 0.35, -r * 0.6), r * 0.08, _fill);
      case Accessory.robot:
        _stroke
          ..color = const Color(0xFF6E7C8C)
          ..strokeWidth = 0.04;
        canvas.drawLine(Offset(-r * 0.8, r * 0.45), Offset(r * 0.9, r * 0.45), _stroke);
      case Accessory.knight:
      case Accessory.astronaut:
      case Accessory.dino:
      case Accessory.wizard:
      case Accessory.crown:
        break;
    }

    _drawFace(canvas, s, r, headAngle, dead: dead, speed: speed, skin: skin);

    switch (skin.accessory) {
      case Accessory.knight:
        _fill.color = const Color(0xFFC3CCD5);
        final helmet = Path()
          ..addArc(
            Rect.fromCircle(center: Offset.zero, radius: r * 1.08),
            math.pi,
            math.pi,
          )
          ..lineTo(r * 1.08, r * 0.1)
          ..lineTo(-r * 1.08, r * 0.1)
          ..close();
        canvas.drawPath(helmet, _fill);
        _stroke.color = skin.outline;
        canvas.drawPath(helmet, _stroke);
        _fill.color = const Color(0xFF2B2D42);
        canvas.drawRect(
          Rect.fromLTRB(-r * 0.1, -r * 0.3, r * 0.95, -r * 0.12),
          _fill,
        );
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
      case Accessory.pirate:
        // Eye patch over the front eye, and a gold earring.
        _stroke
          ..color = Palette.ink
          ..strokeWidth = 0.035;
        canvas.drawLine(Offset(-r * 0.9, -r * 0.55), Offset(r * 0.95, r * 0.05), _stroke);
        _fill.color = Palette.ink;
        canvas.drawOval(Rect.fromCenter(center: Offset(r * 0.55, -r * 0.15), width: r * 0.5, height: r * 0.42), _fill);
        _stroke
          ..color = const Color(0xFFFFC21A)
          ..strokeWidth = 0.03;
        canvas.drawCircle(Offset(-r * 0.1, r * 0.75), r * 0.14, _stroke);
      case Accessory.robot:
        _stroke
          ..color = const Color(0xFF4A5563)
          ..strokeWidth = 0.04;
        canvas.drawLine(Offset(0, -r), Offset(0, -r * 1.55), _stroke);
        final blink = math.sin(wt * 5) > 0;
        _fill.color = blink ? const Color(0xFFFF4040) : const Color(0xFFB02020);
        canvas.drawCircle(Offset(0, -r * 1.6), r * 0.16, _fill);
        _fill.color = const Color(0xFF6E7C8C);
        canvas.drawCircle(Offset(-r * 0.95, 0), r * 0.18, _fill);
      case Accessory.dino:
        _fill.color = Palette.ink;
        canvas.drawCircle(Offset(r * 0.95, r * 0.05), r * 0.05, _fill);
      case Accessory.wizard:
        // Beard, then a tall starry hat.
        _fill.color = const Color(0xFFF4F4F4);
        canvas.drawPath(
          Path()
            ..moveTo(-r * 0.2, r * 0.35)
            ..quadraticBezierTo(r * 0.3, r * 1.9, r * 0.95, r * 0.25)
            ..close(),
          _fill,
        );
        _fill.color = const Color(0xFF6A4BC4);
        canvas.drawPath(
          Path()
            ..moveTo(-r * 1.15, -r * 0.45)
            ..lineTo(r * 1.1, -r * 0.45)
            ..lineTo(-r * 0.3, -r * 2.4)
            ..close(),
          _fill,
        );
        _fill.color = const Color(0xFF503796);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTRB(-r * 1.3, -r * 0.6, r * 1.25, -r * 0.35), Radius.circular(r * 0.1)),
          _fill,
        );
        _star(canvas, -r * 0.1, -r * 1.2, r * 0.22, const Color(0xFFFFD23F));
      case Accessory.crown:
        _fill.color = const Color(0xFFFFC21A);
        final crown = Path()
          ..moveTo(-r * 0.75, -r * 0.65)
          ..lineTo(-r * 0.85, -r * 1.55)
          ..lineTo(-r * 0.4, -r * 1.1)
          ..lineTo(0, -r * 1.7)
          ..lineTo(r * 0.4, -r * 1.1)
          ..lineTo(r * 0.85, -r * 1.55)
          ..lineTo(r * 0.75, -r * 0.65)
          ..close();
        canvas.drawPath(crown, _fill);
        _stroke
          ..color = const Color(0xFFB07A00)
          ..strokeWidth = 0.04;
        canvas.drawPath(crown, _stroke);
        _fill.color = const Color(0xFFE63946);
        canvas.drawCircle(Offset(0, -r * 0.95), r * 0.13, _fill);
        // A little sparkle.
        final twinkle = (math.sin(wt * 4) + 1) / 2;
        _star(canvas, r * 0.9, -r * 1.7, r * 0.18 * twinkle + 0.02, Palette.white);
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
    final eyeY = -r * 0.12;
    final eyes = [Offset(r * 0.12, eyeY), Offset(r * 0.58, eyeY)];
    final ink = skin.accessory == Accessory.ninja ? const Color(0xFF14151C) : Palette.ink;
    if (dead) {
      _stroke
        ..color = ink
        ..strokeWidth = 0.05;
      for (final e in eyes) {
        const d = 0.075;
        canvas.drawLine(e + const Offset(-d, -d), e + const Offset(d, d), _stroke);
        canvas.drawLine(e + const Offset(-d, d), e + const Offset(d, -d), _stroke);
      }
      // Tongue out.
      _fill.color = const Color(0xFFFF6B8A);
      canvas.drawOval(Rect.fromCenter(center: Offset(r * 0.45, r * 0.52), width: r * 0.3, height: r * 0.42), _fill);
      _stroke.strokeWidth = 0.04;
      canvas.drawLine(Offset(r * 0.18, r * 0.38), Offset(r * 0.72, r * 0.38), _stroke);
      return;
    }
    // Pupils look along the velocity (in head space).
    var lx = 0.0, ly = 0.0;
    if (speed > 0.5) {
      final c = math.cos(-headAngle), sn = math.sin(-headAngle);
      lx = (s.vx * c - s.vy * sn) / speed * 0.045;
      ly = (s.vx * sn + s.vy * c) / speed * 0.045;
    }
    final excited = speed > 9;
    for (final e in eyes) {
      final white = Rect.fromCenter(center: e, width: r * 0.36, height: r * (excited ? 0.5 : 0.44));
      _fill.color = Palette.white;
      canvas.drawOval(white, _fill);
      _stroke
        ..color = ink
        ..strokeWidth = 0.03;
      canvas.drawOval(white, _stroke);
      final pupil = e + Offset(lx, ly + r * 0.03);
      _fill.color = ink;
      canvas.drawOval(Rect.fromCenter(center: pupil, width: r * 0.19, height: r * 0.23), _fill);
      _fill.color = Palette.white;
      canvas.drawCircle(pupil + Offset(-r * 0.04, -r * 0.05), r * 0.045, _fill);
      canvas.drawCircle(pupil + Offset(r * 0.035, r * 0.04), r * 0.02, _fill);
      // Eyebrows: raised when flying fast, relaxed otherwise.
      if (skin.accessory != Accessory.knight && skin.accessory != Accessory.ninja) {
        final lift = excited ? r * 0.12 : 0.0;
        _stroke
          ..color = Color.lerp(ink, skin.skin, 0.15)!
          ..strokeWidth = 0.035;
        canvas.drawArc(
          Rect.fromCenter(center: e + Offset(0, -r * 0.34 - lift), width: r * 0.34, height: r * 0.16),
          math.pi * 1.1,
          math.pi * 0.8,
          false,
          _stroke,
        );
      }
    }
    if (skin.accessory != Accessory.ninja && skin.accessory != Accessory.knight) {
      _fill.color = const Color(0x66FF6B8A);
      canvas.drawOval(Rect.fromCenter(center: Offset(r * 0.78, r * 0.24), width: r * 0.26, height: r * 0.16), _fill);
      canvas.drawOval(Rect.fromCenter(center: Offset(-r * 0.02, r * 0.24), width: r * 0.22, height: r * 0.14), _fill);
    }
    final mouth = Offset(r * 0.38, r * 0.38);
    if (excited) {
      // Screaming with joy (or terror).
      final o = Rect.fromCenter(center: mouth + Offset(0, r * 0.04), width: r * 0.32, height: r * 0.4);
      _fill.color = const Color(0xFF7A1F2B);
      canvas.drawOval(o, _fill);
      _fill.color = const Color(0xFFFF7D95);
      canvas.drawOval(Rect.fromLTRB(o.left + r * 0.06, o.center.dy + r * 0.02, o.right - r * 0.06, o.bottom - r * 0.02), _fill);
      _stroke
        ..color = ink
        ..strokeWidth = 0.03;
      canvas.drawOval(o, _stroke);
    } else if (speed > 4) {
      // Open grin.
      final grin = Path()
        ..moveTo(mouth.dx - r * 0.24, mouth.dy - r * 0.06)
        ..quadraticBezierTo(mouth.dx, mouth.dy + r * 0.42, mouth.dx + r * 0.24, mouth.dy - r * 0.06)
        ..close();
      _fill.color = const Color(0xFF7A1F2B);
      canvas.drawPath(grin, _fill);
      _stroke
        ..color = ink
        ..strokeWidth = 0.03;
      canvas.drawPath(grin, _stroke);
    } else {
      _stroke
        ..color = ink
        ..strokeWidth = 0.035;
      canvas.drawArc(Rect.fromCenter(center: mouth - Offset(0, r * 0.08), width: r * 0.42, height: r * 0.3), 0.35, math.pi - 0.7, false, _stroke);
    }
  }


  // --------------------------------------------------------------- effects

  /// Seconds since the latest event of [kind] (optionally matching [value]).
  double? _since(
    List<SimEvent> events,
    EventKind kind,
    double time, [
    double? value,
  ]) {
    for (var i = events.length - 1; i >= 0; i--) {
      final e = events[i];
      if (e.t > time) continue;
      if (time - e.t > 2) return null;
      if (e.kind == kind && (value == null || e.value == value)) {
        return time - e.t;
      }
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
          if (age < 0.4) {
            _sparkle(canvas, e.x, e.y, age / 0.4, Palette.coin, idx);
          }
        case EventKind.bonk:
          if (age < 0.45) _dust(canvas, e.x, e.y, age / 0.45, idx);
          if (age < 0.6) _dizzyStars(canvas, e.x, e.y, age / 0.6, idx);
          if (e.value > 11 && age < 0.5) {
            _comicText(canvas, 'BONK!', e.x, e.y - 1.2, age / 0.5, 0.9);
          }
        case EventKind.bounce:
          if (age < 0.3) {
            _stroke
              ..color = Palette.padTop.withValues(alpha: 1 - age / 0.3)
              ..strokeWidth = 0.12;
            canvas.drawCircle(Offset(e.x, e.y - 0.5), 0.5 + age * 6, _stroke);
          }
        case EventKind.death:
          if (age < 0.8) {
            drawFailEffect(
              canvas,
              e.x,
              e.y,
              age / 0.8,
              idx,
              look.failEffect,
              _deathWord(e.value.toInt()),
            );
          }
        case EventKind.style:
          if (age < 1.2) {
            final t = age / 1.2;
            _floatText(
              canvas,
              '${e.label}  +${e.value.toInt()}',
              e.x,
              e.y - 1.8 - t * 1.5,
              t,
              const Color(0xFFFFE14D),
            );
          }
        case EventKind.checkpoint:
          if (age < 1.2) {
            _floatText(
              canvas,
              'CHECKPOINT!',
              e.x,
              e.y - 4.2 - age,
              age / 1.2,
              const Color(0xFF38D66B),
            );
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
        case EventKind.launch:
          if (age < 0.6) {
            final first = !events
                .take(idx)
                .any((o) => o.kind == EventKind.grab);
            _launchBurst(canvas, e.x, e.y, age / 0.6, first: first);
          }
        case EventKind.shatter:
          if (age < 0.9) _shards(canvas, e.x, e.y, age, idx);
          if (age < 0.5) {
            _comicText(canvas, 'SMASH!', e.x, e.y - 2.2, age / 0.5, 0.9);
          }
        case EventKind.boom:
          if (age < 0.6) _explosion(canvas, e.x, e.y, age / 0.6, idx);
          if (e.label == 'hit' && age < 0.7) {
            _comicText(canvas, 'KABOOM!', e.x, e.y - 1.8, age / 0.7, 1.2);
          }
        case EventKind.crumble:
          if (age < 0.45) _dust(canvas, e.x, e.y, age / 0.45, idx);
        case EventKind.flip:
          if (age < 0.4) _flipSparkle(canvas, e.x, e.y, age / 0.4);
        case EventKind.rocket:
          if (age < 0.5) _dust(canvas, e.x, e.y, age / 0.5, idx);
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

  void _sparkle(
    Canvas canvas,
    double x,
    double y,
    double t,
    Color color,
    int seed,
  ) {
    _fill.color = color.withValues(alpha: 1 - t);
    for (var k = 0; k < 6; k++) {
      final a = k / 6 * math.pi * 2 + _rand(seed, k);
      final d = 0.3 + t * 1.2;
      canvas.drawCircle(
        Offset(x + math.cos(a) * d, y + math.sin(a) * d),
        0.12 * (1 - t) + 0.03,
        _fill,
      );
    }
  }

  void _dust(Canvas canvas, double x, double y, double t, int seed) {
    _fill.color = Palette.white.withValues(alpha: 0.7 * (1 - t));
    for (var k = 0; k < 6; k++) {
      final a = -math.pi * (0.1 + 0.8 * k / 5) + (_rand(seed, k) - 0.5) * 0.4;
      final d = 0.2 + t * (0.8 + _rand(seed, k + 9) * 0.6);
      canvas.drawCircle(
        Offset(x + math.cos(a) * d, y + math.sin(a) * d * 0.6),
        0.12 + 0.22 * t,
        _fill,
      );
    }
  }

  /// Ring of speed puffs where the slingshot launch started, plus a "GO!"
  /// the first time in a run.
  void _launchBurst(
    Canvas canvas,
    double x,
    double y,
    double t, {
    required bool first,
  }) {
    final origin = Offset(x, y);
    _stroke
      ..color = Palette.white.withValues(alpha: 0.8 * (1 - t))
      ..strokeWidth = 0.18 * (1 - t) + 0.03;
    canvas.drawCircle(origin, 0.4 + t * 2.4, _stroke);
    for (var k = 0; k < 8; k++) {
      final a = k / 8 * math.pi * 2;
      final d = 0.5 + t * 2.2;
      _fill.color = Palette.white.withValues(alpha: 0.6 * (1 - t));
      canvas.drawCircle(
        origin + Offset(math.cos(a), math.sin(a)) * d,
        0.18 * (1 - t) + 0.04,
        _fill,
      );
    }
    if (first) {
      _comicText(canvas, 'GO!', origin.dx, origin.dy - 2.2 - t, t, 1.2);
    }
  }

  void _dizzyStars(Canvas canvas, double x, double y, double t, int seed) {
    for (var k = 0; k < 3; k++) {
      final a = t * math.pi * 3 + k * math.pi * 2 / 3;
      _star(
        canvas,
        x + math.cos(a) * 0.6,
        y - 0.4 + math.sin(a) * 0.25,
        0.18 * (1 - t * 0.5),
        const Color(0xFFFFE14D).withValues(alpha: 1 - t),
      );
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
    const colors = [
      Color(0xFFFFE14D),
      Color(0xFFFF5E2B),
      Color(0xFFFFFFFF),
      Color(0xFF2D9CFF),
    ];
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
    const colors = [
      Color(0xFFFF5E8A),
      Color(0xFFFFE14D),
      Color(0xFF2D9CFF),
      Color(0xFF38D66B),
      Color(0xFFB36BFF),
    ];
    for (var k = 0; k < 40; k++) {
      final vx = (_rand(seed, k) - 0.5) * 12;
      final vy = -6 - _rand(seed, k + 50) * 8;
      final px = x + vx * age;
      final py = y + vy * age + 9 * age * age;
      _fill.color = colors[k % colors.length].withValues(
        alpha: (1 - age / 1.6).clamp(0, 1),
      );
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
            shadows: const [
              Shadow(
                color: Palette.ink,
                offset: Offset(0.05, 0.07),
                blurRadius: 0,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    });
  }

  void _floatText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double t,
    Color color,
  ) {
    final alpha = t < 0.7 ? 1.0 : 1 - (t - 0.7) / 0.3;
    // Alpha is quantised so the text layout cache stays small.
    final q = (alpha.clamp(0.0, 1.0) * 8).round() / 8;
    final tp = _text(text, color.withValues(alpha: q), 0.7);
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _comicText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double t,
    double size,
  ) {
    final pop = t < 0.15
        ? t / 0.15 * 1.25
        : (t < 0.3 ? 1.25 - (t - 0.15) / 0.15 * 0.25 : 1.0);
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
