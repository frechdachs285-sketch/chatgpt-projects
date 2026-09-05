import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'pattern_models.dart';
import 'pdf_export.dart';
import 'skirt_pattern_calculator.dart';

void main() => runApp(const SchnittmusterApp());

class SchnittmusterApp extends StatelessWidget {
  const SchnittmusterApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Schnittmuster App',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: const SkirtPage(),
      );
}

class SkirtPage extends StatefulWidget {
  const SkirtPage({super.key});
  @override
  State<SkirtPage> createState() => _SkirtPageState();
}

class _SkirtPageState extends State<SkirtPage> {
  bool _seamAllowanceEnabled = true;

  final _waistController = TextEditingController(text: '76');
  final _hipController = TextEditingController(text: '100');
  final _hipDepthController = TextEditingController(text: '21');
  final _skirtLengthController = TextEditingController(text: '60');

  final _seamWaistController = TextEditingController(text: '1.5');
  final _seamSideController = TextEditingController(text: '1.5');
  final _seamBackCenterController = TextEditingController(text: '1.5');
  final _seamHemController = TextEditingController(text: '3.0');

  Measurements _appliedMeasurements = const Measurements(
    waist: 76,
    hip: 100,
    hipDepth: 21,
    skirtLength: 60,
  );

  SeamAllowanceSettings _appliedSeamAllowance = const SeamAllowanceSettings(
    enabled: true,
    waist: 1.5,
    side: 1.5,
    backCenter: 1.5,
    frontCenter: 0.0,
    hem: 3.0,
  );

  PatternResult? _result;
  String? _inputMessage;
  bool _inputsDirty = false;
  bool _seamInputsDirty = false;

  @override
  void initState() {
    super.initState();
    _recalculate(_appliedMeasurements, _appliedSeamAllowance);
  }

  @override
  void dispose() {
    _waistController.dispose();
    _hipController.dispose();
    _hipDepthController.dispose();
    _skirtLengthController.dispose();
    _seamWaistController.dispose();
    _seamSideController.dispose();
    _seamBackCenterController.dispose();
    _seamHemController.dispose();
    super.dispose();
  }

  double? _readNumber(TextEditingController controller) {
    final parsed = double.tryParse(controller.text.trim().replaceAll(',', '.'));
    return parsed == null || parsed <= 0 ? null : parsed;
  }

  double? _readNonNegative(TextEditingController controller) {
    final parsed = double.tryParse(controller.text.trim().replaceAll(',', '.'));
    return parsed == null || parsed < 0 ? null : parsed;
  }

  Measurements? get _enteredMeasurements {
    final waist = _readNumber(_waistController);
    final hip = _readNumber(_hipController);
    final hipDepth = _readNumber(_hipDepthController);
    final skirtLength = _readNumber(_skirtLengthController);
    if (waist == null || hip == null || hipDepth == null || skirtLength == null) {
      return null;
    }
    return Measurements(
      waist: waist,
      hip: hip,
      hipDepth: hipDepth,
      skirtLength: skirtLength,
    );
  }

  SeamAllowanceSettings? get _enteredSeamAllowance {
    final waist = _readNonNegative(_seamWaistController);
    final side = _readNonNegative(_seamSideController);
    final backCenter = _readNonNegative(_seamBackCenterController);
    final hem = _readNonNegative(_seamHemController);
    if (waist == null || side == null || backCenter == null || hem == null) {
      return null;
    }
    if (waist > 5 || side > 5 || backCenter > 5 || hem > 10) {
      return null;
    }
    return SeamAllowanceSettings(
      enabled: _seamAllowanceEnabled,
      waist: waist,
      side: side,
      backCenter: backCenter,
      frontCenter: 0.0,
      hem: hem,
    );
  }

  void _recalculate(
    Measurements measurements,
    SeamAllowanceSettings seamAllowance,
  ) {
    final next = SkirtPatternCalculator().calculate(
      measurements,
      const ConstructionValues(),
      seamAllowance: seamAllowance,
    );
    setState(() {
      _result = next;
      if (next.isValid) {
        _appliedMeasurements = measurements;
        _appliedSeamAllowance = seamAllowance;
        _inputMessage = null;
        _inputsDirty = false;
        _seamInputsDirty = false;
      } else {
        _inputMessage = next.errors.join('\n');
      }
    });
  }

  void _applyMeasurements() {
    FocusScope.of(context).unfocus();
    final measurements = _enteredMeasurements;
    if (measurements == null) {
      setState(() => _inputMessage = 'Bitte alle vier Maße als positive Zahl eingeben.');
      return;
    }
    _recalculate(measurements, _appliedSeamAllowance);
  }

  void _applySeamAllowances() {
    FocusScope.of(context).unfocus();
    final seamAllowance = _enteredSeamAllowance;
    if (seamAllowance == null) {
      setState(() {
        _inputMessage = 'Bitte gültige Nahtzugaben eingeben: Taille/Seite/hintere Mitte 0–5 cm, Saum 0–10 cm.';
      });
      return;
    }
    _recalculate(_appliedMeasurements, seamAllowance);
  }

  Future<void> _openPatternPdf() async {
    final result = _result;
    if (result == null || !result.isValid) return;
    try {
      final bytes = await PatternPdfExporter().buildPatternPdf(
        measurements: _appliedMeasurements,
        seamAllowance: _appliedSeamAllowance,
      );
      await Printing.layoutPdf(
        name: 'Rock_Schnittmuster_1zu1.pdf',
        onLayout: (_) async => bytes,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF konnte für diese Maße nicht erstellt werden. Bitte Maße prüfen.'),
        ),
      );
    }
  }

  Widget _measurementField(String label, TextEditingController controller) => TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          suffixText: 'cm',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (_) {
          if (!_inputsDirty) setState(() => _inputsDirty = true);
        },
        onSubmitted: (_) => _applyMeasurements(),
      );

  Widget _seamField(String label, TextEditingController controller) => TextField(
        controller: controller,
        enabled: _seamAllowanceEnabled,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          suffixText: 'cm',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (_) {
          if (!_seamInputsDirty) setState(() => _seamInputsDirty = true);
        },
      );

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final result = _result;
    final previewHeight = math.max(430.0, MediaQuery.sizeOf(context).height * 0.48);

    return Scaffold(
      appBar: AppBar(title: const Text('Rock-Schnittmuster')),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 18),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.7,
                children: [
                  _measurementField('Taille', _waistController),
                  _measurementField('Hüfte', _hipController),
                  _measurementField('Hüfttiefe', _hipDepthController),
                  _measurementField('Rocklänge', _skirtLengthController),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _applyMeasurements,
                  icon: const Icon(Icons.check),
                  label: Text(_inputsDirty ? 'Maße anwenden' : 'Maße sind angewendet'),
                ),
              ),
            ),
            SwitchListTile(
              title: const Text('Nahtzugabe'),
              subtitle: Text(_seamAllowanceEnabled ? 'Ein' : 'Aus'),
              value: _seamAllowanceEnabled,
              onChanged: (value) {
                setState(() => _seamAllowanceEnabled = value);
                final next = SeamAllowanceSettings(
                  enabled: value,
                  waist: _appliedSeamAllowance.waist,
                  side: _appliedSeamAllowance.side,
                  backCenter: _appliedSeamAllowance.backCenter,
                  frontCenter: 0.0,
                  hem: _appliedSeamAllowance.hem,
                );
                _recalculate(_appliedMeasurements, next);
              },
            ),
            Card(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: ExpansionTile(
                leading: const Icon(Icons.straighten),
                title: const Text('Nahtzugaben einstellen'),
                subtitle: Text(
                  _seamAllowanceEnabled
                      ? 'Taille ${_appliedSeamAllowance.waist.toStringAsFixed(1)} · Seite ${_appliedSeamAllowance.side.toStringAsFixed(1)} · Saum ${_appliedSeamAllowance.hem.toStringAsFixed(1)} cm'
                      : 'Nahtzugaben sind ausgeschaltet',
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    child: Column(
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.5,
                          children: [
                            _seamField('Taille', _seamWaistController),
                            _seamField('Seitennaht', _seamSideController),
                            _seamField('Hintere Mitte', _seamBackCenterController),
                            _seamField('Saum', _seamHemController),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Vordere Mitte: 0 cm (Stoffbruch)'),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _seamAllowanceEnabled ? _applySeamAllowances : null,
                            icon: const Icon(Icons.check),
                            label: Text(
                              _seamInputsDirty
                                  ? 'Nahtzugaben anwenden'
                                  : 'Nahtzugaben sind angewendet',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: result != null && result.isValid ? _openPatternPdf : null,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Schnittmuster-PDF 1:1'),
                ),
              ),
            ),
            if (_inputMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  _inputMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 8),
            if (keyboardOpen)
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Text(
                  'Eingabe fertigstellen und anschließend anwenden. Du kannst die Seite dabei nach oben und unten scrollen.',
                  textAlign: TextAlign.center,
                ),
              )
            else if (result == null || !result.isValid)
              const SizedBox(
                height: 260,
                child: Center(child: Text('Bitte gültige Maße anwenden.')),
              )
            else
              SizedBox(
                height: previewHeight,
                child: PatternPreview(front: result.front!, back: result.back!),
              ),
          ],
        ),
      ),
    );
  }
}

class PatternPreview extends StatelessWidget {
  final PatternPiece front, back;
  const PatternPreview({super.key, required this.front, required this.back});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
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
      for (final segment in piece.outline.segments)
        if (segment is BezierSegment) ...[segment.control1, segment.control2],
      if (piece.cuttingOutline != null)
        for (final segment in piece.cuttingOutline!.segments) ...[
          segment.start,
          segment.end,
          if (segment is BezierSegment) ...[segment.control1, segment.control2],
        ],
      if (piece.grainline != null) ...[piece.grainline!.start, piece.grainline!.end],
      for (final notch in piece.notches) notch.position,
      for (final label in piece.labels) label.position,
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

  Offset _p(PatternPoint point, _Bounds bounds, Offset origin, double scale) => Offset(
        origin.dx + (point.x - bounds.minX) * scale,
        origin.dy + (point.y - bounds.minY) * scale,
      );

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 24.0, gap = 28.0;
    final bb = _bounds(back), fb = _bounds(front);
    final total = bb.width + fb.width;
    final tall = math.max(bb.height, fb.height);
    final aw = math.max(1.0, size.width - padding * 2 - gap);
    final ah = math.max(1.0, size.height - padding * 2);
    final scale = math.min(aw / total, ah / tall);
    final used = total * scale + gap;
    final startX = math.max(padding, (size.width - used) / 2);
    const startY = padding;
    final bo = Offset(startX, startY);
    final fo = Offset(startX + bb.width * scale + gap, startY);
    final cutting = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.2;
    final outline = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2;
    final grain = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2;
    final notch = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final dart = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0;
    _drawPiece(canvas, back, bb, bo, scale, cutting, outline, grain, notch, dart);
    _drawPiece(canvas, front, fb, fo, scale, cutting, outline, grain, notch, dart);
  }

  void _drawPath(Canvas canvas, PatternPath pp, _Bounds b, Offset o, double s, Paint paint) {
    if (pp.segments.isEmpty) return;
    final first = _p(pp.segments.first.start, b, o, s);
    final path = Path()..moveTo(first.dx, first.dy);
    for (final seg in pp.segments) {
      if (seg is BezierSegment) {
        final c1 = _p(seg.control1, b, o, s);
        final c2 = _p(seg.control2, b, o, s);
        final e = _p(seg.end, b, o, s);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, e.dx, e.dy);
      } else {
        final e = _p(seg.end, b, o, s);
        path.lineTo(e.dx, e.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawGrain(Canvas canvas, PatternPiece piece, _Bounds b, Offset o, double s, Paint paint) {
    final g = piece.grainline;
    if (g == null) return;
    final a = _p(g.start, b, o, s), z = _p(g.end, b, o, s);
    canvas.drawLine(a, z, paint);
    const l = 7.0, w = 4.0;
    void arrow(Offset tip, double d) {
      final by = tip.dy + d * l;
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(tip.dx - w, by)
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(tip.dx + w, by),
        paint,
      );
    }
    arrow(a, 1);
    arrow(z, -1);
  }

  void _drawNotches(Canvas canvas, PatternPiece piece, _Bounds b, Offset o, double s, Paint paint) {
    const depth = 7.0, half = 4.0;
    for (final n in piece.notches) {
      final tip = _p(n.position, b, o, s);
      final out = piece.id == 'skirt_back' ? 1.0 : -1.0;
      final bx = tip.dx + out * depth;
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(bx, tip.dy - half)
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(bx, tip.dy + half),
        paint,
      );
    }
  }

  void _drawLabels(Canvas canvas, PatternPiece piece, _Bounds b, Offset o, double s) {
    for (final label in piece.labels) {
      final pos = _p(label.position, b, o, s);
      final text = label.text.replaceAll('Rueckenteil', 'Rückenteil');
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  void _drawPiece(
    Canvas canvas,
    PatternPiece piece,
    _Bounds b,
    Offset o,
    double s,
    Paint cutting,
    Paint outline,
    Paint grain,
    Paint notch,
    Paint dart,
  ) {
    if (piece.outline.segments.isEmpty) return;
    if (piece.cuttingOutline != null) _drawPath(canvas, piece.cuttingOutline!, b, o, s, cutting);
    _drawPath(canvas, piece.outline, b, o, s, outline);
    for (final d in piece.darts) {
      canvas.drawLine(_p(d.leg1, b, o, s), _p(d.apex, b, o, s), dart);
      canvas.drawLine(_p(d.apex, b, o, s), _p(d.leg2, b, o, s), dart);
    }
    _drawGrain(canvas, piece, b, o, s, grain);
    _drawNotches(canvas, piece, b, o, s, notch);
    _drawLabels(canvas, piece, b, o, s);
  }

  @override
  bool shouldRepaint(covariant PatternPreviewPainter oldDelegate) => true;
}
