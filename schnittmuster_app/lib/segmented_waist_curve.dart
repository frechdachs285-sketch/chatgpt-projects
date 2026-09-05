import 'dart:math' as math;

import 'pattern_geometry.dart';
import 'pattern_models.dart';
import 'waist_dart_closure.dart';

class SegmentedWaistCurveResult {
  final PatternPoint correctedSidePoint;
  final PatternPoint closedSidePoint;
  final List<PatternPoint> closedDartMouths;
  final List<CubicBezierCurve> segments;
  final double horizontalShift;
  final double totalLength;

  const SegmentedWaistCurveResult({
    required this.correctedSidePoint,
    required this.closedSidePoint,
    required this.closedDartMouths,
    required this.segments,
    required this.horizontalShift,
    required this.totalLength,
  });
}

class SegmentedWaistCurveSolver {
  const SegmentedWaistCurveSolver();

  SegmentedWaistCurveResult solve({
    required PatternPoint centerPoint,
    required PatternPoint sidePoint,
    required PatternPoint hipPoint,
    required List<Dart> dartsFromCenterToSide,
    required double targetLength,
    double tolerance = 0.000001,
  }) {
    final directionToCenter = (centerPoint.x - sidePoint.x).sign;
    if (directionToCenter == 0) {
      throw ArgumentError('Seitlicher Taillenpunkt muss horizontal von der Mitte getrennt sein.');
    }

    SegmentedWaistCurveResult buildFor(double shift) {
      final correctedSidePoint = PatternPoint(
        sidePoint.x + directionToCenter * shift,
        sidePoint.y,
      );

      final closure = const WaistDartClosure().close(
        sidePoint: correctedSidePoint,
        dartsFromCenterToSide: dartsFromCenterToSide,
      );

      final anchors = <PatternPoint>[
        centerPoint,
        ...closure.closedDartMouths,
        closure.closedSidePoint,
      ];

      final cumulativeAngle = closure.closureAngles.fold<double>(
        0,
        (sum, angle) => sum + angle,
      );

      final originalSideTangent =
          const SideSeamCurveBuilder()
              .build(start: correctedSidePoint, end: hipPoint)
              .derivativeAt(0);
      final rotatedSideTangent = _rotateVector(
        originalSideTangent,
        cumulativeAngle,
      );

      final derivatives = _anchorDerivatives(
        anchors: anchors,
        rotatedSideTangent: rotatedSideTangent,
      );

      final segments = <CubicBezierCurve>[];
      var totalLength = 0.0;

      for (var i = 0; i < anchors.length - 1; i++) {
        final curve = CubicBezierCurve(
          start: anchors[i],
          control1: anchors[i] + derivatives[i] * (1 / 3),
          control2: anchors[i + 1] - derivatives[i + 1] * (1 / 3),
          end: anchors[i + 1],
        );
        segments.add(curve);
        totalLength += curve.arcLength();
      }

      return SegmentedWaistCurveResult(
        correctedSidePoint: correctedSidePoint,
        closedSidePoint: closure.closedSidePoint,
        closedDartMouths: closure.closedDartMouths,
        segments: segments,
        horizontalShift: shift,
        totalLength: totalLength,
      );
    }

    final original = buildFor(0);
    if (original.totalLength < targetLength - tolerance) {
      throw StateError('Die Taillenkurve ist bereits kuerzer als das Ziel.');
    }
    if ((original.totalLength - targetLength).abs() <= tolerance) {
      return original;
    }

    var low = 0.0;
    var high = 0.01;
    var highResult = buildFor(high);
    while (highResult.totalLength > targetLength) {
      high *= 2;
      if (high > 5.0) {
        throw StateError('Taillenkurve konnte nicht auf die Ziel-Laenge eingestellt werden.');
      }
      highResult = buildFor(high);
    }

    for (var i = 0; i < 70; i++) {
      final mid = (low + high) * 0.5;
      final result = buildFor(mid);
      if (result.totalLength > targetLength) {
        low = mid;
      } else {
        high = mid;
      }
    }

    final result = buildFor((low + high) * 0.5);
    if ((result.totalLength - targetLength).abs() > tolerance * 10) {
      throw StateError('Ziel-Laenge der Taillenkurve wurde nicht ausreichend genau erreicht.');
    }
    return result;
  }

  List<PatternPoint> _anchorDerivatives({
    required List<PatternPoint> anchors,
    required PatternPoint rotatedSideTangent,
  }) {
    if (anchors.length < 2) {
      throw ArgumentError('Mindestens zwei Taillenanker sind erforderlich.');
    }

    final derivatives = List<PatternPoint>.filled(
      anchors.length,
      const PatternPoint(0, 0),
    );

    final firstChord = anchors[1] - anchors[0];
    derivatives[0] = PatternPoint(
      firstChord.x.sign * firstChord.distanceTo(const PatternPoint(0, 0)),
      0,
    );

    for (var i = 1; i < anchors.length - 1; i++) {
      derivatives[i] = (anchors[i + 1] - anchors[i - 1]) * 0.5;
    }

    final lastChord = anchors.last - anchors[anchors.length - 2];
    final lastMagnitude = lastChord.distanceTo(const PatternPoint(0, 0));
    final perpendicular = PatternPoint(
      -rotatedSideTangent.y,
      rotatedSideTangent.x,
    );
    final normalizedPerpendicular = _normalizedToward(perpendicular, lastChord);
    derivatives[anchors.length - 1] = normalizedPerpendicular * lastMagnitude;

    return derivatives;
  }

  PatternPoint _rotateVector(PatternPoint vector, double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return PatternPoint(
      vector.x * cosA - vector.y * sinA,
      vector.x * sinA + vector.y * cosA,
    );
  }

  PatternPoint _normalizedToward(PatternPoint vector, PatternPoint toward) {
    var candidate = vector;
    final dot = candidate.x * toward.x + candidate.y * toward.y;
    if (dot < 0) candidate = candidate * -1;

    final length = candidate.distanceTo(const PatternPoint(0, 0));
    if (length == 0) {
      throw ArgumentError('Tangentenvektor darf nicht 0 sein.');
    }
    return candidate * (1 / length);
  }
}
