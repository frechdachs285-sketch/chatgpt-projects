import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'pattern_models.dart';
import 'trouser_shaped_waistband_facing_builder.dart';

/// Isolated preview for the shaped-waistband facing extension.
///
/// Kept separate from the confirmed Hose-v1 trouser preview and from the
/// shaped-waistband preview so the existing confirmed previews stay untouched.
class TrouserShapedWaistbandFacingPreview extends StatelessWidget {
  final TrouserShapedWaistbandFacingGeometry geometry;

  const TrouserShapedWaistbandFacingPreview({
    super.key,
    required this.geometry,
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
            painter: _FacingPainter(geometry),
          ),
        ),
      ),
    );
  }
}

class _FacingPainter extends CustomPainter {
  final TrouserShapedWaistbandFacingGeometry geometry;

  _FacingPainter(this.geometry);

  @override
  void paint(Canvas canvas, Size size) {
    const gapCm = 6.0;
    final frontBounds = _pieceBounds(geometry.front);
    final backBounds = _pieceBounds(geometry.back);
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
      origin: origin,
      bounds: frontBounds,
      scale: scale,
      label: 'Beleg vorn',
    );
    _drawPiece(
      canvas,
      geometry.back,
      origin: Offset(origin.dx + (frontBounds.width + gapCm) * scale, origin.dy),
      bounds: backBounds,
      scale: scale,
      label: 'Beleg hinten',
    );
  }

  void _drawPiece(
    Canvas canvas,
    ShapedWaistbandFacingPieceGeometry piece, {
    required Offset origin,
    required Rect bounds,
    required double scale,
    required String label,
  }) {
    Offset map(PatternPoint p) => Offset(
          origin.dx + (p.x - bounds.left) * scale,
          origin.dy + (p.y - bounds.top) * scale,
        );

    final paint = Paint()
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
      canvas.drawPath(upperPath, paint);

      final lower = piece.lowerSegments[i];
      if (lower.isNotEmpty) {
        final lowerPath = Path();
        final first = map(lower.first);
        lowerPath.moveTo(first.dx, first.dy);
        for (final point in lower.skip(1)) {
          final p = map(point);
          lowerPath.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(lowerPath, paint);
      }
    }

    if (piece.upperSegments.isNotEmpty && piece.lowerSegments.isNotEmpty) {
      canvas.drawLine(
        map(piece.upperSegments.first.start),
        map(piece.lowerSegments.first.first),
        paint,
      );
      canvas.drawLine(
        map(piece.upperSegments.last.end),
        map(piece.lowerSegments.last.last),
        paint,
      );
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

  Rect _pieceBounds(ShapedWaistbandFacingPieceGeometry piece) {
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
  bool shouldRepaint(covariant _FacingPainter oldDelegate) =>
      oldDelegate.geometry != geometry;
}
