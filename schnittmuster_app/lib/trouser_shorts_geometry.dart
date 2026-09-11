import 'horizontal_curve_intersection.dart';
import 'pattern_geometry.dart';
import 'pattern_models.dart';
import 'trouser_curve_geometry.dart';
import 'trouser_pattern_calculator.dart';

/// Geometry for Aldrich tailored shorts derived from the confirmed Hose-v1
/// trouser curves.
///
/// Aldrich source rule (5th ed., pp. 100-101): draw the shorts line parallel
/// to the body-rise line at the required depth; keep the front hem straight;
/// curve the back hemline downwards 1 cm.
///
/// App-specific digital rule: the back 1 cm lowering is represented by the
/// confirmed symmetric parabola helper, with unchanged side/inseam endpoints
/// and the midpoint exactly 1 cm lower in the app coordinate system.
class TrouserShortsGeometry {
  final double shortsDepthY;
  final PatternPoint frontSideHem;
  final PatternPoint frontInseamHem;
  final PatternPoint backSideHem;
  final PatternPoint backInseamHem;
  final LineSegment frontHem;
  final CubicBezierCurve backHem;

  const TrouserShortsGeometry({
    required this.shortsDepthY,
    required this.frontSideHem,
    required this.frontInseamHem,
    required this.backSideHem,
    required this.backInseamHem,
    required this.frontHem,
    required this.backHem,
  });
}

class TrouserShortsGeometryBuilder {
  final TrouserCurveBuilder curves;
  final HorizontalCurveIntersection intersections;

  const TrouserShortsGeometryBuilder({
    this.curves = const TrouserCurveBuilder(),
    this.intersections = const HorizontalCurveIntersection(),
  });

  TrouserShortsGeometry build({
    required TrouserReferenceDraft draft,
    required double shortsDepthY,
  }) {
    if (!shortsDepthY.isFinite) {
      throw ArgumentError('shortsDepthY must be finite.');
    }

    final frontSide = curves.frontSideSeam(
      p11: draft[11],
      p8: draft[8],
      p13: draft[13],
      p12: draft[12],
    );
    final backSide = curves.backSideSeam(
      p22: draft[22],
      p25: draft[25],
      p27: draft[27],
      p26: draft[26],
    );
    final frontInseam = curves.inwardMidpointCurve(
      start: draft[9],
      end: draft[15],
      depth: 0.75,
    );
    final backInseam = curves.inwardMidpointCurve(
      start: draft[24],
      end: draft[29],
      depth: 1.25,
    );

    final frontSideHem = intersections.singleIntersection(
      frontSide.segments,
      shortsDepthY,
    );
    final frontInseamHem = _intersectInseam(
      upperCurve: frontInseam,
      lowerEnd: draft[14],
      targetY: shortsDepthY,
      name: 'front inseam',
    );
    final backSideHem = intersections.singleIntersection(
      backSide.segments,
      shortsDepthY,
    );
    final backInseamHem = _intersectInseam(
      upperCurve: backInseam,
      lowerEnd: draft[28],
      targetY: shortsDepthY,
      name: 'back inseam',
    );

    final frontHem = LineSegment(frontInseamHem, frontSideHem);

    final backMidpoint = PatternPoint(
      (backInseamHem.x + backSideHem.x) / 2.0,
      shortsDepthY + 1.0,
    );
    final backHem = curves.symmetricHemParabola(
      left: backInseamHem.x <= backSideHem.x ? backInseamHem : backSideHem,
      center: backMidpoint,
      right: backInseamHem.x <= backSideHem.x ? backSideHem : backInseamHem,
    );

    return TrouserShortsGeometry(
      shortsDepthY: shortsDepthY,
      frontSideHem: frontSideHem,
      frontInseamHem: frontInseamHem,
      backSideHem: backSideHem,
      backInseamHem: backInseamHem,
      frontHem: frontHem,
      backHem: backHem,
    );
  }

  PatternPoint _intersectInseam({
    required CubicBezierCurve upperCurve,
    required PatternPoint lowerEnd,
    required double targetY,
    required String name,
  }) {
    final upperHits = intersections.detailedIntersections(
      [upperCurve],
      targetY,
    );
    if (upperHits.length == 1) {
      return upperHits.single.point;
    }
    if (upperHits.length > 1) {
      throw StateError(
        'Expected at most one horizontal intersection on $name upper curve, '
        'found ${upperHits.length}.',
      );
    }

    final start = upperCurve.end;
    final dy = lowerEnd.y - start.y;
    const tolerance = 1e-9;
    if (dy.abs() <= tolerance) {
      throw StateError('$name lower segment is horizontal or degenerate.');
    }

    final t = (targetY - start.y) / dy;
    if (t < -tolerance || t > 1.0 + tolerance) {
      throw StateError('No horizontal intersection found on confirmed $name.');
    }
    final clampedT = t.clamp(0.0, 1.0).toDouble();
    return PatternPoint(
      start.x + (lowerEnd.x - start.x) * clampedT,
      start.y + (lowerEnd.y - start.y) * clampedT,
    );
  }
}
