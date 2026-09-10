import 'horizontal_curve_intersection.dart';
import 'pattern_geometry.dart';
import 'pattern_models.dart';
import 'trouser_curve_geometry.dart';
import 'trouser_pattern_calculator.dart';
import 'trouser_shorts_geometry.dart';
import 'trouser_size_rules.dart';

/// Builds true closed Tailored-Shorts seam outlines from the already
/// confirmed Hose-v1 trouser curves.
///
/// No new construction measurements are introduced here. The selected
/// shorts depth is supplied by the caller. The front hem is straight; the
/// back hem uses the confirmed 1 cm symmetric-parabola digital rule from
/// [TrouserShortsGeometryBuilder].
class TrouserShortsOutlineBuilder {
  final TrouserCurveBuilder curves;
  final HorizontalCurveIntersection intersections;
  final TrouserShortsGeometryBuilder shortsGeometry;

  const TrouserShortsOutlineBuilder({
    this.curves = const TrouserCurveBuilder(),
    this.intersections = const HorizontalCurveIntersection(),
    this.shortsGeometry = const TrouserShortsGeometryBuilder(),
  });

  PatternPath front(
    TrouserReferenceDraft d, {
    required double shortsDepthY,
    int sizeCode = 14,
  }) {
    final sizeRules = TrouserSizeRules.forSizeCode(sizeCode);
    final side = curves.frontSideSeam(
      p11: d[11],
      p8: d[8],
      p13: d[13],
      p12: d[12],
    );
    final inseam = curves.inwardMidpointCurve(
      start: d[9],
      end: d[15],
      depth: 0.75,
    );
    final geometry = shortsGeometry.build(
      draft: d,
      shortsDepthY: shortsDepthY,
    );
    final sideHit = intersections.singleDetailedIntersection(
      side.segments,
      shortsDepthY,
    );
    final frontCrotch = curves.naturalSplineThrough([
      d[6],
      curves.frontCrotchGuide(
        d[5],
        distanceCm: sizeRules.frontCrotchGuideCm,
      ),
      d[9],
    ]);

    final sidePrefix = _prefixThroughHit(side.segments, sideHit);
    final reversedInseam = _reversedInseamToHem(
      inseam: inseam,
      lowerEnd: d[14],
      hemPoint: geometry.frontInseamHem,
      targetY: shortsDepthY,
      role: 'front_inseam',
    );

    return PatternPath([
      ...sidePrefix.map((curve) => _segment(curve, 'front_side_seam')),
      LineSegment(geometry.frontSideHem, geometry.frontInseamHem),
      ...reversedInseam,
      ...frontCrotch.segments.reversed
          .map((curve) => _segment(_reverse(curve), 'front_crotch')),
      LineSegment(d[6], d[10]),
      LineSegment(d[10], d[11]),
    ]);
  }

  PatternPath back(
    TrouserReferenceDraft d, {
    required double shortsDepthY,
    int sizeCode = 14,
  }) {
    final sizeRules = TrouserSizeRules.forSizeCode(sizeCode);
    final side = curves.backSideSeam(
      p22: d[22],
      p25: d[25],
      p27: d[27],
      p26: d[26],
    );
    final inseam = curves.inwardMidpointCurve(
      start: d[24],
      end: d[29],
      depth: 1.25,
    );
    final geometry = shortsGeometry.build(
      draft: d,
      shortsDepthY: shortsDepthY,
    );
    final sideHit = intersections.singleDetailedIntersection(
      side.segments,
      shortsDepthY,
    );
    final backCrotch = curves.naturalSplineThrough([
      d[21],
      d[19],
      curves.backCrotchGuide(
        d[16],
        distanceCm: sizeRules.backCrotchGuideCm,
      ),
      d[24],
    ]);

    final sidePrefix = _prefixThroughHit(side.segments, sideHit);
    final reversedInseam = _reversedInseamToHem(
      inseam: inseam,
      lowerEnd: d[28],
      hemPoint: geometry.backInseamHem,
      targetY: shortsDepthY,
      role: 'back_inseam',
    );

    return PatternPath([
      ...sidePrefix.map((curve) => _segment(curve, 'back_side_seam')),
      _segment(_reverse(geometry.backHem), 'back_hem'),
      ...reversedInseam,
      ...backCrotch.segments.reversed
          .map((curve) => _segment(_reverse(curve), 'back_crotch')),
      LineSegment(d[21], d[22]),
    ]);
  }

  List<PathSegment> _reversedInseamToHem({
    required CubicBezierCurve inseam,
    required PatternPoint lowerEnd,
    required PatternPoint hemPoint,
    required double targetY,
    required String role,
  }) {
    final hits = intersections.detailedIntersections([inseam], targetY);
    if (hits.length == 1) {
      final prefix = _prefixThroughHit([inseam], hits.single);
      return [
        ...prefix.reversed.map((curve) => _segment(_reverse(curve), role)),
      ];
    }
    if (hits.length > 1) {
      throw StateError(
        'Expected at most one horizontal intersection on $role upper curve, '
        'found ${hits.length}.',
      );
    }

    const tolerance = 1e-9;
    final minY = inseam.end.y < lowerEnd.y ? inseam.end.y : lowerEnd.y;
    final maxY = inseam.end.y > lowerEnd.y ? inseam.end.y : lowerEnd.y;
    if (targetY < minY - tolerance || targetY > maxY + tolerance) {
      throw StateError('No horizontal intersection found on confirmed $role.');
    }

    return [
      if (hemPoint.distanceTo(inseam.end) > tolerance)
        LineSegment(hemPoint, inseam.end),
      _segment(_reverse(inseam), role),
    ];
  }

  List<CubicBezierCurve> _prefixThroughHit(
    List<CubicBezierCurve> source,
    HorizontalCurveHit hit,
  ) {
    final result = <CubicBezierCurve>[
      for (var i = 0; i < hit.curveIndex; i++) source[i],
    ];
    if (hit.t > 1e-12) {
      result.add(_leftPart(hit.curve, hit.t));
    }
    return result;
  }

  CubicBezierCurve _leftPart(CubicBezierCurve curve, double t) {
    if (t <= 0.0 || t > 1.0) {
      throw ArgumentError('Bezier split t must be in (0, 1].');
    }
    if (t == 1.0) return curve;

    final p01 = _lerp(curve.start, curve.control1, t);
    final p12 = _lerp(curve.control1, curve.control2, t);
    final p23 = _lerp(curve.control2, curve.end, t);
    final p012 = _lerp(p01, p12, t);
    final p123 = _lerp(p12, p23, t);
    final p = _lerp(p012, p123, t);

    return CubicBezierCurve(
      start: curve.start,
      control1: p01,
      control2: p012,
      end: p,
    );
  }

  PatternPoint _lerp(PatternPoint a, PatternPoint b, double t) => PatternPoint(
        a.x + (b.x - a.x) * t,
        a.y + (b.y - a.y) * t,
      );

  BezierSegment _segment(CubicBezierCurve curve, String role) => BezierSegment(
        start: curve.start,
        control1: curve.control1,
        control2: curve.control2,
        end: curve.end,
        role: role,
      );

  CubicBezierCurve _reverse(CubicBezierCurve curve) => CubicBezierCurve(
        start: curve.end,
        control1: curve.control2,
        control2: curve.control1,
        end: curve.start,
      );
}
