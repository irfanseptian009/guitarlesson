import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/music/chords.dart';
import '../../data/catalogs/challenges_catalog.dart';
import '../../data/catalogs/lessons_catalog.dart';
import '../../data/models/lesson.dart';
import '../../providers/app_providers.dart';
import '../../widgets/count_up_text.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/screen_scaffold.dart';

/// Home tab: greeting, weekly goal ring, quick stats, continue-lesson card,
/// daily challenge, and quick tools — all backed by real progress data.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 19) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final progress = ref.watch(progressProvider);

    final weeklyGoal = settings.weeklyGoalMinutes;
    final minutesWeek = progress.minutesThisWeek;
    final minutesToday = progress.secondsOn(DateTime.now()) ~/ 60;
    final earlierFraction =
        ((minutesWeek - minutesToday) / weeklyGoal).clamp(0.0, 1.0);
    final todayFraction = (minutesToday / weeklyGoal)
        .clamp(0.0, 1.0 - earlierFraction)
        .toDouble();
    final weekPct = (minutesWeek / weeklyGoal * 100).clamp(0, 100).round();

    final nextLesson = _nextLesson(progress.lessonProgress);
    final challenge = challengeForToday();

    return ScreenScaffold(
      children: [
        // ------------------------------------------------ header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    gradient: AppColors.avatarGradient,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    settings.initials,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onOrange,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.creamDim)),
                    const SizedBox(height: 2),
                    Text(
                      settings.userName,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: AppColors.orange.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  _PulseDot(active: progress.streakDays > 0),
                  const SizedBox(width: 6),
                  Text(
                    '${progress.streakDays} hari streak',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.orangeLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const Text('Latihanmu hari ini',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),

        // ------------------------------------------------ progress card
        GlassCard(
          padding: const EdgeInsets.all(22),
          onTap: () => context.push('/home/stats'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Progress',
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text(
                    'Minggu ini · ${progress.sessionsThisWeek} dari 7 hari',
                    style: TextStyle(fontSize: 13, color: AppColors.creamDim),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Lanjut latihan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onOrange,
                      ),
                    ),
                  ),
                ],
              ),
              ProgressRing(
                segments: [
                  (earlierFraction, AppColors.orange),
                  (todayFraction, AppColors.blue),
                ],
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
                      'goal mingguan',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.cream.withValues(alpha: 0.5)),
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
              label: 'Menit latihan',
              labelColor: AppColors.orangeLight,
              value: minutesWeek,
              suffix: '/$weeklyGoal',
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: 'Chord dikuasai',
              labelColor: AppColors.blue,
              value: progress.masteredChords.length,
              suffix: '/${kChordCatalog.length}',
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: 'Akurasi AI',
              labelColor: AppColors.yellow,
              value: progress.averageAccuracy,
              suffix: '%',
            ),
          ],
        ),

        // ------------------------------------------------ continue lesson
        if (nextLesson != null)
          GlassCard(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.blue.withValues(alpha: 0.14),
                Colors.white.withValues(alpha: 0.04),
              ],
            ),
            border: AppColors.blue.withValues(alpha: 0.25),
            onTap: () => context.push('/lessons/${nextLesson.id}'),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: AppColors.blue, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LANJUTKAN LESSON',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(nextLesson.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress.progressOf(nextLesson.id),
                          minHeight: 5,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.10),
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(progress.progressOf(nextLesson.id) * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
          ),

        // ------------------------------------------------ daily challenge
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Transform.rotate(
                        angle: 0.785,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.yellow,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Daily Challenge',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Text(
                    '+${challenge.xp} XP',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.yellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                challenge.description,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.55,
                  color: AppColors.cream.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: progress.challengeDoneToday
                    ? null
                    : () => context.push('/home/challenge'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: progress.challengeDoneToday
                          ? AppColors.green.withValues(alpha: 0.45)
                          : AppColors.yellow.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    progress.challengeDoneToday
                        ? 'Selesai hari ini ✓'
                        : 'Mulai challenge',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: progress.challengeDoneToday
                          ? AppColors.green
                          : AppColors.yellow,
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
            const Text('Tools cepat',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            GestureDetector(
              onTap: () => context.go('/tools'),
              child: const Text(
                'Lihat semua',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.orangeLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _QuickToolCard(
                title: 'Tuner',
                subtitle: 'Setem presisi',
                icon: const _TunerGlyph(),
                onTap: () => context.go('/tuner'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickToolCard(
                title: 'Metronome',
                subtitle: '+ drum tracks',
                icon: const _MetronomeGlyph(),
                onTap: () => context.push('/tools/metronome'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// First in-progress lesson, else the first not-yet-completed one.
  Lesson? _nextLesson(Map<String, double> lessonProgress) {
    Lesson? firstIncomplete;
    for (final lesson in kLessonCatalog) {
      final p = lessonProgress[lesson.id] ?? 0;
      if (p > 0 && p < 1) return lesson;
      if (p < 1) firstIncomplete ??= lesson;
    }
    return firstIncomplete;
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
                    fontWeight: FontWeight.w600)),
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
                      fontWeight: FontWeight.w500,
                      color: AppColors.cream.withValues(alpha: 0.5),
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

/// Streak indicator dot: glows and pulses while a streak is alive.
class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.active});

  final bool active;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.6,
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PulseDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.active) {
      _controller.stop();
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.orange,
          shape: BoxShape.circle,
          boxShadow: widget.active
              ? [
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha: 0.7),
                    blurRadius: 8,
                  ),
                ]
              : null,
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
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 20,
      onTap: onTap,
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              Text(
                subtitle,
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.cream.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Mini tuner gauge glyph (orange ring + tilted needle), as in the design.
class _TunerGlyph extends StatelessWidget {
  const _TunerGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.orange, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.49,
            child: Transform.translate(
              offset: const Offset(0, -5),
              child: Container(
                width: 2,
                height: 13,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                  color: AppColors.orange, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini metronome glyph (blue rounded square + 3 bars), as in the design.
class _MetronomeGlyph extends StatelessWidget {
  const _MetronomeGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      padding: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final h in [9.0, 15.0, 6.0]) ...[
            Container(
              width: 4,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
