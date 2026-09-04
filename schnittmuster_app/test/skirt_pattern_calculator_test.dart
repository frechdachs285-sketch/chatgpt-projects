import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';

void main() {
  test('Rock v1 Kontrollmasse erzeugen gueltige Schnittteile', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );

    expect(result.isValid, isTrue);
    expect(result.back, isNotNull);
    expect(result.front, isNotNull);

    final back = result.back!;
    final front = result.front!;

    expect(back.points['P7']!.x, closeTo(26.5, 0.0001));
    expect(back.points['P10']!.x, closeTo(23.25, 0.0001));
    expect(back.points['P10']!.y, closeTo(-1.25, 0.0001));
    expect(front.points['P16']!.x, closeTo(30.25, 0.0001));
    expect(front.points['P16']!.y, closeTo(-1.25, 0.0001));

    expect(back.points['P11']!.distanceTo(back.points['P13']!), closeTo(14.0, 0.0001));
    expect(back.points['P12']!.distanceTo(back.points['P14']!), closeTo(12.5, 0.0001));
    expect(front.points['P17']!.distanceTo(front.points['P18']!), closeTo(10.0, 0.0001));
  });

  test('Ungueltige Masse werden abgewiesen', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 61, skirtLength: 60),
      const ConstructionValues(),
    );

    expect(result.isValid, isFalse);
    expect(result.errors, isNotEmpty);
  });
}
