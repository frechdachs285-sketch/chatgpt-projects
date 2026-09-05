import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pattern_models.dart';
import 'skirt_pattern_calculator.dart';

class PatternPdfExporter {
  static const _mmToPt = 72.0 / 25.4;
  static const _pageMarginMm = 10.0;
  static const _tileWidthMm = 190.0;
  static const _tileHeightMm = 259.0;
  static const _tileOverlapMm = 10.0;

  static double mm(double v) => v * _mmToPt;

  Future<Uint8List> buildCalibrationPage() => buildPatternPdf(
        measurements: const Measurements(
          waist: 76,
          hip: 100,
          hipDepth: 21,
          skirtLength: 60,
        ),
        seamAllowance: const SeamAllowanceSettings(enabled: true),
      );

  Future<Uint8List> buildPatternPdf({
    required Measurements measurements,
    required SeamAllowanceSettings seamAllowance,
  }) async {
    final doc = pw.Document();
    _addCalibrationPage(doc, measurements);

    final result = SkirtPatternCalculator().calculate(
      measurements,
      const ConstructionValues(),
      seamAllowance: seamAllowance,
    );

    if (result.isValid) {
      _addPatternTiles(doc, back: result.back!, front: result.front!);
    }

    return doc.save();
  }

  void _addCalibrationPage(pw.Document doc, Measurements m) {
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(mm(15)),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Schnittmuster-App - Rock 1:1',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: mm(4)),
            pw.Text(
              'Masse: Taille ${m.waist.toStringAsFixed(1)} cm | Huefte ${m.hip.toStringAsFixed(1)} cm | Huefttiefe ${m.hipDepth.toStringAsFixed(1)} cm | Rocklaenge ${m.skirtLength.toStringAsFixed(1)} cm',
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.SizedBox(height: mm(3)),
            pw.Text(
              'Bitte beim Drucken 100 % / Tatsaechliche Groesse waehlen. Keine Seitenanpassung verwenden.',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: mm(10)),
            pw.Text(
              'Kontrollquadrat 100 x 100 mm',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: mm(3)),
            pw.Container(
              width: mm(100),
              height: mm(100),
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.8)),
              child: pw.Center(
                child: pw.Text(
                  '100 mm x 100 mm',
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ),
            ),
            pw.SizedBox(height: mm(12)),
            pw.Text(
              'Kontrolllinie 200 mm',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: mm(3)),
            pw.Container(width: mm(200), height: 1, color: PdfColors.black),
            pw.SizedBox(height: mm(2)),
            pw.Text('200 mm', style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
      ),
    );
  }

  void _addPatternTiles(
    pw.Document doc, {
    required PatternPiece back,
    required PatternPiece front,
  }) {
    final bb = _pieceBounds(back);
    final fb = _pieceBounds(front);

    const pad = 15.0;
    const gap = 30.0;

    final backW = bb.width * 10;
    final backH = bb.height * 10;
    final frontW = fb.width * 10;
    final frontH = fb.height * 10;

    final backOX = pad - bb.minX * 10;
    final backOY = pad - bb.minY * 10;
    final frontOX = pad + backW + gap - fb.minX * 10;
    final frontOY = pad - fb.minY * 10;

    final canvasW = pad * 2 + backW + gap + frontW;
    final canvasH = pad * 2 + math.max(backH, frontH);

    final stepX = _tileWidthMm - _tileOverlapMm;
    final stepY = _tileHeightMm - _tileOverlapMm;
    final cols = math.max(1, ((canvasW - _tileWidthMm) / stepX).ceil() + 1);
    final rows = math.max(1, ((canvasH - _tileHeightMm) / stepY).ceil() + 1);

    final backBox = _PatternBounds(
      backOX + bb.minX * 10,
      backOY + bb.minY * 10,
      backOX + bb.maxX * 10,
      backOY + bb.maxY * 10,
    );
    final frontBox = _PatternBounds(
      frontOX + fb.minX * 10,
      frontOY + fb.minY * 10,
      frontOX + fb.maxX * 10,
      frontOY + fb.maxY * 10,
    );

    final kept = <String>{};
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final x = c * stepX;
        final y = r * stepY;
        final tile = _PatternBounds(
          x,
          y,
          x + _tileWidthMm,
          y + _tileHeightMm,
        );
        if (_overlaps(tile, backBox) || _overlaps(tile, frontBox)) {
          kept.add('$c:$r');
        }
      }
    }

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (!kept.contains('$c:$r')) continue;

        final tileX = c * stepX;
        final tileY = r * stepY;
        final tileName = '${String.fromCharCode(65 + c)}${r + 1}';

        doc.addPage(
          _tilePage(
            tileName: tileName,
            back: back,
            front: front,
            backOffsetX: backOX - tileX,
            backOffsetY: backOY - tileY,
            frontOffsetX: frontOX - tileX,
            frontOffsetY: frontOY - tileY,
            left: kept.contains('${c - 1}:$r'),
            right: kept.contains('${c + 1}:$r'),
            top: kept.contains('$c:${r - 1}'),
            bottom: kept.contains('$c:${r + 1}'),
          ),
        );
      }
    }
  }

  pw.Page _tilePage({
    required String tileName,
    required PatternPiece back,
    required PatternPiece front,
    required double backOffsetX,
    required double backOffsetY,
    required double frontOffsetX,
    required double frontOffsetY,
    required bool left,
    required bool right,
    required bool top,
    required bool bottom,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(mm(_pageMarginMm)),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Rock v1 - A4 1:1',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Seite $tileName',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: mm(1.5)),
          pw.Container(
            width: double.infinity,
            padding: pw.EdgeInsets.symmetric(
              horizontal: mm(2.5),
              vertical: mm(1.5),
            ),
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.45)),
            child: pw.Text(
              'MONTAGE: 1) rechte/untere SCHNEIDELINIE abschneiden  2) linke/obere KLEBEFLAECHE darunterlegen  3) PASSKREUZE exakt ausrichten.',
              style: pw.TextStyle(fontSize: 8.4, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: mm(2)),
          pw.Container(
            width: mm(_tileWidthMm),
            height: mm(_tileHeightMm),
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.25)),
            child: pw.CustomPaint(
              size: PdfPoint(mm(_tileWidthMm), mm(_tileHeightMm)),
              painter: (canvas, size) {
                canvas.saveContext();
                canvas.drawRect(0, 0, size.x, size.y);
                canvas.clipPath();
                canvas.setStrokeColor(PdfColors.black);

                _paintPiece(
                  canvas,
                  size,
                  back,
                  backOffsetX,
                  backOffsetY,
                );
                _paintPiece(
                  canvas,
                  size,
                  front,
                  frontOffsetX,
                  frontOffsetY,
                );
                _paintRegistrationMarks(
                  canvas,
                  size,
                  left: left,
                  right: right,
                  top: top,
                  bottom: bottom,
                );

                canvas.restoreContext();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _paintPiece(
    PdfGraphics canvas,
    PdfPoint size,
    PatternPiece piece,
    double ox,
    double oy,
  ) {
    if (piece.cuttingOutline != null) {
      canvas.setLineWidth(mm(0.8));
      _strokePath(canvas, size, piece.cuttingOutline!, ox, oy);
    }

    canvas.setLineWidth(mm(0.35));
    _strokePath(canvas, size, piece.outline, ox, oy);

    for (final dart in piece.darts) {
      canvas.setLineWidth(mm(0.35));
      canvas.moveTo(_px(dart.leg1, ox), _py(dart.leg1, oy, size));
      canvas.lineTo(_px(dart.apex, ox), _py(dart.apex, oy, size));
      canvas.lineTo(_px(dart.leg2, ox), _py(dart.leg2, oy, size));
      canvas.strokePath();
    }

    final grain = piece.grainline;
    if (grain != null) {
      canvas.setLineWidth(mm(0.35));
      final x1 = _px(grain.start, ox);
      final y1 = _py(grain.start, oy, size);
      final x2 = _px(grain.end, ox);
      final y2 = _py(grain.end, oy, size);
      canvas.drawLine(x1, y1, x2, y2);

      final arrow = mm(4);
      final half = mm(2.5);
      canvas.moveTo(x1, y1);
      canvas.lineTo(x1 - half, y1 - arrow);
      canvas.moveTo(x1, y1);
      canvas.lineTo(x1 + half, y1 - arrow);
      canvas.moveTo(x2, y2);
      canvas.lineTo(x2 - half, y2 + arrow);
      canvas.moveTo(x2, y2);
      canvas.lineTo(x2 + half, y2 + arrow);
      canvas.strokePath();
    }

    for (final notch in piece.notches) {
      final x = _px(notch.position, ox);
      final y = _py(notch.position, oy, size);
      final dir = piece.id == 'skirt_back' ? 1.0 : -1.0;
      final bx = x + mm(dir * 5);
      canvas.setLineWidth(mm(0.45));
      canvas.moveTo(x, y);
      canvas.lineTo(bx, y + mm(2.5));
      canvas.moveTo(x, y);
      canvas.lineTo(bx, y - mm(2.5));
      canvas.strokePath();
    }
  }

  void _strokePath(
    PdfGraphics canvas,
    PdfPoint size,
    PatternPath path,
    double ox,
    double oy,
  ) {
    if (path.segments.isEmpty) return;

    final first = path.segments.first.start;
    canvas.moveTo(_px(first, ox), _py(first, oy, size));

    for (final segment in path.segments) {
      if (segment is BezierSegment) {
        canvas.curveTo(
          _px(segment.control1, ox),
          _py(segment.control1, oy, size),
          _px(segment.control2, ox),
          _py(segment.control2, oy, size),
          _px(segment.end, ox),
          _py(segment.end, oy, size),
        );
      } else {
        canvas.lineTo(
          _px(segment.end, ox),
          _py(segment.end, oy, size),
        );
      }
    }

    canvas.strokePath();
  }

  void _paintRegistrationMarks(
    PdfGraphics canvas,
    PdfPoint size, {
    required bool left,
    required bool right,
    required bool top,
    required bool bottom,
  }) {
    final inset = mm(_tileOverlapMm / 2);
    final arm = mm(4);

    void cross(double x, double y) {
      canvas.setLineDashPattern();
      canvas.setLineWidth(mm(0.45));
      canvas.drawLine(x - arm, y, x + arm, y);
      canvas.drawLine(x, y - arm, x, y + arm);
    }

    if (left) {
      final x = inset;
      canvas.setLineDashPattern([mm(2), mm(2)]);
      canvas.setLineWidth(mm(0.25));
      canvas.drawLine(x, 0, x, size.y);
      cross(x, size.y - mm(35));
      cross(x, mm(35));
    }

    if (right) {
      final x = size.x - inset;
      canvas.setLineDashPattern([mm(5), mm(2)]);
      canvas.setLineWidth(mm(0.65));
      canvas.drawLine(x, 0, x, size.y);
      cross(x, size.y - mm(35));
      cross(x, mm(35));
    }

    if (top) {
      final y = size.y - inset;
      canvas.setLineDashPattern([mm(2), mm(2)]);
      canvas.setLineWidth(mm(0.25));
      canvas.drawLine(0, y, size.x, y);
      cross(mm(45), y);
      cross(size.x - mm(45), y);
    }

    if (bottom) {
      final y = inset;
      canvas.setLineDashPattern([mm(5), mm(2)]);
      canvas.setLineWidth(mm(0.65));
      canvas.drawLine(0, y, size.x, y);
      cross(mm(45), y);
      cross(size.x - mm(45), y);
    }

    canvas.setLineDashPattern();
  }

  double _px(PatternPoint p, double ox) => mm(ox + p.x * 10);

  double _py(PatternPoint p, double oy, PdfPoint size) =>
      size.y - mm(oy + p.y * 10);

  _PatternBounds _pieceBounds(PatternPiece piece) {
    final pts = <PatternPoint>[
      ...piece.points.values,
      for (final d in piece.darts) ...[d.leg1, d.leg2, d.apex],
      for (final s in piece.outline.segments) ...[
        s.start,
        s.end,
        if (s is BezierSegment) ...[s.control1, s.control2],
      ],
      if (piece.cuttingOutline != null)
        for (final s in piece.cuttingOutline!.segments) ...[
          s.start,
          s.end,
          if (s is BezierSegment) ...[s.control1, s.control2],
        ],
    ];

    var minX = pts.first.x;
    var maxX = pts.first.x;
    var minY = pts.first.y;
    var maxY = pts.first.y;

    for (final p in pts.skip(1)) {
      minX = math.min(minX, p.x);
      maxX = math.max(maxX, p.x);
      minY = math.min(minY, p.y);
      maxY = math.max(maxY, p.y);
    }

    return _PatternBounds(minX, minY, maxX, maxY);
  }

  bool _overlaps(_PatternBounds a, _PatternBounds b) =>
      a.minX < b.maxX &&
      a.maxX > b.minX &&
      a.minY < b.maxY &&
      a.maxY > b.minY;
}

class _PatternBounds {
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  const _PatternBounds(this.minX, this.minY, this.maxX, this.maxY);

  double get width => maxX - minX;
  double get height => maxY - minY;
}
