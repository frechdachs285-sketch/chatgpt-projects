import 'dart:math' as math;

import 'bezier_arc_length_fitter.dart';
import 'pattern_geometry.dart';
import 'pattern_models.dart';

class WaistCurveBuilder {
  const WaistCurveBuilder();

  CubicBezierCurve build({
    required PatternPoint centerPoint,
    required PatternPoint closedSidePoint,
    required PatternPoint originalSideSeamStartTangent,
    required double cumulativeDartClosureAngle,
    required double targetLength,
  }) {
    final chord = closedSidePoint - centerPoint;
    if (chord.distanceTo(const PatternPoint(0, 0)) == 0) {
      throw ArgumentError('Taillen-Endpunkte duerfen nicht identisch sein.');
    }

    final startTangent = PatternPoint(chord.x.sign, 0);
    final rotatedSideTangent = _rotateVector(
      originalSideSeamStartTangent,
      cumulativeDartClosureAngle,
    );
    final endTangent = _perpendicularTowardChord(rotatedSideTangent, chord);

    return const CubicBezierArcLengthFitter().fit(
      start: centerPoint,
      end: closedSidePoint,
      startTangent: startTangent,
      endTangent: endTangent,
      targetLength: targetLength,
    );
  }

  PatternPoint _rotateVector(PatternPoint vector, double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return PatternPoint(
      vector.x * cosA - vector.y * sinA,
      vector.x * sinA + vector.y * cosA,
    );
  }

  PatternPoint _perpendicularTowardChord(
    PatternPoint sideTangent,
    PatternPoint chord,
  ) {
    final candidateA = PatternPoint(-sideTangent.y, sideTangent.x);
    final candidateB = candidateA * -1;

    final dotA = candidateA.x * chord.x + candidateA.y * chord.y;
    final dotB = candidateB.x * chord.x + candidateB.y * chord.y;

    return dotA >= dotB ? candidateA : candidateB;
  }
}
