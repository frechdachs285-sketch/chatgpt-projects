import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_curve_geometry.dart';
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
  const builder = TrouserCurveBuilder();

  double signedDistanceFromChord(
    PatternPoint start,
    PatternPoint end,
    PatternPoint point,
  ) {
    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final length = math.sqrt(dx * dx + dy * dy);
    return ((point.x - start.x) * dy - (point.y - start.y) * dx) / length;
  }

  test('front inseam has exact 0.75 cm midpoint shaping', () {
    final curve = builder.inwardMidpointCurve(
      start: draft[9],
      end: draft[15],
      depth: 0.75,
    );
    final q = curve.pointAt(0.5);

    expect(signedDistanceFromChord(draft[9], draft[15], q).abs(), closeTo(0.75, 1e-9));
    expect(q.x, greaterThan((draft[9].x + draft[15].x) / 2.0));
    expect(curve.start.distanceTo(draft[9]), lessThan(1e-12));
    expect(curve.end.distanceTo(draft[15]), lessThan(1e-12));
  });

  test('back inseam has exact 1.25 cm midpoint shaping', () {
    final curve = builder.inwardMidpointCurve(
      start: draft[24],
      end: draft[29],
      depth: 1.25,
    );
    final q = curve.pointAt(0.5);

    expect(signedDistanceFromChord(draft[24], draft[29], q).abs(), closeTo(1.25, 1e-9));
    expect(q.x, greaterThan((draft[24].x + draft[29].x) / 2.0));
    expect(curve.start.distanceTo(draft[24]), lessThan(1e-12));
    expect(curve.end.distanceTo(draft[29]), lessThan(1e-12));
  });

  test('size 14 back inseam form point is fixed numerically', () {
    final curve = builder.inwardMidpointCurve(
      start: draft[24],
      end: draft[29],
      depth: 1.25,
    );
    final q = curve.pointAt(0.5);

    expect(q.x, closeTo(-15.3927, 0.001));
    expect(q.y, closeTo(45.3469, 0.001));
  });
}
