import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../app/theme/app_palette.dart';
import '../../core/audio/wav_codec.dart';
import '../../core/i18n/strings.dart';
import '../../core/dsp/yin.dart';
import '../../core/music/note_utils.dart';
import '../../core/utils/practice_clock.dart';
import '../../data/models/progress_state.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/screen_scaffold.dart';

/// Riff recorder: records WAV takes, plays them back, and runs offline
/// YIN pitch analysis to list the detected notes ("AI notation").
class RiffRecorderScreen extends ConsumerStatefulWidget {
  const RiffRecorderScreen({super.key});

  @override
  ConsumerState<RiffRecorderScreen> createState() => _RiffRecorderScreenState();
}

class _RiffRecorderScreenState extends ConsumerState<RiffRecorderScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  late final PracticeClock _clock;
  StreamSubscription<void>? _playerDone;

  Directory? _riffDir;
  List<File> _riffs = const [];
  bool _recording = false;
  int _elapsedSeconds = 0;
  Timer? _elapsedTimer;
  Timer? _levelTimer;
  String? _playingPath;
  String? _analyzingPath;

  /// Rolling input levels (0..1) shown as a live meter while recording.
  final List<double> _levels = [];
  static const _levelBarCount = 26;

  @override
  void initState() {
    super.initState();
    final progress = ref.read(progressProvider.notifier);
    _clock = PracticeClock(
      (s) => progress.addPracticeSeconds(PracticeCategory.recorder, s),
    );
    _playerDone = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingPath = null);
    });
    unawaited(_loadRiffs());
  }

  Future<void> _loadRiffs() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}${Platform.pathSeparator}riffs');
    await dir.create(recursive: true);
    final files =
        dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.wav'))
            .toList()
          ..sort((a, b) => b.path.compareTo(a.path));
    if (mounted) {
      setState(() {
        _riffDir = dir;
        _riffs = files;
      });
    }
  }

  @override
  void dispose() {
    _clock.commit();
    _elapsedTimer?.cancel();
    _levelTimer?.cancel();
    _playerDone?.cancel();
    unawaited(_recorder.dispose());
    unawaited(_player.dispose());
    super.dispose();
  }

  Future<void> _pollLevel() async {
    if (!_recording || !mounted) return;
    try {
      final amplitude = await _recorder.getAmplitude();
      // Map −45..0 dBFS to 0..1.
      final normalized = ((amplitude.current + 45) / 45)
          .clamp(0.0, 1.0)
          .toDouble();
      if (!mounted) return;
      setState(() {
        _levels.add(normalized);
        if (_levels.length > _levelBarCount) _levels.removeAt(0);
      });
    } catch (_) {
      /* amplitude polling is best-effort */
    }
  }

  // ------------------------------------------------------------ recording

  Future<void> _toggleRecording() async {
    if (_recording) {
      _elapsedTimer?.cancel();
      _levelTimer?.cancel();
      _levels.clear();
      await _recorder.stop();
      ref.read(progressProvider.notifier).incrementRiffCount();
      setState(() => _recording = false);
      await _loadRiffs();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.s.riffSaved)));
      }
      return;
    }

    if (!await _recorder.hasPermission()) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.s.micNeeded)));
      }
      return;
    }
    final dir = _riffDir ?? await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}${Platform.pathSeparator}'
        'riff_${DateTime.now().millisecondsSinceEpoch}.wav';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: path,
    );
    setState(() {
      _recording = true;
      _elapsedSeconds = 0;
    });
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
    _levelTimer = Timer.periodic(
      const Duration(milliseconds: 110),
      (_) => unawaited(_pollLevel()),
    );
  }

  // ------------------------------------------------------------- playback

  Future<void> _togglePlay(File file) async {
    if (_playingPath == file.path) {
      await _player.stop();
      setState(() => _playingPath = null);
      return;
    }
    await _player.stop();
    setState(() => _playingPath = file.path);
    await _player.play(DeviceFileSource(file.path));
  }

  Future<void> _delete(File file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.s.deleteRiffTitle,
          style: const TextStyle(fontSize: 17),
        ),
        content: Text(context.s.deleteRiffBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.s.delete,
              style: TextStyle(color: context.colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (_playingPath == file.path) await _player.stop();
    await file.delete();
    await _loadRiffs();
  }

  // ------------------------------------------------------------- analysis

  Future<void> _analyze(File file) async {
    setState(() => _analyzingPath = file.path);
    List<String> notes = const [];
    try {
      final bytes = await file.readAsBytes();
      notes = await Isolate.run(() => analyzeRiffNotes(bytes));
    } catch (_) {
      notes = const [];
    }
    if (!mounted) return;
    setState(() => _analyzingPath = null);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surfaceDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.s.aiAnalysis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              notes.isEmpty
                  ? context.s.noClearNotes
                  : context.s.notesDetected(notes.length),
              style: TextStyle(fontSize: 12, color: context.colors.creamDim),
            ),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final note in notes)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.blue.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        note,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.colors.blue,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------- UI

  String _riffSubtitle(File file) {
    final name = file.uri.pathSegments.last;
    final match = RegExp(r'riff_(\d+)\.wav').firstMatch(name);
    var label = '';
    if (match != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(
        int.parse(match.group(1)!),
      );
      label =
          '${date.day}/${date.month}/${date.year} · '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    }
    final seconds = ((file.lengthSync() - 44) / 88200).round();
    return '$label · ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return ScreenScaffold(
      gap: 16,
      children: [
        SubScreenHeader(title: s.riffRecorder),
        Text(
          s.riffSubtitle,
          style: TextStyle(fontSize: 13, color: context.colors.creamDim),
        ),

        // ------------------------------------------------ record card
        GlassCard(
          radius: 24,
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => unawaited(_toggleRecording()),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    gradient: _recording ? null : context.colors.buttonGradient,
                    color: _recording
                        ? context.colors.red.withValues(alpha: 0.9)
                        : null,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_recording
                                    ? context.colors.red
                                    : context.colors.orangeGradientBottom)
                                .withValues(alpha: 0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(
                    _recording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: context.colors.onOrange,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (_recording) ...[
                Text(
                  '${(_elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:'
                  '${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: context.colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                // Live input level meter.
                RepaintBoundary(
                  child: SizedBox(
                    height: 34,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _levelBarCount; i++)
                          Container(
                            width: 4,
                            height:
                                4 +
                                (i < _levels.length ? _levels[i] : 0.0) * 30,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: context.colors.red.withValues(
                                alpha: i < _levels.length ? 0.85 : 0.2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ] else
                Text(
                  s.tapToRecord,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.creamDim,
                  ),
                ),
            ],
          ),
        ),

        // ------------------------------------------------ riff list
        Text(
          s.savedRiffs,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        if (_riffs.isEmpty)
          Text(
            s.noRecordings,
            style: TextStyle(fontSize: 12, color: context.colors.creamFaint),
          )
        else
          Column(
            children: [
              for (var i = 0; i < _riffs.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                GlassCard(
                  radius: 20,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.colors.blue.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.graphic_eq_rounded,
                          color: context.colors.blue,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.riffN(_riffs.length - i),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _riffSubtitle(_riffs[i]),
                              style: TextStyle(
                                fontSize: 11,
                                color: context.colors.cream.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => unawaited(_togglePlay(_riffs[i])),
                        icon: Icon(
                          _playingPath == _riffs[i].path
                              ? Icons.stop_circle_outlined
                              : Icons.play_circle_outline_rounded,
                          color: context.colors.orangeLight,
                          size: 26,
                        ),
                      ),
                      GestureDetector(
                        onTap: _analyzingPath == null
                            ? () => unawaited(_analyze(_riffs[i]))
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.orange.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: context.colors.orange.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: _analyzingPath == _riffs[i].path
                              ? SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: context.colors.orangeLight,
                                  ),
                                )
                              : Text(
                                  'AI', // Universal abbreviation — no translation needed.
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.orangeLight,
                                  ),
                                ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => unawaited(_delete(_riffs[i])),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: context.colors.creamFaint,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}

/// Offline note extraction — top-level so it can run in an isolate.
List<String> analyzeRiffNotes(Uint8List bytes) {
  final decoded = WavCodec.decode(bytes);
  if (decoded == null) return const [];
  final samples = decoded.samples;
  final sampleRate = decoded.sampleRate;

  const window = 2048;
  const hop = 1024;
  final maxSamples = sampleRate * 30; // cap analysis at 30 s
  final limit = samples.length < maxSamples ? samples.length : maxSamples;

  final detector = YinDetector(sampleRate: sampleRate.toDouble());
  final notes = <String>[];
  String? last;
  for (var start = 0; start + window <= limit; start += hop) {
    final estimate = detector.estimate(samples.sublist(start, start + window));
    if (estimate == null || estimate.confidence < 0.9) continue;
    final pitch = NoteUtils.pitchFromFrequency(estimate.frequency);
    if (pitch == null) continue;
    if (pitch.label != last) {
      notes.add(pitch.label);
      last = pitch.label;
    }
  }
  return notes;
}
