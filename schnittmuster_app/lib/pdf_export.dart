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
        measurements: const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
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
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(mm(15)),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Schnittmuster-App - Rock 1:1', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: mm(4)),
          pw.Text('Masse: Taille ${m.waist.toStringAsFixed(1)} cm | Huefte ${m.hip.toStringAsFixed(1)} cm | Huefttiefe ${m.hipDepth.toStringAsFixed(1)} cm | Rocklaenge ${m.skirtLength.toStringAsFixed(1)} cm', style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: mm(3)),
          pw.Text('Bitte beim Drucken 100 % / Tatsaechliche Groesse waehlen. Keine Seitenanpassung verwenden.', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: mm(10)),
          pw.Text('Kontrollquadrat 100 x 100 mm', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: mm(3)),
          pw.Container(width: mm(100), height: mm(100), decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.8)), child: pw.Center(child: pw.Text('100 mm x 100 mm', style: const pw.TextStyle(fontSize: 11)))),
          pw.SizedBox(height: mm(12)),
          pw.Text('Kontrolllinie 200 mm', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: mm(3)),
          pw.Container(width: mm(200), height: 1, color: PdfColors.black),
          pw.SizedBox(height: mm(2)),
          pw.Text('200 mm', style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    ));
  }

  void _addPatternTiles(pw.Document doc, {required PatternPiece back, required PatternPiece front}) {
    final bb = _pieceBounds(back);
    final fb = _pieceBounds(front);
    const pad = 15.0, gap = 30.0;
    final backW = bb.width * 10, backH = bb.height * 10;
    final frontW = fb.width * 10, frontH = fb.height * 10;
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

    final backBox = _PatternBounds(backOX + bb.minX * 10, backOY + bb.minY * 10, backOX + bb.maxX * 10, backOY + bb.maxY * 10);
    final frontBox = _PatternBounds(frontOX + fb.minX * 10, frontOY + fb.minY * 10, frontOX + fb.maxX * 10, frontOY + fb.maxY * 10);
    final kept = <String>{};

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final x = c * stepX, y = r * stepY;
        final tile = _PatternBounds(x, y, x + _tileWidthMm, y + _tileHeightMm);
        if (_overlaps(tile, backBox) || _overlaps(tile, frontBox)) kept.add('$c:$r');
      }
    }

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (!kept.contains('$c:$r')) continue;
        final tileX = c * stepX, tileY = r * stepY;
        final tileName = '${String.fromCharCode(65 + c)}${r + 1}';
        final svg = _buildTileSvg(
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
        );
        doc.addPage(_tilePage(tileName, svg));
      }
    }
  }

  pw.Page _tilePage(String tileName, String svg) => pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(mm(_pageMarginMm)),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Rock v1 - A4 1:1', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Text('Seite $tileName', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ]),
            pw.SizedBox(height: mm(1.5)),
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.symmetric(horizontal: mm(2.5), vertical: mm(1.5)),
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.45)),
              child: pw.Text('MONTAGE: 1) rechte/untere SCHNEIDELINIE abschneiden  2) linke/obere KLEBEFLAECHE darunterlegen  3) PASSKREUZE exakt ausrichten.', style: pw.TextStyle(fontSize: 8.4, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: mm(2)),
            pw.Container(
              width: mm(_tileWidthMm),
              height: mm(_tileHeightMm),
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.25)),
              child: pw.SvgImage(svg: svg, width: mm(_tileWidthMm), height: mm(_tileHeightMm), fit: pw.BoxFit.fill),
            ),
          ],
        ),
      );

  String _buildTileSvg({
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
    final b = StringBuffer();
    b.writeln('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $_tileWidthMm $_tileHeightMm">');
    b.writeln('<rect width="$_tileWidthMm" height="$_tileHeightMm" fill="white"/>');
    _writePieceSvg(b, back, backOffsetX, backOffsetY);
    _writePieceSvg(b, front, frontOffsetX, frontOffsetY);
    _writeMarks(b, left: left, right: right, top: top, bottom: bottom);
    b.writeln('</svg>');
    return b.toString();
  }

  void _writeMarks(StringBuffer b, {required bool left, required bool right, required bool top, required bool bottom}) {
    const inset = _tileOverlapMm / 2, arm = 4.0;
    void cross(double x, double y) {
      b.writeln('<circle cx="$x" cy="$y" r="1.5" fill="white" stroke="black" stroke-width="0.45"/>');
      b.writeln('<line x1="${x - arm}" y1="$y" x2="${x + arm}" y2="$y" stroke="black" stroke-width="0.45"/>');
      b.writeln('<line x1="$x" y1="${y - arm}" x2="$x" y2="${y + arm}" stroke="black" stroke-width="0.45"/>');
    }
    if (left) {
      final x = inset;
      b.writeln('<line x1="$x" y1="0" x2="$x" y2="$_tileHeightMm" stroke="black" stroke-width="0.25" stroke-dasharray="2,2"/>');
      cross(x, 35); cross(x, _tileHeightMm - 35);
    }
    if (right) {
      final x = _tileWidthMm - inset;
      b.writeln('<line x1="$x" y1="0" x2="$x" y2="$_tileHeightMm" stroke="black" stroke-width="0.65" stroke-dasharray="5,2"/>');
      cross(x, 35); cross(x, _tileHeightMm - 35);
    }
    if (top) {
      final y = inset;
      b.writeln('<line x1="0" y1="$y" x2="$_tileWidthMm" y2="$y" stroke="black" stroke-width="0.25" stroke-dasharray="2,2"/>');
      cross(45, y); cross(_tileWidthMm - 45, y);
    }
    if (bottom) {
      final y = _tileHeightMm - inset;
      b.writeln('<line x1="0" y1="$y" x2="$_tileWidthMm" y2="$y" stroke="black" stroke-width="0.65" stroke-dasharray="5,2"/>');
      cross(45, y); cross(_tileWidthMm - 45, y);
    }
  }

  void _writePieceSvg(StringBuffer b, PatternPiece piece, double ox, double oy) {
    if (piece.cuttingOutline != null) b.writeln('<path d="${_pathData(piece.cuttingOutline!, ox, oy)}" fill="none" stroke="black" stroke-width="0.8"/>');
    b.writeln('<path d="${_pathData(piece.outline, ox, oy)}" fill="none" stroke="black" stroke-width="0.35"/>');

    for (final d in piece.darts) {
      final l1x = _x(d.leg1, ox), l1y = _y(d.leg1, oy);
      final ax = _x(d.apex, ox), ay = _y(d.apex, oy);
      final l2x = _x(d.leg2, ox), l2y = _y(d.leg2, oy);
      b.writeln('<path d="M $l1x $l1y L $ax $ay L $l2x $l2y" fill="none" stroke="black" stroke-width="0.35"/>');
    }

    final g = piece.grainline;
    if (g != null) {
      final x1 = _x(g.start, ox), y1 = _y(g.start, oy), x2 = _x(g.end, ox), y2 = _y(g.end, oy);
      b.writeln('<line x1="$x1" y1="$y1" x2="$x2" y2="$y2" stroke="black" stroke-width="0.35"/>');
    }

    for (final n in piece.notches) {
      final x = _x(n.position, ox), y = _y(n.position, oy);
      final dir = piece.id == 'skirt_back' ? 1.0 : -1.0;
      final bx = x + dir * 5;
      b.writeln('<path d="M $x $y L $bx ${y - 2.5} M $x $y L $bx ${y + 2.5}" fill="none" stroke="black" stroke-width="0.45"/>');
    }

    for (final label in piece.labels) {
      b.writeln('<text x="${_x(label.position, ox)}" y="${_y(label.position, oy)}" font-family="Helvetica" font-size="4.5" text-anchor="middle" fill="black">${_escape(label.text)}</text>');
    }
  }

  String _pathData(PatternPath path, double ox, double oy) {
    if (path.segments.isEmpty) return '';
    final b = StringBuffer();
    final first = path.segments.first.start;
    b.write('M ${_x(first, ox)} ${_y(first, oy)} ');
    for (final s in path.segments) {
      if (s is BezierSegment) {
        b.write('C ${_x(s.control1, ox)} ${_y(s.control1, oy)} ${_x(s.control2, ox)} ${_y(s.control2, oy)} ${_x(s.end, ox)} ${_y(s.end, oy)} ');
      } else {
        b.write('L ${_x(s.end, ox)} ${_y(s.end, oy)} ');
      }
    }
    return b.toString();
  }

  double _x(PatternPoint p, double ox) => ox + p.x * 10;
  double _y(PatternPoint p, double oy) => oy + p.y * 10;

  _PatternBounds _pieceBounds(PatternPiece piece) {
    final pts = <PatternPoint>[
      ...piece.points.values,
      for (final d in piece.darts) ...[d.leg1, d.leg2, d.apex],
      for (final s in piece.outline.segments) ...[s.start, s.end, if (s is BezierSegment) ...[s.control1, s.control2]],
      if (piece.cuttingOutline != null)
        for (final s in piece.cuttingOutline!.segments) ...[s.start, s.end, if (s is BezierSegment) ...[s.control1, s.control2]],
    ];
    var minX = pts.first.x, maxX = pts.first.x, minY = pts.first.y, maxY = pts.first.y;
    for (final p in pts.skip(1)) {
      minX = math.min(minX, p.x); maxX = math.max(maxX, p.x);
      minY = math.min(minY, p.y); maxY = math.max(maxY, p.y);
    }
    return _PatternBounds(minX, minY, maxX, maxY);
  }

  bool _overlaps(_PatternBounds a, _PatternBounds b) => a.minX < b.maxX && a.maxX > b.minX && a.minY < b.maxY && a.maxY > b.minY;
  String _escape(String v) => v.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');
}

class _PatternBounds {
  final double minX, minY, maxX, maxY;
  const _PatternBounds(this.minX, this.minY, this.maxX, this.maxY);
  double get width => maxX - minX;
  double get height => maxY - minY;
}
