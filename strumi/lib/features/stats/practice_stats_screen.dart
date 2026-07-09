import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_palette.dart';
import '../../core/i18n/strings.dart';
import '../../core/utils/dates.dart';
import '../../data/catalogs/lessons_catalog.dart';
import '../../data/models/lesson.dart';
import '../../data/models/progress_state.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/screen_scaffold.dart';

/// Practice statistics: weekly bar chart, totals, and skill breakdown —
/// every number computed from the real practice log.
class PracticeStatsScreen extends ConsumerWidget {
  const PracticeStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
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

    final months = s.monthsShort;
    final rangeLabel =
        '${weekStart.day} ${months[weekStart.month - 1]} – '
        '${weekStart.add(const Duration(days: 6)).day} '
        '${months[weekStart.add(const Duration(days: 6)).month - 1]}';

    return ScreenScaffold(
      gap: 16,
      children: [
        SubScreenHeader(title: s.practiceStats),

        // ------------------------------------------------ weekly chart
        GlassCard(
          radius: 24,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.thisWeek,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(rangeLabel,
                      style: TextStyle(
                          fontSize: 12,
                          color: context.colors.cream.withValues(alpha: 0.5))),
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
                                  ? context.colors.cream.withValues(alpha: 0.08)
                                  : i == todayIndex
                                      ? context.colors.orange
                                      : context.colors.orange
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
                                  ? context.colors.orangeLight
                                  : context.colors.creamFaint,
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
                  label: s.totalHours,
                  value: '${progress.totalSeconds ~/ 3600}',
                  unit:
                      'h ${(progress.totalSeconds % 3600) ~/ 60}m',
                  delta: _weekDelta(context, thisWeekMinutes, lastWeekMinutes),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TotalCard(
                  label: s.avgAccuracy,
                  value: '${progress.averageAccuracy}',
                  unit: '%',
                  delta: _accuracyDelta(context, progress.accuracyLog),
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
              Text(s.skillBreakdown,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              for (final skill in _skills(context, progress)) ...[
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
                                  context.colors.cream.withValues(alpha: 0.65)),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: skill.$2 / 100,
                            minHeight: 7,
                            backgroundColor:
                                context.colors.cream.withValues(alpha: 0.1),
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

  (String, Color) _weekDelta(BuildContext context, int thisWeek, int lastWeek) {
    final s = context.s;
    if (lastWeek == 0) {
      return thisWeek > 0
          ? (s.firstActiveWeek, context.colors.green)
          : (s.noPracticeThisWeek, context.colors.creamFaint);
    }
    final pct = ((thisWeek - lastWeek) / lastWeek * 100).round();
    return pct >= 0
        ? (s.upFromLastWeek(pct), context.colors.green)
        : (s.downFromLastWeek(pct.abs()), context.colors.red);
  }

  (String, Color) _accuracyDelta(BuildContext context, List<double> log) {
    final s = context.s;
    if (log.isEmpty) return (s.noAiData, context.colors.creamFaint);
    if (log.length < 4) return (s.earlyData, context.colors.green);
    final half = log.length ~/ 2;
    final first = log.take(half).reduce((a, b) => a + b) / half;
    final second =
        log.skip(half).reduce((a, b) => a + b) / (log.length - half);
    final diff = (second - first).round();
    return diff >= 0
        ? (s.upPoints(diff), context.colors.green)
        : (s.downPoints(diff.abs()), context.colors.red);
  }

  List<(String, int, Color)> _skills(BuildContext context, ProgressState progress) {
    final theoryLessons =
        kLessonCatalog.where((l) => l.kind == LessonKind.theory).toList();
    final theoryDone =
        theoryLessons.where((l) => progress.isLessonCompleted(l.id)).length;
    double meanProgress(List<String> ids) => ids.isEmpty
        ? 0
        : ids.map(progress.progressOf).reduce((a, b) => a + b) / ids.length;

    final s = context.s;
    return [
      (s.chordChanges, progress.averageAccuracy, context.colors.orange),
      (
        s.strumming,
        (meanProgress(['beg-03', 'int-04']) * 100).round(),
        context.colors.blue,
      ),
      (
        s.fingerpicking,
        (progress.progressOf('int-02') * 100).round(),
        context.colors.yellowDeep,
      ),
      (
        s.musicTheory,
        theoryLessons.isEmpty
            ? 0
            : (theoryDone / theoryLessons.length * 100).round(),
        context.colors.green,
      ),
      (
        'Ear training',
        ((progress.bestEarStreak / 12).clamp(0.0, 1.0) * 100).round(),
        context.colors.purple,
      ),
    ];
  }
}

String _categoryLabel(PracticeCategory category, S s) => switch (category) {
      PracticeCategory.songs => s.categorySong,
      PracticeCategory.recorder => s.categoryRecording,
      _ => category.label,
    };

/// Donut of total practice time split by activity category.
class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard({required this.progress});

  final ProgressState progress;

  // Fixed chart accents — stable and readable on both themes.
  static const _colors = {
    PracticeCategory.lesson: Color(0xFFF0521F),
    PracticeCategory.tuner: Color(0xFF3554D1),
    PracticeCategory.metronome: Color(0xFFEFA51D),
    PracticeCategory.chords: Color(0xFF1FA05A),
    PracticeCategory.songs: Color(0xFFDE3F2B),
    PracticeCategory.earTraining: Color(0xFF7A4FD8),
    PracticeCategory.recorder: Color(0xFFEF6FAC),
    PracticeCategory.challenge: Color(0xFF7C8598),
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
          Text(context.s.practiceFocus,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          if (grandTotal == 0)
            Text(
              context.s.noDataYet,
              style: TextStyle(fontSize: 12, color: context.colors.creamFaint),
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
                        _colors[entry.key] ?? context.colors.cream,
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
                                  _categoryLabel(entry.key, context.s),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.colors.cream
                                        .withValues(alpha: 0.65),
                                  ),
                                ),
                              ),
                              Text(
                                '${entry.value ~/ 60} '
                                '${context.s.minutesShort}',
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
                  color: context.colors.cream.withValues(alpha: 0.5))),
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
                    color: context.colors.cream.withValues(alpha: 0.5),
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
