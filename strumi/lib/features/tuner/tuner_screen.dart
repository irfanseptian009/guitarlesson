import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../core/audio/mic_service.dart';
import '../../core/dsp/yin.dart';
import '../../core/music/note_utils.dart';
import '../../core/music/tunings.dart';
import '../../core/utils/practice_clock.dart';
import '../../data/models/progress_state.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/screen_scaffold.dart';

/// Real chromatic tuner: microphone → YIN pitch detection → needle gauge,
/// with per-string targets, reference tones, presets and A4 calibration.
class TunerScreen extends ConsumerStatefulWidget {
  const TunerScreen({super.key});

  @override
  ConsumerState<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends ConsumerState<TunerScreen> {
  static const _window = 2048;

  late final MicService _mic;
  late final PracticeClock _clock;
  final YinDetector _detector =
      YinDetector(sampleRate: MicService.sampleRate.toDouble());

  static const _holdToConfirm = Duration(milliseconds: 1200);

  Timer? _timer;
  bool _micDenied = false;
  int? _manualString;
  int _activeString = 0;
  double _cents = 0;
  double? _frequency;
  DateTime _lastSignal = DateTime.fromMillisecondsSinceEpoch(0);

  /// Hold-to-confirm: how long the string has been continuously in tune.
  DateTime? _inTuneSince;
  bool _confirmed = false;

  bool get _hasSignal =>
      DateTime.now().difference(_lastSignal).inMilliseconds < 1200;

  bool get _isInTune => _hasSignal && _cents.abs() <= 5;

  double get _holdProgress {
    final since = _inTuneSince;
    if (since == null) return 0;
    return (DateTime.now().difference(since).inMilliseconds /
            _holdToConfirm.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _mic = ref.read(micServiceProvider);
    final progress = ref.read(progressProvider.notifier);
    _clock = PracticeClock(
        (s) => progress.addPracticeSeconds(PracticeCategory.tuner, s));
    unawaited(_startMic());
  }

  Future<void> _startMic() async {
    final ok = await _mic.start();
    if (!mounted) return;
    setState(() => _micDenied = !ok);
    if (ok) {
      _timer ??=
          Timer.periodic(const Duration(milliseconds: 120), (_) => _poll());
    }
  }

  void _poll() {
    final samples = _mic.latest(_window);
    if (samples == null || !mounted) return;
    final estimate = _detector.estimate(samples);
    if (estimate == null ||
        estimate.confidence < 0.85 ||
        estimate.frequency < 55 ||
        estimate.frequency > 1000) {
      if (!_hasSignal) setState(() {});
      return;
    }

    final settings = ref.read(settingsProvider);
    final tuning = kTunings[settings.tuningIndex];
    final a4 = settings.a4Calibration;

    var target = _manualString;
    if (target == null) {
      var best = 0;
      var bestAbs = double.infinity;
      for (var i = 0; i < 6; i++) {
        final c = NoteUtils.centsBetween(
                estimate.frequency, tuning.frequencyOf(i, a4: a4))
            .abs();
        if (c < bestAbs) {
          bestAbs = c;
          best = i;
        }
      }
      target = best;
    }

    final cents = NoteUtils.centsBetween(
            estimate.frequency, tuning.frequencyOf(target, a4: a4))
        .clamp(-50.0, 50.0);

    setState(() {
      _activeString = target!;
      _cents = _cents * 0.65 + cents * 0.35;
      _frequency = estimate.frequency;
      _lastSignal = DateTime.now();
    });
    _trackInTune();
  }

  /// Confirms a string after ~1.2 s continuously in tune: haptic + chime,
  /// and in manual mode auto-advances to the next string.
  void _trackInTune() {
    if (!_isInTune) {
      _inTuneSince = null;
      _confirmed = false;
      return;
    }
    _inTuneSince ??= DateTime.now();
    if (_confirmed || _holdProgress < 1) return;
    _confirmed = true;
    HapticFeedback.mediumImpact();
    final settings = ref.read(settingsProvider);
    final tuning = kTunings[settings.tuningIndex];
    unawaited(ref.read(soundBankProvider).playPluck(
        tuning.midiNotes[_activeString],
        a4: settings.a4Calibration));
    if (_manualString != null) {
      Timer(const Duration(milliseconds: 700), () {
        if (!mounted || _manualString == null) return;
        setState(() {
          _manualString = (_manualString! + 1) % 6;
          _activeString = _manualString!;
          _inTuneSince = null;
          _confirmed = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _clock.commit();
    unawaited(_mic.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final tuning = kTunings[settings.tuningIndex];
    final a4 = settings.a4Calibration;
    final inTune = _isInTune;
    final noteName = kNoteNames[tuning.midiNotes[_activeString] % 12];

    final String status;
    final Color statusColor;
    if (!_hasSignal) {
      status = 'Petik senar…';
      statusColor = AppColors.creamDim;
    } else if (inTune) {
      status = 'Pas! Senar sudah setem';
      statusColor = AppColors.green;
    } else if (_cents > 0) {
      status = 'Sedikit tinggi — kendurkan';
      statusColor = AppColors.orangeLight;
    } else {
      status = 'Sedikit rendah — kencangkan';
      statusColor = AppColors.orangeLight;
    }

    return ScreenScaffold(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tuner',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            _StatusBadge(
              denied: _micDenied,
              manualNote: _manualString == null
                  ? null
                  : tuning.labels[_manualString!],
              onTap: () {
                if (_micDenied) {
                  unawaited(_startMic());
                } else {
                  setState(() => _manualString = null);
                }
              },
            ),
          ],
        ),

        // ------------------------------------------------ gauge card
        GlassCard(
          radius: 26,
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
          border: inTune
              ? AppColors.green.withValues(alpha: 0.55)
              : AppColors.cardBorder,
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(end: _hasSignal ? _cents : 0),
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                builder: (context, cents, _) => CustomPaint(
                  size: const Size(260, 140),
                  painter: _GaugePainter(cents: cents),
                ),
              ),
              const SizedBox(height: 6),
              Text(noteName,
                  style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      height: 1)),
              const SizedBox(height: 6),
              Text(
                _confirmed ? 'Terkunci ✓ — senar pas!' : status,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _confirmed ? AppColors.green : statusColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _hasSignal && _frequency != null
                    ? '${_cents >= 0 ? '+' : ''}${_cents.round()} cents · '
                        '${_frequency!.toStringAsFixed(1)} Hz'
                    : '— cents · — Hz',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: AppColors.cream.withValues(alpha: 0.5),
                ),
              ),
              // Hold-to-confirm progress while the needle sits in the
              // green zone.
              AnimatedOpacity(
                opacity: inTune && !_confirmed ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: SizedBox(
                      width: 140,
                      child: LinearProgressIndicator(
                        value: _holdProgress,
                        minHeight: 4,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.10),
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.green),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ------------------------------------------------ string buttons
        Row(
          children: [
            for (var i = 0; i < 6; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _StringButton(
                  note: kNoteNames[tuning.midiNotes[i] % 12],
                  hz: tuning.frequencyOf(i, a4: a4).toStringAsFixed(1),
                  active: _activeString == i,
                  onTap: () {
                    setState(() {
                      _manualString = i;
                      _activeString = i;
                      _inTuneSince = null;
                      _confirmed = false;
                    });
                    unawaited(ref
                        .read(soundBankProvider)
                        .playPluck(tuning.midiNotes[i], a4: a4));
                  },
                ),
              ),
            ],
          ],
        ),

        // ------------------------------------------------ preset card
        GlassCard(
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          onTap: () {
            ref.read(settingsProvider.notifier).update((s) => s.copyWith(
                tuningIndex: (s.tuningIndex + 1) % kTunings.length));
            setState(() {
              _manualString = null;
              _inTuneSince = null;
              _confirmed = false;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tuning preset',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    kTunings.map((t) => t.name).join(' · '),
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.cream.withValues(alpha: 0.5)),
                  ),
                ],
              ),
              Text(
                '${tuning.name} ›',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orangeLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.denied,
    required this.manualNote,
    required this.onTap,
  });

  final bool denied;
  final String? manualNote;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = denied ? AppColors.red : AppColors.blue;
    final label = denied
        ? 'Mic mati · ketuk'
        : manualNote != null
            ? 'Manual · $manualNote'
            : 'Auto · mic aktif';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _StringButton extends StatelessWidget {
  const _StringButton({
    required this.note,
    required this.hz,
    required this.active,
    required this.onTap,
  });

  final String note;
  final String hz;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 62,
        decoration: BoxDecoration(
          color: active ? AppColors.cardFillActive : AppColors.cardFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color:
                  active ? AppColors.cardBorderActive : AppColors.cardBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              note,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: active ? AppColors.orangeLight : AppColors.cream,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              hz,
              style: TextStyle(
                fontSize: 9,
                fontFamily: 'monospace',
                color: AppColors.creamFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Semicircular tuner gauge: orange/green/blue arc, glowing needle, hub.
class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.cents});

  final double cents;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;
    const stroke = 16.0;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Left (flat), middle (in tune), right (sharp) — as in the design.
    arcPaint.color = AppColors.orange.withValues(alpha: 0.55);
    canvas.drawArc(rect, math.pi, math.pi / 3, false, arcPaint);
    arcPaint.color = AppColors.green.withValues(alpha: 0.75);
    canvas.drawArc(rect, math.pi + math.pi / 3, math.pi / 3, false, arcPaint);
    arcPaint.color = AppColors.blue.withValues(alpha: 0.55);
    canvas.drawArc(
        rect, math.pi + 2 * math.pi / 3, math.pi / 3, false, arcPaint);

    // Needle: rotates ±85° for ±50 cents.
    final angle = (cents * 1.7) * math.pi / 180;
    final needlePaint = Paint()
      ..color = AppColors.cream
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);
    final tip = center +
        Offset(math.sin(angle), -math.cos(angle)) * (radius - stroke);
    canvas.drawLine(center, tip, needlePaint);

    // Hub.
    canvas.drawCircle(
      center,
      11,
      Paint()..color = AppColors.orange,
    );
    canvas.drawCircle(
      center,
      11,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = AppColors.surfaceDeep,
    );

    // Scale labels.
    void label(String text, Offset offset) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'monospace',
            color: AppColors.cream.withValues(alpha: 0.4),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, offset - Offset(painter.width / 2, 0));
    }

    label('0', Offset(size.width / 2, 0));
    label('-50', Offset(16, size.height - 14));
    label('+50', Offset(size.width - 16, size.height - 14));
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.cents != cents;
}
