import 'dart:typed_data';

/// Result of a single YIN analysis frame.
class PitchEstimate {
  const PitchEstimate({required this.frequency, required this.confidence});

  /// Estimated fundamental frequency in Hz.
  final double frequency;

  /// 0..1 — how periodic the frame is (1 = perfectly periodic).
  final double confidence;
}

/// YIN monophonic pitch detector
/// (de Cheveigné & Kawahara, 2002) — used by the tuner and riff analyzer.
class YinDetector {
  YinDetector({
    required this.sampleRate,
    this.bufferSize = 2048,
    this.threshold = 0.14,
  })  : _halfSize = bufferSize ~/ 2,
        _diff = Float64List(bufferSize ~/ 2);

  final double sampleRate;
  final int bufferSize;

  /// CMNDF acceptance threshold; lower = stricter.
  final double threshold;

  final int _halfSize;
  final Float64List _diff;

  /// Analyzes [samples] (length >= [bufferSize], mono, −1..1).
  /// Returns null when no periodic pitch is present.
  PitchEstimate? estimate(Float64List samples) {
    assert(samples.length >= bufferSize);

    // 1. Difference function.
    for (var tau = 1; tau < _halfSize; tau++) {
      var sum = 0.0;
      for (var i = 0; i < _halfSize; i++) {
        final delta = samples[i] - samples[i + tau];
        sum += delta * delta;
      }
      _diff[tau] = sum;
    }

    // 2. Cumulative mean normalized difference (CMNDF).
    _diff[0] = 1;
    var runningSum = 0.0;
    for (var tau = 1; tau < _halfSize; tau++) {
      runningSum += _diff[tau];
      _diff[tau] = runningSum == 0 ? 1 : _diff[tau] * tau / runningSum;
    }

    // 3. Absolute threshold: first dip below threshold, then walk to its
    //    local minimum.
    var tauEstimate = -1;
    for (var tau = 2; tau < _halfSize; tau++) {
      if (_diff[tau] < threshold) {
        while (tau + 1 < _halfSize && _diff[tau + 1] < _diff[tau]) {
          tau++;
        }
        tauEstimate = tau;
        break;
      }
    }
    if (tauEstimate == -1) return null;

    // 4. Parabolic interpolation around the minimum for sub-sample accuracy.
    final betterTau = _parabolicInterpolation(tauEstimate);
    if (betterTau <= 0) return null;

    return PitchEstimate(
      frequency: sampleRate / betterTau,
      confidence: (1 - _diff[tauEstimate]).clamp(0.0, 1.0),
    );
  }

  double _parabolicInterpolation(int tau) {
    final x0 = tau < 1 ? tau : tau - 1;
    final x2 = tau + 1 < _halfSize ? tau + 1 : tau;
    if (x0 == tau || x2 == tau) return tau.toDouble();
    final s0 = _diff[x0], s1 = _diff[tau], s2 = _diff[x2];
    final denom = 2 * (2 * s1 - s2 - s0);
    if (denom == 0) return tau.toDouble();
    return tau + (s2 - s0) / denom;
  }
}
