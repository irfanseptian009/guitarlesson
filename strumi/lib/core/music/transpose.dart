import 'note_utils.dart';

/// Transposes a chord name by [semitones] (e.g. `Am` +2 → `Bm`,
/// `Cmaj7` −1 → `Bmaj7`). Quality suffix is preserved; sharps are used.
String transposeChordName(String name, int semitones) {
  if (name.isEmpty || semitones == 0) return name;
  final hasSharp = name.length > 1 && name[1] == '#';
  final rootIndex = kNoteNames.indexOf(name[0]);
  if (rootIndex == -1) return name;
  final root = hasSharp ? (rootIndex + 1) % 12 : rootIndex;
  final suffix = name.substring(hasSharp ? 2 : 1);
  final transposed = ((root + semitones) % 12 + 12) % 12;
  return kNoteNames[transposed] + suffix;
}
