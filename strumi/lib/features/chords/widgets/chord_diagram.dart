import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../core/music/chords.dart';

/// Fretboard chord diagram: nut, 4-fret grid, finger dots (with numbers),
/// barre bars, and open/mute markers — matching the design's mini grid.
class ChordDiagram extends StatelessWidget {
  const ChordDiagram({
    super.key,
    required this.chord,
    this.width = 110,
    this.height = 132,
    this.dotColor,
  });

  final ChordShape chord;
  final double width;
  final double height;

  /// Defaults to the theme orange when not given.
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _DiagramPainter(
          chord,
          dotColor ?? colors.orange,
          ink: colors.cream,
          onDot: colors.onOrange,
        ),
      ),
    );
  }
}

class _DiagramPainter extends CustomPainter {
  _DiagramPainter(this.chord, this.dotColor,
      {required this.ink, required this.onDot});

  final ChordShape chord;
  final Color dotColor;
  final Color ink;
  final Color onDot;

  static const int _fretRows = 4;

  @override
  void paint(Canvas canvas, Size size) {
    const markerSpace = 16.0;
    const nutHeight = 4.0;
    final n = chord.stringCount;
    final gridTop = markerSpace + nutHeight;
    final gridHeight = size.height - gridTop;
    final stringGap = size.width / (n - 1);
    final fretGap = gridHeight / _fretRows;

    // High voicings (e.g. barre at fret 3+) shift the window and get a
    // "3fr" position label instead of the nut.
    var maxFret = 0;
    var minFret = 99;
    for (final f in chord.frets) {
      if (f > 0) {
        if (f > maxFret) maxFret = f;
        if (f < minFret) minFret = f;
      }
    }
    final baseFret = maxFret > _fretRows ? minFret : 1;
    double rowOf(int fret) => (fret - baseFret + 0.5);

    final linePaint = Paint()
      ..color = ink.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    // Nut (only when the window starts at the actual nut).
    if (baseFret == 1) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, markerSpace, size.width, nutHeight),
          const Radius.circular(2),
        ),
        Paint()..color = ink,
      );
    } else {
      canvas.drawLine(Offset(0, gridTop), Offset(size.width, gridTop),
          linePaint..strokeWidth = 1.6);
      linePaint.strokeWidth = 1;
      final label = TextPainter(
        text: TextSpan(
          text: '${baseFret}fr',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: ink.withValues(alpha: 0.6),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(size.width - label.width, 1));
    }

    // Strings (vertical) and frets (horizontal).
    for (var s = 0; s < n; s++) {
      final x = s * stringGap;
      canvas.drawLine(Offset(x, gridTop), Offset(x, size.height), linePaint);
    }
    for (var f = 1; f <= _fretRows; f++) {
      final y = gridTop + f * fretGap;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Open / mute markers above the nut.
    for (var s = 0; s < n; s++) {
      final x = s * stringGap;
      final fret = chord.frets[s];
      if (fret == 0) {
        canvas.drawCircle(
          Offset(x, markerSpace / 2),
          3.5,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color = ink.withValues(alpha: 0.7),
        );
      } else if (fret < 0) {
        final paint = Paint()
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..color = ink.withValues(alpha: 0.45);
        const r = 3.2;
        final c = Offset(x, markerSpace / 2);
        canvas.drawLine(c.translate(-r, -r), c.translate(r, r), paint);
        canvas.drawLine(c.translate(-r, r), c.translate(r, -r), paint);
      }
    }

    // Barre bars: same finger on the same fret across 2+ strings.
    final barrePaint = Paint()..color = dotColor.withValues(alpha: 0.85);
    final drawnBarres = <String>{};
    for (var s = 0; s < n; s++) {
      final finger = chord.fingers[s];
      final fret = chord.frets[s];
      if (finger <= 0 || fret <= 0) continue;
      final key = '$finger-$fret';
      if (drawnBarres.contains(key)) continue;
      final matches = [
        for (var t = 0; t < n; t++)
          if (chord.fingers[t] == finger && chord.frets[t] == fret) t,
      ];
      if (matches.length < 2) continue;
      drawnBarres.add(key);
      final y = gridTop + rowOf(fret) * fretGap;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            matches.first * stringGap - 6,
            y - 6,
            matches.last * stringGap + 6,
            y + 6,
          ),
          const Radius.circular(6),
        ),
        barrePaint,
      );
    }

    // Finger dots + numbers.
    for (var s = 0; s < n; s++) {
      final fret = chord.frets[s];
      final finger = chord.fingers[s];
      if (fret <= 0) continue;
      final center =
          Offset(s * stringGap, gridTop + rowOf(fret) * fretGap);
      canvas.drawCircle(center, 8.5, Paint()..color = dotColor);
      if (finger > 0) {
        final painter = TextPainter(
          text: TextSpan(
            text: '$finger',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: onDot,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        painter.paint(
          canvas,
          center - Offset(painter.width / 2, painter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DiagramPainter oldDelegate) =>
      oldDelegate.chord != chord ||
      oldDelegate.dotColor != dotColor ||
      oldDelegate.ink != ink;
}
