import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_geometry.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/seam_allowance_geometry.dart';

void main() {
  test('Adaptive Bezier-Nahtzugabe erreicht geforderte Abweichung', () {
    const curve = CubicBezierCurve(
      start: PatternPoint(0, 0),
      control1: PatternPoint(3, -1),
      control2: PatternPoint(7, 8),
      end: PatternPoint(10, 10),
    );
    const distance = 1.5;
    const tolerance = 0.01;

    final points = SeamAllowanceGeometry.offsetBezierAdaptive(
      curve,
      distance,
      maxDeviation: tolerance,
    );

    expect(points.length, greaterThan(2));
    expect(points.first.distanceTo(
      SeamAllowanceGeometry.offsetBezierSamples(curve, distance, samples: 1).first,
    ), lessThan(1e-9));
    expect(points.last.distanceTo(
      SeamAllowanceGeometry.offsetBezierSamples(curve, distance, samples: 1).last,
    ), lessThan(1e-9));

    // Dense independent reference sampling: every exact offset reference point
    // must stay close to the adaptive polyline. The threshold is intentionally
    // slightly above the recursive midpoint tolerance because nearest-segment
    // distance is evaluated independently over the whole parameter range.
    const referenceSamples = 4000;
    var maxDistance = 0.0;
    for (var i = 0; i <= referenceSamples; i++) {
      final reference = SeamAllowanceGeometry.offsetBezierSamples(
        curve,
        distance,
        samples: referenceSamples,
      )[i];
      final d = _distanceToPolyline(reference, points);
      if (d > maxDistance) maxDistance = d;
    }

    expect(maxDistance, lessThanOrEqualTo(0.012));
  });

  test('Strengere Toleranz erzeugt mindestens gleich viele Punkte', () {
    const curve = CubicBezierCurve(
      start: PatternPoint(0, 0),
      control1: PatternPoint(2, 5),
      control2: PatternPoint(8, 5),
      end: PatternPoint(10, 0),
    );

    final coarse = SeamAllowanceGeometry.offsetBezierAdaptive(
      curve,
      1.5,
      maxDeviation: 0.05,
    );
    final fine = SeamAllowanceGeometry.offsetBezierAdaptive(
      curve,
      1.5,
      maxDeviation: 0.005,
    );

    expect(fine.length, greaterThanOrEqualTo(coarse.length));
  });

  test('Ungueltige adaptive Toleranz wird abgewiesen', () {
    const curve = CubicBezierCurve(
      start: PatternPoint(0, 0),
      control1: PatternPoint(2, 0),
      control2: PatternPoint(4, 4),
      end: PatternPoint(6, 4),
    );

    expect(
      () => SeamAllowanceGeometry.offsetBezierAdaptive(
        curve,
        1.5,
        maxDeviation: 0,
      ),
      throwsArgumentError,
    );
  });
}

double _distanceToPolyline(PatternPoint point, List<PatternPoint> polyline) {
  var best = double.infinity;
  for (var i = 1; i < polyline.length; i++) {
    final d = _distanceToSegment(point, polyline[i - 1], polyline[i]);
    if (d < best) best = d;
  }
  return best;
}

double _distanceToSegment(
  PatternPoint point,
  PatternPoint a,
  PatternPoint b,
) {
  final ab = b - a;
  final ap = point - a;
  final lengthSquared = ab.x * ab.x + ab.y * ab.y;
  if (lengthSquared == 0) return point.distanceTo(a);

  var t = (ap.x * ab.x + ap.y * ab.y) / lengthSquared;
  if (t < 0) t = 0;
  if (t > 1) t = 1;
  final nearest = a + ab * t;
  return point.distanceTo(nearest);
}
