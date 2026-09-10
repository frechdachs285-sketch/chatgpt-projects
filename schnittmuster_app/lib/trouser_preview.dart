import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'pattern_geometry.dart';
import 'pattern_models.dart';
import 'trouser_fly.dart';
import 'trouser_shorts_geometry.dart';

class TrouserPreview extends StatelessWidget {
  final PatternPiece leftFront;
  final PatternPiece rightFront;
  final PatternPiece back;
  final PatternPiece waistband;
  final TrouserFlyGeometry? fly;
  final TrouserShortsGeometry? shortsGeometry;

  const TrouserPreview({
    super.key,
    required this.leftFront,
    required this.rightFront,
    required this.back,
    required this.waistband,
    this.fly,
    this.shortsGeometry,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: CustomPaint(
            painter: _TrouserPreviewPainter(
              leftFront: leftFront,
              rightFront: rightFront,
              back: back,
              waistband: waistband,
              fly: fly,
              shortsGeometry: shortsGeometry,
            ),
          ),
        ),
      ),
    );
  }
}

class _TrouserPreviewPainter extends CustomPainter {
  final PatternPiece leftFront;
  final PatternPiece rightFront;
  final PatternPiece back;
  final PatternPiece waistband;
  final TrouserFlyGeometry? fly;
  final TrouserShortsGeometry? shortsGeometry;

  _TrouserPreviewPainter({
    required this.leftFront,
    required this.rightFront,
    required this.back,
    required this.waistband,
    required this.fly,
    required this.shortsGeometry,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const gapCm = 8.0;
    final shorts = shortsGeometry;
    final leftFrontBounds = _pieceBounds(
      leftFront,
      maxY: shorts?.shortsDepthY,
    );
    final rightFrontBounds = _pieceBounds(
      rightFront,
      maxY: shorts?.shortsDepthY,
    );
    final backBounds = _pieceBounds(
      back,
      maxY: shorts == null ? null : shorts.shortsDepthY + 1.0,
    );
    final waistbandBounds = _pieceBounds(waistband);

    final trouserWidth = leftFrontBounds.width +
        gapCm +
        rightFrontBounds.width +
        gapCm +
        backBounds.width;
    final trouserHeight = math.max(
      math.max(leftFrontBounds.height, rightFrontBounds.height),
      backBounds.height,
    );
    final totalWidth = math.max(trouserWidth, waistbandBounds.width);
    final totalHeight = trouserHeight + gapCm + waistbandBounds.height;
    if (totalWidth <= 0 || totalHeight <= 0) return;

    final scale = math.min(size.width / totalWidth, size.height / totalHeight);
    final drawWidth = totalWidth * scale;
    final drawHeight = totalHeight * scale;
    final origin = Offset(
      (size.width - drawWidth) / 2.0,
      (size.height - drawHeight) / 2.0,
    );
    final trouserX = origin.dx + (totalWidth - trouserWidth) * scale / 2.0;

    _drawPiece(
      canvas,
      leftFront,
      origin: Offset(trouserX, origin.dy),
      bounds: leftFrontBounds,
      scale: scale,
      shortsHemLine: shorts?.frontHem,
      suppressCuttingOutline: shorts != null,
    );
    _drawPiece(
      canvas,
      rightFront,
      origin: Offset(trouserX + (leftFrontBounds.width + gapCm) * scale, origin.dy),
      bounds: rightFrontBounds,
      scale: scale,
      fly: fly,
      shortsHemLine: shorts?.frontHem,
      suppressCuttingOutline: shorts != null,
    );
    _drawPiece(
      canvas,
      back,
      origin: Offset(
        trouserX +
            (leftFrontBounds.width + gapCm + rightFrontBounds.width + gapCm) * scale,
        origin.dy,
      ),
      bounds: backBounds,
      scale: scale,
      shortsHemCurve: shorts?.backHem,
      suppressCuttingOutline: shorts != null,
    );
    _drawPiece(
      canvas,
      waistband,
      origin: Offset(
        origin.dx + (totalWidth - waistbandBounds.width) * scale / 2.0,
        origin.dy + (trouserHeight + gapCm) * scale,
      ),
      bounds: waistbandBounds,
      scale: scale,
    );
  }

  void _drawPiece(
    Canvas canvas,
    PatternPiece piece, {
    required Offset origin,
    required Rect bounds,
    required double scale,
    TrouserFlyGeometry? fly,
    LineSegment? shortsHemLine,
    CubicBezierCurve? shortsHemCurve,
    bool suppressCuttingOutline = false,
  }) {
    Offset map(PatternPoint p) => Offset(
          origin.dx + (p.x - bounds.left) * scale,
          origin.dy + (p.y - bounds.top) * scale,
        );

    final cuttingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final guidePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;
    final dartPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    final grainPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    final flyPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final shortsHemPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(
      origin.dx - 1.0,
      origin.dy - 1.0,
      bounds.width * scale + 2.0,
      bounds.height * scale + 2.0,
    ));

    final cuttingOutline = piece.cuttingOutline;
    if (!suppressCuttingOutline && cuttingOutline != null) {
      canvas.drawPath(_canvasPath(cuttingOutline, map), cuttingPaint);
    }
    canvas.drawPath(_canvasPath(piece.outline, map), outlinePaint);

    if (shortsHemLine != null) {
      canvas.drawLine(map(shortsHemLine.start), map(shortsHemLine.end), shortsHemPaint);
    }
    if (shortsHemCurve != null) {
      final start = map(shortsHemCurve.start);
      final c1 = map(shortsHemCurve.control1);
      final c2 = map(shortsHemCurve.control2);
      final end = map(shortsHemCurve.end);
      final hemPath = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
      canvas.drawPath(hemPath, shortsHemPaint);
    }

    for (final guide in piece.guideLines) {
      canvas.drawLine(map(guide.start), map(guide.end), guidePaint);
    }
    if (fly != null) {
      canvas.drawLine(map(fly.waistCenterFront), map(fly.lowerEnd), flyPaint);
    }
    for (final dart in piece.darts) {
      final leg1 = map(dart.leg1);
      final apex = map(dart.apex);
      final leg2 = map(dart.leg2);
      final dartPath = Path()
        ..moveTo(leg1.dx, leg1.dy)
        ..lineTo(apex.dx, apex.dy)
        ..lineTo(leg2.dx, leg2.dy);
      canvas.drawPath(dartPath, dartPaint);
    }

    final grain = piece.grainline;
    if (grain != null) {
      final start = map(grain.start);
      final end = map(grain.end);
      canvas.drawLine(start, end, grainPaint);
      _drawArrowHead(canvas, start, end, grainPaint);
      _drawArrowHead(canvas, end, start, grainPaint);
    }

    for (final label in piece.labels) {
      final position = map(label.position);
      final isTrouserPiece = label.text.startsWith('Vorderhose ') ||
          label.text.startsWith('Hinterhose');
      final isShortsPiece = label.text.startsWith('Shorts Vorderhose ') ||
          label.text.startsWith('Shorts Hinterhose');
      final previewText = isTrouserPiece
          ? label.text.replaceFirst(' - Größe ', '\nGröße ')
          : isShortsPiece
              ? label.text
                  .replaceFirst('Shorts ', '')
                  .replaceFirst(' - Größe ', '\nGröße ')
              : label.text;
      final painter = TextPainter(
        text: TextSpan(
          text: previewText,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(position.dx - painter.width / 2.0, position.dy - painter.height / 2.0),
      );
    }

    canvas.restore();
  }

  Path _canvasPath(PatternPath patternPath, Offset Function(PatternPoint point) map) {
    final path = Path();
    var started = false;
    for (final segment in patternPath.segments) {
      if (!started) {
        final start = map(segment.start);
        path.moveTo(start.dx, start.dy);
        started = true;
      }
      if (segment is BezierSegment) {
        final c1 = map(segment.control1);
        final c2 = map(segment.control2);
        final end = map(segment.end);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
      } else {
        final end = map(segment.end);
        path.lineTo(end.dx, end.dy);
      }
    }
    return path;
  }

  void _drawArrowHead(Canvas canvas, Offset tip, Offset other, Paint paint) {
    final dx = other.dx - tip.dx;
    final dy = other.dy - tip.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    if (length <= 0.0) return;
    final ux = dx / length;
    final uy = dy / length;
    final px = -uy;
    final py = ux;
    const arrowLength = 6.0;
    const arrowHalfWidth = 2.5;
    final base = Offset(tip.dx + ux * arrowLength, tip.dy + uy * arrowLength);
    canvas.drawLine(tip, Offset(base.dx + px * arrowHalfWidth, base.dy + py * arrowHalfWidth), paint);
    canvas.drawLine(tip, Offset(base.dx - px * arrowHalfWidth, base.dy - py * arrowHalfWidth), paint);
  }

  Rect _pieceBounds(PatternPiece piece, {double? maxY}) {
    final points = <PatternPoint>[];
    _addPathPoints(points, piece.outline);
    final cuttingOutline = piece.cuttingOutline;
    if (cuttingOutline != null) _addPathPoints(points, cuttingOutline);
    for (final guide in piece.guideLines) {
      points.addAll([guide.start, guide.end]);
    }
    for (final dart in piece.darts) {
      points.addAll([dart.leg1, dart.leg2, dart.apex]);
    }
    final grain = piece.grainline;
    if (grain != null) points.addAll([grain.start, grain.end]);
    for (final label in piece.labels) {
      points.add(label.position);
    }
    final full = _boundsOf(points);
    if (maxY == null) return full;
    final bottom = math.max(full.top, math.min(full.bottom, maxY));
    return Rect.fromLTRB(full.left, full.top, full.right, bottom);
  }

  void _addPathPoints(List<PatternPoint> points, PatternPath path) {
    for (final segment in path.segments) {
      points.add(segment.start);
      points.add(segment.end);
      if (segment is BezierSegment) {
        points.add(segment.control1);
        points.add(segment.control2);
      }
    }
  }

  Rect _boundsOf(List<PatternPoint> points) {
    if (points.isEmpty) return Rect.zero;
    var minX = points.first.x;
    var maxX = points.first.x;
    var minY = points.first.y;
    var maxY = points.first.y;
    for (final p in points.skip(1)) {
      minX = math.min(minX, p.x);
      maxX = math.max(maxX, p.x);
      minY = math.min(minY, p.y);
      maxY = math.max(maxY, p.y);
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  @override
  bool shouldRepaint(covariant _TrouserPreviewPainter oldDelegate) =>
      oldDelegate.leftFront != leftFront ||
      oldDelegate.rightFront != rightFront ||
      oldDelegate.back != back ||
      oldDelegate.waistband != waistband ||
      oldDelegate.fly != fly ||
      oldDelegate.shortsGeometry != shortsGeometry;
}
