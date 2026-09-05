import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_geometry.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';

void main() {
  double waistLength(PatternPiece piece) {
    return piece.outline.segments
        .whereType<BezierSegment>()
        .where((segment) => segment.role == 'waist')
        .fold<double>(0, (sum, segment) {
      final curve = CubicBezierCurve(
        start: segment.start,
        control1: segment.control1,
        control2: segment.control2,
        end: segment.end,
      );
      return sum + curve.arcLength();
    });
  }

  void expectProductionGeometry(Measurements measurements, ConstructionValues construction) {
    final result = SkirtPatternCalculator().calculate(measurements, construction);
    expect(result.isValid, isTrue);
    final back = result.back!;
    final front = result.front!;
    final backWaist = back.outline.segments.whereType<BezierSegment>().where((s) => s.role == 'waist').toList();
    final frontWaist = front.outline.segments.whereType<BezierSegment>().where((s) => s.role == 'waist').toList();
    final backSide = back.outline.segments.whereType<BezierSegment>().singleWhere((s) => s.role == 'sideSeam');
    final frontSide = front.outline.segments.whereType<BezierSegment>().singleWhere((s) => s.role == 'sideSeam');

    expect(backWaist.length, 3);
    expect(frontWaist.length, 2);
    expect(backWaist[0].start.distanceTo(back.points['P1']!), lessThan(0.000001));
    expect(backWaist[0].end.distanceTo(back.darts[0].leg1), lessThan(0.000001));
    expect(backWaist[1].start.distanceTo(back.darts[0].leg2), lessThan(0.000001));
    expect(backWaist[1].end.distanceTo(back.darts[1].leg1), lessThan(0.000001));
    expect(backWaist[2].start.distanceTo(back.darts[1].leg2), lessThan(0.000001));
    expect(backWaist[2].end.distanceTo(backSide.start), lessThan(0.000001));
    expect(frontWaist[0].start.distanceTo(front.points['P2']!), lessThan(0.000001));
    expect(frontWaist[0].end.distanceTo(front.darts[0].leg1), lessThan(0.000001));
    expect(frontWaist[1].start.distanceTo(front.darts[0].leg2), lessThan(0.000001));
    expect(frontWaist[1].end.distanceTo(frontSide.start), lessThan(0.000001));

    final targetPieceWaist = (measurements.waist + construction.waistEase) / 4;
    final backLength = waistLength(back);
    final frontLength = waistLength(front);
    expect(backLength, closeTo(targetPieceWaist, 0.00001));
    expect(frontLength, closeTo(targetPieceWaist, 0.00001));
    expect(backLength + frontLength, closeTo((measurements.waist + construction.waistEase) / 2, 0.00001));
    expect(backSide.end.distanceTo(back.points['P7']!), lessThan(0.000001));
    expect(frontSide.end.distanceTo(front.points['P7']!), lessThan(0.000001));
    expect(backSide.start.y, closeTo(-construction.sideWaistLift, 0.000001));
    expect(frontSide.start.y, closeTo(-construction.sideWaistLift, 0.000001));
  }

  test('Rock v1 Kontrollmasse erzeugen gueltige Schnittteile', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );
    expect(result.isValid, isTrue);
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

  test('Fadenlaeufe sind vertikal und adaptiv positioniert', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );
    final back = result.back!;
    final front = result.front!;
    final backGrainline = back.grainline!;
    final frontGrainline = front.grainline!;

    expect(backGrainline.start.x, closeTo(13.25, 0.000001));
    expect(backGrainline.end.x, closeTo(13.25, 0.000001));
    expect(frontGrainline.start.x, closeTo(39.0, 0.000001));
    expect(frontGrainline.end.x, closeTo(39.0, 0.000001));
    expect(backGrainline.start.y, closeTo(15.0, 0.000001));
    expect(backGrainline.end.y, closeTo(45.0, 0.000001));
    expect(frontGrainline.start.y, closeTo(15.0, 0.000001));
    expect(frontGrainline.end.y, closeTo(45.0, 0.000001));
  });

  test('Hueft-Passzeichen stimmen an P7 exakt ueberein', () {
    final result = SkirtPatternCalculator().calculate(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );
    final back = result.back!;
    final front = result.front!;

    expect(back.notches.length, 1);
    expect(front.notches.length, 1);
    final backNotch = back.notches.single;
    final frontNotch = front.notches.single;
    expect(backNotch.role, 'side_hip');
    expect(frontNotch.role, 'side_hip');
    expect(backNotch.type, NotchType.single);
    expect(frontNotch.type, NotchType.single);
    expect(backNotch.position.distanceTo(back.points['P7']!), lessThan(0.000001));
    expect(frontNotch.position.distanceTo(front.points['P7']!), lessThan(0.000001));
    expect(backNotch.position.distanceTo(frontNotch.position), lessThan(0.000001));
    expect(backNotch.position.x, closeTo(26.5, 0.000001));
    expect(backNotch.position.y, closeTo(21.0, 0.000001));
  });

  test('Produktionskontur nutzt echte Taillen-Beziers und ist lueckenlos', () {
    expectProductionGeometry(
      const Measurements(waist: 76, hip: 100, hipDepth: 21, skirtLength: 60),
      const ConstructionValues(),
    );
  });

  test('Produktionsgeometrie bleibt bei mehreren Koerpermassen exakt', () {
    const construction = ConstructionValues();
    const cases = [
      Measurements(waist: 68, hip: 94, hipDepth: 20, skirtLength: 55),
      Measurements(waist: 84, hip: 108, hipDepth: 22, skirtLength: 65),
      Measurements(waist: 92, hip: 116, hipDepth: 24, skirtLength: 72),
    ];
    for (final measurements in cases) {
      expectProductionGeometry(measurements, construction);
    }
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
