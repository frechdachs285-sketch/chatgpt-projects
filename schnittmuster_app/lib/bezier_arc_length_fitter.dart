import 'dart:math' as math;

import 'pattern_geometry.dart';
import 'pattern_models.dart';

class CubicBezierArcLengthFitter {
  const CubicBezierArcLengthFitter();

  CubicBezierCurve fit({
    required PatternPoint start,
    required PatternPoint end,
    required PatternPoint startTangent,
    required PatternPoint endTangent,
    required double targetLength,
    double tolerance = 0.000001,
  }) {
    final chordLength = start.distanceTo(end);
    if (targetLength + tolerance < chordLength) {
      throw ArgumentError(
        'Die Ziel-Bogenlaenge darf nicht kuerzer als die direkte Strecke sein.',
      );
    }

    final startDirection = _normalized(startTangent);
    final endDirection = _normalized(endTangent);

    CubicBezierCurve curveFor(double handleLength) {
      return CubicBezierCurve(
        start: start,
        control1: start + startDirection * handleLength,
        control2: end - endDirection * handleLength,
        end: end,
      );
    }

    final minimumCurve = curveFor(0);
    final minimumLength = minimumCurve.arcLength();
    if ((minimumLength - targetLength).abs() <= tolerance) {
      return minimumCurve;
    }

    var low = 0.0;
    var high = math.max(chordLength / 8, 0.001);
    var highLength = curveFor(high).arcLength();

    while (highLength < targetLength) {
      high *= 2;
      if (high > chordLength * 100 + 100) {
        throw StateError(
          'Fuer die vorgegebenen Tangenten konnte die Ziel-Bogenlaenge nicht erreicht werden.',
        );
      }
      highLength = curveFor(high).arcLength();
    }

    for (var i = 0; i < 70; i++) {
      final mid = (low + high) / 2;
      final length = curveFor(mid).arcLength();
      if (length < targetLength) {
        low = mid;
      } else {
        high = mid;
      }
    }

    final result = curveFor((low + high) / 2);
    if ((result.arcLength() - targetLength).abs() > tolerance * 10) {
      throw StateError('Ziel-Bogenlaenge wurde nicht ausreichend genau erreicht.');
    }
    return result;
  }

  PatternPoint _normalized(PatternPoint vector) {
    final length = math.sqrt(vector.x * vector.x + vector.y * vector.y);
    if (length == 0) {
      throw ArgumentError('Tangentenvektor darf nicht 0 sein.');
    }
    return PatternPoint(vector.x / length, vector.y / length);
  }
}
