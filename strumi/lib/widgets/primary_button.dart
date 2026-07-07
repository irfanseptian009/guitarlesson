import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import 'pressable_scale.dart';

/// Orange gradient pill button (the design's `MULAI BELAJAR` CTA).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 58,
    this.fontSize = 16,
    this.expanded = true,
  });

  final String label;
  final VoidCallback onTap;
  final double height;
  final double fontSize;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = PressableScale(
      onTap: onTap,
      scale: 0.96,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: expanded ? 0 : 26),
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.orangeGradientBottom.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: AppColors.onOrange,
          ),
        ),
      ),
    );
    return button;
  }
}
