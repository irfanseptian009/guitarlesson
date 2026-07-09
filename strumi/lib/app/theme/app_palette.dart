import 'package:flutter/material.dart';

/// Theme-aware design tokens for the "Capi" playful-geometric design:
/// warm cream canvas, deep navy ink & cards, punchy orange / sun-yellow /
/// bubblegum-pink accents. [AppPalette.light] is the default look;
/// [AppPalette.dark] is its navy-night counterpart. Access via
/// `context.colors` (see the [AppPaletteX] extension below).
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
    required this.yellowDeep,
    required this.green,
    required this.red,
    required this.purple,
    required this.navy,
    required this.onNavy,
    required this.pink,
    required this.pinkStrong,
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
    required this.cardShadow,
  });

  final Brightness brightness;

  final Color orange;
  final Color orangeLight;
  final Color orangeGradientTop;
  final Color orangeGradientBottom;
  final Color onOrange;

  final Color blue;

  /// Sun-yellow fill (Switch pill, rings). Pair with [navy] text.
  final Color yellow;

  /// Darker gold for yellow *text/accents* sitting on the background.
  final Color yellowDeep;
  final Color green;
  final Color red;
  final Color purple;

  /// Deep indigo-navy: hero cards, active chips, headline ink.
  final Color navy;

  /// Warm cream text/icons on top of [navy].
  final Color onNavy;

  /// Soft bubblegum pink (active nav pill, deco shapes).
  final Color pink;

  /// Punchier pink for small accents & zigzag trims.
  final Color pinkStrong;

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
  final Color cardShadow;

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
        colors: [orange, const Color(0xFFD84315)],
      );

  static final light = AppPalette(
    brightness: Brightness.light,
    orange: const Color(0xFFF0521F),
    orangeLight: const Color(0xFFD8451A),
    orangeGradientTop: const Color(0xFFF96A32),
    orangeGradientBottom: const Color(0xFFE94614),
    onOrange: const Color(0xFFFFF8EF),
    blue: const Color(0xFF3554D1),
    yellow: const Color(0xFFFFC72C),
    yellowDeep: const Color(0xFFB8860B),
    green: const Color(0xFF1FA05A),
    red: const Color(0xFFDE3F2B),
    purple: const Color(0xFF7A4FD8),
    navy: const Color(0xFF232B54),
    onNavy: const Color(0xFFFAF5EA),
    pink: const Color(0xFFF9C6DD),
    pinkStrong: const Color(0xFFEF6FAC),
    backgroundTop: const Color(0xFFFDFBF4),
    backgroundMid: const Color(0xFFF8F3E7),
    backgroundBottom: const Color(0xFFF3ECDC),
    surfaceDeep: const Color(0xFFFFFDF6),
    navBackground: const Color(0xFAFFFDF6),
    navBorderFill: const Color(0xFFFFFDF6),
    cream: const Color(0xFF232B54),
    creamDim: const Color(0xFF232B54).withValues(alpha: 0.62),
    creamFaint: const Color(0xFF232B54).withValues(alpha: 0.48),
    creamGhost: const Color(0xFF232B54).withValues(alpha: 0.34),
    cardFill: const Color(0xFFFFFDF6),
    cardBorder: const Color(0xFF232B54).withValues(alpha: 0.10),
    cardFillActive: const Color(0xFFF0521F).withValues(alpha: 0.10),
    cardBorderActive: const Color(0xFFF0521F).withValues(alpha: 0.50),
    cardShadow: const Color(0xFF232B54).withValues(alpha: 0.07),
  );

  static final dark = AppPalette(
    brightness: Brightness.dark,
    orange: const Color(0xFFFF6B35),
    orangeLight: const Color(0xFFFF8A5C),
    orangeGradientTop: const Color(0xFFFF7A42),
    orangeGradientBottom: const Color(0xFFEE5220),
    onOrange: const Color(0xFFFFF8EF),
    blue: const Color(0xFF8FA8FF),
    yellow: const Color(0xFFFFD44D),
    yellowDeep: const Color(0xFFFFD44D),
    green: const Color(0xFF6FD59A),
    red: const Color(0xFFFF8577),
    purple: const Color(0xFFC0A8F8),
    navy: const Color(0xFF283163),
    onNavy: const Color(0xFFFAF5EA),
    pink: const Color(0xFFF4B8D3),
    pinkStrong: const Color(0xFFF58BBE),
    backgroundTop: const Color(0xFF1A2040),
    backgroundMid: const Color(0xFF131735),
    backgroundBottom: const Color(0xFF0D1026),
    surfaceDeep: const Color(0xFF1D2447),
    navBackground: const Color(0xF51A2144),
    navBorderFill: const Color(0xFF1A2144),
    cream: const Color(0xFFF2EEE3),
    creamDim: const Color(0xFFF2EEE3).withValues(alpha: 0.60),
    creamFaint: const Color(0xFFF2EEE3).withValues(alpha: 0.46),
    creamGhost: const Color(0xFFF2EEE3).withValues(alpha: 0.34),
    cardFill: Colors.white.withValues(alpha: 0.055),
    cardBorder: Colors.white.withValues(alpha: 0.10),
    cardFillActive: const Color(0xFFFF6B35).withValues(alpha: 0.16),
    cardBorderActive: const Color(0xFFFF6B35).withValues(alpha: 0.50),
    cardShadow: Colors.black.withValues(alpha: 0.22),
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
    Color? yellowDeep,
    Color? green,
    Color? red,
    Color? purple,
    Color? navy,
    Color? onNavy,
    Color? pink,
    Color? pinkStrong,
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
    Color? cardShadow,
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
      yellowDeep: yellowDeep ?? this.yellowDeep,
      green: green ?? this.green,
      red: red ?? this.red,
      purple: purple ?? this.purple,
      navy: navy ?? this.navy,
      onNavy: onNavy ?? this.onNavy,
      pink: pink ?? this.pink,
      pinkStrong: pinkStrong ?? this.pinkStrong,
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
      cardShadow: cardShadow ?? this.cardShadow,
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
      yellowDeep: c(yellowDeep, other.yellowDeep),
      green: c(green, other.green),
      red: c(red, other.red),
      purple: c(purple, other.purple),
      navy: c(navy, other.navy),
      onNavy: c(onNavy, other.onNavy),
      pink: c(pink, other.pink),
      pinkStrong: c(pinkStrong, other.pinkStrong),
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
      cardShadow: c(cardShadow, other.cardShadow),
    );
  }
}

/// Ergonomic `context.colors.orange` access to the active [AppPalette].
extension AppPaletteX on BuildContext {
  AppPalette get colors => Theme.of(this).extension<AppPalette>()!;
}
