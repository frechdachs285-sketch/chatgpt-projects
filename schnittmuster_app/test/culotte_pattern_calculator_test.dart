import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/culotte_measurements.dart';
import 'package:schnittmuster_app/culotte_pattern_calculator.dart';

void main() {
  test('Aldrich size 14 reference points are calculated correctly', () {
    const measurements = CulotteMeasurements(
      waist: 76.0,
      hip: 100.0,
      hipDepth: 20.9,
      finishedLength: 60.0, // test input only; not an Aldrich size-table value
      bodyRise: 28.7,
    );

    final points = const CulottePatternCalculator().calculatePoints(measurements);
    const tolerance = 1e-9;

    void expectPoint(String key, double x, double y) {
      expect(points[key], isNotNull);
      expect(points[key]!.x, closeTo(x, tolerance));
      expect(points[key]!.y, closeTo(y, tolerance));
    }

    expectPoint('C0', 0.0, 0.0);
    expectPoint('C1', 0.0, 30.2);
    expectPoint('C2', 0.0, 60.0);
    expectPoint('C3', 0.0, 14.1);
    expectPoint('C4', -14.5, 30.2);

    expectPoint('C5', 0.0, 0.0);
    expectPoint('C6', 0.0, 30.2);
    expectPoint('C7', 0.0, 60.0);
    expectPoint('C8', 0.0, 15.1);
    expectPoint('C9', 10.5, 30.2);

    // Culotte v1 uses Aldrich's explicitly permitted completely straight
    // skirt basis: no optional 1 cm back swing and no 2.5 cm hem flare.
    // Therefore both centre lines remain vertical in the local point system.
    expect(points['C0']!.x, closeTo(points['C1']!.x, tolerance));
    expect(points['C1']!.x, closeTo(points['C2']!.x, tolerance));
    expect(points['C5']!.x, closeTo(points['C6']!.x, tolerance));
    expect(points['C6']!.x, closeTo(points['C7']!.x, tolerance));

    final backOffset = 3.0 / math.sqrt(2.0);
    final frontOffset = 4.0 / math.sqrt(2.0);
    expectPoint('H3', -backOffset, 30.2 - backOffset);
    expectPoint('H4', frontOffset, 30.2 - frontOffset);
  });

  test('rejects non-positive front crotch extension', () {
    const measurements = CulotteMeasurements(
      waist: 76.0,
      hip: 16.0,
      hipDepth: 20.9,
      finishedLength: 60.0,
      bodyRise: 28.7,
    );

    expect(
      () => const CulottePatternCalculator().calculatePoints(measurements),
      throwsArgumentError,
    );
  });
}
