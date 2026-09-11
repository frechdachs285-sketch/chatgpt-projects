import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/culotte_skirt_base_adapter.dart';
import 'package:schnittmuster_app/pattern_models.dart';

void main() {
  PatternPiece piece({
    required String id,
    required Map<String, PatternPoint> points,
  }) {
    return PatternPiece(
      id: id,
      name: id,
      points: points,
      outline: const PatternPath([]),
    );
  }

  test('adapter exposes only the confirmed straight-skirt base points', () {
    const p1 = PatternPoint(0.0, 0.0);
    const p2 = PatternPoint(51.5, 0.0);
    const p3 = PatternPoint(0.0, 60.0);
    const p4 = PatternPoint(51.5, 60.0);
    const p5 = PatternPoint(0.0, 20.9);
    const p6 = PatternPoint(51.5, 20.9);
    const p7 = PatternPoint(26.5, 20.9);
    const p8 = PatternPoint(26.5, 60.0);

    final back = piece(
      id: 'skirt_back',
      points: const {
        'P1': p1,
        'P3': p3,
        'P5': p5,
        'P7': p7,
        'P8': p8,
        // Rock-specific point that the adapter must ignore.
        'P10': PatternPoint(25.0, -1.25),
      },
    );
    final front = piece(
      id: 'skirt_front',
      points: const {
        'P2': p2,
        'P4': p4,
        'P6': p6,
        'P7': p7,
        'P8': p8,
        // Rock-specific point that the adapter must ignore.
        'P16': PatternPoint(28.0, -1.25),
      },
    );

    final base = const CulotteSkirtBaseAdapter().fromPatternPieces(
      back: back,
      front: front,
    );

    expect(base.backCenterWaist, same(p1));
    expect(base.frontCenterWaist, same(p2));
    expect(base.backCenterHip, same(p5));
    expect(base.frontCenterHip, same(p6));
    expect(base.sideHip, same(p7));
    expect(base.backCenterHem, same(p3));
    expect(base.frontCenterHem, same(p4));
    expect(base.sideHem, same(p8));
  });

  test('adapter fails clearly when a required base point is missing', () {
    final back = piece(
      id: 'skirt_back',
      points: const {
        'P1': PatternPoint(0.0, 0.0),
        'P3': PatternPoint(0.0, 60.0),
        'P5': PatternPoint(0.0, 20.9),
        'P7': PatternPoint(26.5, 20.9),
        // P8 deliberately missing.
      },
    );
    final front = piece(
      id: 'skirt_front',
      points: const {
        'P2': PatternPoint(51.5, 0.0),
        'P4': PatternPoint(51.5, 60.0),
        'P6': PatternPoint(51.5, 20.9),
        'P7': PatternPoint(26.5, 20.9),
        'P8': PatternPoint(26.5, 60.0),
      },
    );

    expect(
      () => const CulotteSkirtBaseAdapter().fromPatternPieces(
        back: back,
        front: front,
      ),
      throwsStateError,
    );
  });
}
