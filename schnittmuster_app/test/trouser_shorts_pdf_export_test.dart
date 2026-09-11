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

  int pdfPageCount(List<int> bytes) {
    final source = latin1.decode(bytes, allowInvalid: true);
    return RegExp(r'/Type\s*/Page\b').allMatches(source).length;
  }

  test('PDF export switches between long trouser and tailored shorts output', () async {
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

    final longPageCount = pdfPageCount(longBytes);
    final shortsPageCount = pdfPageCount(shortsBytes);

    // Page dictionaries are not inside the compressed page-content streams,
    // so counting /Type /Page is stable here; unlike searching for visible
    // PDF text, this does not depend on stream compression.
    expect(longPageCount, greaterThan(1));
    expect(shortsPageCount, greaterThan(1));
    expect(shortsPageCount, lessThan(longPageCount));

    // Keep the exact current counts visible in CI while we diagnose whether
    // Hose v1 creates avoidable edge tiles before changing production code.
    // ignore: avoid_print
    print('Trouser PDF pages: long=$longPageCount, shorts40=$shortsPageCount');
  });
}
