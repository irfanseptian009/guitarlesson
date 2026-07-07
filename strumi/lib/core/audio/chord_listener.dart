import 'dart:async';

import '../dsp/chroma.dart';
import 'mic_service.dart';

/// Real-time chord recognition on top of [MicService] + [ChromaAnalyzer].
///
/// Shared by the Chord Detector screen, lesson AI practice, and the daily
/// challenge. Emits a *stable* chord once per strum: two consecutive
/// agreeing frames fire [onStable]; a short silence re-arms the same chord
/// so repeated strums of one chord are counted separately.
class ChordListener {
  ChordListener(
    this._mic, {
    required this.onStable,
    this.onFrame,
    this.minScore = 0.60,
    this.frameInterval = const Duration(milliseconds: 220),
  });

  static const int windowSize = 8192;

  final MicService _mic;

  /// Fired once when a chord becomes stable (two agreeing frames).
  final void Function(ChordMatch match) onStable;

  /// Fired on every analysis frame (null = silence/ambiguous), for meters.
  final void Function(ChordMatch? match)? onFrame;

  final double minScore;
  final Duration frameInterval;

  final ChromaAnalyzer _analyzer =
      ChromaAnalyzer(sampleRate: MicService.sampleRate.toDouble());

  Timer? _timer;
  String? _previousFrameName;
  String? _stableName;
  int _silentFrames = 0;
  bool get isRunning => _timer != null;

  /// Starts the microphone and analysis loop.
  /// Returns false when mic permission is denied.
  Future<bool> start() async {
    if (isRunning) return true;
    if (!await _mic.start()) return false;
    _previousFrameName = null;
    _stableName = null;
    _silentFrames = 0;
    _timer = Timer.periodic(frameInterval, (_) => _analyze());
    return true;
  }

  void _analyze() {
    final samples = _mic.latest(windowSize);
    if (samples == null) return;

    final match = _analyzer.detect(samples, minScore: minScore);
    onFrame?.call(match);

    if (match == null) {
      _previousFrameName = null;
      // Two silent frames (~450 ms) re-arm repeat detection.
      if (++_silentFrames >= 2) _stableName = null;
      return;
    }

    _silentFrames = 0;
    final name = match.chord.name;
    if (name == _previousFrameName && name != _stableName) {
      _stableName = name;
      onStable(match);
    }
    _previousFrameName = name;
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    await _mic.stop();
  }
}
