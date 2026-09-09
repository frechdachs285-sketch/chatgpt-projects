import 'pattern_models.dart';
import 'trouser_pattern_calculator.dart';
import 'trouser_waist_length.dart';
import 'trouser_waistband.dart';

/// Digital straight waistband for Hose v1.
///
/// Confirmed rules used here:
/// - finished width: 4.0 cm (Hose-v1 decision)
/// - cut width before seam allowance: 8.0 cm
/// - waistband length follows the finished trouser waist after darts
/// - 4.0 cm underlap/extension
/// - centre-back, side-seam and centre-front positions are marked
/// - fold line lies halfway across the 8.0 cm strip
///
/// No waistband seam allowance is added here because that value has not yet
/// been separately confirmed for Hose v1.
class TrouserWaistbandBuilder {
  final TrouserWaistLengthCalculator waistLengths;

  const TrouserWaistbandBuilder({
    this.waistLengths = const TrouserWaistLengthCalculator(),
  });

  PatternPiece build(TrouserReferenceDraft draft) {
    final lengths = waistLengths.calculate(draft);
    final front = lengths.frontCm;
    final back = lengths.backCm;
    final garment = lengths.fullGarmentCm;
    final total = garment + TrouserWaistbandSettings.underlapCm;
    const height = TrouserWaistbandSettings.cutWidthWithoutSeamAllowanceCm;
    const foldY = TrouserWaistbandSettings.finishedWidthCm;

    // One-piece waistband sequence starting at centre front:
    // CF -> side -> CB -> side -> CF -> 4 cm extension.
    final leftCfX = 0.0;
    final leftSideX = front;
    final cbX = front + back;
    final rightSideX = front + 2.0 * back;
    final rightCfX = garment;
    final extensionEndX = total;

    final p0 = PatternPoint(leftCfX, 0.0);
    final p1 = PatternPoint(extensionEndX, 0.0);
    final p2 = PatternPoint(extensionEndX, height);
    final p3 = PatternPoint(leftCfX, height);

    return PatternPiece(
      id: 'trouser_waistband',
      name: 'Gerader Bund',
      points: Map.unmodifiable({
        'CF_LEFT': PatternPoint(leftCfX, foldY),
        'SIDE_LEFT': PatternPoint(leftSideX, foldY),
        'CB': PatternPoint(cbX, foldY),
        'SIDE_RIGHT': PatternPoint(rightSideX, foldY),
        'CF_RIGHT': PatternPoint(rightCfX, foldY),
        'EXTENSION_END': PatternPoint(extensionEndX, foldY),
      }),
      outline: PatternPath([
        LineSegment(p0, p1),
        LineSegment(p1, p2),
        LineSegment(p2, p3),
        LineSegment(p3, p0),
      ]),
      guideLines: [
        LineSegment(
          PatternPoint(leftCfX, foldY),
          PatternPoint(extensionEndX, foldY),
        ),
        LineSegment(
          PatternPoint(leftSideX, 0.0),
          PatternPoint(leftSideX, height),
        ),
        LineSegment(
          PatternPoint(cbX, 0.0),
          PatternPoint(cbX, height),
        ),
        LineSegment(
          PatternPoint(rightSideX, 0.0),
          PatternPoint(rightSideX, height),
        ),
        LineSegment(
          PatternPoint(rightCfX, 0.0),
          PatternPoint(rightCfX, height),
        ),
      ],
      labels: [
        PatternLabel(
          position: PatternPoint(total / 2.0, foldY),
          text: 'Gerader Bund',
        ),
      ],
    );
  }
}
