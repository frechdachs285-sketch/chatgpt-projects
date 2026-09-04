import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';
import 'package:schnittmuster_app/waist_anchor_correction_solver.dart';

void main() {
  test('korrigiert Ruecken-Seitenpunkt minimal auf 19,25 cm Pflichtpunkt-Strecke', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );
    final back = result.back!;

    final correction = const WaistAnchorCorrectionSolver().solve(
      centerPoint: back.points['P1']!,
      sidePoint: back.points['P10']!,
      dartsFromCenterToSide: back.darts,
      targetLength: 19.25,
    );

    expect(correction.correctedMinimumLength, closeTo(19.25, 0.000001));
    expect(correction.correctedSidePoint.y, equals(back.points['P10']!.y));
    expect(correction.correctedSidePoint.x, lessThan(back.points['P10']!.x));
    expect(correction.horizontalShift, closeTo(0.03362664, 0.00001));
  });

  test('korrigiert Vorder-Seitenpunkt minimal auf 19,25 cm Pflichtpunkt-Strecke', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );
    final front = result.front!;

    final correction = const WaistAnchorCorrectionSolver().solve(
      centerPoint: front.points['P2']!,
      sidePoint: front.points['P16']!,
      dartsFromCenterToSide: front.darts,
      targetLength: 19.25,
    );

    expect(correction.correctedMinimumLength, closeTo(19.25, 0.000001));
    expect(correction.correctedSidePoint.y, equals(front.points['P16']!.y));
    expect(correction.correctedSidePoint.x, greaterThan(front.points['P16']!.x));
    expect(correction.horizontalShift, closeTo(0.03679663, 0.00001));
  });

  test('beide korrigierten Pflichtpunkt-Strecken ergeben 38,5 cm', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );
    final back = result.back!;
    final front = result.front!;
    const solver = WaistAnchorCorrectionSolver();

    final backCorrection = solver.solve(
      centerPoint: back.points['P1']!,
      sidePoint: back.points['P10']!,
      dartsFromCenterToSide: back.darts,
      targetLength: 19.25,
    );
    final frontCorrection = solver.solve(
      centerPoint: front.points['P2']!,
      sidePoint: front.points['P16']!,
      dartsFromCenterToSide: front.darts,
      targetLength: 19.25,
    );

    expect(
      backCorrection.correctedMinimumLength + frontCorrection.correctedMinimumLength,
      closeTo(38.5, 0.000001),
    );
  });
}
