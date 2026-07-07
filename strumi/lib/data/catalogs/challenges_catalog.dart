/// Daily transition-drill challenge: play the chord cycle N times while
/// the AI verifies each chord.
class DailyChallenge {
  const DailyChallenge({
    required this.chords,
    this.targetCycles = 20,
    this.xp = 50,
  });

  final List<String> chords;
  final int targetCycles;
  final int xp;

  String get title => chords.join(' → ');

  String get description =>
      'Mainkan transisi ${chords.join(' → ')} sebanyak $targetCycles'
      'x tanpa jeda. AI akan menilai kebersihan tiap chord.';
}

const List<DailyChallenge> _rotation = [
  DailyChallenge(chords: ['Am', 'G', 'C']),
  DailyChallenge(chords: ['Em', 'C', 'D']),
  DailyChallenge(chords: ['G', 'D', 'Em']),
  DailyChallenge(chords: ['Am', 'Dm', 'E']),
  DailyChallenge(chords: ['C', 'G', 'Am']),
  DailyChallenge(chords: ['D', 'A', 'G']),
  DailyChallenge(chords: ['Em', 'Am', 'B7']),
];

/// The challenge rotates by calendar day, so everyone gets the same drill
/// on the same date.
DailyChallenge challengeForToday() {
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year)).inDays;
  return _rotation[dayOfYear % _rotation.length];
}
