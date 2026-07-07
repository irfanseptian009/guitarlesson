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
    required this.minutes,
    required this.kind,
    required this.summary,
    this.theoryPoints = const [],
    this.practiceChords = const [],
    this.tab,
    this.xpReward = 100,
  });

  final String id;
  final LessonTrack track;
  final String title;
  final int minutes;
  final LessonKind kind;

  /// One-paragraph description shown in the player.
  final String summary;

  /// Bullet points for theory lessons.
  final List<String> theoryPoints;

  /// Chord names (in order) drilled during AI practice.
  final List<String> practiceChords;

  /// Optional tablature block shown in the player.
  final List<TabLine>? tab;

  final int xpReward;

  String get meta => '$minutes min · ${kind.label}';
  bool get hasAiPractice =>
      kind == LessonKind.practiceAi && practiceChords.isNotEmpty;
}
