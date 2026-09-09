import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/trouser_fly.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';

void main() {
  const measurements = TrouserMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    bodyRise: 28.7,
    waistToFloor: 105.0,
    trouserBottomWidth: 22.0,
  );

  test('Hose-v1 fly uses P10 to P6 and the confirmed 4 cm width', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final fly = const TrouserFlyBuilder().build(draft);

    expect(fly.waistCenterFront.distanceTo(draft[10]), lessThan(1e-9));
    expect(fly.lowerEnd.distanceTo(draft[6]), lessThan(1e-9));
    expect(fly.widthCm, 4.0);
    expect(fly.lengthCm, greaterThan(0.0));
  });

  test('fly length follows the actual P10-P6 draft geometry', () {
    const deeperHip = TrouserMeasurements(
      waist: 76.0,
      hip: 100.0,
      hipDepth: 23.0,
      bodyRise: 28.7,
      waistToFloor: 105.0,
      trouserBottomWidth: 22.0,
    );

    final firstDraft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final secondDraft = TrouserPatternCalculator.calculateReferencePoints(deeperHip);
    final first = const TrouserFlyBuilder().build(firstDraft);
    final second = const TrouserFlyBuilder().build(secondDraft);

    expect(first.lengthCm, closeTo(firstDraft[10].distanceTo(firstDraft[6]), 1e-9));
    expect(second.lengthCm, closeTo(secondDraft[10].distanceTo(secondDraft[6]), 1e-9));
    expect(second.lengthCm, isNot(closeTo(first.lengthCm, 1e-9)));
  });
}
