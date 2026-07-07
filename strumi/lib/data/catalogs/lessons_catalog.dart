import '../models/lesson.dart';

/// Shared demo tab (the design's Am–G–C transition exercise).
const _amGcTab = [
  TabLine('e', ['0', '—', '3', '—', '0', '—']),
  TabLine('B', ['1', '—', '0', '—', '1', '—']),
  TabLine('G', ['2', '—', '0', '—', '0', '—']),
  TabLine('D', ['2', '—', '0', '—', '2', '—']),
  TabLine('A', ['0', '—', '2', '—', '3', '—']),
  TabLine('E', ['—', '—', '3', '—', '—', '—']),
];

/// The full learning path (mirrors the design's three tracks).
const List<Lesson> kLessonCatalog = [
  // ------------------------------------------------------------ Beginner
  Lesson(
    id: 'beg-01',
    track: LessonTrack.beginner,
    title: 'Anatomi gitar & cara memegang',
    minutes: 8,
    kind: LessonKind.theory,
    summary:
        'Kenali bagian-bagian gitar dan postur bermain yang nyaman sebelum '
        'jarimu menyentuh senar.',
    theoryPoints: [
      'Headstock, tuner, nut, neck, fret, body, bridge — hafalkan letaknya.',
      'Senar dihitung dari bawah: senar 1 (e tinggi) sampai senar 6 (E rendah).',
      'Duduk tegak, gitar bertumpu di paha kanan, neck sedikit naik.',
      'Ibu jari tangan kiri di belakang neck, jari melengkung seperti memegang bola.',
      'Tekan senar tepat di belakang fret, bukan di atasnya.',
    ],
    xpReward: 60,
  ),
  Lesson(
    id: 'beg-02',
    track: LessonTrack.beginner,
    title: 'Chord dasar: Am, C, D',
    minutes: 14,
    kind: LessonKind.practiceAi,
    summary:
        'Tiga chord pertamamu. Mainkan satu per satu — AI mendengarkan dan '
        'memastikan setiap chord bunyi bersih.',
    practiceChords: ['Am', 'C', 'D'],
    xpReward: 100,
  ),
  Lesson(
    id: 'beg-03',
    track: LessonTrack.beginner,
    title: 'Strumming pattern pertama',
    minutes: 12,
    kind: LessonKind.practice,
    summary:
        'Pola genjrengan D-DU-UDU di chord Em. Nyalakan metronome 70 BPM dan '
        'jaga tangan kananmu tetap mengayun.',
    theoryPoints: [
      'D = strum ke bawah, U = strum ke atas.',
      'Pola: D · DU · UDU — hitung "1, 2-dan, 3-dan-4-dan".',
      'Tangan terus mengayun seperti pendulum, walau tidak kena senar.',
      'Mulai 60–70 BPM. Naikkan 5 BPM hanya jika sudah rapi.',
    ],
    practiceChords: ['Em'],
    xpReward: 90,
  ),
  Lesson(
    id: 'beg-04',
    track: LessonTrack.beginner,
    title: 'Ganti chord dengan cepat',
    minutes: 15,
    kind: LessonKind.practiceAi,
    summary:
        'Transisi Am → G → C tanpa jeda. AI menilai kebersihan tiap chord '
        'dan kecepatan perpindahanmu.',
    practiceChords: ['Am', 'G', 'C'],
    tab: _amGcTab,
    xpReward: 120,
  ),
  Lesson(
    id: 'beg-05',
    track: LessonTrack.beginner,
    title: 'Lagu pertamamu (3 chord)',
    minutes: 18,
    kind: LessonKind.song,
    summary:
        'Gabungkan G, C, dan D menjadi progresi lagu utuh. Setelah ini, '
        'buka library Songs dan pilih lagu pertamamu!',
    practiceChords: ['G', 'C', 'D'],
    xpReward: 150,
  ),
  // -------------------------------------------------------- Intermediate
  Lesson(
    id: 'int-01',
    track: LessonTrack.intermediate,
    title: 'Barre chord: F & Bm',
    minutes: 16,
    kind: LessonKind.practiceAi,
    summary:
        'Gerbang menuju semua kunci: barre penuh. Latih F dan Bm — AI '
        'memberi tahu senar mana yang belum bunyi.',
    practiceChords: ['F', 'Bm'],
    xpReward: 150,
  ),
  Lesson(
    id: 'int-02',
    track: LessonTrack.intermediate,
    title: 'Fingerpicking pattern',
    minutes: 14,
    kind: LessonKind.practice,
    summary:
        'Pola petikan p-i-m-a di chord Am dan C. Ibu jari memainkan bass, '
        'tiga jari lain bergantian.',
    theoryPoints: [
      'p = ibu jari (senar 6-4), i = telunjuk (senar 3), m = tengah (senar 2), a = manis (senar 1).',
      'Pola dasar: p-i-m-a-m-i, ulangi tanpa putus.',
      'Jaga volume tiap jari seimbang.',
    ],
    practiceChords: ['Am', 'C'],
    xpReward: 120,
  ),
  Lesson(
    id: 'int-03',
    track: LessonTrack.intermediate,
    title: 'Pentatonic scale box 1',
    minutes: 15,
    kind: LessonKind.practice,
    summary:
        'Skala minor pentatonik posisi 1 di kunci Am — fondasi semua solo '
        'rock dan blues.',
    theoryPoints: [
      'Box 1 dimulai dari fret 5 senar 6 (nada A).',
      'Dua nada per senar: 5-8, 5-7, 5-7, 5-7, 5-8, 5-8.',
      'Naik lalu turun perlahan, satu nada per klik metronome.',
    ],
    tab: [
      TabLine('e', ['—', '—', '—', '—', '5', '8']),
      TabLine('B', ['—', '—', '—', '5', '8', '—']),
      TabLine('G', ['—', '—', '5', '7', '—', '—']),
      TabLine('D', ['—', '5', '7', '—', '—', '—']),
      TabLine('A', ['5', '7', '—', '—', '—', '—']),
      TabLine('E', ['5', '8', '—', '—', '—', '—']),
    ],
    xpReward: 130,
  ),
  Lesson(
    id: 'int-04',
    track: LessonTrack.intermediate,
    title: 'Power chord & palm mute',
    minutes: 12,
    kind: LessonKind.practice,
    summary:
        'Root + kwint = power chord. Tambahkan palm mute untuk sound rock '
        'yang rapat.',
    theoryPoints: [
      'Bentuk: jari 1 di root, jari 3 dua fret lebih tinggi di senar berikutnya.',
      'Telapak tangan kanan menyentuh senar tepat di bridge.',
      'Coba riff: E5 – G5 – A5 dengan down-stroke semua.',
    ],
    xpReward: 110,
  ),
  // ------------------------------------------------------------ Advanced
  Lesson(
    id: 'adv-01',
    track: LessonTrack.advanced,
    title: 'Sistem CAGED',
    minutes: 20,
    kind: LessonKind.theory,
    summary:
        'Lima bentuk chord terbuka (C-A-G-E-D) yang dipindah-pindah untuk '
        'memetakan seluruh fretboard.',
    theoryPoints: [
      'Setiap chord mayor bisa dimainkan lewat 5 bentuk: C, A, G, E, D.',
      'Barre menggantikan nut saat bentuk digeser naik.',
      'Contoh: C terbuka → bentuk A di fret 3 → bentuk G di fret 5.',
      'Hafalkan akar (root) tiap bentuk di senar 6, 5, dan 4.',
    ],
    xpReward: 160,
  ),
  Lesson(
    id: 'adv-02',
    track: LessonTrack.advanced,
    title: 'Improvisasi blues 12-bar',
    minutes: 22,
    kind: LessonKind.practiceAi,
    summary:
        'Progresi 12-bar di kunci A (A7–D7–E7) plus lick pentatonik. AI '
        'memeriksa chord dominanmu.',
    practiceChords: ['A7', 'D7', 'E7'],
    xpReward: 180,
  ),
  Lesson(
    id: 'adv-03',
    track: LessonTrack.advanced,
    title: 'Sweep picking dasar',
    minutes: 18,
    kind: LessonKind.practice,
    summary:
        'Arpeggio tiga senar dengan satu gerakan pick yang menyapu. Pelan '
        'dulu — kebersihan di atas kecepatan.',
    theoryPoints: [
      'Pick "jatuh" dari senar ke senar dalam satu arah.',
      'Mute senar yang sudah dibunyikan dengan telapak/jari kiri.',
      'Mulai dari arpeggio Am: fret 12-14-14 di senar 3-2-1? Gunakan metronome 50 BPM.',
    ],
    xpReward: 170,
  ),
  Lesson(
    id: 'adv-04',
    track: LessonTrack.advanced,
    title: 'Voicing jazz: maj7 & m7',
    minutes: 20,
    kind: LessonKind.practiceAi,
    summary:
        'Warna akor jazz pertamamu: Cmaj7, Am7, Dm7, dan Gmaj7 dalam progresi '
        'ii-V-I ringan.',
    practiceChords: ['Cmaj7', 'Am7', 'Dm7', 'Gmaj7'],
    xpReward: 180,
  ),
];

List<Lesson> lessonsInTrack(LessonTrack track) =>
    [for (final l in kLessonCatalog) if (l.track == track) l];

Lesson lessonById(String id) => kLessonCatalog.firstWhere((l) => l.id == id);
