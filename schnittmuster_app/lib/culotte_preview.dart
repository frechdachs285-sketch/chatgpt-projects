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
    final cuttingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dartPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    final grainPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final cuttingOutline = piece.cuttingOutline;
    if (cuttingOutline != null) {
      canvas.drawPath(_canvasPath(cuttingOutline, map), cuttingPaint);
    }

    canvas.drawPath(_canvasPath(piece.outline, map), outlinePaint);

    for (final dart in piece.darts) {
      final path = Path()
        ..moveTo(map(dart.leg1).dx, map(dart.leg1).dy)
        ..lineTo(map(dart.apex).dx, map(dart.apex).dy)
        ..lineTo(map(dart.leg2).dx, map(dart.leg2).dy);
      canvas.drawPath(path, dartPaint);
    }

    final grainline = piece.grainline;
    if (grainline != null) {
      final start = map(grainline.start);
      final end = map(grainline.end);
      canvas.drawLine(start, end, grainPaint);

      final arrowSize = math.max(4.0, math.min(8.0, 0.7 * scale));
      _drawArrowHead(canvas, start, end, grainPaint, arrowSize);
      _drawArrowHead(canvas, end, start, grainPaint, arrowSize);
    }

    for (final label in piece.labels) {
      final center = map(label.position);
      final textPainter = TextPainter(
        text: TextSpan(
          text: label.text,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 11.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2.0,
          center.dy - textPainter.height / 2.0,
        ),
      );
    }
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset tip,
    Offset toward,
    Paint paint,
    double size,
  ) {
    final dx = toward.dx - tip.dx;
    final dy = toward.dy - tip.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    if (length <= 0.000001) return;

    final ux = dx / length;
    final uy = dy / length;
    final px = -uy;
    final py = ux;
    final baseX = tip.dx + ux * size;
    final baseY = tip.dy + uy * size;
    final halfWidth = size * 0.45;

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(baseX + px * halfWidth, baseY + py * halfWidth)
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(baseX - px * halfWidth, baseY - py * halfWidth);
    canvas.drawPath(path, paint);
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

    void addPath(PatternPath path) {
      for (final segment in path.segments) {
        points.add(segment.start);
        points.add(segment.end);
        if (segment is BezierSegment) {
          points.add(segment.control1);
          points.add(segment.control2);
        }
      }
    }

    addPath(piece.outline);
    final cuttingOutline = piece.cuttingOutline;
    if (cuttingOutline != null) addPath(cuttingOutline);

    for (final dart in piece.darts) {
      points.addAll([dart.leg1, dart.leg2, dart.apex]);
    }
    final grainline = piece.grainline;
    if (grainline != null) {
      points.add(grainline.start);
      points.add(grainline.end);
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
