import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';
import 'package:schnittmuster_app/trouser_pattern_piece_builder.dart';

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
}
