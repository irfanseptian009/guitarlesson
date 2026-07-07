import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import '../music/note_utils.dart';
import 'synthesizer.dart';
import 'wav_codec.dart';

/// Percussive one-shots used by the metronome/drum engine.
enum DrumSample { clickHi, clickLo, kick, snare, hihat, hihatOpen, ride }

/// Synthesizes samples once, caches them as WAV files, and plays them
/// through small low-latency player pools.
///
/// Two playback paths:
///  * [playDrum] — pre-warmed low-latency pools for rhythm-critical hits.
///  * [playPluck]/[playStrum] — melodic sounds synthesized & cached on demand.
class SoundBank {
  SoundBank._(this._dir);

  static const int _poolSize = 3;
  static const int _melodicPoolSize = 4;

  final Directory _dir;
  final Map<DrumSample, List<AudioPlayer>> _drumPools = {};
  final Map<DrumSample, int> _drumCursor = {};
  final Map<String, String> _melodicPaths = {};
  final List<AudioPlayer> _melodicPlayers = [];
  int _melodicCursor = 0;

  static Future<SoundBank> create() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory('${support.path}${Platform.pathSeparator}samples');
    await dir.create(recursive: true);
    final bank = SoundBank._(dir);
    await bank._prepareDrums();
    for (var i = 0; i < _melodicPoolSize; i++) {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      bank._melodicPlayers.add(player);
    }
    return bank;
  }

  Future<void> _prepareDrums() async {
    final generators = <DrumSample, Float64List Function()>{
      DrumSample.clickHi: () => Synthesizer.click(accent: true),
      DrumSample.clickLo: () => Synthesizer.click(),
      DrumSample.kick: Synthesizer.kick,
      DrumSample.snare: Synthesizer.snare,
      DrumSample.hihat: Synthesizer.hihat,
      DrumSample.hihatOpen: () => Synthesizer.hihat(open: true),
      DrumSample.ride: Synthesizer.ride,
    };

    for (final entry in generators.entries) {
      final path = await _ensureFile('drum_${entry.key.name}', entry.value);
      final pool = <AudioPlayer>[];
      for (var i = 0; i < _poolSize; i++) {
        final player = AudioPlayer();
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setSourceDeviceFile(path);
        pool.add(player);
      }
      _drumPools[entry.key] = pool;
      _drumCursor[entry.key] = 0;
    }
  }

  Future<String> _ensureFile(
    String key,
    Float64List Function() generate,
  ) async {
    final file = File('${_dir.path}${Platform.pathSeparator}$key.wav');
    if (!await file.exists()) {
      await file.writeAsBytes(
        WavCodec.encode(generate(), sampleRate: Synthesizer.sampleRate),
      );
    }
    return file.path;
  }

  /// Fire-and-forget drum/click hit.
  void playDrum(DrumSample sample, {double volume = 1.0}) {
    final pool = _drumPools[sample];
    if (pool == null || pool.isEmpty) return;
    final cursor = _drumCursor[sample]!;
    _drumCursor[sample] = (cursor + 1) % pool.length;
    final player = pool[cursor];
    // Not awaited on purpose: rhythm callbacks must never block.
    unawaited(() async {
      try {
        await player.stop();
        await player.setVolume(volume);
        await player.resume();
      } catch (_) {/* player may race during dispose; safe to drop a hit */}
    }());
  }

  Future<void> _playMelodicFile(String path, {double volume = 1.0}) async {
    final player = _melodicPlayers[_melodicCursor];
    _melodicCursor = (_melodicCursor + 1) % _melodicPlayers.length;
    try {
      await player.stop();
      await player.setVolume(volume);
      await player.play(DeviceFileSource(path));
    } catch (_) {/* ignore playback races */}
  }

  /// Plays a single plucked note.
  Future<void> playPluck(int midi, {double a4 = 440.0}) async {
    final key = 'pluck_${midi}_${a4.round()}';
    final path = _melodicPaths[key] ??= await _ensureFile(
      key,
      () => Synthesizer.pluck(NoteUtils.midiToFrequency(midi, a4: a4)),
    );
    await _playMelodicFile(path);
  }

  /// Plays a full strummed chord voicing.
  Future<void> playStrum(List<int> midiNotes, {double a4 = 440.0}) async {
    final key = 'strum_${midiNotes.join('_')}_${a4.round()}';
    final path = _melodicPaths[key] ??= await _ensureFile(
      key,
      () => Synthesizer.strum([
        for (final m in midiNotes) NoteUtils.midiToFrequency(m, a4: a4),
      ]),
    );
    await _playMelodicFile(path);
  }

  Future<void> dispose() async {
    for (final pool in _drumPools.values) {
      for (final player in pool) {
        await player.dispose();
      }
    }
    for (final player in _melodicPlayers) {
      await player.dispose();
    }
  }
}
