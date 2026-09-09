import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';
import 'package:schnittmuster_app/trouser_shaped_waistband_builder.dart';

void main() {
  const size14 = TrouserMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    bodyRise: 28.7,
    waistToFloor: 105.0,
    trouserBottomWidth: 22.0,
  );

  test('size 14 shaped waistband keeps requested 4 cm normal depth', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(
      size14,
      sizeCode: 14,
    );

    const depthCm = 4.0;
    const builder = TrouserShapedWaistbandBuilder();
    final result = builder.build(
      draft: draft,
      waistbandDepthCm: depthCm,
    );

    expect(result.waistbandDepthCm, closeTo(depthCm, 1e-12));

    // One front dart creates two closed waist segments.
    expect(result.front.upperSegments.length, 2);
    expect(result.front.lowerSegments.length, 2);

    // Two back darts create three closed waist segments.
    expect(result.back.upperSegments.length, 3);
    expect(result.back.lowerSegments.length, 3);

    void verifyPiece(ShapedWaistbandPieceGeometry piece) {
      for (var i = 0; i < piece.upperSegments.length; i++) {
        final upper = piece.upperSegments[i];
        final lower = piece.lowerSegments[i];

        expect(lower.length, greaterThanOrEqualTo(2));

        // Adaptive offset includes the exact offset endpoints. Therefore the
        // distance from each upper endpoint to its matching lower endpoint must
        // equal the freely selected digital waistband depth exactly within
        // floating-point tolerance.
        expect(
          upper.start.distanceTo(lower.first),
          closeTo(depthCm, 1e-9),
          reason: 'segment $i start depth',
        );
        expect(
          upper.end.distanceTo(lower.last),
          closeTo(depthCm, 1e-9),
          reason: 'segment $i end depth',
        );
      }
    }

    verifyPiece(result.front);
    verifyPiece(result.back);
  });

  test('shaped waistband rejects non-positive depth', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(
      size14,
      sizeCode: 14,
    );

    const builder = TrouserShapedWaistbandBuilder();

    expect(
      () => builder.build(draft: draft, waistbandDepthCm: 0.0),
      throwsArgumentError,
    );
    expect(
      () => builder.build(draft: draft, waistbandDepthCm: -1.0),
      throwsArgumentError,
    );
  });
}
