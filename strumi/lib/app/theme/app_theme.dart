import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Global [ThemeData] for Strumi (dark, Sora typeface).
abstract final class AppTheme {
  static ThemeData dark() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.orange,
        secondary: AppColors.blue,
        surface: AppColors.surfaceDeep,
        onPrimary: AppColors.onOrange,
        onSurface: AppColors.cream,
        error: AppColors.red,
      ),
      splashFactory: InkSparkle.splashFactory,
    );

    final textTheme = GoogleFonts.soraTextTheme(base.textTheme).apply(
      bodyColor: AppColors.cream,
      displayColor: AppColors.cream,
    );

    return base.copyWith(
      textTheme: textTheme,
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.orange,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.10),
        thumbColor: AppColors.cream,
        overlayColor: AppColors.orange.withValues(alpha: 0.15),
        trackHeight: 4,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceDeep,
        contentTextStyle: textTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        // Keep toasts clear of the floating bottom nav.
        insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 108),
      ),
      timePickerTheme: const TimePickerThemeData(
        backgroundColor: AppColors.surfaceDeep,
      ),
    );
  }

  static const systemUiOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.backgroundBottom,
    systemNavigationBarIconBrightness: Brightness.light,
  );
}
