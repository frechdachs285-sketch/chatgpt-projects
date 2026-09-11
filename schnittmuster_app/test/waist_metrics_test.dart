import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';
import 'package:schnittmuster_app/waist_metrics.dart';

void main() {
  test('Rock v1 Netto-Taillenprojektion entspricht 76 + 1 cm', () {
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

    final metrics = const WaistConstructionMetricsCalculator().calculate(
      measurements: measurements,
      construction: construction,
      back: result.back!,
      front: result.front!,
    );

    expect(metrics.projectedBackWaist, closeTo(23.25, 0.000001));
    expect(metrics.projectedFrontWaist, closeTo(21.25, 0.000001));
    expect(metrics.dartIntake, closeTo(6.0, 0.000001));
    expect(metrics.targetHalfWaist, closeTo(38.5, 0.000001));
    expect(metrics.netProjectedWaist, closeTo(38.5, 0.000001));
    expect(metrics.matchesTarget(), isTrue);
  });
}
