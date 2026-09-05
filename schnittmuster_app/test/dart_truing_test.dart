import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/dart_truing.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';

void main() {
  test('Alle drei Rock-v1-Abnaeher lassen sich exakt schliessen', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );

    expect(result.isValid, isTrue);

    const truer = DartTruer();
    final darts = <Dart>[
      ...result.back!.darts,
      ...result.front!.darts,
    ];

    expect(darts.length, 3);

    for (final dart in darts) {
      final trued = truer.close(dart);
      expect(trued.hasEqualLegLengths(), isTrue);
      expect(trued.isClosed(), isTrue);
      expect(trued.closureError, closeTo(0, 0.000001));
    }
  });

  test('Unsymmetrischer Abnaeher wird als ungleiche Schenkellaenge erkannt', () {
    const dart = Dart(
      center: PatternPoint(0, 0),
      apex: PatternPoint(0, 10),
      leg1: PatternPoint(-1, 0),
      leg2: PatternPoint(2, 0),
      width: 3,
      length: 10,
    );

    final trued = const DartTruer().close(dart);

    expect(trued.hasEqualLegLengths(), isFalse);
    expect(trued.isClosed(), isFalse);
  });
}
