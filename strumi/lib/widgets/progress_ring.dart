import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';

/// Conic-gradient progress ring (Home screen weekly-goal card).
///
/// [segments] are fractions (0..1) painted clockwise from the top in order;
/// the remainder is painted with [trackColor].
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.segments,
    this.size = 112,
    this.thickness = 15,
    this.trackColor,
    required this.center,
  });

  final List<(double, Color)> segments;
  final double size;
  final double thickness;
  final Color? trackColor;
  final Widget center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          segments: segments,
          thickness: thickness,
          trackColor: trackColor ?? Colors.white.withValues(alpha: 0.10),
        ),
        child: Center(
          child: Container(
            width: size - thickness * 2,
            height: size - thickness * 2,
            decoration: const BoxDecoration(
              color: AppColors.surfaceDeep,
              shape: BoxShape.circle,
            ),
            child: Center(child: center),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.segments,
    required this.thickness,
    required this.trackColor,
  });

  final List<(double, Color)> segments;
  final double thickness;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..style = PaintingStyle.fill;

    var start = -math.pi / 2;
    var total = 0.0;
    for (final (fraction, color) in segments) {
      final sweep = fraction.clamp(0.0, 1.0 - total) * 2 * math.pi;
      paint.color = color;
      canvas.drawArc(rect, start, sweep, true, paint);
      start += sweep;
      total += fraction;
    }
    if (total < 1.0) {
      paint.color = trackColor;
      canvas.drawArc(rect, start, (1.0 - total) * 2 * math.pi, true, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.segments != segments;
}
