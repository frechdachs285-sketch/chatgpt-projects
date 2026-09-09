import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'pattern_models.dart';
import 'trouser_pattern_calculator.dart';
import 'trouser_pattern_piece_builder.dart';
import 'trouser_pdf_export.dart';
import 'trouser_preview.dart';
import 'trouser_seam_allowance.dart';

class TrouserPage extends StatefulWidget {
  const TrouserPage({super.key});

  @override
  State<TrouserPage> createState() => _TrouserPageState();
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

  TrouserReferenceDraft? _draft;
  PatternPiece? _front;
  PatternPiece? _back;
  TrouserMeasurements? _appliedMeasurements;
  TrouserSeamAllowanceSettings? _appliedSeamAllowance;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _calculate();
    });
  }

  @override
  void dispose() {
    _waistController.dispose();
    _hipController.dispose();
    _hipDepthController.dispose();
    _bodyRiseController.dispose();
    _waistToFloorController.dispose();
    _bottomWidthController.dispose();
    _normalSeamController.dispose();
    _waistSeamController.dispose();
    _hemSeamController.dispose();
    super.dispose();
  }

  double? _read(TextEditingController controller) {
    final value = double.tryParse(controller.text.trim().replaceAll(',', '.'));
    if (value == null || !value.isFinite || value <= 0.0) return null;
    return value;
  }

  double? _readNonNegative(TextEditingController controller) {
    final value = double.tryParse(controller.text.trim().replaceAll(',', '.'));
    if (value == null || !value.isFinite || value < 0.0) return null;
    return value;
  }

  TrouserMeasurements? get _measurements {
    final waist = _read(_waistController);
    final hip = _read(_hipController);
    final hipDepth = _read(_hipDepthController);
    final bodyRise = _read(_bodyRiseController);
    final waistToFloor = _read(_waistToFloorController);
    final bottomWidth = _read(_bottomWidthController);

    if (waist == null ||
        hip == null ||
        hipDepth == null ||
        bodyRise == null ||
        waistToFloor == null ||
        bottomWidth == null) {
      return null;
    }

    return TrouserMeasurements(
      waist: waist,
      hip: hip,
      hipDepth: hipDepth,
      bodyRise: bodyRise,
      waistToFloor: waistToFloor,
      trouserBottomWidth: bottomWidth,
    );
  }

  TrouserSeamAllowanceSettings? get _seamAllowance {
    final normal = _readNonNegative(_normalSeamController);
    final waist = _readNonNegative(_waistSeamController);
    final hem = _readNonNegative(_hemSeamController);
    if (normal == null || waist == null || hem == null) return null;

    final settings = TrouserSeamAllowanceSettings(
      enabled: _seamAllowanceEnabled,
      normalCm: normal,
      waistCm: waist,
      hemCm: hem,
    );
    return settings.isValid ? settings : null;
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    final measurements = _measurements;
    final seamAllowance = _seamAllowance;
    if (measurements == null) {
      setState(() => _message = 'Bitte alle sechs Maße als positive Zahl eingeben.');
      return;
    }
    if (seamAllowance == null) {
      setState(() => _message = 'Bitte gültige Nahtzugaben ab 0 cm eingeben.');
      return;
    }

    try {
      final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
      const pieceBuilder = TrouserPatternPieceBuilder();
      final front = pieceBuilder.front(draft, seamAllowance: seamAllowance);
      final back = pieceBuilder.back(draft, seamAllowance: seamAllowance);
      setState(() {
        _draft = draft;
        _front = front;
        _back = back;
        _appliedMeasurements = measurements;
        _appliedSeamAllowance = seamAllowance;
        _message = null;
      });
    } on ArgumentError catch (error) {
      setState(() => _message = error.message?.toString() ?? 'Maße bitte prüfen.');
    } on StateError catch (error) {
      setState(() => _message = error.message);
    }
  }

  Future<void> _openPatternPdf() async {
    final measurements = _appliedMeasurements;
    if (measurements == null) return;

    try {
      final bytes = await TrouserPdfExporter().buildPatternPdf(
        measurements: measurements,
        seamAllowance: _appliedSeamAllowance,
      );
      await Printing.layoutPdf(
        name: 'Hose_v1_Schnittmuster_1zu1.pdf',
        onLayout: (_) async => bytes,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hose-PDF konnte nicht erstellt werden. Bitte Maße prüfen.'),
        ),
      );
    }
  }

  Widget _field(String label, TextEditingController controller) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: label,
            suffixText: 'cm',
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      );

  Widget _seamField(String label, TextEditingController controller) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
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
        ),
      );

  @override
  Widget build(BuildContext context) {
    final draft = _draft;
    final front = _front;
    final back = _back;

    return Scaffold(
      appBar: AppBar(title: const Text('Hose v1')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Körper- und Konstruktionsmaße',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _field('Taillenumfang', _waistController),
            _field('Hüftumfang', _hipController),
            _field('Hüfttiefe', _hipDepthController),
            _field('Sitzhöhe', _bodyRiseController),
            _field('Taille bis Boden', _waistToFloorController),
            _field('Fertige Saumweite je Hosenbein', _bottomWidthController),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Nahtzugabe'),
                      value: _seamAllowanceEnabled,
                      onChanged: (value) {
                        setState(() => _seamAllowanceEnabled = value);
                        _calculate();
                      },
                    ),
                    _seamField(
                      'Seitennähte, Innenbein und Schritt',
                      _normalSeamController,
                    ),
                    _seamField('Taille', _waistSeamController),
                    _seamField('Saum', _hemSeamController),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Hose berechnen'),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(
                _message!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (draft != null && front != null && back != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Berechnung erfolgreich'),
                      const SizedBox(height: 6),
                      Text('Referenzpunkte: ${draft.points.length}'),
                      Text(
                        'Vorderhose: ${front.outline.segments.length} Kontursegmente, ${front.darts.length} Abnäher',
                      ),
                      Text(
                        'Hinterhose: ${back.outline.segments.length} Kontursegmente, ${back.darts.length} Abnäher',
                      ),
                      Text(
                        _appliedSeamAllowance?.enabled == true
                            ? 'Nahtzugabe: an'
                            : 'Nahtzugabe: aus',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Vorschau',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TrouserPreview(front: front, back: back),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _openPatternPdf,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('PDF 1:1 öffnen'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
