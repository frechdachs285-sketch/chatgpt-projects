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

PatternPoint rotatePoint(PatternPoint point, PatternPoint center, double angle) {
  final translated = point - center;
  final cosA = math.cos(angle);
  final sinA = math.sin(angle);
  return PatternPoint(
    center.x + translated.x * cosA - translated.y * sinA,
    center.y + translated.x * sinA + translated.y * cosA,
  );
}

double angleOf(PatternPoint vector) => math.atan2(vector.y, vector.x);

double normalizeAngle(double angle) {
  var result = angle;
  while (result <= -math.pi) {
    result += 2 * math.pi;
  }
  while (result > math.pi) {
    result -= 2 * math.pi;
  }
  return result;
}

List<({PatternPoint apex, double angle})> closureTransforms(List<Dart> darts) {
  final working = darts
      .map((dart) => Dart(
            center: dart.center,
            apex: dart.apex,
            leg1: dart.leg1,
            leg2: dart.leg2,
            width: dart.width,
            length: dart.length,
          ))
      .toList();
  final transforms = <({PatternPoint apex, double angle})>[];

  for (var i = 0; i < working.length; i++) {
    final dart = working[i];
    final angle = normalizeAngle(
      angleOf(dart.leg1 - dart.apex) - angleOf(dart.leg2 - dart.apex),
    );
    transforms.add((apex: dart.apex, angle: angle));

    for (var j = i + 1; j < working.length; j++) {
      final later = working[j];
      working[j] = Dart(
        center: rotatePoint(later.center, dart.apex, angle),
        apex: rotatePoint(later.apex, dart.apex, angle),
        leg1: rotatePoint(later.leg1, dart.apex, angle),
        leg2: rotatePoint(later.leg2, dart.apex, angle),
        width: later.width,
        length: later.length,
      );
    }
  }
  return transforms;
}

List<List<PatternPoint>> closeSampledSegments({
  required List<List<PatternPoint>> openedSegments,
  required List<Dart> darts,
}) {
  final transforms = closureTransforms(darts);
  final result = <List<PatternPoint>>[];

  for (var segmentIndex = 0; segmentIndex < openedSegments.length; segmentIndex++) {
    var points = List<PatternPoint>.from(openedSegments[segmentIndex]);
    for (var transformIndex = 0; transformIndex < segmentIndex; transformIndex++) {
      final transform = transforms[transformIndex];
      points = [
        for (final point in points)
          rotatePoint(point, transform.apex, transform.angle),
      ];
    }
    result.add(points);
  }
  return result;
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
  final reclosed = closeSampledSegments(openedSegments: opened, darts: darts);

  expect(opened.length, darts.length + 1);
  expect(reclosed.length, closedOffsets.length);

  // Every sampled allowance point must survive the exact round trip
  // closed -> unfolded -> closed. This verifies that the opened dart-cap
  // geometry uses the inverse of the same sequential dart rotations.
  for (var i = 0; i < closedOffsets.length; i++) {
    expect(reclosed[i].length, closedOffsets[i].length);
    for (var j = 0; j < closedOffsets[i].length; j++) {
      expect(reclosed[i][j].distanceTo(closedOffsets[i][j]), lessThan(1e-8));
    }
  }

  // Rigid unfolding must preserve every sampled segment length.
  for (var i = 0; i < opened.length; i++) {
    expect(opened[i].length, closedOffsets[i].length);
    for (var j = 1; j < opened[i].length; j++) {
      final openLength = opened[i][j - 1].distanceTo(opened[i][j]);
      final closedLength = closedOffsets[i][j - 1].distanceTo(closedOffsets[i][j]);
      expect(openLength, closeTo(closedLength, 1e-9));
    }
  }

  // The closed allowance is continuous at each dart boundary. After opening,
  // the endpoints separate into the dart cap; after re-closing they must meet
  // again at the same closed cutting-edge point.
  for (var i = 0; i < closedOffsets.length - 1; i++) {
    expect(closedOffsets[i].last.distanceTo(closedOffsets[i + 1].first), lessThan(1e-9));
    expect(opened[i].last.distanceTo(opened[i + 1].first), greaterThan(0));
    expect(reclosed[i].last.distanceTo(reclosed[i + 1].first), lessThan(1e-8));
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
