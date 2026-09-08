import 'pattern_models.dart';
import 'trouser_seam_allowance.dart';
import 'trouser_seam_allowance_geometry.dart';

class TrouserOffsetPart {
  final PathSegment source;
  final double allowanceCm;
  final List<PatternPoint> points;

  const TrouserOffsetPart({
    required this.source,
    required this.allowanceCm,
    required this.points,
  });
}

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

  List<TrouserOffsetPart> prepareOffsetParts(
    PatternPath outline, {
    required TrouserSeamAllowanceSettings settings,
    required PatternPoint frontP10,
    required PatternPoint frontP11,
    required PatternPoint backP21,
    required PatternPoint backP22,
  }) {
    if (!settings.enabled) return const [];
    if (!settings.isValid) {
      throw ArgumentError('Invalid Hose-v1 seam allowance settings.');
    }
    return [
      for (final segment in outline.segments)
        _preparePart(
          segment,
          settings: settings,
          frontP10: frontP10,
          frontP11: frontP11,
          backP21: backP21,
          backP22: backP22,
        ),
    ];
  }

  PatternPoint lineLineTransition(
    TrouserOffsetPart first,
    TrouserOffsetPart second,
  ) {
    if (first.source is! LineSegment || second.source is! LineSegment) {
      throw ArgumentError('lineLineTransition requires two straight parts.');
    }
    if (first.points.length != 2 || second.points.length != 2) {
      throw StateError('Straight offset parts must contain exactly two points.');
    }
    return geometry.intersectLines(
      LineSegment(first.points[0], first.points[1]),
      LineSegment(second.points[0], second.points[1]),
    );
  }

  PatternPoint curveLineTransition(
    TrouserOffsetPart curvePart,
    TrouserOffsetPart linePart,
  ) {
    if (curvePart.source is! BezierSegment || linePart.source is! LineSegment) {
      throw ArgumentError(
        'curveLineTransition requires curve part first and straight part second.',
      );
    }
    if (curvePart.points.length < 2) {
      throw StateError('Curve offset part must contain at least two points.');
    }
    if (linePart.points.length != 2) {
      throw StateError('Straight offset part must contain exactly two points.');
    }
    return geometry.intersectPolylineWithLine(
      curvePart.points,
      LineSegment(linePart.points[0], linePart.points[1]),
    );
  }

  /// Returns the finite accepted offset-polyline intersection for two
  /// neighbouring curved contour parts. This is the confirmed internal rule
  /// used for the Hose-v1 side-seam -> hem transition: no curve extension,
  /// tangent construction or arbitrary radius is introduced.
  PatternPoint curveCurveTransition(
    TrouserOffsetPart first,
    TrouserOffsetPart second,
  ) {
    if (first.source is! BezierSegment || second.source is! BezierSegment) {
      throw ArgumentError('curveCurveTransition requires two curved parts.');
    }
    if (first.points.length < 2 || second.points.length < 2) {
      throw StateError('Curve offset parts must contain at least two points.');
    }
    return geometry.intersectPolylines(first.points, second.points);
  }

  /// Resolves the actual Hose-v1 side-seam -> hem transition from prepared
  /// offset parts while keeping both original seam-line segments untouched.
  PatternPoint sideHemTransition(
    TrouserOffsetPart sidePart,
    TrouserOffsetPart hemPart,
  ) {
    final side = sidePart.source;
    final hem = hemPart.source;
    if (side is! BezierSegment ||
        hem is! BezierSegment ||
        !side.role.endsWith('_side_seam') ||
        !hem.role.endsWith('_hem')) {
      throw ArgumentError(
        'sideHemTransition requires side-seam curve first and hem curve second.',
      );
    }
    return curveCurveTransition(sidePart, hemPart);
  }

  TrouserOffsetPart _preparePart(
    PathSegment segment, {
    required TrouserSeamAllowanceSettings settings,
    required PatternPoint frontP10,
    required PatternPoint frontP11,
    required PatternPoint backP21,
    required PatternPoint backP22,
  }) {
    final allowance = allowanceForSegment(
      segment,
      settings: settings,
      frontP10: frontP10,
      frontP11: frontP11,
      backP21: backP21,
      backP22: backP22,
    );
    return TrouserOffsetPart(
      source: segment,
      allowanceCm: allowance,
      points: offsetSegment(segment, distanceCm: allowance),
    );
  }

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
