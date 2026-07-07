import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../core/music/tunings.dart';
import '../../data/catalogs/achievements_catalog.dart';
import '../../data/models/app_settings.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/screen_scaffold.dart';

/// Profile tab: level/XP, live achievements, and all app settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _formatXp(int xp) {
    final digits = xp.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final progress = ref.watch(progressProvider);
    final xpFraction =
        (progress.xpIntoLevel / progress.xpToNextLevel).clamp(0.0, 1.0);

    return ScreenScaffold(
      gap: 16,
      children: [
        // ------------------------------------------------ header
        Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppColors.avatarGradient,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.orange.withValues(alpha: 0.3),
                    width: 3),
              ),
              alignment: Alignment.center,
              child: Text(
                settings.initials,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onOrange,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(settings.userName,
                style: const TextStyle(
                    fontSize: 21, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Pill(
                  label:
                      'Level ${progress.level} · ${progress.levelTitle}',
                  color: AppColors.blue,
                ),
                const SizedBox(width: 8),
                _Pill(
                  label: '${_formatXp(progress.xp)} XP',
                  color: AppColors.yellow,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Menuju Level ${progress.level + 1}',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.cream.withValues(alpha: 0.5))),
                Text(
                  '${_formatXp(progress.xpIntoLevel)} / '
                  '${_formatXp(progress.xpToNextLevel)} XP',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.cream.withValues(alpha: 0.5)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 8,
                child: Stack(
                  children: [
                    Container(color: Colors.white.withValues(alpha: 0.1)),
                    FractionallySizedBox(
                      widthFactor: xpFraction,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.orange, AppColors.yellow],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ------------------------------------------------ achievements
        const Text('Achievements',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.05,
          children: [
            for (final achievement in kAchievements)
              _AchievementTile(
                achievement: achievement,
                unlocked: achievement.isUnlocked(progress),
                onTap: () => ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(achievement.description))),
              ),
          ],
        ),

        // ------------------------------------------------ settings
        GlassCard(
          radius: 22,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SettingRow(
                name: 'Nama',
                value: settings.userName,
                onTap: () => _editName(context, ref, settings),
              ),
              _SettingRow(
                name: 'Gitar saya',
                value: settings.guitarType,
                onTap: () => _pickGuitar(context, ref, settings),
              ),
              _SettingRow(
                name: 'Goal harian',
                value: '${settings.dailyGoalMinutes} menit',
                onTap: () => _editGoal(context, ref, settings),
              ),
              _SettingRow(
                name: 'Notifikasi latihan',
                value: settings.reminderEnabled
                    ? '${settings.reminderHour.toString().padLeft(2, '0')}:'
                        '${settings.reminderMinute.toString().padLeft(2, '0')}'
                    : 'Nonaktif',
                extra: Switch(
                  value: settings.reminderEnabled,
                  activeThumbColor: AppColors.orange,
                  onChanged: (v) => ref
                      .read(settingsProvider.notifier)
                      .update((s) => s.copyWith(reminderEnabled: v)),
                ),
                onTap: () => _pickReminderTime(context, ref, settings),
              ),
              _SettingRow(
                name: 'Kalibrasi tuner',
                value: 'A = ${settings.a4Calibration.round()} Hz',
                onTap: () => _editCalibration(context, ref, settings),
              ),
              _SettingRow(
                name: 'Tuning',
                value: kTunings[settings.tuningIndex].name,
                onTap: () => ref.read(settingsProvider.notifier).update(
                    (s) => s.copyWith(
                        tuningIndex:
                            (s.tuningIndex + 1) % kTunings.length)),
              ),
              _SettingRow(
                name: 'Tentang Strumi',
                value: 'v1.1.0',
                onTap: () => _showAbout(context),
              ),
              _SettingRow(
                name: 'Reset progress',
                value: '',
                destructive: true,
                showDivider: false,
                onTap: () => _confirmReset(context, ref),
              ),
            ],
          ),
        ),

        Center(
          child: Text('Strumi 1.1.0 · dibuat dengan Flutter',
              style: TextStyle(fontSize: 11, color: AppColors.creamGhost)),
        ),
      ],
    );
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Strumi', style: TextStyle(fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teman belajar gitarmu — tuner presisi, metronome + drum '
              'tracks, chord detector AI, dan learning path adaptif.\n\n'
              'Semua audio disintesis langsung di perangkat; analisis '
              'suara (YIN & chromagram) berjalan offline.',
              style: TextStyle(
                  fontSize: 13, height: 1.6, color: AppColors.creamDim),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup',
                style: TextStyle(color: AppColors.orangeLight)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            const Text('Reset semua progress?', style: TextStyle(fontSize: 17)),
        content: Text(
          'XP, streak, lesson, chord dikuasai, dan statistik akan dihapus '
          'permanen. Pengaturan tetap tersimpan.',
          style: TextStyle(
              fontSize: 13, height: 1.5, color: AppColors.creamDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(progressProvider.notifier).resetAll();
    }
  }

  Future<void> _editName(
      BuildContext context, WidgetRef ref, AppSettings settings) async {
    final controller = TextEditingController(text: settings.userName);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nama', style: TextStyle(fontSize: 17)),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Simpan',
                style: TextStyle(color: AppColors.orangeLight)),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      ref
          .read(settingsProvider.notifier)
          .update((s) => s.copyWith(userName: name));
    }
    controller.dispose();
  }

  Future<void> _pickGuitar(
      BuildContext context, WidgetRef ref, AppSettings settings) async {
    const options = [
      'Akustik steel',
      'Akustik nylon',
      'Elektrik',
      'Klasik',
    ];
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Gitar saya', style: TextStyle(fontSize: 17)),
        children: [
          for (final option in options)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, option),
              child: Text(
                option,
                style: TextStyle(
                  color: option == settings.guitarType
                      ? AppColors.orangeLight
                      : AppColors.cream,
                  fontWeight: option == settings.guitarType
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
    if (choice != null) {
      ref
          .read(settingsProvider.notifier)
          .update((s) => s.copyWith(guitarType: choice));
    }
  }

  Future<void> _editGoal(
      BuildContext context, WidgetRef ref, AppSettings settings) async {
    var minutes = settings.dailyGoalMinutes;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Goal harian', style: TextStyle(fontSize: 17)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$minutes menit / hari',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              Slider(
                min: 10,
                max: 120,
                divisions: 22,
                value: minutes.toDouble(),
                onChanged: (v) => setState(() => minutes = v.round()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, minutes),
              child: const Text('Simpan',
                  style: TextStyle(color: AppColors.orangeLight)),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      ref
          .read(settingsProvider.notifier)
          .update((s) => s.copyWith(dailyGoalMinutes: result));
    }
  }

  Future<void> _pickReminderTime(
      BuildContext context, WidgetRef ref, AppSettings settings) async {
    final time = await showTimePicker(
      context: context,
      initialTime: settings.reminderTime,
    );
    if (time != null) {
      ref.read(settingsProvider.notifier).update((s) => s.copyWith(
            reminderEnabled: true,
            reminderHour: time.hour,
            reminderMinute: time.minute,
          ));
    }
  }

  Future<void> _editCalibration(
      BuildContext context, WidgetRef ref, AppSettings settings) async {
    var a4 = settings.a4Calibration.round();
    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title:
              const Text('Kalibrasi tuner', style: TextStyle(fontSize: 17)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('A = $a4 Hz',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              Slider(
                min: 432,
                max: 446,
                divisions: 14,
                value: a4.toDouble(),
                onChanged: (v) => setState(() => a4 = v.round()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, a4),
              child: const Text('Simpan',
                  style: TextStyle(color: AppColors.orangeLight)),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      ref
          .read(settingsProvider.notifier)
          .update((s) => s.copyWith(a4Calibration: result.toDouble()));
    }
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.achievement,
    required this.unlocked,
    required this.onTap,
  });

  final Achievement achievement;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: unlocked ? 1 : 0.5,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.cardFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: unlocked
                  ? AppColors.orange.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.07),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: unlocked
                      ? achievement.color.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: 0.785,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: unlocked
                          ? achievement.color
                          : AppColors.creamFaint,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                achievement.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.name,
    required this.value,
    required this.onTap,
    this.extra,
    this.showDivider = true,
    this.destructive = false,
  });

  final String name;
  final String value;
  final VoidCallback onTap;
  final Widget? extra;
  final bool showDivider;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.06)),
                )
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: destructive ? AppColors.red : AppColors.cream,
                ),
              ),
            ),
            ?extra,
            Text(
              value.isEmpty ? '›' : '$value ›',
              style: TextStyle(
                fontSize: 13,
                color: destructive
                    ? AppColors.red.withValues(alpha: 0.7)
                    : AppColors.cream.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
