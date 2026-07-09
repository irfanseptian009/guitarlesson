/// Instrument kinds the player can own. Selecting one swaps the hero
/// illustration and surfaces instrument-specific lessons.
enum GuitarKind {
  acousticSteel('acousticSteel'),
  acousticNylon('acousticNylon'),
  electric('electric'),
  bass('bass'),
  ukulele('ukulele');

  const GuitarKind(this.id);
  final String id;

  String get labelEn => switch (this) {
        GuitarKind.acousticSteel => 'Steel Acoustic',
        GuitarKind.acousticNylon => 'Nylon / Classical',
        GuitarKind.electric => 'Electric',
        GuitarKind.bass => 'Bass',
        GuitarKind.ukulele => 'Ukulele',
      };

  String get labelId => switch (this) {
        GuitarKind.acousticSteel => 'Akustik Steel',
        GuitarKind.acousticNylon => 'Nylon / Klasik',
        GuitarKind.electric => 'Elektrik',
        GuitarKind.bass => 'Bass',
        GuitarKind.ukulele => 'Ukulele',
      };

  String label(String lang) => lang == 'id' ? labelId : labelEn;

  /// Illustrated PNG for the picker/hero card; null falls back to the
  /// hand-drawn vector art (no photo asset provided for this kind yet).
  String? get assetPath => switch (this) {
        GuitarKind.acousticSteel => 'assets/guitar-png/acoustic.png',
        GuitarKind.acousticNylon => 'assets/guitar-png/acoustic.png',
        GuitarKind.electric => 'assets/guitar-png/electric.png',
        GuitarKind.ukulele => 'assets/guitar-png/gutarlele.png',
        GuitarKind.bass => null,
      };

  /// One-line vibe description for the picker sheet.
  String tagline(String lang) => switch (this) {
        GuitarKind.acousticSteel => lang == 'id'
            ? 'Serbaguna — pop, folk & strumming'
            : 'All-rounder — pop, folk & strumming',
        GuitarKind.acousticNylon => lang == 'id'
            ? 'Lembut di jari — klasik & fingerstyle'
            : 'Easy on fingers — classical & fingerstyle',
        GuitarKind.electric => lang == 'id'
            ? 'Rock, blues & solo — butuh ampli'
            : 'Rock, blues & solos — needs an amp',
        GuitarKind.bass => lang == 'id'
            ? 'Fondasi groove — 4 senar tebal'
            : 'Groove foundation — 4 thick strings',
        GuitarKind.ukulele => lang == 'id'
            ? 'Kecil & ceria — 4 senar nylon'
            : 'Small & cheerful — 4 nylon strings',
      };

  /// Parses stored ids and the legacy human labels
  /// ('Akustik steel', 'Elektrik', …) older installs saved.
  static GuitarKind fromStored(String? value) {
    if (value == null) return GuitarKind.acousticSteel;
    for (final kind in GuitarKind.values) {
      if (kind.id == value) return kind;
    }
    final lower = value.toLowerCase();
    if (lower.contains('elektrik') || lower.contains('electric')) {
      return GuitarKind.electric;
    }
    if (lower.contains('nylon') || lower.contains('klasik')) {
      return GuitarKind.acousticNylon;
    }
    if (lower.contains('bass')) return GuitarKind.bass;
    if (lower.contains('ukulele')) return GuitarKind.ukulele;
    return GuitarKind.acousticSteel;
  }
}
