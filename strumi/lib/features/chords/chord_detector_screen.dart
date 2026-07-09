import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_palette.dart';
import '../../core/i18n/strings.dart';
import '../../core/audio/mic_service.dart';
import '../../core/dsp/chroma.dart';
import '../../core/music/chords.dart';
import '../../core/music/note_utils.dart';
import '../../core/utils/practice_clock.dart';
import '../../data/models/progress_state.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/screen_scaffold.dart';
import 'widgets/chord_diagram.dart';

/// AI chord detector: listens to the guitar, ranks the whole catalog by
/// chromagram similarity, and marks confident detections as mastered.
class ChordDetectorScreen extends ConsumerStatefulWidget {
  const ChordDetectorScreen({super.key});

  @override
  ConsumerState<ChordDetectorScreen> createState() =>
      _ChordDetectorScreenState();
}

class _ChordDetectorScreenState extends ConsumerState<ChordDetectorScreen> {
  late final MicService _mic;
  late final PracticeClock _clock;
  final ChromaAnalyzer _analyzer = ChromaAnalyzer(
    sampleRate: MicService.sampleRate.toDouble(),
  );

  Timer? _timer;
  bool _micDenied = false;
  List<ChordMatch> _top = const [];
  ChordMatch? _detected;
  String? _previousTop;
  int _silentFrames = 0;

  /// Latest 12-bin chromagram for the live visualization.
  Float64List? _chroma;

  @override
  void initState() {
    super.initState();
    _mic = ref.read(micServiceProvider);
    final progress = ref.read(progressProvider.notifier);
    _clock = PracticeClock(
      (s) => progress.addPracticeSeconds(PracticeCategory.chords, s),
    );
    unawaited(_startMic());
  }

  Future<void> _startMic() async {
    final ok = await _mic.start();
    if (!mounted) return;
    setState(() => _micDenied = !ok);
    if (ok) {
      _timer ??= Timer.periodic(
        const Duration(milliseconds: 250),
        (_) => _poll(),
      );
    }
  }

  void _poll() {
    final samples = _mic.latest(ChordListenerWindow.size);
    if (samples == null || !mounted) return;

    final chroma = _analyzer.chroma(samples);
    if (chroma == null) {
      if (++_silentFrames >= 3 && (_top.isNotEmpty || _detected != null)) {
        setState(() {
          _top = const [];
          _previousTop = null;
          _chroma = null;
        });
      }
      return;
    }
    _silentFrames = 0;

    final ranked = _analyzer.rank(chroma);
    final top = ranked.take(3).toList();
    final best = top.first;

    setState(() {
      _top = top;
      _chroma = chroma;
    });

    // Two agreeing frames above threshold lock a detection.
    if (best.score >= 0.60 && best.chord.name == _previousTop) {
      final isNew = _detected?.chord.name != best.chord.name;
      setState(() => _detected = best);
      if (isNew && best.score >= 0.75) _master(best.chord.name);
    }
    _previousTop = best.chord.name;
  }

  void _master(String name) {
    final alreadyMastered = ref
        .read(progressProvider)
        .masteredChords
        .contains(name);
    ref.read(progressProvider.notifier).masterChord(name);
    if (!alreadyMastered && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.s.chordVerified(name))));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _clock.commit();
    unawaited(_mic.stop());
    super.dispose();
  }

  /// Bar height 0..1 for pitch class [pc], scaled to the loudest bin.
  double _chromaHeight(int pc) {
    final chroma = _chroma;
    if (chroma == null) return 0;
    var maxValue = 0.0;
    for (final v in chroma) {
      if (v > maxValue) maxValue = v;
    }
    if (maxValue <= 0) return 0;
    return (chroma[pc] / maxValue).clamp(0.0, 1.0);
  }

  bool _isChordTone(int pc) =>
      _detected?.chord.pitchClasses.contains(pc) ?? false;

  @override
  Widget build(BuildContext context) {
    final st = context.s;
    final progress = ref.watch(progressProvider);
    final detected = _detected;

    return ScreenScaffold(
      gap: 16,
      children: [
        SubScreenHeader(title: st.chordDetector),

        // ------------------------------------------------ live status
        GlassCard(
          radius: 24,
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
          child: Column(
            children: [
              GestureDetector(
                onTap: _micDenied ? () => unawaited(_startMic()) : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Dot(
                      color: _micDenied
                          ? context.colors.red
                          : context.colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _micDenied ? st.micOffTapAllow : st.aiListeningEllipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _micDenied
                            ? context.colors.red
                            : context.colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                detected?.chord.name ?? '—',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                detected == null
                    ? st.playOneChord
                    : st.confidence((detected.score * 100).round()),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: detected == null
                      ? context.colors.creamDim
                      : context.colors.blue,
                ),
              ),
              if (detected != null) ...[
                const SizedBox(height: 18),
                ChordDiagram(chord: detected.chord, width: 110, height: 128),
                const SizedBox(height: 12),
                Text(
                  detected.chord.tipFor(st.lang),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: context.colors.creamDim,
                  ),
                ),
              ],
            ],
          ),
        ),

        // ------------------------------------------------ live chroma
        GlassCard(
          radius: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                st.chromagram,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              RepaintBoundary(
                child: SizedBox(
                  height: 74,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var pc = 0; pc < 12; pc++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.5,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  height: 4 + _chromaHeight(pc) * 52,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: _isChordTone(pc)
                                        ? context.colors.orange
                                        : context.colors.blue.withValues(
                                            alpha: 0.45,
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  kNoteNames[pc],
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w600,
                                    color: _isChordTone(pc)
                                        ? context.colors.orangeLight
                                        : context.colors.creamFaint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ------------------------------------------------ top candidates
        GlassCard(
          radius: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                st.topCandidates,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (_top.isEmpty)
                Text(
                  st.noSignalYet,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.creamFaint,
                  ),
                )
              else
                for (final match in _top) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 64,
                          child: Text(
                            match.chord.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: match.score,
                              minHeight: 6,
                              backgroundColor: context.colors.cream.withValues(
                                alpha: 0.10,
                              ),
                              valueColor: AlwaysStoppedAnimation(
                                context.colors.blue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 38,
                          child: Text(
                            '${(match.score * 100).round()}%',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
            ],
          ),
        ),

        // ------------------------------------------------ mastered count
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colors.green.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              st.masteredCount(
                progress.masteredChords.length,
                kGuitarChords.length,
              ),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: context.colors.green,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Analysis window shared with [ChordListener].
abstract final class ChordListenerWindow {
  static const int size = 8192;
}

class _Dot extends StatefulWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
    lowerBound: 0.35,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
