import 'dart:math' as math;
import 'dart:typed_data';

import '../music/chords.dart';
import '../music/note_utils.dart';
import 'fft.dart';

/// A ranked chord hypothesis from the chromagram matcher.
class ChordMatch {
  const ChordMatch({required this.chord, required this.score});

  final ChordShape chord;

  /// Cosine similarity 0..1 between the observed chroma and the template.
  final double score;
}

/// Polyphonic chord recognition via a 12-bin chromagram + template matching.
///
/// Pipeline: Hann window → FFT → fold spectral energy of the guitar band
/// into pitch classes → cosine-match against templates derived from the
/// chord catalog's actual voicings.
class ChromaAnalyzer {
  ChromaAnalyzer({required this.sampleRate, this.fftSize = 8192})
      : _templates = {
          // Suspended chords share too many notes with their neighbours
          // and only confuse the matcher — leave them out of detection.
          for (final chord in kGuitarChords)
            if (!chord.name.contains('sus'))
              chord.name: _templateFor(chord),
        };

  final double sampleRate;
  final int fftSize;
  final Map<String, Float64List> _templates;

  /// Minimum RMS before a frame is considered signal rather than silence.
  static const double silenceRms = 0.012;

  /// Chromagram of a mono frame (length >= [fftSize]); null when silent.
  Float64List? chroma(Float64List samples) {
    assert(samples.length >= fftSize);

    var rms = 0.0;
    for (var i = 0; i < fftSize; i++) {
      rms += samples[i] * samples[i];
    }
    rms = math.sqrt(rms / fftSize);
    if (rms < silenceRms) return null;

    final mags = Fft.magnitudeSpectrum(
      samples.length == fftSize ? samples : samples.sublist(0, fftSize),
    );

    final chroma = Float64List(12);
    final binHz = sampleRate / fftSize;
    final minBin = (70 / binHz).ceil(); // below low guitar range
    final maxBin = math.min((1100 / binHz).floor(), mags.length - 1);

    for (var bin = minBin; bin <= maxBin; bin++) {
      final freq = bin * binHz;
      final midiExact = NoteUtils.frequencyToMidi(freq);
      final midi = midiExact.round();
      // Reject broadband noise between tempered pitches — but widen the
      // gate at low frequencies where a single FFT bin spans more than
      // ±35 cents (half bin width ≈ 8.66·binHz/f semitones).
      final tolerance = math.max(0.35, 8.66 * binHz / freq + 0.05);
      if ((midiExact - midi).abs() > tolerance) continue;
      // De-emphasize the upper octaves where harmonics (not fundamentals)
      // dominate, so the template match tracks what is actually fretted.
      final weight = freq < 350 ? 1.0 : (freq < 700 ? 0.6 : 0.3);
      // sqrt-compress magnitudes so one freshly plucked string cannot
      // drown out the rest of the voicing.
      chroma[midi % 12] += math.sqrt(mags[bin]) * weight;
    }

    var norm = 0.0;
    for (final v in chroma) {
      norm += v * v;
    }
    if (norm <= 1e-9) return null;
    norm = math.sqrt(norm);
    for (var i = 0; i < 12; i++) {
      chroma[i] /= norm;
    }
    return chroma;
  }

  /// Ranks the whole catalog against [chromaVector], best match first.
  List<ChordMatch> rank(Float64List chromaVector) {
    final matches = [
      for (final entry in _templates.entries)
        ChordMatch(
          chord: chordByName(entry.key),
          score: _cosine(chromaVector, entry.value),
        ),
    ]..sort((a, b) => b.score.compareTo(a.score));
    return matches;
  }

  /// Convenience: best match for a frame, or null when silent/ambiguous.
  ChordMatch? detect(Float64List samples, {double minScore = 0.60}) {
    final c = chroma(samples);
    if (c == null) return null;
    final ranked = rank(c);
    if (ranked.isEmpty || ranked.first.score < minScore) return null;
    return ranked.first;
  }

  static Float64List _templateFor(ChordShape chord) {
    final template = Float64List(12);
    for (final pc in chord.pitchClasses) {
      template[pc] = 1.0;
    }
    // Roots ring loudest on a strummed guitar.
    template[chord.rootPitchClass] = 1.6;
    var norm = 0.0;
    for (final v in template) {
      norm += v * v;
    }
    norm = math.sqrt(norm);
    for (var i = 0; i < 12; i++) {
      template[i] /= norm;
    }
    return template;
  }

  static double _cosine(Float64List a, Float64List b) {
    var dot = 0.0;
    for (var i = 0; i < 12; i++) {
      dot += a[i] * b[i];
    }
    return dot.clamp(0.0, 1.0);
  }
}
