import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/culotte_base_geometry.dart';
import 'package:schnittmuster_app/culotte_cutting_outline_builder.dart';
import 'package:schnittmuster_app/culotte_measurements.dart';
import 'package:schnittmuster_app/culotte_pattern_piece_builder.dart';
import 'package:schnittmuster_app/culotte_seam_allowance.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';

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
  const settings = CulotteSeamAllowanceSettings(
    enabled: true,
    normalCm: 1.0,
    waistCm: 1.0,
    hemCm: 3.0,
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

  test('builds closed exterior cutting outlines for back and front', () {
    const builder = CulotteCuttingOutlineBuilder();

    for (final isBack in [true, false]) {
      final piece = buildPiece(isBack: isBack);
      final originalFirst = piece.outline.segments.first.start;
      final originalLast = piece.outline.segments.last.end;

      final cutting = builder.build(
        piece: piece,
        isBack: isBack,
        settings: settings,
      );

      expect(cutting.segments, isNotEmpty);
      expect(
        cutting.segments.first.start.distanceTo(cutting.segments.last.end),
        lessThanOrEqualTo(0.000001),
      );

      // The builder must never mutate the confirmed Culotte seam line.
      expect(piece.outline.segments.first.start.distanceTo(originalFirst), 0.0);
      expect(piece.outline.segments.last.end.distanceTo(originalLast), 0.0);

      final seamBounds = _bounds(piece.outline);
      final cutBounds = _bounds(cutting);
      expect(cutBounds.width, greaterThan(seamBounds.width));
      expect(cutBounds.height, greaterThan(seamBounds.height));
    }
  });

  test('rejects disabled seam allowance', () {
    final piece = buildPiece(isBack: true);
    expect(
      () => const CulotteCuttingOutlineBuilder().build(
        piece: piece,
        isBack: true,
        settings: const CulotteSeamAllowanceSettings(
          enabled: false,
          normalCm: 1.0,
          waistCm: 1.0,
          hemCm: 3.0,
        ),
      ),
      throwsArgumentError,
    );
  });
}

Rect _bounds(PatternPath path) {
  final points = <PatternPoint>[];
  for (final segment in path.segments) {
    points.add(segment.start);
    points.add(segment.end);
    if (segment is BezierSegment) {
      points.add(segment.control1);
      points.add(segment.control2);
    }
  }
  var minX = points.first.x;
  var maxX = points.first.x;
  var minY = points.first.y;
  var maxY = points.first.y;
  for (final p in points.skip(1)) {
    minX = math.min(minX, p.x);
    maxX = math.max(maxX, p.x);
    minY = math.min(minY, p.y);
    maxY = math.max(maxY, p.y);
  }
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}
