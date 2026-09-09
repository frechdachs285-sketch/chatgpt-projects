import 'pattern_models.dart';
import 'trouser_cutting_outline_builder.dart';

extension TrouserBackP21CuttingTransition on TrouserCuttingOutlineBuilder {
  /// Joins the final back crotch offset to the P21-P22 waist offset.
  /// The waist offset is treated as an infinite line and the accepted crotch
  /// offset remains finite. No radius or additional construction value is
  /// introduced.
  PatternPoint backP21Transition(
    TrouserOffsetPart crotchPart,
    TrouserOffsetPart waistPart,
  ) {
    final crotch = crotchPart.source;
    final waist = waistPart.source;
    if (crotch is! BezierSegment ||
        crotch.role != 'back_crotch' ||
        waist is! LineSegment) {
      throw ArgumentError(
        'backP21Transition requires back crotch curve first and P21-P22 waist line second.',
      );
    }
    if (crotchPart.points.length < 2 || waistPart.points.length != 2) {
      throw StateError('Back P21 offset parts do not contain enough points.');
    }
    if (crotch.end.distanceTo(waist.start) > 1e-9) {
      throw ArgumentError('Back crotch and P21-P22 must meet at P21.');
    }

    return curveLineTransition(crotchPart, waistPart);
  }
}
