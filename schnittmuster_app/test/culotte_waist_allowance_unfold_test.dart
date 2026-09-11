import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/culotte_base_geometry.dart';
import 'package:schnittmuster_app/culotte_measurements.dart';
import 'package:schnittmuster_app/culotte_pattern_piece_builder.dart';
import 'package:schnittmuster_app/culotte_seam_allowance.dart';
import 'package:schnittmuster_app/pattern_geometry.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/seam_allowance_geometry.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';
import 'package:schnittmuster_app/waist_curve_unfolder.dart';

void main() {
  const skirtMeasurements = Measurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    skirtLength: 60.0,
  );
  const culotteMeasurements = CulotteMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    finishedLength: 60.0,
    bodyRise: 28.7,
  );

  PatternPiece buildPiece({required bool isBack}) {
    final skirt = SkirtPatternCalculator().calculate(
      skirtMeasurements,
      const ConstructionValues(),
      seamAllowance: const SeamAllowanceSettings(enabled: false),
    );
    expect(skirt.isValid, isTrue);

    final geometry = const CulotteBaseGeometryBuilder().build(
      back: skirt.back!,
      front: skirt.front!,
      measurements: culotteMeasurements,
    );
    const builder = CulottePatternPieceBuilder();
    return isBack
        ? builder.buildBack(skirtBack: skirt.back!, geometry: geometry)
        : builder.buildFront(skirtFront: skirt.front!, geometry: geometry);
  }

  test('dart unfolding preserves the sampled waist-allowance geometry', () {
    for (final isBack in [true, false]) {
      final piece = buildPiece(isBack: isBack);
      final waistSegments = piece.outline.segments
          .whereType<BezierSegment>()
          .where((segment) => segment.role == 'waist')
          .toList();

      expect(waistSegments.length, piece.darts.length + 1);

      final closedOffsets = <List<PatternPoint>>[
        for (final segment in waistSegments)
          _offsetWaistSegment(segment, isBack: isBack),
      ];

      final unfolded = const WaistCurveUnfolder().unfoldSampledSegments(
        closedSegments: closedOffsets,
        dartsFromCenterToSide: piece.darts,
      );

      expect(unfolded.length, closedOffsets.length);

      // Each unfolded waist section is produced only by rigid rotations.
      // Therefore its sampled polyline length must stay unchanged.
      for (var i = 0; i < closedOffsets.length; i++) {
        expect(
          _polylineLength(unfolded[i]),
          closeTo(_polylineLength(closedOffsets[i]), 0.0000001),
          reason: '${isBack ? 'back' : 'front'} waist segment $i was deformed',
        );
      }

      // The first centre-side segment is before every dart and therefore is
      // not rotated at all by the unfolding operation.
      expect(
        unfolded.first.first.distanceTo(closedOffsets.first.first),
        lessThanOrEqualTo(0.0000001),
      );
      expect(
        unfolded.first.last.distanceTo(closedOffsets.first.last),
        lessThanOrEqualTo(0.0000001),
      );

      // At least one later segment must actually move when darts are present.
      // This confirms that visible slanted allowance extensions are the
      // expected result of opening the dart rather than accidental distortion.
      expect(piece.darts, isNotEmpty);
      var moved = false;
      for (var i = 1; i < closedOffsets.length; i++) {
        if (unfolded[i].first.distanceTo(closedOffsets[i].first) > 0.000001 ||
            unfolded[i].last.distanceTo(closedOffsets[i].last) > 0.000001) {
          moved = true;
          break;
        }
      }
      expect(moved, isTrue);
    }
  });
}

List<PatternPoint> _offsetWaistSegment(
  BezierSegment segment, {
  required bool isBack,
}) {
  CubicBezierCurve curveFrom(BezierSegment s) => CubicBezierCurve(
        start: s.start,
        control1: s.control1,
        control2: s.control2,
        end: s.end,
      );

  const distance = 1.0;
  final leftSide = !isBack;
  if (leftSide) {
    return SeamAllowanceGeometry.offsetBezierAdaptive(
      curveFrom(segment),
      distance,
      maxDeviation: culotteSeamAllowanceToleranceCm,
    );
  }

  final reversed = BezierSegment(
    start: segment.end,
    control1: segment.control2,
    control2: segment.control1,
    end: segment.start,
    role: segment.role,
  );
  return SeamAllowanceGeometry.offsetBezierAdaptive(
    curveFrom(reversed),
    distance,
    maxDeviation: culotteSeamAllowanceToleranceCm,
  ).reversed.toList();
}

double _polylineLength(List<PatternPoint> points) {
  var length = 0.0;
  for (var i = 1; i < points.length; i++) {
    length += points[i - 1].distanceTo(points[i]);
  }
  return length;
}
