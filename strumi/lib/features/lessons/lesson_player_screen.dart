import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../core/audio/chord_listener.dart';
import '../../core/audio/sound_bank.dart';
import '../../core/dsp/chroma.dart';
import '../../core/music/chords.dart';
import '../../core/utils/practice_clock.dart';
import '../../data/catalogs/lessons_catalog.dart';
import '../../data/models/lesson.dart';
import '../../data/models/progress_state.dart';
import '../../providers/app_providers.dart';
import '../../widgets/celebration.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_scaffold.dart';
import '../chords/widgets/chord_diagram.dart';

enum _AiStatus { idle, listening, done }

/// Lesson player: chord demo panel, slow-downer, interactive tab with a
/// moving playhead, theory notes, and a real AI practice loop that listens
/// to the guitar and scores every strum.
class LessonPlayerScreen extends ConsumerStatefulWidget {
  const LessonPlayerScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonPlayerScreen> createState() =>
      _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen>
    with TickerProviderStateMixin {
  late final Lesson _lesson = lessonById(widget.lessonId);

  // Demo panel.
  Timer? _demoTimer;
  bool _demoPlaying = false;
  int _demoIndex = 0;
  AnimationController? _demoProgress;

  // Tab playhead.
  AnimationController? _playhead;

  // Slow-downer.
  double _speed = 1.0;

  // AI practice.
  late final ChordListener _listener;
  late final ProgressNotifier _progress;
  late final SoundBank _soundBank;
  late final PracticeClock _clock;
  _AiStatus _status = _AiStatus.idle;
  int _targetIndex = 0;
  final List<double> _repScores = [];
  final List<DateTime> _repTimes = [];
  final Map<String, List<double>> _scoresPerChord = {};
  String? _wrongChord;
  int get _totalReps => _lesson.practiceChords.length * 4;

  @override
  void initState() {
    super.initState();
    _progress = ref.read(progressProvider.notifier);
    _soundBank = ref.read(soundBankProvider);
    _clock = PracticeClock(
        (s) => _progress.addPracticeSeconds(PracticeCategory.lesson, s));
    _listener = ChordListener(
      ref.read(micServiceProvider),
      onStable: _onChordDetected,
      onFrame: (_) {},
    );
    if (_lesson.tab != null) {
      _playhead = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: (6000 / _speed).round()),
      )..repeat();
    }
    if (_lesson.practiceChords.isNotEmpty) {
      _demoProgress = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: (2400 / _speed).round()),
      );
      _startDemo();
    }
  }

  @override
  void dispose() {
    _clock.commit();
    if (_status == _AiStatus.listening && _repScores.isNotEmpty) {
      _progress.setLessonProgress(
          _lesson.id, _repScores.length / _totalReps);
    }
    unawaited(_listener.stop());
    _demoTimer?.cancel();
    _demoProgress?.dispose();
    _playhead?.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- demo

  void _startDemo() {
    _demoPlaying = true;
    _demoProgress?.repeat();
    _demoTimer?.cancel();
    _demoTimer = Timer.periodic(
      Duration(milliseconds: (2400 / _speed).round()),
      (_) => setState(() =>
          _demoIndex = (_demoIndex + 1) % _lesson.practiceChords.length),
    );
  }

  void _stopDemo() {
    _demoPlaying = false;
    _demoTimer?.cancel();
    _demoProgress?.stop();
  }

  void _setSpeed(double speed) {
    setState(() => _speed = speed);
    _playhead?.duration = Duration(milliseconds: (6000 / speed).round());
    if (_playhead?.isAnimating ?? false) _playhead!.repeat();
    _demoProgress?.duration =
        Duration(milliseconds: (2400 / speed).round());
    if (_demoPlaying) _startDemo();
  }

  // ------------------------------------------------------- AI practice

  String get _targetChord =>
      _lesson.practiceChords[_targetIndex % _lesson.practiceChords.length];

  Future<void> _togglePractice() async {
    if (_status == _AiStatus.listening) {
      await _listener.stop();
      if (_repScores.isNotEmpty) {
        _progress.setLessonProgress(
            _lesson.id, _repScores.length / _totalReps);
      }
      setState(() => _status = _AiStatus.idle);
      return;
    }
    final ok = await _listener.start();
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Izin mikrofon dibutuhkan untuk AI feedback.')));
      }
      return;
    }
    setState(() {
      _status = _AiStatus.listening;
      _targetIndex = 0;
      _repScores.clear();
      _repTimes.clear();
      _scoresPerChord.clear();
      _wrongChord = null;
    });
  }

  void _onChordDetected(ChordMatch match) {
    if (_status != _AiStatus.listening || !mounted) return;
    final name = match.chord.name;
    if (name == _targetChord) {
      final score = match.score * 100;
      _repScores.add(score);
      _repTimes.add(DateTime.now());
      _scoresPerChord.putIfAbsent(name, () => []).add(score);
      _soundBank.playDrum(DrumSample.clickHi, volume: 0.5);
      setState(() {
        _wrongChord = null;
        _targetIndex++;
      });
      if (_repScores.length >= _totalReps) _finishPractice();
    } else {
      setState(() => _wrongChord = name);
    }
  }

  Future<void> _finishPractice() async {
    await _listener.stop();
    final overall = _overallScore;
    _progress.logAccuracy(overall);
    _progress.recordLessonScore(_lesson.id, overall);
    _progress.setLessonProgress(_lesson.id, 1.0,
        xpOnComplete: _lesson.xpReward);
    for (final entry in _scoresPerChord.entries) {
      final mean =
          entry.value.reduce((a, b) => a + b) / entry.value.length;
      if (mean >= 70) _progress.masterChord(entry.key);
    }
    if (mounted) {
      setState(() => _status = _AiStatus.done);
      Celebration.show(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lesson selesai! +${_lesson.xpReward} XP 🎉')));
    }
  }

  // ------------------------------------------------------------ metrics

  double get _cleanliness => _repScores.isEmpty
      ? 0
      : _repScores.reduce((a, b) => a + b) / _repScores.length;

  double get _timing {
    if (_repTimes.length < 3) return 0;
    final intervals = <double>[
      for (var i = 1; i < _repTimes.length; i++)
        _repTimes[i].difference(_repTimes[i - 1]).inMilliseconds / 1000,
    ];
    final mean = intervals.reduce((a, b) => a + b) / intervals.length;
    if (mean <= 0) return 0;
    final variance = intervals
            .map((v) => (v - mean) * (v - mean))
            .reduce((a, b) => a + b) /
        intervals.length;
    final cv = math.sqrt(variance) / mean;
    return ((1 - cv).clamp(0.0, 1.0)) * 100;
  }

  double get _transition {
    if (_repTimes.length < 2) return 0;
    final intervals = <double>[
      for (var i = 1; i < _repTimes.length; i++)
        _repTimes[i].difference(_repTimes[i - 1]).inMilliseconds / 1000,
    ];
    final mean = intervals.reduce((a, b) => a + b) / intervals.length;
    if (mean <= 2) return 100;
    if (mean >= 6) return 40;
    return 100 - (mean - 2) / 4 * 60;
  }

  double get _overallScore {
    if (_repScores.isEmpty) return 0;
    return (0.5 * _cleanliness + 0.25 * _timing + 0.25 * _transition)
        .clamp(0, 100);
  }

  String get _tip {
    if (_status == _AiStatus.idle && _repScores.isEmpty) {
      return 'Tekan mulai, lalu mainkan chord target — AI memverifikasi '
          'tiap strum lewat mikrofon.';
    }
    if (_repScores.length < 2) {
      return 'Strum chord ${_targetChord.toUpperCase()} dengan mantap dan '
          'biarkan berbunyi sebentar.';
    }
    final weakest = [
      (_cleanliness, 'Tekan senar lebih mantap dan pastikan tiap nada bunyi '
          'bersih tanpa buzz.'),
      (_timing, 'Jaga jarak antar strum tetap rata — latih dengan metronome '
          '70 BPM.'),
      (_transition, 'Perlambat dulu perpindahan jari, lalu naikkan kecepatan '
          'bertahap.'),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    return 'Tip: ${weakest.first.$2}';
  }

  // ---------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final trackLessons = lessonsInTrack(_lesson.track);
    final number =
        (trackLessons.indexWhere((l) => l.id == _lesson.id) + 1)
            .toString()
            .padLeft(2, '0');

    return ScreenScaffold(
      gap: 16,
      children: [
        SubScreenHeader(
          overline: '${_lesson.track.label} · Lesson $number',
          title: _lesson.title,
        ),
        _buildDemoPanel(),
        if (_lesson.practiceChords.isNotEmpty) _buildSlowDowner(),
        if (_lesson.tab != null) _buildTab(),
        if (_lesson.theoryPoints.isNotEmpty) _buildTheory(),
        if (_lesson.hasAiPractice)
          _buildAiPanel()
        else
          _buildCompleteButton(),
      ],
    );
  }

  Widget _buildDemoPanel() {
    final chords = _lesson.practiceChords;
    return GlassCard(
      radius: 22,
      fill: Colors.white.withValues(alpha: 0.04),
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 196,
        child: chords.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.menu_book_rounded,
                        size: 40, color: AppColors.blue),
                    const SizedBox(height: 12),
                    Text(
                      _lesson.summary,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.creamDim),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 14,
                    child: Text(
                      'demo: ${chords.join(' – ')}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppColors.creamGhost,
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChordDiagram(
                          chord: chordByName(chords[_demoIndex]),
                          width: 96,
                          height: 114,
                        ),
                        const SizedBox(width: 22),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chords[_demoIndex],
                              style: const TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () => setState(
                                  _demoPlaying ? _stopDemo : _startDemo),
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: AppColors.buttonGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.orangeGradientBottom
                                          .withValues(alpha: 0.4),
                                      blurRadius: 26,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _demoPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: AppColors.onOrange,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_demoProgress != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AnimatedBuilder(
                        animation: _demoProgress!,
                        builder: (context, _) => ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(22)),
                          child: LinearProgressIndicator(
                            value: _demoProgress!.value,
                            minHeight: 4,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.12),
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.orange),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildSlowDowner() {
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Slow-downer',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.cream.withValues(alpha: 0.7),
            ),
          ),
          Row(
            children: [
              for (final speed in [0.5, 0.75, 1.0]) ...[
                GestureDetector(
                  onTap: () => _setSpeed(speed),
                  child: Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 7),
                    decoration: BoxDecoration(
                      color: _speed == speed
                          ? AppColors.orange
                          : Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      speed == 1.0 ? '1x' : '${speed}x',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _speed == speed
                            ? AppColors.onOrange
                            : AppColors.cream.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab() {
    final tab = _lesson.tab!;
    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tab interaktif',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              Text(
                'auto-scroll aktif',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      for (var i = 0; i < tab.length; i++) ...[
                        if (i > 0) const SizedBox(height: 11),
                        SizedBox(
                          height: 14,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.cream
                                      .withValues(alpha: 0.25),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  child: Text(
                                    tab[i].string,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                      color: AppColors.creamFaint,
                                    ),
                                  ),
                                ),
                                for (final note in tab[i].notes)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(right: 26),
                                    child: Text(
                                      note,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_playhead != null)
                  AnimatedBuilder(
                    animation: _playhead!,
                    builder: (context, _) => Positioned(
                      left: _playhead!.value * (constraints.maxWidth - 2),
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(1),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.orange.withValues(alpha: 0.7),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTheory() {
    return GlassCard(
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _lesson.theoryPoints.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.orange, shape: BoxShape.circle),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _lesson.theoryPoints[i],
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.55,
                      color: AppColors.cream.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAiPanel() {
    final statusText = switch (_status) {
      _AiStatus.idle => 'siap',
      _AiStatus.listening => 'mendengarkan',
      _AiStatus.done => 'selesai',
    };
    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.all(18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.orange.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.04),
        ],
      ),
      border: AppColors.orange.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _PulsingDot(active: _status == _AiStatus.listening),
                  const SizedBox(width: 8),
                  Text('AI Feedback — $statusText',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_overallScore.round()}%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.orangeLight,
                    ),
                  ),
                  Builder(builder: (context) {
                    final best = ref
                            .watch(progressProvider)
                            .lessonBestScores[_lesson.id] ??
                        0;
                    if (best <= 0) return const SizedBox.shrink();
                    return Text(
                      'terbaik ${best.round()}%',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.creamFaint),
                    );
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('Mainkan:',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.creamDim)),
              const SizedBox(width: 12),
              ChordDiagram(
                chord: chordByName(_targetChord),
                width: 64,
                height: 76,
              ),
              const SizedBox(width: 12),
              Text(_targetChord,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800)),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rep ${_repScores.length}/$_totalReps',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blue,
                    ),
                  ),
                  if (_wrongChord != null)
                    Text(
                      'Terdeteksi: $_wrongChord',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.creamFaint),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MetricBar(
              label: 'Kebersihan',
              value: _cleanliness,
              color: AppColors.orange),
          const SizedBox(height: 9),
          _MetricBar(label: 'Timing', value: _timing, color: AppColors.blue),
          const SizedBox(height: 9),
          _MetricBar(
              label: 'Transisi', value: _transition, color: AppColors.yellow),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            child: Text(
              _tip,
              style: TextStyle(
                fontSize: 12,
                height: 1.55,
                color: AppColors.cream.withValues(alpha: 0.65),
              ),
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: _status == _AiStatus.listening
                ? 'BERHENTI'
                : 'MULAI LATIHAN AI',
            height: 46,
            fontSize: 13,
            onTap: _togglePracticeSafe,
          ),
        ],
      ),
    );
  }

  void _togglePracticeSafe() => unawaited(_togglePractice());

  Widget _buildCompleteButton() {
    final done = ref.watch(progressProvider).isLessonCompleted(_lesson.id);
    return PrimaryButton(
      label: done ? 'SUDAH SELESAI ✓' : 'TANDAI SELESAI',
      onTap: () {
        if (done) return;
        _progress.setLessonProgress(_lesson.id, 1.0,
            xpOnComplete: _lesson.xpReward);
        Celebration.show(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('+${_lesson.xpReward} XP 🎉')));
      },
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.cream.withValues(alpha: 0.6))),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 26,
          child: Text(
            '${value.round()}',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

/// Small orange dot that pulses while the AI is listening.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.active});

  final bool active;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
    lowerBound: 0.35,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.active
          ? _controller
          : const AlwaysStoppedAnimation(1.0),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.orange,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.orange.withValues(alpha: 0.8),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
