import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_cutting_outline_builder.dart';
import 'package:schnittmuster_app/trouser_cutting_outline_p11_transition.dart';
import 'package:schnittmuster_app/trouser_outline_builder.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';
import 'package:schnittmuster_app/trouser_seam_allowance.dart';

void main() {
  const measurements = TrouserMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    bodyRise: 28.7,
    waistToFloor: 105.0,
    trouserBottomWidth: 22.0,
  );
  const settings = TrouserSeamAllowanceSettings(
    enabled: true,
    normalCm: 1.5,
    waistCm: 1.0,
    hemCm: 3.0,
  );
  const outlineBuilder = TrouserOutlineBuilder();
  const cuttingBuilder = TrouserCuttingOutlineBuilder();
  const tolerance = 1e-9;

  test('actual front P11 transition uses finite side offset and infinite waist line', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final outline = outlineBuilder.frontLowerContour(draft);
    final parts = cuttingBuilder.prepareOffsetParts(
      outline,
      settings: settings,
      frontP10: draft[10],
      frontP11: draft[11],
      backP21: draft[21],
      backP22: draft[22],
    );

    final sidePart = parts.first;
    final waistPart = parts.last;
    expect((sidePart.source as BezierSegment).role, 'front_side_seam');
    expect(waistPart.source, isA<LineSegment>());

    final expected = _polylineInfiniteLineIntersection(
      sidePart.points,
      waistPart.points,
    );
    final actual = cuttingBuilder.frontP11Transition(waistPart, sidePart);

    expect(actual.distanceTo(expected), lessThan(tolerance));
  });

  test('frontP11Transition rejects reversed part order', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final outline = outlineBuilder.frontLowerContour(draft);
    final parts = cuttingBuilder.prepareOffsetParts(
      outline,
      settings: settings,
      frontP10: draft[10],
      frontP11: draft[11],
      backP21: draft[21],
      backP22: draft[22],
    );

    expect(
      () => cuttingBuilder.frontP11Transition(parts.first, parts.last),
      throwsArgumentError,
    );
  });
}

PatternPoint _polylineInfiniteLineIntersection(
  List<PatternPoint> polyline,
  List<PatternPoint> line,
) {
  for (var i = 0; i < polyline.length - 1; i++) {
    final hit = _segmentInfiniteLineIntersection(
      polyline[i],
      polyline[i + 1],
      line[0],
      line[1],
    );
    if (hit != null) return hit;
  }
  throw StateError('Expected fixture polyline and infinite line to intersect.');
}

PatternPoint? _segmentInfiniteLineIntersection(
  PatternPoint a,
  PatternPoint b,
  PatternPoint c,
  PatternPoint d,
) {
  final rx = b.x - a.x;
  final ry = b.y - a.y;
  final sx = d.x - c.x;
  final sy = d.y - c.y;
  final denominator = rx * sy - ry * sx;
  if (denominator.abs() <= 1e-12) return null;
  final qpx = c.x - a.x;
  final qpy = c.y - a.y;
  final t = (qpx * sy - qpy * sx) / denominator;
  if (t < -1e-12 || t > 1.0 + 1e-12) return null;
  return PatternPoint(a.x + t * rx, a.y + t * ry);
}
