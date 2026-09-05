import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/segmented_waist_curve.dart';
import 'package:schnittmuster_app/seam_allowance_geometry.dart';
import 'package:schnittmuster_app/waist_curve_unfolder.dart';

Dart exactDart({
  required PatternPoint center,
  required PatternPoint waistStart,
  required PatternPoint waistEnd,
  required double width,
  required double length,
}) {
  final waistVector = waistEnd - waistStart;
  final waistLength = math.sqrt(
    waistVector.x * waistVector.x + waistVector.y * waistVector.y,
  );
  final direction = PatternPoint(
    waistVector.x / waistLength,
    waistVector.y / waistLength,
  );

  var normal = PatternPoint(-direction.y, direction.x);
  if (normal.y < 0) {
    normal = normal * -1;
  }

  final halfWidth = width / 2;
  return Dart(
    center: center,
    apex: center + normal * length,
    leg1: center - direction * halfWidth,
    leg2: center + direction * halfWidth,
    width: width,
    length: length,
  );
}

void main() {
  test('Geschlossene Taillen-Zugabe wird segmentweise exakt aufgeklappt', () {
    const center = PatternPoint(0, 0);
    const side = PatternPoint(23.25, -1.25);
    const hip = PatternPoint(26.5, 21);

    final waistVector = side - center;
    final dart1Center = center + waistVector * (1 / 3);
    final dart2Center = center + waistVector * (2 / 3);
    final dart1 = exactDart(
      center: dart1Center,
      waistStart: center,
      waistEnd: side,
      width: 2.0,
      length: 14.0,
    );
    final dart2 = exactDart(
      center: dart2Center,
      waistStart: center,
      waistEnd: side,
      width: 2.0,
      length: 12.5,
    );

    expect(
      dart1.apex.distanceTo(dart1.leg1),
      closeTo(dart1.apex.distanceTo(dart1.leg2), 0.000001),
    );
    expect(
      dart2.apex.distanceTo(dart2.leg1),
      closeTo(dart2.apex.distanceTo(dart2.leg2), 0.000001),
    );

    final solved = const SegmentedWaistCurveSolver().solve(
      centerPoint: center,
      sidePoint: side,
      hipPoint: hip,
      dartsFromCenterToSide: [dart1, dart2],
      targetLength: 19.25,
    );

    final closedSamples = [
      for (final curve in solved.segments)
        SeamAllowanceGeometry.offsetBezierSamples(
          curve,
          1.5,
          samples: 40,
        ),
    ];

    final unfolded = const WaistCurveUnfolder().unfoldSampledSegments(
      closedSegments: closedSamples,
      dartsFromCenterToSide: [dart1, dart2],
    );

    expect(unfolded.length, 3);
    expect(unfolded[0].length, 41);
    expect(unfolded[1].length, 41);
    expect(unfolded[2].length, 41);

    for (var i = 0; i < closedSamples[0].length; i++) {
      expect(
        unfolded[0][i].distanceTo(closedSamples[0][i]),
        lessThan(0.000001),
      );
    }

    for (var segmentIndex = 0;
        segmentIndex < closedSamples.length;
        segmentIndex++) {
      for (var i = 1; i < closedSamples[segmentIndex].length; i++) {
        final closedLength = closedSamples[segmentIndex][i - 1]
            .distanceTo(closedSamples[segmentIndex][i]);
        final openLength = unfolded[segmentIndex][i - 1]
            .distanceTo(unfolded[segmentIndex][i]);
        expect(openLength, closeTo(closedLength, 0.000001));
      }
    }

    expect(
      unfolded[1].first.distanceTo(closedSamples[1].first),
      greaterThan(0.01),
    );
    expect(
      unfolded[2].first.distanceTo(closedSamples[2].first),
      greaterThan(0.01),
    );
  });

  test('Falsche Anzahl geschlossener Punktsegmente wird abgewiesen', () {
    const dart = Dart(
      center: PatternPoint(5, 0),
      apex: PatternPoint(5, 10),
      leg1: PatternPoint(4, 0),
      leg2: PatternPoint(6, 0),
      width: 2,
      length: 10,
    );

    expect(
      () => const WaistCurveUnfolder().unfoldSampledSegments(
        closedSegments: const [
          [PatternPoint(0, 0), PatternPoint(4, 0)],
        ],
        dartsFromCenterToSide: const [dart],
      ),
      throwsArgumentError,
    );
  });
}
