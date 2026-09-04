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
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 5,
      boundaryMargin: const EdgeInsets.all(100),
      child: CustomPaint(
        size: const Size(700, 700),
        painter: PatternPreviewPainter(front: front, back: back),
      ),
    );
  }
}

class PatternPreviewPainter extends CustomPainter {
  final PatternPiece front;
  final PatternPiece back;

  PatternPreviewPainter({required this.front, required this.back});

  static const scale = 8.0;

  Offset _p(PatternPoint p, Offset origin) =>
      Offset(origin.dx + p.x * scale, origin.dy + p.y * scale);

  @override
  void paint(Canvas canvas, Size size) {
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final debugPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final markerPaint = Paint()..style = PaintingStyle.fill;

    _drawPiece(canvas, back, const Offset(40, 40), outlinePaint, debugPaint, markerPaint);
    _drawPiece(canvas, front, const Offset(250, 40), outlinePaint, debugPaint, markerPaint);
  }

  void _drawPiece(Canvas canvas, PatternPiece piece, Offset origin, Paint outlinePaint,
      Paint debugPaint, Paint markerPaint) {
    if (piece.outline.segments.isEmpty) return;

    final path = Path();
    path.moveTo(_p(piece.outline.segments.first.start, origin).dx,
        _p(piece.outline.segments.first.start, origin).dy);

    for (final segment in piece.outline.segments) {
      final end = _p(segment.end, origin);
      // Curves are deliberately straight placeholders in this first debug build.
      path.lineTo(end.dx, end.dy);
    }
    canvas.drawPath(path, outlinePaint);

    for (final dart in piece.darts) {
      canvas.drawLine(_p(dart.center, origin), _p(dart.apex, origin), debugPaint);
    }

    for (final entry in piece.points.entries) {
      final pos = _p(entry.value, origin);
      canvas.drawCircle(pos, 2.5, markerPaint);
      final tp = TextPainter(
        text: TextSpan(text: entry.key, style: const TextStyle(fontSize: 10, color: Colors.black)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos + const Offset(4, -12));
    }
  }

  @override
  bool shouldRepaint(covariant PatternPreviewPainter oldDelegate) => true;
}
