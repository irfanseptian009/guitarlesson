import 'dart:math' as math;
import 'dart:typed_data';

/// Minimal iterative radix-2 FFT (Cooley–Tukey), sufficient for the
/// chromagram chord detector. Operates in place on [re]/[im].
abstract final class Fft {
  static void transform(Float64List re, Float64List im) {
    final n = re.length;
    assert(n == im.length && (n & (n - 1)) == 0, 'length must be a power of 2');

    // Bit-reversal permutation.
    for (var i = 1, j = 0; i < n; i++) {
      var bit = n >> 1;
      for (; (j & bit) != 0; bit >>= 1) {
        j &= ~bit;
      }
      j |= bit;
      if (i < j) {
        final tr = re[i];
        re[i] = re[j];
        re[j] = tr;
        final ti = im[i];
        im[i] = im[j];
        im[j] = ti;
      }
    }

    for (var len = 2; len <= n; len <<= 1) {
      final ang = -2 * math.pi / len;
      final wRe = math.cos(ang);
      final wIm = math.sin(ang);
      for (var i = 0; i < n; i += len) {
        var curRe = 1.0, curIm = 0.0;
        final half = len >> 1;
        for (var k = 0; k < half; k++) {
          final aRe = re[i + k], aIm = im[i + k];
          final bRe = re[i + k + half] * curRe - im[i + k + half] * curIm;
          final bIm = re[i + k + half] * curIm + im[i + k + half] * curRe;
          re[i + k] = aRe + bRe;
          im[i + k] = aIm + bIm;
          re[i + k + half] = aRe - bRe;
          im[i + k + half] = aIm - bIm;
          final nextRe = curRe * wRe - curIm * wIm;
          curIm = curRe * wIm + curIm * wRe;
          curRe = nextRe;
        }
      }
    }
  }

  /// Magnitude spectrum (first half) of a real signal, Hann-windowed.
  static Float64List magnitudeSpectrum(Float64List signal) {
    final n = signal.length;
    final re = Float64List(n);
    final im = Float64List(n);
    for (var i = 0; i < n; i++) {
      final hann = 0.5 * (1 - math.cos(2 * math.pi * i / (n - 1)));
      re[i] = signal[i] * hann;
    }
    transform(re, im);
    final mags = Float64List(n ~/ 2);
    for (var i = 0; i < mags.length; i++) {
      mags[i] = math.sqrt(re[i] * re[i] + im[i] * im[i]);
    }
    return mags;
  }
}
