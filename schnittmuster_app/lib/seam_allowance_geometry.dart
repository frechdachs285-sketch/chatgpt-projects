import 'dart:math' as math;

import 'pattern_geometry.dart';
import 'pattern_models.dart';

/// Low-level geometry helpers for seam allowances.
///
/// Positive [distance] offsets to the left side of the directed geometry.
/// The caller is responsible for choosing the direction that corresponds to
/// the outside of a pattern piece.
class SeamAllowanceGeometry {
  const SeamAllowanceGeometry._();

  static LineSegment offsetLine(LineSegment line, double distance) {
    _validateDistance(distance);

    final dx = line.end.x - line.start.x;
    final dy = line.end.y - line.start.y;
    final length = math.sqrt(dx * dx + dy * dy);
    if (length == 0) {
      throw ArgumentError('Cannot offset a zero-length line segment.');
    }

    final nx = -dy / length;
    final ny = dx / length;
    final shift = PatternPoint(nx * distance, ny * distance);

    return LineSegment(line.start + shift, line.end + shift);
  }

  /// Returns points on a constant-distance normal offset of a cubic Bezier.
  ///
  /// A true offset of a cubic Bezier is generally not itself a cubic Bezier.
  /// Therefore this method deliberately returns sampled offset points instead
  /// of pretending that four shifted control points would be exact.
  ///
  /// [samples] is the number of equal parameter intervals. The returned list
  /// therefore contains [samples] + 1 points, including both endpoints.
  static List<PatternPoint> offsetBezierSamples(
    CubicBezierCurve curve,
    double distance, {
    required int samples,
  }) {
    _validateDistance(distance);
    if (samples < 1) {
      throw ArgumentError.value(samples, 'samples', 'must be at least 1');
    }

    return List<PatternPoint>.generate(samples + 1, (index) {
      final t = index / samples;
      final point = curve.pointAt(t);
      final tangent = curve.derivativeAt(t);
      final tangentLength = math.sqrt(
        tangent.x * tangent.x + tangent.y * tangent.y,
      );
      if (tangentLength == 0) {
        throw StateError('Cannot offset Bezier at a point with zero tangent.');
      }

      final nx = -tangent.y / tangentLength;
      final ny = tangent.x / tangentLength;
      return PatternPoint(
        point.x + nx * distance,
        point.y + ny * distance,
      );
    });
  }

  /// Joins two already-offset edges by intersecting their terminal directions.
  ///
  /// [first] and [second] must each contain at least two points. The last two
  /// points of [first] define the outgoing direction of the first edge, and the
  /// first two points of [second] define the incoming direction of the second
  /// edge. The returned point is the intersection of those infinite lines.
  ///
  /// This is the corner rule we use for two offset edges that must meet in one
  /// precise miter point. Parallel or near-parallel directions are rejected so
  /// that no unstable artificial corner is created.
  static PatternPoint joinOffsetEdges(
    List<PatternPoint> first,
    List<PatternPoint> second, {
    double parallelTolerance = 0.000000001,
  }) {
    if (first.length < 2 || second.length < 2) {
      throw ArgumentError('Each offset edge needs at least two points.');
    }
    if (!parallelTolerance.isFinite || parallelTolerance <= 0) {
      throw ArgumentError.value(
        parallelTolerance,
        'parallelTolerance',
        'must be finite and greater than 0',
      );
    }

    final a = first[first.length - 2];
    final b = first.last;
    final c = second.first;
    final d = second[1];

    return lineIntersection(
      LineSegment(a, b),
      LineSegment(c, d),
      parallelTolerance: parallelTolerance,
    );
  }

  /// Intersection of two infinite directed lines.
  static PatternPoint lineIntersection(
    LineSegment first,
    LineSegment second, {
    double parallelTolerance = 0.000000001,
  }) {
    final r = first.end - first.start;
    final s = second.end - second.start;
    final denominator = _cross(r, s);

    if (denominator.abs() <= parallelTolerance) {
      throw StateError('Cannot join parallel or near-parallel offset edges.');
    }

    final qMinusP = second.start - first.start;
    final t = _cross(qMinusP, s) / denominator;
    return first.start + r * t;
  }

  /// Builds one continuous polyline from offset edge point lists.
  ///
  /// Adjacent edges are joined at their exact miter intersection. The original
  /// input lists are not modified.
  static List<PatternPoint> joinOffsetPolylineEdges(
    List<List<PatternPoint>> edges,
  ) {
    if (edges.isEmpty) {
      throw ArgumentError('At least one offset edge is required.');
    }
    for (final edge in edges) {
      if (edge.length < 2) {
        throw ArgumentError('Each offset edge needs at least two points.');
      }
    }

    if (edges.length == 1) {
      return List<PatternPoint>.from(edges.single);
    }

    final result = <PatternPoint>[];
    var current = List<PatternPoint>.from(edges.first);

    for (var i = 1; i < edges.length; i++) {
      final next = List<PatternPoint>.from(edges[i]);
      final join = joinOffsetEdges(current, next);
      current[current.length - 1] = join;
      next[0] = join;

      if (result.isEmpty) {
        result.addAll(current);
      } else {
        result.addAll(current.skip(1));
      }
      current = next;
    }

    result.addAll(current.skip(1));
    return result;
  }

  /// Exact point-to-point distance at matching Bezier parameter values.
  static double sampleOffsetDistance(
    CubicBezierCurve curve,
    PatternPoint offsetPoint,
    double t,
  ) {
    if (t < 0 || t > 1 || !t.isFinite) {
      throw ArgumentError.value(t, 't', 'must be finite and between 0 and 1');
    }
    return curve.pointAt(t).distanceTo(offsetPoint);
  }

  /// Perpendicular distance between two parallel directed line segments.
  static double parallelDistance(LineSegment original, LineSegment offset) {
    final dx = original.end.x - original.start.x;
    final dy = original.end.y - original.start.y;
    final length = math.sqrt(dx * dx + dy * dy);
    if (length == 0) {
      throw ArgumentError('Cannot measure from a zero-length line segment.');
    }

    final vx = offset.start.x - original.start.x;
    final vy = offset.start.y - original.start.y;
    return (dx * vy - dy * vx).abs() / length;
  }

  static double _cross(PatternPoint a, PatternPoint b) => a.x * b.y - a.y * b.x;

  static void _validateDistance(double distance) {
    if (!distance.isFinite || distance < 0) {
      throw ArgumentError.value(
        distance,
        'distance',
        'must be finite and non-negative',
      );
    }
  }
}
