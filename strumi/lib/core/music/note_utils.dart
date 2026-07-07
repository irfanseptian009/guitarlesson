import 'dart:math' as math;

/// Pitch-class names using sharps.
const List<String> kNoteNames = [
  'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
];

/// A concrete pitch (name + octave + frequency) resolved from a frequency
/// or a MIDI number.
class Pitch {
  const Pitch({
    required this.midi,
    required this.frequency,
    required this.cents,
  });

  /// MIDI note number of the nearest tempered pitch.
  final int midi;

  /// The measured/exact frequency in Hz.
  final double frequency;

  /// Deviation from the tempered pitch in cents (−50..+50).
  final double cents;

  int get pitchClass => midi % 12;
  int get octave => (midi ~/ 12) - 1;
  String get name => kNoteNames[pitchClass];
  String get label => '$name$octave';

  @override
  String toString() =>
      '$label ${cents >= 0 ? '+' : ''}${cents.toStringAsFixed(1)}c';
}

/// Equal-temperament math with adjustable concert pitch (A4).
abstract final class NoteUtils {
  static const int a4Midi = 69;

  /// Frequency of a MIDI note at the given concert pitch.
  static double midiToFrequency(int midi, {double a4 = 440.0}) =>
      a4 * math.pow(2, (midi - a4Midi) / 12).toDouble();

  /// Fractional MIDI number for a frequency.
  static double frequencyToMidi(double frequency, {double a4 = 440.0}) =>
      a4Midi + 12 * (math.log(frequency / a4) / math.ln2);

  /// Nearest tempered pitch (with cent deviation) for a raw frequency.
  static Pitch? pitchFromFrequency(double frequency, {double a4 = 440.0}) {
    if (frequency <= 20 || frequency > 5000 || !frequency.isFinite) {
      return null;
    }
    final midiExact = frequencyToMidi(frequency, a4: a4);
    final midi = midiExact.round();
    if (midi < 0 || midi > 127) return null;
    return Pitch(
      midi: midi,
      frequency: frequency,
      cents: (midiExact - midi) * 100,
    );
  }

  /// Cent offset of [frequency] relative to a target [reference] frequency.
  static double centsBetween(double frequency, double reference) =>
      1200 * (math.log(frequency / reference) / math.ln2);
}
