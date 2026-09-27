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
    final content = widget.child ??
        Row(
          mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null)
              Icon(widget.icon, color: Colors.white, size: widget.fontSize * 1.1,
                  shadows: const [Shadow(color: AppColors.ink, offset: Offset(0, 2))]),
            if (widget.icon != null && widget.label != null) const SizedBox(width: 8),
            if (widget.label != null) Text(widget.label!, style: display(widget.fontSize)),
          ],
        );
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
    child: child,
  );
}
