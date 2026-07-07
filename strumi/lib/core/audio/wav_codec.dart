import 'dart:typed_data';

/// Encode/decode 16-bit PCM WAV. Used to persist synthesized samples for
/// playback and to load riff recordings for offline pitch analysis.
abstract final class WavCodec {
  /// Encodes mono samples (−1..1) as a 16-bit PCM WAV file.
  static Uint8List encode(Float64List samples, {int sampleRate = 44100}) {
    final dataLength = samples.length * 2;
    final bytes = BytesBuilder();
    final header = ByteData(44);

    void writeAscii(int offset, String text) {
      for (var i = 0; i < text.length; i++) {
        header.setUint8(offset + i, text.codeUnitAt(i));
      }
    }

    writeAscii(0, 'RIFF');
    header.setUint32(4, 36 + dataLength, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    header.setUint32(16, 16, Endian.little); // PCM chunk size
    header.setUint16(20, 1, Endian.little); // PCM format
    header.setUint16(22, 1, Endian.little); // mono
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * 2, Endian.little); // byte rate
    header.setUint16(32, 2, Endian.little); // block align
    header.setUint16(34, 16, Endian.little); // bits per sample
    writeAscii(36, 'data');
    header.setUint32(40, dataLength, Endian.little);
    bytes.add(header.buffer.asUint8List());

    final pcm = ByteData(dataLength);
    for (var i = 0; i < samples.length; i++) {
      final v = (samples[i].clamp(-1.0, 1.0) * 32767).round();
      pcm.setInt16(i * 2, v, Endian.little);
    }
    bytes.add(pcm.buffer.asUint8List());
    return bytes.takeBytes();
  }

  /// Decodes a 16-bit PCM WAV file to mono samples (−1..1) + sample rate.
  /// Multi-channel input is downmixed. Returns null if the file is not
  /// a supported PCM WAV.
  static ({Float64List samples, int sampleRate})? decode(Uint8List bytes) {
    if (bytes.length < 44) return null;
    final data = ByteData.sublistView(bytes);
    if (String.fromCharCodes(bytes.sublist(0, 4)) != 'RIFF' ||
        String.fromCharCodes(bytes.sublist(8, 12)) != 'WAVE') {
      return null;
    }

    var offset = 12;
    int? sampleRate;
    int channels = 1;
    int bitsPerSample = 16;
    Float64List? samples;

    while (offset + 8 <= bytes.length) {
      final chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      final chunkSize = data.getUint32(offset + 4, Endian.little);
      final body = offset + 8;
      if (chunkId == 'fmt ') {
        final format = data.getUint16(body, Endian.little);
        if (format != 1) return null; // PCM only
        channels = data.getUint16(body + 2, Endian.little);
        sampleRate = data.getUint32(body + 4, Endian.little);
        bitsPerSample = data.getUint16(body + 14, Endian.little);
        if (bitsPerSample != 16) return null;
      } else if (chunkId == 'data' && sampleRate != null) {
        final end = (body + chunkSize).clamp(0, bytes.length);
        final frameCount = (end - body) ~/ (2 * channels);
        samples = Float64List(frameCount);
        for (var i = 0; i < frameCount; i++) {
          var acc = 0.0;
          for (var ch = 0; ch < channels; ch++) {
            acc += data.getInt16(body + (i * channels + ch) * 2, Endian.little);
          }
          samples[i] = acc / channels / 32768.0;
        }
        break;
      }
      offset = body + chunkSize + (chunkSize.isOdd ? 1 : 0);
    }

    if (sampleRate == null || samples == null) return null;
    return (samples: samples, sampleRate: sampleRate);
  }
}
