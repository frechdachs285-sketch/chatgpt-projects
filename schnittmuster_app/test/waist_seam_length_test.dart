import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';
import 'package:schnittmuster_app/waist_seam_length.dart';

void main() {
  test('Angehobene Taille zeigt den exakten Korrekturbedarf', () {
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

    expect(metrics.targetHalfWaist, closeTo(38.5, 0.000001));
    expect(metrics.dartIntake, closeTo(6.0, 0.000001));
    expect(metrics.netHalfWaist, closeTo(38.57031, 0.0001));
    expect(metrics.halfCorrectionRequired, closeTo(0.07031, 0.0001));
    expect(metrics.fullCorrectionRequired, closeTo(0.14062, 0.0001));
  });
}
