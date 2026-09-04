import 'dart:math' as math;

import 'pattern_models.dart';

class WaistDartClosureResult {
  final PatternPoint closedSidePoint;
  final List<PatternPoint> closedDartMouths;
  final List<double> closureAngles;

  const WaistDartClosureResult({
    required this.closedSidePoint,
    required this.closedDartMouths,
    required this.closureAngles,
  });
}

class WaistDartClosure {
  const WaistDartClosure();

  WaistDartClosureResult close({
    required PatternPoint sidePoint,
    required List<Dart> dartsFromCenterToSide,
  }) {
    var workingSidePoint = sidePoint;
    final workingDarts = dartsFromCenterToSide
        .map(
          (dart) => Dart(
            center: dart.center,
            apex: dart.apex,
            leg1: dart.leg1,
            leg2: dart.leg2,
            width: dart.width,
            length: dart.length,
          ),
        )
        .toList();

    final mouths = <PatternPoint>[];
    final angles = <double>[];

    for (var i = 0; i < workingDarts.length; i++) {
      final dart = workingDarts[i];
      final leg1Length = dart.apex.distanceTo(dart.leg1);
      final leg2Length = dart.apex.distanceTo(dart.leg2);

      if ((leg1Length - leg2Length).abs() > 0.000001) {
        throw ArgumentError('Abnaeher-Schenkel muessen gleich lang sein.');
      }

      // Die innere Schenkelseite bleibt beim Schliessen fest. Genau dieser
      // Punkt ist die Taillen-Muendung des geschlossenen Abnaehers.
      mouths.add(dart.leg1);

      final angleToClose = _angle(dart.leg1 - dart.apex) -
          _angle(dart.leg2 - dart.apex);
      angles.add(_normalizeAngle(angleToClose));

      workingSidePoint = _rotateAround(
        workingSidePoint,
        dart.apex,
        angleToClose,
      );

      for (var j = i + 1; j < workingDarts.length; j++) {
        final later = workingDarts[j];
        workingDarts[j] = Dart(
          center: _rotateAround(later.center, dart.apex, angleToClose),
          apex: _rotateAround(later.apex, dart.apex, angleToClose),
          leg1: _rotateAround(later.leg1, dart.apex, angleToClose),
          leg2: _rotateAround(later.leg2, dart.apex, angleToClose),
          width: later.width,
          length: later.length,
        );
      }
    }

    return WaistDartClosureResult(
      closedSidePoint: workingSidePoint,
      closedDartMouths: mouths,
      closureAngles: angles,
    );
  }

  double _angle(PatternPoint vector) => math.atan2(vector.y, vector.x);

  PatternPoint _rotateAround(
    PatternPoint point,
    PatternPoint center,
    double angle,
  ) {
    final translated = point - center;
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);

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
