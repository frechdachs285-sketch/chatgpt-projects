import 'dart:math' as math;

import 'pattern_geometry.dart';
import 'pattern_models.dart';
import 'segmented_waist_curve.dart';

class _ClosureTransform {
  final PatternPoint apex;
  final double angle;

  const _ClosureTransform({required this.apex, required this.angle});
}

class WaistCurveUnfolder {
  const WaistCurveUnfolder();

  List<CubicBezierCurve> unfold({
    required SegmentedWaistCurveResult closedCurve,
    required List<Dart> dartsFromCenterToSide,
  }) {
    if (closedCurve.segments.length != dartsFromCenterToSide.length + 1) {
      throw ArgumentError(
        'Anzahl der Taillensegmente passt nicht zur Anzahl der Abnaeher.',
      );
    }

    final transforms = _closureTransforms(dartsFromCenterToSide);
    final result = <CubicBezierCurve>[];

    for (var segmentIndex = 0;
        segmentIndex < closedCurve.segments.length;
        segmentIndex++) {
      var curve = closedCurve.segments[segmentIndex];

      for (var transformIndex = segmentIndex - 1;
          transformIndex >= 0;
          transformIndex--) {
        final transform = transforms[transformIndex];
        curve = _rotateCurve(
          curve,
          transform.apex,
          -transform.angle,
        );
      }

      result.add(curve);
    }

    return result;
  }

  List<_ClosureTransform> _closureTransforms(
    List<Dart> dartsFromCenterToSide,
  ) {
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

    final transforms = <_ClosureTransform>[];

    for (var i = 0; i < workingDarts.length; i++) {
      final dart = workingDarts[i];
      final angle = _normalizeAngle(
        _angle(dart.leg1 - dart.apex) -
            _angle(dart.leg2 - dart.apex),
      );

      transforms.add(_ClosureTransform(apex: dart.apex, angle: angle));

      for (var j = i + 1; j < workingDarts.length; j++) {
        final later = workingDarts[j];
        workingDarts[j] = Dart(
          center: _rotatePoint(later.center, dart.apex, angle),
          apex: _rotatePoint(later.apex, dart.apex, angle),
          leg1: _rotatePoint(later.leg1, dart.apex, angle),
          leg2: _rotatePoint(later.leg2, dart.apex, angle),
          width: later.width,
          length: later.length,
        );
      }
    }

    return transforms;
  }

  CubicBezierCurve _rotateCurve(
    CubicBezierCurve curve,
    PatternPoint center,
    double angle,
  ) {
    return CubicBezierCurve(
      start: _rotatePoint(curve.start, center, angle),
      control1: _rotatePoint(curve.control1, center, angle),
      control2: _rotatePoint(curve.control2, center, angle),
      end: _rotatePoint(curve.end, center, angle),
    );
  }

  PatternPoint _rotatePoint(
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

  double _angle(PatternPoint vector) => math.atan2(vector.y, vector.x);

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
