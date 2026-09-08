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
