import 'pattern_models.dart';
import 'trouser_cutting_outline_builder.dart';

extension TrouserFrontP10CuttingTransition on TrouserCuttingOutlineBuilder {
  /// Joins the front P6-P10 normal-allowance line to the P10-P11
  /// waist-allowance line at their exact infinite-line intersection.
  /// No radius or additional construction value is introduced.
  PatternPoint frontP10Transition(
    TrouserOffsetPart topPart,
    TrouserOffsetPart waistPart,
  ) {
    final top = topPart.source;
    final waist = waistPart.source;
    if (top is! LineSegment || waist is! LineSegment) {
      throw ArgumentError(
        'frontP10Transition requires P6-P10 line first and P10-P11 waist line second.',
      );
    }
    if (topPart.points.length != 2 || waistPart.points.length != 2) {
      throw StateError('Front P10 offset parts must each contain exactly two points.');
    }
    if (top.end.distanceTo(waist.start) > 1e-9) {
      throw ArgumentError('P6-P10 and P10-P11 must meet at P10.');
    }

    return lineLineTransition(topPart, waistPart);
  }
}
