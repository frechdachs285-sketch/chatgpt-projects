import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';
import 'package:schnittmuster_app/trouser_shaped_waistband_facing_builder.dart';

void main() {
  const size14 = TrouserMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    bodyRise: 28.7,
    waistToFloor: 105.0,
    trouserBottomWidth: 22.0,
  );

  test('size 14 shaped waistband facing keeps requested 4 cm depth', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(
      size14,
      sizeCode: 14,
    );

    const depthCm = 4.0;
    const builder = TrouserShapedWaistbandFacingBuilder();
    final result = builder.build(
      draft: draft,
      facingDepthCm: depthCm,
    );

    expect(result.facingDepthCm, closeTo(depthCm, 1e-12));
    expect(result.front.upperSegments.length, 2);
    expect(result.front.lowerSegments.length, 2);
    expect(result.back.upperSegments.length, 3);
    expect(result.back.lowerSegments.length, 3);

    void verifyPiece(ShapedWaistbandFacingPieceGeometry piece) {
      for (var i = 0; i < piece.upperSegments.length; i++) {
        final upper = piece.upperSegments[i];
        final lower = piece.lowerSegments[i];

        expect(lower.length, greaterThanOrEqualTo(2));
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

  test('size 14 facing lower edge points toward trouser body', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(
      size14,
      sizeCode: 14,
    );

    const builder = TrouserShapedWaistbandFacingBuilder();
    final result = builder.build(
      draft: draft,
      facingDepthCm: 4.0,
    );

    void verifyTowardHip(
      ShapedWaistbandFacingPieceGeometry piece,
      PatternPoint hipPoint,
      String name,
    ) {
      for (var i = 0; i < piece.upperSegments.length; i++) {
        final upper = piece.upperSegments[i];
        final lower = piece.lowerSegments[i];

        expect(
          lower.first.distanceTo(hipPoint),
          lessThan(upper.start.distanceTo(hipPoint)),
          reason: '$name segment $i start must move toward hip/interior',
        );
        expect(
          lower.last.distanceTo(hipPoint),
          lessThan(upper.end.distanceTo(hipPoint)),
          reason: '$name segment $i end must move toward hip/interior',
        );

        for (final point in lower) {
          expect(point.x.isFinite, isTrue, reason: '$name segment $i finite x');
          expect(point.y.isFinite, isTrue, reason: '$name segment $i finite y');
        }
      }
    }

    verifyTowardHip(result.front, draft[8], 'front');
    verifyTowardHip(result.back, draft[25], 'back');
  });

  test('shaped waistband facing rejects non-positive depth', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(
      size14,
      sizeCode: 14,
    );

    const builder = TrouserShapedWaistbandFacingBuilder();

    expect(
      () => builder.build(draft: draft, facingDepthCm: 0.0),
      throwsArgumentError,
    );
    expect(
      () => builder.build(draft: draft, facingDepthCm: -1.0),
      throwsArgumentError,
    );
  });
}
