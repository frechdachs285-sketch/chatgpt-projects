import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_outline_builder.dart';
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
  const builder = TrouserOutlineBuilder();

  void expectContinuous(PatternPath path, {double tolerance = 1e-9}) {
    for (var i = 0; i < path.segments.length - 1; i++) {
      final a = path.segments[i];
      final b = path.segments[i + 1];
      expect(
        a.end.distanceTo(b.start),
        lessThanOrEqualTo(tolerance),
        reason: 'Segment $i -> ${i + 1} ist nicht kontinuierlich.',
      );
    }
  }

  test('front lower contour is continuous and keeps confirmed endpoints', () {
    final path = builder.frontLowerContour(draft);

    expect(path.segments, isNotEmpty);
    expect(path.segments.first.start.distanceTo(draft[11]), lessThan(1e-9));
    expect(path.segments.last.end.distanceTo(draft[9]), lessThan(1e-9));
    expectContinuous(path);
  });

  test('back lower contour is continuous and keeps confirmed endpoints', () {
    final path = builder.backLowerContour(draft);

    expect(path.segments, isNotEmpty);
    expect(path.segments.first.start.distanceTo(draft[22]), lessThan(1e-9));
    expect(path.segments.last.end.distanceTo(draft[24]), lessThan(1e-9));
    expectContinuous(path);
  });

  test('front and back contours include hem roles', () {
    final front = builder.frontLowerContour(draft);
    final back = builder.backLowerContour(draft);

    expect(
      front.segments.whereType<BezierSegment>().any((s) => s.role == 'front_hem'),
      isTrue,
    );
    expect(
      back.segments.whereType<BezierSegment>().any((s) => s.role == 'back_hem'),
      isTrue,
    );
  });
}
