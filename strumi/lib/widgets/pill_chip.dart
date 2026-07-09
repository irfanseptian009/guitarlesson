import 'package:flutter/material.dart';

import '../app/theme/app_palette.dart';
import 'pressable_scale.dart';

/// Selectable pill chip. Active = solid navy pill with warm-cream label
/// (the "Set up" pill treatment from the Capi design).
class PillChip extends StatelessWidget {
  const PillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.horizontalPadding = 15,
    this.fontSize = 12,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double horizontalPadding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      scale: 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding:
            EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? colors.navy : colors.cardFill,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? colors.navy : colors.cardBorder,
            width: 1.4,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: colors.navy.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: selected
                ? colors.onNavy
                : colors.cream.withValues(alpha: 0.72),
          ),
        ),
      ),
    );
  }
}
