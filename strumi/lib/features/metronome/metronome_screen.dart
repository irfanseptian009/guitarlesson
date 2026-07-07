import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../core/audio/metronome_engine.dart';
import '../../core/utils/practice_clock.dart';
import '../../data/models/progress_state.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/screen_scaffold.dart';

/// Metronome with synthesized click + drum backing patterns, tap tempo,
/// and time-signature support (40–220 BPM).
class MetronomeScreen extends ConsumerStatefulWidget {
  const MetronomeScreen({super.key});

  @override
  ConsumerState<MetronomeScreen> createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends ConsumerState<MetronomeScreen> {
  late final MetronomeEngine _engine;
  late final PracticeClock _clock;
  int _beat = -1;

  /// Seconds the metronome has been running this session.
  int _elapsedSeconds = 0;
  Timer? _elapsedTimer;

  @override
  void initState() {
    super.initState();
    _engine = MetronomeEngine(
      ref.read(soundBankProvider),
      onBeat: (beat) {
        if (mounted) setState(() => _beat = beat);
      },
    );
    // Restore the last-used metronome state.
    final settings = ref.read(settingsProvider);
    _engine
      ..bpm = settings.metronomeBpm
      ..signature = TimeSignature.values[settings.metronomeSignatureIndex
          .clamp(0, TimeSignature.values.length - 1)]
      ..style = DrumStyle.values[settings.metronomeStyleIndex
          .clamp(0, DrumStyle.values.length - 1)];
    final progress = ref.read(progressProvider.notifier);
    _clock = PracticeClock(
        (s) => progress.addPracticeSeconds(PracticeCategory.metronome, s));
  }

  @override
  void dispose() {
    _clock.commit();
    _elapsedTimer?.cancel();
    _engine.dispose();
    super.dispose();
  }

  void _persist() {
    ref.read(settingsProvider.notifier).update((s) => s.copyWith(
          metronomeBpm: _engine.bpm,
          metronomeSignatureIndex:
              TimeSignature.values.indexOf(_engine.signature),
          metronomeStyleIndex: DrumStyle.values.indexOf(_engine.style),
        ));
  }

  void _togglePlay() {
    setState(() {
      if (_engine.isPlaying) {
        _engine.stop();
        _beat = -1;
        _elapsedTimer?.cancel();
      } else {
        _engine.start();
        _elapsedSeconds = 0;
        _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() => _elapsedSeconds++);
        });
      }
    });
    _persist();
  }

  String get _tempoName => switch (_engine.bpm) {
        < 60 => 'Largo — sangat lambat',
        < 76 => 'Adagio — lambat',
        < 108 => 'Andante — sedang',
        < 132 => 'Moderato',
        < 168 => 'Allegro — cepat',
        _ => 'Presto — sangat cepat',
      };

  void _setBpm(int bpm) => setState(() => _engine.bpm = bpm);

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      children: [
        const SubScreenHeader(title: 'Metronome'),

        // ------------------------------------------------ main card
        GlassCard(
          radius: 26,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Column(
            children: [
              _Pendulum(
                playing: _engine.isPlaying,
                beat: _beat,
                bpm: _engine.bpm,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${_engine.bpm}',
                      style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w800,
                          height: 1)),
                  const SizedBox(width: 8),
                  Text(
                    'BPM',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _engine.isPlaying
                    ? '$_tempoName · '
                        '${(_elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:'
                        '${(_elapsedSeconds % 60).toString().padLeft(2, '0')}'
                    : _tempoName,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.orangeLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _RoundStepButton(
                      label: '−', onTap: () => _setBpm(_engine.bpm - 1)),
                  Expanded(
                    child: Slider(
                      min: MetronomeEngine.minBpm.toDouble(),
                      max: MetronomeEngine.maxBpm.toDouble(),
                      value: _engine.bpm.toDouble(),
                      onChanged: (v) => _setBpm(v.round()),
                      onChangeEnd: (_) => _persist(),
                    ),
                  ),
                  _RoundStepButton(
                      label: '+', onTap: () => _setBpm(_engine.bpm + 1)),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _engine.signature.beats; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _engine.isPlaying && _beat == i
                            ? (i == 0 ? AppColors.orange : AppColors.blue)
                            : Colors.white.withValues(alpha: 0.12),
                        boxShadow: _engine.isPlaying && _beat == i && i == 0
                            ? [
                                BoxShadow(
                                  color: AppColors.orange
                                      .withValues(alpha: 0.6),
                                  blurRadius: 12,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        gradient: AppColors.buttonGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orangeGradientBottom
                                .withValues(alpha: 0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Icon(
                        _engine.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.onOrange,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      final bpm = _engine.tap();
                      if (bpm != null) setState(() {});
                    },
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(23),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18)),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'TAP TEMPO',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ------------------------------------------------ time signatures
        Row(
          children: [
            for (final signature in TimeSignature.values) ...[
              if (signature != TimeSignature.values.first)
                const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _engine.signature = signature;
                      _beat = -1;
                    });
                    _persist();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: _engine.signature == signature
                          ? AppColors.cardFillActive
                          : AppColors.cardFill,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _engine.signature == signature
                            ? AppColors.cardBorderActive
                            : AppColors.cardBorder,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      signature.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _engine.signature == signature
                            ? AppColors.orangeLight
                            : AppColors.cream.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),

        // ------------------------------------------------ drum styles
        GlassCard(
          radius: 22,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Drum backing track',
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final style in DrumStyle.values)
                    GestureDetector(
                      onTap: () {
                        setState(() => _engine.style = style);
                        _persist();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: _engine.style == style
                              ? AppColors.cardFillActive
                              : AppColors.cardFill,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _engine.style == style
                                ? AppColors.cardBorderActive
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Text(
                          style.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _engine.style == style
                                ? AppColors.orangeLight
                                : AppColors.cream.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Little animated pendulum that swings once per beat while playing.
class _Pendulum extends StatelessWidget {
  const _Pendulum({
    required this.playing,
    required this.beat,
    required this.bpm,
  });

  final bool playing;
  final int beat;
  final int bpm;

  @override
  Widget build(BuildContext context) {
    final angle = !playing ? 0.0 : (beat.isEven ? -0.4 : 0.4);
    return SizedBox(
      height: 44,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: angle),
        duration: Duration(milliseconds: playing ? (60000 ~/ bpm) : 300),
        curve: Curves.easeInOut,
        builder: (context, value, _) => Transform.rotate(
          angle: value,
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: playing ? AppColors.orange : AppColors.creamFaint,
                  shape: BoxShape.circle,
                  boxShadow: playing
                      ? [
                          BoxShadow(
                            color: AppColors.orange.withValues(alpha: 0.6),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
              ),
              Container(
                width: 3,
                height: 26,
                decoration: BoxDecoration(
                  color: (playing ? AppColors.orange : AppColors.creamFaint)
                      .withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundStepButton extends StatelessWidget {
  const _RoundStepButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(label,
            style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
