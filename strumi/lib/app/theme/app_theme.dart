import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_palette.dart';

/// Global [ThemeData] for Strumi — light and dark, both using the locally
/// bundled Sora typeface (no runtime font fetch).
abstract final class AppTheme {
  static ThemeData light() => _build(AppPalette.light);

  static ThemeData dark() => _build(AppPalette.dark);

  static ThemeData _build(AppPalette palette) {
    final base = ThemeData(
      brightness: palette.brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: ColorScheme(
        brightness: palette.brightness,
        primary: palette.orange,
        onPrimary: palette.onOrange,
        secondary: palette.blue,
        onSecondary: palette.onOrange,
        error: palette.red,
        onError: palette.onOrange,
        surface: palette.surfaceDeep,
        onSurface: palette.cream,
      ),
      splashFactory: InkSparkle.splashFactory,
      extensions: [palette],
    );

    final textTheme = base.textTheme.apply(
      fontFamily: 'Sora',
      bodyColor: palette.cream,
      displayColor: palette.cream,
    );

    return base.copyWith(
      textTheme: textTheme,
      sliderTheme: SliderThemeData(
        activeTrackColor: palette.orange,
        inactiveTrackColor: palette.cream.withValues(alpha: 0.10),
        thumbColor: palette.cream,
        overlayColor: palette.orange.withValues(alpha: 0.15),
        trackHeight: 4,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surfaceDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceDeep,
        contentTextStyle: textTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        // Keep toasts clear of the floating bottom nav.
        insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 108),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: palette.surfaceDeep,
      ),
    );
  }

  static SystemUiOverlayStyle systemUiOverlay(Brightness brightness) {
    final iconBrightness =
        brightness == Brightness.dark ? Brightness.light : Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: iconBrightness,
      statusBarBrightness: brightness,
      systemNavigationBarColor: brightness == Brightness.dark
          ? const Color(0xFF0D1026)
          : const Color(0xFFF3ECDC),
      systemNavigationBarIconBrightness: iconBrightness,
    );
  }
}
