import '../models/song.dart';

/// Song library: chord-progression charts only (progressions are facts;
/// no lyrics or recorded audio are included).
const List<Song> kSongCatalog = [
  Song(
    id: 'wonderwall',
    title: 'Wonderwall',
    artist: 'Oasis',
    genre: 'Pop Rock',
    level: SongLevel.easy,
    bpm: 87,
    key: 'Em',
    strumPattern: 'D DU UDU',
    sections: [
      SongSection('Intro', ['Em7', 'G', 'D', 'A7']),
      SongSection('Verse', ['Em7', 'G', 'D', 'A7', 'Em7', 'G', 'D', 'A7']),
      SongSection('Pre-Chorus', ['C', 'D', 'Em', 'C', 'D', 'A7']),
      SongSection('Chorus', ['C', 'Em7', 'G', 'Em7', 'C', 'Em7', 'G', 'A7']),
    ],
  ),
  Song(
    id: 'perfect',
    title: 'Perfect',
    artist: 'Ed Sheeran',
    genre: 'Pop',
    level: SongLevel.easy,
    bpm: 63,
    key: 'G',
    strumPattern: 'D DU DU',
    sections: [
      SongSection('Verse', ['G', 'Em', 'C', 'D', 'G', 'Em', 'C', 'D']),
      SongSection('Chorus', ['Em', 'C', 'G', 'D', 'Em', 'C', 'G', 'D']),
      SongSection('Bridge', ['C', 'G', 'D', 'Em', 'C', 'G', 'D', 'D']),
    ],
  ),
  Song(
    id: 'hotel-california',
    title: 'Hotel California',
    artist: 'Eagles',
    genre: 'Rock',
    level: SongLevel.medium,
    bpm: 74,
    key: 'Am (versi mudah)',
    strumPattern: 'D DU UDU',
    sections: [
      SongSection('Verse', ['Am', 'E7', 'G', 'D', 'F', 'C', 'Dm', 'E7']),
      SongSection('Chorus', ['F', 'C', 'E7', 'Am', 'F', 'C', 'Dm', 'E7']),
    ],
  ),
  Song(
    id: 'blackbird',
    title: 'Blackbird',
    artist: 'The Beatles',
    genre: 'Folk',
    level: SongLevel.medium,
    bpm: 94,
    key: 'G',
    strumPattern: 'Fingerpicking p-i-m',
    sections: [
      SongSection('Verse', ['G', 'Am7', 'G', 'C', 'A7', 'D7', 'G', 'G']),
      SongSection('Bridge', ['F', 'C', 'Dm', 'C', 'G', 'A7', 'D7', 'G']),
    ],
  ),
  Song(
    id: 'tears-in-heaven',
    title: 'Tears in Heaven',
    artist: 'Eric Clapton',
    genre: 'Blues',
    level: SongLevel.medium,
    bpm: 78,
    key: 'A',
    strumPattern: 'Fingerpicking p-i-m-a',
    sections: [
      SongSection('Verse', ['A', 'E', 'F#m', 'D', 'A', 'E', 'A', 'A']),
      SongSection('Chorus', ['F#m', 'D', 'A', 'E', 'F#m', 'D', 'E7', 'A']),
    ],
  ),
  Song(
    id: 'sweet-child',
    title: "Sweet Child O' Mine",
    artist: "Guns N' Roses",
    genre: 'Rock',
    level: SongLevel.hard,
    bpm: 125,
    key: 'D (versi akustik)',
    strumPattern: 'D DU DU DU',
    sections: [
      SongSection('Intro/Verse', ['D', 'D', 'C', 'C', 'G', 'G', 'D', 'D']),
      SongSection('Chorus', ['A', 'C', 'D', 'D', 'A', 'C', 'D', 'D']),
      SongSection('Bridge', ['Em', 'G', 'A', 'C', 'Em', 'G', 'A', 'A']),
    ],
  ),
  Song(
    id: 'autumn-leaves',
    title: 'Autumn Leaves',
    artist: 'Jazz Standard',
    genre: 'Jazz',
    level: SongLevel.hard,
    bpm: 110,
    key: 'Em',
    strumPattern: 'Swing comping',
    sections: [
      SongSection('A', ['Am7', 'D7', 'Gmaj7', 'Cmaj7', 'F#m', 'B7', 'Em', 'Em']),
      SongSection('B', ['F#m', 'B7', 'Em', 'Em', 'Am7', 'D7', 'Gmaj7', 'Gmaj7']),
    ],
  ),
  Song(
    id: 'asturias',
    title: 'Asturias (Leyenda)',
    artist: 'Isaac Albéniz',
    genre: 'Klasik',
    level: SongLevel.hard,
    bpm: 132,
    key: 'Em (disederhanakan)',
    strumPattern: 'Arpeggio klasik',
    sections: [
      SongSection('Tema', ['Em', 'Em', 'Am', 'Em', 'B7', 'Em', 'B7', 'Em']),
      SongSection('Variasi', ['Am', 'Em', 'Am', 'Em', 'F', 'E', 'B7', 'Em']),
    ],
  ),
];

Song songById(String id) => kSongCatalog.firstWhere((s) => s.id == id);

/// Genre filter chips (design order).
const List<String> kSongGenres = [
  'Semua', 'Pop', 'Rock', 'Folk', 'Blues', 'Jazz', 'Klasik',
];
