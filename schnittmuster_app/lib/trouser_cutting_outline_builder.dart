import 'pattern_models.dart';
import 'trouser_seam_allowance.dart';
import 'trouser_seam_allowance_geometry.dart';

class TrouserOffsetPart {
  final PathSegment source;
  final double allowanceCm;
  final List<PatternPoint> points;

  const TrouserOffsetPart({required this.source, required this.allowanceCm, required this.points});
}

class TrouserCuttingOutlineBuilder {
  final TrouserSeamAllowanceGeometry geometry;
  const TrouserCuttingOutlineBuilder({this.geometry = const TrouserSeamAllowanceGeometry()});

  double allowanceForSegment(PathSegment segment, {required TrouserSeamAllowanceSettings settings, required PatternPoint frontP10, required PatternPoint frontP11, required PatternPoint backP21, required PatternPoint backP22}) {
    if (!settings.isValid) throw ArgumentError('Invalid Hose-v1 seam allowance settings.');
    if (segment is BezierSegment && segment.role.endsWith('_hem')) return settings.hemCm;
    if (segment is LineSegment && (_sameDirectedLine(segment, frontP10, frontP11) || _sameDirectedLine(segment, backP21, backP22))) return settings.waistCm;
    return settings.normalCm;
  }

  List<TrouserOffsetPart> prepareOffsetParts(PatternPath outline, {required TrouserSeamAllowanceSettings settings, required PatternPoint frontP10, required PatternPoint frontP11, required PatternPoint backP21, required PatternPoint backP22}) {
    if (!settings.enabled) return const [];
    if (!settings.isValid) throw ArgumentError('Invalid Hose-v1 seam allowance settings.');
    return [for (final segment in outline.segments) _preparePart(segment, settings: settings, frontP10: frontP10, frontP11: frontP11, backP21: backP21, backP22: backP22)];
  }

  PatternPoint lineLineTransition(TrouserOffsetPart first, TrouserOffsetPart second) {
    if (first.source is! LineSegment || second.source is! LineSegment) throw ArgumentError('lineLineTransition requires two straight parts.');
    if (first.points.length != 2 || second.points.length != 2) throw StateError('Straight offset parts must contain exactly two points.');
    return geometry.intersectLines(LineSegment(first.points[0], first.points[1]), LineSegment(second.points[0], second.points[1]));
  }

  PatternPoint curveLineTransition(TrouserOffsetPart curvePart, TrouserOffsetPart linePart) {
    if (curvePart.source is! BezierSegment || linePart.source is! LineSegment) throw ArgumentError('curveLineTransition requires curve part first and straight part second.');
    if (curvePart.points.length < 2) throw StateError('Curve offset part must contain at least two points.');
    if (linePart.points.length != 2) throw StateError('Straight offset part must contain exactly two points.');
    return geometry.intersectPolylineWithLine(curvePart.points, LineSegment(linePart.points[0], linePart.points[1]));
  }

  /// Same geometry as curveLineTransition, but with the contour stored in the
  /// opposite order. The finite accepted curve offset is still the object
  /// tested against the infinite straight offset line.
  PatternPoint lineCurveTransition(TrouserOffsetPart linePart, TrouserOffsetPart curvePart) {
    if (linePart.source is! LineSegment || curvePart.source is! BezierSegment) {
      throw ArgumentError('lineCurveTransition requires straight part first and curve part second.');
    }
    return curveLineTransition(curvePart, linePart);
  }

  PatternPoint curveCurveTransition(TrouserOffsetPart first, TrouserOffsetPart second) {
    if (first.source is! BezierSegment || second.source is! BezierSegment) throw ArgumentError('curveCurveTransition requires two curved parts.');
    if (first.points.length < 2 || second.points.length < 2) throw StateError('Curve offset parts must contain at least two points.');
    return geometry.intersectPolylines(first.points, second.points);
  }

  PatternPoint sideHemTransition(TrouserOffsetPart sidePart, TrouserOffsetPart hemPart) {
    final side = sidePart.source;
    final hem = hemPart.source;
    if (side is! BezierSegment || hem is! BezierSegment || !side.role.endsWith('_side_seam') || !hem.role.endsWith('_hem')) {
      throw ArgumentError('sideHemTransition requires side-seam curve first and hem curve second.');
    }
    return curveCurveTransition(sidePart, hemPart);
  }

  PatternPoint hemLowerInseamTransition(TrouserOffsetPart hemPart, TrouserOffsetPart lowerInseamPart) {
    final hem = hemPart.source;
    final inseam = lowerInseamPart.source;
    if (hem is! BezierSegment || !hem.role.endsWith('_hem') || inseam is! LineSegment) {
      throw ArgumentError('hemLowerInseamTransition requires hem curve first and lower inseam line second.');
    }
    return curveLineTransition(hemPart, lowerInseamPart);
  }

  /// Joins the lower straight inseam to the upper curved inseam. Both parts
  /// must use the same normal allowance, so no artificial corner or radius is
  /// introduced. The accepted upper curve remains finite and the lower
  /// straight offset is treated as an infinite line for the transition point.
  PatternPoint lowerUpperInseamTransition(TrouserOffsetPart lowerPart, TrouserOffsetPart upperPart) {
    final upper = upperPart.source;
    if (lowerPart.source is! LineSegment || upper is! BezierSegment || !upper.role.endsWith('_inseam')) {
      throw ArgumentError('lowerUpperInseamTransition requires lower inseam line first and upper inseam curve second.');
    }
    if ((lowerPart.allowanceCm - upperPart.allowanceCm).abs() > 1e-12) {
      throw ArgumentError('Lower and upper inseam must use the same seam allowance.');
    }
    return lineCurveTransition(lowerPart, upperPart);
  }

  TrouserOffsetPart _preparePart(PathSegment segment, {required TrouserSeamAllowanceSettings settings, required PatternPoint frontP10, required PatternPoint frontP11, required PatternPoint backP21, required PatternPoint backP22}) {
    final allowance = allowanceForSegment(segment, settings: settings, frontP10: frontP10, frontP11: frontP11, backP21: backP21, backP22: backP22);
    return TrouserOffsetPart(source: segment, allowanceCm: allowance, points: offsetSegment(segment, distanceCm: allowance));
  }

  List<PatternPoint> offsetSegment(PathSegment segment, {required double distanceCm}) {
    if (segment is LineSegment) {
      final offset = geometry.offsetLine(segment, distanceCm: distanceCm, side: trouserOuterOffsetSide);
      return [offset.start, offset.end];
    }
    if (segment is BezierSegment) {
      return geometry.adaptiveBezierOffset(segment, distanceCm: distanceCm, side: trouserOuterOffsetSide, toleranceCm: trouserSeamAllowanceToleranceCm);
    }
    throw ArgumentError('Unsupported Hose-v1 contour segment type.');
  }

  bool _sameDirectedLine(LineSegment segment, PatternPoint expectedStart, PatternPoint expectedEnd) => segment.start.distanceTo(expectedStart) <= 1e-9 && segment.end.distanceTo(expectedEnd) <= 1e-9;
}
