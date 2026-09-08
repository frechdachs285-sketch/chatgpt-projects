import 'dart:math' as math;

import 'pattern_models.dart';

/// Defines on which side of the directed source line an offset is created.
enum TrouserOffsetSide { left, right }

/// Small, exact geometry building blocks for Hose-v1 seam allowances.
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
    if (!distanceCm.isFinite || distanceCm < 0.0) {
      throw ArgumentError.value(
        distanceCm,
        'distanceCm',
        'must be a finite value >= 0',
      );
    }

    final dx = source.end.x - source.start.x;
    final dy = source.end.y - source.start.y;
    final length = math.sqrt(dx * dx + dy * dy);
    if (length <= 0.0) {
      throw ArgumentError('Cannot offset a zero-length line segment.');
    }

    final leftNormalX = -dy / length;
    final leftNormalY = dx / length;
    final sign = side == TrouserOffsetSide.left ? 1.0 : -1.0;
    final shift = PatternPoint(
      leftNormalX * distanceCm * sign,
      leftNormalY * distanceCm * sign,
    );

    return LineSegment(source.start + shift, source.end + shift);
  }
}
