import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_geometry.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';
import 'package:schnittmuster_app/waist_curve_builder.dart';
import 'package:schnittmuster_app/waist_dart_closure.dart';

void main() {
  test('Rueckenteil-Taillenkurve trifft 19,25 cm auf geschlossener Geometrie', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );

    expect(result.isValid, isTrue);
    final back = result.back!;
    final p1 = back.points['P1']!;
    final p10 = back.points['P10']!;
    final p7 = back.points['P7']!;

    final closure = const WaistDartClosure().close(
      sidePoint: p10,
      dartsFromCenterToSide: back.darts,
    );
    final sideCurve = const SideSeamCurveBuilder().build(start: p10, end: p7);
    final cumulativeAngle = closure.closureAngles.fold<double>(0, (a, b) => a + b);

    final waistCurve = const WaistCurveBuilder().build(
      centerPoint: p1,
      closedSidePoint: closure.closedSidePoint,
      originalSideSeamStartTangent: sideCurve.derivativeAt(0),
      cumulativeDartClosureAngle: cumulativeAngle,
      targetLength: 19.25,
    );

    expect(waistCurve.arcLength(), closeTo(19.25, 0.00001));
    expect(waistCurve.derivativeAt(0).y.abs(), lessThan(0.000001));
  });

  test('Vorderteil-Taillenkurve trifft 19,25 cm auf geschlossener Geometrie', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );

    expect(result.isValid, isTrue);
    final front = result.front!;
    final p2 = front.points['P2']!;
    final p16 = front.points['P16']!;
    final p7 = front.points['P7']!;

    final closure = const WaistDartClosure().close(
      sidePoint: p16,
      dartsFromCenterToSide: front.darts,
    );
    final sideCurve = const SideSeamCurveBuilder().build(start: p16, end: p7);
    final cumulativeAngle = closure.closureAngles.fold<double>(0, (a, b) => a + b);

    final waistCurve = const WaistCurveBuilder().build(
      centerPoint: p2,
      closedSidePoint: closure.closedSidePoint,
      originalSideSeamStartTangent: sideCurve.derivativeAt(0),
      cumulativeDartClosureAngle: cumulativeAngle,
      targetLength: 19.25,
    );

    expect(waistCurve.arcLength(), closeTo(19.25, 0.00001));
    expect(waistCurve.derivativeAt(0).y.abs(), lessThan(0.000001));
  });

  test('Beide Taillenkurven ergeben zusammen exakt 38,5 cm halben Umfang', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );

    final back = result.back!;
    final front = result.front!;

    final backClosure = const WaistDartClosure().close(
      sidePoint: back.points['P10']!,
      dartsFromCenterToSide: back.darts,
    );
    final frontClosure = const WaistDartClosure().close(
      sidePoint: front.points['P16']!,
      dartsFromCenterToSide: front.darts,
    );

    final backSide = const SideSeamCurveBuilder().build(
      start: back.points['P10']!,
      end: back.points['P7']!,
    );
    final frontSide = const SideSeamCurveBuilder().build(
      start: front.points['P16']!,
      end: front.points['P7']!,
    );

    final backWaist = const WaistCurveBuilder().build(
      centerPoint: back.points['P1']!,
      closedSidePoint: backClosure.closedSidePoint,
      originalSideSeamStartTangent: backSide.derivativeAt(0),
      cumulativeDartClosureAngle:
          backClosure.closureAngles.fold<double>(0, (a, b) => a + b),
      targetLength: 19.25,
    );
    final frontWaist = const WaistCurveBuilder().build(
      centerPoint: front.points['P2']!,
      closedSidePoint: frontClosure.closedSidePoint,
      originalSideSeamStartTangent: frontSide.derivativeAt(0),
      cumulativeDartClosureAngle:
          frontClosure.closureAngles.fold<double>(0, (a, b) => a + b),
      targetLength: 19.25,
    );

    expect(backWaist.arcLength() + frontWaist.arcLength(), closeTo(38.5, 0.00001));
  });
}
