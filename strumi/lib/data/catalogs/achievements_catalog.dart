import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../models/progress_state.dart';

/// A badge on the profile screen with a live unlock condition.
class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    required this.color,
    required this.isUnlocked,
    required this.description,
  });

  final String id;
  final String name;
  final Color color;
  final String description;
  final bool Function(ProgressState progress) isUnlocked;
}

/// The six badges from the design, each backed by real progress data.
final List<Achievement> kAchievements = [
  Achievement(
    id: 'streak-7',
    name: 'Streak 7 hari',
    color: AppColors.orange,
    description: 'Berlatih 7 hari berturut-turut',
    isUnlocked: (p) => p.streakDays >= 7,
  ),
  Achievement(
    id: 'chords-10',
    name: '10 chord',
    color: AppColors.blue,
    description: 'Kuasai 10 chord lewat verifikasi AI',
    isUnlocked: (p) => p.masteredChords.length >= 10,
  ),
  Achievement(
    id: 'first-song',
    name: 'Lagu pertama',
    color: AppColors.yellow,
    description: 'Buka dan pelajari satu lagu',
    isUnlocked: (p) => p.openedSongs.isNotEmpty,
  ),
  Achievement(
    id: 'barre-master',
    name: 'Barre master',
    color: AppColors.green,
    description: 'Selesaikan lesson barre chord',
    isUnlocked: (p) => p.isLessonCompleted('int-01'),
  ),
  Achievement(
    id: 'hours-100',
    name: '100 jam',
    color: AppColors.purple,
    description: 'Total 100 jam latihan',
    isUnlocked: (p) => p.totalSeconds >= 100 * 3600,
  ),
  Achievement(
    id: 'perfect-pitch',
    name: 'Perfect pitch',
    color: AppColors.red,
    description: 'Streak 12 jawaban benar di ear training',
    isUnlocked: (p) => p.bestEarStreak >= 12,
  ),
  Achievement(
    id: 'first-riff',
    name: 'Riff pertama',
    color: AppColors.purple,
    description: 'Simpan satu rekaman di Riff Recorder',
    isUnlocked: (p) => p.savedRiffCount >= 1,
  ),
  Achievement(
    id: 'challenge-5',
    name: 'Challenge ×5',
    color: AppColors.orange,
    description: 'Selesaikan 5 daily challenge',
    isUnlocked: (p) => p.completedChallengeDates.length >= 5,
  ),
  Achievement(
    id: 'level-5',
    name: 'Level 5',
    color: AppColors.blue,
    description: 'Capai level 5 (5.000 XP)',
    isUnlocked: (p) => p.level >= 5,
  ),
];
