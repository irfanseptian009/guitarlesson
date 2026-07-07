import 'package:flutter/material.dart';

/// Strumi design tokens, lifted 1:1 from the GuitarMaster dark design.
abstract final class AppColors {
  // Brand
  static const orange = Color(0xFFF9772E);
  static const orangeLight = Color(0xFFF9A05C);
  static const orangeGradientTop = Color(0xFFFB8A45);
  static const orangeGradientBottom = Color(0xFFF0661A);

  /// Near-black used for text sitting on orange surfaces.
  static const onOrange = Color(0xFF14100B);

  // Accents
  static const blue = Color(0xFFA8C7E8);
  static const yellow = Color(0xFFE8D48A);
  static const green = Color(0xFF8CC88C);
  static const red = Color(0xFFE8908A);
  static const purple = Color(0xFFC9A8E8);

  // Surfaces
  static const backgroundTop = Color(0xFF141B26);
  static const backgroundMid = Color(0xFF0B0F15);
  static const backgroundBottom = Color(0xFF0A0D12);
  static const surfaceDeep = Color(0xFF131A24);
  static const navBackground = Color(0xEB10151C);
  static const navBorderFill = Color(0xFF10151C);

  // Text
  static const cream = Color(0xFFF2EEE6);
  static Color get creamDim => cream.withValues(alpha: 0.55);
  static Color get creamFaint => cream.withValues(alpha: 0.45);
  static Color get creamGhost => cream.withValues(alpha: 0.35);

  // Cards
  static Color get cardFill => Colors.white.withValues(alpha: 0.05);
  static Color get cardBorder => Colors.white.withValues(alpha: 0.09);
  static Color get cardFillActive => orange.withValues(alpha: 0.16);
  static Color get cardBorderActive => orange.withValues(alpha: 0.5);

  static const buttonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [orangeGradientTop, orangeGradientBottom],
  );

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundTop, backgroundMid, backgroundBottom],
    stops: [0.0, 0.55, 1.0],
  );

  static const avatarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, Color(0xFFC24E12)],
  );
}
