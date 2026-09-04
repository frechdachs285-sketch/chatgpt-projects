import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/segmented_waist_curve.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';

void main() {
  test('Rueckenteil-Taillenkurve trifft 19,25 cm durch beide Abnaeher-Muendungen', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );
    final back = result.back!;

    final waist = const SegmentedWaistCurveSolver().solve(
      centerPoint: back.points['P1']!,
      sidePoint: back.points['P10']!,
      hipPoint: back.points['P7']!,
      dartsFromCenterToSide: back.darts,
      targetLength: 19.25,
    );

    expect(waist.segments.length, 3);
    expect(waist.closedDartMouths.length, 2);
    expect(waist.totalLength, closeTo(19.25, 0.00001));
    expect(waist.horizontalShift, greaterThan(0));
    expect(waist.correctedSidePoint.y, equals(back.points['P10']!.y));

    final firstTangent = waist.segments.first.derivativeAt(0);
    expect(firstTangent.y.abs(), lessThan(0.000001));

    for (var i = 0; i < waist.closedDartMouths.length; i++) {
      expect(
        waist.segments[i].end.distanceTo(waist.closedDartMouths[i]),
        lessThan(0.000001),
      );
      expect(
        waist.segments[i + 1].start.distanceTo(waist.closedDartMouths[i]),
        lessThan(0.000001),
      );

      final left = waist.segments[i].derivativeAt(1);
      final right = waist.segments[i + 1].derivativeAt(0);
      final cross = left.x * right.y - left.y * right.x;
      expect(cross.abs(), lessThan(0.000001));
    }
  });

  test('Vorderteil-Taillenkurve trifft 19,25 cm durch Abnaeher-Muendung', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );
    final front = result.front!;

    final waist = const SegmentedWaistCurveSolver().solve(
      centerPoint: front.points['P2']!,
      sidePoint: front.points['P16']!,
      hipPoint: front.points['P7']!,
      dartsFromCenterToSide: front.darts,
      targetLength: 19.25,
    );

    expect(waist.segments.length, 2);
    expect(waist.closedDartMouths.length, 1);
    expect(waist.totalLength, closeTo(19.25, 0.00001));
    expect(waist.horizontalShift, greaterThan(0));
    expect(waist.correctedSidePoint.y, equals(front.points['P16']!.y));

    final firstTangent = waist.segments.first.derivativeAt(0);
    expect(firstTangent.y.abs(), lessThan(0.000001));

    final mouth = waist.closedDartMouths.first;
    expect(waist.segments.first.end.distanceTo(mouth), lessThan(0.000001));
    expect(waist.segments.last.start.distanceTo(mouth), lessThan(0.000001));

    final left = waist.segments.first.derivativeAt(1);
    final right = waist.segments.last.derivativeAt(0);
    final cross = left.x * right.y - left.y * right.x;
    expect(cross.abs(), lessThan(0.000001));
  });

  test('Beide segmentierten Taillenkurven ergeben exakt 38,5 cm', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );
    final back = result.back!;
    final front = result.front!;
    const solver = SegmentedWaistCurveSolver();

    final backWaist = solver.solve(
      centerPoint: back.points['P1']!,
      sidePoint: back.points['P10']!,
      hipPoint: back.points['P7']!,
      dartsFromCenterToSide: back.darts,
      targetLength: 19.25,
    );
    final frontWaist = solver.solve(
      centerPoint: front.points['P2']!,
      sidePoint: front.points['P16']!,
      hipPoint: front.points['P7']!,
      dartsFromCenterToSide: front.darts,
      targetLength: 19.25,
    );

    expect(backWaist.totalLength + frontWaist.totalLength, closeTo(38.5, 0.00001));
  });
}
