import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_geometry.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/seam_allowance_geometry.dart';
import 'package:schnittmuster_app/segmented_waist_curve.dart';
import 'package:schnittmuster_app/waist_curve_unfolder.dart';

Dart makeExactDart({
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

void expectDartCapsCloseExactly({
  required SegmentedWaistCurveResult closedWaist,
  required List<Dart> darts,
  required bool leftSide,
}) {
  final closedOffsets = <List<PatternPoint>>[
    for (final curve in closedWaist.segments)
      if (leftSide)
        SeamAllowanceGeometry.offsetBezierSamples(curve, 1.5, samples: 200)
      else
        SeamAllowanceGeometry.offsetBezierSamples(
          CubicBezierCurve(
            start: curve.end,
            control1: curve.control2,
            control2: curve.control1,
            end: curve.start,
          ),
          1.5,
          samples: 200,
        ).reversed.toList(),
  ];

  final opened = const WaistCurveUnfolder().unfoldSampledSegments(
    closedSegments: closedOffsets,
    dartsFromCenterToSide: darts,
  );

  expect(opened.length, darts.length + 1);

  // The open cutting contour bridges each dart mouth between adjacent
  // unfolded offset-waist segments. When the dart is closed again, the two
  // cap endpoints must represent the same point of the closed cutting edge.
  // Rigid unfolding must also preserve every sampled segment length.
  for (var i = 0; i < opened.length; i++) {
    expect(opened[i].length, closedOffsets[i].length);
    for (var j = 1; j < opened[i].length; j++) {
      final openLength = opened[i][j - 1].distanceTo(opened[i][j]);
      final closedLength = closedOffsets[i][j - 1].distanceTo(closedOffsets[i][j]);
      expect(openLength, closeTo(closedLength, 1e-9));
    }
  }

  // The source closed offset is continuous at every dart boundary. This is
  // the invariant the opened dart cap must recover when folded closed.
  for (var i = 0; i < closedOffsets.length - 1; i++) {
    expect(
      closedOffsets[i].last.distanceTo(closedOffsets[i + 1].first),
      lessThan(1e-9),
    );
    expect(opened[i].last.distanceTo(opened[i + 1].first), greaterThan(0));
  }
}

void main() {
  test('Rueckenteil: Taillen-Nahtzugabe bildet zwei schliessbare Dart Caps', () {
    const center = PatternPoint(0, 0);
    const side = PatternPoint(23.25, -1.25);
    const hip = PatternPoint(26.5, 21);
    final v = side - center;
    final darts = [
      makeExactDart(
        center: center + v * (1 / 3),
        waistStart: center,
        waistEnd: side,
        width: 2,
        length: 14,
      ),
      makeExactDart(
        center: center + v * (2 / 3),
        waistStart: center,
        waistEnd: side,
        width: 2,
        length: 12.5,
      ),
    ];
    final closed = const SegmentedWaistCurveSolver().solve(
      centerPoint: center,
      sidePoint: side,
      hipPoint: hip,
      dartsFromCenterToSide: darts,
      targetLength: 19.25,
    );
    expectDartCapsCloseExactly(closedWaist: closed, darts: darts, leftSide: false);
  });

  test('Vorderteil: Taillen-Nahtzugabe bildet eine schliessbare Dart Cap', () {
    const center = PatternPoint(51.5, 0);
    const side = PatternPoint(30.25, -1.25);
    const hip = PatternPoint(26.5, 21);
    final v = side - center;
    final dart = makeExactDart(
      center: center + v * (1 / 3),
      waistStart: center,
      waistEnd: side,
      width: 2,
      length: 10,
    );
    final closed = const SegmentedWaistCurveSolver().solve(
      centerPoint: center,
      sidePoint: side,
      hipPoint: hip,
      dartsFromCenterToSide: [dart],
      targetLength: 19.25,
    );
    expectDartCapsCloseExactly(closedWaist: closed, darts: [dart], leftSide: true);
  });
}
