import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_palette.dart';
import '../../core/i18n/strings.dart';
import '../../core/music/guitars.dart';
import '../../providers/app_providers.dart';
import '../../widgets/capi_deco.dart';
import '../../widgets/guitar_picker.dart';
import '../../widgets/primary_button.dart';

/// First-run screen in the Capi look: playful geometric backdrop, an
/// instrument picker, brand card, name input, and the START LEARNING CTA.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  GuitarKind _guitar = GuitarKind.acousticSteel;

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
            guitarKindId: _guitar.id,
          ),
        );
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Playful geometric backdrop.
          const Positioned.fill(child: CustomPaint(painter: _CapiShapes())),
          Positioned(
            top: topInset + 10,
            right: 26,
            child: GestureDetector(
              onTap: _finish,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  context.s.skip,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.creamDim,
                    decoration: TextDecoration.underline,
                    decorationColor: colors.creamDim,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              reverse: true,
              padding: EdgeInsets.fromLTRB(22, topInset + 46, 22, bottomInset + 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOutBack,
                      child: GuitarIllustration(
                        key: ValueKey(_guitar),
                        kind: _guitar,
                        width: 150,
                        height: 208,
                        blobColor: colors.yellow,
                        bodyColor: colors.pink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.s.chooseGuitar,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colors.creamDim,
                          )),
                      const SizedBox(width: 6),
                      Sparkle(color: colors.pinkStrong, size: 12),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 128,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: GuitarKind.values.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final kind = GuitarKind.values[i];
                        return GuitarKindChip(
                          kind: kind,
                          selected: kind == _guitar,
                          width: 90,
                          onTap: () => setState(() => _guitar = kind),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
                    decoration: BoxDecoration(
                      color: colors.cardFill,
                      border: Border.all(color: colors.cardBorder, width: 1.4),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: colors.cardShadow,
                          blurRadius: 26,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Sparkle(color: colors.orange, size: 14),
                            const SizedBox(width: 8),
                            Text(
                              'STRUMI',
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 2,
                                color: colors.orange,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.s.onboardTitle,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.22,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.s.onboardBody,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: colors.creamDim,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: context.s.whatsYourName,
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: colors.creamFaint,
                            ),
                            filled: true,
                            fillColor: colors.cream.withValues(alpha: 0.05),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: colors.cardBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: colors.cardBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: colors.orange, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(
                      label: context.s.startLearning, onTap: _finish),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scattered Capi shapes: navy quarter-circle, pink arch, orange ring,
/// green triangle — echoing the design's promo backdrop.
class _CapiShapes extends CustomPainter {
  const _CapiShapes();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint();

    // Navy quarter disc, top-left.
    paint.color = const Color(0xFF232B54);
    canvas.drawCircle(Offset(0, -h * 0.02), w * 0.30, paint);

    // Pink half-ring hugging the navy disc.
    paint
      ..color = const Color(0xFFF9C6DD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, -h * 0.02), radius: w * 0.40),
      -0.3,
      2.2,
      false,
      paint,
    );
    paint.style = PaintingStyle.fill;

    // Orange semicircle, top-right.
    paint.color = const Color(0xFFF0521F);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w, h * 0.10), radius: w * 0.14),
      1.5707,
      3.1415,
      true,
      paint,
    );

    // Sun-yellow dot, mid-right.
    paint.color = const Color(0xFFFFC72C);
    canvas.drawCircle(Offset(w * 0.94, h * 0.30), w * 0.05, paint);

    // Green triangle, bottom-left.
    paint.color = const Color(0xFF1FA05A);
    final tri = Path()
      ..moveTo(0, h)
      ..lineTo(w * 0.22, h)
      ..lineTo(0, h - w * 0.22)
      ..close();
    canvas.drawPath(tri, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
