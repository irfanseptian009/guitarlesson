import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/theme/app_palette.dart';
import '../../core/i18n/strings.dart';
import '../../core/music/tunings.dart';
import '../../data/catalogs/achievements_catalog.dart';
import '../../data/models/app_settings.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/guitar_picker.dart';
import '../../widgets/pressable_scale.dart';
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
    final s = context.s;
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
            PressableScale(
              onTap: () => _editAvatar(context, ref, settings),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _AvatarCircle(settings: settings, size: 92),
                  Positioned(
                    bottom: 0,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.colors.navy,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: context.colors.surfaceDeep, width: 2),
                      ),
                      child: Icon(Icons.photo_camera_rounded,
                          size: 13, color: context.colors.onNavy),
                    ),
                  ),
                ],
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
                      '${s.level} ${progress.level} · ${progress.levelTitle}',
                  color: context.colors.blue,
                ),
                const SizedBox(width: 8),
                _Pill(
                  label: '${_formatXp(progress.xp)} XP',
                  color: context.colors.yellow,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s.toLevel(progress.level + 1),
                    style: TextStyle(
                        fontSize: 11,
                        color: context.colors.cream.withValues(alpha: 0.5))),
                Text(
                  '${_formatXp(progress.xpIntoLevel)} / '
                  '${_formatXp(progress.xpToNextLevel)} XP',
                  style: TextStyle(
                      fontSize: 11,
                      color: context.colors.cream.withValues(alpha: 0.5)),
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
                    Container(color: context.colors.cream.withValues(alpha: 0.1)),
                    FractionallySizedBox(
                      widthFactor: xpFraction,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [context.colors.orange, context.colors.yellow],
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
        Text(s.achievements,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
                      content:
                          Text(achievement.descriptionFor(s.lang)))),
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
                name: s.darkMode,
                value: settings.isDarkMode ? s.active : s.inactive,
                extra: Switch(
                  value: settings.isDarkMode,
                  activeThumbColor: context.colors.orange,
                  onChanged: (v) => ref
                      .read(settingsProvider.notifier)
                      .update((s) => s.copyWith(isDarkMode: v)),
                ),
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .update((s) => s.copyWith(isDarkMode: !s.isDarkMode)),
              ),
              _SettingRow(
                name: s.language,
                value: settings.languageCode == 'id'
                    ? 'Bahasa Indonesia'
                    : 'English',
                onTap: () => ref.read(settingsProvider.notifier).update(
                    (st) => st.copyWith(
                        languageCode:
                            st.languageCode == 'id' ? 'en' : 'id')),
              ),
              _SettingRow(
                name: s.name,
                value: settings.userName,
                onTap: () => _editName(context, ref, settings),
              ),
              _SettingRow(
                name: s.myGuitar,
                value: settings.guitarKind.label(s.lang),
                onTap: () => showGuitarPicker(context, ref),
              ),
              _SettingRow(
                name: s.dailyGoal,
                value: '${settings.dailyGoalMinutes} ${s.minutes}',
                onTap: () => _editGoal(context, ref, settings),
              ),
              _SettingRow(
                name: s.practiceReminder,
                value: settings.reminderEnabled
                    ? '${settings.reminderHour.toString().padLeft(2, '0')}:'
                        '${settings.reminderMinute.toString().padLeft(2, '0')}'
                    : s.inactive,
                extra: Switch(
                  value: settings.reminderEnabled,
                  activeThumbColor: context.colors.orange,
                  onChanged: (v) => ref
                      .read(settingsProvider.notifier)
                      .update((s) => s.copyWith(reminderEnabled: v)),
                ),
                onTap: () => _pickReminderTime(context, ref, settings),
              ),
              _SettingRow(
                name: s.tunerCalibration,
                value: 'A = ${settings.a4Calibration.round()} Hz',
                onTap: () => _editCalibration(context, ref, settings),
              ),
              _SettingRow(
                name: s.tuning,
                value: kTunings[settings.tuningIndex].name,
                onTap: () => ref.read(settingsProvider.notifier).update(
                    (s) => s.copyWith(
                        tuningIndex:
                            (s.tuningIndex + 1) % kTunings.length)),
              ),
              _SettingRow(
                name: s.aboutStrumi,
                value: 'v1.2.0',
                onTap: () => _showAbout(context),
              ),
              _SettingRow(
                name: s.resetProgress,
                value: '',
                destructive: true,
                showDivider: false,
                onTap: () => _confirmReset(context, ref),
              ),
            ],
          ),
        ),

        Center(
          child: Text(s.madeWith,
              style: TextStyle(
                  fontSize: 11, color: context.colors.creamGhost)),
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
              context.s.aboutBody,
              style: TextStyle(
                  fontSize: 13, height: 1.6, color: context.colors.creamDim),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.s.close,
                style: TextStyle(color: context.colors.orangeLight)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.s.resetTitle,
            style: const TextStyle(fontSize: 17)),
        content: Text(
          context.s.resetBody,
          style: TextStyle(
              fontSize: 13, height: 1.5, color: context.colors.creamDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.s.reset,
                style: TextStyle(color: context.colors.red)),
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
        title: Text(context.s.name, style: const TextStyle(fontSize: 17)),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(context.s.save,
                style: TextStyle(color: context.colors.orangeLight)),
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

  Future<void> _editGoal(
      BuildContext context, WidgetRef ref, AppSettings settings) async {
    var minutes = settings.dailyGoalMinutes;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.s.dailyGoal,
              style: const TextStyle(fontSize: 17)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$minutes ${context.s.minutes}',
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
              child: Text(context.s.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, minutes),
              child: Text(context.s.save,
                  style: TextStyle(color: context.colors.orangeLight)),
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


  static const _presetEmojis = [
    '🎸', '🎶', '🤘', '🎵', '🎤', '🎧', '🥁', '🎹',
    '🌟', '🔥', '😎', '🦖', '🐱', '🌈', '⚡', '🍀',
  ];

  Future<void> _editAvatar(
      BuildContext context, WidgetRef ref, AppSettings settings) async {
    final colors = context.colors;
    final s = context.s;
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: colors.surfaceDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) {
        final bottomInset = MediaQuery.paddingOf(sheetContext).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.profilePhoto,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: PressableScale(
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        await _pickPhoto(ref);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: colors.navy,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library_rounded,
                                size: 17, color: colors.onNavy),
                            const SizedBox(width: 8),
                            Text(s.pickFromGallery,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: colors.onNavy)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (settings.avatarPath.isNotEmpty ||
                      settings.avatarEmoji.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    PressableScale(
                      onTap: () {
                        ref.read(settingsProvider.notifier).update((st) =>
                            st.copyWith(avatarPath: '', avatarEmoji: ''));
                        Navigator.pop(sheetContext);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.red.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.delete_outline_rounded,
                            size: 18, color: colors.red),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Text(s.pickAvatar,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.creamDim)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final emoji in _presetEmojis)
                    PressableScale(
                      onTap: () {
                        ref.read(settingsProvider.notifier).update((st) =>
                            st.copyWith(avatarEmoji: emoji, avatarPath: ''));
                        Navigator.pop(sheetContext);
                      },
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: settings.avatarEmoji == emoji
                              ? colors.pink
                              : colors.cardFill,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.cardBorder),
                        ),
                        alignment: Alignment.center,
                        child: Text(emoji,
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickPhoto(WidgetRef ref) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 640,
        maxHeight: 640,
        imageQuality: 88,
      );
      if (picked == null) return;
      // Copy out of the picker cache so the avatar survives cache cleanup.
      final dir = await getApplicationDocumentsDirectory();
      final target = File(
          '${dir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await File(picked.path).copy(target.path);
      ref.read(settingsProvider.notifier).update(
          (st) => st.copyWith(avatarPath: target.path, avatarEmoji: ''));
    } catch (_) {
      // Picker unavailable (e.g. no gallery on this device) — ignore.
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
          title: Text(context.s.tunerCalibration,
              style: const TextStyle(fontSize: 17)),
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
              child: Text(context.s.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, a4),
              child: Text(context.s.save,
                  style: TextStyle(color: context.colors.orangeLight)),
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
            color: context.colors.cardFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: unlocked
                  ? context.colors.orange.withValues(alpha: 0.25)
                  : context.colors.cream.withValues(alpha: 0.07),
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
                      : context.colors.cream.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  achievement.icon,
                  size: 21,
                  color: unlocked
                      ? achievement.color
                      : context.colors.creamFaint,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                achievement.nameFor(context.s.lang),
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
                      color: context.colors.cream.withValues(alpha: 0.06)),
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
                  color: destructive ? context.colors.red : context.colors.cream,
                ),
              ),
            ),
            ?extra,
            Text(
              value.isEmpty ? '›' : '$value ›',
              style: TextStyle(
                fontSize: 13,
                color: destructive
                    ? context.colors.red.withValues(alpha: 0.7)
                    : context.colors.cream.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile avatar: gallery photo > emoji > gradient initials.
class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.settings, required this.size});

  final AppSettings settings;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final photo =
        settings.avatarPath.isNotEmpty ? File(settings.avatarPath) : null;
    final hasPhoto = photo != null && photo.existsSync();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: hasPhoto ? null : colors.avatarGradient,
        color: hasPhoto ? colors.navy : null,
        shape: BoxShape.circle,
        border: Border.all(
            color: colors.orange.withValues(alpha: 0.3), width: 3),
        image: hasPhoto
            ? DecorationImage(image: FileImage(photo), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: hasPhoto
          ? null
          : settings.avatarEmoji.isNotEmpty
              ? Text(settings.avatarEmoji,
                  style: TextStyle(fontSize: size * 0.42))
              : Text(
                  settings.initials,
                  style: TextStyle(
                    fontSize: size * 0.32,
                    fontWeight: FontWeight.w800,
                    color: colors.onOrange,
                  ),
                ),
    );
  }
}
