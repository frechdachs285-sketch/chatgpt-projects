import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_cutting_outline_builder.dart';
import 'package:schnittmuster_app/trouser_seam_allowance.dart';

void main() {
  const builder = TrouserCuttingOutlineBuilder();
  const settings = TrouserSeamAllowanceSettings(
    enabled: true,
    normalCm: 1.2,
    waistCm: 0.8,
    hemCm: 3.4,
  );
  const p10 = PatternPoint(1.0, 0.0);
  const p11 = PatternPoint(8.0, 0.0);
  const p21 = PatternPoint(-2.0, 1.0);
  const p22 = PatternPoint(7.0, 0.0);

  double allowance(PathSegment segment) => builder.allowanceForSegment(
        segment,
        settings: settings,
        frontP10: p10,
        frontP11: p11,
        backP21: p21,
        backP22: p22,
      );

  test('front and back waist use only waist allowance', () {
    expect(allowance(LineSegment(p10, p11)), settings.waistCm);
    expect(allowance(LineSegment(p21, p22)), settings.waistCm);
  });

  test('hem role uses only hem allowance', () {
    final hem = BezierSegment(
      const PatternPoint(8.0, 10.0),
      const PatternPoint(5.0, 11.0),
      const PatternPoint(-5.0, 11.0),
      const PatternPoint(-8.0, 10.0),
      role: 'front_hem',
    );
    expect(allowance(hem), settings.hemCm);
  });

  test('normal contour lines do not accidentally become waist allowance', () {
    final frontCenterTop = LineSegment(
      const PatternPoint(0.0, 4.0),
      p10,
    );
    final lowerInseam = LineSegment(
      const PatternPoint(-6.0, 10.0),
      const PatternPoint(-5.0, 5.0),
    );
    expect(allowance(frontCenterTop), settings.normalCm);
    expect(allowance(lowerInseam), settings.normalCm);
  });

  test('non-hem bezier uses normal allowance', () {
    final crotch = BezierSegment(
      const PatternPoint(0.0, 4.0),
      const PatternPoint(-1.0, 5.0),
      const PatternPoint(-2.0, 6.0),
      const PatternPoint(-3.0, 7.0),
      role: 'front_crotch',
    );
    expect(allowance(crotch), settings.normalCm);
  });

  test('invalid settings are rejected before classification', () {
    const invalid = TrouserSeamAllowanceSettings(
      enabled: true,
      normalCm: -0.1,
      waistCm: 1.0,
      hemCm: 2.0,
    );
    final segment = LineSegment(p10, p11);
    expect(
      () => builder.allowanceForSegment(
        segment,
        settings: invalid,
        frontP10: p10,
        frontP11: p11,
        backP21: p21,
        backP22: p22,
      ),
      throwsArgumentError,
    );
  });
}
