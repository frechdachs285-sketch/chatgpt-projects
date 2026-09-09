import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_cutting_outline_builder.dart';
import 'package:schnittmuster_app/trouser_cutting_outline_front.dart';
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

  test('buildFrontCuttingOutline returns a closed continuous polyline', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final seamOutline = outlineBuilder.frontLowerContour(draft);
    final cuttingOutline = cuttingBuilder.buildFrontCuttingOutline(
      outline: seamOutline,
      draft: draft,
      settings: settings,
    );

    expect(cuttingOutline.segments, isNotEmpty);
    expect(cuttingOutline.segments.every((segment) => segment is LineSegment), isTrue);

    for (var i = 0; i < cuttingOutline.segments.length; i++) {
      final current = cuttingOutline.segments[i];
      expect(current.start.x.isFinite, isTrue);
      expect(current.start.y.isFinite, isTrue);
      expect(current.end.x.isFinite, isTrue);
      expect(current.end.y.isFinite, isTrue);
      expect(current.start.distanceTo(current.end), greaterThan(1e-12));
      if (i + 1 < cuttingOutline.segments.length) {
        expect(
          current.end.distanceTo(cuttingOutline.segments[i + 1].start),
          lessThanOrEqualTo(1e-12),
        );
      }
    }

    expect(
      cuttingOutline.segments.last.end.distanceTo(cuttingOutline.segments.first.start),
      lessThanOrEqualTo(1e-12),
    );
  });

  test('buildFrontCuttingOutline does not modify the confirmed seam outline', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final seamOutline = outlineBuilder.frontLowerContour(draft);
    final originalSegments = List<PathSegment>.from(seamOutline.segments);

    cuttingBuilder.buildFrontCuttingOutline(
      outline: seamOutline,
      draft: draft,
      settings: settings,
    );

    expect(seamOutline.segments.length, originalSegments.length);
    for (var i = 0; i < originalSegments.length; i++) {
      expect(identical(seamOutline.segments[i], originalSegments[i]), isTrue);
    }
  });

  test('buildFrontCuttingOutline rejects disabled seam allowance', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final seamOutline = outlineBuilder.frontLowerContour(draft);
    const disabled = TrouserSeamAllowanceSettings(
      enabled: false,
      normalCm: 1.5,
      waistCm: 1.0,
      hemCm: 3.0,
    );

    expect(
      () => cuttingBuilder.buildFrontCuttingOutline(
        outline: seamOutline,
        draft: draft,
        settings: disabled,
      ),
      throwsArgumentError,
    );
  });
}
