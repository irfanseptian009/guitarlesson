import 'package:flutter/material.dart';

/// Legacy static design tokens, aligned with the default (light) "Capi"
/// palette. Only const-context data (catalogs/models) should still use
/// these — screens must read the theme-aware `context.colors` instead.
abstract final class AppColors {
  // Brand
  static const orange = Color(0xFFF0521F);
  static const orangeLight = Color(0xFFD8451A);
  static const orangeGradientTop = Color(0xFFF96A32);
  static const orangeGradientBottom = Color(0xFFE94614);

  /// Warm white used for text sitting on orange surfaces.
  static const onOrange = Color(0xFFFFF8EF);

  // Accents
  static const blue = Color(0xFF3554D1);
  static const yellow = Color(0xFFFFC72C);
  static const green = Color(0xFF1FA05A);
  static const red = Color(0xFFDE3F2B);
  static const purple = Color(0xFF7A4FD8);
  static const navy = Color(0xFF232B54);
  static const pink = Color(0xFFF9C6DD);
  static const pinkStrong = Color(0xFFEF6FAC);

  // Surfaces
  static const backgroundTop = Color(0xFFFDFBF4);
  static const backgroundMid = Color(0xFFF8F3E7);
  static const backgroundBottom = Color(0xFFF3ECDC);
  static const surfaceDeep = Color(0xFFFFFDF6);
  static const navBackground = Color(0xFAFFFDF6);
  static const navBorderFill = Color(0xFFFFFDF6);

  // Text (navy ink on the cream canvas)
  static const cream = Color(0xFF232B54);
  static Color get creamDim => cream.withValues(alpha: 0.62);
  static Color get creamFaint => cream.withValues(alpha: 0.48);
  static Color get creamGhost => cream.withValues(alpha: 0.34);

  // Cards
  static const cardFill = Color(0xFFFFFDF6);
  static Color get cardBorder => navy.withValues(alpha: 0.10);
  static Color get cardFillActive => orange.withValues(alpha: 0.10);
  static Color get cardBorderActive => orange.withValues(alpha: 0.50);

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
    colors: [orange, Color(0xFFD84315)],
  );
}
