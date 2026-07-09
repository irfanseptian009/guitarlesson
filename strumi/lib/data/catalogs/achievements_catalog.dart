import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../models/progress_state.dart';

/// A badge on the profile screen with a live unlock condition.
class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.color,
    required this.isUnlocked,
    required this.description,
    required this.descriptionEn,
  });

  final String id;
  final String name;
  final String nameEn;

  /// Playful glyph shown on the badge tile & unlock dialog.
  final IconData icon;
  final Color color;
  final String description;
  final String descriptionEn;
  final bool Function(ProgressState progress) isUnlocked;

  String nameFor(String lang) => lang == 'id' ? name : nameEn;
  String descriptionFor(String lang) =>
      lang == 'id' ? description : descriptionEn;
}

/// The badges, each backed by real progress data.
final List<Achievement> kAchievements = [
  Achievement(
    id: 'streak-7',
    name: 'Streak 7 hari',
    nameEn: '7-day streak',
    icon: Icons.local_fire_department_rounded,
    color: AppColors.orange,
    description: 'Berlatih 7 hari berturut-turut',
    descriptionEn: 'Practice 7 days in a row',
    isUnlocked: (p) => p.streakDays >= 7,
  ),
  Achievement(
    id: 'chords-10',
    name: '10 chord',
    nameEn: '10 chords',
    icon: Icons.grid_on_rounded,
    color: AppColors.blue,
    description: 'Kuasai 10 chord lewat verifikasi AI',
    descriptionEn: 'Master 10 chords via AI verification',
    isUnlocked: (p) => p.masteredChords.length >= 10,
  ),
  Achievement(
    id: 'first-song',
    name: 'Lagu pertama',
    nameEn: 'First song',
    icon: Icons.music_note_rounded,
    color: AppColors.pinkStrong,
    description: 'Buka dan pelajari satu lagu',
    descriptionEn: 'Open and learn one song',
    isUnlocked: (p) => p.openedSongs.isNotEmpty,
  ),
  Achievement(
    id: 'barre-master',
    name: 'Barre master',
    nameEn: 'Barre master',
    icon: Icons.back_hand_rounded,
    color: AppColors.green,
    description: 'Selesaikan lesson barre chord',
    descriptionEn: 'Finish the barre-chord lesson',
    isUnlocked: (p) => p.isLessonCompleted('int-01'),
  ),
  Achievement(
    id: 'hours-100',
    name: '100 jam',
    nameEn: '100 hours',
    icon: Icons.schedule_rounded,
    color: AppColors.purple,
    description: 'Total 100 jam latihan',
    descriptionEn: '100 hours of practice in total',
    isUnlocked: (p) => p.totalSeconds >= 100 * 3600,
  ),
  Achievement(
    id: 'perfect-pitch',
    name: 'Perfect pitch',
    nameEn: 'Perfect pitch',
    icon: Icons.hearing_rounded,
    color: AppColors.red,
    description: 'Streak 12 jawaban benar di ear training',
    descriptionEn: 'Streak of 12 correct ear-training answers',
    isUnlocked: (p) => p.bestEarStreak >= 12,
  ),
  Achievement(
    id: 'first-riff',
    name: 'Riff pertama',
    nameEn: 'First riff',
    icon: Icons.graphic_eq_rounded,
    color: AppColors.purple,
    description: 'Simpan satu rekaman di Riff Recorder',
    descriptionEn: 'Save one recording in the Riff Recorder',
    isUnlocked: (p) => p.savedRiffCount >= 1,
  ),
  Achievement(
    id: 'challenge-5',
    name: 'Challenge ×5',
    nameEn: 'Challenge ×5',
    icon: Icons.emoji_events_rounded,
    color: AppColors.yellow,
    description: 'Selesaikan 5 daily challenge',
    descriptionEn: 'Complete 5 daily challenges',
    isUnlocked: (p) => p.completedChallengeDates.length >= 5,
  ),
  Achievement(
    id: 'level-5',
    name: 'Level 5',
    nameEn: 'Level 5',
    icon: Icons.workspace_premium_rounded,
    color: AppColors.blue,
    description: 'Capai level 5 (5.000 XP)',
    descriptionEn: 'Reach level 5 (5,000 XP)',
    isUnlocked: (p) => p.level >= 5,
  ),
];
