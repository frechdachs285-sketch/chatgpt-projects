import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_geometry.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/skirt_cutting_outline_builder.dart';
import 'package:schnittmuster_app/segmented_waist_curve.dart';

Dart makeDart({
  required PatternPoint center,
  required PatternPoint waistStart,
  required PatternPoint waistEnd,
  required double width,
  required double length,
}) {
  final v = waistEnd - waistStart;
  final len = math.sqrt(v.x * v.x + v.y * v.y);
  final direction = PatternPoint(v.x / len, v.y / len);
  var normal = PatternPoint(-direction.y, direction.x);
  if (normal.y < 0) normal = normal * -1;
  return Dart(
    center: center,
    apex: center + normal * length,
    leg1: center - direction * (width / 2),
    leg2: center + direction * (width / 2),
    width: width,
    length: length,
  );
}

void main() {
  test('Vorderteil-Schneidelinie bleibt am Stoffbruch bei 0 cm', () {
    const centerWaist = PatternPoint(51.5, 0);
    const sideWaist = PatternPoint(30.25, -1.25);
    const hip = PatternPoint(26.5, 21);
    const sideHem = PatternPoint(26.5, 60);
    const centerHem = PatternPoint(51.5, 60);

    final waistVector = sideWaist - centerWaist;
    final dart = makeDart(
      center: centerWaist + waistVector * (1 / 3),
      waistStart: centerWaist,
      waistEnd: sideWaist,
      width: 2,
      length: 10,
    );
    final closedWaist = const SegmentedWaistCurveSolver().solve(
      centerPoint: centerWaist,
      sidePoint: sideWaist,
      hipPoint: hip,
      dartsFromCenterToSide: [dart],
      targetLength: 19.25,
    );
    final sideCurve = const SideSeamCurveBuilder().build(
      start: closedWaist.correctedSidePoint,
      end: hip,
    );

    final path = const SkirtCuttingOutlineBuilder().build(
      isBack: false,
      closedWaist: closedWaist,
      dartsFromCenterToSide: [dart],
      sideCurve: sideCurve,
      hipPoint: hip,
      sideHemPoint: sideHem,
      centerHemPoint: centerHem,
      centerWaistPoint: centerWaist,
      settings: const SeamAllowanceSettings(),
      curveMaxDeviation: 0.01,
    );

    expect(path.segments, isNotEmpty);
    final centerSegments = path.segments.whereType<LineSegment>().where(
      (segment) =>
          (segment.start.x - 51.5).abs() < 0.000001 &&
          (segment.end.x - 51.5).abs() < 0.000001,
    );
    expect(centerSegments, isNotEmpty);

    final allLines = path.segments.whereType<LineSegment>().toList();
    expect(allLines.first.start.distanceTo(allLines.last.end), lessThan(0.000001));
  });

  test('Rueckenteil-Schneidelinie ist geschlossen und Saum liegt 3 cm tiefer', () {
    const centerWaist = PatternPoint(0, 0);
    const sideWaist = PatternPoint(23.25, -1.25);
    const hip = PatternPoint(26.5, 21);
    const sideHem = PatternPoint(26.5, 60);
    const centerHem = PatternPoint(0, 60);

    final waistVector = sideWaist - centerWaist;
    final dart1 = makeDart(
      center: centerWaist + waistVector * (1 / 3),
      waistStart: centerWaist,
      waistEnd: sideWaist,
      width: 2,
      length: 14,
    );
    final dart2 = makeDart(
      center: centerWaist + waistVector * (2 / 3),
      waistStart: centerWaist,
      waistEnd: sideWaist,
      width: 2,
      length: 12.5,
    );
    final closedWaist = const SegmentedWaistCurveSolver().solve(
      centerPoint: centerWaist,
      sidePoint: sideWaist,
      hipPoint: hip,
      dartsFromCenterToSide: [dart1, dart2],
      targetLength: 19.25,
    );
    final sideCurve = const SideSeamCurveBuilder().build(
      start: closedWaist.correctedSidePoint,
      end: hip,
    );

    final path = const SkirtCuttingOutlineBuilder().build(
      isBack: true,
      closedWaist: closedWaist,
      dartsFromCenterToSide: [dart1, dart2],
      sideCurve: sideCurve,
      hipPoint: hip,
      sideHemPoint: sideHem,
      centerHemPoint: centerHem,
      centerWaistPoint: centerWaist,
      settings: const SeamAllowanceSettings(),
      curveMaxDeviation: 0.01,
    );

    final lines = path.segments.whereType<LineSegment>().toList();
    expect(lines, isNotEmpty);
    expect(lines.first.start.distanceTo(lines.last.end), lessThan(0.000001));

    final hemPoints = <PatternPoint>[
      for (final line in lines) ...[line.start, line.end],
    ].where((point) => (point.y - 63).abs() < 0.000001).toList();
    expect(hemPoints.length, greaterThanOrEqualTo(2));
  });

  test('Deaktivierte Nahtzugabe erzeugt keine Schneidelinie', () {
    const dummyWaist = SegmentedWaistCurveResult(
      correctedSidePoint: PatternPoint(10, 0),
      closedSidePoint: PatternPoint(10, 0),
      closedDartMouths: [],
      segments: [],
      horizontalShift: 0,
      totalLength: 10,
    );
    const sideCurve = CubicBezierCurve(
      start: PatternPoint(10, 0),
      control1: PatternPoint(10, 3),
      control2: PatternPoint(10, 7),
      end: PatternPoint(10, 10),
    );

    expect(
      () => const SkirtCuttingOutlineBuilder().build(
        isBack: false,
        closedWaist: dummyWaist,
        dartsFromCenterToSide: const [],
        sideCurve: sideCurve,
        hipPoint: const PatternPoint(10, 10),
        sideHemPoint: const PatternPoint(10, 20),
        centerHemPoint: const PatternPoint(20, 20),
        centerWaistPoint: const PatternPoint(20, 0),
        settings: const SeamAllowanceSettings(enabled: false),
      ),
      throwsArgumentError,
    );
  });
}
