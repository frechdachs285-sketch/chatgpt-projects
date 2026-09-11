import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'pattern_models.dart';
import 'trouser_shaped_waistband_builder.dart';
import 'trouser_shaped_waistband_pattern_adapter.dart';

/// Isolated preview for the shaped-waistband extension.
///
/// Kept separate from the confirmed Hose-v1 [TrouserPreview] so the existing
/// trouser and straight-waistband preview remains untouched.
class TrouserShapedWaistbandPreview extends StatelessWidget {
  final TrouserShapedWaistbandGeometry geometry;
  final bool seamAllowanceEnabled;

  const TrouserShapedWaistbandPreview({
    super.key,
    required this.geometry,
    this.seamAllowanceEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: CustomPaint(
            painter: _ShapedWaistbandPainter(
              geometry,
              seamAllowanceEnabled: seamAllowanceEnabled,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShapedWaistbandPainter extends CustomPainter {
  final TrouserShapedWaistbandGeometry geometry;
  final bool seamAllowanceEnabled;

  _ShapedWaistbandPainter(
    this.geometry, {
    required this.seamAllowanceEnabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const gapCm = 6.0;
    const adapter = TrouserShapedWaistbandPatternAdapter();
    final frontPattern = adapter.front(
      geometry,
      seamAllowanceEnabled: seamAllowanceEnabled,
    );
    final backPattern = adapter.back(
      geometry,
      seamAllowanceEnabled: seamAllowanceEnabled,
    );

    final frontBounds = _pieceBounds(geometry.front, frontPattern.cuttingOutline);
    final backBounds = _pieceBounds(geometry.back, backPattern.cuttingOutline);
    final totalWidth = frontBounds.width + gapCm + backBounds.width;
    final totalHeight = math.max(frontBounds.height, backBounds.height);
    if (totalWidth <= 0 || totalHeight <= 0) return;

    final scale = math.min(size.width / totalWidth, size.height / totalHeight);
    final drawWidth = totalWidth * scale;
    final drawHeight = totalHeight * scale;
    final origin = Offset(
      (size.width - drawWidth) / 2.0,
      (size.height - drawHeight) / 2.0,
    );

    _drawPiece(
      canvas,
      geometry.front,
      cuttingOutline: frontPattern.cuttingOutline,
      origin: origin,
      bounds: frontBounds,
      scale: scale,
      label: 'Geformter Bund vorn',
    );
    _drawPiece(
      canvas,
      geometry.back,
      cuttingOutline: backPattern.cuttingOutline,
      origin: Offset(origin.dx + (frontBounds.width + gapCm) * scale, origin.dy),
      bounds: backBounds,
      scale: scale,
      label: 'Geformter Bund hinten',
    );
  }

  void _drawPiece(
    Canvas canvas,
    ShapedWaistbandPieceGeometry piece, {
    required PatternPath? cuttingOutline,
    required Offset origin,
    required Rect bounds,
    required double scale,
    required String label,
  }) {
    Offset map(PatternPoint p) => Offset(
          origin.dx + (p.x - bounds.left) * scale,
          origin.dy + (p.y - bounds.top) * scale,
        );

    final sewingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var i = 0; i < piece.upperSegments.length; i++) {
      final upper = piece.upperSegments[i];
      final start = map(upper.start);
      final c1 = map(upper.control1);
      final c2 = map(upper.control2);
      final end = map(upper.end);
      final upperPath = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
      canvas.drawPath(upperPath, sewingPaint);

      final lower = piece.lowerSegments[i];
      if (lower.isNotEmpty) {
        final lowerPath = Path();
        final first = map(lower.first);
        lowerPath.moveTo(first.dx, first.dy);
        for (final point in lower.skip(1)) {
          final p = map(point);
          lowerPath.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(lowerPath, sewingPaint);
      }
    }

    if (piece.upperSegments.isNotEmpty && piece.lowerSegments.isNotEmpty) {
      canvas.drawLine(
        map(piece.upperSegments.first.start),
        map(piece.lowerSegments.first.first),
        sewingPaint,
      );
      canvas.drawLine(
        map(piece.upperSegments.last.end),
        map(piece.lowerSegments.last.last),
        sewingPaint,
      );
    }

    if (cuttingOutline != null) {
      final cuttingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      _drawPatternPath(canvas, cuttingOutline, map, cuttingPaint);
    }

    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(
        origin.dx + bounds.width * scale / 2.0 - painter.width / 2.0,
        origin.dy + bounds.height * scale / 2.0 - painter.height / 2.0,
      ),
    );
  }

  void _drawPatternPath(
    Canvas canvas,
    PatternPath path,
    Offset Function(PatternPoint) map,
    Paint paint,
  ) {
    if (path.segments.isEmpty) return;
    final drawing = Path();
    final first = map(path.segments.first.start);
    drawing.moveTo(first.dx, first.dy);

    for (final segment in path.segments) {
      if (segment is LineSegment) {
        final end = map(segment.end);
        drawing.lineTo(end.dx, end.dy);
      } else if (segment is BezierSegment) {
        final c1 = map(segment.control1);
        final c2 = map(segment.control2);
        final end = map(segment.end);
        drawing.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
      }
    }
    canvas.drawPath(drawing, paint);
  }

  Rect _pieceBounds(
    ShapedWaistbandPieceGeometry piece,
    PatternPath? cuttingOutline,
  ) {
    final points = <PatternPoint>[];
    for (final curve in piece.upperSegments) {
      points.addAll([
        curve.start,
        curve.control1,
        curve.control2,
        curve.end,
      ]);
    }
    for (final segment in piece.lowerSegments) {
      points.addAll(segment);
    }
    if (cuttingOutline != null) {
      for (final segment in cuttingOutline.segments) {
        points.add(segment.start);
        points.add(segment.end);
        if (segment is BezierSegment) {
          points.add(segment.control1);
          points.add(segment.control2);
        }
      }
    }
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
  bool shouldRepaint(covariant _ShapedWaistbandPainter oldDelegate) =>
      oldDelegate.geometry != geometry ||
      oldDelegate.seamAllowanceEnabled != seamAllowanceEnabled;
}
