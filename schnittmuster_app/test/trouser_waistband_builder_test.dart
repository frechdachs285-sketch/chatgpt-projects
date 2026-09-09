import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';
import 'package:schnittmuster_app/trouser_waist_length.dart';
import 'package:schnittmuster_app/trouser_waistband.dart';
import 'package:schnittmuster_app/trouser_waistband_builder.dart';

void main() {
  const measurements = TrouserMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    bodyRise: 28.7,
    waistToFloor: 105.0,
    trouserBottomWidth: 22.0,
  );

  final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
  const waistLengthCalculator = TrouserWaistLengthCalculator();
  const waistbandBuilder = TrouserWaistbandBuilder();

  test('finished waist length removes only the confirmed dart intake', () {
    final lengths = waistLengthCalculator.calculate(draft);

    expect(lengths.frontCm, closeTo(19.25, 1e-9));
    expect(lengths.backCm, closeTo(19.25, 1e-9));
    expect(lengths.halfGarmentCm, closeTo(38.5, 1e-9));
    expect(lengths.fullGarmentCm, closeTo(77.0, 1e-9));
  });

  test('straight waistband uses exact garment waist plus 4 cm extension', () {
    final piece = waistbandBuilder.build(draft);
    final top = piece.outline.segments.first;

    expect(piece.id, 'trouser_waistband');
    expect(piece.name, 'Gerader Bund');
    expect(
      top.start.distanceTo(const PatternPoint(0.0, 0.0)),
      lessThan(1e-9),
    );
    expect(
      top.end.distanceTo(const PatternPoint(81.0, 0.0)),
      lessThan(1e-9),
    );
  });

  test('waistband width and fold line match confirmed Hose-v1 values', () {
    final piece = waistbandBuilder.build(draft);

    expect(TrouserWaistbandSettings.finishedWidthCm, 4.0);
    expect(TrouserWaistbandSettings.cutWidthWithoutSeamAllowanceCm, 8.0);
    expect(TrouserWaistbandSettings.underlapCm, 4.0);

    expect(piece.outline.segments[1].end.y, closeTo(8.0, 1e-9));
    expect(piece.guideLines.first.start.y, closeTo(4.0, 1e-9));
    expect(piece.guideLines.first.end.y, closeTo(4.0, 1e-9));
  });

  test('waistband marks both side seams, centre back and centre front', () {
    final piece = waistbandBuilder.build(draft);

    expect(piece.points['CF_LEFT']!.x, closeTo(0.0, 1e-9));
    expect(piece.points['SIDE_LEFT']!.x, closeTo(19.25, 1e-9));
    expect(piece.points['CB']!.x, closeTo(38.5, 1e-9));
    expect(piece.points['SIDE_RIGHT']!.x, closeTo(57.75, 1e-9));
    expect(piece.points['CF_RIGHT']!.x, closeTo(77.0, 1e-9));
    expect(piece.points['EXTENSION_END']!.x, closeTo(81.0, 1e-9));
    expect(piece.guideLines, hasLength(5));
  });
}
