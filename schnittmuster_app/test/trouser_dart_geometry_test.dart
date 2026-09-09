import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/trouser_dart_geometry.dart';
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

  final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
  const geometry = TrouserDartGeometry();
  const tolerance = 1e-9;

  void expectDartWidthAndLength(
    TrouserDart dart, {
    required double width,
    required double length,
  }) {
    expect(dart.leg1.distanceTo(dart.leg2), closeTo(width, tolerance));
    expect(dart.center.distanceTo(dart.apex), closeTo(length, tolerance));

    final midpointX = (dart.leg1.x + dart.leg2.x) / 2.0;
    final midpointY = (dart.leg1.y + dart.leg2.y) / 2.0;
    expect(midpointX, closeTo(dart.center.x, tolerance));
    expect(midpointY, closeTo(dart.center.y, tolerance));
  }

  test('front dart is centered on P0, 2 cm wide and 10 cm long', () {
    final dart = geometry.front(draft);

    expect(dart.center.distanceTo(draft[0]), lessThan(tolerance));
    expectDartWidthAndLength(dart, width: 2.0, length: 10.0);
    expect(dart.apex.x, closeTo(draft[0].x, tolerance));
    expect(dart.apex.y, greaterThan(dart.center.y));
  });

  test('back P30 dart is 2 cm wide, 12 cm long and perpendicular to P21-P22', () {
    final dart = geometry.back30(draft);

    expect(dart.center.distanceTo(draft[30]), lessThan(tolerance));
    expectDartWidthAndLength(dart, width: 2.0, length: 12.0);

    final waistDx = draft[22].x - draft[21].x;
    final waistDy = draft[22].y - draft[21].y;
    final dartDx = dart.apex.x - dart.center.x;
    final dartDy = dart.apex.y - dart.center.y;
    final dot = waistDx * dartDx + waistDy * dartDy;
    expect(dot, closeTo(0.0, tolerance));
    expect(dart.apex.y, greaterThan(dart.center.y));
  });

  test('back P31 dart is 2 cm wide, 10 cm long and perpendicular to P21-P22', () {
    final dart = geometry.back31(draft);

    expect(dart.center.distanceTo(draft[31]), lessThan(tolerance));
    expectDartWidthAndLength(dart, width: 2.0, length: 10.0);

    final waistDx = draft[22].x - draft[21].x;
    final waistDy = draft[22].y - draft[21].y;
    final dartDx = dart.apex.x - dart.center.x;
    final dartDy = dart.apex.y - dart.center.y;
    final dot = waistDx * dartDx + waistDy * dartDy;
    expect(dot, closeTo(0.0, tolerance));
    expect(dart.apex.y, greaterThan(dart.center.y));
  });
}
