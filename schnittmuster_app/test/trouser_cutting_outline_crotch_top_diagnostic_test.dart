import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_cutting_outline_builder.dart';
import 'package:schnittmuster_app/trouser_cutting_outline_p6_transition.dart';
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
  // Test fixture only. Hose-v1 has no product seam-allowance defaults.
  const settings = TrouserSeamAllowanceSettings(
    enabled: true,
    normalCm: 1.5,
    waistCm: 1.0,
    hemCm: 3.0,
  );
  const outlineBuilder = TrouserOutlineBuilder();
  const cuttingBuilder = TrouserCuttingOutlineBuilder();
  const tolerance = 1e-9;

  List<TrouserOffsetPart> prepare(PatternPath outline, TrouserReferenceDraft d) =>
      cuttingBuilder.prepareOffsetParts(
        outline,
        settings: settings,
        frontP10: d[10],
        frontP11: d[11],
        backP21: d[21],
        backP22: d[22],
      );

  test('front P6 production transition equals independent exact miter', () {
    final d = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final parts = prepare(outlineBuilder.frontLowerContour(d), d);
    final crotchEnd = _lastRoleIndex(parts, 'front_crotch');
    final crotchPart = parts[crotchEnd];
    final topPart = parts[crotchEnd + 1];
    final crotch = crotchPart.source as BezierSegment;

    expect(topPart.source, isA<LineSegment>());
    expect(crotchPart.allowanceCm, settings.normalCm);
    expect(topPart.allowanceCm, settings.normalCm);
    expect(crotch.end.distanceTo(d[6]), lessThan(tolerance));

    final exactOffsetEnd = _exactLeftOffsetEnd(crotch, crotchPart.allowanceCm);
    expect(crotchPart.points.last.distanceTo(exactOffsetEnd), lessThan(tolerance));

    final tangent = crotch.end - crotch.control2;
    final expected = _infiniteLineIntersection(
      exactOffsetEnd,
      exactOffsetEnd + tangent,
      topPart.points[0],
      topPart.points[1],
    );
    final actual = cuttingBuilder.frontCrotchTopTransition(crotchPart, topPart);

    expect(actual.distanceTo(expected), lessThan(tolerance));
  });

  test('back crotch finite offset reaches infinite P21-P22 waist-offset line', () {
    final d = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final parts = prepare(outlineBuilder.backLowerContour(d), d);
    final crotchEnd = _lastRoleIndex(parts, 'back_crotch');
    final crotch = parts[crotchEnd];
    final waist = parts[crotchEnd + 1];

    expect(waist.source, isA<LineSegment>());
    expect(crotch.allowanceCm, settings.normalCm);
    expect(waist.allowanceCm, settings.waistCm);
    expect(crotch.allowanceCm, isNot(waist.allowanceCm));

    final hit = _polylineInfiniteLineIntersection(crotch.points, waist.points);
    expect(hit.x.isFinite && hit.y.isFinite, isTrue);
  });
}

PatternPoint _exactLeftOffsetEnd(BezierSegment curve, double distance) {
  final tangent = curve.end - curve.control2;
  final length = math.sqrt(tangent.x * tangent.x + tangent.y * tangent.y);
  if (length <= 1e-12) throw StateError('Expected non-zero Bezier end tangent.');
  final normal = PatternPoint(-tangent.y / length, tangent.x / length);
  return curve.end + normal * distance;
}

PatternPoint _infiniteLineIntersection(
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
  if (denominator.abs() <= 1e-12) {
    throw StateError('Expected fixture lines not to be parallel.');
  }
  final qpx = c.x - a.x;
  final qpy = c.y - a.y;
  final t = (qpx * sy - qpy * sx) / denominator;
  return PatternPoint(a.x + t * rx, a.y + t * ry);
}

int _lastRoleIndex(List<TrouserOffsetPart> parts, String role) {
  var result = -1;
  for (var i = 0; i < parts.length; i++) {
    final source = parts[i].source;
    if (source is BezierSegment && source.role == role) result = i;
  }
  expect(result, greaterThanOrEqualTo(0));
  return result;
}

PatternPoint _polylineInfiniteLineIntersection(
  List<PatternPoint> polyline,
  List<PatternPoint> line,
) {
  expect(line.length, 2);
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
