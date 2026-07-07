import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/primary_button.dart';

/// First-run screen: hero artwork, brand card, name input, and the
/// MULAI BELAJAR call to action.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _finish() {
    final name = _nameController.text.trim();
    ref.read(settingsProvider.notifier).update(
          (s) => s.copyWith(
            onboardingDone: true,
            userName: name.isEmpty ? s.userName : name,
          ),
        );
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Hero artwork (stylized guitar strings — replaces the design's
          // photo placeholder).
          const CustomPaint(painter: _GuitarArtPainter()),
          // Bottom scrim, as in the design.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.3, 0.78],
                colors: [
                  const Color(0xFF0A0D12).withValues(alpha: 0.15),
                  const Color(0xFF0A0D12).withValues(alpha: 0.92),
                ],
              ),
            ),
          ),
          Positioned(
            top: topInset + 10,
            right: 26,
            child: GestureDetector(
              onTap: _finish,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.cream.withValues(alpha: 0.75),
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.cream.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              reverse: true,
              padding: EdgeInsets.fromLTRB(22, 0, 22, bottomInset + 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C232D).withValues(alpha: 0.55),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10)),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'STRUMI',
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 2,
                                color: AppColors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Dari chord pertama sampai solo di panggung',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            height: 1.22,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Learning path adaptif, tuner & metronome presisi, '
                          'plus AI yang mendengar permainanmu dan memberi '
                          'feedback real-time.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.cream.withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'Siapa namamu?',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.cream.withValues(alpha: 0.4),
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.06),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.12)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.12)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: AppColors.orange, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(label: 'MULAI BELAJAR', onTap: _finish),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Abstract acoustic-guitar artwork: glowing strings, sound-hole arc and
/// bokeh dots on the dark gradient.
class _GuitarArtPainter extends CustomPainter {
  const _GuitarArtPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A222E), Color(0xFF10151D), Color(0xFF0A0D12)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    // Sound hole: large glowing arc off to the right.
    final holeCenter = Offset(size.width * 0.82, size.height * 0.34);
    canvas.drawCircle(
      holeCenter,
      size.width * 0.55,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 42
        ..color = const Color(0xFF04060A).withValues(alpha: 0.65),
    );
    canvas.drawCircle(
      holeCenter,
      size.width * 0.55,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = AppColors.orange.withValues(alpha: 0.35),
    );
    canvas.drawCircle(
      holeCenter,
      size.width * 0.47,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppColors.yellow.withValues(alpha: 0.25),
    );

    // Six strings sweeping diagonally, brighter towards the treble side.
    for (var i = 0; i < 6; i++) {
      final t = i / 5;
      final paint = Paint()
        ..strokeWidth = 3.2 - t * 1.9
        ..strokeCap = StrokeCap.round
        ..color = Color.lerp(
          AppColors.cream.withValues(alpha: 0.12),
          AppColors.orangeLight.withValues(alpha: 0.55),
          t,
        )!;
      final x = size.width * (0.08 + t * 0.13);
      final path = Path()
        ..moveTo(x, -20)
        ..quadraticBezierTo(
          x + size.width * 0.18,
          size.height * 0.5,
          x + size.width * 0.05,
          size.height + 20,
        );
      canvas.drawPath(path, paint);
    }

    // Bokeh accents.
    final random = math.Random(11);
    for (var i = 0; i < 14; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height * 0.6;
      final radius = 1.5 + random.nextDouble() * 3.5;
      canvas.drawCircle(
        Offset(dx, dy),
        radius,
        Paint()
          ..color = (i.isEven ? AppColors.orange : AppColors.blue)
              .withValues(alpha: 0.10 + random.nextDouble() * 0.12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
