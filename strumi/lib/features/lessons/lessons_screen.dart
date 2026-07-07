import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../data/catalogs/lessons_catalog.dart';
import '../../data/models/lesson.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/pill_chip.dart';
import '../../widgets/screen_scaffold.dart';

/// Learning Path tab: three difficulty tracks with sequential unlocking.
class LessonsScreen extends ConsumerStatefulWidget {
  const LessonsScreen({super.key});

  @override
  ConsumerState<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends ConsumerState<LessonsScreen> {
  LessonTrack _track = LessonTrack.beginner;

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final lessons = lessonsInTrack(_track);

    return ScreenScaffold(
      children: [
        const ScreenTitle(
          'Learning Path',
          subtitle: 'Kurikulum adaptif — menyesuaikan progresmu',
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
    final completed = progress >= 1.0;
    final inProgress = progress > 0 && progress < 1;

    final Color badgeBg;
    final Color badgeColor;
    final String stateText;
    final Color stateColor;
    if (completed) {
      badgeBg = AppColors.green.withValues(alpha: 0.15);
      badgeColor = AppColors.green;
      stateText = 'Selesai';
      stateColor = AppColors.green;
    } else if (!unlocked) {
      badgeBg = Colors.white.withValues(alpha: 0.05);
      badgeColor = AppColors.creamFaint;
      stateText = 'Terkunci';
      stateColor = AppColors.creamFaint;
    } else {
      badgeBg = AppColors.orange.withValues(alpha: 0.15);
      badgeColor = AppColors.orangeLight;
      stateText = inProgress ? '${(progress * 100).round()}%' : 'Mulai';
      stateColor = AppColors.orangeLight;
    }

    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.all(18),
      onTap: () {
        if (unlocked) {
          context.push('/lessons/${lesson.id}');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Selesaikan lesson sebelumnya dulu.')),
          );
        }
      },
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}'.padLeft(2, '0'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: badgeColor,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lesson.title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  lesson.meta,
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.cream.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
          Text(
            stateText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: stateColor,
            ),
          ),
        ],
      ),
    );
  }
}
