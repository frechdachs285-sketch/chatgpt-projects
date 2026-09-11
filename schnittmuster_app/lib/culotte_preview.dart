import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'pattern_models.dart';

class CulottePreview extends StatelessWidget {
  final PatternPiece front;
  final PatternPiece back;

  const CulottePreview({
    super.key,
    required this.front,
    required this.back,
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
            painter: _CulottePreviewPainter(front: front, back: back),
          ),
        ),
      ),
    );
  }
}

class _CulottePreviewPainter extends CustomPainter {
  final PatternPiece front;
  final PatternPiece back;

  _CulottePreviewPainter({required this.front, required this.back});

  @override
  void paint(Canvas canvas, Size size) {
    const gapCm = 8.0;
    final frontBounds = _pieceBounds(front);
    final backBounds = _pieceBounds(back);
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

    _drawPiece(canvas, front, origin: origin, bounds: frontBounds, scale: scale);
    _drawPiece(
      canvas,
      back,
      origin: Offset(origin.dx + (frontBounds.width + gapCm) * scale, origin.dy),
      bounds: backBounds,
      scale: scale,
    );
  }

  void _drawPiece(
    Canvas canvas,
    PatternPiece piece, {
    required Offset origin,
    required Rect bounds,
    required double scale,
  }) {
    Offset map(PatternPoint p) => Offset(
          origin.dx + (p.x - bounds.left) * scale,
          origin.dy + (p.y - bounds.top) * scale,
        );

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dartPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(_canvasPath(piece.outline, map), outlinePaint);

    for (final dart in piece.darts) {
      final path = Path()
        ..moveTo(map(dart.leg1).dx, map(dart.leg1).dy)
        ..lineTo(map(dart.apex).dx, map(dart.apex).dy)
        ..lineTo(map(dart.leg2).dx, map(dart.leg2).dy);
      canvas.drawPath(path, dartPaint);
    }
  }

  Path _canvasPath(
    PatternPath patternPath,
    Offset Function(PatternPoint point) map,
  ) {
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

  Rect _pieceBounds(PatternPiece piece) {
    final points = <PatternPoint>[];
    for (final segment in piece.outline.segments) {
      points.add(segment.start);
      points.add(segment.end);
      if (segment is BezierSegment) {
        points.add(segment.control1);
        points.add(segment.control2);
      }
    }
    for (final dart in piece.darts) {
      points.addAll([dart.leg1, dart.leg2, dart.apex]);
    }
    if (points.isEmpty) return Rect.zero;

    var minX = points.first.x;
    var maxX = points.first.x;
    var minY = points.first.y;
    var maxY = points.first.y;
    for (final point in points.skip(1)) {
      minX = math.min(minX, point.x);
      maxX = math.max(maxX, point.x);
      minY = math.min(minY, point.y);
      maxY = math.max(maxY, point.y);
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  @override
  bool shouldRepaint(covariant _CulottePreviewPainter oldDelegate) =>
      oldDelegate.front != front || oldDelegate.back != back;
}
