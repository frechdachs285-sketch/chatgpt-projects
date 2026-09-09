import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';
import 'package:schnittmuster_app/trouser_pattern_piece_builder.dart';
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

  const enabledSeamAllowance = TrouserSeamAllowanceSettings(
    enabled: true,
    normalCm: 1.5,
    waistCm: 1.0,
    hemCm: 3.0,
  );
  const disabledSeamAllowance = TrouserSeamAllowanceSettings(
    enabled: false,
    normalCm: 1.5,
    waistCm: 1.0,
    hemCm: 3.0,
  );

  final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
  const builder = TrouserPatternPieceBuilder();

  test('front piece contains exactly the confirmed Aldrich front dart', () {
    final piece = builder.front(draft);
    expect(piece.id, 'trouser_front');
    expect(piece.name, 'Vorderhose');
    expect(piece.darts, hasLength(1));
    final dart = piece.darts.single;
    expect(dart.width, 2.0);
    expect(dart.length, 10.0);
    expect(dart.center.distanceTo(draft[0]), lessThan(1e-9));
  });

  test('back piece contains exactly the two confirmed Aldrich back darts', () {
    final piece = builder.back(draft);
    expect(piece.id, 'trouser_back');
    expect(piece.name, 'Hinterhose');
    expect(piece.darts, hasLength(2));
    expect(piece.darts[0].width, 2.0);
    expect(piece.darts[0].length, 12.0);
    expect(piece.darts[0].center.distanceTo(draft[30]), lessThan(1e-9));
    expect(piece.darts[1].width, 2.0);
    expect(piece.darts[1].length, 10.0);
    expect(piece.darts[1].center.distanceTo(draft[31]), lessThan(1e-9));
  });

  test('both pieces expose all reference points and a non-empty outline', () {
    final front = builder.front(draft);
    final back = builder.back(draft);
    expect(front.points['P0']!.distanceTo(draft[0]), lessThan(1e-9));
    expect(front.points['P31']!.distanceTo(draft[31]), lessThan(1e-9));
    expect(back.points['P0']!.distanceTo(draft[0]), lessThan(1e-9));
    expect(back.points['P31']!.distanceTo(draft[31]), lessThan(1e-9));
    expect(front.outline.segments, isNotEmpty);
    expect(back.outline.segments, isNotEmpty);
  });

  test('both pieces use the P0-P3 centre-leg axis as the digital grainline', () {
    final front = builder.front(draft);
    final back = builder.back(draft);
    expect(front.grainline, isNotNull);
    expect(back.grainline, isNotNull);
    expect(front.grainline!.start.distanceTo(draft[0]), lessThan(1e-9));
    expect(front.grainline!.end.distanceTo(draft[3]), lessThan(1e-9));
    expect(back.grainline!.start.distanceTo(draft[0]), lessThan(1e-9));
    expect(back.grainline!.end.distanceTo(draft[3]), lessThan(1e-9));
  });

  test('classic tailored trouser block adds no unconfirmed seam notches', () {
    final front = builder.front(draft);
    final back = builder.back(draft);
    expect(front.notches, isEmpty);
    expect(back.notches, isEmpty);
  });

  test('enabled seam allowance attaches cutting outlines to both pieces', () {
    final front = builder.front(draft, seamAllowance: enabledSeamAllowance);
    final back = builder.back(draft, seamAllowance: enabledSeamAllowance);
    expect(front.cuttingOutline, isNotNull);
    expect(back.cuttingOutline, isNotNull);
    expect(front.cuttingOutline!.segments, isNotEmpty);
    expect(back.cuttingOutline!.segments, isNotEmpty);
  });

  test('missing or disabled seam allowance leaves cuttingOutline null', () {
    final frontWithout = builder.front(draft);
    final backWithout = builder.back(draft);
    final frontDisabled = builder.front(draft, seamAllowance: disabledSeamAllowance);
    final backDisabled = builder.back(draft, seamAllowance: disabledSeamAllowance);
    expect(frontWithout.cuttingOutline, isNull);
    expect(backWithout.cuttingOutline, isNull);
    expect(frontDisabled.cuttingOutline, isNull);
    expect(backDisabled.cuttingOutline, isNull);
  });

  test('size 24 is threaded into front and back contour construction', () {
    final draft14 = TrouserPatternCalculator.calculateReferencePoints(
      measurements,
      sizeCode: 14,
    );
    final draft24 = TrouserPatternCalculator.calculateReferencePoints(
      measurements,
      sizeCode: 24,
    );
    final front14 = builder.front(draft14, sizeCode: 14);
    final back14 = builder.back(draft14, sizeCode: 14);
    final front24 = builder.front(draft24, sizeCode: 24);
    final back24 = builder.back(draft24, sizeCode: 24);

    expect(draft24[13].x, closeTo(12.2, 1e-12));
    expect(draft24[15].x, closeTo(-12.2, 1e-12));
    expect(draft24[27].x, closeTo(13.2, 1e-12));
    expect(draft24[29].x, closeTo(-13.2, 1e-12));

    List<BezierSegment> beziers(PatternPiece piece) =>
        piece.outline.segments.whereType<BezierSegment>().toList();
    final front14Curves = beziers(front14);
    final front24Curves = beziers(front24);
    final back14Curves = beziers(back14);
    final back24Curves = beziers(back24);

    expect(front24Curves.length, front14Curves.length);
    expect(back24Curves.length, back14Curves.length);
    expect(
      List.generate(
        front14Curves.length,
        (i) => front14Curves[i].control1.distanceTo(front24Curves[i].control1),
      ).any((distance) => distance > 1e-9),
      isTrue,
    );
    expect(
      List.generate(
        back14Curves.length,
        (i) => back14Curves[i].control1.distanceTo(back24Curves[i].control1),
      ).any((distance) => distance > 1e-9),
      isTrue,
    );
  });
}
