import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/dates.dart';
import '../../data/catalogs/lessons_catalog.dart';
import '../../data/models/lesson.dart';
import '../../data/models/progress_state.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/screen_scaffold.dart';

const _monthsShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// Practice statistics: weekly bar chart, totals, and skill breakdown —
/// every number computed from the real practice log.
class PracticeStatsScreen extends ConsumerWidget {
  const PracticeStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);

    final weekStart = Dates.startOfWeek(DateTime.now());
    final weekMinutes = [
      for (var i = 0; i < 7; i++)
        progress.secondsOn(weekStart.add(Duration(days: i))) ~/ 60,
    ];
    final maxMinutes =
        weekMinutes.fold(0, math.max).clamp(1, 1 << 31);
    final today = DateTime.now();
    final todayIndex = today.weekday - DateTime.monday;

    final lastWeekStart = weekStart.subtract(const Duration(days: 7));
    var lastWeekMinutes = 0;
    for (var i = 0; i < 7; i++) {
      lastWeekMinutes +=
          progress.secondsOn(lastWeekStart.add(Duration(days: i))) ~/ 60;
    }
    final thisWeekMinutes = progress.minutesThisWeek;

    final rangeLabel =
        '${weekStart.day} ${_monthsShort[weekStart.month - 1]} – '
        '${weekStart.add(const Duration(days: 6)).day} '
        '${_monthsShort[weekStart.add(const Duration(days: 6)).month - 1]}';

    return ScreenScaffold(
      gap: 16,
      children: [
        const SubScreenHeader(title: 'Statistik Latihan'),

        // ------------------------------------------------ weekly chart
        GlassCard(
          radius: 24,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Minggu ini',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(rangeLabel,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.cream.withValues(alpha: 0.5))),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < 7; i++)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 26,
                            height: weekMinutes[i] == 0
                                ? 6
                                : (weekMinutes[i] / maxMinutes * 92)
                                    .clamp(6, 92)
                                    .toDouble(),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: weekMinutes[i] == 0
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : i == todayIndex
                                      ? AppColors.orange
                                      : AppColors.orange
                                          .withValues(alpha: 0.45),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            Dates.weekDayInitials[i],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: i == todayIndex
                                  ? AppColors.orangeLight
                                  : AppColors.creamFaint,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ------------------------------------------------ totals
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _TotalCard(
                  label: 'Total jam latihan',
                  value: '${progress.totalSeconds ~/ 3600}',
                  unit:
                      'j ${(progress.totalSeconds % 3600) ~/ 60}m',
                  delta: _weekDelta(thisWeekMinutes, lastWeekMinutes),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TotalCard(
                  label: 'Akurasi rata-rata',
                  value: '${progress.averageAccuracy}',
                  unit: '%',
                  delta: _accuracyDelta(progress.accuracyLog),
                ),
              ),
            ],
          ),
        ),

        // -------------------------------------------- category breakdown
        _CategoryBreakdownCard(progress: progress),

        // ------------------------------------------------ skill breakdown
        GlassCard(
          radius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Skill breakdown',
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              for (final skill in _skills(progress)) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 108,
                        child: Text(
                          skill.$1,
                          style: TextStyle(
                              fontSize: 12,
                              color:
                                  AppColors.cream.withValues(alpha: 0.65)),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: skill.$2 / 100,
                            minHeight: 7,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(skill.$3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${skill.$2}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  (String, Color) _weekDelta(int thisWeek, int lastWeek) {
    if (lastWeek == 0) {
      return thisWeek > 0
          ? ('Minggu aktif pertamamu — semangat!', AppColors.green)
          : ('Belum ada latihan minggu ini', AppColors.creamFaint);
    }
    final pct = ((thisWeek - lastWeek) / lastWeek * 100).round();
    return pct >= 0
        ? ('▲ $pct% dari minggu lalu', AppColors.green)
        : ('▼ ${pct.abs()}% dari minggu lalu', AppColors.red);
  }

  (String, Color) _accuracyDelta(List<double> log) {
    if (log.isEmpty) return ('Belum ada data AI', AppColors.creamFaint);
    if (log.length < 4) return ('Data awal terkumpul', AppColors.green);
    final half = log.length ~/ 2;
    final first = log.take(half).reduce((a, b) => a + b) / half;
    final second =
        log.skip(half).reduce((a, b) => a + b) / (log.length - half);
    final diff = (second - first).round();
    return diff >= 0
        ? ('▲ $diff poin — membaik', AppColors.green)
        : ('▼ ${diff.abs()} poin', AppColors.red);
  }

  List<(String, int, Color)> _skills(ProgressState progress) {
    final theoryLessons =
        kLessonCatalog.where((l) => l.kind == LessonKind.theory).toList();
    final theoryDone =
        theoryLessons.where((l) => progress.isLessonCompleted(l.id)).length;
    double meanProgress(List<String> ids) => ids.isEmpty
        ? 0
        : ids.map(progress.progressOf).reduce((a, b) => a + b) / ids.length;

    return [
      ('Chord changes', progress.averageAccuracy, AppColors.orange),
      (
        'Strumming',
        (meanProgress(['beg-03', 'int-04']) * 100).round(),
        AppColors.blue,
      ),
      (
        'Fingerpicking',
        (progress.progressOf('int-02') * 100).round(),
        AppColors.yellow,
      ),
      (
        'Teori musik',
        theoryLessons.isEmpty
            ? 0
            : (theoryDone / theoryLessons.length * 100).round(),
        AppColors.green,
      ),
      (
        'Ear training',
        ((progress.bestEarStreak / 12).clamp(0.0, 1.0) * 100).round(),
        AppColors.purple,
      ),
    ];
  }
}

/// Donut of total practice time split by activity category.
class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard({required this.progress});

  final ProgressState progress;

  static const _colors = {
    PracticeCategory.lesson: AppColors.orange,
    PracticeCategory.tuner: AppColors.blue,
    PracticeCategory.metronome: AppColors.yellow,
    PracticeCategory.chords: AppColors.green,
    PracticeCategory.songs: AppColors.red,
    PracticeCategory.earTraining: AppColors.purple,
    PracticeCategory.recorder: AppColors.orangeLight,
    PracticeCategory.challenge: AppColors.cream,
  };

  @override
  Widget build(BuildContext context) {
    // Total seconds per category, all time.
    final totals = <PracticeCategory, int>{};
    for (final day in progress.practiceSeconds.values) {
      for (final entry in day.entries) {
        final category = PracticeCategory.values
            .where((c) => c.name == entry.key)
            .firstOrNull;
        if (category == null) continue;
        totals[category] = (totals[category] ?? 0) + entry.value;
      }
    }
    final grandTotal = totals.values.fold(0, (a, b) => a + b);
    final ranked = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GlassCard(
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fokus latihanmu',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          if (grandTotal == 0)
            Text(
              'Belum ada data — mulai dari tuner atau lesson pertamamu.',
              style: TextStyle(fontSize: 12, color: AppColors.creamFaint),
            )
          else
            Row(
              children: [
                ProgressRing(
                  size: 96,
                  thickness: 13,
                  segments: [
                    for (final entry in ranked)
                      (
                        entry.value / grandTotal,
                        _colors[entry.key] ?? AppColors.cream,
                      ),
                  ],
                  center: Text(
                    '${grandTotal ~/ 60}m',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    children: [
                      for (final entry in ranked.take(4))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _colors[entry.key],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.key.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.cream
                                        .withValues(alpha: 0.65),
                                  ),
                                ),
                              ),
                              Text(
                                '${entry.value ~/ 60} mnt',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.delta,
  });

  final String label;
  final String value;
  final String unit;
  final (String, Color) delta;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.cream.withValues(alpha: 0.5))),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              text: value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              children: [
                TextSpan(
                  text: unit,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.cream.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            delta.$1,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: delta.$2,
            ),
          ),
        ],
      ),
    );
  }
}
