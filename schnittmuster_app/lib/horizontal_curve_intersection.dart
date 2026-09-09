import 'pattern_geometry.dart';
import 'pattern_models.dart';

/// App-specific geometry helper for intersecting confirmed digital curves
/// with a horizontal construction line y = targetY.
class HorizontalCurveIntersection {
  const HorizontalCurveIntersection();

  List<PatternPoint> intersections(
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

    final hits = <PatternPoint>[];

    for (final curve in curves) {
      var previousT = 0.0;
      var previous = curve.pointAt(previousT);
      var previousDelta = previous.y - targetY;

      if (previousDelta.abs() <= tolerance) {
        _addUnique(hits, previous, tolerance);
      }

      for (var i = 1; i <= samplesPerCurve; i++) {
        final currentT = i / samplesPerCurve;
        final current = curve.pointAt(currentT);
        final currentDelta = current.y - targetY;

        if (currentDelta.abs() <= tolerance) {
          _addUnique(hits, current, tolerance);
        } else if (previousDelta == 0.0 || currentDelta.sign != previousDelta.sign) {
          final hit = _bisect(
            curve,
            targetY,
            previousT,
            currentT,
            tolerance,
          );
          _addUnique(hits, hit, tolerance);
        }

        previousT = currentT;
        previous = current;
        previousDelta = currentDelta;
      }
    }

    return List<PatternPoint>.unmodifiable(hits);
  }

  PatternPoint singleIntersection(
    Iterable<CubicBezierCurve> curves,
    double targetY, {
    double tolerance = 1e-9,
    int samplesPerCurve = 512,
  }) {
    final hits = intersections(
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

  PatternPoint _bisect(
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
        return point;
      }
      if (delta.sign == lowDelta.sign) {
        low = mid;
        lowDelta = delta;
      } else {
        high = mid;
      }
    }

    return curve.pointAt((low + high) * 0.5);
  }

  void _addUnique(
    List<PatternPoint> points,
    PatternPoint candidate,
    double tolerance,
  ) {
    if (points.any((point) => point.distanceTo(candidate) <= tolerance * 10.0)) {
      return;
    }
    points.add(candidate);
  }
}
