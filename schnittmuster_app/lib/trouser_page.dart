import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'pattern_models.dart';
import 'trouser_fly.dart';
import 'trouser_pattern_calculator.dart';
import 'trouser_pattern_piece_builder.dart';
import 'trouser_pdf_export.dart';
import 'trouser_preview.dart';
import 'trouser_seam_allowance.dart';
import 'trouser_shaped_waistband_builder.dart';
import 'trouser_shaped_waistband_facing_builder.dart';
import 'trouser_shaped_waistband_facing_preview.dart';
import 'trouser_shaped_waistband_preview.dart';
import 'trouser_shorts_geometry.dart';
import 'trouser_size_rules.dart';
import 'trouser_waistband_builder.dart';

class TrouserPage extends StatefulWidget {
  const TrouserPage({super.key});
  @override State<TrouserPage> createState() => _TrouserPageState();
}

class _TrouserPageState extends State<TrouserPage> {
  final _waistController = TextEditingController(text: '76');
  final _hipController = TextEditingController(text: '100');
  final _hipDepthController = TextEditingController(text: '20.9');
  final _bodyRiseController = TextEditingController(text: '28.7');
  final _waistToFloorController = TextEditingController(text: '105');
  final _bottomWidthController = TextEditingController(text: '22');
  final _alternativeLegShapingController = TextEditingController(text: '0');
  final _shortsLengthController = TextEditingController();
  final _shapedWaistbandDepthController = TextEditingController();
  final _facingDepthController = TextEditingController();
  final _normalSeamController = TextEditingController(text: '1.5');
  final _waistSeamController = TextEditingController(text: '1.0');
  final _hemSeamController = TextEditingController(text: '3.0');
  bool _seamAllowanceEnabled = true;
  int _selectedSizeCode = 14, _appliedSizeCode = 14;
  TrouserReferenceDraft? _draft;
  PatternPiece? _leftFront, _rightFront, _back, _waistband;
  TrouserShapedWaistbandGeometry? _shapedWaistband;
  TrouserShapedWaistbandFacingGeometry? _shapedWaistbandFacing;
  TrouserShortsGeometry? _shortsGeometry;
  TrouserFlyGeometry? _fly;
  TrouserMeasurements? _appliedMeasurements;
  TrouserSeamAllowanceSettings? _appliedSeamAllowance;
  double? _appliedShortsLength;
  double? _appliedShapedWaistbandDepth;
  double? _appliedFacingDepth;
  String? _message;

  @override void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _calculate(); }); }
  @override void dispose() { _waistController.dispose(); _hipController.dispose(); _hipDepthController.dispose(); _bodyRiseController.dispose(); _waistToFloorController.dispose(); _bottomWidthController.dispose(); _alternativeLegShapingController.dispose(); _shortsLengthController.dispose(); _shapedWaistbandDepthController.dispose(); _facingDepthController.dispose(); _normalSeamController.dispose(); _waistSeamController.dispose(); _hemSeamController.dispose(); super.dispose(); }
  double? _read(TextEditingController c) { final v = double.tryParse(c.text.trim().replaceAll(',', '.')); return v == null || !v.isFinite || v <= 0 ? null : v; }
  double? _readFinite(TextEditingController c) { final v = double.tryParse(c.text.trim().replaceAll(',', '.')); return v == null || !v.isFinite ? null : v; }
  double? _readNonNegative(TextEditingController c) { final v = double.tryParse(c.text.trim().replaceAll(',', '.')); return v == null || !v.isFinite || v < 0 ? null : v; }

  TrouserMeasurements? get _measurements { final values = [_read(_waistController), _read(_hipController), _read(_hipDepthController), _read(_bodyRiseController), _read(_waistToFloorController), _read(_bottomWidthController)]; final alternativeLegShapingCm = _readFinite(_alternativeLegShapingController); if (values.any((v) => v == null) || alternativeLegShapingCm == null) return null; return TrouserMeasurements(waist: values[0]!, hip: values[1]!, hipDepth: values[2]!, bodyRise: values[3]!, waistToFloor: values[4]!, trouserBottomWidth: values[5]!, alternativeLegShapingCm: alternativeLegShapingCm); }
  double? get _shortsLength { final text = _shortsLengthController.text.trim(); if (text.isEmpty) return null; return _read(_shortsLengthController); }
  double? get _shapedWaistbandDepth { final text = _shapedWaistbandDepthController.text.trim(); if (text.isEmpty) return null; return _read(_shapedWaistbandDepthController); }
  double? get _facingDepth { final text = _facingDepthController.text.trim(); if (text.isEmpty) return null; return _read(_facingDepthController); }
  TrouserSeamAllowanceSettings? get _seamAllowance { final normal = _readNonNegative(_normalSeamController), waist = _readNonNegative(_waistSeamController), hem = _readNonNegative(_hemSeamController); if (normal == null || waist == null || hem == null) return null; final s = TrouserSeamAllowanceSettings(enabled: _seamAllowanceEnabled, normalCm: normal, waistCm: waist, hemCm: hem); return s.isValid ? s : null; }

  void _calculate() {
    FocusScope.of(context).unfocus(); final measurements = _measurements, seamAllowance = _seamAllowance, shortsLength = _shortsLength, shapedWaistbandDepth = _shapedWaistbandDepth, facingDepth = _facingDepth;
    if (measurements == null) { setState(() => _message = 'Bitte Körpermaße als positive Zahlen und die alternative Beinform als gültige Zahl eingeben.'); return; }
    if (_shortsLengthController.text.trim().isNotEmpty && shortsLength == null) { setState(() => _message = 'Bitte die Shorts-Länge ab Taille als positive Zahl eingeben.'); return; }
    if (_shapedWaistbandDepthController.text.trim().isNotEmpty && shapedWaistbandDepth == null) { setState(() => _message = 'Bitte die Bundtiefe als positive Zahl eingeben.'); return; }
    if (_facingDepthController.text.trim().isNotEmpty && facingDepth == null) { setState(() => _message = 'Bitte die Belegtiefe als positive Zahl eingeben.'); return; }
    if (seamAllowance == null) { setState(() => _message = 'Bitte gültige Nahtzugaben ab 0 cm eingeben.'); return; }
    try {
      final draft = TrouserPatternCalculator.calculateReferencePoints(measurements, sizeCode: _selectedSizeCode);
      const pieceBuilder = TrouserPatternPieceBuilder(), waistbandBuilder = TrouserWaistbandBuilder(), shapedWaistbandBuilder = TrouserShapedWaistbandBuilder(), facingBuilder = TrouserShapedWaistbandFacingBuilder(), shortsBuilder = TrouserShortsGeometryBuilder(), flyBuilder = TrouserFlyBuilder();
      final leftFront = pieceBuilder.leftFront(draft, seamAllowance: seamAllowance, sizeCode: _selectedSizeCode);
      final rightFront = pieceBuilder.rightFront(draft, seamAllowance: seamAllowance, sizeCode: _selectedSizeCode);
      final back = pieceBuilder.back(draft, seamAllowance: seamAllowance, sizeCode: _selectedSizeCode);
      final waistband = waistbandBuilder.build(draft: draft, measurements: measurements, sizeCode: _selectedSizeCode, seamAllowanceEnabled: seamAllowance.enabled);
      final shortsGeometry = shortsLength == null ? null : shortsBuilder.build(draft: draft, shortsDepthY: shortsLength);
      final shapedWaistband = shapedWaistbandDepth == null ? null : shapedWaistbandBuilder.build(draft: draft, waistbandDepthCm: shapedWaistbandDepth);
      final shapedWaistbandFacing = facingDepth == null ? null : facingBuilder.build(draft: draft, facingDepthCm: facingDepth);
      final fly = flyBuilder.build(draft);
      setState(() { _draft = draft; _leftFront = leftFront; _rightFront = rightFront; _back = back; _waistband = waistband; _shortsGeometry = shortsGeometry; _shapedWaistband = shapedWaistband; _shapedWaistbandFacing = shapedWaistbandFacing; _fly = fly; _appliedMeasurements = measurements; _appliedSeamAllowance = seamAllowance; _appliedShortsLength = shortsLength; _appliedShapedWaistbandDepth = shapedWaistbandDepth; _appliedFacingDepth = facingDepth; _appliedSizeCode = _selectedSizeCode; _message = null; });
    } on ArgumentError catch (e) { setState(() => _message = e.message?.toString() ?? 'Maße bitte prüfen.'); } on StateError catch (_) { setState(() => _message = 'Diese Shorts-Länge schneidet die bestätigte Hosenkontur nicht eindeutig. Bitte eine andere Länge wählen.'); }
  }

  Future<void> _openPatternPdf() async {
    final m = _appliedMeasurements; if (m == null) return;
    try {
      final bytes = await TrouserPdfExporter().buildPatternPdf(measurements: m, seamAllowance: _appliedSeamAllowance, sizeCode: _appliedSizeCode, shapedWaistbandDepthCm: _appliedShapedWaistbandDepth, facingDepthCm: _appliedFacingDepth);
      await Printing.layoutPdf(name: 'Hose_v1_Schnittmuster_1zu1.pdf', onLayout: (_) async => bytes);
    } catch (_) { if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hose-PDF konnte nicht erstellt werden. Bitte Maße prüfen.'))); }
  }

  Widget _field(String label, TextEditingController c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true), textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: label, suffixText: 'cm', border: const OutlineInputBorder(), isDense: true)));
  Widget _seamField(String label, TextEditingController c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: c, enabled: _seamAllowanceEnabled, keyboardType: const TextInputType.numberWithOptions(decimal: true), textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: label, suffixText: 'cm', border: const OutlineInputBorder(), isDense: true)));

  @override Widget build(BuildContext context) {
    final draft = _draft, leftFront = _leftFront, rightFront = _rightFront, back = _back, waistband = _waistband, shapedWaistband = _shapedWaistband, shapedWaistbandFacing = _shapedWaistbandFacing, shortsGeometry = _shortsGeometry, fly = _fly;
    return Scaffold(appBar: AppBar(title: const Text('Hose v1')), body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
      Text('Körper- und Konstruktionsmaße', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 12),
      DropdownButtonFormField<int>(initialValue: _selectedSizeCode, decoration: const InputDecoration(labelText: 'Aldrich-Konstruktionsgröße', border: OutlineInputBorder(), isDense: true, helperText: 'Wird ausdrücklich gewählt und nicht aus Körpermaßen geschätzt.'), items: [for (final size in TrouserSizeRules.supportedSizeCodes) DropdownMenuItem(value: size, child: Text('Größe $size'))], onChanged: (value) { if (value != null) setState(() => _selectedSizeCode = value); }),
      const SizedBox(height: 12), _field('Taillenumfang', _waistController), _field('Hüftumfang', _hipController), _field('Hüfttiefe', _hipDepthController), _field('Sitzhöhe', _bodyRiseController), _field('Taille bis Boden', _waistToFloorController), _field('Fertige Saumweite je Hosenbein', _bottomWidthController),
      TextField(controller: _alternativeLegShapingController, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Alternative Beinform', suffixText: 'cm', border: OutlineInputBorder(), isDense: true, helperText: 'Hose-v1-Digitalregel: 0 = bestätigter Grundschnitt; positive und negative Werte sind zulässig.')),
      const SizedBox(height: 10),
      TextField(controller: _shortsLengthController, keyboardType: const TextInputType.numberWithOptions(decimal: true), textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Shorts-Länge ab Taille', suffixText: 'cm', border: OutlineInputBorder(), isDense: true, helperText: 'Optional. Eigene App-Regel: der Wert ist direkt die horizontale Shorts-Tiefe; leer lassen für die lange Hose.')),
      const SizedBox(height: 10),
      TextField(controller: _shapedWaistbandDepthController, keyboardType: const TextInputType.numberWithOptions(decimal: true), textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Bundtiefe geformter Bund', suffixText: 'cm', border: OutlineInputBorder(), isDense: true, helperText: 'Frei wählbare digitale Regel; leer lassen für den bestätigten geraden Bund.')),
      const SizedBox(height: 10),
      TextField(controller: _facingDepthController, keyboardType: const TextInputType.numberWithOptions(decimal: true), textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Belegtiefe geformter Bund', suffixText: 'cm', border: OutlineInputBorder(), isDense: true, helperText: 'Frei wählbare digitale Regel.')),
      const SizedBox(height: 8), Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Nahtzugabe'), value: _seamAllowanceEnabled, onChanged: (v) { setState(() => _seamAllowanceEnabled = v); _calculate(); }), _seamField('Seitennähte, Innenbein und Schritt', _normalSeamController), _seamField('Taille', _waistSeamController), _seamField('Saum', _hemSeamController)]))),
      const SizedBox(height: 8), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _calculate, icon: const Icon(Icons.calculate_outlined), label: const Text('Hose berechnen'))),
      if (_message != null) ...[const SizedBox(height: 12), Text(_message!, style: TextStyle(color: Theme.of(context).colorScheme.error))],
      if (draft != null && leftFront != null && rightFront != null && back != null && waistband != null && fly != null) ...[const SizedBox(height: 16), Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Berechnung erfolgreich'), const SizedBox(height: 6), Text('Konstruktionsgröße: $_appliedSizeCode'), Text('Referenzpunkte: ${draft.points.length}'), Text('Alternative Beinform: ${_appliedMeasurements!.alternativeLegShapingCm.toStringAsFixed(1)} cm'), if (shortsGeometry != null) Text('Tailored Shorts: ${_appliedShortsLength!.toStringAsFixed(1)} cm ab Taille, Geometrie berechnet'), Text('Vorderhose links: ${leftFront.outline.segments.length} Kontursegmente, ${leftFront.darts.length} Abnäher'), Text('Vorderhose rechts: ${rightFront.outline.segments.length} Kontursegmente, ${rightFront.darts.length} Abnäher'), Text('Hinterhose: ${back.outline.segments.length} Kontursegmente, ${back.darts.length} Abnäher'), Text('Bund: ${waistband.outline.segments.length} Kontursegmente, ${waistband.guideLines.length} Markierungs-/Bruchlinien'), if (shapedWaistband != null) Text('Geformter Bund: ${shapedWaistband.waistbandDepthCm.toStringAsFixed(1)} cm Tiefe, Geometrie berechnet'), if (shapedWaistbandFacing != null) Text('Beleg geformter Bund: ${shapedWaistbandFacing.facingDepthCm.toStringAsFixed(1)} cm Tiefe, Geometrie berechnet'), Text('Vorderer Schlitz rechts: P10–P6, Breite ${fly.widthCm.toStringAsFixed(1)} cm'), Text(_appliedSeamAllowance?.enabled == true ? 'Nahtzugabe: an' : 'Nahtzugabe: aus')]))), const SizedBox(height: 16), Text('Vorschau', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), TrouserPreview(leftFront: leftFront, rightFront: rightFront, back: back, waistband: waistband, fly: fly), if (shapedWaistband != null) ...[const SizedBox(height: 16), Text('Geformter Bund – Vorschau', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8), TrouserShapedWaistbandPreview(geometry: shapedWaistband, seamAllowanceEnabled: _appliedSeamAllowance?.enabled == true)], if (shapedWaistbandFacing != null) ...[const SizedBox(height: 16), Text('Beleg geformter Bund – Vorschau', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8), TrouserShapedWaistbandFacingPreview(geometry: shapedWaistbandFacing, seamAllowanceEnabled: _appliedSeamAllowance?.enabled == true)], const SizedBox(height: 16), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _openPatternPdf, icon: const Icon(Icons.picture_as_pdf_outlined), label: const Text('PDF 1:1 öffnen')))],
    ])));
  }
}
