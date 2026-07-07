import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import 'pressable_scale.dart';

/// Translucent card used across every Strumi screen
/// (`rgba(255,255,255,0.05)` fill + hairline border in the design).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.fill,
    this.border,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? fill;
  final Color? border;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (fill ?? AppColors.cardFill) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border ?? AppColors.cardBorder),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return PressableScale(onTap: onTap, child: card);
  }
}
