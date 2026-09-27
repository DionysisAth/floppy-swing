import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app.dart';
import 'theme.dart';

/// A fat, bouncy cartoon button with a 3D lip.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.color = AppColors.orange,
    this.shade = AppColors.orangeDark,
    this.fontSize = 26,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
    this.expand = false,
    this.child,
  });

  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final Color color;
  final Color shade;
  final double fontSize;
  final EdgeInsets padding;
  final bool expand;
  final Widget? child;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final color = enabled ? widget.color : AppColors.grey;
    final shade = enabled ? widget.shade : AppColors.greyDark;
    final label = widget.label;
    final row = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null)
          Icon(widget.icon, color: Colors.white, size: widget.fontSize * 1.1,
              shadows: const [Shadow(color: AppColors.ink, offset: Offset(0, 2))]),
        if (widget.icon != null && label != null) const SizedBox(width: 8),
        if (label != null)
          widget.expand
              ? Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(label, style: display(widget.fontSize))))
              : Text(label, style: display(widget.fontSize)),
      ],
    );
    // Labels shrink rather than overflow (long translations, big system text).
    final content = widget.child ?? (widget.expand ? row : FittedBox(fit: BoxFit.scaleDown, child: row));
    const lip = 6.0;
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: enabled
            ? (_) {
                setState(() => _down = false);
                AppServices.maybeOf(context)?.audio.click();
                widget.onPressed!();
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          margin: EdgeInsets.only(top: _down ? lip : 0, bottom: _down ? 0 : lip),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.ink, width: 3),
            boxShadow: [
              BoxShadow(color: shade, offset: Offset(0, _down ? 0 : lip), blurRadius: 0),
            ],
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Round icon-only chunky button.
class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = AppColors.blue,
    this.shade = AppColors.blueDark,
    this.size = 26,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final Color shade;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => Semantics(
    label: tooltip,
    child: ChunkyButton(
      onPressed: onPressed,
      icon: icon,
      color: color,
      shade: shade,
      fontSize: size,
      padding: const EdgeInsets.all(10),
    ),
  );
}

class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: AppColors.yellow,
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.yellowDark, width: size * 0.14),
    ),
    alignment: Alignment.center,
    child: Container(
      width: size * 0.36,
      height: size * 0.36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.yellowDark, width: size * 0.08),
      ),
    ),
  );
}

/// Coin balance pill.
class CoinBadge extends StatelessWidget {
  const CoinBadge({super.key, required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: AppColors.ink, width: 3),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CoinIcon(),
        const SizedBox(width: 6),
        Text('$coins', style: display(22, color: AppColors.ink, shadow: false)),
      ],
    ),
  );
}

/// A faceted gem, the premium currency.
class GemIcon extends StatelessWidget {
  const GemIcon({super.key, this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: const _GemPainter());
}

class _GemPainter extends CustomPainter {
  const _GemPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final outline = Path()
      ..moveTo(w * 0.22, h * 0.12)
      ..lineTo(w * 0.78, h * 0.12)
      ..lineTo(w, h * 0.38)
      ..lineTo(w * 0.5, h * 0.95)
      ..lineTo(0, h * 0.38)
      ..close();
    canvas.drawPath(outline, Paint()..color = const Color(0xFF3FD0FF));
    // Facets.
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.38)
        ..lineTo(w, h * 0.38)
        ..lineTo(w * 0.5, h * 0.95)
        ..close(),
      Paint()..color = const Color(0xFF1C9AD6),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.22, h * 0.12)
        ..lineTo(w * 0.5, h * 0.38)
        ..lineTo(w * 0.78, h * 0.12)
        ..close(),
      Paint()..color = const Color(0xFFB8F1FF),
    );
    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.09
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.ink,
    );
  }

  @override
  bool shouldRepaint(_GemPainter oldDelegate) => false;
}

/// Gem balance pill.
class GemBadge extends StatelessWidget {
  const GemBadge({super.key, required this.gems});
  final int gems;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: AppColors.ink, width: 3),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const GemIcon(),
        const SizedBox(width: 6),
        Text('$gems', style: display(22, color: AppColors.ink, shadow: false)),
      ],
    ),
  );
}

class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.mask, this.size = 18, this.spacing = 1});
  final int mask;
  final double size;
  final double spacing;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < 3; i++)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing),
          child: Icon(
            Icons.star_rounded,
            size: size,
            color: (mask >> i) & 1 == 1 ? AppColors.yellow : const Color(0x55000000),
            shadows: (mask >> i) & 1 == 1
                ? const [Shadow(color: AppColors.ink, offset: Offset(0, 1.5))]
                : null,
          ),
        ),
    ],
  );
}

/// Safe area whose content is at most [maxWidth] wide and centred, so
/// screens don't stretch edge to edge on tablets.
class ContentArea extends StatelessWidget {
  const ContentArea({super.key, required this.child, this.maxWidth = 640});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: LayoutBuilder(
      builder: (context, box) => Center(
        child: SizedBox(width: math.min(box.maxWidth, maxWidth), height: box.maxHeight, child: child),
      ),
    ),
  );
}

/// Centres [child] and keeps it at most [maxWidth] wide (dialogs and
/// panels on tablets).
class Narrow extends StatelessWidget {
  const Narrow({super.key, required this.child, this.maxWidth = 520});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
  );
}

/// White rounded card with a thick outline.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(20), this.color = Colors.white});
  final Widget child;
  final EdgeInsets padding;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: AppColors.ink, width: 4),
      boxShadow: const [BoxShadow(color: Color(0x552B1D14), offset: Offset(0, 8))],
    ),
    // Own Material so list tiles and ink splashes inside show on the card.
    child: Material(type: MaterialType.transparency, child: child),
  );
}
