import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:strumi/core/audio/synthesizer.dart';
import 'package:strumi/core/audio/wav_codec.dart';
import 'package:strumi/core/dsp/chroma.dart';
import 'package:strumi/core/dsp/yin.dart';
import 'package:strumi/core/music/chords.dart';
import 'package:strumi/core/music/note_utils.dart';

Float64List sine(double frequency, int length,
    {double sampleRate = 44100, double amplitude = 0.5}) {
  final out = Float64List(length);
  for (var i = 0; i < length; i++) {
    out[i] = amplitude * math.sin(2 * math.pi * frequency * i / sampleRate);
  }
  return out;
}

void main() {
  group('YinDetector', () {
    test('finds a pure 220 Hz tone within 1.5 Hz', () {
      final detector = YinDetector(sampleRate: 44100);
      final estimate = detector.estimate(sine(220, 2048));
      expect(estimate, isNotNull);
      expect(estimate!.frequency, closeTo(220, 1.5));
      expect(estimate.confidence, greaterThan(0.9));
    });

    test('finds low-E (82.4 Hz) with a 4096 window', () {
      final detector = YinDetector(sampleRate: 44100, bufferSize: 4096);
      final estimate = detector.estimate(sine(82.41, 4096));
      expect(estimate, isNotNull);
      expect(estimate!.frequency, closeTo(82.41, 1.0));
    });

    test('returns null for silence and noise', () {
      final detector = YinDetector(sampleRate: 44100);
      expect(detector.estimate(Float64List(2048)), isNull);
      final random = math.Random(3);
      final noise = Float64List.fromList([
        for (var i = 0; i < 2048; i++) random.nextDouble() * 0.6 - 0.3,
      ]);
      expect(detector.estimate(noise), isNull);
    });
  });

  group('ChromaAnalyzer', () {
    test('recognizes a synthesized Am strum', () {
      final analyzer = ChromaAnalyzer(sampleRate: 44100);
      final am = chordByName('Am');
      final strum = Synthesizer.strum([
        for (final midi in am.midiNotes) NoteUtils.midiToFrequency(midi),
      ]);
      // Skip the noisy attack, analyze the ringing body of the strum.
      final body = strum.sublist(8192, 8192 * 2);
      final chroma = analyzer.chroma(body);
      expect(chroma, isNotNull);
      final top3 =
          analyzer.rank(chroma!).take(3).map((m) => m.chord.name).toList();
      expect(top3, contains('Am'));
    });

    test('is silent below the RMS gate', () {
      final analyzer = ChromaAnalyzer(sampleRate: 44100);
      expect(analyzer.chroma(Float64List(8192)), isNull);
    });
  });

  group('WavCodec', () {
    test('encode/decode roundtrip preserves samples', () {
      final original = sine(440, 4410, amplitude: 0.8);
      final bytes = WavCodec.encode(original);
      final decoded = WavCodec.decode(bytes);
      expect(decoded, isNotNull);
      expect(decoded!.sampleRate, 44100);
      expect(decoded.samples.length, original.length);
      for (var i = 0; i < original.length; i += 441) {
        expect(decoded.samples[i], closeTo(original[i], 0.001));
      }
    });

    test('rejects garbage input', () {
      expect(WavCodec.decode(Uint8List(10)), isNull);
      expect(WavCodec.decode(Uint8List(100)), isNull);
    });
  });
}
