import 'dart:math' as math;

import 'pattern_geometry.dart';
import 'pattern_models.dart';

class HorizontalCurveHit {
  final CubicBezierCurve curve;
  final int curveIndex;
  final double t;
  final PatternPoint point;

  const HorizontalCurveHit({
    required this.curve,
    required this.curveIndex,
    required this.t,
    required this.point,
  });
}

/// App-specific geometry helper for intersecting confirmed digital curves
/// with a horizontal construction line y = targetY.
class HorizontalCurveIntersection {
  const HorizontalCurveIntersection();

  List<HorizontalCurveHit> detailedIntersections(
    Iterable<CubicBezierCurve> curves,
    double targetY, {
    double tolerance = 1e-9,
    int samplesPerCurve = 512,
  }) {
    if (!targetY.isFinite) {
      throw ArgumentError('targetY must be finite.');
    }
    if (!tolerance.isFinite || tolerance <= 0.0) {
      throw ArgumentError('tolerance must be finite and > 0.');
    }
    if (samplesPerCurve < 8) {
      throw ArgumentError('samplesPerCurve must be at least 8.');
    }

    final list = curves.toList(growable: false);
    final hits = <HorizontalCurveHit>[];

    for (var curveIndex = 0; curveIndex < list.length; curveIndex++) {
      final curve = list[curveIndex];
      final splitTs = <double>[0.0, ..._stationaryYParameters(curve), 1.0]
        ..sort();

      for (final t in splitTs) {
        final point = curve.pointAt(t);
        if ((point.y - targetY).abs() <= tolerance) {
          _addUniqueHit(
            hits,
            HorizontalCurveHit(
              curve: curve,
              curveIndex: curveIndex,
              t: t,
              point: point,
            ),
            tolerance,
          );
        }
      }

      for (var i = 0; i < splitTs.length - 1; i++) {
        final lowT = splitTs[i];
        final highT = splitTs[i + 1];
        final lowDelta = curve.pointAt(lowT).y - targetY;
        final highDelta = curve.pointAt(highT).y - targetY;

        if (lowDelta.abs() <= tolerance || highDelta.abs() <= tolerance) {
          continue;
        }
        if (lowDelta.sign == highDelta.sign) {
          continue;
        }

        final t = _bisectT(
          curve,
          targetY,
          lowT,
          highT,
          tolerance,
        );
        _addUniqueHit(
          hits,
          HorizontalCurveHit(
            curve: curve,
            curveIndex: curveIndex,
            t: t,
            point: curve.pointAt(t),
          ),
          tolerance,
        );
      }
    }

    return List<HorizontalCurveHit>.unmodifiable(hits);
  }

  HorizontalCurveHit singleDetailedIntersection(
    Iterable<CubicBezierCurve> curves,
    double targetY, {
    double tolerance = 1e-9,
    int samplesPerCurve = 512,
  }) {
    final hits = detailedIntersections(
      curves,
      targetY,
      tolerance: tolerance,
      samplesPerCurve: samplesPerCurve,
    );
    if (hits.length != 1) {
      throw StateError(
        'Expected exactly one horizontal curve intersection, found ${hits.length}.',
      );
    }
    return hits.single;
  }

  List<PatternPoint> intersections(
    Iterable<CubicBezierCurve> curves,
    double targetY, {
    double tolerance = 1e-9,
    int samplesPerCurve = 512,
  }) =>
      List<PatternPoint>.unmodifiable(
        detailedIntersections(
          curves,
          targetY,
          tolerance: tolerance,
          samplesPerCurve: samplesPerCurve,
        ).map((hit) => hit.point),
      );

  PatternPoint singleIntersection(
    Iterable<CubicBezierCurve> curves,
    double targetY, {
    double tolerance = 1e-9,
    int samplesPerCurve = 512,
  }) =>
      singleDetailedIntersection(
        curves,
        targetY,
        tolerance: tolerance,
        samplesPerCurve: samplesPerCurve,
      ).point;

  List<double> _stationaryYParameters(CubicBezierCurve curve) {
    final y0 = curve.start.y;
    final y1 = curve.control1.y;
    final y2 = curve.control2.y;
    final y3 = curve.end.y;

    final cubic = -y0 + 3.0 * y1 - 3.0 * y2 + y3;
    final quadratic = 3.0 * y0 - 6.0 * y1 + 3.0 * y2;
    final linear = -3.0 * y0 + 3.0 * y1;

    final a = 3.0 * cubic;
    final b = 2.0 * quadratic;
    final c = linear;
    const epsilon = 1e-14;
    final roots = <double>[];

    if (a.abs() <= epsilon) {
      if (b.abs() <= epsilon) return roots;
      _addUnitRoot(roots, -c / b);
      return roots;
    }

    final discriminant = b * b - 4.0 * a * c;
    if (discriminant < -epsilon) return roots;

    final sqrtDiscriminant = math.sqrt(math.max(0.0, discriminant));
    _addUnitRoot(roots, (-b - sqrtDiscriminant) / (2.0 * a));
    _addUnitRoot(roots, (-b + sqrtDiscriminant) / (2.0 * a));
    roots.sort();
    return roots;
  }

  void _addUnitRoot(List<double> roots, double t) {
    const epsilon = 1e-12;
    if (!t.isFinite || t <= epsilon || t >= 1.0 - epsilon) return;
    if (roots.any((existing) => (existing - t).abs() <= epsilon)) return;
    roots.add(t);
  }

  double _bisectT(
    CubicBezierCurve curve,
    double targetY,
    double lowT,
    double highT,
    double tolerance,
  ) {
    var low = lowT;
    var high = highT;
    var lowDelta = curve.pointAt(low).y - targetY;

    for (var i = 0; i < 80; i++) {
      final mid = (low + high) * 0.5;
      final point = curve.pointAt(mid);
      final delta = point.y - targetY;
      if (delta.abs() <= tolerance) {
        return mid;
      }
      if (delta.sign == lowDelta.sign) {
        low = mid;
        lowDelta = delta;
      } else {
        high = mid;
      }
    }

    return (low + high) * 0.5;
  }

  void _addUniqueHit(
    List<HorizontalCurveHit> hits,
    HorizontalCurveHit candidate,
    double tolerance,
  ) {
    if (hits.any((hit) => hit.point.distanceTo(candidate.point) <= tolerance * 10.0)) {
      return;
    }
    hits.add(candidate);
  }
}
