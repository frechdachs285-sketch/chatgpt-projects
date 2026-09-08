import 'dart:math' as math;

import 'pattern_models.dart';

/// Defines on which side of the directed source geometry an offset is created.
enum TrouserOffsetSide { left, right }

/// One sampled point of a cubic Bezier together with its exact normal offset.
class TrouserCurveOffsetSample {
  final double t;
  final PatternPoint source;
  final PatternPoint offset;

  const TrouserCurveOffsetSample({
    required this.t,
    required this.source,
    required this.offset,
  });
}

/// Small geometry building blocks for Hose-v1 seam allowances.
///
/// This class does not modify the confirmed seam line. It only returns new
/// geometry that can later be used for a separate cuttingOutline.
class TrouserSeamAllowanceGeometry {
  const TrouserSeamAllowanceGeometry();

  /// Returns a line parallel to [source] at the exact perpendicular distance
  /// [distanceCm].
  ///
  /// [side] is evaluated relative to the direction source.start -> source.end.
  /// No corner handling or curve approximation happens here.
  LineSegment offsetLine(
    LineSegment source, {
    required double distanceCm,
    required TrouserOffsetSide side,
  }) {
    _validateDistance(distanceCm);

    final dx = source.end.x - source.start.x;
    final dy = source.end.y - source.start.y;
    final length = math.sqrt(dx * dx + dy * dy);
    if (length <= 0.0) {
      throw ArgumentError('Cannot offset a zero-length line segment.');
    }

    final normal = _normal(dx, dy, side);
    final shift = normal * distanceCm;

    return LineSegment(source.start + shift, source.end + shift);
  }

  /// Samples the true normal-distance offset of a cubic Bezier.
  ///
  /// Every returned sample lies exactly [distanceCm] from its corresponding
  /// source point along the local curve normal. The samples are intentionally
  /// not yet converted into the final cutting outline: adaptive subdivision
  /// and the confirmed 0.01 cm (0.1 mm) approximation tolerance are handled in
  /// the next layer so the original Bezier remains untouched.
  List<TrouserCurveOffsetSample> sampleBezierOffset(
    BezierSegment source, {
    required double distanceCm,
    required TrouserOffsetSide side,
    required int intervals,
  }) {
    _validateDistance(distanceCm);
    if (intervals < 1) {
      throw ArgumentError.value(intervals, 'intervals', 'must be >= 1');
    }

    final samples = <TrouserCurveOffsetSample>[];
    for (var i = 0; i <= intervals; i++) {
      final t = i / intervals;
      final point = _bezierPoint(source, t);
      final derivative = _bezierDerivative(source, t);
      final length = math.sqrt(
        derivative.x * derivative.x + derivative.y * derivative.y,
      );
      if (length <= 1e-12) {
        throw StateError(
          'Cannot offset cubic Bezier at t=$t because its tangent is zero.',
        );
      }

      final normal = _normal(derivative.x, derivative.y, side);
      samples.add(
        TrouserCurveOffsetSample(
          t: t,
          source: point,
          offset: point + normal * distanceCm,
        ),
      );
    }
    return samples;
  }

  void _validateDistance(double distanceCm) {
    if (!distanceCm.isFinite || distanceCm < 0.0) {
      throw ArgumentError.value(
        distanceCm,
        'distanceCm',
        'must be a finite value >= 0',
      );
    }
  }

  PatternPoint _normal(double dx, double dy, TrouserOffsetSide side) {
    final length = math.sqrt(dx * dx + dy * dy);
    if (length <= 0.0) {
      throw ArgumentError('Cannot calculate a normal for a zero-length vector.');
    }
    final sign = side == TrouserOffsetSide.left ? 1.0 : -1.0;
    return PatternPoint(-dy / length * sign, dx / length * sign);
  }

  PatternPoint _bezierPoint(BezierSegment curve, double t) {
    final u = 1.0 - t;
    return curve.start * (u * u * u) +
        curve.control1 * (3.0 * u * u * t) +
        curve.control2 * (3.0 * u * t * t) +
        curve.end * (t * t * t);
  }

  PatternPoint _bezierDerivative(BezierSegment curve, double t) {
    final u = 1.0 - t;
    return (curve.control1 - curve.start) * (3.0 * u * u) +
        (curve.control2 - curve.control1) * (6.0 * u * t) +
        (curve.end - curve.control2) * (3.0 * t * t);
  }
}
