import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/horizontal_curve_intersection.dart';
import 'package:schnittmuster_app/pattern_geometry.dart';
import 'package:schnittmuster_app/pattern_models.dart';

void main() {
  const helper = HorizontalCurveIntersection();

  test('finds one exact intersection on a simple monotone Bezier', () {
    const curve = CubicBezierCurve(
      start: PatternPoint(0.0, 0.0),
      control1: PatternPoint(1.0, 1.0),
      control2: PatternPoint(2.0, 2.0),
      end: PatternPoint(3.0, 3.0),
    );

    final hit = helper.singleIntersection([curve], 1.5);

    expect(hit.x, closeTo(1.5, 1e-8));
    expect(hit.y, closeTo(1.5, 1e-9));
  });

  test('finds multiple crossings without assuming monotonic y', () {
    const curve = CubicBezierCurve(
      start: PatternPoint(0.0, 0.0),
      control1: PatternPoint(1.0, 3.0),
      control2: PatternPoint(2.0, -3.0),
      end: PatternPoint(3.0, 0.0),
    );

    final hits = helper.intersections([curve], 0.0);

    expect(hits.length, 3);
    expect(hits.first.y, closeTo(0.0, 1e-9));
    expect(hits[1].y, closeTo(0.0, 1e-9));
    expect(hits.last.y, closeTo(0.0, 1e-9));
  });

  test('deduplicates a shared endpoint across adjacent segments', () {
    const first = CubicBezierCurve(
      start: PatternPoint(0.0, 0.0),
      control1: PatternPoint(0.3, 0.3),
      control2: PatternPoint(0.7, 0.7),
      end: PatternPoint(1.0, 1.0),
    );
    const second = CubicBezierCurve(
      start: PatternPoint(1.0, 1.0),
      control1: PatternPoint(1.3, 1.3),
      control2: PatternPoint(1.7, 1.7),
      end: PatternPoint(2.0, 2.0),
    );

    final hits = helper.intersections([first, second], 1.0);

    expect(hits.length, 1);
    expect(hits.single.x, closeTo(1.0, 1e-9));
    expect(hits.single.y, closeTo(1.0, 1e-9));
  });

  test('finds a tangential touch between sampling positions', () {
    // Exact polynomial y(t) = (t - 1/3)^2 represented as a cubic Bezier.
    // The horizontal line y=0 only touches the curve at t=1/3; y does not
    // change sign there. 1/3 is deliberately not one of the default 512
    // sampling positions, so a sign-change-only search misses this contact.
    const curve = CubicBezierCurve(
      start: PatternPoint(0.0, 1.0 / 9.0),
      control1: PatternPoint(1.0 / 3.0, -1.0 / 9.0),
      control2: PatternPoint(2.0 / 3.0, 0.0),
      end: PatternPoint(1.0, 4.0 / 9.0),
    );

    final hits = helper.detailedIntersections([curve], 0.0);

    expect(hits.length, 1);
    expect(hits.single.t, closeTo(1.0 / 3.0, 1e-8));
    expect(hits.single.point.x, closeTo(1.0 / 3.0, 1e-8));
    expect(hits.single.point.y, closeTo(0.0, 1e-9));
  });

  test('singleIntersection rejects ambiguous and missing intersections', () {
    const multiple = CubicBezierCurve(
      start: PatternPoint(0.0, 0.0),
      control1: PatternPoint(1.0, 3.0),
      control2: PatternPoint(2.0, -3.0),
      end: PatternPoint(3.0, 0.0),
    );
    const none = CubicBezierCurve(
      start: PatternPoint(0.0, 2.0),
      control1: PatternPoint(1.0, 2.0),
      control2: PatternPoint(2.0, 2.0),
      end: PatternPoint(3.0, 2.0),
    );

    expect(() => helper.singleIntersection([multiple], 0.0), throwsStateError);
    expect(() => helper.singleIntersection([none], 0.0), throwsStateError);
  });
}
