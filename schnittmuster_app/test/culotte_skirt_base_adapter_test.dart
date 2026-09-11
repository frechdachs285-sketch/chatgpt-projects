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

  test('adapter exposes the confirmed Aldrich tailored-skirt points P1-P18', () {
    const p1 = PatternPoint(0.0, 0.0);
    const p2 = PatternPoint(51.5, 0.0);
    const p3 = PatternPoint(0.0, 60.0);
    const p4 = PatternPoint(51.5, 60.0);
    const p5 = PatternPoint(0.0, 20.9);
    const p6 = PatternPoint(51.5, 20.9);
    const p7 = PatternPoint(26.5, 20.9);
    const p8 = PatternPoint(26.5, 60.0);
    const p9 = PatternPoint(23.25, 0.0);
    const p10 = PatternPoint(23.25, -1.25);
    const p11 = PatternPoint(7.75, -0.4166666666666667);
    const p12 = PatternPoint(15.5, -0.8333333333333334);
    const p13 = PatternPoint(7.75, 13.583333333333334);
    const p14 = PatternPoint(15.5, 11.666666666666666);
    const p15 = PatternPoint(30.25, 0.0);
    const p16 = PatternPoint(30.25, -1.25);
    const p17 = PatternPoint(44.416666666666664, -0.4166666666666667);
    const p18 = PatternPoint(44.416666666666664, 9.583333333333334);

    final back = piece(
      id: 'skirt_back',
      points: const {
        'P1': p1,
        'P3': p3,
        'P5': p5,
        'P7': p7,
        'P8': p8,
        'P9': p9,
        'P10': p10,
        'P11': p11,
        'P12': p12,
        'P13': p13,
        'P14': p14,
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
        'P15': p15,
        'P16': p16,
        'P17': p17,
        'P18': p18,
      },
    );

    final base = const CulotteSkirtBaseAdapter().fromPatternPieces(
      back: back,
      front: front,
    );

    expect(base.p1, same(p1));
    expect(base.p2, same(p2));
    expect(base.p3, same(p3));
    expect(base.p4, same(p4));
    expect(base.p5, same(p5));
    expect(base.p6, same(p6));
    expect(base.p7, same(p7));
    expect(base.p8, same(p8));
    expect(base.p9, same(p9));
    expect(base.p10, same(p10));
    expect(base.p11, same(p11));
    expect(base.p12, same(p12));
    expect(base.p13, same(p13));
    expect(base.p14, same(p14));
    expect(base.p15, same(p15));
    expect(base.p16, same(p16));
    expect(base.p17, same(p17));
    expect(base.p18, same(p18));

    expect(base.backCenterWaist, same(p1));
    expect(base.frontCenterWaist, same(p2));
    expect(base.backCenterHip, same(p5));
    expect(base.frontCenterHip, same(p6));
    expect(base.sideHip, same(p7));
    expect(base.backCenterHem, same(p3));
    expect(base.frontCenterHem, same(p4));
    expect(base.sideHem, same(p8));
  });

  test('adapter fails clearly when a required Aldrich base point is missing', () {
    final back = piece(
      id: 'skirt_back',
      points: const {
        'P1': PatternPoint(0.0, 0.0),
        'P3': PatternPoint(0.0, 60.0),
        'P5': PatternPoint(0.0, 20.9),
        'P7': PatternPoint(26.5, 20.9),
        'P8': PatternPoint(26.5, 60.0),
        'P9': PatternPoint(23.25, 0.0),
        'P10': PatternPoint(23.25, -1.25),
        'P11': PatternPoint(7.75, -0.4166666666666667),
        'P12': PatternPoint(15.5, -0.8333333333333334),
        'P13': PatternPoint(7.75, 13.583333333333334),
        // P14 deliberately missing.
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
        'P15': PatternPoint(30.25, 0.0),
        'P16': PatternPoint(30.25, -1.25),
        'P17': PatternPoint(44.416666666666664, -0.4166666666666667),
        'P18': PatternPoint(44.416666666666664, 9.583333333333334),
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
