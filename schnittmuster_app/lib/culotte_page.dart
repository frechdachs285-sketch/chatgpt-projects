import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'culotte_base_geometry.dart';
import 'culotte_measurements.dart';
import 'culotte_pattern_piece_builder.dart';
import 'culotte_pdf_export.dart';
import 'culotte_preview.dart';
import 'culotte_seam_allowance.dart';
import 'pattern_models.dart';
import 'skirt_pattern_calculator.dart';

class CulottePage extends StatefulWidget {
  const CulottePage({super.key});

  @override
  State<CulottePage> createState() => _CulottePageState();
}

class _CulottePageState extends State<CulottePage> {
  final _waistController = TextEditingController(text: '76');
  final _hipController = TextEditingController(text: '100');
  final _hipDepthController = TextEditingController(text: '20.9');
  final _finishedLengthController = TextEditingController(text: '60');
  final _bodyRiseController = TextEditingController(text: '28.7');

  // Deliberately blank: Culotte-v1 seam-allowance values are app-side user
  // choices and are not taken from Aldrich unless separately confirmed.
  final _normalAllowanceController = TextEditingController();
  final _waistAllowanceController = TextEditingController();
  final _hemAllowanceController = TextEditingController();

  bool _seamAllowanceEnabled = false;
  PatternPiece? _front;
  PatternPiece? _back;
  CulotteMeasurements? _appliedMeasurements;
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
    _finishedLengthController.dispose();
    _bodyRiseController.dispose();
    _normalAllowanceController.dispose();
    _waistAllowanceController.dispose();
    _hemAllowanceController.dispose();
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

  CulotteMeasurements? get _measurements {
    final waist = _read(_waistController);
    final hip = _read(_hipController);
    final hipDepth = _read(_hipDepthController);
    final finishedLength = _read(_finishedLengthController);
    final bodyRise = _read(_bodyRiseController);
    if (waist == null ||
        hip == null ||
        hipDepth == null ||
        finishedLength == null ||
        bodyRise == null) {
      return null;
    }
    return CulotteMeasurements(
      waist: waist,
      hip: hip,
      hipDepth: hipDepth,
      finishedLength: finishedLength,
      bodyRise: bodyRise,
    );
  }

  CulotteSeamAllowanceSettings? get _seamAllowance {
    if (!_seamAllowanceEnabled) return null;
    final normal = _readNonNegative(_normalAllowanceController);
    final waist = _readNonNegative(_waistAllowanceController);
    final hem = _readNonNegative(_hemAllowanceController);
    if (normal == null || waist == null || hem == null) return null;
    return CulotteSeamAllowanceSettings(
      enabled: true,
      normalCm: normal,
      waistCm: waist,
      hemCm: hem,
    );
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    final m = _measurements;
    if (m == null) {
      setState(() {
        _message = 'Bitte alle fünf Maße als positive Zahlen in cm eingeben.';
      });
      return;
    }

    final seamAllowance = _seamAllowance;
    if (_seamAllowanceEnabled && seamAllowance == null) {
      setState(() {
        _message = 'Bitte alle drei Nahtzugaben als Zahlen ab 0 cm eingeben.';
      });
      return;
    }

    try {
      // Culotte v1 uses the confirmed Aldrich skirt basis without modifying
      // that basis with seam allowance. The cutting outline is generated only
      // afterwards as a separate app-side contour.
      final skirt = SkirtPatternCalculator().calculate(
        Measurements(
          waist: m.waist,
          hip: m.hip,
          hipDepth: m.hipDepth,
          skirtLength: m.finishedLength,
        ),
        const ConstructionValues(),
        seamAllowance: const SeamAllowanceSettings(enabled: false),
      );
      if (!skirt.isValid) {
        setState(() => _message = skirt.errors.join('\n'));
        return;
      }

      final geometry = const CulotteBaseGeometryBuilder().build(
        back: skirt.back!,
        front: skirt.front!,
        measurements: m,
      );
      const builder = CulottePatternPieceBuilder();
      final back = builder.buildBack(
        skirtBack: skirt.back!,
        geometry: geometry,
        seamAllowance: seamAllowance,
      );
      final front = builder.buildFront(
        skirtFront: skirt.front!,
        geometry: geometry,
        seamAllowance: seamAllowance,
      );

      setState(() {
        _front = front;
        _back = back;
        _appliedMeasurements = m;
        _message = null;
      });
    } on ArgumentError catch (error) {
      setState(() {
        _message = error.message?.toString() ?? 'Bitte die Culotte-Maße prüfen.';
      });
    } on StateError catch (_) {
      setState(() {
        _message = 'Die Culotte-Geometrie konnte nicht eindeutig berechnet werden. Bitte die Maße oder Nahtzugaben prüfen.';
      });
    }
  }

  Future<void> _openPatternPdf() async {
    final front = _front;
    final back = _back;
    final measurements = _appliedMeasurements;
    if (front == null || back == null || measurements == null) return;

    try {
      final bytes = await CulottePdfExporter().buildPatternPdf(
        measurements: measurements,
        front: front,
        back: back,
      );
      await Printing.layoutPdf(
        name: 'Culotte_v1_Schnittmuster_1zu1.pdf',
        onLayout: (_) async => bytes,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Culotte-PDF konnte nicht erstellt werden. Bitte Maße prüfen.'),
        ),
      );
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: controller,
          enabled: enabled,
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
    final front = _front;
    final back = _back;

    return Scaffold(
      appBar: AppBar(title: const Text('Culotte v1')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Körper- und Längenmaße',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _field('Taillenumfang', _waistController),
            _field('Hüftumfang', _hipController),
            _field('Hüfttiefe', _hipDepthController),
            _field('Fertige Culotte-Länge ab Taille', _finishedLengthController),
            _field('Sitzhöhe', _bodyRiseController),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Nahtzugabe einschalten'),
              subtitle: const Text('Zuschnittkontur getrennt von der Nahtlinie'),
              value: _seamAllowanceEnabled,
              onChanged: (value) {
                setState(() => _seamAllowanceEnabled = value);
              },
            ),
            if (_seamAllowanceEnabled) ...[
              const SizedBox(height: 6),
              _field('Normale Nahtzugabe', _normalAllowanceController),
              _field('Taillenzugabe', _waistAllowanceController),
              _field('Saumzugabe', _hemAllowanceController),
            ],
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Culotte berechnen'),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(
                _message!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (front != null && back != null) ...[
              const SizedBox(height: 18),
              Text('Vorschau', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              CulottePreview(front: front, back: back),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openPatternPdf,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Culotte-PDF 1:1 öffnen'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _seamAllowanceEnabled
                    ? 'Culotte v1: Nahtlinie plus separate Zuschnittkontur, Fadenlauf und Beschriftungen; noch ohne Passzeichen.'
                    : 'Culotte v1: Nahtlinie mit bestätigten Abnähern, Fadenlauf und Beschriftungen; Nahtzugabe ausgeschaltet. Noch ohne Passzeichen.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
