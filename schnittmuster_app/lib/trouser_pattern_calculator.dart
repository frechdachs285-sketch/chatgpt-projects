import 'dart:math' as math;

import 'pattern_models.dart';
import 'trouser_size_rules.dart';

/// Body and design values needed by the Aldrich 5th ed. classic tailored
/// trouser block. Units are centimetres.
class TrouserMeasurements {
  final double waist;
  final double hip;
  final double hipDepth;
  final double bodyRise;
  final double waistToFloor;
  final double trouserBottomWidth;
final double alternativeLegShapingCm;
  
  const TrouserMeasurements({
    required this.waist,
    required this.hip,
    required this.hipDepth,
    required this.bodyRise,
    required this.waistToFloor,
    required this.trouserBottomWidth,
    this.alternativeLegShapingCm = 0.0,
  });
}

class TrouserReferenceDraft {
  final Map<int, PatternPoint> points;

  const TrouserReferenceDraft(this.points);

  PatternPoint operator [](int number) => points[number]!;
}

/// Point construction for Winifred Aldrich, Metric Pattern Cutting for
/// Women's Wear, 5th ed. (2008), classic tailored trouser block, pp.100-101.
///
/// Coordinate system used by the app: x increases right, y increases down.
/// This class intentionally contains only the numbered construction points;
/// digital curve interpolation is kept separate.
class TrouserPatternCalculator {
  static TrouserReferenceDraft calculateReferencePoints(
    TrouserMeasurements m, {
    int sizeCode = 14,
  }) {
    _validate(m);
    final sizeRules = TrouserSizeRules.forSizeCode(sizeCode);

    final p = <int, PatternPoint>{};
    p[0] = const PatternPoint(0.0, 0.0);
    p[1] = PatternPoint(0.0, m.bodyRise);
    p[2] = PatternPoint(0.0, m.hipDepth);

    // Digital hem rule for Hose v1: lower P3 by exactly 1 cm while
    // keeping the Aldrich hem-edge points on the original waist-to-floor line.
    p[3] = PatternPoint(0.0, m.waistToFloor + 1.0);
    p[4] = PatternPoint(
      0.0,
      m.bodyRise + (m.waistToFloor - m.bodyRise) / 2.0 - 5.0,
    );

    final oneToFive = m.hip / 12.0 + 1.5;
    p[5] = PatternPoint(-oneToFive, p[1]!.y);
    p[6] = PatternPoint(p[5]!.x, p[2]!.y);
    p[7] = PatternPoint(p[5]!.x, 0.0);
    p[8] = PatternPoint(p[6]!.x + m.hip / 4.0 + 0.5, p[6]!.y);
    p[9] = PatternPoint(p[5]!.x - (m.hip / 16.0 + 0.5), p[5]!.y);
    p[10] = PatternPoint(p[7]!.x + 1.0, 0.0);
    p[11] = PatternPoint(p[10]!.x + m.waist / 4.0 + 2.25, 0.0);

    final halfBottomMinusHalf = m.trouserBottomWidth / 2.0 - 0.5;
    final aldRichHemY = m.waistToFloor;
    p[12] = PatternPoint(halfBottomMinusHalf, aldRichHemY);
    p[13] = PatternPoint(
      halfBottomMinusHalf + sizeRules.kneeOuterIncrementCm,
      p[4]!.y,
    );
    p[14] = PatternPoint(-halfBottomMinusHalf, aldRichHemY);
    p[15] = PatternPoint(-p[13]!.x, p[4]!.y);

    p[16] = PatternPoint(p[5]!.x + oneToFive / 4.0, p[5]!.y);
    p[17] = PatternPoint(p[16]!.x, p[2]!.y);
    p[18] = PatternPoint(p[16]!.x, 0.0);
    p[19] = PatternPoint(p[16]!.x, (p[16]!.y + p[18]!.y) / 2.0);
    p[20] = PatternPoint(p[18]!.x + 2.0, p[18]!.y);
    p[21] = PatternPoint(p[20]!.x, p[20]!.y - 2.0);

    final backWaistLength = m.waist / 4.0 + 4.25;
    final verticalToWaist = -p[21]!.y;
    final horizontal = math.sqrt(
      backWaistLength * backWaistLength - verticalToWaist * verticalToWaist,
    );
    p[22] = PatternPoint(p[21]!.x + horizontal, 0.0);

    final fiveToNine = p[5]!.distanceTo(p[9]!);
    p[23] = PatternPoint(p[9]!.x - fiveToNine / 2.0, p[9]!.y);
    p[24] = PatternPoint(p[23]!.x - 0.5, p[23]!.y);
    p[25] = PatternPoint(p[17]!.x + m.hip / 4.0 + 1.5, p[17]!.y);
    p[26] = PatternPoint(p[12]!.x + 1.0, p[12]!.y);
    p[27] = PatternPoint(p[13]!.x + 1.0, p[13]!.y);
    p[28] = PatternPoint(p[14]!.x - 1.0, p[14]!.y);
    p[29] = PatternPoint(p[15]!.x - 1.0, p[15]!.y);

    final waistVector = p[22]! - p[21]!;
    p[30] = p[21]! + waistVector * (1.0 / 3.0);
    p[31] = p[21]! + waistVector * (2.0 / 3.0);

    return TrouserReferenceDraft(Map.unmodifiable(p));
  }

  static void _validate(TrouserMeasurements m) {
    final values = <double>[
      m.waist,
      m.hip,
      m.hipDepth,
      m.bodyRise,
      m.waistToFloor,
      m.trouserBottomWidth,
    ];
    if (values.any((v) => !v.isFinite || v <= 0.0)) {
      throw ArgumentError('Trouser measurements must be finite and > 0.');
    }
    if (m.hipDepth >= m.waistToFloor || m.bodyRise >= m.waistToFloor) {
      throw ArgumentError('Hip depth and body rise must be below waist-to-floor.');
    }
  }
}
