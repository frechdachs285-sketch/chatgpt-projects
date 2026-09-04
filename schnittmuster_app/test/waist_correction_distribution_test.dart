import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';
import 'package:schnittmuster_app/waist_correction_distribution.dart';
import 'package:schnittmuster_app/waist_seam_length.dart';

void main() {
  test('Taillenkorrektur wird proportional zur Netto-Nahtlaenge verteilt', () {
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

    final backDartIntake = result.back!.darts
        .fold<double>(0, (sum, dart) => sum + dart.width);
    final frontDartIntake = result.front!.darts
        .fold<double>(0, (sum, dart) => sum + dart.width);

    final distribution = const WaistCorrectionDistributor().distribute(
      metrics: metrics,
      backDartIntake: backDartIntake,
      frontDartIntake: frontDartIntake,
    );

    expect(backDartIntake, closeTo(4.0, 0.000001));
    expect(frontDartIntake, closeTo(2.0, 0.000001));
    expect(distribution.backCorrection, closeTo(0.0351526, 0.000001));
    expect(distribution.frontCorrection, closeTo(0.0351583, 0.000001));
    expect(
      distribution.totalCorrection,
      closeTo(metrics.halfCorrectionRequired, 0.000001),
    );
  });
}
