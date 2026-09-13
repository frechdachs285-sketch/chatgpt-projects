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

  test('front side seam interpolates P11 P8 P13 P12 exactly', () {
    final seam = builder.frontSideSeam(
      p11: draft[11],
      p8: draft[8],
      p13: draft[13],
      p12: draft[12],
    );

    expect(seam.segments, hasLength(3));
    expect(seam.segments[0].start.distanceTo(draft[11]), lessThan(1e-10));
    expect(seam.segments[0].end.distanceTo(draft[8]), lessThan(1e-10));
    expect(seam.segments[1].end.distanceTo(draft[13]), lessThan(1e-10));
    expect(seam.segments[2].end.distanceTo(draft[12]), lessThan(1e-10));
    expect(seam.arcLength.isFinite, isTrue);
  });

  test('back side shaping is exactly 0.5 cm inward at chord midpoint', () {
    final shaping = builder.inwardMidpointCurve(
      start: draft[25],
      end: draft[27],
      depth: 0.5,
    );
    final q = shaping.pointAt(0.5);

    expect(
      signedDistanceFromChord(draft[25], draft[27], q).abs(),
      closeTo(0.5, 1e-9),
    );
    expect(q.x, lessThan((draft[25].x + draft[27].x) / 2.0));
    expect(q.x, closeTo(15.468, 0.002));
    expect(q.y, closeTo(41.299, 0.002));
  });

  test('back side seam interpolates all fixed points and shaping point', () {
    final shaping = builder.inwardMidpointCurve(
      start: draft[25],
      end: draft[27],
      depth: 0.5,
    );
    final q = shaping.pointAt(0.5);
    final seam = builder.backSideSeam(
      p22: draft[22],
      p25: draft[25],
      p27: draft[27],
      p26: draft[26],
    );

    expect(seam.segments, hasLength(4));
    expect(seam.segments[0].start.distanceTo(draft[22]), lessThan(1e-10));
    expect(seam.segments[0].end.distanceTo(draft[25]), lessThan(1e-10));
    expect(seam.segments[1].end.distanceTo(q), lessThan(1e-10));
    expect(seam.segments[2].end.distanceTo(draft[27]), lessThan(1e-10));
    expect(seam.segments[3].end.distanceTo(draft[26]), lessThan(1e-10));
    expect(seam.arcLength.isFinite, isTrue);
  });
}
