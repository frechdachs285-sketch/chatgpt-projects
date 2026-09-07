import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pattern_models.dart';
import 'skirt_pattern_calculator.dart';

class PatternPdfExporter {
  static const _mmToPt = 72.0 / 25.4;
  static const _pageMarginMm = 10.0;
  static const _rockTileWidthMm = 190.0;
  static const _rockTileHeightMm = 240.0;
  static const _waistbandTileWidthMm = 277.0;
  static const _waistbandTileHeightMm = 150.0;
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
    ConstructionValues construction = const ConstructionValues(),
  }) async {
    final doc = pw.Document();
    _addCalibrationPage(doc, measurements);

    final result = SkirtPatternCalculator().calculate(
      measurements,
      construction,
      seamAllowance: seamAllowance,
    );

    if (result.isValid) {
      _addRockTiles(doc, back: result.back!, front: result.front!);
      if (result.waistband != null) {
        _addWaistbandLandscapeTiles(doc, result.waistband!);
      }
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

  void _addRockTiles(
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

    final stepX = _rockTileWidthMm - _tileOverlapMm;
    final stepY = _rockTileHeightMm - _tileOverlapMm;
    final cols = math.max(1, ((canvasW - _rockTileWidthMm) / stepX).ceil() + 1);
    final rows = math.max(1, ((canvasH - _rockTileHeightMm) / stepY).ceil() + 1);

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
        final tile = _PatternBounds(
          c * stepX,
          r * stepY,
          c * stepX + _rockTileWidthMm,
          r * stepY + _rockTileHeightMm,
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
        final children = <pw.Widget>[
          ..._pieceWidgets(
            back,
            backOX - tileX,
            backOY - tileY,
            _rockTileWidthMm,
            _rockTileHeightMm,
          ),
          ..._pieceWidgets(
            front,
            frontOX - tileX,
            frontOY - tileY,
            _rockTileWidthMm,
            _rockTileHeightMm,
          ),
          ..._registrationWidgets(
            tileW: _rockTileWidthMm,
            tileH: _rockTileHeightMm,
            left: kept.contains('${c - 1}:$r'),
            right: kept.contains('${c + 1}:$r'),
            top: kept.contains('$c:${r - 1}'),
            bottom: kept.contains('$c:${r + 1}'),
          ),
        ];
        doc.addPage(
          _tilePage(
            pageFormat: PdfPageFormat.a4,
            title: 'Rock v1 - A4 1:1',
            tileName: tileName,
            tileW: _rockTileWidthMm,
            tileH: _rockTileHeightMm,
            children: children,
          ),
        );
      }
    }
  }

  void _addWaistbandLandscapeTiles(pw.Document doc, PatternPiece waistband) {
    final b = _pieceBounds(waistband);
    const padX = 10.0;
    const padY = 15.0;
    final pieceW = b.width * 10;
    final pieceH = b.height * 10;
    final ox = padX - b.minX * 10;
    final oy = padY + (_waistbandTileHeightMm - pieceH) / 2 - b.minY * 10;
    final canvasW = padX * 2 + pieceW;
    final stepX = _waistbandTileWidthMm - _tileOverlapMm;
    final cols = math.max(1, ((canvasW - _waistbandTileWidthMm) / stepX).ceil() + 1);

    for (var c = 0; c < cols; c++) {
      final tileX = c * stepX;
      final children = <pw.Widget>[
        ..._pieceWidgets(
          waistband,
          ox - tileX,
          oy,
          _waistbandTileWidthMm,
          _waistbandTileHeightMm,
        ),
        ..._registrationWidgets(
          tileW: _waistbandTileWidthMm,
          tileH: _waistbandTileHeightMm,
          left: c > 0,
          right: c < cols - 1,
          top: false,
          bottom: false,
        ),
      ];
      doc.addPage(
        _tilePage(
          pageFormat: PdfPageFormat.a4.landscape,
          title: 'Rock v1 - Bund A4 quer 1:1',
          tileName: 'Bund ${String.fromCharCode(65 + c)}1',
          tileW: _waistbandTileWidthMm,
          tileH: _waistbandTileHeightMm,
          children: children,
        ),
      );
    }
  }

  pw.Page _tilePage({
    required PdfPageFormat pageFormat,
    required String title,
    required String tileName,
    required double tileW,
    required double tileH,
    required List<pw.Widget> children,
  }) {
    return pw.Page(
      pageFormat: pageFormat,
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
              'MONTAGE: 1) rechte/untere SCHNEIDELINIE abschneiden  2) linke/obere KLEBEFLAECHE darunterlegen  3) PASSKREUZE exakt ausrichten.',
              style: pw.TextStyle(fontSize: 8.4, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: mm(2)),
          pw.Container(
            width: mm(tileW),
            height: mm(tileH),
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.25)),
            child: pw.Stack(children: children),
          ),
        ],
      ),
    );
  }

  List<pw.Widget> _pieceWidgets(
    PatternPiece piece,
    double ox,
    double oy,
    double tileW,
    double tileH,
  ) {
    final widgets = <pw.Widget>[];
    if (piece.cuttingOutline != null) {
      widgets.add(_pathPaintWidget(piece.cuttingOutline!, ox, oy, 0.72, tileW, tileH));
    }
    widgets.add(_pathPaintWidget(piece.outline, ox, oy, 0.30, tileW, tileH));

    for (final guide in piece.guideLines) {
      final a = _local(guide.start, ox, oy);
      final z = _local(guide.end, ox, oy);
      final line = _lineWidget(a.x, a.y, z.x, z.y, 0.35, tileW, tileH);
      if (line != null) widgets.add(line);
    }

    final grain = piece.grainline;
    if (grain != null) {
      widgets.addAll(_grainlineWidgets(grain, ox, oy, tileW, tileH));
    }

    for (final notch in piece.notches) {
      final p = _local(notch.position, ox, oy);
      final dir = piece.id == 'skirt_back' ? 1.0 : -1.0;
      final a = _lineWidget(p.x, p.y, p.x + dir * 5, p.y - 2.5, 0.45, tileW, tileH);
      final z = _lineWidget(p.x, p.y, p.x + dir * 5, p.y + 2.5, 0.45, tileW, tileH);
      if (a != null) widgets.add(a);
      if (z != null) widgets.add(z);
    }

    for (final notch in piece.dartNotches) {
      final p = _local(notch.position, ox, oy);
      final parts = notch.role.split('_');
      if (parts.length != 3) continue;
      final dartIndex = int.tryParse(parts[1]);
      if (dartIndex == null || dartIndex < 0 || dartIndex >= piece.darts.length) continue;
      final dart = piece.darts[dartIndex];
      final legPoint = parts[2] == 'leg1' ? dart.leg1 : dart.leg2;
      final target = _local(legPoint, ox, oy);
      final dx = target.x - p.x;
      final dy = target.y - p.y;
      final length = math.sqrt(dx * dx + dy * dy);
      if (length <= 0.01) continue;
      const notchLengthMm = 4.0;
      final line = _lineWidget(
        p.x,
        p.y,
        p.x + dx / length * notchLengthMm,
        p.y + dy / length * notchLengthMm,
        0.45,
        tileW,
        tileH,
      );
      if (line != null) widgets.add(line);
    }

    final zipperEnd = piece.points['ZIP_END'];
    if (piece.id == 'skirt_back' && zipperEnd != null) {
      final p = _local(zipperEnd, ox, oy);
      final mark = _lineWidget(p.x, p.y, p.x + 8.0, p.y, 0.55, tileW, tileH);
      if (mark != null) widgets.add(mark);
      if (p.x >= -5 && p.x <= tileW && p.y >= 0 && p.y <= tileH) {
        widgets.add(
          pw.Positioned(
            left: mm(math.max(0, p.x + 10)),
            top: mm(math.max(0, p.y - 3)),
            child: pw.Text(
              'Reissverschluss Ende',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
          ),
        );
      }
    }

    for (final label in piece.labels) {
      final p = _local(label.position, ox, oy);
      if (p.x >= 0 && p.x <= tileW && p.y >= 0 && p.y <= tileH) {
        widgets.add(
          pw.Positioned(
            left: mm(math.max(0, p.x - 35)),
            top: mm(math.max(0, p.y - 3)),
            child: pw.Container(
              width: mm(70),
              child: pw.Text(
                label.text,
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  List<pw.Widget> _grainlineWidgets(
    Grainline grain,
    double ox,
    double oy,
    double tileW,
    double tileH,
  ) {
    final widgets = <pw.Widget>[];
    final a = _local(grain.start, ox, oy);
    final z = _local(grain.end, ox, oy);
    final visible = _clipLine(a.x, a.y, z.x, z.y, tileW, tileH);
    final line = _lineWidget(a.x, a.y, z.x, z.y, 0.40, tileW, tileH);
    if (line != null) widgets.add(line);

    final dx = z.x - a.x;
    final dy = z.y - a.y;
    final length = math.sqrt(dx * dx + dy * dy);
    if (length < 0.01) return widgets;
    final ux = dx / length;
    final uy = dy / length;
    final px = -uy;
    final py = ux;
    const arrowLength = 7.0;
    const arrowHalfWidth = 3.0;

    void addArrow(double x, double y, double direction) {
      if (x < 0 || x > tileW || y < 0 || y > tileH) return;
      final baseX = x - ux * arrowLength * direction;
      final baseY = y - uy * arrowLength * direction;
      final l = _lineWidget(
        x,
        y,
        baseX + px * arrowHalfWidth,
        baseY + py * arrowHalfWidth,
        0.40,
        tileW,
        tileH,
      );
      final r = _lineWidget(
        x,
        y,
        baseX - px * arrowHalfWidth,
        baseY - py * arrowHalfWidth,
        0.40,
        tileW,
        tileH,
      );
      if (l != null) widgets.add(l);
      if (r != null) widgets.add(r);
    }

    addArrow(a.x, a.y, -1.0);
    addArrow(z.x, z.y, 1.0);

    if (visible != null) {
      final visibleLength = math.sqrt(
        math.pow(visible.x2 - visible.x1, 2) + math.pow(visible.y2 - visible.y1, 2),
      );
      if (visibleLength >= 20) {
        final mx = (visible.x1 + visible.x2) / 2;
        final my = (visible.y1 + visible.y2) / 2;
        widgets.add(
          pw.Positioned(
            left: mm(math.min(tileW - 28.0, math.max(2.0, mx + 4.0))),
            top: mm(math.min(tileH - 6.0, math.max(2.0, my - 3.0))),
            child: pw.Text(
              'Fadenlauf',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  pw.Widget _pathPaintWidget(
    PatternPath path,
    double ox,
    double oy,
    double strokeMm,
    double tileW,
    double tileH,
  ) {
    return pw.Positioned(
      left: 0,
      top: 0,
      child: pw.ClipRect(
        child: pw.CustomPaint(
          size: PdfPoint(mm(tileW), mm(tileH)),
          painter: (canvas, size) {
            canvas
              ..setStrokeColor(PdfColors.black)
              ..setLineWidth(mm(strokeMm))
              ..setLineJoin(PdfLineJoin.round)
              ..setLineCap(PdfLineCap.round);
            PatternPoint? previousEnd;
            for (final segment in path.segments) {
              final start = _local(segment.start, ox, oy);
              final end = _local(segment.end, ox, oy);
              final continues = previousEnd != null &&
                  (previousEnd.x - segment.start.x).abs() < 1e-9 &&
                  (previousEnd.y - segment.start.y).abs() < 1e-9;
              if (!continues) canvas.moveTo(mm(start.x), size.y - mm(start.y));
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

  _LocalPoint _local(PatternPoint p, double ox, double oy) =>
      _LocalPoint(ox + p.x * 10, oy + p.y * 10);

  pw.Widget? _lineWidget(
    double x1,
    double y1,
    double x2,
    double y2,
    double strokeMm,
    double tileW,
    double tileH,
  ) {
    final clipped = _clipLine(x1, y1, x2, y2, tileW, tileH);
    if (clipped == null) return null;
    final dx = clipped.x2 - clipped.x1;
    final dy = clipped.y2 - clipped.y1;
    final length = math.sqrt(dx * dx + dy * dy);
    if (length < 0.01) return null;
    const joinOverlapMm = 0.35;
    final ux = dx / length;
    final uy = dy / length;
    final extended = _clipLine(
      clipped.x1 - ux * joinOverlapMm,
      clipped.y1 - uy * joinOverlapMm,
      clipped.x2 + ux * joinOverlapMm,
      clipped.y2 + uy * joinOverlapMm,
      tileW,
      tileH,
    );
    if (extended == null) return null;
    final drawDx = extended.x2 - extended.x1;
    final drawDy = extended.y2 - extended.y1;
    final drawLength = math.sqrt(drawDx * drawDx + drawDy * drawDy);
    if (drawLength < 0.01) return null;
    final angle = math.atan2(drawDy, drawDx);
    return pw.Positioned(
      left: mm(extended.x1),
      top: mm(extended.y1 - strokeMm / 2),
      child: pw.Transform.rotate(
        angle: angle,
        alignment: pw.Alignment.centerLeft,
        child: pw.Container(
          width: mm(drawLength),
          height: mm(strokeMm),
          color: PdfColors.black,
        ),
      ),
    );
  }

  _ClippedLine? _clipLine(
    double x1,
    double y1,
    double x2,
    double y2,
    double tileW,
    double tileH,
  ) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    var t0 = 0.0;
    var t1 = 1.0;
    bool clip(double p, double q) {
      if (p.abs() < 1e-12) return q >= 0;
      final r = q / p;
      if (p < 0) {
        if (r > t1) return false;
        if (r > t0) t0 = r;
      } else {
        if (r < t0) return false;
        if (r < t1) t1 = r;
      }
      return true;
    }
    if (!clip(-dx, x1)) return null;
    if (!clip(dx, tileW - x1)) return null;
    if (!clip(-dy, y1)) return null;
    if (!clip(dy, tileH - y1)) return null;
    return _ClippedLine(
      x1 + t0 * dx,
      y1 + t0 * dy,
      x1 + t1 * dx,
      y1 + t1 * dy,
    );
  }

  List<pw.Widget> _registrationWidgets({
    required double tileW,
    required double tileH,
    required bool left,
    required bool right,
    required bool top,
    required bool bottom,
  }) {
    final widgets = <pw.Widget>[];
    const inset = _tileOverlapMm / 2;

    void addCross(double x, double y) {
      final h = _lineWidget(x - 5, y, x + 5, y, 0.55, tileW, tileH);
      final v = _lineWidget(x, y - 5, x, y + 5, 0.55, tileW, tileH);
      if (h != null) widgets.add(h);
      if (v != null) widgets.add(v);
    }

    void addLabel(String text, double x, double y, double width) {
      widgets.add(
        pw.Positioned(
          left: mm(x),
          top: mm(y),
          child: pw.Container(
            width: mm(width),
            child: pw.Text(
              text,
              style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),
      );
    }

    final crossTop = math.min(35.0, tileH * 0.28);
    final crossBottom = tileH - crossTop;
    if (left) {
      final l = _lineWidget(inset, 0, inset, tileH, 0.25, tileW, tileH);
      if (l != null) widgets.add(l);
      addCross(inset, crossTop);
      addCross(inset, crossBottom);
      addLabel('KLEBEFLAECHE', inset + 2, 8, 35);
    }
    if (right) {
      final l = _lineWidget(tileW - inset, 0, tileW - inset, tileH, 0.70, tileW, tileH);
      if (l != null) widgets.add(l);
      addCross(tileW - inset, crossTop);
      addCross(tileW - inset, crossBottom);
      addLabel('SCHNEIDELINIE', tileW - 43, 8, 38);
    }
    if (top) {
      final l = _lineWidget(0, inset, tileW, inset, 0.25, tileW, tileH);
      if (l != null) widgets.add(l);
      addCross(math.min(45.0, tileW * 0.25), inset);
      addCross(tileW - math.min(45.0, tileW * 0.25), inset);
      addLabel('KLEBEFLAECHE', 8, inset + 2, 35);
    }
    if (bottom) {
      final l = _lineWidget(0, tileH - inset, tileW, tileH - inset, 0.70, tileW, tileH);
      if (l != null) widgets.add(l);
      addCross(math.min(45.0, tileW * 0.25), tileH - inset);
      addCross(tileW - math.min(45.0, tileW * 0.25), tileH - inset);
      addLabel('SCHNEIDELINIE', 8, tileH - inset - 8, 38);
    }
    return widgets;
  }

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
      for (final guide in piece.guideLines) ...[guide.start, guide.end],
      if (piece.grainline != null) ...[piece.grainline!.start, piece.grainline!.end],
      for (final label in piece.labels) label.position,
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
      a.minX < b.maxX && a.maxX > b.minX && a.minY < b.maxY && a.maxY > b.minY;
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

class _LocalPoint {
  final double x;
  final double y;
  const _LocalPoint(this.x, this.y);
}

class _ClippedLine {
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  const _ClippedLine(this.x1, this.y1, this.x2, this.y2);
}
