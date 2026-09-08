import 'pattern_models.dart';
import 'trouser_cutting_outline_builder.dart';

extension TrouserFrontP11CuttingTransition on TrouserCuttingOutlineBuilder {
  /// Joins the front P10-P11 waist-allowance line to the front side-seam
  /// offset at P11. The waist offset is treated as an infinite line and the
  /// accepted side-seam offset remains finite. No radius or additional
  /// construction value is introduced.
  PatternPoint frontP11Transition(
    TrouserOffsetPart waistPart,
    TrouserOffsetPart sidePart,
  ) {
    final waist = waistPart.source;
    final side = sidePart.source;
    if (waist is! LineSegment ||
        side is! BezierSegment ||
        side.role != 'front_side_seam') {
      throw ArgumentError(
        'frontP11Transition requires P10-P11 waist line first and front side-seam curve second.',
      );
    }
    if (waistPart.points.length != 2 || sidePart.points.length < 2) {
      throw StateError('Front P11 offset parts do not contain enough points.');
    }
    if (waist.end.distanceTo(side.start) > 1e-9) {
      throw ArgumentError('P10-P11 and front side seam must meet at P11.');
    }

    return lineCurveTransition(waistPart, sidePart);
  }
}
