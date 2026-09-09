import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';
import 'package:schnittmuster_app/trouser_shorts_geometry.dart';

void main() {
  const measurements = TrouserMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    bodyRise: 28.7,
    waistToFloor: 105.0,
    trouserBottomWidth: 22.0,
  );

  test('tailored shorts geometry uses exact confirmed trouser intersections', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(
      measurements,
      sizeCode: 14,
    );

    // Use the already confirmed knee-line y-coordinate as a deterministic
    // test construction line. This is a test fixture only, not a product
    // rule for the eventual user-selectable shorts depth.
    final shortsDepthY = draft[4].y;

    final geometry = const TrouserShortsGeometryBuilder().build(
      draft: draft,
      shortsDepthY: shortsDepthY,
    );

    expect(geometry.frontSideHem.x, closeTo(draft[13].x, 1e-8));
    expect(geometry.frontSideHem.y, closeTo(shortsDepthY, 1e-9));
    expect(geometry.frontInseamHem.x, closeTo(draft[15].x, 1e-8));
    expect(geometry.frontInseamHem.y, closeTo(shortsDepthY, 1e-9));

    expect(geometry.backSideHem.x, closeTo(draft[27].x, 1e-8));
    expect(geometry.backSideHem.y, closeTo(shortsDepthY, 1e-9));
    expect(geometry.backInseamHem.x, closeTo(draft[29].x, 1e-8));
    expect(geometry.backInseamHem.y, closeTo(shortsDepthY, 1e-9));
  });

  test('front shorts hem is straight and back midpoint is exactly 1 cm lower', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(
      measurements,
      sizeCode: 14,
    );
    final shortsDepthY = draft[4].y;

    final geometry = const TrouserShortsGeometryBuilder().build(
      draft: draft,
      shortsDepthY: shortsDepthY,
    );

    expect(geometry.frontHem.start.y, closeTo(shortsDepthY, 1e-9));
    expect(geometry.frontHem.end.y, closeTo(shortsDepthY, 1e-9));

    expect(geometry.backHem.start.y, closeTo(shortsDepthY, 1e-9));
    expect(geometry.backHem.end.y, closeTo(shortsDepthY, 1e-9));

    final midpoint = geometry.backHem.pointAt(0.5);
    expect(midpoint.x, closeTo(
      (geometry.backInseamHem.x + geometry.backSideHem.x) / 2.0,
      1e-9,
    ));
    expect(midpoint.y, closeTo(shortsDepthY + 1.0, 1e-9));
  });
}
