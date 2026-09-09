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
/// - waistband seam allowance: 1.5 cm when seam allowance is enabled
///
/// The 1.5 cm waistband seam allowance is an app-specific digital rule,
/// not an Aldrich rule. The confirmed waistband seam line remains unchanged.
class TrouserWaistbandBuilder {
  static const double trouserWaistEaseCm = 1.0;
  static const double waistbandSeamAllowanceCm = 1.5;
  static const double _toleranceCm = 1e-9;

  final TrouserWaistLengthCalculator waistLengths;

  const TrouserWaistbandBuilder({
    this.waistLengths = const TrouserWaistLengthCalculator(),
  });

  PatternPiece build({
    required TrouserReferenceDraft draft,
    required TrouserMeasurements measurements,
    int sizeCode = 14,
    bool seamAllowanceEnabled = false,
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

    final cuttingOutline = seamAllowanceEnabled
        ? PatternPath([
            LineSegment(
              PatternPoint(p0.x - waistbandSeamAllowanceCm,
                  p0.y - waistbandSeamAllowanceCm),
              PatternPoint(p1.x + waistbandSeamAllowanceCm,
                  p1.y - waistbandSeamAllowanceCm),
            ),
            LineSegment(
              PatternPoint(p1.x + waistbandSeamAllowanceCm,
                  p1.y - waistbandSeamAllowanceCm),
              PatternPoint(p2.x + waistbandSeamAllowanceCm,
                  p2.y + waistbandSeamAllowanceCm),
            ),
            LineSegment(
              PatternPoint(p2.x + waistbandSeamAllowanceCm,
                  p2.y + waistbandSeamAllowanceCm),
              PatternPoint(p3.x - waistbandSeamAllowanceCm,
                  p3.y + waistbandSeamAllowanceCm),
            ),
            LineSegment(
              PatternPoint(p3.x - waistbandSeamAllowanceCm,
                  p3.y + waistbandSeamAllowanceCm),
              PatternPoint(p0.x - waistbandSeamAllowanceCm,
                  p0.y - waistbandSeamAllowanceCm),
            ),
          ])
        : null;

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
      cuttingOutline: cuttingOutline,
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
          position: PatternPoint(total / 2.0, foldY / 2.0),
          text: 'Gerader Bund - Größe $sizeCode',
        ),
      ],
    );
  }
}
