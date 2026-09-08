import 'pattern_models.dart';
import 'trouser_seam_allowance.dart';
import 'trouser_seam_allowance_geometry.dart';

/// Builds only the separate Hose-v1 cutting outline.
///
/// The confirmed seam-line outline is never modified. Allowance assignment is
/// deterministic from the already confirmed Hose-v1 topology:
/// - hem: role ending in `_hem`
/// - front waist: P10 -> P11
/// - back waist: P21 -> P22
/// - every other contour segment: normal allowance
class TrouserCuttingOutlineBuilder {
  final TrouserSeamAllowanceGeometry geometry;

  const TrouserCuttingOutlineBuilder({
    this.geometry = const TrouserSeamAllowanceGeometry(),
  });

  double allowanceForSegment(
    PathSegment segment, {
    required TrouserSeamAllowanceSettings settings,
    required PatternPoint frontP10,
    required PatternPoint frontP11,
    required PatternPoint backP21,
    required PatternPoint backP22,
  }) {
    if (!settings.isValid) {
      throw ArgumentError('Invalid Hose-v1 seam allowance settings.');
    }

    if (segment is BezierSegment && segment.role.endsWith('_hem')) {
      return settings.hemCm;
    }

    if (segment is LineSegment &&
        (_sameDirectedLine(segment, frontP10, frontP11) ||
            _sameDirectedLine(segment, backP21, backP22))) {
      return settings.waistCm;
    }

    return settings.normalCm;
  }

  /// Offsets one confirmed contour segment outward without changing it.
  /// Curves use the accepted adaptive polyline representation at the Hose-v1
  /// tolerance; straight segments remain exact parallel offsets.
  List<PatternPoint> offsetSegment(
    PathSegment segment, {
    required double distanceCm,
  }) {
    if (segment is LineSegment) {
      final offset = geometry.offsetLine(
        segment,
        distanceCm: distanceCm,
        side: trouserOuterOffsetSide,
      );
      return [offset.start, offset.end];
    }
    if (segment is BezierSegment) {
      return geometry.adaptiveBezierOffset(
        segment,
        distanceCm: distanceCm,
        side: trouserOuterOffsetSide,
        toleranceCm: trouserSeamAllowanceToleranceCm,
      );
    }
    throw ArgumentError('Unsupported Hose-v1 contour segment type.');
  }

  bool _sameDirectedLine(
    LineSegment segment,
    PatternPoint expectedStart,
    PatternPoint expectedEnd,
  ) =>
      segment.start.distanceTo(expectedStart) <= 1e-9 &&
      segment.end.distanceTo(expectedEnd) <= 1e-9;
}
