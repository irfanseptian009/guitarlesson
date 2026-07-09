import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_palette.dart';
import '../../core/i18n/strings.dart';
import '../../data/catalogs/lessons_catalog.dart';
import '../../data/models/lesson.dart';
import '../../providers/app_providers.dart';
import '../../widgets/capi_deco.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/pill_chip.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/screen_scaffold.dart';

/// Learning Path tab: three difficulty tracks with sequential unlocking,
/// a navy track-summary card and Capi-styled lesson rows.
class LessonsScreen extends ConsumerStatefulWidget {
  const LessonsScreen({super.key});

  @override
  ConsumerState<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends ConsumerState<LessonsScreen> {
  LessonTrack _track = LessonTrack.beginner;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = context.s;
    final progress = ref.watch(progressProvider);
    final guitar = ref.watch(settingsProvider).guitarKind;
    final lessons = lessonsInTrack(_track, guitarId: guitar.id);

    final done =
        lessons.where((l) => progress.isLessonCompleted(l.id)).length;
    final trackXp = lessons.fold<int>(0, (sum, l) => sum + l.xpReward);
    final earnedXp = lessons.fold<int>(
        0,
        (sum, l) =>
            sum + (progress.isLessonCompleted(l.id) ? l.xpReward : 0));

    return ScreenScaffold(
      children: [
        Stack(
          children: [
            ScreenTitle(
              s.learningPath,
              subtitle: s.learningPathSubtitle,
            ),
            Positioned(
              top: 4,
              right: 2,
              child: Sparkle(color: colors.pinkStrong, size: 18),
            ),
          ],
        ),
        Row(
          children: [
            for (final track in LessonTrack.values) ...[
              PillChip(
                label: track.label,
                selected: _track == track,
                onTap: () => setState(() => _track = track),
                horizontalPadding: 18,
                fontSize: 13,
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),

        // ------------------------------------------------ track summary
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            color: colors.navy,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  child: Row(
                    children: [
                      ProgressRing(
                        size: 64,
                        thickness: 8,
                        segments: [
                          (
                            lessons.isEmpty ? 0.0 : done / lessons.length,
                            colors.yellow
                          ),
                        ],
                        trackColor: colors.onNavy.withValues(alpha: 0.16),
                        holeColor: colors.navy,
                        center: Text(
                          '$done/${lessons.length}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: colors.onNavy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${s.track} ${_track.label}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: colors.onNavy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              done == lessons.length
                                  ? s.trackComplete
                                  : s.lessonsDone(done, lessons.length),
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onNavy.withValues(alpha: 0.65),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.yellow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$earnedXp / $trackXp XP',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF232B54),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Sparkle(
                          color: colors.onNavy.withValues(alpha: 0.5),
                          size: 16),
                    ],
                  ),
                ),
                ZigzagTrim(
                    color: colors.pinkStrong, height: 9, toothWidth: 13),
              ],
            ),
          ),
        ),

        // ------------------------------------------------ lesson rows
        Column(
          children: [
            for (var i = 0; i < lessons.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _LessonRow(
                lesson: lessons[i],
                index: i,
                progress: progress.progressOf(lessons[i].id),
                unlocked: i == 0 ||
                    progress.isLessonCompleted(lessons[i - 1].id),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

String _kindLabel(LessonKind kind, S s) => switch (kind) {
      LessonKind.theory => s.theory,
      LessonKind.practice => s.practice,
      LessonKind.practiceAi => s.practiceAi,
      LessonKind.song => s.songKind,
    };

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.lesson,
    required this.index,
    required this.progress,
    required this.unlocked,
  });

  final Lesson lesson;
  final int index;
  final double progress;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = context.s;
    final completed = progress >= 1.0;
    final inProgress = progress > 0 && progress < 1;

    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.all(16),
      onTap: () {
        if (unlocked) {
          context.push('/lessons/${lesson.id}');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.s.finishPreviousFirst)),
          );
        }
      },
      child: Row(
        children: [
          // Leading state badge.
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: completed
                  ? colors.green
                  : !unlocked
                      ? colors.cream.withValues(alpha: 0.06)
                      : inProgress
                          ? colors.navy
                          : colors.orange,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: completed
                ? const Icon(Icons.check_rounded,
                    size: 24, color: Colors.white)
                : !unlocked
                    ? Icon(Icons.lock_rounded,
                        size: 18, color: colors.creamGhost)
                    : Text(
                        '${index + 1}'.padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: inProgress
                              ? colors.onNavy
                              : colors.onOrange,
                        ),
                      ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.titleFor(s.lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color:
                        unlocked ? colors.cream : colors.creamFaint,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${lesson.minutes} ${s.minutes} · '
                        '${_kindLabel(lesson.kind, s)} · +${lesson.xpReward} XP',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11.5, color: colors.creamFaint),
                      ),
                    ),
                    if (lesson.guitar != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.pink.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.electric_bolt_rounded,
                            size: 10, color: colors.navy),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Trailing state.
          if (inProgress)
            ProgressRing(
              size: 38,
              thickness: 5,
              segments: [(progress, colors.yellow)],
              trackColor: colors.cream.withValues(alpha: 0.10),
              center: Text(
                '${(progress * 100).round()}',
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w800),
              ),
            )
          else
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: completed
                    ? colors.green.withValues(alpha: 0.14)
                    : !unlocked
                        ? Colors.transparent
                        : colors.orange.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                completed
                    ? s.done
                    : !unlocked
                        ? s.locked
                        : s.start,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: completed
                      ? colors.green
                      : !unlocked
                          ? colors.creamGhost
                          : colors.orangeLight,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
