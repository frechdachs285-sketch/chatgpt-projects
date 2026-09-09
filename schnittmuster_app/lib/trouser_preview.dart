import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'pattern_models.dart';

class TrouserPreview extends StatelessWidget {
  final PatternPiece front;
  final PatternPiece back;

  const TrouserPreview({
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
            painter: _TrouserPreviewPainter(front: front, back: back),
          ),
        ),
      ),
    );
  }
}

class _TrouserPreviewPainter extends CustomPainter {
  final PatternPiece front;
  final PatternPiece back;

  _TrouserPreviewPainter({required this.front, required this.back});

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = _combinedBounds(front, back);
    if (bounds.width <= 0 || bounds.height <= 0) return;

    const gapCm = 8.0;
    final frontBounds = _pieceBounds(front);
    final backBounds = _pieceBounds(back);
    final totalWidth = frontBounds.width + gapCm + backBounds.width;
    final totalHeight = math.max(frontBounds.height, backBounds.height);

    final scale = math.min(size.width / totalWidth, size.height / totalHeight);
    final drawWidth = totalWidth * scale;
    final drawHeight = totalHeight * scale;
    final origin = Offset(
      (size.width - drawWidth) / 2.0,
      (size.height - drawHeight) / 2.0,
    );

    _drawPiece(
      canvas,
      front,
      origin: origin,
      bounds: frontBounds,
      scale: scale,
    );

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

    final dartPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
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
      final painter = TextPainter(
        text: TextSpan(
          text: label.text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(position.dx - painter.width / 2.0, position.dy - painter.height / 2.0),
      );
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
    final base = Offset(
      tip.dx + ux * arrowLength,
      tip.dy + uy * arrowLength,
    );
    canvas.drawLine(
      tip,
      Offset(base.dx + px * arrowHalfWidth, base.dy + py * arrowHalfWidth),
      paint,
    );
    canvas.drawLine(
      tip,
      Offset(base.dx - px * arrowHalfWidth, base.dy - py * arrowHalfWidth),
      paint,
    );
  }

  Rect _pieceBounds(PatternPiece piece) {
    final points = <PatternPoint>[];
    _addPathPoints(points, piece.outline);
    final cuttingOutline = piece.cuttingOutline;
    if (cuttingOutline != null) {
      _addPathPoints(points, cuttingOutline);
    }
    for (final dart in piece.darts) {
      points.addAll([dart.leg1, dart.leg2, dart.apex]);
    }
    final grain = piece.grainline;
    if (grain != null) {
      points.addAll([grain.start, grain.end]);
    }
    for (final label in piece.labels) {
      points.add(label.position);
    }
    return _boundsOf(points);
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

  Rect _combinedBounds(PatternPiece a, PatternPiece b) {
    final ra = _pieceBounds(a);
    final rb = _pieceBounds(b);
    return Rect.fromLTRB(
      math.min(ra.left, rb.left),
      math.min(ra.top, rb.top),
      math.max(ra.right, rb.right),
      math.max(ra.bottom, rb.bottom),
    );
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
      oldDelegate.front != front || oldDelegate.back != back;
}
