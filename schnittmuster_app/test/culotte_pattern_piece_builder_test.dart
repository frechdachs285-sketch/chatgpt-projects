import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/culotte_base_geometry.dart';
import 'package:schnittmuster_app/culotte_measurements.dart';
import 'package:schnittmuster_app/culotte_pattern_piece_builder.dart';
import 'package:schnittmuster_app/culotte_seam_allowance.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';

void main() {
  const measurements = Measurements(
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

  PatternResult buildSkirt() => SkirtPatternCalculator().calculate(
        measurements,
        const ConstructionValues(),
        seamAllowance: const SeamAllowanceSettings(enabled: false),
      );

  CulotteBaseGeometry buildGeometry(PatternResult skirt) =>
      const CulotteBaseGeometryBuilder().build(
        back: skirt.back!,
        front: skirt.front!,
        measurements: culotteMeasurements,
      );

  test('builder creates front and back Culotte PatternPieces without unconfirmed extras', () {
    final skirt = buildSkirt();
    expect(skirt.isValid, isTrue);
    final geometry = buildGeometry(skirt);

    const builder = CulottePatternPieceBuilder();
    final back = builder.buildBack(skirtBack: skirt.back!, geometry: geometry);
    final front = builder.buildFront(skirtFront: skirt.front!, geometry: geometry);

    expect(back.id, 'culotte_back');
    expect(back.name, 'Culotte Rueckenteil');
    expect(front.id, 'culotte_front');
    expect(front.name, 'Culotte Vorderteil');

    expect(back.outline.segments, isNotEmpty);
    expect(front.outline.segments, isNotEmpty);
    expect(back.cuttingOutline, isNull);
    expect(front.cuttingOutline, isNull);
    expect(back.grainline, isNull);
    expect(front.grainline, isNull);
    expect(back.notches, isEmpty);
    expect(front.notches, isEmpty);
    expect(back.labels, isEmpty);
    expect(front.labels, isEmpty);

    expect(back.darts.length, skirt.back!.darts.length);
    expect(front.darts.length, skirt.front!.darts.length);

    for (final key in ['C0','C1','C2','C3','C4','H3','BACK_INNER_HEM']) {
      expect(back.points.containsKey(key), isTrue, reason: 'back missing $key');
    }
    for (final key in ['C5','C6','C7','C8','C9','H4','FRONT_INNER_HEM']) {
      expect(front.points.containsKey(key), isTrue, reason: 'front missing $key');
    }
  });

  test('enabled Culotte seam allowance creates a separate closed cuttingOutline', () {
    final skirt = buildSkirt();
    expect(skirt.isValid, isTrue);
    final geometry = buildGeometry(skirt);

    const seamAllowance = CulotteSeamAllowanceSettings(
      enabled: true,
      normalCm: 1.0,
      waistCm: 1.0,
      hemCm: 3.0,
    );
    const builder = CulottePatternPieceBuilder();

    final back = builder.buildBack(
      skirtBack: skirt.back!,
      geometry: geometry,
      seamAllowance: seamAllowance,
    );
    final front = builder.buildFront(
      skirtFront: skirt.front!,
      geometry: geometry,
      seamAllowance: seamAllowance,
    );

    for (final piece in [back, front]) {
      expect(piece.cuttingOutline, isNotNull);
      expect(piece.cuttingOutline!.segments, isNotEmpty);
      expect(
        piece.cuttingOutline!.segments.first.start.distanceTo(
          piece.cuttingOutline!.segments.last.end,
        ),
        lessThanOrEqualTo(0.000001),
      );
      expect(identical(piece.cuttingOutline, piece.outline), isFalse);
    }
  });
}
