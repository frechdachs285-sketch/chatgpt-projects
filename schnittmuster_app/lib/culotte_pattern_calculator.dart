import 'dart:math' as math;

import 'culotte_measurements.dart';
import 'pattern_models.dart';

/// Calculates the source-confirmed Aldrich construction points for Culotte v1.
///
/// Source basis decision for Culotte v1:
/// Aldrich's Culotte instruction starts from the straight-skirt pattern.
/// The Straight Skirt example explicitly permits a completely straight skirt
/// without the optional back swing and without the 2.5 cm hem flare. Culotte
/// v1 uses that permitted straight version, matching the Culotte drawing where
/// the back points 0-1-2 and front points 5-6-7 lie on straight vertical
/// centre lines. Therefore no 1 cm back swing and no 2.5 cm side-seam hem
/// flare are introduced here.
///
/// Aldrich-derived rules:
/// - C0-C1 = body rise + 1.5 cm
/// - C0-C2 = finished length
/// - C1-C3 = 1/2 of C0-C1 + 1 cm
/// - C1-C4 = 1/8 hip + 2 cm
/// - C5-C6 = body rise + 1.5 cm
/// - C5-C7 = finished length
/// - C8 is halfway between C5 and C6
/// - C6-C9 = 1/8 hip - 2 cm
///
/// App-specific digitization rule:
/// the 3 cm / 4 cm curve guide is placed on the angle bisector of the
/// illustrated right angle (45 degrees in this local coordinate system).
class CulottePatternCalculator {
  const CulottePatternCalculator();

  Map<String, PatternPoint> calculatePoints(CulotteMeasurements m) {
    _validate(m);

    final riseLine = m.bodyRise + 1.5;

    // Back centre remains vertical by the documented straight-skirt choice.
    final c0 = const PatternPoint(0.0, 0.0);
    final c1 = PatternPoint(0.0, riseLine);
    final c2 = PatternPoint(0.0, m.finishedLength);
    final c1ToC3 = riseLine / 2.0 + 1.0;
    final c3 = PatternPoint(0.0, riseLine - c1ToC3);
    final c4 = PatternPoint(-(m.hip / 8.0 + 2.0), riseLine);

    // Front centre remains vertical as illustrated by Aldrich.
    final c5 = const PatternPoint(0.0, 0.0);
    final c6 = PatternPoint(0.0, riseLine);
    final c7 = PatternPoint(0.0, m.finishedLength);
    final c8 = PatternPoint(0.0, riseLine / 2.0);
    final c9 = PatternPoint(m.hip / 8.0 - 2.0, riseLine);

    // Digital app rule only: 45-degree angle-bisector guides.
    final backGuideOffset = 3.0 / math.sqrt(2.0);
    final frontGuideOffset = 4.0 / math.sqrt(2.0);
    final h3 = PatternPoint(c1.x - backGuideOffset, c1.y - backGuideOffset);
    final h4 = PatternPoint(c6.x + frontGuideOffset, c6.y - frontGuideOffset);

    return <String, PatternPoint>{
      'C0': c0,
      'C1': c1,
      'C2': c2,
      'C3': c3,
      'C4': c4,
      'C5': c5,
      'C6': c6,
      'C7': c7,
      'C8': c8,
      'C9': c9,
      'H3': h3,
      'H4': h4,
    };
  }

  void _validate(CulotteMeasurements m) {
    final values = <double>[
      m.waist,
      m.hip,
      m.hipDepth,
      m.finishedLength,
      m.bodyRise,
    ];
    if (values.any((value) => !value.isFinite || value <= 0.0)) {
      throw ArgumentError('Alle Culotte-Masse muessen endlich und groesser als 0 sein.');
    }

    final frontExtension = m.hip / 8.0 - 2.0;
    if (frontExtension <= 0.0) {
      throw ArgumentError('Die vordere Schrittverlaengerung muss groesser als 0 sein.');
    }
  }
}
