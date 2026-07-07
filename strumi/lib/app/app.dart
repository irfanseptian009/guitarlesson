import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class StrumiApp extends ConsumerWidget {
  const StrumiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.systemUiOverlay,
      child: MaterialApp.router(
        title: 'Strumi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        routerConfig: router,
        builder: (context, child) => DecoratedBox(
          decoration:
              const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
