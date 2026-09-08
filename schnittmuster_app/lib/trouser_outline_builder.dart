import 'pattern_geometry.dart';
import 'pattern_models.dart';
import 'trouser_curve_geometry.dart';
import 'trouser_pattern_calculator.dart';

/// Builds only contour sections whose Hose-v1 geometry is already fixed and
/// tested. No new construction values are introduced here.
class TrouserOutlineBuilder {
  final TrouserCurveBuilder curves;

  const TrouserOutlineBuilder({this.curves = const TrouserCurveBuilder()});

  /// Closed confirmed front contour:
  /// P11..P12 side seam -> reversed hem P12..P14 -> P14-P15 ->
  /// reversed 0.75 cm inseam P15..P9 -> reversed crotch P9..P6 ->
  /// straight Aldrich upper lines P6-P10-P11.
  PatternPath frontLowerContour(TrouserReferenceDraft d) {
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
      curves.frontCrotchGuide(d[5]),
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

  /// Closed confirmed back contour:
  /// P22..P26 side seam -> reversed hem P26..P28 -> P28-P29 ->
  /// reversed 1.25 cm inseam P29..P24 -> reversed crotch P24..P21 ->
  /// straight Aldrich upper line P21-P22.
  PatternPath backLowerContour(TrouserReferenceDraft d) {
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
      curves.backCrotchGuide(d[16]),
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
