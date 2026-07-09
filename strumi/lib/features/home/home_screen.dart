import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_palette.dart';
import '../../core/i18n/strings.dart';
import '../../core/music/chords.dart';
import '../../core/music/guitars.dart';
import '../../data/catalogs/challenges_catalog.dart';
import '../../data/catalogs/lessons_catalog.dart';
import '../../data/models/lesson.dart';
import '../../providers/app_providers.dart';
import '../../widgets/capi_deco.dart';
import '../../widgets/count_up_text.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/guitar_picker.dart';
import '../../widgets/pressable_scale.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/screen_scaffold.dart';

/// Home tab in the Capi look: hero guitar card with quick pills,
/// continue-lesson navy cards, weekly goal ring, quick stats, daily
/// challenge and quick tools — all backed by real progress data.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting(S s) {
    final hour = DateTime.now().hour;
    if (hour < 11) return s.goodMorning;
    if (hour < 15) return s.goodDay;
    if (hour < 19) return s.goodAfternoon;
    return s.goodEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final s = context.s;
    final settings = ref.watch(settingsProvider);
    final progress = ref.watch(progressProvider);
    final guitar = settings.guitarKind;

    final weeklyGoal = settings.weeklyGoalMinutes;
    final minutesWeek = progress.minutesThisWeek;
    final minutesToday = progress.secondsOn(DateTime.now()) ~/ 60;
    final earlierFraction =
        ((minutesWeek - minutesToday) / weeklyGoal).clamp(0.0, 1.0);
    final todayFraction = (minutesToday / weeklyGoal)
        .clamp(0.0, 1.0 - earlierFraction)
        .toDouble();
    final weekPct = (minutesWeek / weeklyGoal * 100).clamp(0, 100).round();

    final nextLessons = _nextLessons(progress.lessonProgress, 2, guitar);
    final challenge = challengeForToday();
    final firstName = settings.userName.trim().split(RegExp(r'\s+')).first;

    return ScreenScaffold(
      children: [
        // ------------------------------------------------ header
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_greeting(s),
                      style:
                          TextStyle(fontSize: 13, color: colors.creamDim)),
                  const SizedBox(height: 2),
                  Text(
                    'Hey, $firstName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            _StreakChip(days: progress.streakDays),
            const SizedBox(width: 10),
            _BellButton(
              hasReminder: settings.reminderEnabled,
              onTap: () => context.go('/profile'),
            ),
          ],
        ),

        // ------------------------------------------------ hero guitar card
        GlassCard(
          radius: 28,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 2,
                child: Sparkle(color: colors.pinkStrong, size: 18),
              ),
              Row(
                children: [
                  PressableScale(
                    onTap: () => showGuitarPicker(context, ref),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOutBack,
                          child: GuitarIllustration(
                            key: ValueKey(guitar),
                            kind: guitar,
                            width: 104,
                            height: 148,
                            blobColor: colors.yellow,
                            bodyColor: colors.pink,
                          ),
                        ),
                        // Little "tap to change" hint.
                        Positioned(
                          bottom: -2,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: colors.navy,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: colors.cardFill, width: 2),
                            ),
                            child: Icon(Icons.swap_horiz_rounded,
                                size: 13, color: colors.onNavy),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.yourGuitar,
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                            color: colors.creamFaint,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          guitar.label(s.lang),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 14),
                        _HeroPill(
                          label: s.tuner,
                          icon: Icons.speed_rounded,
                          background: colors.orange,
                          foreground: colors.onOrange,
                          onTap: () => context.go('/tuner'),
                        ),
                        const SizedBox(height: 8),
                        _HeroPill(
                          label: s.setUp,
                          icon: Icons.settings_rounded,
                          background: colors.navy,
                          foreground: colors.onNavy,
                          onTap: () => context.go('/profile'),
                        ),
                        const SizedBox(height: 8),
                        _HeroPill(
                          label: s.switchLabel,
                          icon: settings.isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          background: colors.yellow,
                          foreground: const Color(0xFF232B54),
                          onTap: () => ref
                              .read(settingsProvider.notifier)
                              .update((s) =>
                                  s.copyWith(isDarkMode: !s.isDarkMode)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ------------------------------------------------ continue lessons
        if (nextLessons.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.continueLessons,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800)),
              GestureDetector(
                onTap: () => context.go('/lessons'),
                child: Text(
                  s.seeAll,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.orangeLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < nextLessons.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: _LessonHeroCard(
                      lesson: nextLessons[i],
                      progress: progress.progressOf(nextLessons[i].id),
                      accent: i.isEven ? colors.pinkStrong : colors.yellow,
                    ),
                  ),
                ],
                if (nextLessons.length == 1) const Spacer(),
              ],
            ),
          ),
        ],

        // ------------------------------------------------ progress card
        GlassCard(
          padding: const EdgeInsets.all(22),
          onTap: () => context.push('/home/stats'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(s.progress,
                            style: const TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.navy,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Lv ${progress.level}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: colors.onNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      s.weekSummary(progress.sessionsThisWeek),
                      style:
                          TextStyle(fontSize: 13, color: colors.creamDim),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: colors.buttonGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        s.keepPracticing,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.onOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ProgressRing(
                segments: [
                  (earlierFraction, colors.orange),
                  (todayFraction, colors.yellow),
                ],
                trackColor: colors.cream.withValues(alpha: 0.08),
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CountUpText(
                      weekPct,
                      format: (v) => '${v.round()}%',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      s.weeklyGoal,
                      style: TextStyle(
                          fontSize: 10, color: colors.creamFaint),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ------------------------------------------------ quick stats
        Row(
          children: [
            _StatCard(
              label: s.statMinutes,
              labelColor: colors.orangeLight,
              value: minutesWeek,
              suffix: '/$weeklyGoal',
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: s.statChords,
              labelColor: colors.blue,
              value: progress.masteredChords.length,
              suffix: '/${kGuitarChords.length}',
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: s.statAccuracy,
              labelColor: colors.green,
              value: progress.averageAccuracy,
              suffix: '%',
            ),
          ],
        ),

        // ------------------------------------------------ daily challenge
        GlassCard(
          fill: colors.yellow,
          border: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Sparkle(color: colors.navy, size: 15),
                      const SizedBox(width: 8),
                      Text(s.dailyChallenge,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: colors.navy)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.navy,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${challenge.xp} XP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: colors.onNavy,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                s.challengeDesc(challenge.title, challenge.targetCycles),
                style: TextStyle(
                  fontSize: 13,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                  color: colors.navy.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 14),
              PressableScale(
                onTap: progress.challengeDoneToday
                    ? null
                    : () => context.push('/home/challenge'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: progress.challengeDoneToday
                        ? colors.navy.withValues(alpha: 0.12)
                        : colors.navy,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    progress.challengeDoneToday
                        ? s.doneToday
                        : s.startChallenge,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: progress.challengeDoneToday
                          ? colors.navy
                          : colors.onNavy,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ------------------------------------------------ quick tools
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(s.quickTools,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800)),
            GestureDetector(
              onTap: () => context.go('/tools'),
              child: Text(
                s.seeAll,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.orangeLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _QuickToolCard(
                title: s.tuner,
                subtitle: s.preciseTuning,
                icon: Icons.speed_rounded,
                color: colors.orange,
                onTap: () => context.go('/tuner'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickToolCard(
                title: 'Metronome',
                subtitle: s.plusDrumTracks,
                icon: Icons.av_timer_rounded,
                color: colors.blue,
                onTap: () => context.push('/tools/metronome'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Up to [count] lessons to continue: in-progress ones first, then the
  /// next untouched ones — instrument-specific lessons only when they
  /// match the selected guitar (those float to the front of untouched).
  List<Lesson> _nextLessons(
      Map<String, double> lessonProgress, int count, GuitarKind guitar) {
    final inProgress = <Lesson>[];
    final forGuitar = <Lesson>[];
    final generic = <Lesson>[];
    for (final lesson in kLessonCatalog) {
      if (lesson.guitar != null && lesson.guitar != guitar.id) continue;
      final p = lessonProgress[lesson.id] ?? 0;
      if (p > 0 && p < 1) {
        inProgress.add(lesson);
      } else if (p == 0) {
        (lesson.guitar != null ? forGuitar : generic).add(lesson);
      }
    }
    return [...inProgress, ...forGuitar, ...generic].take(count).toList();
  }
}

/// Navy "continue where you left off" card with a progress ring and the
/// design's zigzag trim along the bottom edge.
class _LessonHeroCard extends StatelessWidget {
  const _LessonHeroCard({
    required this.lesson,
    required this.progress,
    required this.accent,
  });

  final Lesson lesson;
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: () => context.push('/lessons/${lesson.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: colors.navy,
          child: Stack(
            children: [
              Positioned(
                top: -16,
                right: -16,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.track.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                              color: colors.onNavy.withValues(alpha: 0.55),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lesson.titleFor(context.s.lang),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.3,
                              fontWeight: FontWeight.w800,
                              color: colors.onNavy,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ProgressRing(
                                size: 52,
                                thickness: 6,
                                segments: [(progress, colors.yellow)],
                                trackColor:
                                    colors.onNavy.withValues(alpha: 0.16),
                                holeColor: colors.navy,
                                center: Text(
                                  '${(progress * 100).round()}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: colors.onNavy,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_forward_rounded,
                                  color: colors.onNavy, size: 22),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ZigzagTrim(color: accent, height: 9, toothWidth: 13),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scale: 0.95,
      child: Container(
        width: double.infinity,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: foreground,
              ),
            ),
            Icon(icon, size: 16, color: foreground),
          ],
        ),
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final active = days > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: active
            ? colors.orange.withValues(alpha: 0.13)
            : colors.cream.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active
              ? colors.orange.withValues(alpha: 0.4)
              : colors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 15,
            color: active ? colors.orange : colors.creamFaint,
          ),
          const SizedBox(width: 4),
          Text(
            '$days',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: active ? colors.orangeLight : colors.creamFaint,
            ),
          ),
        ],
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.hasReminder, required this.onTap});

  final bool hasReminder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colors.cardFill,
          shape: BoxShape.circle,
          border: Border.all(color: colors.cardBorder, width: 1.4),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 20, color: colors.cream),
            if (hasReminder)
              Positioned(
                top: 9,
                right: 11,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.cardFill, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.labelColor,
    required this.value,
    required this.suffix,
  });

  final String label;
  final Color labelColor;
  final num value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        radius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: labelColor,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                CountUpText(
                  value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800),
                ),
                Flexible(
                  child: Text(
                    suffix,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.colors.creamFaint,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickToolCard extends StatelessWidget {
  const _QuickToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 20,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 21, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800)),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontSize: 11, color: colors.creamFaint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
