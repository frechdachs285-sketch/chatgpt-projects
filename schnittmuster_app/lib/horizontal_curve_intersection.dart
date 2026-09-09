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
      var previousT = 0.0;
      var previous = curve.pointAt(previousT);
      var previousDelta = previous.y - targetY;

      if (previousDelta.abs() <= tolerance) {
        _addUniqueHit(
          hits,
          HorizontalCurveHit(
            curve: curve,
            curveIndex: curveIndex,
            t: previousT,
            point: previous,
          ),
          tolerance,
        );
      }

      for (var i = 1; i <= samplesPerCurve; i++) {
        final currentT = i / samplesPerCurve;
        final current = curve.pointAt(currentT);
        final currentDelta = current.y - targetY;

        if (currentDelta.abs() <= tolerance) {
          _addUniqueHit(
            hits,
            HorizontalCurveHit(
              curve: curve,
              curveIndex: curveIndex,
              t: currentT,
              point: current,
            ),
            tolerance,
          );
        } else if (previousDelta == 0.0 || currentDelta.sign != previousDelta.sign) {
          final t = _bisectT(
            curve,
            targetY,
            previousT,
            currentT,
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

        previousT = currentT;
        previous = current;
        previousDelta = currentDelta;
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
