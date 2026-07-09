/// Curriculum difficulty tracks.
enum LessonTrack { beginner, intermediate, advanced }

extension LessonTrackLabel on LessonTrack {
  String get label => switch (this) {
        LessonTrack.beginner => 'Beginner',
        LessonTrack.intermediate => 'Intermediate',
        LessonTrack.advanced => 'Advanced',
      };
}

/// What the lesson asks the player to do.
enum LessonKind {
  theory('teori'),
  practice('praktik'),
  practiceAi('praktik + AI'),
  song('lagu');

  const LessonKind(this.label);
  final String label;
}

/// One line of guitar tablature: the string label and six grid cells.
class TabLine {
  const TabLine(this.string, this.notes);
  final String string;
  final List<String> notes;
}

/// A lesson in the adaptive learning path.
class Lesson {
  const Lesson({
    required this.id,
    required this.track,
    required this.title,
    this.titleEn,
    required this.minutes,
    required this.kind,
    required this.summary,
    this.summaryEn,
    this.theoryPoints = const [],
    this.theoryPointsEn = const [],
    this.practiceChords = const [],
    this.tab,
    this.guitar,
    this.xpReward = 100,
  });

  final String id;
  final LessonTrack track;
  final String title;

  /// English title; falls back to [title] when absent.
  final String? titleEn;
  final int minutes;
  final LessonKind kind;

  /// [GuitarKind.id] this lesson is specific to; null = every instrument.
  final String? guitar;

  String titleFor(String lang) =>
      lang == 'id' ? title : (titleEn ?? title);

  String summaryFor(String lang) =>
      lang == 'id' ? summary : (summaryEn ?? summary);

  List<String> theoryFor(String lang) =>
      lang == 'id' || theoryPointsEn.isEmpty ? theoryPoints : theoryPointsEn;

  /// One-paragraph description shown in the player.
  final String summary;

  /// English description; falls back to [summary] when absent.
  final String? summaryEn;

  /// Bullet points for theory lessons.
  final List<String> theoryPoints;

  /// English bullets; falls back to [theoryPoints] when empty.
  final List<String> theoryPointsEn;

  /// Chord names (in order) drilled during AI practice.
  final List<String> practiceChords;

  /// Optional tablature block shown in the player.
  final List<TabLine>? tab;

  final int xpReward;

  String get meta => '$minutes min · ${kind.label}';
  bool get hasAiPractice =>
      kind == LessonKind.practiceAi && practiceChords.isNotEmpty;
}
