import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Song difficulty as shown on the library badges.
enum SongLevel {
  easy('Mudah'),
  medium('Sedang'),
  hard('Sulit');

  const SongLevel(this.label);
  final String label;

  Color get color => switch (this) {
        SongLevel.easy => AppColors.orangeLight,
        SongLevel.medium => AppColors.blue,
        SongLevel.hard => AppColors.red,
      };
}

/// A named section of a song's chord chart (Intro, Verse, ...).
class SongSection {
  const SongSection(this.name, this.bars, {this.lyrics});

  final String name;

  /// One chord name per bar.
  final List<String> bars;

  /// Optional lyric lines with inline chord markers, e.g.
  /// `[C]Burung kakak[G7]tua`. Only present for public-domain songs.
  final List<String>? lyrics;
}

/// A song in the library. Charts are chord-progression only (no lyrics).
class Song {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    required this.level,
    required this.bpm,
    required this.key,
    required this.strumPattern,
    required this.sections,
  });

  final String id;
  final String title;
  final String artist;
  final String genre;
  final SongLevel level;
  final int bpm;
  final String key;

  /// E.g. `D DU UDU` — D = down, U = up.
  final String strumPattern;
  final List<SongSection> sections;

  bool get hasLyrics =>
      sections.any((sec) => sec.lyrics != null && sec.lyrics!.isNotEmpty);

  /// Distinct chords used, in order of first appearance.
  List<String> get chordNames {
    final seen = <String>{};
    return [
      for (final section in sections)
        for (final chord in section.bars)
          if (seen.add(chord)) chord,
    ];
  }
}
