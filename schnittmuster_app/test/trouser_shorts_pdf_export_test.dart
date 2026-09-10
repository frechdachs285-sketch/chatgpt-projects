import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';
import 'package:schnittmuster_app/trouser_pdf_export.dart';
import 'package:schnittmuster_app/trouser_seam_allowance.dart';

void main() {
  const measurements = TrouserMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    bodyRise: 28.7,
    waistToFloor: 105.0,
    trouserBottomWidth: 22.0,
  );

  const seamAllowance = TrouserSeamAllowanceSettings(
    enabled: true,
    normalCm: 1.5,
    waistCm: 1.0,
    hemCm: 3.0,
  );

  test('PDF export switches between long trouser and true tailored shorts pieces', () async {
    final exporter = TrouserPdfExporter();

    final longBytes = await exporter.buildPatternPdf(
      measurements: measurements,
      seamAllowance: seamAllowance,
      sizeCode: 14,
    );
    final shortsBytes = await exporter.buildPatternPdf(
      measurements: measurements,
      seamAllowance: seamAllowance,
      sizeCode: 14,
      shortsLengthFromWaistCm: 40.0,
    );

    expect(longBytes, isNotEmpty);
    expect(shortsBytes, isNotEmpty);
    expect(shortsBytes, isNot(equals(longBytes)));

    final longText = latin1.decode(longBytes, allowInvalid: true);
    final shortsText = latin1.decode(shortsBytes, allowInvalid: true);

    expect(longText.contains('Tailored Shorts'), isFalse);
    expect(shortsText.contains('Tailored Shorts'), isTrue);
  });
}
