import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/music/guitars.dart';

/// Playful-geometric decorations shared by the Capi-style screens:
/// zigzag trims, four-point sparkles and the stylised guitar illustration.

/// Row of upward-pointing triangles, used as the bottom trim of the navy
/// lesson cards (the design's pink zigzag edge).
class ZigzagTrim extends StatelessWidget {
  const ZigzagTrim({
    super.key,
    required this.color,
    this.height = 10,
    this.toothWidth = 14,
  });

  final Color color;
  final double height;
  final double toothWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _ZigzagPainter(color: color, toothWidth: toothWidth),
      ),
    );
  }
}

class _ZigzagPainter extends CustomPainter {
  _ZigzagPainter({required this.color, required this.toothWidth});

  final Color color;
  final double toothWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()..moveTo(0, size.height);
    var x = 0.0;
    while (x < size.width) {
      path.lineTo(x + toothWidth / 2, 0);
      path.lineTo(math.min(x + toothWidth, size.width), size.height);
      x += toothWidth;
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ZigzagPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.toothWidth != toothWidth;
}

/// Four-point sparkle star (the ✦ accent scattered around the design).
class Sparkle extends StatelessWidget {
  const Sparkle({super.key, required this.color, this.size = 16});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SparklePainter(color)),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final pinch = 0.18; // how thin the star waist is
    final path = Path()
      ..moveTo(w / 2, 0)
      ..quadraticBezierTo(w / 2 + w * pinch / 2, h / 2 - h * pinch / 2, w, h / 2)
      ..quadraticBezierTo(w / 2 + w * pinch / 2, h / 2 + h * pinch / 2, w / 2, h)
      ..quadraticBezierTo(w / 2 - w * pinch / 2, h / 2 + h * pinch / 2, 0, h / 2)
      ..quadraticBezierTo(w / 2 - w * pinch / 2, h / 2 - h * pinch / 2, w / 2, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Stylised instrument on a sun-yellow blob — the hero illustration from
/// the Capi design. Draws a different silhouette per [GuitarKind]:
/// steel/nylon acoustic, electric, bass, or ukulele.
class GuitarIllustration extends StatelessWidget {
  const GuitarIllustration({
    super.key,
    this.width = 110,
    this.height = 150,
    this.kind = GuitarKind.acousticSteel,
    required this.blobColor,
    required this.bodyColor,
    this.shadowColor = const Color(0x33232B54),
  });

  final double width;
  final double height;
  final GuitarKind kind;
  final Color blobColor;
  final Color bodyColor;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    final asset = kind.assetPath;
    if (asset == null) {
      // No illustrated PNG for this kind yet (bass) — hand-drawn fallback.
      return SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _GuitarPainter(
            kind: kind,
            blobColor: blobColor,
            bodyColor: bodyColor,
            shadowColor: shadowColor,
          ),
        ),
      );
    }
    // Same blob placement the vector art used, so switching kinds doesn't
    // jump the composition around.
    final blobScale = kind == GuitarKind.ukulele ? 0.34 : 0.40;
    final blobDiameter = width * blobScale * 2;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: width * 0.40 - blobDiameter / 2,
            top: height * 0.62 - blobDiameter / 2,
            child: Container(
              width: blobDiameter,
              height: blobDiameter,
              decoration: BoxDecoration(color: blobColor, shape: BoxShape.circle),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(width * 0.05),
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
                // Source PNGs are up to ~4000px square; decoding at the
                // widget's actual physical size keeps this lightweight
                // even when several illustrations are on screen together
                // (guitar picker sheet, onboarding strip).
                cacheWidth:
                    (width * MediaQuery.devicePixelRatioOf(context)).round(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuitarPainter extends CustomPainter {
  _GuitarPainter({
    required this.kind,
    required this.blobColor,
    required this.bodyColor,
    required this.shadowColor,
  });

  final GuitarKind kind;
  final Color blobColor;
  final Color bodyColor;
  final Color shadowColor;

  static const _neck = Color(0xFF8A5A38);
  static const _neckDark = Color(0xFF6E4529);
  static const _hole = Color(0xFF5C3A22);
  static const _string = Color(0xFFF6EFE2);
  static const _metal = Color(0xFF232B54);

  late double _w;
  late double _h;
  late Canvas _canvas;
  final Paint _fill = Paint()..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    _w = size.width;
    _h = size.height;
    _canvas = canvas;

    // Sun blob behind the instrument.
    _fill.color = blobColor;
    final blobScale = kind == GuitarKind.ukulele ? 0.34 : 0.40;
    canvas.drawCircle(
        Offset(_w * 0.40, _h * 0.62), _w * blobScale, _fill);

    switch (kind) {
      case GuitarKind.acousticSteel:
        _paintAcoustic(slottedHead: false);
      case GuitarKind.acousticNylon:
        _paintAcoustic(slottedHead: true);
      case GuitarKind.electric:
        _paintElectric(bass: false);
      case GuitarKind.bass:
        _paintElectric(bass: true);
      case GuitarKind.ukulele:
        _paintUkulele();
    }
  }

  // Convenience: rounded rect.
  void _rrect(double x, double y, double rw, double rh, double radius,
      Color color) {
    _fill.color = color;
    _canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(_w * x, _h * y, _w * rw, _h * rh),
        Radius.circular(_w * radius),
      ),
      _fill,
    );
  }

  void _strings(double top, double bottom, {int count = 3}) {
    final paint = Paint()
      ..color = _string
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final offsets = count == 2 ? [-0.012, 0.012] : [-0.018, 0.0, 0.018];
    for (final dx in offsets) {
      _canvas.drawLine(
        Offset(_w * (0.52 + dx), _h * top),
        Offset(_w * (0.52 + dx), _h * bottom),
        paint,
      );
    }
  }

  void _pegs(double y1, double y2, {double x1 = 0.415, double x2 = 0.625}) {
    _fill.color = _string;
    for (final y in [y1, y2]) {
      _canvas.drawCircle(Offset(_w * x1, _h * y), _w * 0.022, _fill);
      _canvas.drawCircle(Offset(_w * x2, _h * y), _w * 0.022, _fill);
    }
  }

  // ------------------------------------------------------------ acoustic
  void _paintAcoustic({required bool slottedHead}) {
    Path body(Offset shift) {
      final lower = Rect.fromCircle(
          center: Offset(_w * 0.52, _h * 0.72) + shift, radius: _w * 0.27);
      final upper = Rect.fromCircle(
          center: Offset(_w * 0.52, _h * 0.52) + shift, radius: _w * 0.19);
      return Path()
        ..addOval(lower)
        ..addOval(upper);
    }

    _fill.color = shadowColor;
    _canvas.drawPath(body(Offset(_w * 0.045, _h * 0.02)), _fill);

    _rrect(0.475, 0.04, 0.09, 0.52, 0.03, _neck);
    _rrect(0.44, 0.015, 0.16, 0.10, 0.04, _neckDark);
    if (slottedHead) {
      // Classical slotted headstock: two light windows.
      _rrect(0.465, 0.032, 0.03, 0.065, 0.015, _neck);
      _rrect(0.545, 0.032, 0.03, 0.065, 0.015, _neck);
    }
    _pegs(0.045, 0.085);

    _fill.color = bodyColor;
    _canvas.drawPath(body(Offset.zero), _fill);

    _fill.color = _hole;
    _canvas.drawCircle(Offset(_w * 0.52, _h * 0.635), _w * 0.085, _fill);
    _rrect(0.435, 0.79, 0.17, 0.035, 0.03, _hole);
    _strings(0.075, 0.795);
  }

  // ------------------------------------------------- electric & bass
  void _paintElectric({required bool bass}) {
    // Double-cutaway solid body: slim waisted silhouette + two horns.
    Path body(Offset shift) {
      final lower = Rect.fromCircle(
          center: Offset(_w * 0.52, _h * 0.74) + shift, radius: _w * 0.235);
      final upper = Rect.fromCircle(
          center: Offset(_w * 0.52, _h * 0.60) + shift, radius: _w * 0.185);
      final hornL = Rect.fromCircle(
          center: Offset(_w * 0.385, _h * 0.515) + shift, radius: _w * 0.062);
      final hornR = Rect.fromCircle(
          center: Offset(_w * 0.655, _h * 0.515) + shift, radius: _w * 0.062);
      return Path()
        ..addOval(lower)
        ..addOval(upper)
        ..addOval(hornL)
        ..addOval(hornR);
    }

    _fill.color = shadowColor;
    _canvas.drawPath(body(Offset(_w * 0.045, _h * 0.02)), _fill);

    // Longer, slimmer neck; bass gets a chunkier one.
    final neckW = bass ? 0.10 : 0.075;
    _rrect(0.52 - neckW / 2, 0.03, neckW, 0.56, 0.03, _neck);
    // Pointy headstock (parallelogram-ish).
    _rrect(0.455, 0.005, 0.15, 0.085, 0.05, _neckDark);
    if (bass) {
      _pegs(0.03, 0.065, x1: 0.43, x2: 0.63);
    } else {
      _pegs(0.03, 0.07);
    }

    _fill.color = bodyColor;
    _canvas.drawPath(body(Offset.zero), _fill);

    // Pickups.
    _rrect(0.40, bass ? 0.665 : 0.635, 0.24, 0.045, 0.04, _metal);
    if (!bass) _rrect(0.40, 0.72, 0.24, 0.045, 0.04, _metal);
    // Bridge.
    _rrect(0.42, 0.815, 0.20, 0.035, 0.03, _metal);
    // Control knobs.
    _fill.color = _metal;
    _canvas.drawCircle(Offset(_w * 0.66, _h * 0.79), _w * 0.028, _fill);
    if (!bass) {
      _canvas.drawCircle(Offset(_w * 0.70, _h * 0.735), _w * 0.028, _fill);
    }
    _strings(0.065, 0.82, count: bass ? 2 : 3);
  }

  // ------------------------------------------------------------- ukulele
  void _paintUkulele() {
    Path body(Offset shift) {
      final lower = Rect.fromCircle(
          center: Offset(_w * 0.52, _h * 0.70) + shift, radius: _w * 0.21);
      final upper = Rect.fromCircle(
          center: Offset(_w * 0.52, _h * 0.55) + shift, radius: _w * 0.155);
      return Path()
        ..addOval(lower)
        ..addOval(upper);
    }

    _fill.color = shadowColor;
    _canvas.drawPath(body(Offset(_w * 0.04, _h * 0.018)), _fill);

    // Short stubby neck.
    _rrect(0.48, 0.18, 0.08, 0.40, 0.03, _neck);
    _rrect(0.445, 0.15, 0.15, 0.085, 0.04, _neckDark);
    _pegs(0.175, 0.21, x1: 0.42, x2: 0.62);

    _fill.color = bodyColor;
    _canvas.drawCircle(Offset(_w * 0.52, _h * 0.55), _w * 0.155, _fill);
    _fill.color = bodyColor;
    _canvas.drawPath(body(Offset.zero), _fill);

    _fill.color = _hole;
    _canvas.drawCircle(Offset(_w * 0.52, _h * 0.615), _w * 0.062, _fill);
    _rrect(0.45, 0.755, 0.14, 0.03, 0.03, _hole);
    _strings(0.20, 0.76, count: 2);
  }

  @override
  bool shouldRepaint(covariant _GuitarPainter oldDelegate) =>
      oldDelegate.kind != kind ||
      oldDelegate.blobColor != blobColor ||
      oldDelegate.bodyColor != bodyColor ||
      oldDelegate.shadowColor != shadowColor;
}
