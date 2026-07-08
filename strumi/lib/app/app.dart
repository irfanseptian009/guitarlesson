import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import 'router.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme.dart';

class StrumiApp extends ConsumerWidget {
  const StrumiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isDark = ref.watch(settingsProvider.select((s) => s.isDarkMode));
    final palette = isDark ? AppPalette.dark : AppPalette.light;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.systemUiOverlay(palette.brightness),
      child: MaterialApp.router(
        title: 'Strumi',
        debugShowCheckedModeBanner: false,
        theme: isDark ? AppTheme.dark() : AppTheme.light(),
        routerConfig: router,
        builder: (context, child) => DecoratedBox(
          decoration: BoxDecoration(gradient: palette.backgroundGradient),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
