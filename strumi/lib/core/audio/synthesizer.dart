import 'dart:math' as math;
import 'dart:typed_data';

/// Offline synthesizer for every sound Strumi plays: guitar plucks and
/// strums (Karplus–Strong), metronome clicks, and a small drum kit —
/// all generated at runtime, no bundled audio assets.
abstract final class Synthesizer {
  static const int sampleRate = 44100;
  static final math.Random _random = math.Random(7);

  // ---------------------------------------------------------------- guitar

  /// Karplus–Strong plucked string.
  static Float64List pluck(
    double frequency, {
    double seconds = 1.6,
    double gain = 0.9,
  }) {
    final length = (seconds * sampleRate).round();
    final out = Float64List(length);
    final period = (sampleRate / frequency).round().clamp(2, sampleRate);
    final delay = Float64List(period);

    // Noise burst excitation, lightly low-passed for a warmer attack.
    var prev = 0.0;
    for (var i = 0; i < period; i++) {
      final noise = _random.nextDouble() * 2 - 1;
      prev = 0.6 * noise + 0.4 * prev;
      delay[i] = prev;
    }

    // Higher notes decay a touch faster, like a real string.
    final damping = 0.996 - (frequency / 40000).clamp(0.0, 0.004);
    var index = 0;
    for (var i = 0; i < length; i++) {
      final current = delay[index];
      final next = delay[(index + 1) % period];
      final filtered = damping * 0.5 * (current + next);
      delay[index] = filtered;
      out[i] = current * gain;
      index = (index + 1) % period;
    }
    _fadeOut(out, ms: 30);
    return out;
  }

  /// Down-strum: staggered plucks of every chord note, mixed and normalized.
  static Float64List strum(
    List<double> frequencies, {
    double seconds = 2.2,
    double strumGapMs = 45,
  }) {
    final length = (seconds * sampleRate).round();
    final out = Float64List(length);
    final gap = (strumGapMs / 1000 * sampleRate).round();
    for (var n = 0; n < frequencies.length; n++) {
      final voice = pluck(frequencies[n],
          seconds: seconds - n * strumGapMs / 1000, gain: 0.8);
      final offset = n * gap;
      for (var i = 0; i < voice.length && offset + i < length; i++) {
        out[offset + i] += voice[i];
      }
    }
    _normalize(out, peak: 0.85);
    return out;
  }

  // ------------------------------------------------------------ metronome

  /// Short sine "beep" click; accent version is brighter and louder.
  static Float64List click({bool accent = false}) {
    final freq = accent ? 1760.0 : 1175.0;
    final length = (0.055 * sampleRate).round();
    final out = Float64List(length);
    for (var i = 0; i < length; i++) {
      final t = i / sampleRate;
      final env = math.exp(-t * 90);
      out[i] = math.sin(2 * math.pi * freq * t) * env * (accent ? 0.95 : 0.7);
    }
    return out;
  }

  // ----------------------------------------------------------------- drums

  /// Kick: sine with an exponential pitch drop plus a click transient.
  static Float64List kick() {
    final length = (0.30 * sampleRate).round();
    final out = Float64List(length);
    var phase = 0.0;
    for (var i = 0; i < length; i++) {
      final t = i / sampleRate;
      final freq = 42 + 90 * math.exp(-t * 28);
      phase += 2 * math.pi * freq / sampleRate;
      final env = math.exp(-t * 14);
      final transient = i < 90 ? (_random.nextDouble() * 2 - 1) * 0.25 : 0.0;
      out[i] = (math.sin(phase) * 0.95 + transient) * env;
    }
    return out;
  }

  /// Snare: 190 Hz body + bright noise, fast decay.
  static Float64List snare() {
    final length = (0.20 * sampleRate).round();
    final out = Float64List(length);
    var hp = 0.0, prevNoise = 0.0;
    for (var i = 0; i < length; i++) {
      final t = i / sampleRate;
      final tone = math.sin(2 * math.pi * 190 * t) * math.exp(-t * 30) * 0.5;
      final noise = _random.nextDouble() * 2 - 1;
      hp = noise - prevNoise; // crude high-pass
      prevNoise = noise;
      out[i] = tone + hp * math.exp(-t * 22) * 0.8;
    }
    return out;
  }

  /// Closed hi-hat: very short high-passed noise.
  static Float64List hihat({bool open = false}) {
    final decay = open ? 9.0 : 55.0;
    final length = ((open ? 0.35 : 0.09) * sampleRate).round();
    final out = Float64List(length);
    var prev = 0.0;
    for (var i = 0; i < length; i++) {
      final t = i / sampleRate;
      final noise = _random.nextDouble() * 2 - 1;
      final hp = noise - prev;
      prev = noise;
      out[i] = hp * math.exp(-t * decay) * 0.5;
    }
    return out;
  }

  /// Ride cymbal ping for the jazz pattern: metallic partials + noise tail.
  static Float64List ride() {
    final length = (0.5 * sampleRate).round();
    final out = Float64List(length);
    const partials = [330.0, 587.0, 831.0, 1247.0];
    var prev = 0.0;
    for (var i = 0; i < length; i++) {
      final t = i / sampleRate;
      var v = 0.0;
      for (var p = 0; p < partials.length; p++) {
        v += math.sin(2 * math.pi * partials[p] * t) / (p + 1.5);
      }
      final noise = _random.nextDouble() * 2 - 1;
      final hp = noise - prev;
      prev = noise;
      out[i] = (v * 0.22 + hp * 0.18) * math.exp(-t * 7);
    }
    return out;
  }

  // ---------------------------------------------------------------- helpers

  static void _normalize(Float64List samples, {double peak = 0.9}) {
    var maxAbs = 0.0;
    for (final v in samples) {
      final a = v.abs();
      if (a > maxAbs) maxAbs = a;
    }
    if (maxAbs < 1e-9) return;
    final scale = peak / maxAbs;
    for (var i = 0; i < samples.length; i++) {
      samples[i] *= scale;
    }
  }

  static void _fadeOut(Float64List samples, {double ms = 20}) {
    final fade = (ms / 1000 * sampleRate).round().clamp(1, samples.length);
    for (var i = 0; i < fade; i++) {
      samples[samples.length - fade + i] *= 1 - i / fade;
    }
  }
}
