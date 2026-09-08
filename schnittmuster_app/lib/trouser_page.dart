import 'package:flutter/material.dart';

import 'pattern_models.dart';
import 'trouser_pattern_calculator.dart';
import 'trouser_pattern_piece_builder.dart';
import 'trouser_preview.dart';

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

  TrouserReferenceDraft? _draft;
  PatternPiece? _front;
  PatternPiece? _back;
  String? _message;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _waistController.dispose();
    _hipController.dispose();
    _hipDepthController.dispose();
    _bodyRiseController.dispose();
    _waistToFloorController.dispose();
    _bottomWidthController.dispose();
    super.dispose();
  }

  double? _read(TextEditingController controller) {
    final value = double.tryParse(controller.text.trim().replaceAll(',', '.'));
    if (value == null || !value.isFinite || value <= 0.0) return null;
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

  void _calculate() {
    FocusScope.of(context).unfocus();
    final measurements = _measurements;
    if (measurements == null) {
      setState(() => _message = 'Bitte alle sechs Maße als positive Zahl eingeben.');
      return;
    }

    try {
      final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
      const pieceBuilder = TrouserPatternPieceBuilder();
      final front = pieceBuilder.front(draft);
      final back = pieceBuilder.back(draft);
      setState(() {
        _draft = draft;
        _front = front;
        _back = back;
        _message = null;
      });
    } on ArgumentError catch (error) {
      setState(() => _message = error.message?.toString() ?? 'Maße bitte prüfen.');
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
            const SizedBox(height: 4),
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
            ],
          ],
        ),
      ),
    );
  }
}
