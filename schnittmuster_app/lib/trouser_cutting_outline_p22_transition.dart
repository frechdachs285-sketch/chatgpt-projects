import 'pattern_models.dart';
import 'trouser_cutting_outline_builder.dart';

extension TrouserBackP22CuttingTransition on TrouserCuttingOutlineBuilder {
  /// Joins the P21-P22 waist offset to the back side-seam offset at P22.
  /// The waist offset is treated as an infinite line and the accepted side
  /// seam offset remains finite. No radius or additional construction value
  /// is introduced.
  PatternPoint backP22Transition(
    TrouserOffsetPart waistPart,
    TrouserOffsetPart sidePart,
  ) {
    final waist = waistPart.source;
    final side = sidePart.source;
    if (waist is! LineSegment ||
        side is! BezierSegment ||
        side.role != 'back_side_seam') {
      throw ArgumentError(
        'backP22Transition requires P21-P22 waist line first and back side-seam curve second.',
      );
    }
    if (waistPart.points.length != 2 || sidePart.points.length < 2) {
      throw StateError('Back P22 offset parts do not contain enough points.');
    }
    if (waist.end.distanceTo(side.start) > 1e-9) {
      throw ArgumentError('P21-P22 and back side seam must meet at P22.');
    }

    return lineCurveTransition(waistPart, sidePart);
  }
}
