import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';
import 'package:schnittmuster_app/trouser_pattern_piece_builder.dart';
import 'package:schnittmuster_app/trouser_seam_allowance.dart';
import 'package:schnittmuster_app/trouser_waistband_builder.dart';

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

  test('Hose v1 confirmed reference build remains complete', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    const pieceBuilder = TrouserPatternPieceBuilder();
    const waistbandBuilder = TrouserWaistbandBuilder();

    final front = pieceBuilder.front(draft, seamAllowance: seamAllowance);
    final back = pieceBuilder.back(draft, seamAllowance: seamAllowance);
    final waistband = waistbandBuilder.build(
      draft: draft,
      measurements: measurements,
    );

    expect(draft.points, hasLength(32));

    expect(front.name, 'Vorderhose');
    expect(front.outline.segments, hasLength(10));
    expect(front.darts, hasLength(1));
    expect(front.cuttingOutline, isNotNull);
    expect(front.grainline, isNotNull);

    expect(back.name, 'Hinterhose');
    expect(back.outline.segments, hasLength(11));
    expect(back.darts, hasLength(2));
    expect(back.cuttingOutline, isNotNull);
    expect(back.grainline, isNotNull);

    expect(waistband.name, 'Gerader Bund');
    expect(waistband.outline.segments, hasLength(4));
    expect(waistband.guideLines, hasLength(5));
    expect(waistband.points['CF_RIGHT']!.x, closeTo(76.0, 1e-9));
    expect(waistband.points['EXTENSION_END']!.x, closeTo(80.0, 1e-9));
  });
}
