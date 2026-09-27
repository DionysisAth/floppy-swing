part of 'renderer.dart';

/// Rope styles, trails and fail effects (see `cosmetics.dart`). Public so the
/// shop can preview them with the same code the game uses.
extension CosmeticArt on WorldRenderer {
  /// Draws a rope from [hand] to [anchor] bending through the quadratic
  /// control point [mid], in [style].
  void drawRopeStyled(
    Canvas canvas,
    Offset hand,
    Offset mid,
    Offset anchor,
    double wt,
    String style,
  ) {
    final length = (anchor - hand).distance;
    final path = Path()
      ..moveTo(hand.dx, hand.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, anchor.dx, anchor.dy);
    // Samples along the curve: point and unit tangent.
    Iterable<(Offset, Offset)> samples(double spacing) sync* {
      final steps = (length / spacing).clamp(2, 200).round();
      for (var i = 0; i <= steps; i++) {
        final t = i / steps, u = 1 - t;
        final p = hand * (u * u) + mid * (2 * u * t) + anchor * (t * t);
        final tan = (mid - hand) * (2 * u) + (anchor - mid) * (2 * t);
        final len = tan.distance;
        yield (p, len < 1e-6 ? const Offset(1, 0) : tan / len);
      }
    }

    switch (style) {
      case 'chain':
        _stroke
          ..color = const Color(0xFF5E6772)
          ..strokeWidth = 0.05;
        canvas.drawPath(path, _stroke);
        var k = 0;
        for (final (p, d) in samples(0.2)) {
          final flat = (k++).isEven;
          canvas.save();
          canvas.translate(p.dx, p.dy);
          canvas.rotate(math.atan2(d.dy, d.dx));
          final r = Rect.fromCenter(
            center: Offset.zero,
            width: 0.28,
            height: flat ? 0.16 : 0.07,
          );
          _fill.color = flat
              ? const Color(0xFFC3CCD5)
              : const Color(0xFF8C98A4);
          canvas.drawOval(r, _fill);
          _stroke
            ..color = Palette.ink
            ..strokeWidth = 0.03;
          canvas.drawOval(r, _stroke);
          canvas.restore();
        }
      case 'spaghetti':
        final wiggle = Path();
        var first = true;
        for (final (p, d) in samples(0.08)) {
          final n = Offset(-d.dy, d.dx);
          final along = (p - hand).distance;
          final q = p + n * (math.sin(along * 7 + wt * 6) * 0.07);
          first ? wiggle.moveTo(q.dx, q.dy) : wiggle.lineTo(q.dx, q.dy);
          first = false;
        }
        _stroke
          ..color = const Color(0xFFB8862E)
          ..strokeWidth = 0.15;
        canvas.drawPath(wiggle, _stroke);
        _stroke
          ..color = const Color(0xFFF6D98A)
          ..strokeWidth = 0.09;
        canvas.drawPath(wiggle, _stroke);
        _fill.color = const Color(0xFFD7263D);
        var k = 0;
        for (final (p, _) in samples(1.3)) {
          if (k++ > 0) canvas.drawCircle(p, 0.07, _fill);
        }
      case 'rainbow':
        const bands = [
          Color(0xFFFF4D4D),
          Color(0xFFFF9F1C),
          Color(0xFFFFE14D),
          Color(0xFF38D66B),
          Color(0xFF2D9CFF),
          Color(0xFFB36BFF),
        ];
        _stroke
          ..color = Palette.ink
          ..strokeWidth = 0.28;
        canvas.drawPath(path, _stroke);
        final pts = samples(0.12).toList();
        for (var b = 0; b < bands.length; b++) {
          final off = (b - (bands.length - 1) / 2) * 0.038;
          final band = Path();
          for (var i = 0; i < pts.length; i++) {
            final (p, d) = pts[i];
            final q = p + Offset(-d.dy, d.dx) * off;
            i == 0 ? band.moveTo(q.dx, q.dy) : band.lineTo(q.dx, q.dy);
          }
          _stroke
            ..color = bands[b]
            ..strokeWidth = 0.045;
          canvas.drawPath(band, _stroke);
        }
      case 'laser':
        final flicker = 0.85 + 0.15 * math.sin(wt * 45);
        _stroke
          ..color = const Color(0x44FF2D6F)
          ..strokeWidth = 0.4 * flicker;
        canvas.drawPath(path, _stroke);
        _stroke
          ..color = const Color(0xAAFF2D6F)
          ..strokeWidth = 0.18 * flicker;
        canvas.drawPath(path, _stroke);
        _stroke
          ..color = const Color(0xFFFFF0F5)
          ..strokeWidth = 0.06;
        canvas.drawPath(path, _stroke);
        _fill.color = const Color(0xCCFF2D6F);
        canvas.drawCircle(anchor, 0.18 * flicker, _fill);
      default:
        _stroke
          ..color = Palette.ink
          ..strokeWidth = 0.17;
        canvas.drawPath(path, _stroke);
        _stroke
          ..color = const Color(0xFFC98E52)
          ..strokeWidth = 0.1;
        canvas.drawPath(path, _stroke);
        // Twisted-rope stripes.
        _stroke
          ..color = const Color(0xFF8A5A2E)
          ..strokeWidth = 0.035;
        var first = true;
        for (final (p, d) in samples(0.28)) {
          if (first) {
            first = false;
            continue;
          }
          final nrm = Offset(-d.dy, d.dx);
          canvas.drawLine(
            p - nrm * 0.045 - d * 0.04,
            p + nrm * 0.045 + d * 0.04,
            _stroke,
          );
        }
    }
  }

  /// Motion trail through [trail] (oldest first) in [style].
  void drawTrailStyled(
    Canvas canvas,
    List<Offset> trail,
    double wt,
    String style,
  ) {
    final n = trail.length;
    if (n < 2) return;
    double at(int i) => i / (n - 1);
    switch (style) {
      case 'sparkles':
      case 'stars':
        for (var i = 0; i < n; i += 2) {
          final t = at(i);
          final twinkle = 0.6 + 0.4 * math.sin(wt * 20 + i);
          final jitter = Offset(_rand(i, 1) - 0.5, _rand(i, 2) - 0.5) * 0.5;
          final color = style == 'stars'
              ? (i % 4 == 0 ? const Color(0xFFFFE14D) : const Color(0xFFC9A8FF))
              : Palette.white;
          _star(
            canvas,
            trail[i].dx + jitter.dx,
            trail[i].dy + jitter.dy,
            (0.08 + 0.14 * t) * twinkle,
            color.withValues(alpha: t),
          );
        }
      case 'fire':
        for (var i = 0; i < n; i++) {
          final t = at(i);
          final flick = 0.85 + 0.15 * math.sin(wt * 30 + i * 1.7);
          _fill.color = Color.lerp(
            const Color(0xFFE63946),
            const Color(0xFFFFE14D),
            t,
          )!.withValues(alpha: 0.25 + 0.55 * t);
          canvas.drawCircle(
            trail[i] + Offset(0, -(1 - t) * 0.3),
            (0.08 + 0.26 * t) * flick,
            _fill,
          );
        }
      case 'bubbles':
        for (var i = 0; i < n; i += 2) {
          final t = at(i);
          final c =
              trail[i] + Offset(math.sin(wt * 6 + i) * 0.15, -(1 - t) * 0.5);
          final r = 0.07 + 0.14 * _rand(i, 7) + 0.06 * t;
          _stroke
            ..color = const Color(0xFF9BE3FF).withValues(alpha: 0.3 + 0.6 * t)
            ..strokeWidth = 0.035;
          canvas.drawCircle(c, r, _stroke);
          _fill.color = Palette.white.withValues(alpha: 0.7 * t);
          canvas.drawCircle(c + Offset(-r * 0.35, -r * 0.35), r * 0.25, _fill);
        }
      case 'gold':
        for (var i = 0; i < n; i += 2) {
          final t = at(i);
          final c = trail[i] + Offset(0, (1 - t) * 0.4);
          canvas.save();
          canvas.translate(c.dx, c.dy);
          canvas.scale(math.cos(wt * 8 + i).abs() * 0.8 + 0.2, 1);
          _fill.color = const Color(0xFFFFC21A).withValues(alpha: t);
          canvas.drawCircle(Offset.zero, 0.09 + 0.06 * t, _fill);
          _stroke
            ..color = const Color(0xFFB07A00).withValues(alpha: t)
            ..strokeWidth = 0.025;
          canvas.drawCircle(Offset.zero, 0.09 + 0.06 * t, _stroke);
          canvas.restore();
        }
      case 'circuit':
        _stroke
          ..color = const Color(0xFF3FF0FF).withValues(alpha: 0.5)
          ..strokeWidth = 0.03;
        for (var i = 1; i < n; i++) {
          final a = trail[i - 1], b = trail[i];
          // Right-angled traces.
          canvas.drawLine(a, Offset(b.dx, a.dy), _stroke);
          canvas.drawLine(Offset(b.dx, a.dy), b, _stroke);
        }
        for (var i = 0; i < n; i += 3) {
          final t = at(i);
          _fill.color = const Color(0xFF3FF0FF).withValues(alpha: t);
          canvas.drawRect(
            Rect.fromCenter(
              center: trail[i],
              width: 0.1 + 0.1 * t,
              height: 0.1 + 0.1 * t,
            ),
            _fill,
          );
        }
      case 'leaves':
        for (var i = 0; i < n; i += 2) {
          final t = at(i);
          canvas.save();
          canvas.translate(trail[i].dx, trail[i].dy + (1 - t) * 0.4);
          canvas.rotate(wt * 4 + i);
          _fill.color =
              (i % 4 == 0 ? const Color(0xFF6BCB4E) : const Color(0xFF3E8A2C))
                  .withValues(alpha: t);
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: 0.3 * (0.5 + t),
              height: 0.14 * (0.5 + t),
            ),
            _fill,
          );
          canvas.restore();
        }
      default:
        for (var i = 1; i < n; i++) {
          final t = at(i);
          final seg = trail[i] - trail[i - 1];
          if (seg.distance < 0.02) continue;
          _stroke
            ..color = Palette.white.withValues(alpha: 0.5 * t * t)
            ..strokeWidth = 0.08 + 0.3 * t;
          canvas.drawLine(trail[i - 1], trail[i], _stroke);
        }
    }
  }

  /// The burst on a fail, [t] from 0 to 1 over [failEffectDuration].
  void drawFailEffect(
    Canvas canvas,
    double x,
    double y,
    double t,
    int seed,
    String style,
    String word,
  ) {
    switch (style) {
      case 'confetti':
        _confetti(canvas, x, y - 0.5, t * 1.2, seed);
        _burst(canvas, x, y, (t * 1.6).clamp(0.0, 1.0), seed);
        _comicText(canvas, 'WHEEE!', x, y - 1.6, t, 1.2);
      case 'coinpile':
        for (var k = 0; k < 24; k++) {
          final vx = (_rand(seed, k) - 0.5) * 9;
          final vy = -5 - _rand(seed, k + 40) * 7;
          final age = t * 1.2;
          final px = x + vx * age,
              py = math.min(y + 0.6, y + vy * age + 11 * age * age);
          canvas.save();
          canvas.translate(px, py);
          canvas.scale(math.cos(age * 14 + k).abs() * 0.8 + 0.2, 1);
          _fill.color = const Color(0xFFFFC21A);
          canvas.drawCircle(Offset.zero, 0.17, _fill);
          _stroke
            ..color = const Color(0xFFB07A00)
            ..strokeWidth = 0.04;
          canvas.drawCircle(Offset.zero, 0.17, _stroke);
          canvas.restore();
        }
        _comicText(canvas, 'JACKPOT!', x, y - 1.8, t, 1.2);
      case 'squeaky':
        for (var k = 0; k < 3; k++) {
          final rt = (t * 1.5 - k * 0.15).clamp(0.0, 1.0);
          if (rt <= 0) continue;
          _stroke
            ..color = const Color(0xFFFFE14D).withValues(alpha: 1 - rt)
            ..strokeWidth = 0.12;
          canvas.drawCircle(Offset(x, y), 0.4 + rt * 2.4, _stroke);
        }
        _comicText(canvas, 'SQUEAK!', x, y - 1.7, t, 1.3);
      default:
        _burst(canvas, x, y, t, seed);
        _comicText(canvas, word, x, y - 1.6, t, 1.3);
    }
  }
}
