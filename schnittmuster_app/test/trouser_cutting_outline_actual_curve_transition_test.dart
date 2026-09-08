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

  List<TrouserOffsetPart> prepareParts(PatternPath outline, TrouserReferenceDraft draft) =>
      cuttingBuilder.prepareOffsetParts(
        outline,
        settings: settings,
        frontP10: draft[10],
        frontP11: draft[11],
        backP21: draft[21],
        backP22: draft[22],
      );

  test('actual front side-seam to hem transition uses finite offset crossing', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final parts = prepareParts(outlineBuilder.frontLowerContour(draft), draft);
    final hemIndex = _hemIndex(parts, 'front_hem');
    final sidePart = parts[hemIndex - 1];
    final hemPart = parts[hemIndex];
    expect((sidePart.source as BezierSegment).role, 'front_side_seam');
    final expected = _firstIntersection(sidePart.points, hemPart.points);
    final actual = cuttingBuilder.sideHemTransition(sidePart, hemPart);
    expect(actual.distanceTo(expected), lessThan(tolerance));
  });

  test('actual back side-seam to hem transition uses finite offset crossing', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final parts = prepareParts(outlineBuilder.backLowerContour(draft), draft);
    final hemIndex = _hemIndex(parts, 'back_hem');
    final sidePart = parts[hemIndex - 1];
    final hemPart = parts[hemIndex];
    expect((sidePart.source as BezierSegment).role, 'back_side_seam');
    final expected = _firstIntersection(sidePart.points, hemPart.points);
    final actual = cuttingBuilder.sideHemTransition(sidePart, hemPart);
    expect(actual.distanceTo(expected), lessThan(tolerance));
  });

  test('actual front hem to lower inseam uses finite hem and infinite line', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final parts = prepareParts(outlineBuilder.frontLowerContour(draft), draft);
    final hemIndex = _hemIndex(parts, 'front_hem');
    final hemPart = parts[hemIndex];
    final lowerInseamPart = parts[hemIndex + 1];
    expect(lowerInseamPart.source, isA<LineSegment>());
    final expected = _polylineInfiniteLineIntersection(hemPart.points, lowerInseamPart.points);
    final actual = cuttingBuilder.hemLowerInseamTransition(hemPart, lowerInseamPart);
    expect(actual.distanceTo(expected), lessThan(tolerance));
  });

  test('actual back hem to lower inseam uses finite hem and infinite line', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final parts = prepareParts(outlineBuilder.backLowerContour(draft), draft);
    final hemIndex = _hemIndex(parts, 'back_hem');
    final hemPart = parts[hemIndex];
    final lowerInseamPart = parts[hemIndex + 1];
    expect(lowerInseamPart.source, isA<LineSegment>());
    final expected = _polylineInfiniteLineIntersection(hemPart.points, lowerInseamPart.points);
    final actual = cuttingBuilder.hemLowerInseamTransition(hemPart, lowerInseamPart);
    expect(actual.distanceTo(expected), lessThan(tolerance));
  });

  test('actual front lower to upper inseam uses offset-line and curve-start tangent intersection', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final parts = prepareParts(outlineBuilder.frontLowerContour(draft), draft);
    final hemIndex = _hemIndex(parts, 'front_hem');
    final lowerPart = parts[hemIndex + 1];
    final upperPart = parts[hemIndex + 2];
    expect(lowerPart.source, isA<LineSegment>());
    expect((upperPart.source as BezierSegment).role, 'front_inseam');
    expect(lowerPart.allowanceCm, upperPart.allowanceCm);
    final expected = _infiniteLineIntersection(lowerPart.points[0], lowerPart.points[1], upperPart.points[0], upperPart.points[1]);
    final actual = cuttingBuilder.lowerUpperInseamTransition(lowerPart, upperPart);
    expect(actual.distanceTo(expected), lessThan(tolerance));
  });

  test('actual back lower to upper inseam uses offset-line and curve-start tangent intersection', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final parts = prepareParts(outlineBuilder.backLowerContour(draft), draft);
    final hemIndex = _hemIndex(parts, 'back_hem');
    final lowerPart = parts[hemIndex + 1];
    final upperPart = parts[hemIndex + 2];
    expect(lowerPart.source, isA<LineSegment>());
    expect((upperPart.source as BezierSegment).role, 'back_inseam');
    expect(lowerPart.allowanceCm, upperPart.allowanceCm);
    final expected = _infiniteLineIntersection(lowerPart.points[0], lowerPart.points[1], upperPart.points[0], upperPart.points[1]);
    final actual = cuttingBuilder.lowerUpperInseamTransition(lowerPart, upperPart);
    expect(actual.distanceTo(expected), lessThan(tolerance));
  });

  test('actual front upper inseam and crotch finite offsets meet naturally', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final parts = prepareParts(outlineBuilder.frontLowerContour(draft), draft);
    final inseamIndex = _roleIndex(parts, 'front_inseam');
    final inseam = parts[inseamIndex];
    final crotch = parts[inseamIndex + 1];
    expect((crotch.source as BezierSegment).role, 'front_crotch');
    expect(inseam.allowanceCm, crotch.allowanceCm);
    final hit = _firstIntersection(inseam.points, crotch.points);
    expect(hit.x.isFinite && hit.y.isFinite, isTrue);
  });

  test('actual back upper inseam and crotch finite offsets meet naturally', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final parts = prepareParts(outlineBuilder.backLowerContour(draft), draft);
    final inseamIndex = _roleIndex(parts, 'back_inseam');
    final inseam = parts[inseamIndex];
    final crotch = parts[inseamIndex + 1];
    expect((crotch.source as BezierSegment).role, 'back_crotch');
    expect(inseam.allowanceCm, crotch.allowanceCm);
    final hit = _firstIntersection(inseam.points, crotch.points);
    expect(hit.x.isFinite && hit.y.isFinite, isTrue);
  });

  test('sideHemTransition rejects reversed part order', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final parts = prepareParts(outlineBuilder.frontLowerContour(draft), draft);
    final hemIndex = _hemIndex(parts, 'front_hem');
    expect(() => cuttingBuilder.sideHemTransition(parts[hemIndex], parts[hemIndex - 1]), throwsArgumentError);
  });

  test('hemLowerInseamTransition rejects reversed part order', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final parts = prepareParts(outlineBuilder.frontLowerContour(draft), draft);
    final hemIndex = _hemIndex(parts, 'front_hem');
    expect(() => cuttingBuilder.hemLowerInseamTransition(parts[hemIndex + 1], parts[hemIndex]), throwsArgumentError);
  });

  test('lowerUpperInseamTransition rejects reversed part order', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final parts = prepareParts(outlineBuilder.frontLowerContour(draft), draft);
    final hemIndex = _hemIndex(parts, 'front_hem');
    expect(() => cuttingBuilder.lowerUpperInseamTransition(parts[hemIndex + 2], parts[hemIndex + 1]), throwsArgumentError);
  });
}

int _hemIndex(List<TrouserOffsetPart> parts, String role) {
  final index = parts.indexWhere((part) => part.source is BezierSegment && (part.source as BezierSegment).role == role);
  expect(index, greaterThan(0));
  return index;
}

int _roleIndex(List<TrouserOffsetPart> parts, String role) {
  final index = parts.indexWhere((part) => part.source is BezierSegment && (part.source as BezierSegment).role == role);
  expect(index, greaterThanOrEqualTo(0));
  return index;
}

PatternPoint _firstIntersection(List<PatternPoint> first, List<PatternPoint> second) {
  for (var i = 0; i < first.length - 1; i++) {
    for (var j = 0; j < second.length - 1; j++) {
      final hit = _segmentIntersection(first[i], first[i + 1], second[j], second[j + 1]);
      if (hit != null) return hit;
    }
  }
  throw StateError('Expected fixture polylines to intersect.');
}

PatternPoint _polylineInfiniteLineIntersection(List<PatternPoint> polyline, List<PatternPoint> line) {
  for (var i = 0; i < polyline.length - 1; i++) {
    final hit = _segmentInfiniteLineIntersection(polyline[i], polyline[i + 1], line[0], line[1]);
    if (hit != null) return hit;
  }
  throw StateError('Expected fixture polyline and infinite line to intersect.');
}

PatternPoint _infiniteLineIntersection(PatternPoint a, PatternPoint b, PatternPoint c, PatternPoint d) {
  final rx = b.x - a.x;
  final ry = b.y - a.y;
  final sx = d.x - c.x;
  final sy = d.y - c.y;
  final denominator = rx * sy - ry * sx;
  if (denominator.abs() <= 1e-12) throw StateError('Expected fixture lines not to be parallel.');
  final qpx = c.x - a.x;
  final qpy = c.y - a.y;
  final t = (qpx * sy - qpy * sx) / denominator;
  return PatternPoint(a.x + t * rx, a.y + t * ry);
}

PatternPoint? _segmentIntersection(PatternPoint a, PatternPoint b, PatternPoint c, PatternPoint d) {
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
  if (t < -1e-12 || t > 1.0 + 1e-12 || u < -1e-12 || u > 1.0 + 1e-12) return null;
  return PatternPoint(a.x + t * rx, a.y + t * ry);
}

PatternPoint? _segmentInfiniteLineIntersection(PatternPoint a, PatternPoint b, PatternPoint c, PatternPoint d) {
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
