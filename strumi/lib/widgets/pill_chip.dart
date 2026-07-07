import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import 'pressable_scale.dart';

/// Selectable pill chip with the design's orange active treatment.
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
    return PressableScale(
      onTap: onTap,
      scale: 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.cardFillActive : AppColors.cardFill,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? AppColors.cardBorderActive : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: selected
                ? AppColors.orangeLight
                : AppColors.cream.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
