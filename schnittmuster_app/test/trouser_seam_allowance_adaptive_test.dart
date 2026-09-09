import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_seam_allowance.dart';
import 'package:schnittmuster_app/trouser_seam_allowance_geometry.dart';

void main() {
  const geometry = TrouserSeamAllowanceGeometry();

  BezierSegment curve() => BezierSegment(
        start: const PatternPoint(0.0, 0.0),
        control1: const PatternPoint(2.5, -1.0),
        control2: const PatternPoint(5.0, 4.0),
        end: const PatternPoint(8.0, 3.0),
        role: 'adaptive_test_curve',
      );

  PatternPoint bezierPoint(BezierSegment c, double t) {
    final u = 1.0 - t;
    return c.start * (u * u * u) +
        c.control1 * (3.0 * u * u * t) +
        c.control2 * (3.0 * u * t * t) +
        c.end * (t * t * t);
  }

  PatternPoint bezierDerivative(BezierSegment c, double t) {
    final u = 1.0 - t;
    return (c.control1 - c.start) * (3.0 * u * u) +
        (c.control2 - c.control1) * (6.0 * u * t) +
        (c.end - c.control2) * (3.0 * t * t);
  }

  PatternPoint trueOffset(BezierSegment c, double t, double distance) {
    final p = bezierPoint(c, t);
    final d = bezierDerivative(c, t);
    final length = math.sqrt(d.x * d.x + d.y * d.y);
    final normal = PatternPoint(-d.y / length, d.x / length);
    return p + normal * distance;
  }

  double distanceToSegment(PatternPoint p, PatternPoint a, PatternPoint b) {
    final vx = b.x - a.x;
    final vy = b.y - a.y;
    final wx = p.x - a.x;
    final wy = p.y - a.y;
    final vv = vx * vx + vy * vy;
    if (vv <= 0.0) return p.distanceTo(a);
    final t = ((wx * vx + wy * vy) / vv).clamp(0.0, 1.0);
    final q = PatternPoint(a.x + vx * t, a.y + vy * t);
    return p.distanceTo(q);
  }

  test('adaptive offset is refined and keeps endpoints on exact normal offset', () {
    const distance = 1.5;
    final c = curve();
    final polyline = geometry.adaptiveBezierOffset(
      c,
      distanceCm: distance,
      side: TrouserOffsetSide.left,
      toleranceCm: trouserSeamAllowanceToleranceCm,
    );

    expect(polyline.length, greaterThan(2));
    expect(
      polyline.first.distanceTo(trueOffset(c, 0.0, distance)),
      lessThan(1e-9),
    );
    expect(
      polyline.last.distanceTo(trueOffset(c, 1.0, distance)),
      lessThan(1e-9),
    );
  });

  test('adaptive offset stays within confirmed 0.1 mm tolerance', () {
    const distance = 1.5;
    final c = curve();
    final polyline = geometry.adaptiveBezierOffset(
      c,
      distanceCm: distance,
      side: TrouserOffsetSide.left,
      toleranceCm: trouserSeamAllowanceToleranceCm,
    );

    // Dense independent verification against the generated polyline.
    for (var i = 0; i <= 1000; i++) {
      final t = i / 1000.0;
      final p = trueOffset(c, t, distance);
      var minDistance = double.infinity;
      for (var j = 0; j < polyline.length - 1; j++) {
        minDistance = math.min(
          minDistance,
          distanceToSegment(p, polyline[j], polyline[j + 1]),
        );
      }
      expect(
        minDistance,
        lessThanOrEqualTo(trouserSeamAllowanceToleranceCm + 1e-9),
        reason: 'Offsetabweichung bei t=$t ist zu gross.',
      );
    }
  });

  test('smaller tolerance creates equal or finer polyline', () {
    final c = curve();
    final coarse = geometry.adaptiveBezierOffset(
      c,
      distanceCm: 1.0,
      side: TrouserOffsetSide.left,
      toleranceCm: 0.02,
    );
    final fine = geometry.adaptiveBezierOffset(
      c,
      distanceCm: 1.0,
      side: TrouserOffsetSide.left,
      toleranceCm: 0.005,
    );

    expect(fine.length, greaterThanOrEqualTo(coarse.length));
  });

  test('invalid adaptive tolerance is rejected', () {
    expect(
      () => geometry.adaptiveBezierOffset(
        curve(),
        distanceCm: 1.0,
        side: TrouserOffsetSide.left,
        toleranceCm: 0.0,
      ),
      throwsArgumentError,
    );
  });
}
