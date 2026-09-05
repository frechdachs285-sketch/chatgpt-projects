import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'pattern_models.dart';
import 'skirt_pattern_calculator.dart';

void main() => runApp(const SchnittmusterApp());

class SchnittmusterApp extends StatelessWidget {
  const SchnittmusterApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Schnittmuster App',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: const SkirtDebugPage(),
      );
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
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 700.0;
        final height = constraints.maxHeight.isFinite ? constraints.maxHeight : 700.0;
        return InteractiveViewer(
          minScale: 0.5,
          maxScale: 5,
          boundaryMargin: const EdgeInsets.all(100),
          child: CustomPaint(size: Size(width, height), painter: PatternPreviewPainter(front: front, back: back)),
        );
      });
}

class _Bounds {
  final double minX, minY, maxX, maxY;
  const _Bounds(this.minX, this.minY, this.maxX, this.maxY);
  double get width => maxX - minX;
  double get height => maxY - minY;
}

class PatternPreviewPainter extends CustomPainter {
  final PatternPiece front, back;
  PatternPreviewPainter({required this.front, required this.back});

  _Bounds _bounds(PatternPiece piece) {
    final points = <PatternPoint>[
      ...piece.points.values,
      for (final dart in piece.darts) ...[dart.leg1, dart.leg2, dart.apex],
      for (final segment in piece.outline.segments) if (segment is BezierSegment) ...[segment.control1, segment.control2],
      if (piece.grainline != null) ...[piece.grainline!.start, piece.grainline!.end],
      for (final notch in piece.notches) notch.position,
      for (final label in piece.labels) label.position,
    ];
    var minX = points.first.x, minY = points.first.y, maxX = points.first.x, maxY = points.first.y;
    for (final point in points.skip(1)) {
      minX = math.min(minX, point.x); minY = math.min(minY, point.y);
      maxX = math.max(maxX, point.x); maxY = math.max(maxY, point.y);
    }
    return _Bounds(minX, minY, maxX, maxY);
  }

  Offset _p(PatternPoint point, _Bounds bounds, Offset origin, double scale) => Offset(
        origin.dx + (point.x - bounds.minX) * scale,
        origin.dy + (point.y - bounds.minY) * scale,
      );

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 24.0, gap = 28.0;
    final backBounds = _bounds(back), frontBounds = _bounds(front);
    final totalPatternWidth = backBounds.width + frontBounds.width;
    final tallestPattern = math.max(backBounds.height, frontBounds.height);
    final availableWidth = math.max(1.0, size.width - padding * 2 - gap);
    final availableHeight = math.max(1.0, size.height - padding * 2);
    final scale = math.min(availableWidth / totalPatternWidth, availableHeight / tallestPattern);
    final usedWidth = totalPatternWidth * scale + gap;
    final startX = math.max(padding, (size.width - usedWidth) / 2), startY = padding;
    final backOrigin = Offset(startX, startY);
    final frontOrigin = Offset(startX + backBounds.width * scale + gap, startY);
    final outlinePaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final debugPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8;
    final helperPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 0.6;
    final markerPaint = Paint()..style = PaintingStyle.fill;
    final grainlinePaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2;
    final notchPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5;
    _drawPiece(canvas, back, backBounds, backOrigin, scale, outlinePaint, debugPaint, helperPaint, markerPaint, grainlinePaint, notchPaint);
    _drawPiece(canvas, front, frontBounds, frontOrigin, scale, outlinePaint, debugPaint, helperPaint, markerPaint, grainlinePaint, notchPaint);
  }

  void _drawHelperLine(Canvas canvas, PatternPoint start, PatternPoint end, _Bounds bounds, Offset origin, double scale, Paint paint) =>
      canvas.drawLine(_p(start, bounds, origin, scale), _p(end, bounds, origin, scale), paint);

  void _drawConstructionLines(Canvas canvas, PatternPiece piece, _Bounds bounds, Offset origin, double scale, Paint paint) {
    final p = piece.points;
    if (piece.id == 'skirt_back') {
      _drawHelperLine(canvas,p['P1']!,p['P9']!,bounds,origin,scale,paint); _drawHelperLine(canvas,p['P5']!,p['P7']!,bounds,origin,scale,paint);
      _drawHelperLine(canvas,p['P7']!,p['P8']!,bounds,origin,scale,paint); _drawHelperLine(canvas,p['P11']!,p['P13']!,bounds,origin,scale,paint); _drawHelperLine(canvas,p['P12']!,p['P14']!,bounds,origin,scale,paint);
    } else {
      _drawHelperLine(canvas,p['P15']!,p['P2']!,bounds,origin,scale,paint); _drawHelperLine(canvas,p['P7']!,p['P6']!,bounds,origin,scale,paint);
      _drawHelperLine(canvas,p['P7']!,p['P8']!,bounds,origin,scale,paint); _drawHelperLine(canvas,p['P17']!,p['P18']!,bounds,origin,scale,paint);
    }
  }

  void _drawGrainline(Canvas canvas, PatternPiece piece, _Bounds bounds, Offset origin, double scale, Paint paint) {
    final g = piece.grainline; if (g == null) return;
    final start = _p(g.start,bounds,origin,scale), end = _p(g.end,bounds,origin,scale);
    canvas.drawLine(start,end,paint);
    const length=7.0,width=4.0;
    void arrow(Offset tip,double direction) {
      final baseY=tip.dy+direction*length;
      canvas.drawPath(Path()..moveTo(tip.dx,tip.dy)..lineTo(tip.dx-width,baseY)..moveTo(tip.dx,tip.dy)..lineTo(tip.dx+width,baseY),paint);
    }
    arrow(start,1); arrow(end,-1);
  }

  void _drawNotches(Canvas canvas, PatternPiece piece, _Bounds bounds, Offset origin, double scale, Paint paint) {
    const depth=7.0,halfWidth=4.0;
    for(final notch in piece.notches){
      final tip=_p(notch.position,bounds,origin,scale); final outward=piece.id=='skirt_back'?1.0:-1.0; final baseX=tip.dx+outward*depth;
      canvas.drawPath(Path()..moveTo(tip.dx,tip.dy)..lineTo(baseX,tip.dy-halfWidth)..moveTo(tip.dx,tip.dy)..lineTo(baseX,tip.dy+halfWidth),paint);
    }
  }

  void _drawLabels(Canvas canvas, PatternPiece piece, _Bounds bounds, Offset origin, double scale) {
    for (final label in piece.labels) {
      final pos = _p(label.position, bounds, origin, scale);
      final visibleText = label.text.replaceAll('Rueckenteil', 'Rückenteil');
      final tp = TextPainter(
        text: TextSpan(text: visibleText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  void _drawPiece(Canvas canvas, PatternPiece piece, _Bounds bounds, Offset origin, double scale, Paint outlinePaint, Paint debugPaint, Paint helperPaint, Paint markerPaint, Paint grainlinePaint, Paint notchPaint) {
    if(piece.outline.segments.isEmpty)return;
    _drawConstructionLines(canvas,piece,bounds,origin,scale,helperPaint);
    final first=_p(piece.outline.segments.first.start,bounds,origin,scale); final path=Path()..moveTo(first.dx,first.dy);
    for(final segment in piece.outline.segments){
      if(segment is BezierSegment){final c1=_p(segment.control1,bounds,origin,scale),c2=_p(segment.control2,bounds,origin,scale),end=_p(segment.end,bounds,origin,scale);path.cubicTo(c1.dx,c1.dy,c2.dx,c2.dy,end.dx,end.dy);}else{final end=_p(segment.end,bounds,origin,scale);path.lineTo(end.dx,end.dy);}
    }
    canvas.drawPath(path,outlinePaint); _drawGrainline(canvas,piece,bounds,origin,scale,grainlinePaint); _drawNotches(canvas,piece,bounds,origin,scale,notchPaint); _drawLabels(canvas,piece,bounds,origin,scale);
    for(final dart in piece.darts)canvas.drawLine(_p(dart.center,bounds,origin,scale),_p(dart.apex,bounds,origin,scale),debugPaint);
    for(final entry in piece.points.entries){
      final pos=_p(entry.value,bounds,origin,scale);canvas.drawCircle(pos,2.5,markerPaint);
      final tp=TextPainter(text:TextSpan(text:entry.key,style:const TextStyle(fontSize:10,color:Colors.black)),textDirection:TextDirection.ltr)..layout();tp.paint(canvas,pos+const Offset(4,-12));
    }
  }

  @override
  bool shouldRepaint(covariant PatternPreviewPainter oldDelegate)=>true;
}
