import 'package:flutter/foundation.dart';

import '../../core/utils/dates.dart';

/// What kind of activity a practice minute belongs to.
enum PracticeCategory {
  lesson('Lesson'),
  tuner('Tuner'),
  metronome('Metronome'),
  chords('Chord'),
  songs('Lagu'),
  earTraining('Ear training'),
  recorder('Rekaman'),
  challenge('Challenge');

  const PracticeCategory(this.label);
  final String label;
}

/// Everything Strumi persists about the player: XP, lesson progress,
/// per-day practice seconds, accuracy history, and unlock bookkeeping.
@immutable
class ProgressState {
  const ProgressState({
    this.xp = 0,
    this.lessonProgress = const {},
    this.masteredChords = const {},
    this.openedSongs = const {},
    this.practiceSeconds = const {},
    this.accuracyLog = const [],
    this.completedChallengeDates = const {},
    this.bestEarStreak = 0,
    this.savedRiffCount = 0,
    this.lessonBestScores = const {},
    this.seenAchievements = const {},
    this.favoriteChords = const {},
  });

  /// Total experience points.
  final int xp;

  /// Lesson id → progress 0..1 (1 = completed).
  final Map<String, double> lessonProgress;

  /// Chord names the player has successfully verified with the detector.
  final Set<String> masteredChords;

  /// Song ids the player has opened at least once.
  final Set<String> openedSongs;

  /// `yyyy-MM-dd` → category name → seconds practiced.
  final Map<String, Map<String, int>> practiceSeconds;

  /// Rolling log (newest last, capped) of AI feedback scores 0..100.
  final List<double> accuracyLog;

  /// Dates (`yyyy-MM-dd`) on which the daily challenge was completed.
  final Set<String> completedChallengeDates;

  /// Longest correct-answer streak in ear training.
  final int bestEarStreak;

  /// Number of riffs ever saved with the recorder.
  final int savedRiffCount;

  /// Lesson id → best AI practice score (0..100).
  final Map<String, double> lessonBestScores;

  /// Achievement ids whose unlock celebration has been shown.
  final Set<String> seenAchievements;

  /// Chord names starred in the library.
  final Set<String> favoriteChords;

  // ------------------------------------------------------------- derived

  /// XP needed to go from [level] to the next: 500 × level
  /// (matches the design: level 7 → 8 costs 3500 XP).
  static int xpForNextLevel(int level) => 500 * level;

  /// Cumulative XP required to *reach* [level].
  static int cumulativeXpForLevel(int level) => 250 * level * (level - 1);

  int get level {
    var l = 1;
    while (cumulativeXpForLevel(l + 1) <= xp) {
      l++;
    }
    return l;
  }

  int get xpIntoLevel => xp - cumulativeXpForLevel(level);
  int get xpToNextLevel => xpForNextLevel(level);

  String get levelTitle => switch (level) {
        <= 3 => 'Beginner',
        <= 8 => 'Intermediate',
        _ => 'Advanced',
      };

  int secondsOn(DateTime day, [PracticeCategory? category]) {
    final perCategory = practiceSeconds[Dates.key(day)];
    if (perCategory == null) return 0;
    if (category != null) return perCategory[category.name] ?? 0;
    return perCategory.values.fold(0, (a, b) => a + b);
  }

  int get totalSeconds => practiceSeconds.values
      .expand((m) => m.values)
      .fold(0, (a, b) => a + b);

  /// Minutes practiced in the current Monday-based week.
  int get minutesThisWeek {
    final start = Dates.startOfWeek(DateTime.now());
    var seconds = 0;
    for (var i = 0; i < 7; i++) {
      seconds += secondsOn(start.add(Duration(days: i)));
    }
    return seconds ~/ 60;
  }

  /// Days practiced (≥ 1 minute) in the current week.
  int get sessionsThisWeek {
    final start = Dates.startOfWeek(DateTime.now());
    var days = 0;
    for (var i = 0; i < 7; i++) {
      if (secondsOn(start.add(Duration(days: i))) >= 60) days++;
    }
    return days;
  }

  /// Consecutive practice days ending today (or yesterday when today is
  /// still empty).
  int get streakDays {
    var day = DateTime.now();
    if (secondsOn(day) == 0) day = day.subtract(const Duration(days: 1));
    var streak = 0;
    while (secondsOn(day) > 0) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Mean of the recent AI accuracy scores, 0 when none yet.
  int get averageAccuracy {
    if (accuracyLog.isEmpty) return 0;
    final recent = accuracyLog.length > 20
        ? accuracyLog.sublist(accuracyLog.length - 20)
        : accuracyLog;
    return (recent.reduce((a, b) => a + b) / recent.length).round();
  }

  bool get challengeDoneToday =>
      completedChallengeDates.contains(Dates.todayKey());

  double progressOf(String lessonId) => lessonProgress[lessonId] ?? 0;
  bool isLessonCompleted(String lessonId) => progressOf(lessonId) >= 1.0;

  // --------------------------------------------------------------- copy

  ProgressState copyWith({
    int? xp,
    Map<String, double>? lessonProgress,
    Set<String>? masteredChords,
    Set<String>? openedSongs,
    Map<String, Map<String, int>>? practiceSeconds,
    List<double>? accuracyLog,
    Set<String>? completedChallengeDates,
    int? bestEarStreak,
    int? savedRiffCount,
    Map<String, double>? lessonBestScores,
    Set<String>? seenAchievements,
    Set<String>? favoriteChords,
  }) {
    return ProgressState(
      xp: xp ?? this.xp,
      lessonProgress: lessonProgress ?? this.lessonProgress,
      masteredChords: masteredChords ?? this.masteredChords,
      openedSongs: openedSongs ?? this.openedSongs,
      practiceSeconds: practiceSeconds ?? this.practiceSeconds,
      accuracyLog: accuracyLog ?? this.accuracyLog,
      completedChallengeDates:
          completedChallengeDates ?? this.completedChallengeDates,
      bestEarStreak: bestEarStreak ?? this.bestEarStreak,
      savedRiffCount: savedRiffCount ?? this.savedRiffCount,
      lessonBestScores: lessonBestScores ?? this.lessonBestScores,
      seenAchievements: seenAchievements ?? this.seenAchievements,
      favoriteChords: favoriteChords ?? this.favoriteChords,
    );
  }

  // ---------------------------------------------------------------- json

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'lessonProgress': lessonProgress,
        'masteredChords': masteredChords.toList(),
        'openedSongs': openedSongs.toList(),
        'practiceSeconds': practiceSeconds,
        'accuracyLog': accuracyLog,
        'completedChallengeDates': completedChallengeDates.toList(),
        'bestEarStreak': bestEarStreak,
        'savedRiffCount': savedRiffCount,
        'lessonBestScores': lessonBestScores,
        'seenAchievements': seenAchievements.toList(),
        'favoriteChords': favoriteChords.toList(),
      };

  factory ProgressState.fromJson(Map<String, dynamic> json) => ProgressState(
        xp: json['xp'] as int? ?? 0,
        lessonProgress: {
          for (final e
              in (json['lessonProgress'] as Map<String, dynamic>? ?? {})
                  .entries)
            e.key: (e.value as num).toDouble(),
        },
        masteredChords: {
          ...?(json['masteredChords'] as List?)?.cast<String>(),
        },
        openedSongs: {...?(json['openedSongs'] as List?)?.cast<String>()},
        practiceSeconds: {
          for (final e
              in (json['practiceSeconds'] as Map<String, dynamic>? ?? {})
                  .entries)
            e.key: {
              for (final c in (e.value as Map<String, dynamic>).entries)
                c.key: (c.value as num).toInt(),
            },
        },
        accuracyLog: [
          ...?(json['accuracyLog'] as List?)?.map((v) => (v as num).toDouble()),
        ],
        completedChallengeDates: {
          ...?(json['completedChallengeDates'] as List?)?.cast<String>(),
        },
        bestEarStreak: json['bestEarStreak'] as int? ?? 0,
        savedRiffCount: json['savedRiffCount'] as int? ?? 0,
        lessonBestScores: {
          for (final e
              in (json['lessonBestScores'] as Map<String, dynamic>? ?? {})
                  .entries)
            e.key: (e.value as num).toDouble(),
        },
        seenAchievements: {
          ...?(json['seenAchievements'] as List?)?.cast<String>(),
        },
        favoriteChords: {
          ...?(json['favoriteChords'] as List?)?.cast<String>(),
        },
      );
}
