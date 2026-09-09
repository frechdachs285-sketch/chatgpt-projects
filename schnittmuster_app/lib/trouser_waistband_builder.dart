import 'pattern_models.dart';
import 'trouser_pattern_calculator.dart';
import 'trouser_waist_length.dart';
import 'trouser_waistband.dart';

/// Digital straight waistband for Hose v1.
///
/// Confirmed rules used here:
/// - finished width: 4.0 cm (Hose-v1 decision)
/// - cut width before seam allowance: 8.0 cm
/// - the trouser waistline contains 1.0 cm ease and is eased onto the waistband
/// - waistband length therefore equals the entered waist measurement exactly
/// - 4.0 cm underwrap/extension
/// - centre-back, side-seam and centre-front positions are marked
/// - fold line lies halfway across the 8.0 cm strip
///
/// No waistband seam allowance is added here because that value has not yet
/// been separately confirmed for Hose v1.
class TrouserWaistbandBuilder {
  static const double trouserWaistEaseCm = 1.0;
  static const double _toleranceCm = 1e-9;

  final TrouserWaistLengthCalculator waistLengths;

  const TrouserWaistbandBuilder({
    this.waistLengths = const TrouserWaistLengthCalculator(),
  });

  PatternPiece build({
    required TrouserReferenceDraft draft,
    required TrouserMeasurements measurements,
  }) {
    final lengths = waistLengths.calculate(draft);
    final expectedTrouserWaist = measurements.waist + trouserWaistEaseCm;

    if ((lengths.fullGarmentCm - expectedTrouserWaist).abs() > _toleranceCm) {
      throw StateError(
        'Finished trouser waist must equal waist measurement plus 1.0 cm ease.',
      );
    }

    final waistband = measurements.waist;
    final quarter = waistband / 4.0;
    final total = waistband + TrouserWaistbandSettings.underlapCm;
    const height = TrouserWaistbandSettings.cutWidthWithoutSeamAllowanceCm;
    const foldY = TrouserWaistbandSettings.finishedWidthCm;

    // The four trouser waist sections each contain 0.25 cm ease and are
    // eased to the quarter-waist marks on this one-piece straight waistband.
    final leftCfX = 0.0;
    final leftSideX = quarter;
    final cbX = quarter * 2.0;
    final rightSideX = quarter * 3.0;
    final rightCfX = waistband;
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
