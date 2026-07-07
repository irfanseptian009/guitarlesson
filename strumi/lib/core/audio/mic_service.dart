import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';

/// Streams raw microphone PCM into a rolling ring buffer that DSP
/// consumers (tuner, chord detector, practice feedback) sample from.
class MicService {
  static const int sampleRate = 44100;
  static const int _ringSize = 32768;

  final AudioRecorder _recorder = AudioRecorder();
  final Float64List _ring = Float64List(_ringSize);
  int _writeIndex = 0;
  int _written = 0;
  StreamSubscription<Uint8List>? _subscription;
  bool _running = false;

  bool get isRunning => _running;

  /// Total samples captured since [start]; consumers can use this to know
  /// whether fresh audio has arrived.
  int get samplesWritten => _written;

  Future<bool> hasPermission() => _recorder.hasPermission();

  /// Starts streaming. Returns false when mic permission is denied.
  Future<bool> start() async {
    if (_running) return true;
    if (!await _recorder.hasPermission()) return false;

    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: 1,
      ),
    );
    _writeIndex = 0;
    _written = 0;
    _subscription = stream.listen(_onChunk);
    _running = true;
    return true;
  }

  void _onChunk(Uint8List chunk) {
    final data = ByteData.sublistView(chunk);
    final count = chunk.length ~/ 2;
    for (var i = 0; i < count; i++) {
      _ring[_writeIndex] = data.getInt16(i * 2, Endian.little) / 32768.0;
      _writeIndex = (_writeIndex + 1) % _ringSize;
    }
    _written += count;
  }

  /// Copy of the most recent [n] samples (oldest first).
  /// Returns null until at least [n] samples have been captured.
  Float64List? latest(int n) {
    assert(n <= _ringSize);
    if (_written < n) return null;
    final out = Float64List(n);
    var index = (_writeIndex - n) % _ringSize;
    if (index < 0) index += _ringSize;
    for (var i = 0; i < n; i++) {
      out[i] = _ring[index];
      index = (index + 1) % _ringSize;
    }
    return out;
  }

  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    await _subscription?.cancel();
    _subscription = null;
    await _recorder.stop();
  }

  Future<void> dispose() async {
    await stop();
    await _recorder.dispose();
  }
}
