import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_cutting_outline_builder.dart';
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

  test('actual front side-seam and hem offset polylines intersect', () {
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

    final hemIndex = parts.indexWhere(
      (part) => part.source is BezierSegment &&
          (part.source as BezierSegment).role == 'front_hem',
    );
    expect(hemIndex, greaterThan(0));
    final sidePart = parts[hemIndex - 1];
    final hemPart = parts[hemIndex];
    expect(sidePart.source, isA<BezierSegment>());
    expect((sidePart.source as BezierSegment).role, 'front_side_seam');

    expect(_polylineIntersections(sidePart.points, hemPart.points), isNotEmpty);
  });

  test('actual back side-seam and hem offset polylines intersect', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final outline = outlineBuilder.backLowerContour(draft);
    final parts = cuttingBuilder.prepareOffsetParts(
      outline,
      settings: settings,
      frontP10: draft[10],
      frontP11: draft[11],
      backP21: draft[21],
      backP22: draft[22],
    );

    final hemIndex = parts.indexWhere(
      (part) => part.source is BezierSegment &&
          (part.source as BezierSegment).role == 'back_hem',
    );
    expect(hemIndex, greaterThan(0));
    final sidePart = parts[hemIndex - 1];
    final hemPart = parts[hemIndex];
    expect(sidePart.source, isA<BezierSegment>());
    expect((sidePart.source as BezierSegment).role, 'back_side_seam');

    expect(_polylineIntersections(sidePart.points, hemPart.points), isNotEmpty);
  });
}

List<PatternPoint> _polylineIntersections(
  List<PatternPoint> first,
  List<PatternPoint> second,
) {
  final hits = <PatternPoint>[];
  for (var i = 0; i < first.length - 1; i++) {
    for (var j = 0; j < second.length - 1; j++) {
      final hit = _segmentIntersection(
        first[i],
        first[i + 1],
        second[j],
        second[j + 1],
      );
      if (hit != null) hits.add(hit);
    }
  }
  return hits;
}

PatternPoint? _segmentIntersection(
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
  final u = (qpx * ry - qpy * rx) / denominator;
  if (t < -1e-12 || t > 1.0 + 1e-12 || u < -1e-12 || u > 1.0 + 1e-12) {
    return null;
  }
  return PatternPoint(a.x + t * rx, a.y + t * ry);
}
