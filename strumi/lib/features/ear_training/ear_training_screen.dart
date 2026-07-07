import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../core/audio/sound_bank.dart';
import '../../core/music/chords.dart';
import '../../core/utils/practice_clock.dart';
import '../../data/models/progress_state.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/pill_chip.dart';
import '../../widgets/screen_scaffold.dart';

enum _Mode { interval, chordQuality }

const _intervals = [
  ('Sekon minor', 1),
  ('Sekon mayor', 2),
  ('Terts minor', 3),
  ('Terts mayor', 4),
  ('Kuart murni', 5),
  ('Kuint murni', 7),
  ('Oktaf', 12),
];

/// Extra intervals mixed in when "Mode sulit" is on.
const _hardIntervals = [
  ('Triton', 6),
  ('Sekst minor', 8),
  ('Sekst mayor', 9),
  ('Septim minor', 10),
  ('Septim mayor', 11),
];

const _qualityOptions = ['Mayor', 'Minor', 'Dominant 7', 'Maj7'];

/// Ear training: interval and chord-quality quizzes with synthesized
/// guitar sounds, streak tracking, and XP rewards.
class EarTrainingScreen extends ConsumerStatefulWidget {
  const EarTrainingScreen({super.key});

  @override
  ConsumerState<EarTrainingScreen> createState() =>
      _EarTrainingScreenState();
}

class _EarTrainingScreenState extends ConsumerState<EarTrainingScreen> {
  final math.Random _random = math.Random();
  late final SoundBank _soundBank;
  late final PracticeClock _clock;

  _Mode _mode = _Mode.interval;
  bool _hard = false;
  int _correct = 0;
  int _wrong = 0;
  int _streak = 0;

  List<(String, int)> get _intervalPool =>
      _hard ? [..._intervals, ..._hardIntervals] : _intervals;

  // Current question.
  List<String> _options = const [];
  String _answer = '';
  String? _picked;

  // Interval question data.
  int _rootMidi = 57;
  int _semitones = 4;

  // Chord question data.
  ChordShape? _questionChord;

  @override
  void initState() {
    super.initState();
    _soundBank = ref.read(soundBankProvider);
    final progress = ref.read(progressProvider.notifier);
    _clock = PracticeClock(
        (s) => progress.addPracticeSeconds(PracticeCategory.earTraining, s));
    _nextQuestion();
  }

  @override
  void dispose() {
    _clock.commit();
    super.dispose();
  }

  /// Chords with an unambiguous quality for the quiz.
  static final List<(ChordShape, String)> _qualityPool = [
    for (final chord in kChordCatalog)
      if (_qualityOf(chord) != null) (chord, _qualityOf(chord)!),
  ];

  static String? _qualityOf(ChordShape chord) {
    final name = chord.name;
    if (name == 'Asus2' || name == 'Cadd9') return null;
    if (name.endsWith('maj7')) return 'Maj7';
    if (name.endsWith('m7')) return null; // minor 7th — ambiguous for 4 opts
    if (name.endsWith('7')) return 'Dominant 7';
    if (chord.isMinor) return 'Minor';
    return 'Mayor';
  }

  void _nextQuestion() {
    _picked = null;
    if (_mode == _Mode.interval) {
      final pool = _intervalPool;
      _rootMidi = 48 + _random.nextInt(17);
      final interval = pool[_random.nextInt(pool.length)];
      _answer = interval.$1;
      _semitones = interval.$2;
      final wrong = [...pool.map((i) => i.$1)]
        ..remove(_answer)
        ..shuffle(_random);
      _options = ([_answer, ...wrong.take(3)]..shuffle(_random));
    } else {
      final pick = _qualityPool[_random.nextInt(_qualityPool.length)];
      _questionChord = pick.$1;
      _answer = pick.$2;
      _options = _qualityOptions;
    }
    setState(() {});
    _playQuestion();
  }

  void _playQuestion() {
    if (_mode == _Mode.interval) {
      final a4 = ref.read(settingsProvider).a4Calibration;
      unawaited(_soundBank.playPluck(_rootMidi, a4: a4));
      Timer(const Duration(milliseconds: 650), () {
        if (mounted) {
          unawaited(_soundBank.playPluck(_rootMidi + _semitones, a4: a4));
        }
      });
    } else if (_questionChord != null) {
      final a4 = ref.read(settingsProvider).a4Calibration;
      unawaited(_soundBank.playStrum(_questionChord!.midiNotes, a4: a4));
    }
  }

  void _pick(String option) {
    if (_picked != null) return;
    setState(() => _picked = option);
    final progress = ref.read(progressProvider.notifier);
    if (option == _answer) {
      _correct++;
      _streak++;
      progress.reportEarStreak(_streak);
      if (_correct % 10 == 0) {
        progress.awardXp(25);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
              content: Text('+25 XP — telinga makin tajam! 👂')));
      }
    } else {
      _wrong++;
      _streak = 0;
    }
    Timer(const Duration(milliseconds: 950), () {
      if (mounted) _nextQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final best = ref.watch(progressProvider).bestEarStreak;

    return ScreenScaffold(
      gap: 16,
      children: [
        const SubScreenHeader(title: 'Ear Training'),
        Text(
          'Latih telinga: interval & kualitas chord',
          style: TextStyle(fontSize: 13, color: AppColors.creamDim),
        ),
        Row(
          children: [
            PillChip(
              label: 'Interval',
              selected: _mode == _Mode.interval,
              onTap: () {
                if (_mode != _Mode.interval) {
                  _mode = _Mode.interval;
                  _nextQuestion();
                }
              },
              horizontalPadding: 18,
              fontSize: 13,
            ),
            const SizedBox(width: 8),
            PillChip(
              label: 'Kualitas chord',
              selected: _mode == _Mode.chordQuality,
              onTap: () {
                if (_mode != _Mode.chordQuality) {
                  _mode = _Mode.chordQuality;
                  _nextQuestion();
                }
              },
              horizontalPadding: 18,
              fontSize: 13,
            ),
            const Spacer(),
            if (_mode == _Mode.interval)
              PillChip(
                label: '🔥 Sulit',
                selected: _hard,
                onTap: () {
                  _hard = !_hard;
                  _nextQuestion();
                },
                fontSize: 12,
              ),
          ],
        ),

        // ------------------------------------------------ scoreboard
        GlassCard(
          radius: 22,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(label: 'Benar', value: '$_correct',
                  color: AppColors.green),
              _Stat(label: 'Salah', value: '$_wrong', color: AppColors.red),
              _Stat(
                  label: 'Streak',
                  value: '$_streak',
                  color: AppColors.orangeLight),
              _Stat(label: 'Terbaik', value: '$best', color: AppColors.blue),
            ],
          ),
        ),

        // ------------------------------------------------ question card
        GlassCard(
          radius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                _mode == _Mode.interval
                    ? 'Dua nada dimainkan berurutan.\nInterval apa itu?'
                    : 'Satu chord di-strum.\nApa kualitasnya?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.cream.withValues(alpha: 0.75)),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: _playQuestion,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orangeGradientBottom
                            .withValues(alpha: 0.4),
                        blurRadius: 26,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.volume_up_rounded,
                      color: AppColors.onOrange, size: 30),
                ),
              ),
              const SizedBox(height: 8),
              Text('putar lagi',
                  style:
                      TextStyle(fontSize: 11, color: AppColors.creamFaint)),
            ],
          ),
        ),

        // ------------------------------------------------ options
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.9,
          children: [
            for (final option in _options)
              _OptionButton(
                label: option,
                state: _picked == null
                    ? _OptionState.idle
                    : option == _answer
                        ? _OptionState.correct
                        : option == _picked
                            ? _OptionState.wrong
                            : _OptionState.dimmed,
                onTap: () => _pick(option),
              ),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(fontSize: 11, color: AppColors.creamDim)),
      ],
    );
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (fill, border, text) = switch (state) {
      _OptionState.idle => (
          AppColors.cardFill,
          AppColors.cardBorder,
          AppColors.cream,
        ),
      _OptionState.correct => (
          AppColors.green.withValues(alpha: 0.2),
          AppColors.green,
          AppColors.green,
        ),
      _OptionState.wrong => (
          AppColors.red.withValues(alpha: 0.2),
          AppColors.red,
          AppColors.red,
        ),
      _OptionState.dimmed => (
          AppColors.cardFill,
          AppColors.cardBorder,
          AppColors.creamFaint,
        ),
    };
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: text),
        ),
      ),
    );
  }
}
