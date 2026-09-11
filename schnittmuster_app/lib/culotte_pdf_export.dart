import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'culotte_measurements.dart';
import 'pattern_models.dart';

class CulottePdfExporter {
  static const _mmToPt = 72.0 / 25.4;
  static const _pageMarginMm = 10.0;
  static const _tileWidthMm = 190.0;
  static const _tileHeightMm = 240.0;
  static const _tileOverlapMm = 10.0;
  static const _piecePaddingMm = 15.0;

  static double mm(double value) => value * _mmToPt;

  Future<Uint8List> buildPatternPdf({
    required CulotteMeasurements measurements,
    required PatternPiece front,
    required PatternPiece back,
  }) async {
    final doc = pw.Document();
    _addCalibrationPage(doc, measurements);
    _addPieceTiles(doc, front, title: 'Culotte v1 - Vorderteil 1:1');
    _addPieceTiles(doc, back, title: 'Culotte v1 - Rueckenteil 1:1');
    return doc.save();
  }

  void _addCalibrationPage(pw.Document doc, CulotteMeasurements m) {
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(mm(15)),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Schnittmuster-App - Culotte v1 - 1:1',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: mm(4)),
            pw.Text(
              'Masse: Taille ${m.waist.toStringAsFixed(1)} cm | Huefte ${m.hip.toStringAsFixed(1)} cm | Huefttiefe ${m.hipDepth.toStringAsFixed(1)} cm | Sitzhoehe ${m.bodyRise.toStringAsFixed(1)} cm | fertige Laenge ${m.finishedLength.toStringAsFixed(1)} cm',
              style: const pw.TextStyle(fontSize: 8.5),
            ),
            pw.SizedBox(height: mm(3)),
            pw.Text(
              'Beim Drucken 100 % / Tatsaechliche Groesse waehlen. Keine Seitenanpassung verwenden.',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: mm(10)),
            pw.Text('Kontrollquadrat 100 x 100 mm', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: mm(3)),
            pw.Container(
              width: mm(100),
              height: mm(100),
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.8)),
              child: pw.Center(
                child: pw.Text('100 mm x 100 mm', style: const pw.TextStyle(fontSize: 11)),
              ),
            ),
            pw.SizedBox(height: mm(12)),
            pw.Text('Kontrolllinie 200 mm', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: mm(3)),
            pw.Container(width: mm(200), height: 1, color: PdfColors.black),
            pw.SizedBox(height: mm(2)),
            pw.Text('200 mm', style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
      ),
    );
  }

  void _addPieceTiles(
    pw.Document doc,
    PatternPiece piece, {
    required String title,
  }) {
    final b = _pieceBounds(piece);
    final canvasWidthMm = b.width * 10.0 + 2 * _piecePaddingMm;
    final canvasHeightMm = b.height * 10.0 + 2 * _piecePaddingMm;
    final originX = _piecePaddingMm - b.minX * 10.0;
    final originY = _piecePaddingMm - b.minY * 10.0;
    final stepX = _tileWidthMm - _tileOverlapMm;
    final stepY = _tileHeightMm - _tileOverlapMm;
    final cols = math.max(1, ((canvasWidthMm - _tileWidthMm) / stepX).ceil() + 1);
    final rows = math.max(1, ((canvasHeightMm - _tileHeightMm) / stepY).ceil() + 1);

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final tileX = col * stepX;
        final tileY = row * stepY;
        if (!_tileHasVisibleContent(piece, originX, originY, tileX, tileY)) continue;
        final tileName = '${String.fromCharCode(65 + col)}${row + 1}';
        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(mm(_pageMarginMm)),
            build: (_) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(title, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Seite $tileName', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: mm(2)),
                pw.Container(
                  width: mm(_tileWidthMm),
                  height: mm(_tileHeightMm),
                  decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.25)),
                  child: pw.Stack(
                    children: [
                      if (piece.cuttingOutline != null)
                        _pathWidget(piece.cuttingOutline!, originX - tileX, originY - tileY, 0.45),
                      _pathWidget(piece.outline, originX - tileX, originY - tileY, 0.25),
                      ..._dartWidgets(piece, originX - tileX, originY - tileY),
                      if (piece.grainline != null)
                        _grainlineWidget(piece.grainline!, originX - tileX, originY - tileY),
                      ..._labelWidgets(piece, originX - tileX, originY - tileY),
                      ..._registrationWidgets(
                        left: col > 0,
                        right: col < cols - 1,
                        top: row > 0,
                        bottom: row < rows - 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  bool _tileHasVisibleContent(
    PatternPiece piece,
    double originX,
    double originY,
    double tileX,
    double tileY,
  ) {
    final minX = tileX;
    final minY = tileY;
    final maxX = tileX + _tileWidthMm;
    final maxY = tileY + _tileHeightMm;

    bool lineTouches(PatternPoint a, PatternPoint b) {
      final ax = originX + a.x * 10.0;
      final ay = originY + a.y * 10.0;
      final bx = originX + b.x * 10.0;
      final by = originY + b.y * 10.0;
      return math.max(ax, bx) >= minX &&
          math.min(ax, bx) <= maxX &&
          math.max(ay, by) >= minY &&
          math.min(ay, by) <= maxY;
    }

    bool pathTouches(PatternPath path) {
      for (final segment in path.segments) {
        if (lineTouches(segment.start, segment.end)) return true;
        if (segment is BezierSegment) {
          if (lineTouches(segment.start, segment.control1) ||
              lineTouches(segment.control1, segment.control2) ||
              lineTouches(segment.control2, segment.end)) {
            return true;
          }
        }
      }
      return false;
    }

    if (piece.cuttingOutline != null && pathTouches(piece.cuttingOutline!)) return true;
    if (pathTouches(piece.outline)) return true;
    for (final dart in piece.darts) {
      if (lineTouches(dart.leg1, dart.apex) || lineTouches(dart.apex, dart.leg2)) return true;
    }
    final grain = piece.grainline;
    return grain != null && lineTouches(grain.start, grain.end);
  }

  pw.Widget _pathWidget(PatternPath path, double ox, double oy, double lineWidthMm) {
    return pw.Positioned(
      left: 0,
      top: 0,
      child: pw.ClipRect(
        child: pw.CustomPaint(
          size: PdfPoint(mm(_tileWidthMm), mm(_tileHeightMm)),
          painter: (canvas, size) {
            canvas
              ..setStrokeColor(PdfColors.black)
              ..setLineWidth(mm(lineWidthMm))
              ..setLineJoin(PdfLineJoin.round)
              ..setLineCap(PdfLineCap.round);
            PatternPoint? previousEnd;
            for (final segment in path.segments) {
              final start = _local(segment.start, ox, oy);
              final end = _local(segment.end, ox, oy);
              final continues = previousEnd != null && previousEnd.distanceTo(segment.start) <= 1e-9;
              if (!continues) canvas.moveTo(mm(start.x), size.y - mm(start.y));
              if (segment is BezierSegment) {
                final c1 = _local(segment.control1, ox, oy);
                final c2 = _local(segment.control2, ox, oy);
                canvas.curveTo(
                  mm(c1.x), size.y - mm(c1.y),
                  mm(c2.x), size.y - mm(c2.y),
                  mm(end.x), size.y - mm(end.y),
                );
              } else {
                canvas.lineTo(mm(end.x), size.y - mm(end.y));
              }
              previousEnd = segment.end;
            }
            canvas.strokePath();
          },
        ),
      ),
    );
  }

  List<pw.Widget> _dartWidgets(PatternPiece piece, double ox, double oy) {
    return [
      for (final dart in piece.darts)
        _pathWidget(
          PatternPath([LineSegment(dart.leg1, dart.apex), LineSegment(dart.apex, dart.leg2)]),
          ox,
          oy,
          0.25,
        ),
    ];
  }

  pw.Widget _grainlineWidget(Grainline grain, double ox, double oy) {
    return _pathWidget(
      PatternPath([LineSegment(grain.start, grain.end)]),
      ox,
      oy,
      0.25,
    );
  }

  List<pw.Widget> _labelWidgets(PatternPiece piece, double ox, double oy) {
    final widgets = <pw.Widget>[];
    for (final label in piece.labels) {
      final p = _local(label.position, ox, oy);
      if (p.x < 0 || p.x > _tileWidthMm || p.y < 0 || p.y > _tileHeightMm) continue;
      widgets.add(
        pw.Positioned(
          left: mm(math.max(0.0, p.x - 30.0)),
          top: mm(math.max(0.0, p.y - 3.0)),
          child: pw.Container(
            width: mm(60),
            alignment: pw.Alignment.center,
            child: pw.Text(
              label.text,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  List<pw.Widget> _registrationWidgets({
    required bool left,
    required bool right,
    required bool top,
    required bool bottom,
  }) {
    final marks = <pw.Widget>[];
    void addCross(double x, double y) {
      marks.add(
        pw.Positioned(
          left: mm(x - 3),
          top: mm(y - 3),
          child: pw.Container(
            width: mm(6),
            height: mm(6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.3),
              shape: pw.BoxShape.circle,
            ),
          ),
        ),
      );
    }

    if (left) addCross(_tileOverlapMm / 2, _tileHeightMm / 2);
    if (right) addCross(_tileWidthMm - _tileOverlapMm / 2, _tileHeightMm / 2);
    if (top) addCross(_tileWidthMm / 2, _tileOverlapMm / 2);
    if (bottom) addCross(_tileWidthMm / 2, _tileHeightMm - _tileOverlapMm / 2);
    return marks;
  }

  _PieceBounds _pieceBounds(PatternPiece piece) {
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
    if (piece.cuttingOutline != null) addPath(piece.cuttingOutline!);
    for (final dart in piece.darts) {
      points.addAll([dart.leg1, dart.apex, dart.leg2]);
    }
    final grain = piece.grainline;
    if (grain != null) points.addAll([grain.start, grain.end]);

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
    return _PieceBounds(minX, minY, maxX, maxY);
  }

  _LocalPoint _local(PatternPoint p, double ox, double oy) {
    return _LocalPoint(ox + p.x * 10.0, oy + p.y * 10.0);
  }
}

class _LocalPoint {
  final double x;
  final double y;
  const _LocalPoint(this.x, this.y);
}

class _PieceBounds {
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  const _PieceBounds(this.minX, this.minY, this.maxX, this.maxY);

  double get width => maxX - minX;
  double get height => maxY - minY;
}
