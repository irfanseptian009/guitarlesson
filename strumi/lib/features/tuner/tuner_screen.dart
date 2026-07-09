import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_palette.dart';
import '../../core/audio/mic_service.dart';
import '../../core/dsp/fft.dart';
import '../../core/dsp/yin.dart';
import '../../core/i18n/strings.dart';
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
  final YinDetector _detector = YinDetector(
    sampleRate: MicService.sampleRate.toDouble(),
  );

  static const _holdToConfirm = Duration(milliseconds: 1200);

  Timer? _timer;
  bool _micDenied = false;

  /// Downsampled copy of the newest mic window for the waveform.
  Float64List? _wave;

  /// Low-bin FFT magnitudes for the spectrum bars.
  Float64List? _spectrum;
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
      (s) => progress.addPracticeSeconds(PracticeCategory.tuner, s),
    );
    unawaited(_startMic());
  }

  Future<void> _startMic() async {
    final ok = await _mic.start();
    if (!mounted) return;
    setState(() => _micDenied = !ok);
    if (ok) {
      _timer ??= Timer.periodic(
        const Duration(milliseconds: 120),
        (_) => _poll(),
      );
    }
  }

  void _poll() {
    final samples = _mic.latest(_window);
    if (samples == null || !mounted) return;

    // Feed the live visualizer regardless of pitch confidence.
    final wave = Float64List(_window ~/ 8);
    for (var i = 0; i < wave.length; i++) {
      wave[i] = samples[i * 8];
    }
    _wave = wave;
    final mags = Fft.magnitudeSpectrum(samples);
    // Guitar range lives in the first ~64 bins (0–1.4 kHz @ 44.1 kHz).
    _spectrum = Float64List.sublistView(mags, 0, 64);

    final estimate = _detector.estimate(samples);
    if (estimate == null ||
        estimate.confidence < 0.85 ||
        estimate.frequency < 55 ||
        estimate.frequency > 1000) {
      setState(() {});
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
          estimate.frequency,
          tuning.frequencyOf(i, a4: a4),
        ).abs();
        if (c < bestAbs) {
          bestAbs = c;
          best = i;
        }
      }
      target = best;
    }

    final cents = NoteUtils.centsBetween(
      estimate.frequency,
      tuning.frequencyOf(target, a4: a4),
    ).clamp(-50.0, 50.0);

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
    unawaited(
      ref
          .read(soundBankProvider)
          .playPluck(
            tuning.midiNotes[_activeString],
            a4: settings.a4Calibration,
          ),
    );
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
    final st = context.s;
    final tuning = kTunings[settings.tuningIndex];
    final a4 = settings.a4Calibration;
    final inTune = _isInTune;
    final noteName = kNoteNames[tuning.midiNotes[_activeString] % 12];

    final String status;
    final Color statusColor;
    if (!_hasSignal) {
      status = st.pluckString;
      statusColor = context.colors.creamDim;
    } else if (inTune) {
      status = st.inTuneMsg;
      statusColor = context.colors.green;
    } else if (_cents > 0) {
      status = st.slightlySharp;
      statusColor = context.colors.orangeLight;
    } else {
      status = st.slightlyFlat;
      statusColor = context.colors.orangeLight;
    }

    return ScreenScaffold(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tuner',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
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
              ? context.colors.green.withValues(alpha: 0.55)
              : context.colors.cardBorder,
          child: Column(
            children: [
              RepaintBoundary(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: _hasSignal ? _cents : 0),
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  builder: (context, cents, _) => CustomPaint(
                    size: const Size(260, 140),
                    painter: _GaugePainter(
                      cents: cents,
                      colors: context.colors,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                noteName,
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _confirmed ? st.lockedIn : status,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _confirmed ? context.colors.green : statusColor,
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
                  color: context.colors.cream.withValues(alpha: 0.5),
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
                        backgroundColor: context.colors.cream.withValues(
                          alpha: 0.10,
                        ),
                        valueColor: AlwaysStoppedAnimation(
                          context.colors.green,
                        ),
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
                    unawaited(
                      ref
                          .read(soundBankProvider)
                          .playPluck(tuning.midiNotes[i], a4: a4),
                    );
                  },
                ),
              ),
            ],
          ],
        ),

        // ------------------------------------------------ live sound viz
        _LiveSoundCard(
          wave: _wave,
          spectrum: _spectrum,
          active: _hasSignal,
          inTune: inTune,
        ),

        // ------------------------------------------------ preset card
        GlassCard(
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          onTap: () {
            ref
                .read(settingsProvider.notifier)
                .update(
                  (s) => s.copyWith(
                    tuningIndex: (s.tuningIndex + 1) % kTunings.length,
                  ),
                );
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
                  Text(
                    st.tuningPreset,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    kTunings.map((t) => t.name).join(' · '),
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.cream.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              Text(
                '${tuning.name} ›',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.colors.orangeLight,
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
    final color = denied ? context.colors.red : context.colors.blue;
    final label = denied
        ? context.s.micOffTap
        : manualNote != null
        ? '${context.s.manual} · $manualNote'
        : context.s.autoMicActive;
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
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
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
          color: active
              ? context.colors.cardFillActive
              : context.colors.cardFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active
                ? context.colors.cardBorderActive
                : context.colors.cardBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              note,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: active
                    ? context.colors.orangeLight
                    : context.colors.cream,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              hz,
              style: TextStyle(
                fontSize: 9,
                fontFamily: 'monospace',
                color: context.colors.creamFaint,
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
  _GaugePainter({required this.cents, required this.colors});

  final double cents;
  final AppPalette colors;

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
    arcPaint.color = colors.orange.withValues(alpha: 0.55);
    canvas.drawArc(rect, math.pi, math.pi / 3, false, arcPaint);
    arcPaint.color = colors.green.withValues(alpha: 0.75);
    canvas.drawArc(rect, math.pi + math.pi / 3, math.pi / 3, false, arcPaint);
    arcPaint.color = colors.blue.withValues(alpha: 0.55);
    canvas.drawArc(
      rect,
      math.pi + 2 * math.pi / 3,
      math.pi / 3,
      false,
      arcPaint,
    );

    // Needle: rotates ±85° for ±50 cents.
    final angle = (cents * 1.7) * math.pi / 180;
    final needlePaint = Paint()
      ..color = colors.cream
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);
    final tip =
        center + Offset(math.sin(angle), -math.cos(angle)) * (radius - stroke);
    canvas.drawLine(center, tip, needlePaint);

    // Hub.
    canvas.drawCircle(center, 11, Paint()..color = colors.orange);
    canvas.drawCircle(
      center,
      11,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = colors.surfaceDeep,
    );

    // Scale labels.
    void label(String text, Offset offset) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'monospace',
            color: colors.cream.withValues(alpha: 0.4),
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
      oldDelegate.cents != cents || oldDelegate.colors != colors;
}

/// Navy "studio" card with a live waveform and FFT spectrum of the mic —
/// keeps the tuner feeling alive below the gauge.
class _LiveSoundCard extends StatelessWidget {
  const _LiveSoundCard({
    required this.wave,
    required this.spectrum,
    required this.active,
    required this.inTune,
  });

  final Float64List? wave;
  final Float64List? spectrum;
  final bool active;
  final bool inTune;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = inTune ? colors.green : colors.yellow;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        color: colors.navy,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? colors.pinkStrong : colors.creamGhost,
                    shape: BoxShape.circle,
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: colors.pinkStrong.withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  context.s.liveSound,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: colors.onNavy,
                  ),
                ),
                const Spacer(),
                Text(
                  context.s.waveform.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                    color: colors.onNavy.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            RepaintBoundary(
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: CustomPaint(
                  painter: _WaveformPainter(
                    wave: active ? wave : null,
                    color: accent,
                    faint: colors.onNavy.withValues(alpha: 0.22),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.s.spectrum.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                    color: colors.onNavy.withValues(alpha: 0.45),
                  ),
                ),
                Text(
                  '82 Hz — 1.4 kHz',
                  style: TextStyle(
                    fontSize: 9,
                    fontFamily: 'monospace',
                    color: colors.onNavy.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            RepaintBoundary(
              child: SizedBox(
                height: 44,
                width: double.infinity,
                child: CustomPaint(
                  painter: _SpectrumPainter(
                    spectrum: active ? spectrum : null,
                    low: colors.blue,
                    high: colors.pinkStrong,
                    faint: colors.onNavy.withValues(alpha: 0.14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Oscilloscope-style waveform line.
class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.wave,
    required this.color,
    required this.faint,
  });

  final Float64List? wave;
  final Color color;
  final Color faint;

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final baseline = Paint()
      ..color = faint
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), baseline);

    final w = wave;
    if (w == null || w.isEmpty) return;

    // Normalize so quiet playing still shows a visible wave.
    var peak = 0.0;
    for (final v in w) {
      final a = v.abs();
      if (a > peak) peak = a;
    }
    final gain = peak < 0.02 ? 0.0 : (0.92 / peak).clamp(1.0, 30.0);

    final path = Path();
    for (var i = 0; i < w.length; i++) {
      final x = i / (w.length - 1) * size.width;
      final y = midY - (w[i] * gain).clamp(-1.0, 1.0) * midY;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => true;
}

/// Frequency bars, blue lows blending into pink highs.
class _SpectrumPainter extends CustomPainter {
  _SpectrumPainter({
    required this.spectrum,
    required this.low,
    required this.high,
    required this.faint,
  });

  final Float64List? spectrum;
  final Color low;
  final Color high;
  final Color faint;

  static const _bars = 32;

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / _bars;
    final paint = Paint();
    final mags = spectrum;

    double magOf(int bar) {
      if (mags == null || mags.isEmpty) return 0;
      final per = mags.length / _bars;
      var sum = 0.0;
      final from = (bar * per).floor();
      final to = math.max(from + 1, ((bar + 1) * per).floor());
      for (var i = from; i < to && i < mags.length; i++) {
        sum += mags[i];
      }
      return sum / (to - from);
    }

    var peak = 1e-9;
    final values = List<double>.generate(_bars, magOf);
    for (final v in values) {
      if (v > peak) peak = v;
    }

    for (var i = 0; i < _bars; i++) {
      final t = i / (_bars - 1);
      // Log-ish scaling reads better than linear for audio.
      final level = mags == null
          ? 0.0
          : (math.log(1 + 9 * values[i] / peak) / math.log(10)).clamp(0.0, 1.0);
      final barHeight = math.max(2.5, level * size.height);
      paint.color = mags == null
          ? faint
          : Color.lerp(low, high, t)!.withValues(alpha: 0.35 + 0.65 * level);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * barWidth + barWidth * 0.18,
          size.height - barHeight,
          barWidth * 0.64,
          barHeight,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpectrumPainter oldDelegate) => true;
}
