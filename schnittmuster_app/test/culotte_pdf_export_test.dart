import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/culotte_base_geometry.dart';
import 'package:schnittmuster_app/culotte_measurements.dart';
import 'package:schnittmuster_app/culotte_pattern_piece_builder.dart';
import 'package:schnittmuster_app/culotte_pdf_export.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';

void main() {
  const skirtMeasurements = Measurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    skirtLength: 60.0,
  );
  const culotteMeasurements = CulotteMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    finishedLength: 60.0,
    bodyRise: 28.7,
  );

  int pdfPageCount(List<int> bytes) {
    final source = latin1.decode(bytes, allowInvalid: true);
    return RegExp(r'/Type\s*/Page\b').allMatches(source).length;
  }

  test('Culotte v1 exporter creates a valid multi-page PDF from confirmed pieces', () async {
    final skirt = SkirtPatternCalculator().calculate(
      skirtMeasurements,
      const ConstructionValues(),
      seamAllowance: const SeamAllowanceSettings(enabled: false),
    );
    expect(skirt.isValid, isTrue);

    final geometry = const CulotteBaseGeometryBuilder().build(
      back: skirt.back!,
      front: skirt.front!,
      measurements: culotteMeasurements,
    );

    const builder = CulottePatternPieceBuilder();
    final back = builder.buildBack(
      skirtBack: skirt.back!,
      geometry: geometry,
    );
    final front = builder.buildFront(
      skirtFront: skirt.front!,
      geometry: geometry,
    );

    expect(front.id, 'culotte_front');
    expect(back.id, 'culotte_back');
    expect(front.outline.segments, isNotEmpty);
    expect(back.outline.segments, isNotEmpty);

    final bytes = await CulottePdfExporter().buildPatternPdf(
      measurements: culotteMeasurements,
      front: front,
      back: back,
    );

    expect(bytes, isNotEmpty);
    expect(ascii.decode(bytes.take(4).toList()), '%PDF');
    expect(pdfPageCount(bytes), greaterThan(2));
  });
}
