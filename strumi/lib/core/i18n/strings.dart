import 'package:flutter/widgets.dart';

/// App copy in English (default) and Indonesian. One getter per string —
/// `context.s.navHome` — resolved from [AppSettings.languageCode] via the
/// [StringsScope] installed in the app builder.
class S {
  const S(this.lang);

  final String lang;
  bool get _id => lang == 'id';

  static S of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StringsScope>()!.strings;

  // ------------------------------------------------------------- common
  String get cancel => _id ? 'Batal' : 'Cancel';
  String get save => _id ? 'Simpan' : 'Save';
  String get close => _id ? 'Tutup' : 'Close';
  String get seeAll => _id ? 'Lihat semua' : 'See all';
  String get minutes => _id ? 'menit' : 'min';
  String get active => _id ? 'Aktif' : 'On';
  String get inactive => _id ? 'Nonaktif' : 'Off';

  // ---------------------------------------------------------------- nav
  String get navHome => 'Home';
  String get navLessons => 'Lessons';
  String get navTools => 'Tools';
  String get navProfile => _id ? 'Profil' : 'Profile';

  // -------------------------------------------------------------- shell
  String get achievementUnlocked =>
      _id ? 'ACHIEVEMENT TERBUKA' : 'ACHIEVEMENT UNLOCKED';
  String get awesome => _id ? 'MANTAP!' : 'AWESOME!';

  // --------------------------------------------------------------- home
  String get goodMorning => _id ? 'Selamat pagi' : 'Good morning';
  String get goodDay => _id ? 'Selamat siang' : 'Good afternoon';
  String get goodAfternoon => _id ? 'Selamat sore' : 'Good afternoon';
  String get goodEvening => _id ? 'Selamat malam' : 'Good evening';
  String get yourGuitar => _id ? 'GITAR KAMU' : 'YOUR GUITAR';
  String get tuner => 'Tuner';
  String get setUp => 'Set up';
  String get switchLabel => 'Switch';
  String get continueLessons => _id ? 'Lanjutkan lessonmu' : 'Continue learning';
  String get progress => 'Progress';
  String weekSummary(int days) => _id
      ? 'Minggu ini · $days dari 7 hari'
      : 'This week · $days of 7 days';
  String get keepPracticing => _id ? 'Lanjut latihan' : 'Keep practicing';
  String get weeklyGoal => _id ? 'goal mingguan' : 'weekly goal';
  String get statMinutes => _id ? 'Menit latihan' : 'Practice minutes';
  String get statChords => _id ? 'Chord dikuasai' : 'Chords mastered';
  String get statAccuracy => _id ? 'Akurasi AI' : 'AI accuracy';
  String get dailyChallenge => 'Daily Challenge';
  String get startChallenge => _id ? 'Mulai challenge' : 'Start challenge';
  String get doneToday => _id ? 'Selesai hari ini ✓' : 'Done for today ✓';
  String get quickTools => _id ? 'Tools cepat' : 'Quick tools';
  String get preciseTuning => _id ? 'Setem presisi' : 'Precise tuning';
  String get plusDrumTracks => '+ drum tracks';

  // ------------------------------------------------------ guitar picker
  String get chooseGuitar => _id ? 'Pilih gitarmu' : 'Choose your guitar';
  String get lessonsAdapt => _id
      ? 'Lesson & ilustrasi menyesuaikan instrumenmu'
      : 'Lessons & artwork adapt to your instrument';

  // ------------------------------------------------------------ lessons
  String get learningPath => 'Learning Path';
  String get learningPathSubtitle => _id
      ? 'Kurikulum adaptif — menyesuaikan progresmu'
      : 'Adaptive curriculum — it follows your progress';
  String get track => 'Track';
  String lessonsDone(int done, int total) => _id
      ? '$done dari $total lesson selesai'
      : '$done of $total lessons done';
  String get trackComplete =>
      _id ? 'Track selesai — luar biasa! 🎉' : 'Track complete — amazing! 🎉';
  String get start => _id ? 'Mulai' : 'Start';
  String get locked => _id ? 'Terkunci' : 'Locked';
  String get done => _id ? 'Selesai' : 'Done';
  String get finishPreviousFirst => _id
      ? 'Selesaikan lesson sebelumnya dulu.'
      : 'Finish the previous lesson first.';
  String get forYourGuitar => _id ? 'Khusus gitarmu' : 'For your guitar';
  String get theory => _id ? 'teori' : 'theory';
  String get practice => _id ? 'praktik' : 'practice';
  String get practiceAi => _id ? 'praktik + AI' : 'practice + AI';
  String get songKind => _id ? 'lagu' : 'song';

  // ------------------------------------------------------ lesson player
  String get interactiveTab => _id ? 'Tab interaktif' : 'Interactive tab';
  String get autoScrollOn => _id ? 'auto-scroll aktif' : 'auto-scroll on';
  String get tabLegendStrings => _id
      ? 'Baris atas = senar 1 (e tipis) · bawah = senar 6 (E tebal)'
      : 'Top row = string 1 (thin e) · bottom = string 6 (thick E)';
  String get tabLegendNumbers => _id
      ? 'Angka = fret yang ditekan · 0 = senar lepas'
      : 'Numbers = fret to press · 0 = open string';
  String get tabLegendSymbols =>
      'h = hammer-on · p = pull-off · b = bend · t = tap · r = release';
  String get markDone => _id ? 'TANDAI SELESAI' : 'MARK AS DONE';
  String get alreadyDone => _id ? 'SUDAH SELESAI ✓' : 'COMPLETED ✓';
  String fretRange(int a, int b) =>
      a == b ? 'Fret $a' : 'Fret $a–$b';
  String lessonDone(int xp) =>
      _id ? 'Lesson selesai! +$xp XP 🎉' : 'Lesson complete! +$xp XP 🎉';
  String xpGained(int xp) => '+$xp XP 🎉';
  String get aiPressStart => _id
      ? 'Tekan mulai, lalu mainkan chord target — AI memverifikasi tiap chord.'
      : 'Press start, then play the target chord — the AI verifies each one.';
  String aiStrumChord(String chord) => _id
      ? 'Strum chord $chord dengan mantap dan biarkan berbunyi.'
      : 'Strum the $chord chord firmly and let it ring.';
  String get aiListening => _id ? 'mendengarkan' : 'listening';
  String get aiDone => _id ? 'selesai' : 'done';
  String detected(String chord) =>
      _id ? 'Terdeteksi: $chord' : 'Detected: $chord';
  String get startAiPractice =>
      _id ? 'MULAI LATIHAN AI' : 'START AI PRACTICE';
  String get demoLabel => 'demo';
  String get aiIdle => _id ? 'siap' : 'ready';
  String get aiTipClean => _id
      ? 'Tekan senar lebih mantap dan pastikan tiap nada bunyi bersih tanpa buzz.'
      : 'Press the strings more firmly and make sure every note rings without buzzing.';
  String get aiTipTiming => _id
      ? 'Jaga jarak antar strum tetap rata — latih dengan metronome 70 BPM.'
      : 'Keep the gap between strums even — drill it with the metronome at 70 BPM.';
  String get aiTipTransition => _id
      ? 'Perlambat dulu perpindahan jari, lalu naikkan kecepatan bertahap.'
      : 'Slow the finger switch down first, then build speed gradually.';
  String rep(int done, int total) => 'Rep $done/$total';

  // ---------------------------------------------------- daily challenge
  String challengeDesc(String cycle, int n) => _id
      ? 'Mainkan transisi $cycle sebanyak ${n}x tanpa jeda. AI akan menilai '
          'kebersihan tiap chord.'
      : 'Play the $cycle transition ${n}x without stopping. The AI grades '
          'how clean each chord is.';

  // -------------------------------------------------------------- tools
  String get tools => 'Tools';
  String get toolsSubtitle => _id
      ? 'Semua alat bantu latihanmu di satu tempat'
      : 'All your practice tools in one place';
  String get toolTunerDesc => _id
      ? 'Setem 6 senar dengan gauge presisi ±1 cent'
      : 'Tune all 6 strings with a ±1-cent gauge';
  String get toolMetronomeDesc => _id
      ? 'BPM 40–220, tap tempo & drum tracks'
      : 'BPM 40–220, tap tempo & drum tracks';
  String get toolChordLibDesc => _id
      ? '40+ chord — gitar, ukulele & bass'
      : '40+ chords — guitar, ukulele & bass';
  String get toolDetectorDesc => _id
      ? 'AI menebak chord yang kamu mainkan'
      : 'AI names the chord you strum';
  String get toolSongsDesc => _id
      ? 'Chart chord auto-play + slow-downer'
      : 'Auto-playing chord charts + slow-downer';
  String get toolEarDesc => _id
      ? 'Latih telinga: interval, chord & melodi'
      : 'Train your ear: intervals, chords & melody';
  String get toolJamDesc => _id
      ? 'Drum backing track semua genre & tempo'
      : 'Drum backing tracks, every genre & tempo';
  String get toolRecorderDesc => _id
      ? 'Rekam ide riff-mu, AI baca notasinya'
      : 'Record riff ideas, AI reads the notes';

  // -------------------------------------------------------------- tuner
  String get pluckString => _id ? 'Petik senar…' : 'Pluck a string…';
  String get inTuneMsg => _id ? 'Pas! Senar sudah setem' : 'Perfect — in tune!';
  String get slightlySharp =>
      _id ? 'Sedikit tinggi — kendurkan' : 'Slightly sharp — loosen';
  String get slightlyFlat =>
      _id ? 'Sedikit rendah — kencangkan' : 'Slightly flat — tighten';
  String get lockedIn => _id ? 'Terkunci ✓ — senar pas!' : 'Locked ✓ — in tune!';
  String get micOffTap => _id ? 'Mic mati · ketuk' : 'Mic off · tap';
  String get manual => 'Manual';
  String get autoMicActive => _id ? 'Auto · mic aktif' : 'Auto · mic on';
  String get tuningPreset => 'Tuning preset';
  String get liveSound => _id ? 'Suara live' : 'Live sound';
  String get waveform => 'Waveform';
  String get spectrum => _id ? 'Spektrum' : 'Spectrum';

  // ------------------------------------------------------------ profile
  String get achievements => 'Achievements';
  String get level => 'Level';
  String toLevel(int level) =>
      _id ? 'Menuju Level $level' : 'Towards Level $level';
  String get darkMode => _id ? 'Mode gelap' : 'Dark mode';
  String get name => _id ? 'Nama' : 'Name';
  String get myGuitar => _id ? 'Gitar saya' : 'My guitar';
  String get dailyGoal => _id ? 'Goal harian' : 'Daily goal';
  String get practiceReminder =>
      _id ? 'Notifikasi latihan' : 'Practice reminder';
  String get tunerCalibration => _id ? 'Kalibrasi tuner' : 'Tuner calibration';
  String get tuning => 'Tuning';
  String get language => _id ? 'Bahasa' : 'Language';
  String get aboutStrumi => _id ? 'Tentang Strumi' : 'About Strumi';
  String get resetProgress => 'Reset progress';
  String get resetTitle =>
      _id ? 'Reset semua progress?' : 'Reset all progress?';
  String get resetBody => _id
      ? 'XP, streak, lesson, chord dikuasai, dan statistik akan dihapus '
          'permanen. Pengaturan tetap tersimpan.'
      : 'XP, streaks, lessons, mastered chords and stats will be deleted '
          'permanently. Settings are kept.';
  String get reset => 'Reset';
  String get aboutBody => _id
      ? 'Teman belajar gitarmu — tuner presisi, metronome + drum tracks, '
          'chord detector AI, dan learning path adaptif.\n\nSemua audio '
          'disintesis langsung di perangkat; analisis suara berjalan offline.'
      : 'Your guitar-learning buddy — precise tuner, metronome + drum '
          'tracks, AI chord detector and an adaptive learning path.\n\nAll '
          'audio is synthesized on-device; sound analysis runs offline.';
  String get madeWith => _id
      ? 'Strumi 1.2.0 · dibuat dengan Flutter'
      : 'Strumi 1.2.0 · made with Flutter';
  String get profilePhoto => _id ? 'Foto profil' : 'Profile photo';
  String get pickFromGallery =>
      _id ? 'Pilih dari galeri' : 'Choose from gallery';
  String get pickAvatar => _id ? 'Atau pilih avatar' : 'Or pick an avatar';
  String get removePhoto => _id ? 'Hapus foto' : 'Remove photo';

  // -------------------------------------------------------------- songs
  String get songs => 'Songs';
  String get songsSubtitle => _id
      ? 'Semua genre · chart auto-play + slow-downer'
      : 'Every genre · auto-play charts + slow-downer';
  String get lyrics => _id ? 'Lirik' : 'Lyrics';
  String get strumPattern => _id ? 'Pola genjrengan' : 'Strum pattern';
  String get chordsUsed => _id ? 'Chord yang dipakai' : 'Chords used';
  String get playChart => _id ? 'MAINKAN CHART' : 'PLAY CHART';
  String get stopChart => _id ? 'BERHENTI' : 'STOP';
  String ready(int n) => _id ? 'SIAP… $n' : 'READY… $n';
  String get keyWord => _id ? 'Kunci' : 'Key';
  String get transpose => 'Transpose';
  String get loop => 'Loop';
  String get levelEasy => _id ? 'Mudah' : 'Easy';
  String get levelMedium => _id ? 'Sedang' : 'Medium';
  String get levelHard => _id ? 'Sulit' : 'Hard';
  String get genreAll => _id ? 'Semua' : 'All';
  String get downUpHint =>
      _id ? 'D = genjreng bawah · U = atas' : 'D = downstrum · U = upstrum';

  String get stop => _id ? 'BERHENTI' : 'STOP';
  String get back => _id ? 'KEMBALI' : 'BACK';
  String get startChallengeCta =>
      _id ? 'MULAI CHALLENGE' : 'START CHALLENGE';
  String get micNeeded =>
      _id ? 'Izin mikrofon dibutuhkan.' : 'Microphone permission needed.';
  String playTarget(String chord) =>
      _id ? 'Mainkan: $chord' : 'Play: $chord';
  String get avgCleanliness =>
      _id ? 'Rata-rata kebersihan chord: ' : 'Average chord cleanliness: ';
  String get alreadyDoneToday => _id
      ? 'Sudah selesai hari ini ✓ — latihan ulang tidak menambah XP'
      : 'Done for today ✓ — replays don\'t add XP';
  String get pressStartCycle => _id
      ? 'Tekan mulai, lalu mainkan siklus chord-nya'
      : 'Press start, then play the chord cycle';
  String detectedVsTarget(String got, String want) => _id
      ? 'Terdeteksi $got — target $want'
      : 'Detected $got — target $want';
  String get cyclesDone => _id ? 'siklus selesai' : 'cycles done';
  String challengeDone(int xp) => _id
      ? 'Challenge selesai! +$xp XP'
      : 'Challenge complete! +$xp XP';

  // ------------------------------------------------------ chord library
  String get chordLibrary => 'Chord Library';
  String get chordDetector => 'Chord Detector';
  String get detectorBannerDesc => _id
      ? 'Mainkan chord apa pun — AI menebak namanya'
      : 'Play any chord — AI names it';
  String get listen => _id ? 'Dengar' : 'Listen';
  String get checkWithAi => _id ? 'Cek dengan AI' : 'Check with AI';
  String get masteredBadge => _id ? 'Dikuasai ✓' : 'Mastered ✓';
  String get searchChordsHint =>
      _id ? 'Cari chord… (Am, F, Cmaj7)' : 'Search chords… (Am, F, Cmaj7)';
  String get all => _id ? 'Semua' : 'All';
  String get favorites => _id ? 'Favorit' : 'Favorites';
  String get noFavorites => _id
      ? 'Belum ada chord favorit — bintangi dari kartu detail.'
      : 'No favorite chords yet — star one from the detail card.';
  String get noMatches =>
      _id ? 'Tidak ada chord yang cocok.' : 'No matching chords.';
  String get instrumentGuitar => _id ? 'Gitar' : 'Guitar';
  String get instrumentUkulele => 'Ukulele';
  String get instrumentBass => 'Bass';

  // ----------------------------------------------------- chord detector
  String get aiListeningEllipsis =>
      _id ? 'AI mendengarkan…' : 'AI is listening…';
  String get noSignalYet => _id
      ? 'Belum ada sinyal — strum chord-mu.'
      : 'No signal yet — strum a chord.';
  String get topCandidates => _id ? 'Kandidat teratas' : 'Top candidates';
  String get playOneChord =>
      _id ? 'Mainkan satu chord dan tahan' : 'Play one chord and hold it';
  String get micOffTapAllow => _id
      ? 'Mic mati — ketuk untuk izinkan'
      : 'Mic off — tap to allow';
  String get chromagram =>
      _id ? 'Spektrum nada (chromagram)' : 'Pitch spectrum (chromagram)';
  String confidence(int pct) =>
      _id ? 'keyakinan $pct%' : '$pct% confidence';
  String chordVerified(String name) => _id
      ? '+15 XP — chord $name diverifikasi! 🎸'
      : '+15 XP — $name chord verified! 🎸';
  String masteredCount(int n, int total) =>
      _id ? 'Chord dikuasai: $n/$total' : 'Chords mastered: $n/$total';

  // ------------------------------------------------------- ear training
  String get earTitle => 'Ear Training';
  String get earSubtitle => _id
      ? 'Latih telinga: interval & kualitas chord'
      : 'Train your ear: intervals & chord quality';
  String get interval => 'Interval';
  String get chordQuality => _id ? 'Kualitas chord' : 'Chord quality';
  String get hardMode => _id ? '🔥 Sulit' : '🔥 Hard';
  String get correct => _id ? 'Benar' : 'Right';
  String get wrongLabel => _id ? 'Salah' : 'Wrong';
  String get streakLabel => 'Streak';
  String get bestLabel => _id ? 'Terbaik' : 'Best';
  String get playAgain => _id ? 'putar lagi' : 'play again';
  String get intervalQuestion => _id
      ? 'Dua nada dimainkan berurutan.\nInterval apa itu?'
      : 'Two notes played in a row.\nWhich interval is it?';
  String get qualityQuestion => _id
      ? 'Satu chord di-strum.\nApa kualitasnya?'
      : 'One chord is strummed.\nWhat is its quality?';
  String get earXp =>
      _id ? '+25 XP — telinga makin tajam! 👂' : '+25 XP — sharper ears! 👂';

  // ---------------------------------------------------------- metronome
  String get drumBackingTrack => 'Drum backing track';
  String get clickOnly => _id ? 'Klik saja' : 'Click only';
  String get bpmLabel => 'BPM';
  String get tapTempo => _id ? 'TAP TEMPO' : 'TAP TEMPO';
  String tempoName(String base) => switch (base) {
        'Largo' => _id ? 'Largo — sangat lambat' : 'Largo — very slow',
        'Adagio' => _id ? 'Adagio — lambat' : 'Adagio — slow',
        'Andante' => _id ? 'Andante — sedang' : 'Andante — walking pace',
        'Moderato' => 'Moderato',
        'Allegro' => _id ? 'Allegro — cepat' : 'Allegro — fast',
        _ => _id ? 'Presto — sangat cepat' : 'Presto — very fast',
      };

  // ------------------------------------------------------ riff recorder
  String get riffRecorder => 'Riff Recorder';
  String get riffSubtitle => _id
      ? 'Rekam ide riff-mu — AI membaca nadanya'
      : 'Record your riff ideas — AI reads the notes';
  String get tapToRecord =>
      _id ? 'Ketuk untuk mulai merekam' : 'Tap to start recording';
  String get riffSaved => _id ? 'Riff tersimpan! 🎸' : 'Riff saved! 🎸';
  String get noRecordings => _id
      ? 'Belum ada rekaman. Riff pertamamu menunggu!'
      : 'No recordings yet. Your first riff awaits!';
  String get deleteRiffTitle => _id ? 'Hapus riff?' : 'Delete riff?';
  String get deleteRiffBody => _id
      ? 'Rekaman ini akan dihapus permanen.'
      : 'This recording will be deleted permanently.';
  String get delete => _id ? 'Hapus' : 'Delete';
  String get aiAnalysis => _id ? 'Analisis AI' : 'AI analysis';
  String notesDetected(int n) =>
      _id ? 'Terdeteksi $n nada:' : '$n notes detected:';
  String get noClearNotes => _id
      ? 'Tidak ada nada jelas terdeteksi — coba rekam lebih dekat ke gitar.'
      : 'No clear notes detected — try recording closer to the guitar.';
  String riffN(int n) => 'Riff $n';
  String get savedRiffs => _id ? 'Riff tersimpan' : 'Saved riffs';
  String get categorySong => _id ? 'Lagu' : 'Song';
  String get categoryRecording => _id ? 'Rekaman' : 'Recording';
  String get chordChanges => 'Chord changes';
  String get strumming => 'Strumming';
  String get fingerpicking => 'Fingerpicking';

  // -------------------------------------------------------------- stats
  String get practiceStats => _id ? 'Statistik Latihan' : 'Practice Stats';
  String get thisWeek => _id ? 'Minggu ini' : 'This week';
  String get avgAccuracy => _id ? 'Akurasi rata-rata' : 'Average accuracy';
  String get totalHours => _id ? 'Total jam latihan' : 'Total practice time';
  String get skillBreakdown => 'Skill breakdown';
  String get practiceFocus => _id ? 'Fokus latihanmu' : 'Your practice focus';
  String get noDataYet => _id
      ? 'Belum ada data — mulai dari tuner atau lesson pertamamu.'
      : 'No data yet — start with the tuner or your first lesson.';
  String get noAiData => _id ? 'Belum ada data AI' : 'No AI data yet';
  String get earlyData => _id ? 'Data awal terkumpul' : 'Early data coming in';
  String get noPracticeThisWeek =>
      _id ? 'Belum ada latihan minggu ini' : 'No practice yet this week';
  String get firstActiveWeek => _id
      ? 'Minggu aktif pertamamu — semangat!'
      : 'Your first active week — keep going!';
  String upFromLastWeek(int pct) =>
      _id ? '▲ $pct% dari minggu lalu' : '▲ $pct% vs last week';
  String downFromLastWeek(int pct) =>
      _id ? '▼ $pct% dari minggu lalu' : '▼ $pct% vs last week';
  String upPoints(int n) => _id ? '▲ $n poin — membaik' : '▲ $n pts — improving';
  String downPoints(int n) => _id ? '▼ $n poin' : '▼ $n pts';
  String get musicTheory => _id ? 'Teori musik' : 'Music theory';
  String get minutesShort => _id ? 'mnt' : 'min';
  List<String> get monthsShort => _id
      ? const ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
              'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des']
      : const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  // --------------------------------------------------------- onboarding
  String get skip => 'Skip';
  String get onboardTitle => _id
      ? 'Dari chord pertama sampai solo di panggung'
      : 'From your first chord to solos on stage';
  String get onboardBody => _id
      ? 'Learning path adaptif, tuner & metronome presisi, plus AI yang '
          'mendengar permainanmu dan memberi feedback real-time.'
      : 'An adaptive learning path, precise tuner & metronome, plus AI '
          'that listens to your playing and gives real-time feedback.';
  String get whatsYourName => _id ? 'Siapa namamu?' : "What's your name?";
  String get startLearning => _id ? 'MULAI BELAJAR' : 'START LEARNING';
}

/// Inherited scope so any widget can read `S.of(context)` / `context.s`.
class StringsScope extends InheritedWidget {
  const StringsScope({super.key, required this.strings, required super.child});

  final S strings;

  @override
  bool updateShouldNotify(StringsScope oldWidget) =>
      oldWidget.strings.lang != strings.lang;
}

extension StringsX on BuildContext {
  S get s => S.of(this);
}
