import 'note_utils.dart';

/// Difficulty/style bucket shown under each chord tile.
enum ChordLevel {
  dasar('Dasar'),
  barre('Barre'),
  blues('Blues'),
  jazz('Jazz');

  const ChordLevel(this.label);
  final String label;
}

/// A playable chord voicing on a standard-tuned guitar.
///
/// [frets] and [fingers] are ordered low E → high e.
/// Fret `-1` means muted, `0` open. Finger `0` means no finger.
class ChordShape {
  const ChordShape({
    required this.name,
    required this.level,
    required this.tip,
    required this.frets,
    required this.fingers,
  });

  final String name;
  final ChordLevel level;

  /// Coaching tip shown on the detail card (Bahasa Indonesia).
  final String tip;
  final List<int> frets;
  final List<int> fingers;

  static const List<int> _standardTuningMidi = [40, 45, 50, 55, 59, 64];

  /// Sounding MIDI notes, low string first (muted strings skipped).
  List<int> get midiNotes => [
        for (var s = 0; s < 6; s++)
          if (frets[s] >= 0) _standardTuningMidi[s] + frets[s],
      ];

  /// Distinct pitch classes in the voicing.
  Set<int> get pitchClasses => {for (final m in midiNotes) m % 12};

  /// Pitch class of the chord root, parsed from the name.
  int get rootPitchClass {
    final sharp = name.length > 1 && name[1] == '#';
    final letter = name[0];
    final base = kNoteNames.indexOf(letter);
    return sharp ? (base + 1) % 12 : base;
  }

  bool get isMinor {
    final rest = name.length > 1 && name[1] == '#'
        ? name.substring(2)
        : name.substring(1);
    return rest.startsWith('m') && !rest.startsWith('maj');
  }
}

/// Full chord catalog. The first 12 voicings mirror the design mock;
/// the rest round out a practical open/barre/blues/jazz library.
const List<ChordShape> kChordCatalog = [
  // ---- Dasar ----
  ChordShape(
    name: 'Am',
    level: ChordLevel.dasar,
    tip: 'Chord minor pertama. Jaga jari 1 tetap melengkung agar senar B bunyi bersih.',
    frets: [-1, 0, 2, 2, 1, 0],
    fingers: [0, 0, 2, 3, 1, 0],
  ),
  ChordShape(
    name: 'C',
    level: ChordLevel.dasar,
    tip: 'Rentangkan jari 3 ke fret 3 senar A. Jangan sentuh senar G.',
    frets: [-1, 3, 2, 0, 1, 0],
    fingers: [0, 3, 2, 0, 1, 0],
  ),
  ChordShape(
    name: 'G',
    level: ChordLevel.dasar,
    tip: 'Gunakan jari 2-3-4 agar transisi ke C lebih cepat.',
    frets: [3, 2, 0, 0, 0, 3],
    fingers: [3, 2, 0, 0, 0, 4],
  ),
  ChordShape(
    name: 'D',
    level: ChordLevel.dasar,
    tip: 'Bentuk segitiga kecil. Hanya petik 4 senar bawah.',
    frets: [-1, -1, 0, 2, 3, 2],
    fingers: [0, 0, 0, 1, 3, 2],
  ),
  ChordShape(
    name: 'Em',
    level: ChordLevel.dasar,
    tip: 'Chord termudah — dua jari saja. Biarkan semua senar berbunyi.',
    frets: [0, 2, 2, 0, 0, 0],
    fingers: [0, 2, 3, 0, 0, 0],
  ),
  ChordShape(
    name: 'E',
    level: ChordLevel.dasar,
    tip: 'Seperti Em plus jari 1 di fret 1 senar G.',
    frets: [0, 2, 2, 1, 0, 0],
    fingers: [0, 2, 3, 1, 0, 0],
  ),
  ChordShape(
    name: 'Dm',
    level: ChordLevel.dasar,
    tip: 'Mirip D tapi jari 1 turun ke fret 1 senar e.',
    frets: [-1, -1, 0, 2, 3, 1],
    fingers: [0, 0, 0, 2, 3, 1],
  ),
  ChordShape(
    name: 'A',
    level: ChordLevel.dasar,
    tip: 'Tiga jari berjajar di fret 2. Rapatkan agar tidak menyentuh senar lain.',
    frets: [-1, 0, 2, 2, 2, 0],
    fingers: [0, 0, 1, 2, 3, 0],
  ),
  ChordShape(
    name: 'Asus2',
    level: ChordLevel.dasar,
    tip: 'Seperti A tanpa jari di senar B — terbuka dan menggantung.',
    frets: [-1, 0, 2, 2, 0, 0],
    fingers: [0, 0, 2, 3, 0, 0],
  ),
  ChordShape(
    name: 'Cadd9',
    level: ChordLevel.dasar,
    tip: 'C dengan warna ekstra. Jari 3-4 tetap di tempat saat pindah ke G.',
    frets: [-1, 3, 2, 0, 3, 0],
    fingers: [0, 2, 1, 0, 3, 0],
  ),
  // ---- Barre ----
  ChordShape(
    name: 'F',
    level: ChordLevel.barre,
    tip: 'Barre penuh fret 1. Mulai dari versi mini (4 senar) dulu.',
    frets: [1, 3, 3, 2, 1, 1],
    fingers: [1, 3, 4, 2, 1, 1],
  ),
  ChordShape(
    name: 'Bm',
    level: ChordLevel.barre,
    tip: 'Barre fret 2. Kunci ibu jari di tengah belakang neck.',
    frets: [-1, 2, 4, 4, 3, 2],
    fingers: [0, 1, 3, 4, 2, 1],
  ),
  ChordShape(
    name: 'B',
    level: ChordLevel.barre,
    tip: 'Barre fret 2 + jari 3 menekan tiga senar sekaligus di fret 4.',
    frets: [-1, 2, 4, 4, 4, 2],
    fingers: [0, 1, 3, 3, 3, 1],
  ),
  ChordShape(
    name: 'F#m',
    level: ChordLevel.barre,
    tip: 'Bentuk Em digeser + barre fret 2. Latih tekanan barre perlahan.',
    frets: [2, 4, 4, 2, 2, 2],
    fingers: [1, 3, 4, 1, 1, 1],
  ),
  // ---- Blues (dominant 7th) ----
  ChordShape(
    name: 'A7',
    level: ChordLevel.blues,
    tip: 'Chord dominan untuk blues 12-bar.',
    frets: [-1, 0, 2, 0, 2, 0],
    fingers: [0, 0, 2, 0, 3, 0],
  ),
  ChordShape(
    name: 'B7',
    level: ChordLevel.blues,
    tip: 'Empat jari bekerja — jangkar jari 2 di senar A.',
    frets: [-1, 2, 1, 2, 0, 2],
    fingers: [0, 2, 1, 3, 0, 4],
  ),
  ChordShape(
    name: 'C7',
    level: ChordLevel.blues,
    tip: 'C biasa plus jari 4 di fret 3 senar G.',
    frets: [-1, 3, 2, 3, 1, 0],
    fingers: [0, 3, 2, 4, 1, 0],
  ),
  ChordShape(
    name: 'D7',
    level: ChordLevel.blues,
    tip: 'Segitiga terbalik dari D. Suara khas country & blues.',
    frets: [-1, -1, 0, 2, 1, 2],
    fingers: [0, 0, 0, 2, 1, 3],
  ),
  ChordShape(
    name: 'E7',
    level: ChordLevel.blues,
    tip: 'E dengan jari 3 diangkat — pintu masuk blues di kunci E.',
    frets: [0, 2, 0, 1, 0, 0],
    fingers: [0, 2, 0, 1, 0, 0],
  ),
  ChordShape(
    name: 'G7',
    level: ChordLevel.blues,
    tip: 'Seperti G tapi jari 1 turun ke fret 1 senar e.',
    frets: [3, 2, 0, 0, 0, 1],
    fingers: [3, 2, 0, 0, 0, 1],
  ),
  // ---- Jazz ----
  ChordShape(
    name: 'Cmaj7',
    level: ChordLevel.jazz,
    tip: 'Warna jazz lembut — seperti C tanpa jari 1.',
    frets: [-1, 3, 2, 0, 0, 0],
    fingers: [0, 3, 2, 0, 0, 0],
  ),
  ChordShape(
    name: 'Em7',
    level: ChordLevel.jazz,
    tip: 'Em dengan satu jari diangkat — terbuka dan luas.',
    frets: [0, 2, 0, 0, 0, 0],
    fingers: [0, 2, 0, 0, 0, 0],
  ),
  ChordShape(
    name: 'Am7',
    level: ChordLevel.jazz,
    tip: 'Am dengan jari 3 diangkat. Transisi mulus dari Am.',
    frets: [-1, 0, 2, 0, 1, 0],
    fingers: [0, 0, 2, 0, 1, 0],
  ),
  ChordShape(
    name: 'Dm7',
    level: ChordLevel.jazz,
    tip: 'Mini-barre jari 1 di dua senar teratas.',
    frets: [-1, -1, 0, 2, 1, 1],
    fingers: [0, 0, 0, 2, 1, 1],
  ),
  ChordShape(
    name: 'Fmaj7',
    level: ChordLevel.jazz,
    tip: 'Alternatif F tanpa barre — lembut dan dreamy.',
    frets: [-1, -1, 3, 2, 1, 0],
    fingers: [0, 0, 3, 2, 1, 0],
  ),
  ChordShape(
    name: 'Gmaj7',
    level: ChordLevel.jazz,
    tip: 'G dengan sentuhan manis di senar e fret 2.',
    frets: [3, 2, 0, 0, 0, 2],
    fingers: [3, 2, 0, 0, 0, 1],
  ),
];

/// Lookup by chord name; throws if the chord is not in the catalog.
ChordShape chordByName(String name) =>
    kChordCatalog.firstWhere((c) => c.name == name);
