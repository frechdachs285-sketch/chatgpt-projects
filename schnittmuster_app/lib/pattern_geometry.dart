import 'dart:math' as math;

import 'pattern_models.dart';

class CubicBezierCurve {
  final PatternPoint start;
  final PatternPoint control1;
  final PatternPoint control2;
  final PatternPoint end;

  const CubicBezierCurve({
    required this.start,
    required this.control1,
    required this.control2,
    required this.end,
  });

  PatternPoint pointAt(double t) {
    final u = 1.0 - t;
    final uu = u * u;
    final tt = t * t;
    final uuu = uu * u;
    final ttt = tt * t;

    return PatternPoint(
      uuu * start.x +
          3 * uu * t * control1.x +
          3 * u * tt * control2.x +
          ttt * end.x,
      uuu * start.y +
          3 * uu * t * control1.y +
          3 * u * tt * control2.y +
          ttt * end.y,
    );
  }

  PatternPoint derivativeAt(double t) {
    final u = 1.0 - t;

    return PatternPoint(
      3 * u * u * (control1.x - start.x) +
          6 * u * t * (control2.x - control1.x) +
          3 * t * t * (end.x - control2.x),
      3 * u * u * (control1.y - start.y) +
          6 * u * t * (control2.y - control1.y) +
          3 * t * t * (end.y - control2.y),
    );
  }

  bool hasVerticalEndTangent({double tolerance = 0.000001}) {
    final tangent = derivativeAt(1.0);
    return tangent.x.abs() <= tolerance && tangent.y.abs() > tolerance;
  }

  double maxDeviationFromChord({int samples = 4000}) {
    final chordX = end.x - start.x;
    final chordY = end.y - start.y;
    final chordLength = math.sqrt(chordX * chordX + chordY * chordY);

    if (chordLength == 0) {
      throw ArgumentError('Start- und Endpunkt duerfen nicht identisch sein.');
    }

    var maxDeviation = 0.0;

    for (var i = 0; i <= samples; i++) {
      final point = pointAt(i / samples);
      final relativeX = point.x - start.x;
      final relativeY = point.y - start.y;
      final cross = relativeX * chordY - relativeY * chordX;
      final deviation = (cross / chordLength).abs();
      maxDeviation = math.max(maxDeviation, deviation);
    }

    return maxDeviation;
  }
}

class SideSeamCurveValidationResult {
  final List<String> errors;

  const SideSeamCurveValidationResult(this.errors);

  bool get isValid => errors.isEmpty;
}

class SideSeamCurveValidator {
  const SideSeamCurveValidator();

  SideSeamCurveValidationResult validate({
    required CubicBezierCurve curve,
    required PatternPoint expectedStart,
    required PatternPoint expectedEnd,
    required double expectedMaxDeviation,
    double pointTolerance = 0.000001,
    double deviationTolerance = 0.002,
  }) {
    final errors = <String>[];

    if (curve.start.distanceTo(expectedStart) > pointTolerance) {
      errors.add('Startpunkt stimmt nicht.');
    }

    if (curve.end.distanceTo(expectedEnd) > pointTolerance) {
      errors.add('Endpunkt stimmt nicht.');
    }

    if (!curve.hasVerticalEndTangent(tolerance: pointTolerance)) {
      errors.add('Endtangente ist nicht vertikal.');
    }

    final deviation = curve.maxDeviationFromChord();
    if ((deviation - expectedMaxDeviation).abs() > deviationTolerance) {
      errors.add('Maximale Ausformung stimmt nicht.');
    }

    return SideSeamCurveValidationResult(errors);
  }
}
