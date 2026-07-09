import 'note_utils.dart';

/// Which instrument a chord voicing is fingered for.
enum Instrument { guitar, ukulele, bass }

/// Difficulty/style bucket shown under each chord tile.
enum ChordLevel {
  dasar('Dasar'),
  barre('Barre'),
  blues('Blues'),
  jazz('Jazz');

  const ChordLevel(this.label);
  final String label;
}

/// A playable chord voicing on a standard-tuned instrument.
///
/// [frets] and [fingers] are ordered low string → high string
/// (guitar: E→e, ukulele: G→A, bass: E→G).
/// Fret `-1` means muted, `0` open. Finger `0` means no finger.
class ChordShape {
  const ChordShape({
    required this.name,
    required this.level,
    required this.tip,
    this.tipEn,
    required this.frets,
    required this.fingers,
    this.instrument = Instrument.guitar,
  });

  final String name;
  final ChordLevel level;

  /// Coaching tip shown on the detail card (Bahasa Indonesia).
  final String tip;

  /// English tip; falls back to [tip] when absent.
  final String? tipEn;

  String tipFor(String lang) => lang == 'id' ? tip : (tipEn ?? tip);
  final List<int> frets;
  final List<int> fingers;
  final Instrument instrument;

  int get stringCount => frets.length;

  /// Open-string MIDI notes per instrument (standard tunings).
  List<int> get _openMidi => switch (instrument) {
        Instrument.guitar => const [40, 45, 50, 55, 59, 64],
        Instrument.ukulele => const [67, 60, 64, 69], // g C E A (re-entrant)
        Instrument.bass => const [28, 33, 38, 43],
      };

  /// Sounding MIDI notes, low string first (muted strings skipped).
  List<int> get midiNotes => [
        for (var s = 0; s < stringCount; s++)
          if (frets[s] >= 0) _openMidi[s] + frets[s],
      ];

  /// Distinct pitch classes in the voicing.
  Set<int> get pitchClasses => {for (final m in midiNotes) m % 12};

  /// Pitch class of the chord root, parsed from the name
  /// (handles sharps `F#` and flats `Bb`).
  int get rootPitchClass {
    final base = kNoteNames.indexOf(name[0]);
    if (name.length > 1 && name[1] == '#') return (base + 1) % 12;
    if (name.length > 1 && name[1] == 'b') return (base + 11) % 12;
    return base;
  }

  bool get isMinor {
    final hasAccidental =
        name.length > 1 && (name[1] == '#' || name[1] == 'b');
    final rest = name.substring(hasAccidental ? 2 : 1);
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
    tipEn: 'Your first minor chord. Keep finger 1 arched so string B rings clean.',
    frets: [-1, 0, 2, 2, 1, 0],
    fingers: [0, 0, 2, 3, 1, 0],
  ),
  ChordShape(
    name: 'C',
    level: ChordLevel.dasar,
    tip: 'Rentangkan jari 3 ke fret 3 senar A. Jangan sentuh senar G.',
    tipEn: 'Stretch finger 3 to fret 3 on string A. Don\'t touch string G.',
    frets: [-1, 3, 2, 0, 1, 0],
    fingers: [0, 3, 2, 0, 1, 0],
  ),
  ChordShape(
    name: 'G',
    level: ChordLevel.dasar,
    tip: 'Gunakan jari 2-3-4 agar transisi ke C lebih cepat.',
    tipEn: 'Use fingers 2-3-4 so the transition to C is faster.',
    frets: [3, 2, 0, 0, 0, 3],
    fingers: [3, 2, 0, 0, 0, 4],
  ),
  ChordShape(
    name: 'D',
    level: ChordLevel.dasar,
    tip: 'Bentuk segitiga kecil. Hanya petik 4 senar bawah.',
    tipEn: 'A small triangle shape. Only strum the bottom 4 strings.',
    frets: [-1, -1, 0, 2, 3, 2],
    fingers: [0, 0, 0, 1, 3, 2],
  ),
  ChordShape(
    name: 'Em',
    level: ChordLevel.dasar,
    tip: 'Chord termudah — dua jari saja. Biarkan semua senar berbunyi.',
    tipEn: 'The easiest chord — just two fingers. Let every string ring.',
    frets: [0, 2, 2, 0, 0, 0],
    fingers: [0, 2, 3, 0, 0, 0],
  ),
  ChordShape(
    name: 'E',
    level: ChordLevel.dasar,
    tip: 'Seperti Em plus jari 1 di fret 1 senar G.',
    tipEn: 'Like Em plus finger 1 on fret 1 of string G.',
    frets: [0, 2, 2, 1, 0, 0],
    fingers: [0, 2, 3, 1, 0, 0],
  ),
  ChordShape(
    name: 'Dm',
    level: ChordLevel.dasar,
    tip: 'Mirip D tapi jari 1 turun ke fret 1 senar e.',
    tipEn: 'Similar to D but finger 1 drops to fret 1 of string e.',
    frets: [-1, -1, 0, 2, 3, 1],
    fingers: [0, 0, 0, 2, 3, 1],
  ),
  ChordShape(
    name: 'A',
    level: ChordLevel.dasar,
    tip: 'Tiga jari berjajar di fret 2. Rapatkan agar tidak menyentuh senar lain.',
    tipEn: 'Three fingers lined up on fret 2. Keep them tight so they don\'t touch other strings.',
    frets: [-1, 0, 2, 2, 2, 0],
    fingers: [0, 0, 1, 2, 3, 0],
  ),
  ChordShape(
    name: 'Asus2',
    level: ChordLevel.dasar,
    tip: 'Seperti A tanpa jari di senar B — terbuka dan menggantung.',
    tipEn: 'Like A with no finger on string B — open and suspended.',
    frets: [-1, 0, 2, 2, 0, 0],
    fingers: [0, 0, 2, 3, 0, 0],
  ),
  ChordShape(
    name: 'Cadd9',
    level: ChordLevel.dasar,
    tip: 'C dengan warna ekstra. Jari 3-4 tetap di tempat saat pindah ke G.',
    tipEn: 'C with extra color. Fingers 3-4 stay put when moving to G.',
    frets: [-1, 3, 2, 0, 3, 0],
    fingers: [0, 2, 1, 0, 3, 0],
  ),
  // ---- Barre ----
  ChordShape(
    name: 'F',
    level: ChordLevel.barre,
    tip: 'Barre penuh fret 1. Mulai dari versi mini (4 senar) dulu.',
    tipEn: 'Full barre at fret 1. Start with the mini (4-string) version first.',
    frets: [1, 3, 3, 2, 1, 1],
    fingers: [1, 3, 4, 2, 1, 1],
  ),
  ChordShape(
    name: 'Bm',
    level: ChordLevel.barre,
    tip: 'Barre fret 2. Kunci ibu jari di tengah belakang neck.',
    tipEn: 'Barre at fret 2. Anchor your thumb behind the middle of the neck.',
    frets: [-1, 2, 4, 4, 3, 2],
    fingers: [0, 1, 3, 4, 2, 1],
  ),
  ChordShape(
    name: 'B',
    level: ChordLevel.barre,
    tip: 'Barre fret 2 + jari 3 menekan tiga senar sekaligus di fret 4.',
    tipEn: 'Barre at fret 2 + finger 3 presses three strings at once on fret 4.',
    frets: [-1, 2, 4, 4, 4, 2],
    fingers: [0, 1, 3, 3, 3, 1],
  ),
  ChordShape(
    name: 'F#m',
    level: ChordLevel.barre,
    tip: 'Bentuk Em digeser + barre fret 2. Latih tekanan barre perlahan.',
    tipEn: 'The Em shape shifted up + a barre at fret 2. Build barre pressure slowly.',
    frets: [2, 4, 4, 2, 2, 2],
    fingers: [1, 3, 4, 1, 1, 1],
  ),
  // ---- Blues (dominant 7th) ----
  ChordShape(
    name: 'A7',
    level: ChordLevel.blues,
    tip: 'Chord dominan untuk blues 12-bar.',
    tipEn: 'The dominant chord for 12-bar blues.',
    frets: [-1, 0, 2, 0, 2, 0],
    fingers: [0, 0, 2, 0, 3, 0],
  ),
  ChordShape(
    name: 'B7',
    level: ChordLevel.blues,
    tip: 'Empat jari bekerja — jangkar jari 2 di senar A.',
    tipEn: 'All four fingers at work — anchor finger 2 on string A.',
    frets: [-1, 2, 1, 2, 0, 2],
    fingers: [0, 2, 1, 3, 0, 4],
  ),
  ChordShape(
    name: 'C7',
    level: ChordLevel.blues,
    tip: 'C biasa plus jari 4 di fret 3 senar G.',
    tipEn: 'Regular C plus finger 4 on fret 3 of string G.',
    frets: [-1, 3, 2, 3, 1, 0],
    fingers: [0, 3, 2, 4, 1, 0],
  ),
  ChordShape(
    name: 'D7',
    level: ChordLevel.blues,
    tip: 'Segitiga terbalik dari D. Suara khas country & blues.',
    tipEn: 'D\'s triangle flipped. The classic country & blues sound.',
    frets: [-1, -1, 0, 2, 1, 2],
    fingers: [0, 0, 0, 2, 1, 3],
  ),
  ChordShape(
    name: 'E7',
    level: ChordLevel.blues,
    tip: 'E dengan jari 3 diangkat — pintu masuk blues di kunci E.',
    tipEn: 'E with finger 3 lifted — the gateway to blues in the key of E.',
    frets: [0, 2, 0, 1, 0, 0],
    fingers: [0, 2, 0, 1, 0, 0],
  ),
  ChordShape(
    name: 'G7',
    level: ChordLevel.blues,
    tip: 'Seperti G tapi jari 1 turun ke fret 1 senar e.',
    tipEn: 'Like G but finger 1 drops to fret 1 of string e.',
    frets: [3, 2, 0, 0, 0, 1],
    fingers: [3, 2, 0, 0, 0, 1],
  ),
  // ---- Jazz ----
  ChordShape(
    name: 'Cmaj7',
    level: ChordLevel.jazz,
    tip: 'Warna jazz lembut — seperti C tanpa jari 1.',
    tipEn: 'A soft jazz color — like C without finger 1.',
    frets: [-1, 3, 2, 0, 0, 0],
    fingers: [0, 3, 2, 0, 0, 0],
  ),
  ChordShape(
    name: 'Em7',
    level: ChordLevel.jazz,
    tip: 'Em dengan satu jari diangkat — terbuka dan luas.',
    tipEn: 'Em with one finger lifted — open and spacious.',
    frets: [0, 2, 0, 0, 0, 0],
    fingers: [0, 2, 0, 0, 0, 0],
  ),
  ChordShape(
    name: 'Am7',
    level: ChordLevel.jazz,
    tip: 'Am dengan jari 3 diangkat. Transisi mulus dari Am.',
    tipEn: 'Am with finger 3 lifted. A smooth transition from Am.',
    frets: [-1, 0, 2, 0, 1, 0],
    fingers: [0, 0, 2, 0, 1, 0],
  ),
  ChordShape(
    name: 'Dm7',
    level: ChordLevel.jazz,
    tip: 'Mini-barre jari 1 di dua senar teratas.',
    tipEn: 'A mini-barre with finger 1 across the top two strings.',
    frets: [-1, -1, 0, 2, 1, 1],
    fingers: [0, 0, 0, 2, 1, 1],
  ),
  ChordShape(
    name: 'Fmaj7',
    level: ChordLevel.jazz,
    tip: 'Alternatif F tanpa barre — lembut dan dreamy.',
    tipEn: 'A barre-free alternative to F — soft and dreamy.',
    frets: [-1, -1, 3, 2, 1, 0],
    fingers: [0, 0, 3, 2, 1, 0],
  ),
  ChordShape(
    name: 'Gmaj7',
    level: ChordLevel.jazz,
    tip: 'G dengan sentuhan manis di senar e fret 2.',
    tipEn: 'G with a sweet touch on string e, fret 2.',
    frets: [3, 2, 0, 0, 0, 2],
    fingers: [3, 2, 0, 0, 0, 1],
  ),

  // ---- Tambahan gitar ----
  ChordShape(
    name: 'Dsus4',
    level: ChordLevel.dasar,
    tip: 'D biasa + kelingking di fret 3 senar e. Lepas-pasang untuk hiasan.',
    tipEn: 'Regular D + pinky on fret 3 of string e. Lift on and off for ornamentation.',
    frets: [-1, -1, 0, 2, 3, 3],
    fingers: [0, 0, 0, 1, 3, 4],
  ),
  ChordShape(
    name: 'Asus4',
    level: ChordLevel.dasar,
    tip: 'A dengan jari manis pindah ke fret 3 senar B — bunyi menggantung.',
    tipEn: 'A with the ring finger moved to fret 3 of string B — a suspended sound.',
    frets: [-1, 0, 2, 2, 3, 0],
    fingers: [0, 0, 1, 2, 3, 0],
  ),
  ChordShape(
    name: 'Esus4',
    level: ChordLevel.dasar,
    tip: 'E dengan nada A ekstra — resolve kembali ke E untuk efek klasik.',
    tipEn: 'E with an extra A note — resolve back to E for a classic effect.',
    frets: [0, 2, 2, 2, 0, 0],
    fingers: [0, 1, 2, 3, 0, 0],
  ),
  ChordShape(
    name: 'Bb',
    level: ChordLevel.barre,
    tip: 'Barre bentuk A di fret 1. Jari manis menekan tiga senar sekaligus.',
    tipEn: 'An A-shaped barre at fret 1. The ring finger presses three strings at once.',
    frets: [-1, 1, 3, 3, 3, 1],
    fingers: [0, 1, 3, 3, 3, 1],
  ),
  ChordShape(
    name: 'Gm',
    level: ChordLevel.barre,
    tip: 'Barre bentuk Em di fret 3 — kerabat gelap dari G mayor.',
    tipEn: 'An Em-shaped barre at fret 3 — the dark cousin of G major.',
    frets: [3, 5, 5, 3, 3, 3],
    fingers: [1, 3, 4, 1, 1, 1],
  ),
  ChordShape(
    name: 'Cm',
    level: ChordLevel.barre,
    tip: 'Barre bentuk Am di fret 3. Cek senar B — sering mati di sini.',
    tipEn: 'An Am-shaped barre at fret 3. Check string B — it often goes dead here.',
    frets: [-1, 3, 5, 5, 4, 3],
    fingers: [0, 1, 3, 4, 2, 1],
  ),
  // ---- Ukulele (G-C-E-A) ----
  ChordShape(
    name: 'C',
    instrument: Instrument.ukulele,
    level: ChordLevel.dasar,
    tip: 'Satu jari saja: jari manis di fret 3 senar A.',
    tipEn: 'Just one finger: ring finger on fret 3 of string A.',
    frets: [0, 0, 0, 3],
    fingers: [0, 0, 0, 3],
  ),
  ChordShape(
    name: 'G',
    instrument: Instrument.ukulele,
    level: ChordLevel.dasar,
    tip: 'Bentuk segitiga di fret 2-3-2 — mirip D di gitar.',
    tipEn: 'A triangle shape at frets 2-3-2 — similar to guitar\'s D.',
    frets: [0, 2, 3, 2],
    fingers: [0, 1, 3, 2],
  ),
  ChordShape(
    name: 'Am',
    instrument: Instrument.ukulele,
    level: ChordLevel.dasar,
    tip: 'Jari tengah di fret 2 senar G. Chord paling mudah kedua.',
    tipEn: 'Middle finger on fret 2 of string G. The second-easiest chord.',
    frets: [2, 0, 0, 0],
    fingers: [2, 0, 0, 0],
  ),
  ChordShape(
    name: 'F',
    instrument: Instrument.ukulele,
    level: ChordLevel.dasar,
    tip: 'Dua jari: fret 2 senar G dan fret 1 senar E.',
    tipEn: 'Two fingers: fret 2 on string G and fret 1 on string E.',
    frets: [2, 0, 1, 0],
    fingers: [2, 0, 1, 0],
  ),
  ChordShape(
    name: 'Dm',
    instrument: Instrument.ukulele,
    level: ChordLevel.dasar,
    tip: 'F ukulele + jari di fret 2 senar C.',
    tipEn: 'Ukulele F plus a finger on fret 2 of string C.',
    frets: [2, 2, 1, 0],
    fingers: [2, 3, 1, 0],
  ),
  ChordShape(
    name: 'Em',
    instrument: Instrument.ukulele,
    level: ChordLevel.dasar,
    tip: 'Tangga kecil 0-4-3-2 — geser jari satu per satu.',
    tipEn: 'A little staircase 0-4-3-2 — slide fingers one at a time.',
    frets: [0, 4, 3, 2],
    fingers: [0, 3, 2, 1],
  ),
  ChordShape(
    name: 'A',
    instrument: Instrument.ukulele,
    level: ChordLevel.dasar,
    tip: 'Fret 2 senar G + fret 1 senar C.',
    tipEn: 'Fret 2 on string G + fret 1 on string C.',
    frets: [2, 1, 0, 0],
    fingers: [2, 1, 0, 0],
  ),
  ChordShape(
    name: 'D',
    instrument: Instrument.ukulele,
    level: ChordLevel.dasar,
    tip: 'Tiga senar fret 2 — rapatkan tiga jari, atau barre kecil.',
    tipEn: 'Three strings at fret 2 — squeeze three fingers together, or a small barre.',
    frets: [2, 2, 2, 0],
    fingers: [1, 2, 3, 0],
  ),
  ChordShape(
    name: 'E7',
    instrument: Instrument.ukulele,
    level: ChordLevel.blues,
    tip: 'Pola zig-zag 1-2-0-2. Jembatan menuju A.',
    tipEn: 'A 1-2-0-2 zig-zag pattern. A bridge toward A.',
    frets: [1, 2, 0, 2],
    fingers: [1, 2, 0, 3],
  ),
  ChordShape(
    name: 'G7',
    instrument: Instrument.ukulele,
    level: ChordLevel.blues,
    tip: 'G ukulele dengan telunjuk turun ke fret 1 senar E.',
    tipEn: 'Ukulele G with the index finger dropping to fret 1 of string E.',
    frets: [0, 2, 1, 2],
    fingers: [0, 2, 1, 3],
  ),
  ChordShape(
    name: 'C7',
    instrument: Instrument.ukulele,
    level: ChordLevel.blues,
    tip: 'Satu jari di fret 1 senar A — blues instan.',
    tipEn: 'One finger on fret 1 of string A — instant blues.',
    frets: [0, 0, 0, 1],
    fingers: [0, 0, 0, 1],
  ),
  ChordShape(
    name: 'Bm',
    instrument: Instrument.ukulele,
    level: ChordLevel.barre,
    tip: 'Barre fret 2 dengan telunjuk + jari manis di fret 4 senar G.',
    tipEn: 'A fret-2 barre with the index finger + ring finger on fret 4 of string G.',
    frets: [4, 2, 2, 2],
    fingers: [3, 1, 1, 1],
  ),
  // ---- Bass (E-A-D-G): power shapes ----
  ChordShape(
    name: 'E5',
    instrument: Instrument.bass,
    level: ChordLevel.dasar,
    tip: 'Root E open + kwint di fret 2 senar A. Fondasi rock.',
    tipEn: 'Open E root + the fifth on fret 2 of string A. The foundation of rock.',
    frets: [0, 2, -1, -1],
    fingers: [0, 2, 0, 0],
  ),
  ChordShape(
    name: 'A5',
    instrument: Instrument.bass,
    level: ChordLevel.dasar,
    tip: 'Root A open + kwint di fret 2 senar D.',
    tipEn: 'Open A root + the fifth on fret 2 of string D.',
    frets: [-1, 0, 2, -1],
    fingers: [0, 0, 2, 0],
  ),
  ChordShape(
    name: 'D5',
    instrument: Instrument.bass,
    level: ChordLevel.dasar,
    tip: 'Root D open + kwint di fret 2 senar G.',
    tipEn: 'Open D root + the fifth on fret 2 of string G.',
    frets: [-1, -1, 0, 2],
    fingers: [0, 0, 0, 2],
  ),
  ChordShape(
    name: 'G5',
    instrument: Instrument.bass,
    level: ChordLevel.dasar,
    tip: 'Bentuk bergerak: telunjuk root, jari manis kwint. Geser ke mana pun.',
    tipEn: 'A movable shape: index on the root, ring finger on the fifth. Slide it anywhere.',
    frets: [3, 5, -1, -1],
    fingers: [1, 3, 0, 0],
  ),
  ChordShape(
    name: 'C5',
    instrument: Instrument.bass,
    level: ChordLevel.dasar,
    tip: 'Pola sama seperti G5, dimulai dari senar A fret 3.',
    tipEn: 'The same pattern as G5, starting from fret 3 of string A.',
    frets: [-1, 3, 5, -1],
    fingers: [0, 1, 3, 0],
  ),
];

/// Guitar-only voicings — chroma templates, mastery counters, and song
/// charts key off this list (uke/bass share names like "C").
final List<ChordShape> kGuitarChords = [
  for (final c in kChordCatalog)
    if (c.instrument == Instrument.guitar) c,
];

List<ChordShape> chordsFor(Instrument instrument) => [
      for (final c in kChordCatalog)
        if (c.instrument == instrument) c,
    ];

/// Lookup by chord name (guitar voicings take priority); throws if the
/// chord is not in the catalog.
ChordShape chordByName(String name) =>
    kChordCatalog.firstWhere((c) => c.name == name);
