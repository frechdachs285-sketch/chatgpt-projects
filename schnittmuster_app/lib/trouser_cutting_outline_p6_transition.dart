import 'pattern_models.dart';
import 'trouser_cutting_outline_builder.dart';

extension TrouserFrontP6CuttingTransition on TrouserCuttingOutlineBuilder {
  /// Joins the final front crotch curve at P6 to the following P6-P10 line.
  /// Both parts use the normal allowance. The corner is the intersection of
  /// the exact offset curve-end tangent and the exact offset straight line;
  /// no radius or additional construction value is introduced.
  PatternPoint frontCrotchTopTransition(
    TrouserOffsetPart crotchPart,
    TrouserOffsetPart topPart,
  ) {
    final crotch = crotchPart.source;
    if (crotch is! BezierSegment ||
        crotch.role != 'front_crotch' ||
        topPart.source is! LineSegment) {
      throw ArgumentError(
        'frontCrotchTopTransition requires front crotch curve first and P6-P10 line second.',
      );
    }
    if ((crotchPart.allowanceCm - topPart.allowanceCm).abs() > 1e-12) {
      throw ArgumentError(
        'Front crotch and P6-P10 must use the same seam allowance.',
      );
    }
    if (crotchPart.points.length < 2 || topPart.points.length != 2) {
      throw StateError('Front P6 offset parts do not contain enough points.');
    }

    final tangent = crotch.end - crotch.control2;
    final tangentLengthSquared =
        tangent.x * tangent.x + tangent.y * tangent.y;
    if (tangentLengthSquared <= 1e-24) {
      throw StateError('Front crotch Bezier has zero end tangent at P6.');
    }

    // adaptiveBezierOffset stores the exact normal offset at t=1 as its
    // final point. Use the exact source end-tangent direction rather than a
    // polyline secant.
    final offsetEnd = crotchPart.points.last;
    final crotchTangent = LineSegment(offsetEnd, offsetEnd + tangent);
    final topOffsetLine = LineSegment(topPart.points[0], topPart.points[1]);
    return geometry.intersectLines(crotchTangent, topOffsetLine);
  }
}
