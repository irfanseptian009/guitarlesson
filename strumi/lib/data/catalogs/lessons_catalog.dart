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
    titleEn: 'Guitar anatomy & how to hold it',
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
    summaryEn: 'Get to know the parts of your guitar and a comfortable playing posture before your fingers touch the strings.',
    theoryPointsEn: [
      'Headstock, tuners, nut, neck, frets, body, bridge — memorize where each one lives.',
      'Strings are counted from the bottom: string 1 (high e) up to string 6 (low E).',
      'Sit up straight, guitar resting on your right thigh, neck angled slightly up.',
      'Left thumb behind the neck, fingers curved as if holding a ball.',
      'Press the strings right behind the fret, not on top of it.',
    ],
    xpReward: 60,
  ),
  Lesson(
    id: 'beg-02',
    track: LessonTrack.beginner,
    title: 'Chord dasar: Am, C, D',
    titleEn: 'Basic chords: Am, C, D',
    minutes: 14,
    kind: LessonKind.practiceAi,
    summary:
        'Tiga chord pertamamu. Mainkan satu per satu — AI mendengarkan dan '
        'memastikan setiap chord bunyi bersih.',
    practiceChords: ['Am', 'C', 'D'],
    summaryEn: 'Your first three chords. Play them one at a time — the AI listens and makes sure every chord rings clean.',
    xpReward: 100,
  ),
  Lesson(
    id: 'beg-03',
    track: LessonTrack.beginner,
    title: 'Strumming pattern pertama',
    titleEn: 'Your first strumming pattern',
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
    summaryEn: 'The D-DU-UDU strumming pattern on Em. Set the metronome to 70 BPM and keep your right hand swinging.',
    theoryPointsEn: [
      'D = downstrum, U = upstrum.',
      'Pattern: D · DU · UDU — count "1, 2-and, 3-and-4-and".',
      'Keep the hand swinging like a pendulum, even when it skips the strings.',
      'Start at 60–70 BPM. Add 5 BPM only once it sounds tidy.',
    ],
    xpReward: 90,
  ),
  Lesson(
    id: 'beg-04',
    track: LessonTrack.beginner,
    title: 'Ganti chord dengan cepat',
    titleEn: 'Fast chord changes',
    minutes: 15,
    kind: LessonKind.practiceAi,
    summary:
        'Transisi Am → G → C tanpa jeda. AI menilai kebersihan tiap chord '
        'dan kecepatan perpindahanmu.',
    practiceChords: ['Am', 'G', 'C'],
    tab: _amGcTab,
    summaryEn: 'Am → G → C transitions with no gaps. The AI grades how clean each chord is and how fast you switch.',
    xpReward: 120,
  ),
  Lesson(
    id: 'beg-05',
    track: LessonTrack.beginner,
    title: 'Membaca diagram chord & tab',
    titleEn: 'Reading chord diagrams & tabs',
    minutes: 10,
    kind: LessonKind.theory,
    summary:
        'Bekal wajib: cara membaca diagram chord (titik, jari, senar mati) '
        'dan tablature — biar semua lesson berikutnya terasa mudah.',
    theoryPoints: [
      'Diagram chord dibaca vertikal: garis tegak = senar, garis datar = fret.',
      'Angka pada titik = jari (1 telunjuk, 2 tengah, 3 manis, 4 kelingking).',
      'Tanda X = senar tidak dibunyikan, O = senar lepas (open).',
      'Tab dibaca kiri ke kanan; angka = fret yang ditekan pada senar itu.',
      'h = hammer-on, p = pull-off, b = bending, / = slide naik.',
    ],
    summaryEn: 'The essential toolkit: reading chord diagrams (dots, fingers, muted strings) and tablature — so every lesson after this feels easy.',
    theoryPointsEn: [
      'A chord diagram is read vertically: vertical lines = strings, horizontal lines = frets.',
      'Numbers on the dots = fingers (1 index, 2 middle, 3 ring, 4 pinky).',
      'X = don\'t play that string, O = open string.',
      'Tab reads left to right; a number = the fret to press on that string.',
      'h = hammer-on, p = pull-off, b = bend, / = slide up.',
    ],
    xpReward: 70,
  ),
  Lesson(
    id: 'beg-06',
    track: LessonTrack.beginner,
    title: 'Chord Em, E & Dm',
    titleEn: 'Chords Em, E & Dm',
    minutes: 13,
    kind: LessonKind.practiceAi,
    summary:
        'Lengkapi chord dasarmu: Em, E, dan Dm. AI mengecek tiap senar '
        'supaya tidak ada yang mati atau fals.',
    practiceChords: ['Em', 'E', 'Dm'],
    summaryEn: 'Complete your basic chords: Em, E and Dm. The AI checks every string so nothing is muted or buzzing.',
    xpReward: 110,
  ),
  Lesson(
    id: 'beg-07',
    track: LessonTrack.beginner,
    title: 'Lagu pertamamu (3 chord)',
    titleEn: 'Your first song (3 chords)',
    minutes: 18,
    kind: LessonKind.song,
    summary:
        'Gabungkan G, C, dan D menjadi progresi lagu utuh. Setelah ini, '
        'buka library Songs dan pilih lagu pertamamu!',
    practiceChords: ['G', 'C', 'D'],
    summaryEn: 'Combine G, C and D into a full song progression. After this, open the Songs library and pick your first song!',
    xpReward: 150,
  ),
  Lesson(
    id: 'beg-08',
    track: LessonTrack.beginner,
    title: 'Warna baru: Asus2 & Cadd9',
    titleEn: 'New colors: Asus2 & Cadd9',
    minutes: 14,
    kind: LessonKind.practiceAi,
    summary:
        'Dua chord "cantik" yang bikin progresi pop-mu terdengar modern. '
        'Ganti A → Asus2 dan C → Cadd9, rasakan bedanya.',
    practiceChords: ['Asus2', 'Cadd9', 'G', 'D'],
    summaryEn: 'Two "pretty" chords that make pop progressions sound modern. Swap A → Asus2 and C → Cadd9 and hear the difference.',
    xpReward: 120,
  ),
  // -------------------------------------------------------- Intermediate
  Lesson(
    id: 'int-01',
    track: LessonTrack.intermediate,
    title: 'Barre chord: F & Bm',
    titleEn: 'Barre chords: F & Bm',
    minutes: 16,
    kind: LessonKind.practiceAi,
    summary:
        'Gerbang menuju semua kunci: barre penuh. Latih F dan Bm — AI '
        'memberi tahu senar mana yang belum bunyi.',
    practiceChords: ['F', 'Bm'],
    summaryEn: 'The gateway to every key: the full barre. Drill F and Bm — the AI tells you which strings aren\'t ringing yet.',
    xpReward: 150,
  ),
  Lesson(
    id: 'int-02',
    track: LessonTrack.intermediate,
    title: 'Fingerpicking pattern',
    titleEn: 'Fingerpicking patterns',
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
    summaryEn: 'The p-i-m-a picking pattern on Am and C. The thumb plays bass while the other three fingers take turns.',
    theoryPointsEn: [
      'p = thumb (strings 6-4), i = index (string 3), m = middle (string 2), a = ring (string 1).',
      'Base pattern: p-i-m-a-m-i, repeated without stopping.',
      'Keep every finger\'s volume even.',
    ],
    xpReward: 120,
  ),
  Lesson(
    id: 'int-03',
    track: LessonTrack.intermediate,
    title: 'Pentatonic scale box 1',
    titleEn: 'Pentatonic scale box 1',
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
    summaryEn: 'Minor pentatonic position 1 in A minor — the foundation of every rock and blues solo.',
    theoryPointsEn: [
      'Box 1 starts at fret 5 of string 6 (the note A).',
      'Two notes per string: 5-8, 5-7, 5-7, 5-7, 5-8, 5-8.',
      'Climb up then back down slowly, one note per metronome click.',
    ],
    xpReward: 130,
  ),
  Lesson(
    id: 'int-04',
    track: LessonTrack.intermediate,
    title: 'Power chord & palm mute',
    titleEn: 'Power chords & palm muting',
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
    summaryEn: 'Root + fifth = power chord. Add palm muting for that tight rock sound.',
    theoryPointsEn: [
      'Shape: finger 1 on the root, finger 3 two frets up on the next string.',
      'Rest your right palm on the strings right at the bridge.',
      'Try the riff: E5 – G5 – A5, all downstrokes.',
    ],
    xpReward: 110,
  ),
  Lesson(
    id: 'int-05',
    track: LessonTrack.intermediate,
    title: 'Legato Technique: hammer-on & pull-off',
    titleEn: 'Legato technique: hammer-on & pull-off',
    minutes: 14,
    kind: LessonKind.practice,
    summary:
        'Sambungkan nada tanpa memetik ulang. Hammer-on dan pull-off adalah '
        'kunci melodi yang mengalir mulus (legato).',
    theoryPoints: [
      'Hammer-on (h): "pukul" fret berikutnya dengan ujung jari tanpa memetik.',
      'Pull-off (p): tarik jari sedikit ke bawah saat melepas agar senar tetap bunyi.',
      'Latih trill 5h7p5 di senar 3 — 4 hitungan per klik metronome.',
      'Volume nada legato harus setara dengan nada yang dipetik.',
    ],
    tab: [
      TabLine('e', ['—', '—', '—', '—', '—', '—']),
      TabLine('B', ['—', '—', '—', '—', '—', '—']),
      TabLine('G', ['5h7', 'p5', '5h7', 'p5', '5h7', 'p5']),
      TabLine('D', ['—', '—', '—', '—', '—', '—']),
      TabLine('A', ['—', '—', '—', '—', '—', '—']),
      TabLine('E', ['—', '—', '—', '—', '—', '—']),
    ],
    summaryEn: 'Connect notes without re-picking. Hammer-ons and pull-offs are the key to smooth, singing lines (legato).',
    theoryPointsEn: [
      'Hammer-on (h): "hammer" the next fret with your fingertip without picking.',
      'Pull-off (p): flick the finger slightly downward as you release so the string keeps ringing.',
      'Drill the 5h7p5 trill on string 3 — four counts per metronome click.',
      'Legato notes should be just as loud as picked ones.',
    ],
    xpReward: 140,
  ),
  Lesson(
    id: 'int-06',
    track: LessonTrack.intermediate,
    title: 'Bending Technique',
    titleEn: 'Bending technique',
    minutes: 15,
    kind: LessonKind.practice,
    summary:
        'Teknik paling ekspresif di gitar: dorong senar hingga nadanya naik '
        'persis satu (full) atau setengah (half) nada.',
    theoryPoints: [
      'Gunakan 3 jari sekaligus untuk mendorong — jari 3 di nada target, jari 1-2 membantu.',
      'Full bend: fret 7 senar 3 harus berbunyi seperti fret 9. Cek dengan memetik fret 9 dulu.',
      'Putar pergelangan tangan, bukan hanya jari, saat mendorong senar.',
      'Release bend (r): turunkan kembali perlahan sampai nada awal, tanpa bunyi pecah.',
    ],
    tab: [
      TabLine('e', ['—', '—', '—', '—', '—', '—']),
      TabLine('B', ['—', '—', '—', '—', '—', '—']),
      TabLine('G', ['9', '7b9', '—', '7b9', 'r7', '5']),
      TabLine('D', ['—', '—', '—', '—', '—', '—']),
      TabLine('A', ['—', '—', '—', '—', '—', '—']),
      TabLine('E', ['—', '—', '—', '—', '—', '—']),
    ],
    summaryEn: 'The most expressive technique on guitar: push the string until the pitch rises exactly a whole (full) or half step.',
    theoryPointsEn: [
      'Push with three fingers at once — finger 3 on the target note, fingers 1-2 helping.',
      'Full bend: fret 7 on string 3 should sound like fret 9. Check by picking fret 9 first.',
      'Rotate the wrist, not just the fingers, as you push.',
      'Release bend (r): let it back down slowly to the starting pitch, without wobble.',
    ],
    xpReward: 140,
  ),
  Lesson(
    id: 'int-07',
    track: LessonTrack.intermediate,
    title: 'Chord minor7: Em7, Am7 & Dm7',
    titleEn: 'Minor7 chords: Em7, Am7 & Dm7',
    minutes: 13,
    kind: LessonKind.practiceAi,
    summary:
        'Chord minor7 membuat progresimu terdengar hangat dan jazzy. AI '
        'memastikan nada tambahan (7th) benar-benar berbunyi.',
    practiceChords: ['Em7', 'Am7', 'Dm7'],
    summaryEn: 'Minor7 chords make your progressions sound warm and jazzy. The AI makes sure the added 7th really rings.',
    xpReward: 130,
  ),
  // ------------------------------------------------------------ Advanced
  Lesson(
    id: 'adv-01',
    track: LessonTrack.advanced,
    title: 'Sistem CAGED',
    titleEn: 'The CAGED system',
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
    summaryEn: 'Five open shapes (C-A-G-E-D) that slide up the neck to map the entire fretboard.',
    theoryPointsEn: [
      'Every major chord can be played through 5 shapes: C, A, G, E, D.',
      'A barre replaces the nut when a shape moves up the neck.',
      'Example: open C → A-shape at fret 3 → G-shape at fret 5.',
      'Memorize each shape\'s root on strings 6, 5 and 4.',
    ],
    xpReward: 160,
  ),
  Lesson(
    id: 'adv-02',
    track: LessonTrack.advanced,
    title: 'Improvisasi blues 12-bar',
    titleEn: '12-bar blues improvisation',
    minutes: 22,
    kind: LessonKind.practiceAi,
    summary:
        'Progresi 12-bar di kunci A (A7–D7–E7) plus lick pentatonik. AI '
        'memeriksa chord dominanmu.',
    practiceChords: ['A7', 'D7', 'E7'],
    summaryEn: 'The 12-bar progression in A (A7–D7–E7) plus pentatonic licks. The AI checks your dominant chords.',
    xpReward: 180,
  ),
  Lesson(
    id: 'adv-03',
    track: LessonTrack.advanced,
    title: 'Sweep picking dasar',
    titleEn: 'Sweep picking basics',
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
    summaryEn: 'Three-string arpeggios with one sweeping pick motion. Slow first — clean beats fast.',
    theoryPointsEn: [
      'The pick \'falls\' from string to string in a single direction.',
      'Mute each string after it sounds with your palm/left hand.',
      'Start with an Am arpeggio: frets 12-14-14 on strings 3-2-1. Metronome at 50 BPM.',
    ],
    xpReward: 170,
  ),
  Lesson(
    id: 'adv-04',
    track: LessonTrack.advanced,
    title: 'Voicing jazz: maj7 & m7',
    titleEn: 'Jazz voicings: maj7 & m7',
    minutes: 20,
    kind: LessonKind.practiceAi,
    summary:
        'Warna akor jazz pertamamu: Cmaj7, Am7, Dm7, dan Gmaj7 dalam progresi '
        'ii-V-I ringan.',
    practiceChords: ['Cmaj7', 'Am7', 'Dm7', 'Gmaj7'],
    summaryEn: 'Your first jazz colors: Cmaj7, Am7, Dm7 and Gmaj7 in a light ii-V-I progression.',
    xpReward: 180,
  ),
  Lesson(
    id: 'adv-05',
    track: LessonTrack.advanced,
    title: 'Tapping dua tangan',
    titleEn: 'Two-hand tapping',
    minutes: 16,
    kind: LessonKind.practice,
    summary:
        'Teknik ala Van Halen: jari tangan kanan ikut "menekan" fretboard. '
        'Gabungan tap, pull-off, dan hammer-on dalam satu lick.',
    theoryPoints: [
      't = tap: ketuk fret dengan jari telunjuk/tengah tangan kanan.',
      'Pola klasik: 12t – p8 – h5 di senar 1, ulangi seperti roda berputar.',
      'Mute senar lain dengan telapak kanan agar tidak ikut berdengung.',
      'Mulai 60 BPM; naikkan hanya saat tiap nada bunyi jelas.',
    ],
    tab: [
      TabLine('e', ['12t', 'p8', 'h5', '12t', 'p8', 'h5']),
      TabLine('B', ['—', '—', '—', '—', '—', '—']),
      TabLine('G', ['—', '—', '—', '—', '—', '—']),
      TabLine('D', ['—', '—', '—', '—', '—', '—']),
      TabLine('A', ['—', '—', '—', '—', '—', '—']),
      TabLine('E', ['—', '—', '—', '—', '—', '—']),
    ],
    summaryEn: 'The Van Halen technique: right-hand fingers fret the board too. Tap, pull-off and hammer-on combined in one lick.',
    theoryPointsEn: [
      't = tap: strike the fret with a right-hand finger.',
      'Classic pattern: 12t – p8 – h5 on string 1, looping like a spinning wheel.',
      'Mute the other strings with your right palm so they don\'t drone.',
      'Start at 60 BPM; speed up only when every note is clear.',
    ],
    xpReward: 190,
  ),
  Lesson(
    id: 'adv-06',
    track: LessonTrack.advanced,
    title: 'Travis picking (fingerstyle)',
    titleEn: 'Travis picking (fingerstyle)',
    minutes: 20,
    kind: LessonKind.practice,
    summary:
        'Bass bergantian + melodi di atasnya — fondasi fingerstyle modern. '
        'Latih di chord C dan Am sampai ibu jarimu jalan otomatis.',
    theoryPoints: [
      'Ibu jari bergantian: senar 5 → 4 di chord C, senar 5 → 3 di Am, tanpa berhenti.',
      'Jari i-m mengisi melodi di senar 2-1 di antara ketukan bass.',
      'Mulai hanya bass dulu 2 menit, baru tambahkan melodinya.',
      'Dengarkan "Dust in the Wind" — itulah target soundmu.',
    ],
    practiceChords: ['C', 'Am'],
    summaryEn: 'Alternating bass + melody on top — the foundation of modern fingerstyle. Drill it on C and Am until your thumb runs on autopilot.',
    theoryPointsEn: [
      'Alternating thumb: strings 5 → 4 on C, strings 5 → 3 on Am, without stopping.',
      'Fingers i-m fill in the melody on strings 2-1 between bass notes.',
      'Play bass only for 2 minutes first, then add the melody.',
      'Listen to "Dust in the Wind" — that is the target sound.',
    ],
    xpReward: 200,
  ),
  // ------------------------------------------------------------- Melody
  Lesson(
    id: 'mel-01',
    track: LessonTrack.beginner,
    title: 'Melodi pertamamu: Ode to Joy',
    titleEn: 'Your first melody: Ode to Joy',
    minutes: 12,
    kind: LessonKind.practice,
    summary:
        'Mainkan melodi utuh pertamamu, nada demi nada, hanya di dua senar '
        'teratas — frasa pembuka Ode to Joy dari Beethoven.',
    theoryPoints: [
      'Satu nada satu petikan — pakai downstroke dulu semuanya.',
      'Senar 1 (e) fret 0 = E, fret 1 = F, fret 3 = G.',
      'Nyanyikan nadanya sambil main — telinga ikut belajar.',
      'Ulangi frasa 4x tanpa salah sebelum menaikkan tempo.',
    ],
    tab: [
      TabLine('e', ['0', '0', '1', '3', '3', '1']),
      TabLine('B', ['—', '—', '—', '—', '—', '—']),
      TabLine('G', ['—', '—', '—', '—', '—', '—']),
      TabLine('D', ['—', '—', '—', '—', '—', '—']),
      TabLine('A', ['—', '—', '—', '—', '—', '—']),
      TabLine('E', ['—', '—', '—', '—', '—', '—']),
    ],
    summaryEn: 'Play your first full melody, note by note, on just the top two strings — the opening phrase of Beethoven\'s Ode to Joy.',
    theoryPointsEn: [
      'One note, one pick stroke — all downstrokes for now.',
      'String 1 (e): fret 0 = E, fret 1 = F, fret 3 = G.',
      'Sing along as you play — your ear learns too.',
      'Repeat the phrase 4× cleanly before raising the tempo.',
    ],
    xpReward: 110,
  ),
  Lesson(
    id: 'mel-02',
    track: LessonTrack.intermediate,
    title: 'Melodi & slide: menyambung nada',
    titleEn: 'Melody & slides: connecting notes',
    minutes: 14,
    kind: LessonKind.practice,
    summary:
        'Slide membuat melodimu terdengar menyanyi. Latih frasa pendek '
        'dengan slide naik (/) dan turun di senar 3.',
    theoryPoints: [
      'Slide (/): petik sekali, geser jari tanpa dilepas ke fret tujuan.',
      'Tekanan jari tetap penuh selama meluncur.',
      'Frasa: 5 / 7, tahan, lalu 7 turun ke 5 — dengarkan nadanya menyambung.',
      'Gabungkan dengan vibrato tipis di nada terakhir.',
    ],
    tab: [
      TabLine('e', ['—', '—', '—', '—', '—', '—']),
      TabLine('B', ['—', '—', '—', '—', '8', '—']),
      TabLine('G', ['5/7', '—', '7', '9', '—', '7']),
      TabLine('D', ['—', '—', '—', '—', '—', '—']),
      TabLine('A', ['—', '—', '—', '—', '—', '—']),
      TabLine('E', ['—', '—', '—', '—', '—', '—']),
    ],
    summaryEn: 'Slides make your melody sing. Drill a short phrase with upward (/) and downward slides on string 3.',
    theoryPointsEn: [
      'Slide (/): pick once, glide the finger to the target fret without lifting.',
      'Keep full finger pressure while gliding.',
      'Phrase: 5 / 7, hold, then 7 back down to 5 — hear the notes connect.',
      'Finish with a light vibrato on the last note.',
    ],
    xpReward: 130,
  ),
  Lesson(
    id: 'mel-03',
    track: LessonTrack.advanced,
    title: 'Improvisasi melodi: target notes',
    titleEn: 'Melodic improv: target notes',
    minutes: 18,
    kind: LessonKind.theory,
    summary:
        'Solo yang enak bukan soal cepat — tapi mendarat di nada yang '
        'tepat. Belajar membidik chord tone saat improvisasi.',
    theoryPoints: [
      'Target note = nada chord yang sedang berbunyi (root, 3rd, 5th).',
      'Di Am: bidik A, C, atau E tepat di ketukan 1 tiap bar.',
      'Nada lain dari skala jadi "jembatan" di antara target.',
      'Latihan: backing Am–G–C, mainkan hanya 3 nada per bar — pilih dengan sadar.',
      'Rekam dirimu dengan Riff Recorder, dengarkan: apakah tiap frasa "mendarat"?',
    ],
    summaryEn: 'A great solo isn\'t about speed — it\'s about landing on the right note. Learn to aim for chord tones while improvising.',
    theoryPointsEn: [
      'Target note = a note of the chord currently sounding (root, 3rd, 5th).',
      'Over Am: aim for A, C or E right on beat 1 of every bar.',
      'Other scale notes are "bridges" between the targets.',
      'Drill: over an Am–G–C backing, play only 3 notes per bar — choose them deliberately.',
      'Record yourself with the Riff Recorder and listen back: does every phrase "land"?',
    ],
    xpReward: 170,
  ),
  Lesson(
    id: 'mel-04',
    track: LessonTrack.advanced,
    title: 'Solo melodik penuh: dinamika & vibrato',
    titleEn: 'A full melodic solo: dynamics & vibrato',
    minutes: 22,
    kind: LessonKind.practice,
    summary:
        'Rangkai semua teknikmu — bending, legato, slide, vibrato — jadi '
        'satu solo 8 bar yang bernyanyi di kunci Am.',
    theoryPoints: [
      'Mulai pelan dan rendah, akhiri tinggi dan penuh — bangun cerita.',
      'Vibrato lebar di nada panjang; diam juga bagian dari musik.',
      'Frasa inti: 5/7 – 8b10 – 7p5 – vibrato di 5 (senar 2 & 3).',
      'Mainkan bersama metronome 70 BPM, lalu coba tanpa klik — rasakan waktumu sendiri.',
    ],
    tab: [
      TabLine('e', ['—', '—', '—', '—', '—', '—']),
      TabLine('B', ['—', '8b10', '—', '8', '5', '—']),
      TabLine('G', ['5/7', '—', '7p5', '—', '—', '5']),
      TabLine('D', ['—', '—', '—', '—', '—', '7']),
      TabLine('A', ['—', '—', '—', '—', '—', '—']),
      TabLine('E', ['—', '—', '—', '—', '—', '—']),
    ],
    summaryEn: 'String all your techniques — bending, legato, slides, vibrato — into one singing 8-bar solo in A minor.',
    theoryPointsEn: [
      'Start low and quiet, end high and full — build a story.',
      'Wide vibrato on long notes; silence is part of the music too.',
      'Core phrase: 5/7 – 8b10 – 7p5 – vibrato on 5 (strings 2 & 3).',
      'Play with the metronome at 70 BPM, then without the click — feel your own time.',
    ],
    xpReward: 200,
  ),
  // ----------------------------------------------------------- Electric
  Lesson(
    id: 'ele-01',
    track: LessonTrack.beginner,
    guitar: 'electric',
    title: 'Kenalan dengan gitar elektrikmu',
    titleEn: 'Meet your electric guitar',
    minutes: 10,
    kind: LessonKind.theory,
    summary:
        'Volume, tone, pickup selector, dan ampli — pahami senjatamu '
        'sebelum menyalakan distorsi.',
    theoryPoints: [
      'Pickup neck = bulat & hangat, pickup bridge = tajam & garang.',
      'Mulai dengan clean: gain rendah, volume ampli sedang.',
      'Tone 7–8 untuk rhythm, 10 untuk solo yang menembus mix.',
      'Distorsi menyorot kesalahan — mute senar yang tidak dipakai!',
      'Kabel: gitar → (pedal) → input ampli. Nyalakan ampli paling akhir.',
    ],
    summaryEn: 'Volume, tone, pickup selector and the amp — understand your weapon before you switch on the distortion.',
    theoryPointsEn: [
      'Neck pickup = round & warm, bridge pickup = sharp & aggressive.',
      'Start clean: low gain, medium amp volume.',
      'Tone 7–8 for rhythm, 10 for solos that cut through the mix.',
      'Distortion exposes mistakes — mute the strings you aren\'t using!',
      'Cable: guitar → (pedals) → amp input. Switch the amp on last.',
    ],
    xpReward: 80,
  ),
  Lesson(
    id: 'ele-02',
    track: LessonTrack.intermediate,
    guitar: 'electric',
    title: 'Riff rock pertamamu',
    titleEn: 'Your first rock riff',
    minutes: 14,
    kind: LessonKind.practice,
    summary:
        'Power chord + palm mute + distorsi = riff rock klasik. Kunci '
        'ritme ada di tangan kananmu.',
    theoryPoints: [
      'Semua downstroke, palm mute rapat di bridge.',
      'Riff: E5 ×4 (mute) → G5 ×2 → A5 ×2, ulangi.',
      'Aksen di ketukan 1: sedikit lebih keras, sisanya rata.',
      'Naikkan tempo 5 BPM tiap kali bersih 4x berturut-turut.',
    ],
    tab: [
      TabLine('e', ['—', '—', '—', '—', '—', '—']),
      TabLine('B', ['—', '—', '—', '—', '—', '—']),
      TabLine('G', ['—', '—', '—', '—', '—', '—']),
      TabLine('D', ['—', '—', '—', '5', '7', '7']),
      TabLine('A', ['2', '2', '2', '5', '7', '7']),
      TabLine('E', ['0', '0', '0', '3', '5', '5']),
    ],
    summaryEn: 'Power chords + palm mute + distortion = the classic rock riff. The rhythm lives in your right hand.',
    theoryPointsEn: [
      'All downstrokes, palm mute tight at the bridge.',
      'Riff: E5 ×4 (muted) → G5 ×2 → A5 ×2, repeat.',
      'Accent beat 1 slightly harder, keep the rest even.',
      'Add 5 BPM every time you nail it 4× in a row.',
    ],
    xpReward: 140,
  ),
  // --------------------------------------------------------------- Bass
  Lesson(
    id: 'bas-01',
    track: LessonTrack.beginner,
    guitar: 'bass',
    title: 'Groove bass pertamamu',
    titleEn: 'Your first bass groove',
    minutes: 12,
    kind: LessonKind.practice,
    summary:
        'Bass adalah jembatan drum dan chord. Kunci groove: nada root '
        'yang tepat waktu, bukan banyak nada.',
    theoryPoints: [
      'Petik dengan telunjuk-tengah bergantian, dekat pickup.',
      'Root note mengikuti chord: Am → nada A, G → nada G, C → nada C.',
      'Mainkan nada ke-8 (dua petikan per ketuk) rata seperti mesin.',
      'Telapak kiri mute senar yang tidak dibunyikan.',
    ],
    tab: [
      TabLine('G', ['—', '—', '—', '—', '—', '—']),
      TabLine('D', ['—', '—', '—', '—', '—', '—']),
      TabLine('A', ['0', '0', '—', '—', '3', '3']),
      TabLine('E', ['—', '—', '3', '3', '—', '—']),
    ],
    summaryEn: 'Bass is the bridge between drums and chords. The secret to groove: the right root note at the right time — not lots of notes.',
    theoryPointsEn: [
      'Pluck with alternating index and middle fingers, near the pickup.',
      'Root notes follow the chords: Am → A, G → G, C → C.',
      'Play eighth notes (two plucks per beat) machine-steady.',
      'Mute idle strings with your left palm.',
    ],
    xpReward: 110,
  ),
  Lesson(
    id: 'bas-02',
    track: LessonTrack.intermediate,
    guitar: 'bass',
    title: 'Walking bass sederhana',
    titleEn: 'Simple walking bass',
    minutes: 15,
    kind: LessonKind.practice,
    summary:
        '"Berjalan" dari chord ke chord dengan nada penghubung — dasar '
        'blues dan jazz yang bikin bassline hidup.',
    theoryPoints: [
      'Formula per bar: root → 3rd → 5th → nada pendekatan ke chord berikut.',
      'Contoh A ke D: A – C# – E – Eb → mendarat di D.',
      'Semua nada seperempat, rata, tanpa aksen berlebih.',
      'Latih pelan 60 BPM; walking bass soal konsistensi, bukan speed.',
    ],
    tab: [
      TabLine('G', ['—', '—', '—', '—', '—', '—']),
      TabLine('D', ['—', '—', '2', '1', '0', '—']),
      TabLine('A', ['0', '4', '—', '—', '—', '5']),
      TabLine('E', ['—', '—', '—', '—', '—', '—']),
    ],
    summaryEn: '"Walk" from chord to chord through connecting notes — the blues and jazz foundation that brings basslines to life.',
    theoryPointsEn: [
      'Per-bar formula: root → 3rd → 5th → approach note into the next chord.',
      'Example A to D: A – C# – E – Eb → landing on D.',
      'All quarter notes, even, with no extra accents.',
      'Drill slowly at 60 BPM; walking bass is about consistency, not speed.',
    ],
    xpReward: 140,
  ),
  // ------------------------------------------------------------ Ukulele
  Lesson(
    id: 'uku-01',
    track: LessonTrack.beginner,
    guitar: 'ukulele',
    title: 'Chord ukulele pertama: C, Am, F & G',
    titleEn: 'First ukulele chords: C, Am, F & G',
    minutes: 12,
    kind: LessonKind.practice,
    summary:
        'Empat chord, ribuan lagu. Di ukulele semuanya cuma butuh 1–3 '
        'jari — progresi pop siap dalam sehari.',
    theoryPoints: [
      'Senar ukulele dari atas: G-C-E-A (senar 4 → 1).',
      'C: jari 3 di fret 3 senar 1. Satu jari saja!',
      'Am: jari 2 di fret 2 senar 4. F: tambah jari 1 di fret 1 senar 2.',
      'G: bentuk segitiga — fret 2 senar 4 & 1, fret 3 senar 2.',
      'Progresi latihan: C → Am → F → G, 4 genjrengan tiap chord.',
    ],
    summaryEn: 'Four chords, thousands of songs. On ukulele they take just 1–3 fingers — a pop progression ready in a day.',
    theoryPointsEn: [
      'Ukulele strings from the top: G-C-E-A (string 4 → 1).',
      'C: ring finger on fret 3, string 1. One finger!',
      'Am: middle finger on fret 2, string 4. F: add the index on fret 1, string 2.',
      'G: a little triangle — fret 2 on strings 4 & 1, fret 3 on string 2.',
      'Practice loop: C → Am → F → G, four strums each.',
    ],
    xpReward: 110,
  ),
  Lesson(
    id: 'uku-02',
    track: LessonTrack.beginner,
    guitar: 'ukulele',
    title: 'Island strum: genjrengan ukulele',
    titleEn: 'The island strum',
    minutes: 10,
    kind: LessonKind.practice,
    summary:
        'Pola genjrengan paling terkenal di dunia ukulele: D-DU-UDU. '
        'Sekali hafal, semua lagu pantai terbuka.',
    theoryPoints: [
      'Genjreng dengan telunjuk: turun pakai kuku, naik pakai ujung jari.',
      'Pola: D · DU · UDU — hitung "1, 2-dan, dan-4-dan".',
      'Ketukan 3 dilewati (tangan tetap mengayun ke bawah tanpa kena senar).',
      'Mulai 70 BPM di chord C, lalu coba ganti chord tiap 1 bar.',
    ],
    summaryEn: 'The most famous strum in the ukulele world: D-DU-UDU. Learn it once and every beach song opens up.',
    theoryPointsEn: [
      'Strum with the index finger: nail on the way down, fingertip on the way up.',
      'Pattern: D · DU · UDU — count "1, 2-and, and-4-and".',
      'Skip beat 3 (the hand keeps swinging without touching the strings).',
      'Start at 70 BPM on C, then try changing chords every bar.',
    ],
    xpReward: 100,
  ),
];

/// Lessons for [track], keeping instrument-specific ones only when they
/// match [guitarId] (the player's selected [GuitarKind.id]).
List<Lesson> lessonsInTrack(LessonTrack track, {String? guitarId}) => [
      for (final l in kLessonCatalog)
        if (l.track == track && (l.guitar == null || l.guitar == guitarId)) l,
    ];

Lesson lessonById(String id) => kLessonCatalog.firstWhere((l) => l.id == id);
