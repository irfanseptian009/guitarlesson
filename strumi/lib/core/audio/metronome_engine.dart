import 'dart:async';
import 'dart:math' as math;

import 'sound_bank.dart';

/// Backing patterns offered by the metronome (design: "Drum backing track").
enum DrumStyle {
  click('Klik saja'),
  rock('Rock 8-beat'),
  pop('Pop groove'),
  shuffle('Blues shuffle'),
  jazz('Jazz swing'),
  latin('Latin');

  const DrumStyle(this.label);
  final String label;
}

/// Supported time signatures.
enum TimeSignature {
  twoFour('2/4', 2),
  threeFour('3/4', 3),
  fourFour('4/4', 4),
  sixEight('6/8', 6);

  const TimeSignature(this.label, this.beats);
  final String label;
  final int beats;
}

/// Drift-corrected metronome/drum-machine scheduler on an 8th-note grid.
///
/// Timing uses a monotonic [Stopwatch]; each tick re-arms a one-shot timer
/// against the *ideal* next tick time so error never accumulates.
class MetronomeEngine {
  MetronomeEngine(this._bank, {this.onBeat});

  final SoundBank _bank;

  /// UI callback: fires on every beat with the beat index inside the bar
  /// (−1 means stopped).
  final void Function(int beat)? onBeat;

  static const int minBpm = 40;
  static const int maxBpm = 220;

  int _bpm = 96;
  TimeSignature _signature = TimeSignature.fourFour;

  /// Active drum pattern; takes effect from the next scheduled step.
  DrumStyle style = DrumStyle.click;
  bool _playing = false;

  Timer? _timer;
  final Stopwatch _clock = Stopwatch();
  double _nextTickUs = 0;
  int _step = -1;
  int? _lastTapMs;

  int get bpm => _bpm;
  TimeSignature get signature => _signature;
  bool get isPlaying => _playing;

  /// 8th-note steps per bar.
  int get _stepsPerBar =>
      _signature == TimeSignature.sixEight ? 6 : _signature.beats * 2;

  /// Swing ratio: fraction of a beat given to the on-8th.
  double get _swing => switch (style) {
        DrumStyle.shuffle || DrumStyle.jazz => 0.66,
        _ => 0.5,
      };

  set bpm(int value) => _bpm = value.clamp(minBpm, maxBpm);

  set signature(TimeSignature value) {
    _signature = value;
    _step = -1;
  }

  void start() {
    if (_playing) return;
    _playing = true;
    _step = -1;
    _clock
      ..reset()
      ..start();
    _nextTickUs = 0;
    _tick();
  }

  void stop() {
    _playing = false;
    _timer?.cancel();
    _timer = null;
    _clock.stop();
    onBeat?.call(-1);
  }

  /// Tap-tempo: two taps within 2 s set the BPM.
  /// Returns the new BPM when it changed.
  int? tap() {
    final now = DateTime.now().millisecondsSinceEpoch;
    int? result;
    if (_lastTapMs != null && now - _lastTapMs! < 2000) {
      bpm = (60000 / (now - _lastTapMs!)).round();
      result = _bpm;
    }
    _lastTapMs = now;
    return result;
  }

  void _tick() {
    if (!_playing) return;
    _step = (_step + 1) % _stepsPerBar;
    _playStep(_step);

    // 6/8 grid steps are straight 8ths; /4 grids swing in on/off pairs.
    final beatUs = 60e6 / _bpm;
    final double stepUs;
    if (_signature == TimeSignature.sixEight) {
      stepUs = beatUs / 2;
    } else {
      stepUs = _step.isEven ? beatUs * _swing : beatUs * (1 - _swing);
    }
    _nextTickUs += stepUs;
    final delay = _nextTickUs - _clock.elapsedMicroseconds;
    _timer = Timer(
      Duration(microseconds: math.max(0, delay.round())),
      _tick,
    );
  }

  void _playStep(int step) {
    final isBeat = _signature == TimeSignature.sixEight || step.isEven;
    final beat = _signature == TimeSignature.sixEight ? step : step ~/ 2;
    if (isBeat) onBeat?.call(beat);

    if (style == DrumStyle.click) {
      if (!isBeat) return;
      _bank.playDrum(beat == 0 ? DrumSample.clickHi : DrumSample.clickLo);
      return;
    }

    final is44 = _signature == TimeSignature.fourFour;
    final (kick, snare, hat) = is44
        ? _fourFourPattern(step)
        : _genericPattern(step, beat, isBeat);

    if (hat > 0) {
      _bank.playDrum(
        style == DrumStyle.jazz ? DrumSample.ride : DrumSample.hihat,
        volume: hat,
      );
    }
    if (kick > 0) _bank.playDrum(DrumSample.kick, volume: kick);
    if (snare > 0) _bank.playDrum(DrumSample.snare, volume: snare);
  }

  /// (kick, snare, hat) velocities for 8th-note [step] 0..7 in 4/4.
  (double, double, double) _fourFourPattern(int step) {
    const off = 0.0;
    switch (style) {
      case DrumStyle.rock:
        return (
          const [1.0, off, off, off, 1.0, 0.9, off, off][step],
          const [off, off, 1.0, off, off, off, 1.0, off][step],
          step.isEven ? 0.8 : 0.5,
        );
      case DrumStyle.pop:
        return (
          const [1.0, off, off, 0.9, off, 0.9, off, off][step],
          const [off, off, 1.0, off, off, off, 1.0, off][step],
          step.isEven ? 0.7 : 0.45,
        );
      case DrumStyle.shuffle:
        return (
          const [1.0, off, off, off, 1.0, off, off, off][step],
          const [off, off, 1.0, off, off, off, 1.0, off][step],
          0.7,
        );
      case DrumStyle.jazz:
        // Ride: 1, 2, 2&, 3, 4, 4& — the classic swing pattern.
        return (
          const [0.5, off, off, off, 0.5, off, off, off][step],
          const [off, off, off, 0.35, off, off, off, 0.35][step],
          const [0.9, off, 0.9, 0.7, 0.9, off, 0.9, 0.7][step],
        );
      case DrumStyle.latin:
        // Son-clave flavored rim/kick pattern.
        return (
          const [1.0, off, off, 0.9, off, off, 0.9, off][step],
          const [off, off, 0.8, off, off, 0.8, off, off][step],
          0.6,
        );
      case DrumStyle.click:
        return (off, off, off);
    }
  }

  /// Fallback groove for 2/4, 3/4, 6/8: hats on the grid, kick on 1,
  /// snare on the bar's midpoint.
  (double, double, double) _genericPattern(int step, int beat, bool isBeat) {
    final mid = _signature == TimeSignature.sixEight
        ? 3
        : _signature.beats == 3
            ? 2
            : 1;
    return (
      step == 0 ? 1.0 : 0.0,
      isBeat && beat == mid ? 0.9 : 0.0,
      isBeat ? 0.75 : 0.5,
    );
  }

  void dispose() => stop();
}
