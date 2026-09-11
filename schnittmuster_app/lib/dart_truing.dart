import 'dart:math' as math;

import 'pattern_models.dart';

class DartTruingResult {
  final PatternPoint rotatedLeg1;
  final PatternPoint targetLeg2;
  final double leg1Length;
  final double leg2Length;
  final double closureAngleRadians;
  final double closureError;

  const DartTruingResult({
    required this.rotatedLeg1,
    required this.targetLeg2,
    required this.leg1Length,
    required this.leg2Length,
    required this.closureAngleRadians,
    required this.closureError,
  });

  bool isClosed({double tolerance = 0.000001}) => closureError <= tolerance;

  bool hasEqualLegLengths({double tolerance = 0.000001}) =>
      (leg1Length - leg2Length).abs() <= tolerance;
}

class DartTruer {
  const DartTruer();

  DartTruingResult close(Dart dart) {
    final leg1Vector = dart.leg1 - dart.apex;
    final leg2Vector = dart.leg2 - dart.apex;

    final leg1Length = dart.apex.distanceTo(dart.leg1);
    final leg2Length = dart.apex.distanceTo(dart.leg2);

    if (leg1Length == 0 || leg2Length == 0) {
      throw ArgumentError('Abnaeher-Schenkel duerfen nicht die Spitze treffen.');
    }

    final angle1 = math.atan2(leg1Vector.y, leg1Vector.x);
    final angle2 = math.atan2(leg2Vector.y, leg2Vector.x);
    final closureAngle = _normalizeAngle(angle2 - angle1);

    final rotatedLeg1 = _rotateAround(
      point: dart.leg1,
      center: dart.apex,
      angleRadians: closureAngle,
    );

    return DartTruingResult(
      rotatedLeg1: rotatedLeg1,
      targetLeg2: dart.leg2,
      leg1Length: leg1Length,
      leg2Length: leg2Length,
      closureAngleRadians: closureAngle,
      closureError: rotatedLeg1.distanceTo(dart.leg2),
    );
  }

  PatternPoint _rotateAround({
    required PatternPoint point,
    required PatternPoint center,
    required double angleRadians,
  }) {
    final translated = point - center;
    final cosA = math.cos(angleRadians);
    final sinA = math.sin(angleRadians);

    return PatternPoint(
      center.x + translated.x * cosA - translated.y * sinA,
      center.y + translated.x * sinA + translated.y * cosA,
    );
  }

  double _normalizeAngle(double angle) {
    var result = angle;
    while (result <= -math.pi) {
      result += 2 * math.pi;
    }
    while (result > math.pi) {
      result -= 2 * math.pi;
    }
    return result;
  }
}
