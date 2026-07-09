import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_palette.dart';
import '../../core/audio/sound_bank.dart';
import '../../core/i18n/strings.dart';
import '../../core/music/chords.dart';
import '../../core/utils/practice_clock.dart';
import '../../data/models/progress_state.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/pill_chip.dart';
import '../../widgets/screen_scaffold.dart';

enum _Mode { interval, chordQuality }

// Canonical (English) identifiers used for answer comparison; localized
// for display via [_intervalLabel] / [_qualityLabel].
const _intervals = [
  ('Minor 2nd', 1),
  ('Major 2nd', 2),
  ('Minor 3rd', 3),
  ('Major 3rd', 4),
  ('Perfect 4th', 5),
  ('Perfect 5th', 7),
  ('Octave', 12),
];

/// Extra intervals mixed in when hard mode is on.
const _hardIntervals = [
  ('Tritone', 6),
  ('Minor 6th', 8),
  ('Major 6th', 9),
  ('Minor 7th', 10),
  ('Major 7th', 11),
];

const _qualityOptions = ['Major', 'Minor', 'Dominant 7', 'Maj7'];

const _intervalLabelsId = {
  'Minor 2nd': 'Sekon minor',
  'Major 2nd': 'Sekon mayor',
  'Minor 3rd': 'Terts minor',
  'Major 3rd': 'Terts mayor',
  'Perfect 4th': 'Kuart murni',
  'Perfect 5th': 'Kuint murni',
  'Octave': 'Oktaf',
  'Tritone': 'Triton',
  'Minor 6th': 'Sekst minor',
  'Major 6th': 'Sekst mayor',
  'Minor 7th': 'Septim minor',
  'Major 7th': 'Septim mayor',
};

const _qualityLabelsId = {
  'Major': 'Mayor',
  'Minor': 'Minor',
  'Dominant 7': 'Dominant 7',
  'Maj7': 'Maj7',
};

String _intervalLabel(String canonical, String lang) =>
    lang == 'id' ? (_intervalLabelsId[canonical] ?? canonical) : canonical;

String _qualityLabel(String canonical, String lang) =>
    lang == 'id' ? (_qualityLabelsId[canonical] ?? canonical) : canonical;

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
    for (final chord in kGuitarChords)
      if (_qualityOf(chord) != null) (chord, _qualityOf(chord)!),
  ];

  static String? _qualityOf(ChordShape chord) {
    final name = chord.name;
    if (name == 'Asus2' || name == 'Cadd9') return null;
    if (name.endsWith('maj7')) return 'Maj7';
    if (name.endsWith('m7')) return null; // minor 7th — ambiguous for 4 opts
    if (name.endsWith('7')) return 'Dominant 7';
    if (chord.isMinor) return 'Minor';
    return 'Major';
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
    final s = context.s;
    final best = ref.watch(progressProvider).bestEarStreak;

    return ScreenScaffold(
      gap: 16,
      children: [
        SubScreenHeader(title: s.earTitle),
        Text(
          s.earSubtitle,
          style: TextStyle(fontSize: 13, color: context.colors.creamDim),
        ),
        Row(
          children: [
            PillChip(
              label: s.interval,
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
              label: s.chordQuality,
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
                label: s.hardMode,
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
              _Stat(label: s.correct, value: '$_correct',
                  color: context.colors.green),
              _Stat(label: s.wrongLabel, value: '$_wrong',
                  color: context.colors.red),
              _Stat(
                  label: s.streakLabel,
                  value: '$_streak',
                  color: context.colors.orangeLight),
              _Stat(label: s.bestLabel, value: '$best',
                  color: context.colors.blue),
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
                    ? s.intervalQuestion
                    : s.qualityQuestion,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: context.colors.cream.withValues(alpha: 0.75)),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: _playQuestion,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: context.colors.buttonGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.orangeGradientBottom
                            .withValues(alpha: 0.4),
                        blurRadius: 26,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(Icons.volume_up_rounded,
                      color: context.colors.onOrange, size: 30),
                ),
              ),
              const SizedBox(height: 8),
              Text(s.playAgain,
                  style:
                      TextStyle(fontSize: 11, color: context.colors.creamFaint)),
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
                label: _mode == _Mode.interval
                    ? _intervalLabel(option, s.lang)
                    : _qualityLabel(option, s.lang),
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
            style: TextStyle(fontSize: 11, color: context.colors.creamDim)),
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
          context.colors.cardFill,
          context.colors.cardBorder,
          context.colors.cream,
        ),
      _OptionState.correct => (
          context.colors.green.withValues(alpha: 0.2),
          context.colors.green,
          context.colors.green,
        ),
      _OptionState.wrong => (
          context.colors.red.withValues(alpha: 0.2),
          context.colors.red,
          context.colors.red,
        ),
      _OptionState.dimmed => (
          context.colors.cardFill,
          context.colors.cardBorder,
          context.colors.creamFaint,
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
