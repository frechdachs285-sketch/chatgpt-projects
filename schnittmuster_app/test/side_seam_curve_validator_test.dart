import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_geometry.dart';
import 'package:schnittmuster_app/pattern_models.dart';

void main() {
  test('Seitenkurven-Regeln werden mathematisch geprueft', () {
    const start = PatternPoint(0, 0);
    const end = PatternPoint(0, 10);

    // Neutrale Testkurve: keine Rockkonstruktion.
    const curve = CubicBezierCurve(
      start: start,
      control1: PatternPoint(1.125, 10 / 3),
      control2: PatternPoint(0, 20 / 3),
      end: end,
    );

    final result = const SideSeamCurveValidator().validate(
      curve: curve,
      expectedStart: start,
      expectedEnd: end,
      expectedMaxDeviation: 0.5,
    );

    expect(result.isValid, isTrue, reason: result.errors.join(' | '));
    expect(curve.pointAt(0).distanceTo(start), closeTo(0, 0.000001));
    expect(curve.pointAt(1).distanceTo(end), closeTo(0, 0.000001));
    expect(curve.hasVerticalEndTangent(), isTrue);
    expect(curve.maxDeviationFromChord(), closeTo(0.5, 0.002));
  });

  test('Falsche Endtangente wird erkannt', () {
    const curve = CubicBezierCurve(
      start: PatternPoint(0, 0),
      control1: PatternPoint(1.125, 10 / 3),
      control2: PatternPoint(1, 20 / 3),
      end: PatternPoint(0, 10),
    );

    final result = const SideSeamCurveValidator().validate(
      curve: curve,
      expectedStart: PatternPoint(0, 0),
      expectedEnd: PatternPoint(0, 10),
      expectedMaxDeviation: 0.5,
    );

    expect(result.isValid, isFalse);
    expect(result.errors, contains('Endtangente ist nicht vertikal.'));
  });

  test('Rock v1 Rueckenteil-Seitenkurve erfuellt die Digitalregel', () {
    const start = PatternPoint(23.25, -1.25); // P10
    const end = PatternPoint(26.5, 21); // P7

    final curve = const SideSeamCurveBuilder().build(
      start: start,
      end: end,
      maxDeviation: 0.5,
    );

    final result = const SideSeamCurveValidator().validate(
      curve: curve,
      expectedStart: start,
      expectedEnd: end,
      expectedMaxDeviation: 0.5,
    );

    expect(result.isValid, isTrue, reason: result.errors.join(' | '));
  });

  test('Rock v1 Vorderteil-Seitenkurve erfuellt die Digitalregel', () {
    const start = PatternPoint(30.25, -1.25); // P16
    const end = PatternPoint(26.5, 21); // P7

    final curve = const SideSeamCurveBuilder().build(
      start: start,
      end: end,
      maxDeviation: 0.5,
    );

    final result = const SideSeamCurveValidator().validate(
      curve: curve,
      expectedStart: start,
      expectedEnd: end,
      expectedMaxDeviation: 0.5,
    );

    expect(result.isValid, isTrue, reason: result.errors.join(' | '));
  });
}
