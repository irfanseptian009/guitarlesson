import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/audio/mic_service.dart';
import '../core/audio/sound_bank.dart';
import '../core/services/reminder_service.dart';
import '../core/utils/dates.dart';
import '../data/models/app_settings.dart';
import '../data/models/progress_state.dart';

/// Overridden in `main()` with the real instances created before `runApp`.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('overridden in main'),
);

final soundBankProvider = Provider<SoundBank>(
  (ref) => throw UnimplementedError('overridden in main'),
);

/// Single shared microphone pipeline (tuner, detector, practice feedback).
final micServiceProvider = Provider<MicService>((ref) {
  final mic = MicService();
  ref.onDispose(mic.dispose);
  return mic;
});

// ---------------------------------------------------------------- settings

class SettingsNotifier extends Notifier<AppSettings> {
  static const _prefsKey = 'strumi.settings';

  @override
  AppSettings build() {
    final raw = ref.read(sharedPreferencesProvider).getString(_prefsKey);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  void update(AppSettings Function(AppSettings) transform) {
    final previous = state;
    state = transform(state);
    ref
        .read(sharedPreferencesProvider)
        .setString(_prefsKey, jsonEncode(state.toJson()));
    _syncReminder(previous);
  }

  void _syncReminder(AppSettings previous) {
    final changed = previous.reminderEnabled != state.reminderEnabled ||
        previous.reminderHour != state.reminderHour ||
        previous.reminderMinute != state.reminderMinute;
    if (!changed) return;
    if (state.reminderEnabled) {
      ReminderService.instance.scheduleDaily(state.reminderTime);
    } else {
      ReminderService.instance.cancel();
    }
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

// ---------------------------------------------------------------- progress

class ProgressNotifier extends Notifier<ProgressState> {
  static const _prefsKey = 'strumi.progress';
  static const _maxAccuracyEntries = 100;

  @override
  ProgressState build() {
    final raw = ref.read(sharedPreferencesProvider).getString(_prefsKey);
    if (raw == null) return const ProgressState();
    try {
      return ProgressState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const ProgressState();
    }
  }

  void _save(ProgressState next) {
    state = next;
    ref
        .read(sharedPreferencesProvider)
        .setString(_prefsKey, jsonEncode(next.toJson()));
  }

  /// Records elapsed practice time; ignores sub-5-second blips.
  void addPracticeSeconds(PracticeCategory category, int seconds) {
    if (seconds < 5) return;
    final key = Dates.todayKey();
    final log = {
      for (final e in state.practiceSeconds.entries)
        e.key: Map<String, int>.from(e.value),
    };
    final day = log.putIfAbsent(key, () => {});
    day[category.name] = (day[category.name] ?? 0) + seconds;
    _save(state.copyWith(practiceSeconds: log));
  }

  void awardXp(int amount) => _save(state.copyWith(xp: state.xp + amount));

  /// Raises lesson progress (never lowers). Awards XP on first completion.
  void setLessonProgress(String lessonId, double value, {int xpOnComplete = 0}) {
    final current = state.progressOf(lessonId);
    final next = value.clamp(0.0, 1.0);
    if (next <= current) return;
    final wasCompleted = state.isLessonCompleted(lessonId);
    _save(state.copyWith(
      lessonProgress: {...state.lessonProgress, lessonId: next},
      xp: !wasCompleted && next >= 1.0 ? state.xp + xpOnComplete : state.xp,
    ));
  }

  /// Marks a chord as verified by the AI detector.
  void masterChord(String chordName) {
    if (state.masteredChords.contains(chordName)) return;
    _save(state.copyWith(
      masteredChords: {...state.masteredChords, chordName},
      xp: state.xp + 15,
    ));
  }

  void openSong(String songId) {
    if (state.openedSongs.contains(songId)) return;
    _save(state.copyWith(
      openedSongs: {...state.openedSongs, songId},
      xp: state.xp + 10,
    ));
  }

  void logAccuracy(double score) {
    final log = [...state.accuracyLog, score.clamp(0, 100).toDouble()];
    if (log.length > _maxAccuracyEntries) log.removeAt(0);
    _save(state.copyWith(accuracyLog: log));
  }

  /// Completes today's daily challenge (idempotent) and awards its XP.
  void completeChallengeToday({int xp = 50}) {
    final key = Dates.todayKey();
    if (state.completedChallengeDates.contains(key)) return;
    _save(state.copyWith(
      completedChallengeDates: {...state.completedChallengeDates, key},
      xp: state.xp + xp,
    ));
  }

  void reportEarStreak(int streak) {
    if (streak <= state.bestEarStreak) return;
    _save(state.copyWith(bestEarStreak: streak));
  }

  void incrementRiffCount() =>
      _save(state.copyWith(savedRiffCount: state.savedRiffCount + 1));

  /// Keeps the highest AI practice score per lesson.
  void recordLessonScore(String lessonId, double score) {
    final current = state.lessonBestScores[lessonId] ?? 0;
    if (score <= current) return;
    _save(state.copyWith(
      lessonBestScores: {...state.lessonBestScores, lessonId: score},
    ));
  }

  /// Marks achievement celebrations as shown so they fire only once.
  void markAchievementsSeen(Iterable<String> ids) {
    _save(state.copyWith(
      seenAchievements: {...state.seenAchievements, ...ids},
    ));
  }

  void toggleFavoriteChord(String name) {
    final favorites = {...state.favoriteChords};
    if (!favorites.remove(name)) favorites.add(name);
    _save(state.copyWith(favoriteChords: favorites));
  }

  /// Wipes all progress (Profile → Reset). Settings are kept.
  void resetAll() => _save(const ProgressState());
}

final progressProvider =
    NotifierProvider<ProgressNotifier, ProgressState>(ProgressNotifier.new);
