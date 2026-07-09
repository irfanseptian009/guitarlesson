import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-screen confetti burst rendered in the root overlay.
/// Fire-and-forget: `Celebration.show(context)`.
abstract final class Celebration {
  static void show(BuildContext context) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    HapticFeedback.mediumImpact();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ConfettiLayer(onDone: () => entry.remove()),
    );
    overlay.insert(entry);
  }
}

class _ConfettiLayer extends StatefulWidget {
  const _ConfettiLayer({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_ConfettiLayer> createState() => _ConfettiLayerState();
}

class _Particle {
  _Particle(math.Random random)
      : x = random.nextDouble(),
        velocityX = (random.nextDouble() - 0.5) * 0.9,
        velocityY = -(0.8 + random.nextDouble() * 1.4),
        size = 4 + random.nextDouble() * 6,
        spin = (random.nextDouble() - 0.5) * 14,
        color = _palette[random.nextInt(_palette.length)],
        isCircle = random.nextBool();

  // Fixed Capi party colors — bright enough on both themes.
  static const _palette = [
    Color(0xFFF0521F), // orange
    Color(0xFFFFC72C), // sun yellow
    Color(0xFFEF6FAC), // pink
    Color(0xFF3554D1), // royal blue
    Color(0xFF1FA05A), // green
    Color(0xFF7A4FD8), // purple
  ];

  final double x;
  final double velocityX;
  final double velocityY;
  final double size;
  final double spin;
  final Color color;
  final bool isCircle;
}

class _ConfettiLayerState extends State<_ConfettiLayer>
    with SingleTickerProviderStateMixin {
  static const _count = 42;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _particles = List.generate(_count, (_) => _Particle(random));
    _controller.forward().whenCompleteOrCancel(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: MediaQuery.sizeOf(context),
          painter: _ConfettiPainter(_particles, _controller.value),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.t);

  final List<_Particle> particles;

  /// Animation progress 0..1.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final fade = (1 - t).clamp(0.0, 1.0);
    for (final p in particles) {
      // Launch from the bottom center-ish, arc under gravity.
      final x = size.width * (0.5 + (p.x - 0.5) * 0.7) +
          p.velocityX * size.width * t;
      final y = size.height * 0.78 +
          (p.velocityY * t + 1.6 * t * t) * size.height * 0.55;
      if (y > size.height + 20) continue;
      paint.color = p.color.withValues(alpha: 0.9 * fade);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * t);
      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero, width: p.size, height: p.size * 0.62),
            const Radius.circular(1.5),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.t != t;
}
