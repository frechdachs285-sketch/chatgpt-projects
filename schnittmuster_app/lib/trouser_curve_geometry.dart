import 'dart:math' as math;

import 'pattern_geometry.dart';
import 'pattern_models.dart';

/// Digital curve representation used by Hose v1.
///
/// The construction points come from Aldrich. The interpolation between
/// those points is an app-specific digitization rule: a natural parametric
/// cubic spline with chord-length parameterization.
class TrouserNaturalSpline {
  final List<PatternPoint> knots;
  final List<double> parameters;
  final List<CubicBezierCurve> segments;

  const TrouserNaturalSpline({
    required this.knots,
    required this.parameters,
    required this.segments,
  });

  double get arcLength =>
      segments.fold(0.0, (sum, curve) => sum + curve.arcLength(samples: 1200));
}

class TrouserCurveBuilder {
  const TrouserCurveBuilder();

  TrouserNaturalSpline naturalSplineThrough(List<PatternPoint> points) {
    if (points.length < 2) {
      throw ArgumentError('Mindestens zwei Kurvenpunkte werden benoetigt.');
    }

    final knots = List<PatternPoint>.unmodifiable(points);
    final t = <double>[0.0];
    for (var i = 1; i < knots.length; i++) {
      final chord = knots[i - 1].distanceTo(knots[i]);
      if (!chord.isFinite || chord <= 1e-9) {
        throw ArgumentError('Aufeinanderfolgende Kurvenpunkte muessen verschieden sein.');
      }
      t.add(t.last + chord);
    }

    final mx = _naturalSecondDerivatives(
      t,
      [for (final point in knots) point.x],
    );
    final my = _naturalSecondDerivatives(
      t,
      [for (final point in knots) point.y],
    );

    final segments = <CubicBezierCurve>[];
    for (var i = 0; i < knots.length - 1; i++) {
      final h = t[i + 1] - t[i];
      final dx0 = (knots[i + 1].x - knots[i].x) / h -
          h * (2 * mx[i] + mx[i + 1]) / 6.0;
      final dy0 = (knots[i + 1].y - knots[i].y) / h -
          h * (2 * my[i] + my[i + 1]) / 6.0;
      final dx1 = (knots[i + 1].x - knots[i].x) / h +
          h * (mx[i] + 2 * mx[i + 1]) / 6.0;
      final dy1 = (knots[i + 1].y - knots[i].y) / h +
          h * (my[i] + 2 * my[i + 1]) / 6.0;

      segments.add(
        CubicBezierCurve(
          start: knots[i],
          control1: PatternPoint(
            knots[i].x + h * dx0 / 3.0,
            knots[i].y + h * dy0 / 3.0,
          ),
          control2: PatternPoint(
            knots[i + 1].x - h * dx1 / 3.0,
            knots[i + 1].y - h * dy1 / 3.0,
          ),
          end: knots[i + 1],
        ),
      );
    }

    return TrouserNaturalSpline(
      knots: knots,
      parameters: List<double>.unmodifiable(t),
      segments: List<CubicBezierCurve>.unmodifiable(segments),
    );
  }

  /// Front side seam through the fixed Aldrich points P11-P8-P13-P12.
  TrouserNaturalSpline frontSideSeam({
    required PatternPoint p11,
    required PatternPoint p8,
    required PatternPoint p13,
    required PatternPoint p12,
  }) {
    return naturalSplineThrough([p11, p8, p13, p12]);
  }

  /// Back side seam through P22-P25, the digital 0.5 cm inward form point
  /// between P25 and P27, then P27-P26.
  TrouserNaturalSpline backSideSeam({
    required PatternPoint p22,
    required PatternPoint p25,
    required PatternPoint p27,
    required PatternPoint p26,
  }) {
    final shaping = backSideShapingCurve(
      start: p25,
      end: p27,
      depth: 0.5,
    );
    final q = shaping.pointAt(0.5);
    return naturalSplineThrough([p22, p25, q, p27, p26]);
  }

  /// Hose-v1 back-side shaping: 0.5 cm inward at the chord midpoint.
  /// On the right-hand back side seam, inward is the normal with negative x.
  CubicBezierCurve backSideShapingCurve({
    required PatternPoint start,
    required PatternPoint end,
    required double depth,
  }) =>
      _midpointCurve(
        start: start,
        end: end,
        depth: depth,
        positiveXNormal: false,
      );

  /// App digitization for the left-hand inseams.
  /// Inward is the normal with positive x.
  CubicBezierCurve inwardMidpointCurve({
    required PatternPoint start,
    required PatternPoint end,
    required double depth,
  }) =>
      _midpointCurve(
        start: start,
        end: end,
        depth: depth,
        positiveXNormal: true,
      );

  CubicBezierCurve _midpointCurve({
    required PatternPoint start,
    required PatternPoint end,
    required double depth,
    required bool positiveXNormal,
  }) {
    if (!depth.isFinite || depth <= 0.0) {
      throw ArgumentError('Die Einformung muss endlich und groesser als 0 sein.');
    }

    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final length = math.sqrt(dx * dx + dy * dy);
    if (!length.isFinite || length <= 1e-9) {
      throw ArgumentError('Start- und Endpunkt muessen verschieden sein.');
    }

    var nx = -dy / length;
    var ny = dx / length;
    if ((positiveXNormal && nx < 0.0) || (!positiveXNormal && nx > 0.0)) {
      nx = -nx;
      ny = -ny;
    }

    final midpoint = PatternPoint(
      (start.x + end.x) / 2.0,
      (start.y + end.y) / 2.0,
    );
    final formPoint = PatternPoint(
      midpoint.x + nx * depth,
      midpoint.y + ny * depth,
    );

    final quadraticControl = PatternPoint(
      2.0 * formPoint.x - 0.5 * (start.x + end.x),
      2.0 * formPoint.y - 0.5 * (start.y + end.y),
    );

    return CubicBezierCurve(
      start: start,
      control1: PatternPoint(
        start.x + (2.0 / 3.0) * (quadraticControl.x - start.x),
        start.y + (2.0 / 3.0) * (quadraticControl.y - start.y),
      ),
      control2: PatternPoint(
        end.x + (2.0 / 3.0) * (quadraticControl.x - end.x),
        end.y + (2.0 / 3.0) * (quadraticControl.y - end.y),
      ),
      end: end,
    );
  }

  /// Exact symmetric Hose-v1 hem parabola.
  CubicBezierCurve symmetricHemParabola({
    required PatternPoint left,
    required PatternPoint center,
    required PatternPoint right,
  }) {
    const tolerance = 1e-9;
    if ((left.y - right.y).abs() > tolerance) {
      throw ArgumentError('Die Saum-Endpunkte muessen auf gleicher Hoehe liegen.');
    }
    if ((center.x - (left.x + right.x) / 2.0).abs() > tolerance) {
      throw ArgumentError('P3 muss horizontal exakt in der Saummitte liegen.');
    }
    if (center.y <= left.y) {
      throw ArgumentError('P3 muss unterhalb der Saum-Endpunkte liegen.');
    }

    final quadraticControl = PatternPoint(
      2.0 * center.x - 0.5 * (left.x + right.x),
      2.0 * center.y - 0.5 * (left.y + right.y),
    );

    return CubicBezierCurve(
      start: left,
      control1: PatternPoint(
        left.x + (2.0 / 3.0) * (quadraticControl.x - left.x),
        left.y + (2.0 / 3.0) * (quadraticControl.y - left.y),
      ),
      control2: PatternPoint(
        right.x + (2.0 / 3.0) * (quadraticControl.x - right.x),
        right.y + (2.0 / 3.0) * (quadraticControl.y - right.y),
      ),
      end: right,
    );
  }

  CubicBezierCurve frontHem({
    required PatternPoint p14,
    required PatternPoint p3,
    required PatternPoint p12,
  }) =>
      symmetricHemParabola(left: p14, center: p3, right: p12);

  CubicBezierCurve backHem({
    required PatternPoint p28,
    required PatternPoint p3,
    required PatternPoint p26,
  }) =>
      symmetricHemParabola(left: p28, center: p3, right: p26);

  /// Aldrich size 10-14 front crotch control point: 3.0 cm from P5 along
  /// the 45-degree construction line shown in the source drawing.
  PatternPoint frontCrotchGuide(PatternPoint p5) {
    final offset = 3.0 / math.sqrt(2.0);
    return PatternPoint(p5.x - offset, p5.y - offset);
  }

  /// Aldrich size 10-14 back crotch control point: 4.25 cm from P16 along
  /// the 45-degree construction line shown in the source drawing.
  PatternPoint backCrotchGuide(PatternPoint p16) {
    final offset = 4.25 / math.sqrt(2.0);
    return PatternPoint(p16.x - offset, p16.y - offset);
  }

  List<double> _naturalSecondDerivatives(List<double> t, List<double> values) {
    final n = values.length;
    if (n == 2) return const [0.0, 0.0];

    final interior = n - 2;
    final lower = List<double>.filled(interior, 0.0);
    final diagonal = List<double>.filled(interior, 0.0);
    final upper = List<double>.filled(interior, 0.0);
    final rhs = List<double>.filled(interior, 0.0);

    for (var j = 0; j < interior; j++) {
      final i = j + 1;
      final h0 = t[i] - t[i - 1];
      final h1 = t[i + 1] - t[i];
      lower[j] = j == 0 ? 0.0 : h0;
      diagonal[j] = 2.0 * (h0 + h1);
      upper[j] = j == interior - 1 ? 0.0 : h1;
      rhs[j] = 6.0 *
          ((values[i + 1] - values[i]) / h1 -
              (values[i] - values[i - 1]) / h0);
    }

    for (var i = 1; i < interior; i++) {
      final factor = lower[i] / diagonal[i - 1];
      diagonal[i] -= factor * upper[i - 1];
      rhs[i] -= factor * rhs[i - 1];
    }

    final interiorSolution = List<double>.filled(interior, 0.0);
    interiorSolution[interior - 1] = rhs[interior - 1] / diagonal[interior - 1];
    for (var i = interior - 2; i >= 0; i--) {
      interiorSolution[i] =
          (rhs[i] - upper[i] * interiorSolution[i + 1]) / diagonal[i];
    }

    return <double>[
      0.0,
      ...interiorSolution,
      0.0,
    ];
  }
}
