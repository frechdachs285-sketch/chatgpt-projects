import 'package:flutter_test/flutter_test.dart';
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

  test('front crotch guide is exactly 3.0 cm from P5', () {
    final q = builder.frontCrotchGuide(draft[5]);
    expect(draft[5].distanceTo(q), closeTo(3.0, 1e-10));
  });

  test('back crotch guide is exactly 4.25 cm from P16', () {
    final q = builder.backCrotchGuide(draft[16]);
    expect(draft[16].distanceTo(q), closeTo(4.25, 1e-10));
  });

  test('front natural spline interpolates P6, Qv and P9 exactly', () {
    final q = builder.frontCrotchGuide(draft[5]);
    final spline = builder.naturalSplineThrough([draft[6], q, draft[9]]);

    expect(spline.segments, hasLength(2));
    expect(spline.segments.first.start.distanceTo(draft[6]), lessThan(1e-10));
    expect(spline.segments.first.end.distanceTo(q), lessThan(1e-10));
    expect(spline.segments.last.start.distanceTo(q), lessThan(1e-10));
    expect(spline.segments.last.end.distanceTo(draft[9]), lessThan(1e-10));
    expect(spline.arcLength.isFinite, isTrue);
  });

  test('back natural spline interpolates P21, P19, Qh and P24 exactly', () {
    final q = builder.backCrotchGuide(draft[16]);
    final spline = builder.naturalSplineThrough([
      draft[21],
      draft[19],
      q,
      draft[24],
    ]);

    expect(spline.segments, hasLength(3));
    expect(spline.segments[0].start.distanceTo(draft[21]), lessThan(1e-10));
    expect(spline.segments[0].end.distanceTo(draft[19]), lessThan(1e-10));
    expect(spline.segments[1].start.distanceTo(draft[19]), lessThan(1e-10));
    expect(spline.segments[1].end.distanceTo(q), lessThan(1e-10));
    expect(spline.segments[2].start.distanceTo(q), lessThan(1e-10));
    expect(spline.segments[2].end.distanceTo(draft[24]), lessThan(1e-10));
    expect(spline.arcLength.isFinite, isTrue);
  });

  test('spline uses cumulative chord-length parameters', () {
    final q = builder.frontCrotchGuide(draft[5]);
    final spline = builder.naturalSplineThrough([draft[6], q, draft[9]]);

    expect(spline.parameters[0], 0.0);
    expect(
      spline.parameters[1],
      closeTo(draft[6].distanceTo(q), 1e-10),
    );
    expect(
      spline.parameters[2],
      closeTo(draft[6].distanceTo(q) + q.distanceTo(draft[9]), 1e-10),
    );
  });
}
