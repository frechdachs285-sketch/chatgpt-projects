import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';
import 'package:schnittmuster_app/waist_correction_distribution.dart';
import 'package:schnittmuster_app/waist_seam_length.dart';
import 'package:schnittmuster_app/waist_side_point_correction.dart';

void main() {
  test('Minimale Seitenpunktkorrektur trifft 77 cm ohne Abnaeher zu aendern', () {
    const measurements = Measurements(
      waist: 76,
      hip: 100,
      hipDepth: 21,
      skirtLength: 60,
    );
    const construction = ConstructionValues();

    final result = SkirtPatternCalculator().calculate(
      measurements,
      construction,
    );

    expect(result.isValid, isTrue);

    final metrics = const WaistSeamLengthCalculator().calculate(
      measurements: measurements,
      construction: construction,
      back: result.back!,
      front: result.front!,
    );

    final distribution = const WaistCorrectionDistributor().distribute(
      metrics: metrics,
      backDartIntake: construction.backDart1Width + construction.backDart2Width,
      frontDartIntake: construction.frontDartWidth,
    );

    const corrector = WaistSidePointCorrector();
    final back = corrector.correct(
      centerPoint: result.back!.points['P1']!,
      sidePoint: result.back!.points['P10']!,
      lengthReduction: distribution.backCorrection,
    );
    final front = corrector.correct(
      centerPoint: result.front!.points['P2']!,
      sidePoint: result.front!.points['P16']!,
      lengthReduction: distribution.frontCorrection,
    );

    expect(back.correctedPoint.y, closeTo(-1.25, 0.000001));
    expect(front.correctedPoint.y, closeTo(-1.25, 0.000001));
    expect(back.horizontalShift, closeTo(0.0352034, 0.000001));
    expect(front.horizontalShift, closeTo(0.0352192, 0.000001));

    final correctedHalfWaist =
        back.targetLength + front.targetLength - metrics.dartIntake;

    expect(correctedHalfWaist, closeTo(38.5, 0.000001));
    expect(correctedHalfWaist * 2, closeTo(77.0, 0.000001));
  });
}
