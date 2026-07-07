import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/music/chords.dart';

/// Fretboard chord diagram: nut, 4-fret grid, finger dots (with numbers),
/// barre bars, and open/mute markers — matching the design's mini grid.
class ChordDiagram extends StatelessWidget {
  const ChordDiagram({
    super.key,
    required this.chord,
    this.width = 110,
    this.height = 132,
    this.dotColor = AppColors.orange,
  });

  final ChordShape chord;
  final double width;
  final double height;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _DiagramPainter(chord, dotColor)),
    );
  }
}

class _DiagramPainter extends CustomPainter {
  _DiagramPainter(this.chord, this.dotColor);

  final ChordShape chord;
  final Color dotColor;

  static const int _fretRows = 4;

  @override
  void paint(Canvas canvas, Size size) {
    const markerSpace = 16.0;
    const nutHeight = 4.0;
    final gridTop = markerSpace + nutHeight;
    final gridHeight = size.height - gridTop;
    final stringGap = size.width / 5;
    final fretGap = gridHeight / _fretRows;

    final linePaint = Paint()
      ..color = AppColors.cream.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    // Nut.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, markerSpace, size.width, nutHeight),
        const Radius.circular(2),
      ),
      Paint()..color = AppColors.cream,
    );

    // Strings (vertical) and frets (horizontal).
    for (var s = 0; s < 6; s++) {
      final x = s * stringGap;
      canvas.drawLine(Offset(x, gridTop), Offset(x, size.height), linePaint);
    }
    for (var f = 1; f <= _fretRows; f++) {
      final y = gridTop + f * fretGap;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Open / mute markers above the nut.
    for (var s = 0; s < 6; s++) {
      final x = s * stringGap;
      final fret = chord.frets[s];
      if (fret == 0) {
        canvas.drawCircle(
          Offset(x, markerSpace / 2),
          3.5,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color = AppColors.cream.withValues(alpha: 0.7),
        );
      } else if (fret < 0) {
        final paint = Paint()
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..color = AppColors.cream.withValues(alpha: 0.45);
        const r = 3.2;
        final c = Offset(x, markerSpace / 2);
        canvas.drawLine(c.translate(-r, -r), c.translate(r, r), paint);
        canvas.drawLine(c.translate(-r, r), c.translate(r, -r), paint);
      }
    }

    // Barre bars: same finger on the same fret across 2+ strings.
    final barrePaint = Paint()..color = dotColor.withValues(alpha: 0.85);
    final drawnBarres = <String>{};
    for (var s = 0; s < 6; s++) {
      final finger = chord.fingers[s];
      final fret = chord.frets[s];
      if (finger <= 0 || fret <= 0) continue;
      final key = '$finger-$fret';
      if (drawnBarres.contains(key)) continue;
      final matches = [
        for (var t = 0; t < 6; t++)
          if (chord.fingers[t] == finger && chord.frets[t] == fret) t,
      ];
      if (matches.length < 2) continue;
      drawnBarres.add(key);
      final y = gridTop + (fret - 0.5) * fretGap;
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
    for (var s = 0; s < 6; s++) {
      final fret = chord.frets[s];
      final finger = chord.fingers[s];
      if (fret <= 0) continue;
      final center =
          Offset(s * stringGap, gridTop + (fret - 0.5) * fretGap);
      canvas.drawCircle(center, 8.5, Paint()..color = dotColor);
      if (finger > 0) {
        final painter = TextPainter(
          text: TextSpan(
            text: '$finger',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.onOrange,
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
      oldDelegate.chord != chord || oldDelegate.dotColor != dotColor;
}
