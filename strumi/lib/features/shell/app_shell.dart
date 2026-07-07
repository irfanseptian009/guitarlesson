import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../data/catalogs/achievements_catalog.dart';
import '../../data/models/progress_state.dart';
import '../../providers/app_providers.dart';
import '../../widgets/celebration.dart';
import '../../widgets/primary_button.dart';

/// Shell around the five tab branches: gradient backdrop, the floating
/// pill navigation bar with the orange tuner FAB, and the global
/// achievement-unlock celebration.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _celebrating = false;

  @override
  void initState() {
    super.initState();
    // Catch achievements unlocked before this launch (e.g. data from an
    // older version) once the first frame is up.
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _checkAchievements(ref.read(progressProvider)));
  }

  void _goBranch(int index) {
    HapticFeedback.selectionClick();
    widget.shell.goBranch(
      index,
      initialLocation: index == widget.shell.currentIndex,
    );
  }

  void _checkAchievements(ProgressState progress) {
    if (_celebrating || !mounted) return;
    final fresh = [
      for (final a in kAchievements)
        if (a.isUnlocked(progress) && !progress.seenAchievements.contains(a.id))
          a,
    ];
    if (fresh.isEmpty) return;
    _celebrating = true;
    ref
        .read(progressProvider.notifier)
        .markAchievementsSeen([for (final a in fresh) a.id]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (final achievement in fresh) {
        if (!mounted) break;
        await _showUnlock(achievement);
      }
      _celebrating = false;
    });
  }

  Future<void> _showUnlock(Achievement achievement) async {
    Celebration.show(context);
    HapticFeedback.heavyImpact();
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'achievement',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (context, animation, secondary, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: curved, child: child),
        );
      },
      pageBuilder: (context, animation, secondary) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.fromLTRB(26, 30, 26, 24),
              decoration: BoxDecoration(
                color: AppColors.surfaceDeep,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: achievement.color.withValues(alpha: 0.45)),
                boxShadow: [
                  BoxShadow(
                    color: achievement.color.withValues(alpha: 0.25),
                    blurRadius: 60,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: achievement.color.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Transform.rotate(
                      angle: 0.785,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: achievement.color,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ACHIEVEMENT TERBUKA',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                      color: achievement.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.creamDim),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'MANTAP!',
                    height: 46,
                    fontSize: 13,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(progressProvider, (previous, next) => _checkAchievements(next));
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            widget.shell,
            Positioned(
              left: 20,
              right: 20,
              bottom: bottomInset + 16,
              child: _BottomNav(
                currentIndex: widget.shell.currentIndex,
                onSelect: _goBranch,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onSelect});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    Color tint(int index) =>
        currentIndex == index ? AppColors.orange : AppColors.creamFaint;

    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.navBackground,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x80000000),
                blurRadius: 34,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                label: 'Home',
                color: tint(0),
                onTap: () => onSelect(0),
                icon: (color) => Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    border: Border.all(color: color, width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              _NavItem(
                label: 'Lessons',
                color: tint(1),
                onTap: () => onSelect(1),
                icon: (color) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(color, 16),
                    const SizedBox(height: 3),
                    _bar(color, 16),
                    const SizedBox(height: 3),
                    _bar(color, 10),
                  ],
                ),
              ),
              _TunerFab(onTap: () => onSelect(2)),
              _NavItem(
                label: 'Tools',
                color: tint(3),
                onTap: () => onSelect(3),
                icon: (color) => SizedBox(
                  width: 15,
                  height: 15,
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (var i = 0; i < 4; i++)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _NavItem(
                label: 'Profil',
                color: tint(4),
                onTap: () => onSelect(4),
                icon: (color) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 13,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                          bottom: Radius.circular(1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _bar(Color color, double width) => Container(
        width: width,
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Widget Function(Color) icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 16, child: Center(child: icon(color))),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Raised orange circle in the middle of the nav — jumps to the tuner.
class _TunerFab extends StatelessWidget {
  const _TunerFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -22),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.buttonGradient,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.navBorderFill, width: 4),
            boxShadow: [
              BoxShadow(
                color: AppColors.orangeGradientBottom.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: SizedBox(
              width: 26,
              height: 26,
              child: CustomPaint(painter: _GaugeIconPainter()),
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.onOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width / 2 - 1.5, paint);
    // Needle tilted ~30° like the design glyph.
    canvas.drawLine(center, center.translate(4.5, -6.5), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
