part of 'renderer.dart';

/// Which scenery a world's backdrop shows.
enum Backdrop { hills, factory, city, sky, base }

/// Per-world theme keyframes. Each world drifts from its first to its last
/// keyframe across its 20 levels.
abstract final class WorldThemes {
  static const factoryStart = WorldTheme(
    skyTop: Color(0xFF5F7390),
    skyMid: Color(0xFFC7A68C),
    skyBottom: Color(0xFFEBD3B5),
    sun: Color(0xFFFFE6B8),
    sunGlow: Color(0x66FFC98A),
    mountain: Color(0xFF8D8F9C),
    hillFar: Color(0xFF6E717C),
    hillFarDark: Color(0xFF585B66),
    hillNear: Color(0xFF4F525B),
    hillNearDark: Color(0xFF3A3C44),
    tree: Color(0xFFB9B4AE),
    cloud: Color(0xFFE9E1D8),
    cloudShade: Color(0xFFC4B4A6),
    sunX: 0.75,
    sunY: 0.2,
    backdrop: Backdrop.factory,
  );
  static const factoryEnd = WorldTheme(
    skyTop: Color(0xFF3A2F4F),
    skyMid: Color(0xFFC2675A),
    skyBottom: Color(0xFFF0A36B),
    sun: Color(0xFFFFC27A),
    sunGlow: Color(0x88FF7A45),
    mountain: Color(0xFF5E4E5E),
    hillFar: Color(0xFF4A3F4B),
    hillFarDark: Color(0xFF3A313C),
    hillNear: Color(0xFF332C36),
    hillNearDark: Color(0xFF221D25),
    tree: Color(0xFF9A8A8A),
    cloud: Color(0xFFE0B7A3),
    cloudShade: Color(0xFFA9707A),
    sunX: 0.68,
    sunY: 0.32,
    backdrop: Backdrop.factory,
  );
  static const cityStart = WorldTheme(
    skyTop: Color(0xFF2D7FD1),
    skyMid: Color(0xFF8FD0F2),
    skyBottom: Color(0xFFE6F7FF),
    sun: Color(0xFFFFFBE6),
    sunGlow: Color(0x66FFFFFF),
    mountain: Color(0xFFA9CBE3),
    hillFar: Color(0xFF6D9CC0),
    hillFarDark: Color(0xFF557FA3),
    hillNear: Color(0xFF3E6689),
    hillNearDark: Color(0xFF2C4C69),
    tree: Color(0xFFFFF4C2),
    cloud: Color(0xFFFFFFFF),
    cloudShade: Color(0xFFCFE3F3),
    sunX: 0.82,
    sunY: 0.14,
    backdrop: Backdrop.city,
  );
  static const cityEnd = WorldTheme(
    skyTop: Color(0xFF101A3A),
    skyMid: Color(0xFF2E4E86),
    skyBottom: Color(0xFF6C8FC4),
    sun: Color(0xFFF4F1DE),
    sunGlow: Color(0x44C8D8FF),
    mountain: Color(0xFF2A3F63),
    hillFar: Color(0xFF1E2F4E),
    hillFarDark: Color(0xFF16243D),
    hillNear: Color(0xFF121D33),
    hillNearDark: Color(0xFF0B1222),
    tree: Color(0xFFFFD86B),
    cloud: Color(0xFF6E83A8),
    cloudShade: Color(0xFF4A5C80),
    sunX: 0.78,
    sunY: 0.18,
    backdrop: Backdrop.city,
  );
  static const skyStart = WorldTheme(
    skyTop: Color(0xFF2B9BF2),
    skyMid: Color(0xFF9AD8FF),
    skyBottom: Color(0xFFF4FBFF),
    sun: Color(0xFFFFFDE8),
    sunGlow: Color(0x77FFF7C4),
    mountain: Color(0xFF9EC9E8),
    hillFar: Color(0xFFE8F4FF),
    hillFarDark: Color(0xFFCBE1F5),
    hillNear: Color(0xFFFFFFFF),
    hillNearDark: Color(0xFFDCEBFA),
    tree: Color(0xFF6CCB4E),
    cloud: Color(0xFFFFFFFF),
    cloudShade: Color(0xFFD5E8F8),
    sunX: 0.8,
    sunY: 0.12,
    backdrop: Backdrop.sky,
  );
  static const skyEnd = WorldTheme(
    skyTop: Color(0xFF5B4BB0),
    skyMid: Color(0xFFF19AB6),
    skyBottom: Color(0xFFFFE0C2),
    sun: Color(0xFFFFE3A0),
    sunGlow: Color(0x88FFB07A),
    mountain: Color(0xFFB58FB9),
    hillFar: Color(0xFFFFD6DA),
    hillFarDark: Color(0xFFF0B8C8),
    hillNear: Color(0xFFFFE9EC),
    hillNearDark: Color(0xFFF3C6D2),
    tree: Color(0xFF7FAE55),
    cloud: Color(0xFFFFE6EE),
    cloudShade: Color(0xFFE4A9C0),
    sunX: 0.72,
    sunY: 0.3,
    backdrop: Backdrop.sky,
  );
  static const baseStart = WorldTheme(
    skyTop: Color(0xFF1B1F4A),
    skyMid: Color(0xFF6A3F7A),
    skyBottom: Color(0xFFF08A5D),
    sun: Color(0xFFFFD08A),
    sunGlow: Color(0x88FF8A50),
    mountain: Color(0xFF4A3654),
    hillFar: Color(0xFF3A2D44),
    hillFarDark: Color(0xFF2C2236),
    hillNear: Color(0xFF2A2433),
    hillNearDark: Color(0xFF1A1622),
    tree: Color(0xFF8B93A6),
    cloud: Color(0xFFB58398),
    cloudShade: Color(0xFF7C5A7E),
    sunX: 0.7,
    sunY: 0.38,
    backdrop: Backdrop.base,
  );
  static const baseEnd = WorldTheme(
    skyTop: Color(0xFF05071A),
    skyMid: Color(0xFF151C45),
    skyBottom: Color(0xFF3A2F6B),
    sun: Color(0xFFF1F4FF),
    sunGlow: Color(0x55AFC4FF),
    mountain: Color(0xFF1F2143),
    hillFar: Color(0xFF171833),
    hillFarDark: Color(0xFF111126),
    hillNear: Color(0xFF14121F),
    hillNearDark: Color(0xFF0A0912),
    tree: Color(0xFF6E7890),
    cloud: Color(0xFF3F3F6E),
    cloudShade: Color(0xFF2A2A50),
    sunX: 0.8,
    sunY: 0.14,
    backdrop: Backdrop.base,
  );
}

extension _WorldArt on WorldRenderer {
  bool get _dark => theme.skyTop.computeLuminance() < 0.05;

  // ----------------------------------------------------------- backdrops

  void _drawStars(Canvas canvas, Size size, double wt) {
    final strength = (1 - theme.skyTop.computeLuminance() / 0.05).clamp(
      0.0,
      1.0,
    );
    if (strength <= 0) return;
    for (var i = 0; i < 70; i++) {
      final x = _rand(i, 1) * size.width;
      final y = _rand(i, 2) * size.height * 0.6;
      final twinkle = 0.55 + 0.45 * math.sin(wt * (1.5 + _rand(i, 3) * 2) + i);
      _fill.color = Palette.white.withValues(
        alpha: strength * twinkle * (0.4 + _rand(i, 4) * 0.6),
      );
      canvas.drawCircle(Offset(x, y), 0.8 + _rand(i, 5) * 1.4, _fill);
    }
  }

  /// Screen x of a world x seen through [parallax].
  double _px(double wx, Cam cam, Size size, double scale, double parallax) =>
      (wx - cam.x * parallax) * scale + size.width / 2;

  double _wx(double px, Cam cam, Size size, double scale, double parallax) =>
      cam.x * parallax + (px - size.width / 2) / scale;

  /// A row of buildings: plain blocks (city) or sheds with chimneys (factory).
  void _skyline(
    Canvas canvas,
    Size size,
    Cam cam,
    double scale,
    double wt, {
    required double parallax,
    required double baseFrac,
    required Color color,
    required int seed,
    required bool factory,
    Color? windows,
    double heightScale = 1,
  }) {
    final base = size.height * baseFrac - cam.y * parallax * scale * 0.2;
    const spacing = 3.2;
    final first = (_wx(-60, cam, size, scale, parallax) / spacing).floor();
    final last = (_wx(size.width + 60, cam, size, scale, parallax) / spacing)
        .ceil();
    for (var n = first; n <= last; n++) {
      final w = (1.8 + _rand(n + seed, 1) * 1.8) * scale;
      final h = (2.5 + _rand(n + seed, 2) * 5.5) * scale * heightScale;
      final x = _px(n * spacing, cam, size, scale, parallax);
      final top = base - h;
      _fill.color = color;
      if (factory && _rand(n + seed, 3) < 0.5) {
        // Saw-tooth factory roof.
        final roof = Path()..moveTo(x, base);
        final teeth = math.max(2, (w / (0.9 * scale)).round());
        for (var k = 0; k < teeth; k++) {
          final x0 = x + w * k / teeth;
          roof
            ..lineTo(x0, top + h * 0.35)
            ..lineTo(x0, top + h * 0.15)
            ..lineTo(x0 + w / teeth, top + h * 0.35);
        }
        roof
          ..lineTo(x + w, base)
          ..close();
        canvas.drawPath(roof, _fill);
      } else {
        canvas.drawRect(Rect.fromLTRB(x, top, x + w, base), _fill);
      }
      if (factory && _rand(n + seed, 4) < 0.45) {
        final cw = 0.35 * scale, ch = h * (0.6 + _rand(n + seed, 5) * 0.5);
        final cx = x + w * (0.2 + 0.5 * _rand(n + seed, 6));
        canvas.drawRect(
          Rect.fromLTRB(cx, top - ch * 0.6, cx + cw, base),
          _fill,
        );
        _fill.color = Palette.danger.withValues(alpha: 0.8);
        canvas.drawRect(
          Rect.fromLTRB(cx, top - ch * 0.6, cx + cw, top - ch * 0.5),
          _fill,
        );
        // Smoke drifting up.
        for (var p = 0; p < 4; p++) {
          final age = ((wt * 0.35 + p / 4 + _rand(n, 7)) % 1.0);
          _fill.color = theme.tree.withValues(alpha: 0.45 * (1 - age));
          canvas.drawCircle(
            Offset(
              cx + cw / 2 + age * 1.5 * scale,
              top - ch * 0.6 - age * 3.5 * scale,
            ),
            (0.3 + age * 0.9) * scale,
            _fill,
          );
        }
      }
      if (windows != null) {
        _fill.color = windows;
        final cols = math.max(1, (w / (0.55 * scale)).floor());
        final rows = math.max(1, (h / (0.8 * scale)).floor() - 1);
        for (var c = 0; c < cols; c++) {
          for (var r = 0; r < rows; r++) {
            if (_rand(n * 131 + c * 7 + r, seed) < 0.45) continue;
            canvas.drawRect(
              Rect.fromLTWH(
                x + (c + 0.3) * w / cols,
                top + (r + 0.6) * 0.8 * scale,
                w / cols * 0.4,
                0.35 * scale,
              ),
              _fill,
            );
          }
        }
      }
    }
    _fill.color = color;
    canvas.drawRect(Rect.fromLTRB(0, base - 1, size.width, size.height), _fill);
  }

  void _floatingIslands(
    Canvas canvas,
    Size size,
    Cam cam,
    double scale,
    double wt,
  ) {
    const parallax = 0.12;
    const spacing = 9.0;
    final first = (_wx(-80, cam, size, scale, parallax) / spacing).floor();
    final last = (_wx(size.width + 80, cam, size, scale, parallax) / spacing)
        .ceil();
    for (var n = first; n <= last; n++) {
      if (_rand(n, 11) < 0.3) continue;
      final x = _px(n * spacing + _rand(n, 12) * 4, cam, size, scale, parallax);
      final bob = math.sin(wt * 0.6 + n) * 0.15 * scale;
      final y =
          size.height * (0.3 + _rand(n, 13) * 0.3) -
          cam.y * parallax * scale * 0.2 +
          bob;
      final w = (2 + _rand(n, 14) * 2.5) * scale * 0.7;
      final island = Path()
        ..moveTo(x - w, y)
        ..quadraticBezierTo(x - w * 0.5, y + w * 0.9, x, y + w * 1.1)
        ..quadraticBezierTo(x + w * 0.5, y + w * 0.9, x + w, y)
        ..close();
      _fill.color = theme.mountain;
      canvas.drawPath(island, _fill);
      _fill.color = Color.lerp(theme.tree, theme.mountain, 0.45)!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            x - w * 1.02,
            y - 0.25 * scale,
            x + w * 1.02,
            y + 0.15 * scale,
          ),
          Radius.circular(0.2 * scale),
        ),
        _fill,
      );
    }
  }

  void _cloudSea(
    Canvas canvas,
    Size size,
    Cam cam,
    double scale,
    double wt,
    double parallax,
    double baseFrac,
    Color color,
    Color shade,
  ) {
    final base = size.height * baseFrac - cam.y * parallax * scale * 0.2;
    final path = Path()..moveTo(0, size.height);
    for (var px = 0.0; px <= size.width + 10; px += 10) {
      final wx = _wx(px, cam, size, scale, parallax) + wt * 0.2;
      final h =
          (math.sin(wx * 1.3).abs() * 0.6 +
              math.sin(wx * 0.37 + 1).abs() * 0.8) *
          scale;
      path.lineTo(px, base - h);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    _fill.shader = ui.Gradient.linear(
      Offset(0, base - scale),
      Offset(0, base + 4 * scale),
      [color, shade],
    );
    canvas.drawPath(path, _fill);
    _fill.shader = null;
  }

  void _launchTowers(
    Canvas canvas,
    Size size,
    Cam cam,
    double scale,
    double wt,
  ) {
    const parallax = 0.18;
    const spacing = 16.0;
    final base = size.height * 0.74 - cam.y * parallax * scale * 0.2;
    final first = (_wx(-60, cam, size, scale, parallax) / spacing).floor();
    final last = (_wx(size.width + 60, cam, size, scale, parallax) / spacing)
        .ceil();
    for (var n = first; n <= last; n++) {
      final x = _px(n * spacing + _rand(n, 21) * 5, cam, size, scale, parallax);
      final h = (6 + _rand(n, 22) * 3) * scale;
      final w = 0.9 * scale;
      _stroke
        ..color = theme.tree
        ..strokeWidth = 0.08 * scale;
      canvas.drawLine(Offset(x, base), Offset(x, base - h), _stroke);
      canvas.drawLine(Offset(x + w, base), Offset(x + w, base - h), _stroke);
      for (var y = base; y > base - h; y -= w) {
        canvas.drawLine(Offset(x, y), Offset(x + w, y - w), _stroke);
      }
      // Rocket on the pad next to the tower.
      if (_rand(n, 23) < 0.6) {
        final rx = x + w * 2.2, rh = h * 0.8;
        _fill.color = Color.lerp(theme.tree, Palette.white, 0.35)!;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(rx, base - rh, rx + w * 0.9, base),
            Radius.circular(w * 0.45),
          ),
          _fill,
        );
      }
      // Blinking warning light.
      final on = math.sin(wt * 3 + n) > 0.3;
      _fill.color = on ? const Color(0xFFFF4040) : const Color(0x55FF4040);
      canvas.drawCircle(
        Offset(x + w / 2, base - h - 0.2 * scale),
        0.15 * scale,
        _fill,
      );
    }
  }

  /// Everything behind the level for worlds 2-5.
  void _drawWorldBackdrop(
    Canvas canvas,
    Size size,
    Cam cam,
    double scale,
    double wt,
  ) {
    switch (theme.backdrop) {
      case Backdrop.hills:
        break;
      case Backdrop.factory:
        _skyline(
          canvas,
          size,
          cam,
          scale,
          wt,
          parallax: 0.1,
          baseFrac: 0.64,
          color: theme.mountain,
          seed: 3,
          factory: true,
        );
        _skyline(
          canvas,
          size,
          cam,
          scale,
          wt,
          parallax: 0.25,
          baseFrac: 0.76,
          color: theme.hillFar,
          seed: 17,
          factory: true,
          heightScale: 0.8,
        );
        _hills(
          canvas,
          size,
          cam,
          scale,
          0.45,
          0.86,
          theme.hillNear,
          theme.hillNearDark,
          5,
          0.5,
          trees: false,
        );
      case Backdrop.city:
        final lit = _dark ? theme.tree : theme.tree.withValues(alpha: 0.35);
        _skyline(
          canvas,
          size,
          cam,
          scale,
          wt,
          parallax: 0.1,
          baseFrac: 0.66,
          color: theme.mountain,
          seed: 5,
          factory: false,
          heightScale: 1.5,
          windows: lit.withValues(alpha: lit.a * 0.6),
        );
        _skyline(
          canvas,
          size,
          cam,
          scale,
          wt,
          parallax: 0.28,
          baseFrac: 0.8,
          color: theme.hillFar,
          seed: 29,
          factory: false,
          heightScale: 1.2,
          windows: lit,
        );
        _hills(
          canvas,
          size,
          cam,
          scale,
          0.45,
          0.9,
          theme.hillNear,
          theme.hillNearDark,
          5,
          0.2,
          trees: false,
        );
      case Backdrop.sky:
        _floatingIslands(canvas, size, cam, scale, wt);
        _cloudSea(
          canvas,
          size,
          cam,
          scale,
          wt,
          0.25,
          0.8,
          theme.hillFar,
          theme.hillFarDark,
        );
        _cloudSea(
          canvas,
          size,
          cam,
          scale,
          wt * 1.5,
          0.45,
          0.88,
          theme.hillNear,
          theme.hillNearDark,
        );
      case Backdrop.base:
        _mountains(canvas, size, cam, scale);
        _launchTowers(canvas, size, cam, scale, wt);
        _hills(
          canvas,
          size,
          cam,
          scale,
          0.45,
          0.84,
          theme.hillNear,
          theme.hillNearDark,
          7,
          0.4,
          trees: false,
        );
    }
  }

  // ------------------------------------------------------------ platforms

  /// Non-grass platforms for worlds 2-5.
  void _drawSlab(Canvas canvas, Box b) {
    _withBox(canvas, b, () {
      final r = Rect.fromCenter(center: Offset.zero, width: b.w, height: b.h);
      _fill.color = const Color(0x2A000000);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          r.shift(const Offset(0.15, 0.3)),
          const Radius.circular(0.2),
        ),
        _fill,
      );
      switch (theme.backdrop) {
        case Backdrop.sky:
          // Floating island: grassy top, rocky tapered underside.
          final rock = Path()
            ..moveTo(r.left, r.top + 0.1)
            ..lineTo(r.right, r.top + 0.1)
            ..quadraticBezierTo(
              r.right - b.w * 0.1,
              r.bottom + b.h * 0.8,
              r.center.dx + b.w * 0.1,
              r.bottom + b.h * 1.4,
            )
            ..quadraticBezierTo(
              r.center.dx - b.w * 0.2,
              r.bottom + b.h * 1.2,
              r.left + b.w * 0.08,
              r.bottom,
            )
            ..close();
          _fill.color = WorldRenderer._opaque;
          _fill.shader = ui.Gradient.linear(
            Offset(0, r.top),
            Offset(0, r.bottom + b.h * 1.4),
            const [Color(0xFFB09A86), Color(0xFF6E5A4B)],
          );
          canvas.drawPath(rock, _fill);
          _fill.shader = null;
          _fill.color = const Color(0xFF5CC236);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTRB(
                r.left - 0.05,
                r.top - 0.06,
                r.right + 0.05,
                r.top + 0.3,
              ),
              const Radius.circular(0.15),
            ),
            _fill,
          );
          _fill.color = const Color(0xFF8BE05C);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTRB(
                r.left + 0.1,
                r.top - 0.04,
                r.right - 0.1,
                r.top + 0.1,
              ),
              const Radius.circular(0.08),
            ),
            _fill,
          );
          return;
        case Backdrop.city:
          final rr = RRect.fromRectAndRadius(r, const Radius.circular(0.12));
          _fill.color = WorldRenderer._opaque;
          _fill.shader = ui.Gradient.linear(
            Offset(0, r.top),
            Offset(0, r.bottom),
            const [Color(0xFFE3E7EC), Color(0xFFA9B3BE)],
          );
          canvas.drawRRect(rr, _fill);
          _fill.shader = null;
          _fill.color = const Color(0xFF7FC8F0);
          for (var x = r.left + 0.35; x < r.right - 0.4; x += 0.8) {
            canvas.drawRect(
              Rect.fromLTWH(x, r.top + 0.3, 0.45, math.max(0.1, b.h - 0.5)),
              _fill,
            );
          }
          _stroke
            ..color = const Color(0xFF5C6773)
            ..strokeWidth = 0.06;
          canvas.drawRRect(rr, _stroke);
          return;
        case Backdrop.factory:
        case Backdrop.base:
        case Backdrop.hills:
          final rr = RRect.fromRectAndRadius(r, const Radius.circular(0.1));
          final steel = theme.backdrop == Backdrop.base
              ? const [Color(0xFF5B6475), Color(0xFF363C48)]
              : const [Color(0xFF9AA3AE), Color(0xFF5E6772)];
          _fill.color = WorldRenderer._opaque;
          _fill.shader = ui.Gradient.linear(
            Offset(0, r.top),
            Offset(0, r.bottom),
            steel,
          );
          canvas.drawRRect(rr, _fill);
          _fill.shader = null;
          // Hazard stripes along the top edge.
          canvas.save();
          canvas.clipRect(Rect.fromLTRB(r.left, r.top, r.right, r.top + 0.22));
          _fill.color = const Color(0xFFFFC21A);
          canvas.drawRect(
            Rect.fromLTRB(r.left, r.top, r.right, r.top + 0.22),
            _fill,
          );
          _fill.color = const Color(0xFF2B2B2B);
          for (var x = r.left - 0.3; x < r.right; x += 0.5) {
            canvas.drawPath(
              Path()
                ..moveTo(x, r.top + 0.22)
                ..lineTo(x + 0.22, r.top + 0.22)
                ..lineTo(x + 0.44, r.top)
                ..lineTo(x + 0.22, r.top)
                ..close(),
              _fill,
            );
          }
          canvas.restore();
          _fill.color = const Color(0xFFD5DAE0);
          for (var x = r.left + 0.3; x < r.right - 0.2; x += 1.0) {
            canvas.drawCircle(Offset(x, r.bottom - 0.2), 0.06, _fill);
          }
          _stroke
            ..color = const Color(0xFF2B2F36)
            ..strokeWidth = 0.06;
          canvas.drawRRect(rr, _stroke);
      }
    });
  }

  // ------------------------------------------------------------ mechanics

  void _drawRail(Canvas canvas, Anchor a) {
    final to = a.to!;
    _stroke
      ..color = const Color(0xB03A3A48)
      ..strokeWidth = 0.2;
    canvas.drawLine(Offset(a.x, a.y), Offset(to.x, to.y), _stroke);
    _stroke
      ..color = const Color(0x99FFFFFF)
      ..strokeWidth = 0.04;
    canvas.drawLine(Offset(a.x, a.y), Offset(to.x, to.y), _stroke);
    _fill.color = const Color(0xFF4A4A55);
    canvas.drawCircle(Offset(a.x, a.y), 0.14, _fill);
    canvas.drawCircle(Offset(to.x, to.y), 0.14, _fill);
  }

  void _drawGlass(Canvas canvas, Box b, double wt) {
    _withBox(canvas, b, () {
      final r = Rect.fromCenter(center: Offset.zero, width: b.w, height: b.h);
      _fill.color = const Color(0x8091DDFF);
      canvas.drawRect(r, _fill);
      canvas.save();
      canvas.clipRect(r);
      _stroke
        ..color = const Color(0xAAFFFFFF)
        ..strokeWidth = 0.08;
      final shine = (wt * 0.25) % 1.0;
      for (var k = 0; k < 3; k++) {
        final y = r.top + (shine + k / 3) % 1.0 * b.h;
        canvas.drawLine(Offset(r.left, y), Offset(r.right, y - 1.2), _stroke);
      }
      canvas.restore();
      _stroke
        ..color = const Color(0xFF3F8FC0)
        ..strokeWidth = 0.12;
      canvas.drawRect(r, _stroke);
      _stroke
        ..color = const Color(0xFFE6F9FF)
        ..strokeWidth = 0.04;
      canvas.drawRect(r.deflate(0.08), _stroke);
    });
  }

  void _drawWind(Canvas canvas, Wind w, double wt) {
    _withBox(canvas, w.box, () {
      final b = w.box;
      final r = Rect.fromCenter(center: Offset.zero, width: b.w, height: b.h);
      _fill.color = WorldRenderer._opaque;
      _fill.shader = ui.Gradient.linear(
        Offset(0, r.bottom),
        Offset(0, r.top),
        const [Color(0x70FFFFFF), Color(0x10FFFFFF)],
      );
      canvas.drawRect(r, _fill);
      _fill.shader = null;
      // Streaks rushing along the wind direction (local up).
      _stroke
        ..color = const Color(0xEEFFFFFF)
        ..strokeWidth = 0.09;
      final lanes = math.max(3, (b.w / 0.7).floor());
      for (var i = 0; i < lanes; i++) {
        final x = r.left + (i + 0.5) * b.w / lanes;
        for (var k = 0; k < 3; k++) {
          final f = ((wt * 1.4 + _rand(i, k) + k / 3) % 1.0);
          final y = r.bottom - f * b.h;
          canvas.drawLine(Offset(x, y), Offset(x, y - 0.8), _stroke);
        }
      }
      // Fan housing at the base.
      final fan = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          r.left + 0.2,
          r.bottom - 0.35,
          r.right - 0.2,
          r.bottom + 0.35,
        ),
        const Radius.circular(0.2),
      );
      _fill.color = const Color(0xFF5E6772);
      canvas.drawRRect(fan, _fill);
      _fill.color = const Color(0xFFD5DAE0);
      final blades = (b.w / 1.2).floor().clamp(1, 6);
      for (var k = 0; k < blades; k++) {
        final cx = r.left + 0.2 + (k + 0.5) * (b.w - 0.4) / blades;
        final spin = math.sin(wt * 30 + k) * 0.35;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, r.bottom),
            width: 0.8 * spin.abs() + 0.1,
            height: 0.4,
          ),
          _fill,
        );
      }
    });
  }

  void _drawFlipZone(Canvas canvas, Box b, double wt) {
    _withBox(canvas, b, () {
      final r = Rect.fromCenter(center: Offset.zero, width: b.w, height: b.h);
      _fill.color = const Color(0x40B36BFF);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(0.4)),
        _fill,
      );
      _stroke
        ..color = const Color(0xAAD6A8FF)
        ..strokeWidth = 0.08;
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(0.4)),
        _stroke,
      );
      // Chevrons drifting upwards.
      for (var i = 0; i < 3; i++) {
        for (var k = 0; k < 3; k++) {
          final f = ((wt * 0.6 + k / 3) % 1.0);
          final x = r.left + (i + 0.5) * b.w / 3;
          final y = r.bottom - f * b.h;
          _stroke.color = const Color(0xFFE8D2FF)
              .withValues(alpha: math.sin(f * math.pi) * 0.9);
          canvas.drawPath(
            Path()
              ..moveTo(x - 0.35, y + 0.2)
              ..lineTo(x, y - 0.15)
              ..lineTo(x + 0.35, y + 0.2),
            _stroke,
          );
        }
      }
    });
  }

  void _drawCrumble(
    Canvas canvas,
    int i,
    Snapshot s,
    List<SimEvent> events,
    double time,
    double wt,
  ) {
    final b = level.crumbles[i];
    final x = s.crumbles[i * 3],
        y = s.crumbles[i * 3 + 1],
        a = s.crumbles[i * 3 + 2];
    final cracked = _since(events, EventKind.crumble, time, i.toDouble());
    final shaking = cracked != null && cracked < 1.0 && y < b.y + 0.05;
    final jitter = shaking ? math.sin(wt * 70) * 0.05 : 0.0;
    canvas.save();
    canvas.translate(x + jitter, y);
    canvas.rotate(a);
    final r = Rect.fromCenter(center: Offset.zero, width: b.w, height: b.h);
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(0.12));
    _fill.color = WorldRenderer._opaque;
    _fill.shader = ui.Gradient.linear(
      Offset(0, r.top),
      Offset(0, r.bottom),
      cracked == null
          ? const [Color(0xFFC9A274), Color(0xFF8A6A48)]
          : const [Color(0xFFB08A60), Color(0xFF6E5236)],
    );
    canvas.drawRRect(rr, _fill);
    _fill.shader = null;
    _stroke
      ..color = const Color(0xFF5A4028)
      ..strokeWidth = 0.05;
    // Planks and cracks.
    for (var px = r.left + b.w / 4; px < r.right - 0.1; px += b.w / 4) {
      canvas.drawLine(Offset(px, r.top), Offset(px, r.bottom), _stroke);
    }
    if (cracked != null) {
      canvas.drawPath(
        Path()
          ..moveTo(-b.w * 0.2, r.top)
          ..lineTo(-b.w * 0.05, 0)
          ..lineTo(-b.w * 0.15, r.bottom)
          ..moveTo(b.w * 0.25, r.top)
          ..lineTo(b.w * 0.1, r.bottom * 0.5)
          ..lineTo(b.w * 0.2, r.bottom),
        _stroke,
      );
    }
    _stroke.strokeWidth = 0.06;
    canvas.drawRRect(rr, _stroke);
    canvas.restore();
  }

  void _drawLauncher(Canvas canvas, Launcher l, double time, double wt) {
    canvas.save();
    canvas.translate(l.x, l.y);
    canvas.rotate(l.angle + math.pi / 2);
    // Warning light when a launch is imminent.
    final phase = (time / l.period - l.phase) % 1.0;
    final untilNext = (1 - phase) * l.period;
    final warn = untilNext < 0.7 && math.sin(wt * 30) > 0;
    _fill.color = const Color(0xFF3C4350);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-0.55, -0.9, 0.55, 0.6),
        const Radius.circular(0.2),
      ),
      _fill,
    );
    _fill.color = const Color(0xFF6B7482);
    canvas.drawRect(const Rect.fromLTRB(-0.35, -1.3, 0.35, -0.6), _fill);
    _fill.color = warn ? const Color(0xFFFF3B30) : const Color(0x66FF3B30);
    canvas.drawCircle(const Offset(0, 0.1), 0.18, _fill);
    canvas.restore();
  }

  void _drawRocket(
    Canvas canvas,
    Launcher l,
    double rx,
    double ry,
    double wt,
    int seed,
  ) {
    canvas.save();
    canvas.translate(rx, ry);
    canvas.rotate(l.angle);
    // Flame.
    final flick = 0.8 + 0.2 * math.sin(wt * 50 + seed);
    _fill.color = const Color(0xFFFFB020);
    canvas.drawPath(
      Path()
        ..moveTo(-0.45, -0.18)
        ..lineTo(-0.45 - 0.9 * flick, 0)
        ..lineTo(-0.45, 0.18)
        ..close(),
      _fill,
    );
    _fill.color = const Color(0xFFFFF0A0);
    canvas.drawPath(
      Path()
        ..moveTo(-0.45, -0.09)
        ..lineTo(-0.45 - 0.45 * flick, 0)
        ..lineTo(-0.45, 0.09)
        ..close(),
      _fill,
    );
    // Body, nose and fins.
    _fill.color = const Color(0xFFF2F4F7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-0.5, -0.2, 0.35, 0.2),
        const Radius.circular(0.1),
      ),
      _fill,
    );
    _fill.color = Palette.danger;
    canvas.drawPath(
      Path()
        ..moveTo(0.3, -0.2)
        ..lineTo(0.7, 0)
        ..lineTo(0.3, 0.2)
        ..close(),
      _fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(-0.5, -0.2)
        ..lineTo(-0.65, -0.42)
        ..lineTo(-0.25, -0.2)
        ..moveTo(-0.5, 0.2)
        ..lineTo(-0.65, 0.42)
        ..lineTo(-0.25, 0.2),
      _fill,
    );
    canvas.restore();
  }

  /// Rockets in flight at [time], skipping ones that already exploded.
  void _drawRockets(Canvas canvas, Rect view, Snapshot s, double wt) {
    for (var li = 0; li < level.launchers.length; li++) {
      final l = level.launchers[li];
      if (_visible(view, l.x, l.y, 2)) {
        _drawLauncher(canvas, l, s.t, wt);
      }
      for (final k in l.activeAt(s.t)) {
        if (s.explodedRockets.contains(Simulation.rocketKey(li, k))) continue;
        final r = l.rocketAt(k, s.t);
        if (!_visible(view, r.x, r.y, 2)) continue;
        // Smoke trail.
        for (var p = 1; p <= 5; p++) {
          final back = l.rocketAt(k, s.t - p * 0.05);
          _fill.color = const Color(0xFFDDDDDD)
              .withValues(alpha: 0.5 - p * 0.08);
          canvas.drawCircle(Offset(back.x, back.y), 0.15 + p * 0.07, _fill);
        }
        _drawRocket(canvas, l, r.x, r.y, wt, k);
      }
    }
  }

  // --------------------------------------------------------------- effects

  void _shards(Canvas canvas, double x, double y, double age, int seed) {
    final t = age / 0.9;
    for (var k = 0; k < 14; k++) {
      final vx = (_rand(seed, k) - 0.3) * 10;
      final vy = (_rand(seed, k + 30) - 0.7) * 10;
      final px = x + vx * age,
          py = y + (_rand(seed, k + 60) - 0.5) * 6 + vy * age + 12 * age * age;
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(age * 12 + k);
      _fill.color = const Color(0xFFBFEFFF)
          .withValues(alpha: (1 - t).clamp(0, 1));
      canvas.drawPath(
        Path()
          ..moveTo(0, -0.25)
          ..lineTo(0.18, 0.15)
          ..lineTo(-0.15, 0.1)
          ..close(),
        _fill,
      );
      canvas.restore();
    }
  }

  void _explosion(Canvas canvas, double x, double y, double t, int seed) {
    final c = Offset(x, y);
    _fill.color = const Color(0xFFFFE14D).withValues(alpha: (1 - t) * 0.9);
    canvas.drawCircle(c, 0.4 + t * 1.6, _fill);
    _fill.color = const Color(0xFFFF7A2B).withValues(alpha: (1 - t) * 0.8);
    canvas.drawCircle(c, 0.3 + t * 1.2, _fill);
    for (var k = 0; k < 8; k++) {
      final a = k / 8 * math.pi * 2 + _rand(seed, k);
      final d = 0.6 + t * 2.4;
      _fill.color = const Color(0xFF8A8A8A).withValues(alpha: (1 - t) * 0.6);
      canvas.drawCircle(
        c + Offset(math.cos(a), math.sin(a)) * d,
        0.35 + t * 0.4,
        _fill,
      );
    }
  }

  void _flipSparkle(Canvas canvas, double x, double y, double t) {
    _stroke
      ..color = const Color(0xFFD6A8FF).withValues(alpha: 1 - t)
      ..strokeWidth = 0.1;
    canvas.drawCircle(Offset(x, y), 0.4 + t * 1.8, _stroke);
  }
}
