import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/segmented_waist_curve.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';
import 'package:schnittmuster_app/waist_curve_unfolder.dart';

void main() {
  test('Ruecken-Taillenkurve klappt exakt an beide Abnaeher auf', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );
    final back = result.back!;
    final closed = const SegmentedWaistCurveSolver().solve(
      centerPoint: back.points['P1']!,
      sidePoint: back.points['P10']!,
      hipPoint: back.points['P7']!,
      dartsFromCenterToSide: back.darts,
      targetLength: 19.25,
    );

    final open = const WaistCurveUnfolder().unfold(
      closedCurve: closed,
      dartsFromCenterToSide: back.darts,
    );

    expect(open.length, 3);
    expect(open.first.start.distanceTo(back.points['P1']!), lessThan(0.000001));
    expect(open[0].end.distanceTo(back.darts[0].leg1), lessThan(0.000001));
    expect(open[1].start.distanceTo(back.darts[0].leg2), lessThan(0.000001));
    expect(open[1].end.distanceTo(back.darts[1].leg1), lessThan(0.000001));
    expect(open[2].start.distanceTo(back.darts[1].leg2), lessThan(0.000001));
    expect(open[2].end.y, closeTo(closed.correctedSidePoint.y, 0.000001));

    final openLength = open.fold<double>(0, (sum, curve) => sum + curve.arcLength());
    expect(openLength, closeTo(19.25, 0.00001));
  });

  test('Vorder-Taillenkurve klappt exakt am Abnaeher auf', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );
    final front = result.front!;
    final closed = const SegmentedWaistCurveSolver().solve(
      centerPoint: front.points['P2']!,
      sidePoint: front.points['P16']!,
      hipPoint: front.points['P7']!,
      dartsFromCenterToSide: front.darts,
      targetLength: 19.25,
    );

    final open = const WaistCurveUnfolder().unfold(
      closedCurve: closed,
      dartsFromCenterToSide: front.darts,
    );

    expect(open.length, 2);
    expect(open.first.start.distanceTo(front.points['P2']!), lessThan(0.000001));
    expect(open[0].end.distanceTo(front.darts[0].leg1), lessThan(0.000001));
    expect(open[1].start.distanceTo(front.darts[0].leg2), lessThan(0.000001));

    final openLength = open.fold<double>(0, (sum, curve) => sum + curve.arcLength());
    expect(openLength, closeTo(19.25, 0.00001));
  });
}
