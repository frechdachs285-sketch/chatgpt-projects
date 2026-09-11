import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/culotte_curve_geometry.dart';
import 'package:schnittmuster_app/pattern_models.dart';

void main() {
  test('back culotte step curve passes through C3, H3 and C4', () {
    const c3 = PatternPoint(0.0, 14.1);
    const h3 = PatternPoint(-2.1213203435596424, 28.078679656440358);
    const c4 = PatternPoint(-14.5, 30.2);

    final spline = const CulotteCurveGeometry().backStepCurve(
      c3: c3,
      h3: h3,
      c4: c4,
    );

    expect(spline.knots.length, 3);
    expect(spline.segments.length, 2);
    expect(spline.knots[0], same(c3));
    expect(spline.knots[1], same(h3));
    expect(spline.knots[2], same(c4));
    expect(spline.segments.first.start, same(c3));
    expect(spline.segments.first.end, same(h3));
    expect(spline.segments.last.start, same(h3));
    expect(spline.segments.last.end, same(c4));
  });

  test('front culotte step curve passes through C8, H4 and C9', () {
    const c8 = PatternPoint(0.0, 15.1);
    const h4 = PatternPoint(2.82842712474619, 27.37157287525381);
    const c9 = PatternPoint(10.5, 30.2);

    final spline = const CulotteCurveGeometry().frontStepCurve(
      c8: c8,
      h4: h4,
      c9: c9,
    );

    expect(spline.knots.length, 3);
    expect(spline.segments.length, 2);
    expect(spline.knots[0], same(c8));
    expect(spline.knots[1], same(h4));
    expect(spline.knots[2], same(c9));
    expect(spline.segments.first.start, same(c8));
    expect(spline.segments.first.end, same(h4));
    expect(spline.segments.last.start, same(h4));
    expect(spline.segments.last.end, same(c9));
  });
}
