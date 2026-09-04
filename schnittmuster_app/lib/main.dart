import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'pattern_models.dart';
import 'skirt_pattern_calculator.dart';

void main() => runApp(const SchnittmusterApp());

class SchnittmusterApp extends StatelessWidget {
  const SchnittmusterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Schnittmuster App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const SkirtDebugPage(),
    );
  }
}

class SkirtDebugPage extends StatelessWidget {
  const SkirtDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Rock v1 - Debug')),
      body: result.isValid
          ? PatternPreview(front: result.front!, back: result.back!)
          : Center(child: Text(result.errors.join('\n'))),
    );
  }
}

class PatternPreview extends StatelessWidget {
  final PatternPiece front;
  final PatternPiece back;

  const PatternPreview({super.key, required this.front, required this.back});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 700.0;
        final height = constraints.maxHeight.isFinite ? constraints.maxHeight : 700.0;

        return InteractiveViewer(
          minScale: 0.5,
          maxScale: 5,
          boundaryMargin: const EdgeInsets.all(100),
          child: CustomPaint(
            size: Size(width, height),
            painter: PatternPreviewPainter(front: front, back: back),
          ),
        );
      },
    );
  }
}

class _Bounds {
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  const _Bounds(this.minX, this.minY, this.maxX, this.maxY);

  double get width => maxX - minX;
  double get height => maxY - minY;
}

class PatternPreviewPainter extends CustomPainter {
  final PatternPiece front;
  final PatternPiece back;

  PatternPreviewPainter({required this.front, required this.back});

  _Bounds _bounds(PatternPiece piece) {
    final points = <PatternPoint>[
      ...piece.points.values,
      for (final dart in piece.darts) ...[
        dart.leg1,
        dart.leg2,
        dart.apex,
      ],
    ];

    var minX = points.first.x;
    var minY = points.first.y;
    var maxX = points.first.x;
    var maxY = points.first.y;

    for (final point in points.skip(1)) {
      minX = math.min(minX, point.x);
      minY = math.min(minY, point.y);
      maxX = math.max(maxX, point.x);
      maxY = math.max(maxY, point.y);
    }

    return _Bounds(minX, minY, maxX, maxY);
  }

  Offset _p(
    PatternPoint point,
    _Bounds bounds,
    Offset origin,
    double scale,
  ) {
    return Offset(
      origin.dx + (point.x - bounds.minX) * scale,
      origin.dy + (point.y - bounds.minY) * scale,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 24.0;
    const gap = 28.0;

    final backBounds = _bounds(back);
    final frontBounds = _bounds(front);

    final totalPatternWidth = backBounds.width + frontBounds.width;
    final tallestPattern = math.max(backBounds.height, frontBounds.height);

    final availableWidth = math.max(1.0, size.width - padding * 2 - gap);
    final availableHeight = math.max(1.0, size.height - padding * 2);

    final scaleX = availableWidth / totalPatternWidth;
    final scaleY = availableHeight / tallestPattern;
    final scale = math.min(scaleX, scaleY);

    final usedWidth = totalPatternWidth * scale + gap;
    final startX = math.max(padding, (size.width - usedWidth) / 2);
    final startY = padding;

    final backOrigin = Offset(startX, startY);
    final frontOrigin = Offset(
      startX + backBounds.width * scale + gap,
      startY,
    );

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final debugPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final helperPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    final markerPaint = Paint()..style = PaintingStyle.fill;

    _drawPiece(
      canvas,
      back,
      backBounds,
      backOrigin,
      scale,
      outlinePaint,
      debugPaint,
      helperPaint,
      markerPaint,
    );

    _drawPiece(
      canvas,
      front,
      frontBounds,
      frontOrigin,
      scale,
      outlinePaint,
      debugPaint,
      helperPaint,
      markerPaint,
    );
  }

  void _drawHelperLine(
    Canvas canvas,
    PatternPoint start,
    PatternPoint end,
    _Bounds bounds,
    Offset origin,
    double scale,
    Paint paint,
  ) {
    canvas.drawLine(
      _p(start, bounds, origin, scale),
      _p(end, bounds, origin, scale),
      paint,
    );
  }

  void _drawConstructionLines(
    Canvas canvas,
    PatternPiece piece,
    _Bounds bounds,
    Offset origin,
    double scale,
    Paint helperPaint,
  ) {
    final p = piece.points;

    if (piece.id == 'skirt_back') {
      _drawHelperLine(canvas, p['P1']!, p['P9']!, bounds, origin, scale, helperPaint);
      _drawHelperLine(canvas, p['P5']!, p['P7']!, bounds, origin, scale, helperPaint);
      _drawHelperLine(canvas, p['P7']!, p['P8']!, bounds, origin, scale, helperPaint);
      _drawHelperLine(canvas, p['P11']!, p['P13']!, bounds, origin, scale, helperPaint);
      _drawHelperLine(canvas, p['P12']!, p['P14']!, bounds, origin, scale, helperPaint);
    }

    if (piece.id == 'skirt_front') {
      _drawHelperLine(canvas, p['P15']!, p['P2']!, bounds, origin, scale, helperPaint);
      _drawHelperLine(canvas, p['P7']!, p['P6']!, bounds, origin, scale, helperPaint);
      _drawHelperLine(canvas, p['P7']!, p['P8']!, bounds, origin, scale, helperPaint);
      _drawHelperLine(canvas, p['P17']!, p['P18']!, bounds, origin, scale, helperPaint);
    }
  }

  void _drawPiece(
    Canvas canvas,
    PatternPiece piece,
    _Bounds bounds,
    Offset origin,
    double scale,
    Paint outlinePaint,
    Paint debugPaint,
    Paint helperPaint,
    Paint markerPaint,
  ) {
    if (piece.outline.segments.isEmpty) return;

    _drawConstructionLines(
      canvas,
      piece,
      bounds,
      origin,
      scale,
      helperPaint,
    );

    final first = _p(piece.outline.segments.first.start, bounds, origin, scale);
    final path = Path()..moveTo(first.dx, first.dy);

    for (final segment in piece.outline.segments) {
      final end = _p(segment.end, bounds, origin, scale);
      // Curves are deliberately straight placeholders in this debug build.
      path.lineTo(end.dx, end.dy);
    }
    canvas.drawPath(path, outlinePaint);

    for (final dart in piece.darts) {
      canvas.drawLine(
        _p(dart.center, bounds, origin, scale),
        _p(dart.apex, bounds, origin, scale),
        debugPaint,
      );
    }

    for (final entry in piece.points.entries) {
      final pos = _p(entry.value, bounds, origin, scale);
      canvas.drawCircle(pos, 2.5, markerPaint);

      final tp = TextPainter(
        text: TextSpan(
          text: entry.key,
          style: const TextStyle(fontSize: 10, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, pos + const Offset(4, -12));
    }
  }

  @override
  bool shouldRepaint(covariant PatternPreviewPainter oldDelegate) => true;
}
