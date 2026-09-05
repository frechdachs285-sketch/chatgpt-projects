import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pattern_models.dart';
import 'skirt_pattern_calculator.dart';

class PatternPdfExporter {
  static const double _mmToPt = 72.0 / 25.4;
  static const double _pageMarginMm = 10.0;
  static const double _tileWidthMm = 190.0;
  static const double _tileHeightMm = 259.0;
  static const double _tileOverlapMm = 10.0;

  static double mm(double value) => value * _mmToPt;

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

  void _addCalibrationPage(pw.Document doc, Measurements measurements) {
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(mm(15)),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Schnittmuster-App - Rock 1:1',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: mm(4)),
              pw.Text(
                'Masse: Taille ${measurements.waist.toStringAsFixed(1)} cm | Huefte ${measurements.hip.toStringAsFixed(1)} cm | Huefttiefe ${measurements.hipDepth.toStringAsFixed(1)} cm | Rocklaenge ${measurements.skirtLength.toStringAsFixed(1)} cm',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: mm(3)),
              pw.Text(
                'Bitte beim Drucken 100 % / Tatsaechliche Groesse waehlen. Keine Seitenanpassung verwenden.',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: mm(10)),
              pw.Text('Kontrollquadrat 100 x 100 mm', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: mm(3)),
              pw.Container(
                width: mm(100),
                height: mm(100),
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.8)),
                child: pw.Center(child: pw.Text('100 mm x 100 mm', style: const pw.TextStyle(fontSize: 11))),
              ),
              pw.SizedBox(height: mm(12)),
              pw.Text('Kontrolllinie 200 mm', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: mm(3)),
              pw.Container(width: mm(200), height: 1, color: PdfColors.black),
              pw.SizedBox(height: mm(2)),
              pw.Text('200 mm', style: const pw.TextStyle(fontSize: 9)),
            ],
          );
        },
      ),
    );
  }

  void _addPatternTiles(
    pw.Document doc, {
    required PatternPiece back,
    required PatternPiece front,
  }) {
    final backBounds = _pieceBounds(back);
    final frontBounds = _pieceBounds(front);

    const outerPaddingMm = 15.0;
    const gapMm = 30.0;

    final backWidthMm = backBounds.width * 10;
    final backHeightMm = backBounds.height * 10;
    final frontWidthMm = frontBounds.width * 10;
    final frontHeightMm = frontBounds.height * 10;

    final backOffsetX = outerPaddingMm - backBounds.minX * 10;
    final backOffsetY = outerPaddingMm - backBounds.minY * 10;
    final frontOffsetX = outerPaddingMm + backWidthMm + gapMm - frontBounds.minX * 10;
    final frontOffsetY = outerPaddingMm - frontBounds.minY * 10;

    final canvasWidthMm = outerPaddingMm * 2 + backWidthMm + gapMm + frontWidthMm;
    final canvasHeightMm = outerPaddingMm * 2 + math.max(backHeightMm, frontHeightMm);

    final stepX = _tileWidthMm - _tileOverlapMm;
    final stepY = _tileHeightMm - _tileOverlapMm;
    final columns = math.max(1, ((canvasWidthMm - _tileWidthMm) / stepX).ceil() + 1);
    final rows = math.max(1, ((canvasHeightMm - _tileHeightMm) / stepY).ceil() + 1);

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < columns; col++) {
        final tileX = col * stepX;
        final tileY = row * stepY;
        final tileName = '${String.fromCharCode(65 + col)}${row + 1}';
        final svg = _buildTileSvg(
          back: back,
          front: front,
          backOffsetX: backOffsetX,
          backOffsetY: backOffsetY,
          frontOffsetX: frontOffsetX,
          frontOffsetY: frontOffsetY,
          tileX: tileX,
          tileY: tileY,
          hasLeftNeighbor: col > 0,
          hasRightNeighbor: col < columns - 1,
          hasTopNeighbor: row > 0,
          hasBottomNeighbor: row < rows - 1,
        );

        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(mm(_pageMarginMm)),
            build: (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Rock v1 - A4 1:1', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Seite $tileName', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: mm(1.5)),
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.symmetric(horizontal: mm(2.5), vertical: mm(1.5)),
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
                  child: pw.SvgImage(
                    svg: svg,
                    width: mm(_tileWidthMm),
                    height: mm(_tileHeightMm),
                    fit: pw.BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  String _buildTileSvg({
    required PatternPiece back,
    required PatternPiece front,
    required double backOffsetX,
    required double backOffsetY,
    required double frontOffsetX,
    required double frontOffsetY,
    required double tileX,
    required double tileY,
    required bool hasLeftNeighbor,
    required bool hasRightNeighbor,
    required bool hasTopNeighbor,
    required bool hasBottomNeighbor,
  }) {
    final b = StringBuffer();
    b.writeln('<svg xmlns="http://www.w3.org/2000/svg" viewBox="$tileX $tileY $_tileWidthMm $_tileHeightMm">');
    b.writeln('<rect x="$tileX" y="$tileY" width="$_tileWidthMm" height="$_tileHeightMm" fill="white"/>');
    _writePieceSvg(b, back, backOffsetX, backOffsetY);
    _writePieceSvg(b, front, frontOffsetX, frontOffsetY);
    _writeRegistrationMarks(
      b,
      tileX: tileX,
      tileY: tileY,
      hasLeftNeighbor: hasLeftNeighbor,
      hasRightNeighbor: hasRightNeighbor,
      hasTopNeighbor: hasTopNeighbor,
      hasBottomNeighbor: hasBottomNeighbor,
    );
    b.writeln('</svg>');
    return b.toString();
  }

  void _writeRegistrationMarks(
    StringBuffer b, {
    required double tileX,
    required double tileY,
    required bool hasLeftNeighbor,
    required bool hasRightNeighbor,
    required bool hasTopNeighbor,
    required bool hasBottomNeighbor,
  }) {
    const inset = _tileOverlapMm / 2;
    const arm = 4.0;
    final centerX = tileX + _tileWidthMm / 2;
    final centerY = tileY + _tileHeightMm / 2;

    void cross(double x, double y) {
      b.writeln('<circle cx="$x" cy="$y" r="1.5" fill="white" stroke="black" stroke-width="0.45"/>');
      b.writeln('<line x1="${x - arm}" y1="$y" x2="${x + arm}" y2="$y" stroke="black" stroke-width="0.45"/>');
      b.writeln('<line x1="$x" y1="${y - arm}" x2="$x" y2="${y + arm}" stroke="black" stroke-width="0.45"/>');
    }

    if (hasLeftNeighbor) {
      final x = tileX + inset;
      b.writeln('<line x1="$x" y1="$tileY" x2="$x" y2="${tileY + _tileHeightMm}" stroke="black" stroke-width="0.25" stroke-dasharray="2,2"/>');
      b.writeln('<text x="${x + 2}" y="${tileY + 18}" font-family="Helvetica" font-size="4.2" font-weight="bold" fill="black">KLEBEFLAECHE</text>');
      cross(x, tileY + 35);
      cross(x, tileY + _tileHeightMm - 35);
    }
    if (hasRightNeighbor) {
      final x = tileX + _tileWidthMm - inset;
      b.writeln('<line x1="$x" y1="$tileY" x2="$x" y2="${tileY + _tileHeightMm}" stroke="black" stroke-width="0.65" stroke-dasharray="5,2"/>');
      b.writeln('<text x="${x - 2}" y="${tileY + 18}" font-family="Helvetica" font-size="4.2" font-weight="bold" text-anchor="end" fill="black">SCHNEIDELINIE</text>');
      cross(x, tileY + 35);
      cross(x, tileY + _tileHeightMm - 35);
    }
    if (hasTopNeighbor) {
      final y = tileY + inset;
      b.writeln('<line x1="$tileX" y1="$y" x2="${tileX + _tileWidthMm}" y2="$y" stroke="black" stroke-width="0.25" stroke-dasharray="2,2"/>');
      b.writeln('<text x="${tileX + 8}" y="${y + 5}" font-family="Helvetica" font-size="4.2" font-weight="bold" fill="black">KLEBEFLAECHE</text>');
      cross(tileX + 45, y);
      cross(tileX + _tileWidthMm - 45, y);
    }
    if (hasBottomNeighbor) {
      final y = tileY + _tileHeightMm - inset;
      b.writeln('<line x1="$tileX" y1="$y" x2="${tileX + _tileWidthMm}" y2="$y" stroke="black" stroke-width="0.65" stroke-dasharray="5,2"/>');
      b.writeln('<text x="${tileX + 8}" y="${y - 3}" font-family="Helvetica" font-size="4.2" font-weight="bold" fill="black">SCHNEIDELINIE</text>');
      cross(tileX + 45, y);
      cross(tileX + _tileWidthMm - 45, y);
    }

    b.writeln('<line x1="${centerX - 2}" y1="$tileY" x2="${centerX + 2}" y2="$tileY" stroke="black" stroke-width="0.25"/>');
    b.writeln('<line x1="${centerX - 2}" y1="${tileY + _tileHeightMm}" x2="${centerX + 2}" y2="${tileY + _tileHeightMm}" stroke="black" stroke-width="0.25"/>');
    b.writeln('<line x1="$tileX" y1="${centerY - 2}" x2="$tileX" y2="${centerY + 2}" stroke="black" stroke-width="0.25"/>');
    b.writeln('<line x1="${tileX + _tileWidthMm}" y1="${centerY - 2}" x2="${tileX + _tileWidthMm}" y2="${centerY + 2}" stroke="black" stroke-width="0.25"/>');
  }

  void _writePieceSvg(StringBuffer b, PatternPiece piece, double offsetX, double offsetY) {
    if (piece.cuttingOutline != null) {
      b.writeln('<path d="${_pathData(piece.cuttingOutline!, offsetX, offsetY)}" fill="none" stroke="black" stroke-width="0.8"/>');
    }
    b.writeln('<path d="${_pathData(piece.outline, offsetX, offsetY)}" fill="none" stroke="black" stroke-width="0.35"/>');

    final grainline = piece.grainline;
    if (grainline != null) {
      final x1 = _x(grainline.start, offsetX);
      final y1 = _y(grainline.start, offsetY);
      final x2 = _x(grainline.end, offsetX);
      final y2 = _y(grainline.end, offsetY);
      b.writeln('<line x1="$x1" y1="$y1" x2="$x2" y2="$y2" stroke="black" stroke-width="0.35"/>');
      b.writeln('<path d="M ${x1 - 3} ${y1 + 5} L $x1 $y1 L ${x1 + 3} ${y1 + 5}" fill="none" stroke="black" stroke-width="0.35"/>');
      b.writeln('<path d="M ${x2 - 3} ${y2 - 5} L $x2 $y2 L ${x2 + 3} ${y2 - 5}" fill="none" stroke="black" stroke-width="0.35"/>');
    }

    for (final notch in piece.notches) {
      final x = _x(notch.position, offsetX);
      final y = _y(notch.position, offsetY);
      final direction = piece.id == 'skirt_back' ? 1.0 : -1.0;
      final baseX = x + direction * 5;
      b.writeln('<path d="M $x $y L $baseX ${y - 2.5} M $x $y L $baseX ${y + 2.5}" fill="none" stroke="black" stroke-width="0.45"/>');
    }

    for (final label in piece.labels) {
      final x = _x(label.position, offsetX);
      final y = _y(label.position, offsetY);
      final text = _escape(label.text);
      b.writeln('<text x="$x" y="$y" font-family="Helvetica" font-size="4.5" text-anchor="middle" fill="black">$text</text>');
    }
  }

  String _pathData(PatternPath path, double offsetX, double offsetY) {
    if (path.segments.isEmpty) return '';
    final b = StringBuffer();
    final first = path.segments.first.start;
    b.write('M ${_x(first, offsetX)} ${_y(first, offsetY)} ');
    for (final segment in path.segments) {
      if (segment is BezierSegment) {
        b.write(
          'C ${_x(segment.control1, offsetX)} ${_y(segment.control1, offsetY)} '
          '${_x(segment.control2, offsetX)} ${_y(segment.control2, offsetY)} '
          '${_x(segment.end, offsetX)} ${_y(segment.end, offsetY)} ',
        );
      } else {
        b.write('L ${_x(segment.end, offsetX)} ${_y(segment.end, offsetY)} ');
      }
    }
    return b.toString();
  }

  double _x(PatternPoint point, double offsetX) => offsetX + point.x * 10;
  double _y(PatternPoint point, double offsetY) => offsetY + point.y * 10;

  _PatternBounds _pieceBounds(PatternPiece piece) {
    final points = <PatternPoint>[
      ...piece.points.values,
      for (final dart in piece.darts) ...[dart.leg1, dart.leg2, dart.apex],
      for (final segment in piece.outline.segments) ...[
        segment.start,
        segment.end,
        if (segment is BezierSegment) ...[segment.control1, segment.control2],
      ],
      if (piece.cuttingOutline != null)
        for (final segment in piece.cuttingOutline!.segments) ...[
          segment.start,
          segment.end,
          if (segment is BezierSegment) ...[segment.control1, segment.control2],
        ],
    ];

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
    return _PatternBounds(minX, minY, maxX, maxY);
  }

  String _escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
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
