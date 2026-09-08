import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pattern_models.dart';
import 'trouser_pattern_calculator.dart';
import 'trouser_pattern_piece_builder.dart';

class TrouserPdfExporter {
  static const _mmToPt = 72.0 / 25.4;
  static const _pageMarginMm = 10.0;
  static const _tileWidthMm = 190.0;
  static const _tileHeightMm = 240.0;
  static const _tileOverlapMm = 10.0;
  static const _piecePaddingMm = 15.0;

  static double mm(double value) => value * _mmToPt;

  Future<Uint8List> buildPatternPdf({
    required TrouserMeasurements measurements,
  }) async {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    const builder = TrouserPatternPieceBuilder();
    final front = builder.front(draft);
    final back = builder.back(draft);

    final doc = pw.Document();
    _addCalibrationPage(doc, measurements);
    _addPieceTiles(doc, front, title: 'Hose v1 - Vorderhose 1:1');
    _addPieceTiles(doc, back, title: 'Hose v1 - Hinterhose 1:1');
    return doc.save();
  }

  void _addCalibrationPage(pw.Document doc, TrouserMeasurements m) {
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(mm(15)),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Schnittmuster-App - Hose v1 - 1:1',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: mm(4)),
            pw.Text(
              'Masse: Taille ${m.waist.toStringAsFixed(1)} cm | Huefte ${m.hip.toStringAsFixed(1)} cm | Huefttiefe ${m.hipDepth.toStringAsFixed(1)} cm | Sitzhoehe ${m.bodyRise.toStringAsFixed(1)} cm | Taille-Boden ${m.waistToFloor.toStringAsFixed(1)} cm | Saumweite ${m.trouserBottomWidth.toStringAsFixed(1)} cm',
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
    final bounds = _pieceBounds(piece);
    final pieceWidthMm = bounds.width * 10.0;
    final pieceHeightMm = bounds.height * 10.0;
    final canvasWidthMm = pieceWidthMm + 2 * _piecePaddingMm;
    final canvasHeightMm = pieceHeightMm + 2 * _piecePaddingMm;
    final originX = _piecePaddingMm - bounds.minX * 10.0;
    final originY = _piecePaddingMm - bounds.minY * 10.0;

    final stepX = _tileWidthMm - _tileOverlapMm;
    final stepY = _tileHeightMm - _tileOverlapMm;
    final cols = math.max(1, ((canvasWidthMm - _tileWidthMm) / stepX).ceil() + 1);
    final rows = math.max(1, ((canvasHeightMm - _tileHeightMm) / stepY).ceil() + 1);

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final tileX = col * stepX;
        final tileY = row * stepY;
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
                pw.SizedBox(height: mm(1.5)),
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.symmetric(horizontal: mm(2.5), vertical: mm(1.5)),
                  decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.45)),
                  child: pw.Text(
                    'MONTAGE: rechte/untere Schneidelinie abschneiden, linke/obere Klebeflaeche unterlegen und Seiten exakt ausrichten.',
                    style: pw.TextStyle(fontSize: 8.4, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: mm(2)),
                pw.Container(
                  width: mm(_tileWidthMm),
                  height: mm(_tileHeightMm),
                  decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.25)),
                  child: pw.Stack(
                    children: [
                      _pathWidget(
                        piece.outline,
                        originX - tileX,
                        originY - tileY,
                      ),
                      ..._dartWidgets(
                        piece,
                        originX - tileX,
                        originY - tileY,
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

  pw.Widget _pathWidget(PatternPath path, double ox, double oy) {
    return pw.Positioned(
      left: 0,
      top: 0,
      child: pw.ClipRect(
        child: pw.CustomPaint(
          size: PdfPoint(mm(_tileWidthMm), mm(_tileHeightMm)),
          painter: (canvas, size) {
            canvas
              ..setStrokeColor(PdfColors.black)
              ..setLineWidth(mm(0.30))
              ..setLineJoin(PdfLineJoin.round)
              ..setLineCap(PdfLineCap.round);

            PatternPoint? previousEnd;
            for (final segment in path.segments) {
              final start = _local(segment.start, ox, oy);
              final end = _local(segment.end, ox, oy);
              final continues = previousEnd != null &&
                  previousEnd.distanceTo(segment.start) <= 1e-9;
              if (!continues) {
                canvas.moveTo(mm(start.x), size.y - mm(start.y));
              }

              if (segment is BezierSegment) {
                final c1 = _local(segment.control1, ox, oy);
                final c2 = _local(segment.control2, ox, oy);
                canvas.curveTo(
                  mm(c1.x),
                  size.y - mm(c1.y),
                  mm(c2.x),
                  size.y - mm(c2.y),
                  mm(end.x),
                  size.y - mm(end.y),
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
        pw.Positioned(
          left: 0,
          top: 0,
          child: pw.ClipRect(
            child: pw.CustomPaint(
              size: PdfPoint(mm(_tileWidthMm), mm(_tileHeightMm)),
              painter: (canvas, size) {
                final leg1 = _local(dart.leg1, ox, oy);
                final apex = _local(dart.apex, ox, oy);
                final leg2 = _local(dart.leg2, ox, oy);
                canvas
                  ..setStrokeColor(PdfColors.black)
                  ..setLineWidth(mm(0.30))
                  ..moveTo(mm(leg1.x), size.y - mm(leg1.y))
                  ..lineTo(mm(apex.x), size.y - mm(apex.y))
                  ..lineTo(mm(leg2.x), size.y - mm(leg2.y))
                  ..strokePath();
              },
            ),
          ),
        ),
    ];
  }

  _LocalPoint _local(PatternPoint point, double ox, double oy) =>
      _LocalPoint(ox + point.x * 10.0, oy + point.y * 10.0);

  _Bounds _pieceBounds(PatternPiece piece) {
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
    return _Bounds(minX, minY, maxX, maxY);
  }
}

class _LocalPoint {
  final double x;
  final double y;
  const _LocalPoint(this.x, this.y);
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
