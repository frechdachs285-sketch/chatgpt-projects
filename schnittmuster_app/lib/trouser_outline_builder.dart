import 'pattern_geometry.dart';
import 'pattern_models.dart';
import 'trouser_curve_geometry.dart';
import 'trouser_pattern_calculator.dart';
import 'trouser_size_rules.dart';

/// Builds only contour sections whose Hose-v1 geometry is already fixed and
/// tested. No new construction values are introduced here.
class TrouserOutlineBuilder {
  final TrouserCurveBuilder curves;

  const TrouserOutlineBuilder({this.curves = const TrouserCurveBuilder()});

  /// Closed confirmed front contour. Size 14 remains the Hose-v1 reference.
  PatternPath frontLowerContour(
    TrouserReferenceDraft d, {
    int sizeCode = 14,
  }) {
    final sizeRules = TrouserSizeRules.forSizeCode(sizeCode);
    final side = curves.frontSideSeam(
      p11: d[11],
      p8: d[8],
      p13: d[13],
      p12: d[12],
    );
    final hem = curves.frontHem(p14: d[14], p3: d[3], p12: d[12]);
    final upperInseam = curves.inwardMidpointCurve(
      start: d[9],
      end: d[15],
      depth: 0.75,
    );
    final frontCrotch = curves.naturalSplineThrough([
      d[6],
      curves.frontCrotchGuide(
        d[5],
        distanceCm: sizeRules.frontCrotchGuideCm,
      ),
      d[9],
    ]);

    return PatternPath([
      ...side.segments.map((curve) => _segment(curve, 'front_side_seam')),
      _segment(_reverse(hem), 'front_hem'),
      LineSegment(d[14], d[15]),
      _segment(_reverse(upperInseam), 'front_inseam'),
      ...frontCrotch.segments.reversed
          .map((curve) => _segment(_reverse(curve), 'front_crotch')),
      LineSegment(d[6], d[10]),
      LineSegment(d[10], d[11]),
    ]);
  }

  /// Closed confirmed back contour. Size 14 remains the Hose-v1 reference.
  PatternPath backLowerContour(
    TrouserReferenceDraft d, {
    int sizeCode = 14,
  }) {
    final sizeRules = TrouserSizeRules.forSizeCode(sizeCode);
    final side = curves.backSideSeam(
      p22: d[22],
      p25: d[25],
      p27: d[27],
      p26: d[26],
    );
    final hem = curves.backHem(p28: d[28], p3: d[3], p26: d[26]);
    final upperInseam = curves.inwardMidpointCurve(
      start: d[24],
      end: d[29],
      depth: 1.25,
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

    return PatternPath([
      ...side.segments.map((curve) => _segment(curve, 'back_side_seam')),
      _segment(_reverse(hem), 'back_hem'),
      LineSegment(d[28], d[29]),
      _segment(_reverse(upperInseam), 'back_inseam'),
      ...backCrotch.segments.reversed
          .map((curve) => _segment(_reverse(curve), 'back_crotch')),
      LineSegment(d[21], d[22]),
    ]);
  }

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
