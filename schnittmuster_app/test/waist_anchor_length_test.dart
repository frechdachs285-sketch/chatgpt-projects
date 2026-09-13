import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';
import 'package:schnittmuster_app/waist_anchor_length.dart';
import 'package:schnittmuster_app/waist_dart_closure.dart';

void main() {
  test('unveraenderte geschlossene Taillenanker sind fuer 19,25 cm zu lang', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );

    final back = result.back!;
    final front = result.front!;
    final closure = const WaistDartClosure();
    final calculator = const WaistAnchorLengthCalculator();

    final backClosed = closure.close(
      sidePoint: back.points['P10']!,
      dartsFromCenterToSide: back.darts,
    );
    final frontClosed = closure.close(
      sidePoint: front.points['P16']!,
      dartsFromCenterToSide: front.darts,
    );

    final backMetrics = calculator.calculate(
      centerPoint: back.points['P1']!,
      closedDartMouths: backClosed.closedDartMouths,
      closedSidePoint: backClosed.closedSidePoint,
      targetLength: 19.25,
    );
    final frontMetrics = calculator.calculate(
      centerPoint: front.points['P2']!,
      closedDartMouths: frontClosed.closedDartMouths,
      closedSidePoint: frontClosed.closedSidePoint,
      targetLength: 19.25,
    );

    expect(backMetrics.minimumLength, closeTo(19.2835779, 0.000001));
    expect(frontMetrics.minimumLength, closeTo(19.2867330, 0.000001));
    expect(backMetrics.isFeasibleWithoutMovingAnchors, isFalse);
    expect(frontMetrics.isFeasibleWithoutMovingAnchors, isFalse);

    final fullExcess = 2 * (backMetrics.excess + frontMetrics.excess);
    expect(fullExcess, closeTo(0.1406217, 0.000001));
  });
}
