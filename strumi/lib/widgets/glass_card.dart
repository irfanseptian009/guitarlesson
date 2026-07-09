import 'package:flutter/material.dart';

import '../app/theme/app_palette.dart';
import 'pressable_scale.dart';

/// Standard card used across every Strumi screen. In the light "Capi"
/// theme it renders as a warm-white card with a soft navy shadow; in the
/// dark theme it falls back to a translucent glass panel.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.fill,
    this.border,
    this.gradient,
    this.shadow = true,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? fill;
  final Color? border;
  final Gradient? gradient;

  /// Set false for nested cards that shouldn't cast their own shadow.
  final bool shadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (fill ?? colors.cardFill) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border ?? colors.cardBorder, width: 1.4),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return PressableScale(onTap: onTap, child: card);
  }
}
