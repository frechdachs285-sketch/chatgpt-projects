import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_seam_allowance_geometry.dart';

void main() {
  const geometry = TrouserSeamAllowanceGeometry();
  const tolerance = 1e-9;

  BezierSegment testCurve() => BezierSegment(
        start: const PatternPoint(0.0, 0.0),
        control1: const PatternPoint(2.0, 0.0),
        control2: const PatternPoint(4.0, 3.0),
        end: const PatternPoint(6.0, 3.0),
        role: 'test_curve',
      );

  test('every sampled curve offset has the exact requested distance', () {
    const distance = 1.25;
    final samples = geometry.sampleBezierOffset(
      testCurve(),
      distanceCm: distance,
      side: TrouserOffsetSide.left,
      intervals: 20,
    );

    expect(samples.length, 21);
    for (final sample in samples) {
      expect(
        sample.source.distanceTo(sample.offset),
        closeTo(distance, tolerance),
      );
    }
  });

  test('offset vector is perpendicular to the local cubic tangent', () {
    final curve = testCurve();
    final samples = geometry.sampleBezierOffset(
      curve,
      distanceCm: 0.8,
      side: TrouserOffsetSide.left,
      intervals: 20,
    );

    for (final sample in samples) {
      final t = sample.t;
      final u = 1.0 - t;
      final tangent =
          (curve.control1 - curve.start) * (3.0 * u * u) +
              (curve.control2 - curve.control1) * (6.0 * u * t) +
              (curve.end - curve.control2) * (3.0 * t * t);
      final offsetVector = sample.offset - sample.source;
      final dot = tangent.x * offsetVector.x + tangent.y * offsetVector.y;
      expect(dot, closeTo(0.0, tolerance));
    }
  });

  test('left and right offsets lie on opposite sides of the same source points', () {
    final curve = testCurve();
    final left = geometry.sampleBezierOffset(
      curve,
      distanceCm: 1.0,
      side: TrouserOffsetSide.left,
      intervals: 10,
    );
    final right = geometry.sampleBezierOffset(
      curve,
      distanceCm: 1.0,
      side: TrouserOffsetSide.right,
      intervals: 10,
    );

    for (var i = 0; i < left.length; i++) {
      expect(left[i].source.distanceTo(right[i].source), lessThan(tolerance));
      final midpoint = PatternPoint(
        (left[i].offset.x + right[i].offset.x) / 2.0,
        (left[i].offset.y + right[i].offset.y) / 2.0,
      );
      expect(midpoint.distanceTo(left[i].source), lessThan(tolerance));
    }
  });

  test('zero distance leaves every sampled point on the source curve', () {
    final samples = geometry.sampleBezierOffset(
      testCurve(),
      distanceCm: 0.0,
      side: TrouserOffsetSide.left,
      intervals: 8,
    );

    for (final sample in samples) {
      expect(sample.source.distanceTo(sample.offset), lessThan(tolerance));
    }
  });

  test('invalid interval count is rejected', () {
    expect(
      () => geometry.sampleBezierOffset(
        testCurve(),
        distanceCm: 1.0,
        side: TrouserOffsetSide.left,
        intervals: 0,
      ),
      throwsArgumentError,
    );
  });

  test('invalid curve offset distance is rejected', () {
    expect(
      () => geometry.sampleBezierOffset(
        testCurve(),
        distanceCm: -0.1,
        side: TrouserOffsetSide.left,
        intervals: 10,
      ),
      throwsArgumentError,
    );
  });
}
