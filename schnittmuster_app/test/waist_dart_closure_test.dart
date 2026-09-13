import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';
import 'package:schnittmuster_app/waist_dart_closure.dart';

void main() {
  test('Rueckenteil schliesst beide Abnaeher sequentiell', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );

    expect(result.isValid, isTrue);

    final back = result.back!;
    final closure = const WaistDartClosure().close(
      sidePoint: back.points['P10']!,
      dartsFromCenterToSide: back.darts,
    );

    expect(closure.closureAngles.length, 2);
    expect(closure.closedSidePoint.x, closeTo(18.73925, 0.0001));
    expect(closure.closedSidePoint.y, closeTo(-3.84318, 0.0001));
    expect(
      back.points['P1']!.distanceTo(closure.closedSidePoint),
      closeTo(19.12928, 0.0001),
    );
  });

  test('Vorderteil schliesst den Abnaeher und transformiert P16', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );

    expect(result.isValid, isTrue);

    final front = result.front!;
    final closure = const WaistDartClosure().close(
      sidePoint: front.points['P16']!,
      dartsFromCenterToSide: front.darts,
    );

    expect(closure.closureAngles.length, 1);
    expect(closure.closedSidePoint.x, closeTo(32.66070, 0.0001));
    expect(closure.closedSidePoint.y, closeTo(-3.72482, 0.0001));
    expect(
      front.points['P2']!.distanceTo(closure.closedSidePoint),
      closeTo(19.20400, 0.0001),
    );
  });

  test('Ungleiche Abnaeher-Schenkel werden abgelehnt', () {
    const invalid = Dart(
      center: PatternPoint(0, 0),
      apex: PatternPoint(0, 10),
      leg1: PatternPoint(-1, 0),
      leg2: PatternPoint(2, 0),
      width: 3,
      length: 10,
    );

    expect(
      () => const WaistDartClosure().close(
        sidePoint: const PatternPoint(5, 0),
        dartsFromCenterToSide: const [invalid],
      ),
      throwsArgumentError,
    );
  });
}
