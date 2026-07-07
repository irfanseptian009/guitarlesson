# 🎸 Strumi

Aplikasi belajar gitar untuk Android & iOS, dibangun dengan **Flutter 3.44**.
Diimplementasikan dari desain "GuitarMaster App" (Claude Design handoff) —
dark theme, aksen oranye `#F9772E`, typeface Sora.

> Semua fitur di bawah **berfungsi nyata** — tanpa mock. Audio disintesis
> saat runtime (Karplus-Strong & synthesis drum), analisis suara berjalan
> on-device, dan tidak ada satu pun aset audio berhak-cipta.

## Fitur

| Fitur | Teknologi di baliknya |
|---|---|
| **Tuner presisi** | Mikrofon → deteksi pitch YIN (implementasi sendiri), kalibrasi A4 432–446 Hz, 4 preset tuning, nada referensi per senar, **hold-to-confirm** (tahan 1,2 dtk di zona hijau → terkunci + chime, mode manual auto-lanjut ke senar berikutnya) |
| **Metronome + drum tracks** | Scheduler drift-corrected 40–220 BPM, tap tempo, 2/4 · 3/4 · 4/4 · 6/8, 5 pola drum tersintesis, **pendulum animasi**, timer sesi, pengaturan terakhir tersimpan |
| **Chord Library** | 26 voicing dengan diagram jari, **pencarian + filter level + favorit (★)**, tips fingering, preview strum |
| **Chord Detector (AI)** | FFT 8192-titik → chromagram 12-bin → template matching; **visualisasi chromagram live** (12 bar nada, chord-tone disorot); deteksi meyakinkan menandai chord "dikuasai" (+XP) |
| **Learning Path** | 13 lesson (Beginner/Intermediate/Advanced), unlock berurutan, progress + **skor terbaik** per lesson |
| **Lesson Player + AI Feedback** | AI memverifikasi tiap strum lewat mic; skor Kebersihan / Timing / Transisi dari data asli; tab interaktif + slow-downer; **confetti** saat selesai |
| **Daily Challenge** | Drill transisi chord dirotasi per tanggal; AI menghitung siklus yang benar; +50 XP + perayaan |
| **Songs** | 8 chart lagu dengan chart player: metronome menggerakkan bar, chord di-strum otomatis, auto-scroll, slow-downer, **count-in 1 bar, loop, dan transpose ±6 semitone** (audio ikut ter-transpose) |
| **Ear Training** | Kuis interval & kualitas chord, **mode sulit** (triton, sekst, septim), streak + XP |
| **Riff Recorder** | Rekam WAV dengan **level meter live**, playback, hapus, analisis AI offline (urutan nada) |
| **Statistik** | Grafik bar mingguan, total jam, akurasi, skill breakdown, **donat "Fokus latihanmu"** per kategori |
| **Profil & Gamifikasi** | Level + XP, **9 achievement** dengan kondisi hidup + **overlay perayaan otomatis saat terbuka**, reset progress, tentang aplikasi |
| **Pengingat harian** | Notifikasi lokal terjadwal (flutter_local_notifications + timezone) |

### Rasa premium
Animasi entrance berjenjang di tiap layar, efek tekan + haptic di semua elemen
interaktif, transisi halaman fade-slide, angka statistik menghitung naik,
confetti perayaan, dan snackbar yang tak menutupi navigasi.

## Arsitektur

```
lib/
├── app/            # MaterialApp, router (go_router), tema (token desain)
├── core/
│   ├── audio/      # Synthesizer, SoundBank, MicService, MetronomeEngine,
│   │               # ChordListener, WavCodec
│   ├── dsp/        # FFT, YIN pitch detection, chromagram (murni Dart)
│   ├── music/      # Teori nada, tuning, katalog chord
│   ├── services/   # ReminderService (notifikasi)
│   └── utils/      # Dates, PracticeClock
├── data/
│   ├── models/     # AppSettings, ProgressState, Lesson, Song
│   └── catalogs/   # Lessons, songs, achievements, challenges
├── providers/      # Riverpod Notifier + persistence (shared_preferences)
├── features/       # 1 folder per layar (16 layar)
└── widgets/        # GlassCard, PillChip, PrimaryButton, ProgressRing, ...
```

- **State**: flutter_riverpod 3 (Notifier), persist otomatis ke SharedPreferences (JSON).
- **Navigasi**: go_router 17, `StatefulShellRoute` 5 tab + bottom-nav mengambang custom.
- **DSP tanpa dependensi native**: FFT radix-2, YIN, dan chromagram ditulis sendiri di Dart murni — teruji unit test.
- **Audio tanpa aset**: semua bunyi (klik, drum kit, petikan & strum gitar) disintesis saat runtime lalu di-cache sebagai WAV.

## Menjalankan

```bash
cd strumi
flutter pub get
flutter run            # perangkat Android (izinkan mikrofon saat diminta)
flutter build apk      # build/app/outputs/flutter-apk/app-release.apk
flutter test           # 24 unit & widget test
```

> **Catatan izin**: Tuner, Chord Detector, AI Feedback, Challenge, dan
> Recorder memerlukan mikrofon. iOS: deskripsi izin sudah ada di
> `Info.plist`; Android: `RECORD_AUDIO` + `POST_NOTIFICATIONS` di manifest.

## Kualitas

- `flutter analyze` — 0 issue (flutter_lints).
- `flutter test` — 26/26 lolos, termasuk test DSP (sinus 220 Hz → 220±1.5 Hz;
  strum Am tersintesis → terdeteksi Am), transpose, dan streak/level.
