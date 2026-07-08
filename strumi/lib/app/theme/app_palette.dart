import 'package:flutter/material.dart';

/// Theme-aware design tokens. [AppPalette.dark] is the original GuitarMaster
/// dark design; [AppPalette.light] is its light counterpart. Access via
/// `context.colors` (see the [AppPaletteX] extension below) instead of the
/// legacy static [AppColors] constants where a screen has been migrated.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.orange,
    required this.orangeLight,
    required this.orangeGradientTop,
    required this.orangeGradientBottom,
    required this.onOrange,
    required this.blue,
    required this.yellow,
    required this.green,
    required this.red,
    required this.purple,
    required this.backgroundTop,
    required this.backgroundMid,
    required this.backgroundBottom,
    required this.surfaceDeep,
    required this.navBackground,
    required this.navBorderFill,
    required this.cream,
    required this.creamDim,
    required this.creamFaint,
    required this.creamGhost,
    required this.cardFill,
    required this.cardBorder,
    required this.cardFillActive,
    required this.cardBorderActive,
  });

  final Brightness brightness;

  final Color orange;
  final Color orangeLight;
  final Color orangeGradientTop;
  final Color orangeGradientBottom;
  final Color onOrange;

  final Color blue;
  final Color yellow;
  final Color green;
  final Color red;
  final Color purple;

  final Color backgroundTop;
  final Color backgroundMid;
  final Color backgroundBottom;
  final Color surfaceDeep;
  final Color navBackground;
  final Color navBorderFill;

  final Color cream;
  final Color creamDim;
  final Color creamFaint;
  final Color creamGhost;

  final Color cardFill;
  final Color cardBorder;
  final Color cardFillActive;
  final Color cardBorderActive;

  Gradient get buttonGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [orangeGradientTop, orangeGradientBottom],
      );

  Gradient get backgroundGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [backgroundTop, backgroundMid, backgroundBottom],
        stops: const [0.0, 0.55, 1.0],
      );

  Gradient get avatarGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [orange, const Color(0xFFC24E12)],
      );

  static final dark = AppPalette(
    brightness: Brightness.dark,
    orange: const Color(0xFFF9772E),
    orangeLight: const Color(0xFFF9A05C),
    orangeGradientTop: const Color(0xFFFB8A45),
    orangeGradientBottom: const Color(0xFFF0661A),
    onOrange: const Color(0xFF14100B),
    blue: const Color(0xFFA8C7E8),
    yellow: const Color(0xFFE8D48A),
    green: const Color(0xFF8CC88C),
    red: const Color(0xFFE8908A),
    purple: const Color(0xFFC9A8E8),
    backgroundTop: const Color(0xFF141B26),
    backgroundMid: const Color(0xFF0B0F15),
    backgroundBottom: const Color(0xFF0A0D12),
    surfaceDeep: const Color(0xFF131A24),
    navBackground: const Color(0xEB10151C),
    navBorderFill: const Color(0xFF10151C),
    cream: const Color(0xFFF2EEE6),
    creamDim: const Color(0xFFF2EEE6).withValues(alpha: 0.55),
    creamFaint: const Color(0xFFF2EEE6).withValues(alpha: 0.45),
    creamGhost: const Color(0xFFF2EEE6).withValues(alpha: 0.35),
    cardFill: Colors.white.withValues(alpha: 0.05),
    cardBorder: Colors.white.withValues(alpha: 0.09),
    cardFillActive: const Color(0xFFF9772E).withValues(alpha: 0.16),
    cardBorderActive: const Color(0xFFF9772E).withValues(alpha: 0.5),
  );

  static final light = AppPalette(
    brightness: Brightness.light,
    orange: const Color(0xFFF9772E),
    orangeLight: const Color(0xFFC85A17),
    orangeGradientTop: const Color(0xFFFB8A45),
    orangeGradientBottom: const Color(0xFFF0661A),
    onOrange: const Color(0xFF14100B),
    blue: const Color(0xFF3169A0),
    yellow: const Color(0xFF9C6B00),
    green: const Color(0xFF3F8F49),
    red: const Color(0xFFC8483C),
    purple: const Color(0xFF7C4FBE),
    backgroundTop: const Color(0xFFFFFFFF),
    backgroundMid: const Color(0xFFFBF3EC),
    backgroundBottom: const Color(0xFFF5E9DC),
    surfaceDeep: const Color(0xFFFFFFFF),
    navBackground: const Color(0xEBFFFFFF),
    navBorderFill: const Color(0xFFFFFFFF),
    cream: const Color(0xFF211A12),
    creamDim: const Color(0xFF211A12).withValues(alpha: 0.6),
    creamFaint: const Color(0xFF211A12).withValues(alpha: 0.48),
    creamGhost: const Color(0xFF211A12).withValues(alpha: 0.35),
    cardFill: Colors.black.withValues(alpha: 0.035),
    cardBorder: Colors.black.withValues(alpha: 0.08),
    cardFillActive: const Color(0xFFF9772E).withValues(alpha: 0.12),
    cardBorderActive: const Color(0xFFF9772E).withValues(alpha: 0.45),
  );

  @override
  AppPalette copyWith({
    Brightness? brightness,
    Color? orange,
    Color? orangeLight,
    Color? orangeGradientTop,
    Color? orangeGradientBottom,
    Color? onOrange,
    Color? blue,
    Color? yellow,
    Color? green,
    Color? red,
    Color? purple,
    Color? backgroundTop,
    Color? backgroundMid,
    Color? backgroundBottom,
    Color? surfaceDeep,
    Color? navBackground,
    Color? navBorderFill,
    Color? cream,
    Color? creamDim,
    Color? creamFaint,
    Color? creamGhost,
    Color? cardFill,
    Color? cardBorder,
    Color? cardFillActive,
    Color? cardBorderActive,
  }) {
    return AppPalette(
      brightness: brightness ?? this.brightness,
      orange: orange ?? this.orange,
      orangeLight: orangeLight ?? this.orangeLight,
      orangeGradientTop: orangeGradientTop ?? this.orangeGradientTop,
      orangeGradientBottom: orangeGradientBottom ?? this.orangeGradientBottom,
      onOrange: onOrange ?? this.onOrange,
      blue: blue ?? this.blue,
      yellow: yellow ?? this.yellow,
      green: green ?? this.green,
      red: red ?? this.red,
      purple: purple ?? this.purple,
      backgroundTop: backgroundTop ?? this.backgroundTop,
      backgroundMid: backgroundMid ?? this.backgroundMid,
      backgroundBottom: backgroundBottom ?? this.backgroundBottom,
      surfaceDeep: surfaceDeep ?? this.surfaceDeep,
      navBackground: navBackground ?? this.navBackground,
      navBorderFill: navBorderFill ?? this.navBorderFill,
      cream: cream ?? this.cream,
      creamDim: creamDim ?? this.creamDim,
      creamFaint: creamFaint ?? this.creamFaint,
      creamGhost: creamGhost ?? this.creamGhost,
      cardFill: cardFill ?? this.cardFill,
      cardBorder: cardBorder ?? this.cardBorder,
      cardFillActive: cardFillActive ?? this.cardFillActive,
      cardBorderActive: cardBorderActive ?? this.cardBorderActive,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      orange: c(orange, other.orange),
      orangeLight: c(orangeLight, other.orangeLight),
      orangeGradientTop: c(orangeGradientTop, other.orangeGradientTop),
      orangeGradientBottom:
          c(orangeGradientBottom, other.orangeGradientBottom),
      onOrange: c(onOrange, other.onOrange),
      blue: c(blue, other.blue),
      yellow: c(yellow, other.yellow),
      green: c(green, other.green),
      red: c(red, other.red),
      purple: c(purple, other.purple),
      backgroundTop: c(backgroundTop, other.backgroundTop),
      backgroundMid: c(backgroundMid, other.backgroundMid),
      backgroundBottom: c(backgroundBottom, other.backgroundBottom),
      surfaceDeep: c(surfaceDeep, other.surfaceDeep),
      navBackground: c(navBackground, other.navBackground),
      navBorderFill: c(navBorderFill, other.navBorderFill),
      cream: c(cream, other.cream),
      creamDim: c(creamDim, other.creamDim),
      creamFaint: c(creamFaint, other.creamFaint),
      creamGhost: c(creamGhost, other.creamGhost),
      cardFill: c(cardFill, other.cardFill),
      cardBorder: c(cardBorder, other.cardBorder),
      cardFillActive: c(cardFillActive, other.cardFillActive),
      cardBorderActive: c(cardBorderActive, other.cardBorderActive),
    );
  }
}

/// Ergonomic `context.colors.orange` access to the active [AppPalette].
extension AppPaletteX on BuildContext {
  AppPalette get colors => Theme.of(this).extension<AppPalette>()!;
}
