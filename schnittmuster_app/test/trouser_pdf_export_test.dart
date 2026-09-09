import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';
import 'package:schnittmuster_app/trouser_pdf_export.dart';

void main() {
  const measurements = TrouserMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    bodyRise: 28.7,
    waistToFloor: 105.0,
    trouserBottomWidth: 22.0,
  );

  test('Hose-v1 PDF contains the confirmed straight waistband pages', () async {
    final bytes = await TrouserPdfExporter().buildPatternPdf(
      measurements: measurements,
    );
    final pdfText = latin1.decode(bytes, allowInvalid: true);

    expect(bytes, isNotEmpty);
    expect(pdfText, contains('Hose v1 - Gerader Bund 1:1'));
    expect(pdfText, contains('Gerader Bund'));
  });
}
