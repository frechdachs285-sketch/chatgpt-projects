import 'dart:math' as math;

import 'pattern_models.dart';

/// Defines on which side of the directed source geometry an offset is created.
enum TrouserOffsetSide { left, right }

/// The confirmed front and back Hose-v1 contours are clockwise in the app's
/// y-down coordinate system. Their interior is therefore on the directed
/// right side and their exterior is on the directed left side.
const TrouserOffsetSide trouserOuterOffsetSide = TrouserOffsetSide.left;

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
    final shift = _normal(dx, dy, side) * distanceCm;
    return LineSegment(source.start + shift, source.end + shift);
  }

  /// Returns the mathematical intersection of the two infinite lines defined
  /// by [first] and [second]. This deliberately uses the extended lines so
  /// different seam-allowance widths can meet at their exact corner.
  PatternPoint intersectLines(LineSegment first, LineSegment second) {
    final rx = first.end.x - first.start.x;
    final ry = first.end.y - first.start.y;
    final sx = second.end.x - second.start.x;
    final sy = second.end.y - second.start.y;
    final denominator = rx * sy - ry * sx;
    if (denominator.abs() <= 1e-12) {
      throw StateError('Cannot intersect parallel or coincident lines.');
    }

    final qpx = second.start.x - first.start.x;
    final qpy = second.start.y - first.start.y;
    final t = (qpx * sy - qpy * sx) / denominator;
    return PatternPoint(
      first.start.x + t * rx,
      first.start.y + t * ry,
    );
  }

  /// Finds the deterministic transition between an accepted adaptive curve
  /// offset polyline and an infinite offset line.
  ///
  /// The polyline is tested segment by segment in its stored direction. The
  /// first mathematical intersection lying on a finite polyline segment is
  /// returned. The line itself is deliberately infinite, matching the agreed
  /// corner rule for seam-allowance transitions.
  PatternPoint intersectPolylineWithLine(
    List<PatternPoint> polyline,
    LineSegment line,
  ) {
    if (polyline.length < 2) {
      throw ArgumentError.value(
        polyline,
        'polyline',
        'must contain at least 2 points',
      );
    }

    for (var i = 0; i < polyline.length - 1; i++) {
      final hit = _finiteSegmentIntersection(
        polyline[i],
        polyline[i + 1],
        line.start,
        line.end,
        secondInfinite: true,
      );
      if (hit != null) return hit;
    }

    throw StateError('Offset polyline does not intersect the offset line.');
  }

  /// Finds the first mathematical intersection of two finite accepted offset
  /// polylines. Both are scanned in their stored path direction. No tangent or
  /// curve extension is invented; only existing finite polyline segments are
  /// eligible for the transition.
  PatternPoint intersectPolylines(
    List<PatternPoint> first,
    List<PatternPoint> second,
  ) {
    if (first.length < 2) {
      throw ArgumentError.value(first, 'first', 'must contain at least 2 points');
    }
    if (second.length < 2) {
      throw ArgumentError.value(
        second,
        'second',
        'must contain at least 2 points',
      );
    }

    for (var i = 0; i < first.length - 1; i++) {
      for (var j = 0; j < second.length - 1; j++) {
        final hit = _finiteSegmentIntersection(
          first[i],
          first[i + 1],
          second[j],
          second[j + 1],
        );
        if (hit != null) return hit;
      }
    }

    throw StateError('Offset polylines do not intersect.');
  }

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
    return List.generate(
      intervals + 1,
      (i) => _offsetSample(source, i / intervals, distanceCm, side),
    );
  }

  /// Returns a polyline approximation of the true normal-distance offset.
  ///
  /// Each interval is recursively split until the true offset midpoint differs
  /// from the straight chord between its two accepted offset endpoints by no
  /// more than [toleranceCm]. For Hose v1 the caller uses the confirmed
  /// engineering tolerance 0.01 cm = 0.1 mm.
  List<PatternPoint> adaptiveBezierOffset(
    BezierSegment source, {
    required double distanceCm,
    required TrouserOffsetSide side,
    required double toleranceCm,
    int maxDepth = 20,
  }) {
    _validateDistance(distanceCm);
    if (!toleranceCm.isFinite || toleranceCm <= 0.0) {
      throw ArgumentError.value(
        toleranceCm,
        'toleranceCm',
        'must be a finite value > 0',
      );
    }
    if (maxDepth < 1) {
      throw ArgumentError.value(maxDepth, 'maxDepth', 'must be >= 1');
    }

    final first = _offsetSample(source, 0.0, distanceCm, side);
    final last = _offsetSample(source, 1.0, distanceCm, side);
    final result = <PatternPoint>[first.offset];
    _subdivideOffset(
      source,
      first,
      last,
      distanceCm,
      side,
      toleranceCm,
      maxDepth,
      0,
      result,
    );
    return result;
  }

  /// Converts an already accepted offset polyline into the PatternPath model
  /// used by cuttingOutline. No geometry is changed: every accepted point is
  /// connected to the next one by a straight segment.
  PatternPath polylinePath(List<PatternPoint> points) {
    if (points.length < 2) {
      throw ArgumentError.value(points, 'points', 'must contain at least 2 points');
    }
    return PatternPath([
      for (var i = 0; i < points.length - 1; i++)
        LineSegment(points[i], points[i + 1]),
    ]);
  }

  PatternPoint? _finiteSegmentIntersection(
    PatternPoint a,
    PatternPoint b,
    PatternPoint c,
    PatternPoint d, {
    bool secondInfinite = false,
  }) {
    final rx = b.x - a.x;
    final ry = b.y - a.y;
    final sx = d.x - c.x;
    final sy = d.y - c.y;
    final denominator = rx * sy - ry * sx;
    if (denominator.abs() <= 1e-12) return null;

    final qpx = c.x - a.x;
    final qpy = c.y - a.y;
    final t = (qpx * sy - qpy * sx) / denominator;
    final u = (qpx * ry - qpy * rx) / denominator;
    if (t < -1e-12 || t > 1.0 + 1e-12) return null;
    if (!secondInfinite && (u < -1e-12 || u > 1.0 + 1e-12)) return null;

    final clampedT = t.clamp(0.0, 1.0).toDouble();
    return PatternPoint(a.x + clampedT * rx, a.y + clampedT * ry);
  }

  void _subdivideOffset(
    BezierSegment source,
    TrouserCurveOffsetSample a,
    TrouserCurveOffsetSample b,
    double distanceCm,
    TrouserOffsetSide side,
    double toleranceCm,
    int maxDepth,
    int depth,
    List<PatternPoint> result,
  ) {
    final tm = (a.t + b.t) / 2.0;
    final mid = _offsetSample(source, tm, distanceCm, side);
    final chordMid = PatternPoint(
      (a.offset.x + b.offset.x) / 2.0,
      (a.offset.y + b.offset.y) / 2.0,
    );
    final error = mid.offset.distanceTo(chordMid);

    if (error <= toleranceCm) {
      result.add(b.offset);
      return;
    }
    if (depth >= maxDepth) {
      throw StateError(
        'Adaptive Bezier offset did not reach tolerance $toleranceCm cm.',
      );
    }

    _subdivideOffset(
      source,
      a,
      mid,
      distanceCm,
      side,
      toleranceCm,
      maxDepth,
      depth + 1,
      result,
    );
    _subdivideOffset(
      source,
      mid,
      b,
      distanceCm,
      side,
      toleranceCm,
      maxDepth,
      depth + 1,
      result,
    );
  }

  TrouserCurveOffsetSample _offsetSample(
    BezierSegment source,
    double t,
    double distanceCm,
    TrouserOffsetSide side,
  ) {
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
    return TrouserCurveOffsetSample(
      t: t,
      source: point,
      offset: point + normal * distanceCm,
    );
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
