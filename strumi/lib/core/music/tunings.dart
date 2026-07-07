import 'note_utils.dart';

/// A guitar tuning preset: six target MIDI notes, low string first.
class Tuning {
  const Tuning({required this.name, required this.midiNotes});

  final String name;

  /// Low E → high E order (index 0 = string 6).
  final List<int> midiNotes;

  /// Note labels, low string first (e.g. `E2 A2 D3 G3 B3 E4`).
  List<String> get labels => [
        for (final m in midiNotes)
          '${kNoteNames[m % 12]}${(m ~/ 12) - 1}',
      ];

  /// Target frequency for string [index] (0 = low E) at concert pitch [a4].
  double frequencyOf(int index, {double a4 = 440.0}) =>
      NoteUtils.midiToFrequency(midiNotes[index], a4: a4);
}

/// Presets listed in the design: Standard E, Drop D, Open G, DADGAD.
const List<Tuning> kTunings = [
  Tuning(name: 'Standard E', midiNotes: [40, 45, 50, 55, 59, 64]),
  Tuning(name: 'Drop D', midiNotes: [38, 45, 50, 55, 59, 64]),
  Tuning(name: 'Open G', midiNotes: [38, 43, 50, 55, 59, 62]),
  Tuning(name: 'DADGAD', midiNotes: [38, 45, 50, 55, 57, 62]),
];
