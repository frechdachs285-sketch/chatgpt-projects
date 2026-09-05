import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/segmented_waist_curve.dart';
import 'package:schnittmuster_app/seam_allowance_geometry.dart';
import 'package:schnittmuster_app/waist_curve_unfolder.dart';

void main() {
  test('Geschlossene Taillen-Zugabe wird segmentweise exakt aufgeklappt', () {
    const center = PatternPoint(0, 0);
    const side = PatternPoint(23.25, -1.25);
    const hip = PatternPoint(26.5, 21);

    const dart1 = Dart(
      center: PatternPoint(7.75, -0.4166666667),
      apex: PatternPoint(8.502, 13.563),
      leg1: PatternPoint(6.7514421, -0.3629808),
      leg2: PatternPoint(8.7485579, -0.4703525),
      width: 2.0,
      length: 14.0,
    );
    const dart2 = Dart(
      center: PatternPoint(15.5, -0.8333333333),
      apex: PatternPoint(16.171, 11.649),
      leg1: PatternPoint(14.5014421, -0.7796475),
      leg2: PatternPoint(16.4985579, -0.8870192),
      width: 2.0,
      length: 12.5,
    );

    final solved = const SegmentedWaistCurveSolver().solve(
      centerPoint: center,
      sidePoint: side,
      hipPoint: hip,
      dartsFromCenterToSide: const [dart1, dart2],
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
      dartsFromCenterToSide: const [dart1, dart2],
    );

    expect(unfolded.length, 3);
    expect(unfolded[0].length, 41);
    expect(unfolded[1].length, 41);
    expect(unfolded[2].length, 41);

    // The first segment is before every dart, so it needs no rotation.
    for (var i = 0; i < closedSamples[0].length; i++) {
      expect(
        unfolded[0][i].distanceTo(closedSamples[0][i]),
        lessThan(0.000001),
      );
    }

    // Rigid rotations must preserve every sampled segment length exactly.
    for (var segmentIndex = 0; segmentIndex < closedSamples.length; segmentIndex++) {
      for (var i = 1; i < closedSamples[segmentIndex].length; i++) {
        final closedLength = closedSamples[segmentIndex][i - 1]
            .distanceTo(closedSamples[segmentIndex][i]);
        final openLength = unfolded[segmentIndex][i - 1]
            .distanceTo(unfolded[segmentIndex][i]);
        expect(openLength, closeTo(closedLength, 0.000001));
      }
    }

    // Segments after darts must actually move when unfolded.
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
