import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_palette.dart';
import '../../core/i18n/strings.dart';
import '../../core/audio/chord_listener.dart';
import '../../core/audio/sound_bank.dart';
import '../../core/dsp/chroma.dart';
import '../../core/music/chords.dart';
import '../../core/utils/practice_clock.dart';
import '../../data/catalogs/challenges_catalog.dart';
import '../../data/models/progress_state.dart';
import '../../providers/app_providers.dart';
import '../../widgets/celebration.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_scaffold.dart';
import '../chords/widgets/chord_diagram.dart';

/// Daily challenge: the AI counts real chord-transition cycles heard
/// through the microphone and awards XP on completion.
class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState
    extends ConsumerState<DailyChallengeScreen> {
  late final DailyChallenge _challenge = challengeForToday();
  late final ChordListener _listener;
  late final ProgressNotifier _progress;
  late final SoundBank _soundBank;
  late final PracticeClock _clock;

  bool _running = false;
  bool _finished = false;
  int _cycles = 0;
  int _stepInCycle = 0;
  String? _wrongChord;
  final List<double> _scores = [];

  String get _targetChord => _challenge.chords[_stepInCycle];

  @override
  void initState() {
    super.initState();
    _progress = ref.read(progressProvider.notifier);
    _soundBank = ref.read(soundBankProvider);
    _clock = PracticeClock(
        (s) => _progress.addPracticeSeconds(PracticeCategory.challenge, s));
    _listener = ChordListener(
      ref.read(micServiceProvider),
      onStable: _onChord,
    );
  }

  @override
  void dispose() {
    _clock.commit();
    unawaited(_listener.stop());
    super.dispose();
  }

  void _onChord(ChordMatch match) {
    if (!_running || !mounted) return;
    if (match.chord.name != _targetChord) {
      setState(() => _wrongChord = match.chord.name);
      return;
    }
    _scores.add(match.score * 100);
    _soundBank.playDrum(DrumSample.clickHi, volume: 0.5);
    setState(() {
      _wrongChord = null;
      if (_stepInCycle + 1 < _challenge.chords.length) {
        _stepInCycle++;
      } else {
        _stepInCycle = 0;
        _cycles++;
      }
    });
    if (_cycles >= _challenge.targetCycles) unawaited(_finish());
  }

  Future<void> _finish() async {
    setState(() {
      _running = false;
      _finished = true;
    });
    await _listener.stop();
    _progress.completeChallengeToday(xp: _challenge.xp);
    if (_scores.isNotEmpty) {
      _progress
          .logAccuracy(_scores.reduce((a, b) => a + b) / _scores.length);
    }
    if (mounted) Celebration.show(context);
  }

  Future<void> _toggle() async {
    if (_running) {
      await _listener.stop();
      setState(() => _running = false);
      return;
    }
    final ok = await _listener.start();
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.s.micNeeded)));
      }
      return;
    }
    setState(() {
      _running = true;
      _finished = false;
      _cycles = 0;
      _stepInCycle = 0;
      _scores.clear();
      _wrongChord = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final doneToday = ref.watch(progressProvider).challengeDoneToday;

    return ScreenScaffold(
      gap: 16,
      children: [
        SubScreenHeader(
          overline: 'Daily Challenge · +${_challenge.xp} XP',
          title: _challenge.title,
        ),
        if (doneToday && !_finished)
          GlassCard(
            radius: 18,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: context.colors.green.withValues(alpha: 0.4),
            child: Text(
              context.s.alreadyDoneToday,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.colors.green),
            ),
          ),
        GlassCard(
          radius: 22,
          child: Text(
            context.s
                .challengeDesc(_challenge.title, _challenge.targetCycles),
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: context.colors.cream.withValues(alpha: 0.65),
            ),
          ),
        ),

        // ------------------------------------------------ the three chords
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _challenge.chords.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: _chordCard(i)),
              ],
            ],
          ),
        ),

        // ------------------------------------------------ progress / result
        if (_finished)
          GlassCard(
            radius: 24,
            padding: const EdgeInsets.all(26),
            border: context.colors.yellowDeep.withValues(alpha: 0.45),
            child: Column(
              children: [
                Transform.rotate(
                  angle: 0.785,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: context.colors.yellowDeep,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  context.s.challengeDone(_challenge.xp),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  '${context.s.avgCleanliness}'
                  '${_scores.isEmpty ? 0 : (_scores.reduce((a, b) => a + b) / _scores.length).round()}%',
                  style:
                      TextStyle(fontSize: 12, color: context.colors.creamDim),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: context.s.back,
                  height: 46,
                  fontSize: 13,
                  onTap: () => context.pop(),
                ),
              ],
            ),
          )
        else
          GlassCard(
            radius: 24,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  '$_cycles/${_challenge.targetCycles}',
                  style: const TextStyle(
                      fontSize: 44, fontWeight: FontWeight.w800, height: 1),
                ),
                const SizedBox(height: 4),
                Text(context.s.cyclesDone,
                    style: TextStyle(
                        fontSize: 11, color: context.colors.creamDim)),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _cycles / _challenge.targetCycles,
                    minHeight: 8,
                    backgroundColor: context.colors.cream.withValues(alpha: 0.1),
                    valueColor:
                        AlwaysStoppedAnimation(context.colors.orange),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  !_running
                      ? context.s.pressStartCycle
                      : _wrongChord != null
                          ? context.s.detectedVsTarget(_wrongChord ?? '', _targetChord)
                          : context.s.playTarget(_targetChord),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _wrongChord != null
                        ? context.colors.orangeLight
                        : context.colors.blue,
                  ),
                ),
              ],
            ),
          ),

        if (!_finished)
          PrimaryButton(
            label: _running ? context.s.stop : context.s.startChallengeCta,
            onTap: () => unawaited(_toggle()),
          ),
      ],
    );
  }

  Widget _chordCard(int index) {
    final name = _challenge.chords[index];
    final isTarget = _running && index == _stepInCycle;
    final isDone = _running && index < _stepInCycle;

    final Color border;
    Color? fill;
    if (isTarget) {
      border = context.colors.cardBorderActive;
      fill = context.colors.orange.withValues(alpha: 0.10);
    } else if (isDone) {
      border = context.colors.green.withValues(alpha: 0.45);
    } else {
      border = context.colors.cardBorder;
    }

    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(vertical: 14),
      border: border,
      fill: fill,
      child: Column(
        children: [
          ChordDiagram(chord: chordByName(name), width: 86, height: 102),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800)),
              if (isDone) ...[
                const SizedBox(width: 4),
                Icon(Icons.check_rounded,
                    size: 14, color: context.colors.green),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
