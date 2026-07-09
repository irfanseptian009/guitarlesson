import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_palette.dart';
import '../../core/i18n/strings.dart';
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
                color: context.colors.surfaceDeep,
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
                    child: Icon(achievement.icon,
                        size: 30, color: achievement.color),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.s.achievementUnlocked,
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                      color: achievement.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement.nameFor(context.s.lang),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement.descriptionFor(context.s.lang),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: context.colors.creamDim),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: context.s.awesome,
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
      decoration: BoxDecoration(gradient: context.colors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            widget.shell,
            Positioned(
              left: 16,
              right: 16,
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

/// Capi-style floating nav: warm-cream rounded bar, the active tab morphs
/// into a soft-pink pill showing its label, and the orange tuner FAB sits
/// half above the bar (drawn in an unclipped [Stack] so it never gets cut
/// off).
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onSelect});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  static List<({String label, IconData icon, int index})> _items(S s) => [
        (label: s.navHome, icon: Icons.home_rounded, index: 0),
        (label: s.navLessons, icon: Icons.menu_book_rounded, index: 1),
        (label: s.navTools, icon: Icons.widgets_rounded, index: 3),
        (label: s.navProfile, icon: Icons.person_rounded, index: 4),
      ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = _items(context.s);
    // Everything (bar + raised FAB) lives inside this box, so nothing can
    // ever be clipped by a parent or lose its tap target.
    return SizedBox(
      height: 92,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 66,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: colors.navBackground,
                borderRadius: BorderRadius.circular(33),
                border: Border.all(
                  color: colors.cream.withValues(alpha: 0.10),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.navy.withValues(
                        alpha: colors.brightness == Brightness.dark
                            ? 0.55
                            : 0.18),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(child: _navItem(context, items[0])),
                  Expanded(child: _navItem(context, items[1])),
                  // Breathing room for the raised tuner FAB.
                  const SizedBox(width: 62),
                  Expanded(child: _navItem(context, items[2])),
                  Expanded(child: _navItem(context, items[3])),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: _TunerFab(
              active: currentIndex == 2,
              onTap: () => onSelect(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    ({String label, IconData icon, int index}) item,
  ) {
    final colors = context.colors;
    final active = currentIndex == item.index;
    return Semantics(
      label: item.label,
      selected: active,
      button: true,
      child: GestureDetector(
        onTap: () => onSelect(item.index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: active
                ? Container(
                    key: const ValueKey('pill'),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.pink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    // Scale down slightly if a label is ever too wide for
                    // its slot — never truncate to "Less…".
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.label,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF232B54),
                        ),
                      ),
                    ),
                  )
                : Icon(
                    item.icon,
                    key: const ValueKey('icon'),
                    size: 24,
                    color: colors.creamFaint,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Raised orange circle in the middle of the nav — jumps to the tuner.
class _TunerFab extends StatelessWidget {
  const _TunerFab({required this.onTap, this.active = false});

  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'Tuner',
      selected: active,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            gradient: colors.buttonGradient,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? colors.pink : colors.navBorderFill,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.orangeGradientBottom
                    .withValues(alpha: active ? 0.55 : 0.38),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(Icons.speed_rounded, size: 28, color: colors.onOrange),
        ),
      ),
    );
  }
}
