import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';

void main() {
  const size14 = TrouserMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    bodyRise: 28.7,
    waistToFloor: 105.0,
    trouserBottomWidth: 22.0,
  );

  test('Aldrich size 14 reference points P0-P31 with Hose v1 hem lowering', () {
    final d = TrouserPatternCalculator.calculateReferencePoints(size14);

    void point(int n, double x, double y, {double eps = 0.001}) {
      expect(d[n].x, closeTo(x, eps), reason: 'P$n.x');
      expect(d[n].y, closeTo(y, eps), reason: 'P$n.y');
    }

    point(0, 0.000, 0.000);
    point(1, 0.000, 28.700);
    point(2, 0.000, 20.900);
    point(3, 0.000, 106.000);
    point(4, 0.000, 61.850);
    point(5, -9.833, 28.700);
    point(6, -9.833, 20.900);
    point(7, -9.833, 0.000);
    point(8, 15.667, 20.900);
    point(9, -16.583, 28.700);
    point(10, -8.833, 0.000);
    point(11, 12.417, 0.000);
    point(12, 10.500, 105.000);
    point(13, 11.800, 61.850);
    point(14, -10.500, 105.000);
    point(15, -11.800, 61.850);
    point(16, -7.375, 28.700);
    point(17, -7.375, 20.900);
    point(18, -7.375, 0.000);
    point(19, -7.375, 14.350);
    point(20, -5.375, 0.000);
    point(21, -5.375, -2.000);
    point(22, 17.789, 0.000, eps: 0.002);
    point(23, -19.958, 28.700);
    point(24, -20.458, 28.700);
    point(25, 19.125, 20.900);
    point(26, 11.500, 105.000);
    point(27, 12.800, 61.850);
    point(28, -11.500, 105.000);
    point(29, -12.800, 61.850);
    point(30, 2.346, -1.333, eps: 0.002);
    point(31, 10.068, -0.667, eps: 0.002);
  });

  test('explicit size 14 is identical to the default reference calculation', () {
    final defaultDraft = TrouserPatternCalculator.calculateReferencePoints(size14);
    final explicitDraft = TrouserPatternCalculator.calculateReferencePoints(
      size14,
      sizeCode: 14,
    );

    for (var n = 0; n <= 31; n++) {
      expect(explicitDraft[n].x, closeTo(defaultDraft[n].x, 1e-12), reason: 'P$n.x');
      expect(explicitDraft[n].y, closeTo(defaultDraft[n].y, 1e-12), reason: 'P$n.y');
    }
  });

  test('alternative leg shaping 0 keeps every reference point unchanged', () {
    final defaultDraft = TrouserPatternCalculator.calculateReferencePoints(size14);
    final zeroDraft = TrouserPatternCalculator.calculateReferencePoints(
      const TrouserMeasurements(
        waist: 76.0,
        hip: 100.0,
        hipDepth: 20.9,
        bodyRise: 28.7,
        waistToFloor: 105.0,
        trouserBottomWidth: 22.0,
        alternativeLegShapingCm: 0.0,
      ),
    );

    for (var n = 0; n <= 31; n++) {
      expect(zeroDraft[n].x, closeTo(defaultDraft[n].x, 1e-12), reason: 'P$n.x');
      expect(zeroDraft[n].y, closeTo(defaultDraft[n].y, 1e-12), reason: 'P$n.y');
    }
  });

  test('alternative leg shaping shifts only P12-P15 and P26-P29 in x', () {
    final base = TrouserPatternCalculator.calculateReferencePoints(size14);
    final plusOne = TrouserPatternCalculator.calculateReferencePoints(
      const TrouserMeasurements(
        waist: 76.0,
        hip: 100.0,
        hipDepth: 20.9,
        bodyRise: 28.7,
        waistToFloor: 105.0,
        trouserBottomWidth: 22.0,
        alternativeLegShapingCm: 1.0,
      ),
    );
    final minusOne = TrouserPatternCalculator.calculateReferencePoints(
      const TrouserMeasurements(
        waist: 76.0,
        hip: 100.0,
        hipDepth: 20.9,
        bodyRise: 28.7,
        waistToFloor: 105.0,
        trouserBottomWidth: 22.0,
        alternativeLegShapingCm: -1.0,
      ),
    );

    const positiveSide = {12, 13, 26, 27};
    const negativeSide = {14, 15, 28, 29};
    const changed = {...positiveSide, ...negativeSide};

    for (var n = 0; n <= 31; n++) {
      expect(plusOne[n].y, closeTo(base[n].y, 1e-12), reason: 'plus P$n.y');
      expect(minusOne[n].y, closeTo(base[n].y, 1e-12), reason: 'minus P$n.y');

      if (positiveSide.contains(n)) {
        expect(plusOne[n].x - base[n].x, closeTo(1.0, 1e-12), reason: 'plus P$n.x');
        expect(minusOne[n].x - base[n].x, closeTo(-1.0, 1e-12), reason: 'minus P$n.x');
      } else if (negativeSide.contains(n)) {
        expect(plusOne[n].x - base[n].x, closeTo(-1.0, 1e-12), reason: 'plus P$n.x');
        expect(minusOne[n].x - base[n].x, closeTo(1.0, 1e-12), reason: 'minus P$n.x');
      } else {
        expect(changed.contains(n), isFalse);
        expect(plusOne[n].x, closeTo(base[n].x, 1e-12), reason: 'plus P$n.x');
        expect(minusOne[n].x, closeTo(base[n].x, 1e-12), reason: 'minus P$n.x');
      }
    }
  });

  test('size-dependent P13/P15/P27/P29 use the selected Aldrich rule', () {
    final size14Draft = TrouserPatternCalculator.calculateReferencePoints(size14, sizeCode: 14);
    final size18Draft = TrouserPatternCalculator.calculateReferencePoints(size14, sizeCode: 18);
    final size24Draft = TrouserPatternCalculator.calculateReferencePoints(size14, sizeCode: 24);

    expect(size14Draft[13].x, closeTo(11.8, 1e-12));
    expect(size18Draft[13].x, closeTo(12.0, 1e-12));
    expect(size24Draft[13].x, closeTo(12.2, 1e-12));

    expect(size14Draft[15].x, closeTo(-11.8, 1e-12));
    expect(size18Draft[15].x, closeTo(-12.0, 1e-12));
    expect(size24Draft[15].x, closeTo(-12.2, 1e-12));

    expect(size14Draft[27].x, closeTo(12.8, 1e-12));
    expect(size18Draft[27].x, closeTo(13.0, 1e-12));
    expect(size24Draft[27].x, closeTo(13.2, 1e-12));

    expect(size14Draft[29].x, closeTo(-12.8, 1e-12));
    expect(size18Draft[29].x, closeTo(-13.0, 1e-12));
    expect(size24Draft[29].x, closeTo(-13.2, 1e-12));
  });

  test('unsupported construction size stays blocked by calculator', () {
    expect(
      () => TrouserPatternCalculator.calculateReferencePoints(size14, sizeCode: 26),
      throwsArgumentError,
    );
  });

  test('Hose v1 hem anchors keep exact 1 cm P3 lowering', () {
    final d = TrouserPatternCalculator.calculateReferencePoints(size14);

    expect(d[3].y - d[12].y, closeTo(1.0, 1e-9));
    expect(d[3].y - d[14].y, closeTo(1.0, 1e-9));
    expect(d[12].y, closeTo(size14.waistToFloor, 1e-9));
    expect(d[14].y, closeTo(size14.waistToFloor, 1e-9));
    expect(d[26].y, closeTo(size14.waistToFloor, 1e-9));
    expect(d[28].y, closeTo(size14.waistToFloor, 1e-9));
  });

  test('size 14 independent construction relations', () {
    final d = TrouserPatternCalculator.calculateReferencePoints(size14);

    expect(d[5].distanceTo(d[9]), closeTo(6.75, 1e-9));
    expect(d[10].distanceTo(d[11]), closeTo(21.25, 1e-9));
    expect(d[21].distanceTo(d[22]), closeTo(23.25, 1e-9));
    expect(d[9].distanceTo(d[23]), closeTo(3.375, 1e-9));
    expect(d[23].distanceTo(d[24]), closeTo(0.5, 1e-9));
    expect(d[17].distanceTo(d[25]), closeTo(26.5, 1e-9));

    // Closing one 2 cm front dart and two 2 cm back darts gives
    // 19.25 cm per quarter, hence 77 cm total = 76 cm waist + 1 cm ease.
    final frontQuarterClosed = d[10].distanceTo(d[11]) - 2.0;
    final backQuarterClosed = d[21].distanceTo(d[22]) - 4.0;
    expect(frontQuarterClosed, closeTo(19.25, 1e-9));
    expect(backQuarterClosed, closeTo(19.25, 1e-9));
    expect(2.0 * (frontQuarterClosed + backQuarterClosed), closeTo(77.0, 1e-9));
  });
}
