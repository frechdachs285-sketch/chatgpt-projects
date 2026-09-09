import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'pattern_models.dart';
import 'trouser_fly.dart';
import 'trouser_pattern_calculator.dart';
import 'trouser_pattern_piece_builder.dart';
import 'trouser_pdf_export.dart';
import 'trouser_preview.dart';
import 'trouser_seam_allowance.dart';
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
  final _normalSeamController = TextEditingController(text: '1.5');
  final _waistSeamController = TextEditingController(text: '1.0');
  final _hemSeamController = TextEditingController(text: '3.0');
  bool _seamAllowanceEnabled = true;
  int _selectedSizeCode = 14, _appliedSizeCode = 14;
  TrouserReferenceDraft? _draft;
  PatternPiece? _leftFront, _rightFront, _back, _waistband;
  TrouserFlyGeometry? _fly;
  TrouserMeasurements? _appliedMeasurements;
  TrouserSeamAllowanceSettings? _appliedSeamAllowance;
  String? _message;

  @override void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _calculate(); }); }
  @override void dispose() { _waistController.dispose(); _hipController.dispose(); _hipDepthController.dispose(); _bodyRiseController.dispose(); _waistToFloorController.dispose(); _bottomWidthController.dispose(); _normalSeamController.dispose(); _waistSeamController.dispose(); _hemSeamController.dispose(); super.dispose(); }
  double? _read(TextEditingController c) { final v = double.tryParse(c.text.trim().replaceAll(',', '.')); return v == null || !v.isFinite || v <= 0 ? null : v; }
  double? _readNonNegative(TextEditingController c) { final v = double.tryParse(c.text.trim().replaceAll(',', '.')); return v == null || !v.isFinite || v < 0 ? null : v; }

  TrouserMeasurements? get _measurements { final values = [_read(_waistController), _read(_hipController), _read(_hipDepthController), _read(_bodyRiseController), _read(_waistToFloorController), _read(_bottomWidthController)]; if (values.any((v) => v == null)) return null; return TrouserMeasurements(waist: values[0]!, hip: values[1]!, hipDepth: values[2]!, bodyRise: values[3]!, waistToFloor: values[4]!, trouserBottomWidth: values[5]!); }
  TrouserSeamAllowanceSettings? get _seamAllowance { final normal = _readNonNegative(_normalSeamController), waist = _readNonNegative(_waistSeamController), hem = _readNonNegative(_hemSeamController); if (normal == null || waist == null || hem == null) return null; final s = TrouserSeamAllowanceSettings(enabled: _seamAllowanceEnabled, normalCm: normal, waistCm: waist, hemCm: hem); return s.isValid ? s : null; }

  void _calculate() {
    FocusScope.of(context).unfocus(); final measurements = _measurements, seamAllowance = _seamAllowance;
    if (measurements == null) { setState(() => _message = 'Bitte alle sechs Maße als positive Zahl eingeben.'); return; }
    if (seamAllowance == null) { setState(() => _message = 'Bitte gültige Nahtzugaben ab 0 cm eingeben.'); return; }
    try {
      final draft = TrouserPatternCalculator.calculateReferencePoints(measurements, sizeCode: _selectedSizeCode);
      const pieceBuilder = TrouserPatternPieceBuilder(), waistbandBuilder = TrouserWaistbandBuilder(), flyBuilder = TrouserFlyBuilder();
      final leftFront = pieceBuilder.leftFront(draft, seamAllowance: seamAllowance, sizeCode: _selectedSizeCode);
      final rightFront = pieceBuilder.rightFront(draft, seamAllowance: seamAllowance, sizeCode: _selectedSizeCode);
      final back = pieceBuilder.back(draft, seamAllowance: seamAllowance, sizeCode: _selectedSizeCode);
      final waistband = waistbandBuilder.build(draft: draft, measurements: measurements);
      final fly = flyBuilder.build(draft);
      setState(() { _draft = draft; _leftFront = leftFront; _rightFront = rightFront; _back = back; _waistband = waistband; _fly = fly; _appliedMeasurements = measurements; _appliedSeamAllowance = seamAllowance; _appliedSizeCode = _selectedSizeCode; _message = null; });
    } on ArgumentError catch (e) { setState(() => _message = e.message?.toString() ?? 'Maße bitte prüfen.'); } on StateError catch (e) { setState(() => _message = e.message); }
  }

  Future<void> _openPatternPdf() async {
    final m = _appliedMeasurements; if (m == null) return;
    try {
      final bytes = await TrouserPdfExporter().buildPatternPdf(measurements: m, seamAllowance: _appliedSeamAllowance, sizeCode: _appliedSizeCode);
      await Printing.layoutPdf(name: 'Hose_v1_Schnittmuster_1zu1.pdf', onLayout: (_) async => bytes);
    } catch (_) { if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hose-PDF konnte nicht erstellt werden. Bitte Maße prüfen.'))); }
  }

  Widget _field(String label, TextEditingController c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true), textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: label, suffixText: 'cm', border: const OutlineInputBorder(), isDense: true)));
  Widget _seamField(String label, TextEditingController c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: c, enabled: _seamAllowanceEnabled, keyboardType: const TextInputType.numberWithOptions(decimal: true), textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: label, suffixText: 'cm', border: const OutlineInputBorder(), isDense: true)));

  @override Widget build(BuildContext context) {
    final draft = _draft, leftFront = _leftFront, rightFront = _rightFront, back = _back, waistband = _waistband, fly = _fly;
    return Scaffold(appBar: AppBar(title: const Text('Hose v1')), body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
      Text('Körper- und Konstruktionsmaße', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 12),
      DropdownButtonFormField<int>(initialValue: _selectedSizeCode, decoration: const InputDecoration(labelText: 'Aldrich-Konstruktionsgröße', border: OutlineInputBorder(), isDense: true, helperText: 'Wird ausdrücklich gewählt und nicht aus Körpermaßen geschätzt.'), items: [for (final size in TrouserSizeRules.supportedSizeCodes) DropdownMenuItem(value: size, child: Text('Größe $size'))], onChanged: (value) { if (value != null) setState(() => _selectedSizeCode = value); }),
      const SizedBox(height: 12), _field('Taillenumfang', _waistController), _field('Hüftumfang', _hipController), _field('Hüfttiefe', _hipDepthController), _field('Sitzhöhe', _bodyRiseController), _field('Taille bis Boden', _waistToFloorController), _field('Fertige Saumweite je Hosenbein', _bottomWidthController),
      const SizedBox(height: 8), Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Nahtzugabe'), value: _seamAllowanceEnabled, onChanged: (v) { setState(() => _seamAllowanceEnabled = v); _calculate(); }), _seamField('Seitennähte, Innenbein und Schritt', _normalSeamController), _seamField('Taille', _waistSeamController), _seamField('Saum', _hemSeamController)]))),
      const SizedBox(height: 8), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _calculate, icon: const Icon(Icons.calculate_outlined), label: const Text('Hose berechnen'))),
      if (_message != null) ...[const SizedBox(height: 12), Text(_message!, style: TextStyle(color: Theme.of(context).colorScheme.error))],
      if (draft != null && leftFront != null && rightFront != null && back != null && waistband != null && fly != null) ...[const SizedBox(height: 16), Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Berechnung erfolgreich'), const SizedBox(height: 6), Text('Konstruktionsgröße: $_appliedSizeCode'), Text('Referenzpunkte: ${draft.points.length}'), Text('Vorderhose links: ${leftFront.outline.segments.length} Kontursegmente, ${leftFront.darts.length} Abnäher'), Text('Vorderhose rechts: ${rightFront.outline.segments.length} Kontursegmente, ${rightFront.darts.length} Abnäher'), Text('Hinterhose: ${back.outline.segments.length} Kontursegmente, ${back.darts.length} Abnäher'), Text('Bund: ${waistband.outline.segments.length} Kontursegmente, ${waistband.guideLines.length} Markierungs-/Bruchlinien'), Text('Vorderer Schlitz rechts: P10–P6, Breite ${fly.widthCm.toStringAsFixed(1)} cm'), Text(_appliedSeamAllowance?.enabled == true ? 'Nahtzugabe: an' : 'Nahtzugabe: aus')]))), const SizedBox(height: 16), Text('Vorschau', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), TrouserPreview(leftFront: leftFront, rightFront: rightFront, back: back, waistband: waistband, fly: fly), const SizedBox(height: 16), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _openPatternPdf, icon: const Icon(Icons.picture_as_pdf_outlined), label: const Text('PDF 1:1 öffnen')))],
    ])));
  }
}
