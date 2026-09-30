import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF2B1D14);
  static const orange = Color(0xFFFF8A3D);
  static const orangeDark = Color(0xFFD9621A);
  static const pink = Color(0xFFFF4E8A);
  static const blue = Color(0xFF2D9CFF);
  static const blueDark = Color(0xFF1B6FC0);
  static const green = Color(0xFF38D66B);
  static const greenDark = Color(0xFF22A04C);
  static const yellow = Color(0xFFFFD23F);
  static const yellowDark = Color(0xFFD9A400);
  static const cream = Color(0xFFFFF6E5);
  static const grey = Color(0xFFB9B2A8);
  static const greyDark = Color(0xFF8C857B);
  static const scrim = Color(0x992B1D14);
}

/// Fredoka is a variable font; pick weights through font variations.
TextStyle body(double size, {double weight = 500, Color color = AppColors.ink}) => TextStyle(
  fontFamily: 'Fredoka',
  fontSize: size,
  color: color,
  fontVariations: [FontVariation.weight(weight)],
);

/// Chunky display face for titles and buttons.
TextStyle display(double size, {Color color = Colors.white, bool shadow = true}) => TextStyle(
  fontFamily: 'LilitaOne',
  fontSize: size,
  color: color,
  height: 1.05,
  shadows: shadow
      ? const [Shadow(color: AppColors.ink, offset: Offset(0, 3))]
      : null,
);

ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'Fredoka',
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.orange, primary: AppColors.orange),
  scaffoldBackgroundColor: AppColors.cream,
  sliderTheme: const SliderThemeData(
    activeTrackColor: AppColors.orange,
    thumbColor: AppColors.orangeDark,
    inactiveTrackColor: Color(0x33FF8A3D),
  ),
);
