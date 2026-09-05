import 'dart:math' as math;

import 'pattern_models.dart';

/// Low-level geometry helpers for seam allowances.
///
/// Positive [distance] offsets to the left side of the directed line
/// start -> end. The caller is responsible for choosing the direction that
/// corresponds to the outside of a pattern piece.
class SeamAllowanceGeometry {
  const SeamAllowanceGeometry._();

  static LineSegment offsetLine(LineSegment line, double distance) {
    if (!distance.isFinite || distance < 0) {
      throw ArgumentError.value(
        distance,
        'distance',
        'must be finite and non-negative',
      );
    }

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
}
