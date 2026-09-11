import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/culotte_base_geometry.dart';
import 'package:schnittmuster_app/culotte_measurements.dart';
import 'package:schnittmuster_app/pattern_models.dart';

void main() {
  PatternPiece piece({
    required String id,
    required Map<String, PatternPoint> points,
  }) =>
      PatternPiece(
        id: id,
        name: id,
        points: points,
        outline: const PatternPath([]),
      );

  PatternPiece backPiece() => piece(
        id: 'skirt_back',
        points: const {
          'P1': PatternPoint(0.0, 0.0),
          'P3': PatternPoint(0.0, 60.0),
          'P5': PatternPoint(0.0, 20.9),
          'P7': PatternPoint(26.5, 20.9),
          'P8': PatternPoint(26.5, 60.0),
          // P9-P14 are required by the full Aldrich base adapter, but their
          // coordinates are not part of this test's assertion scope.
          'P9': PatternPoint(23.25, 0.0),
          'P10': PatternPoint(23.25, -1.25),
          'P11': PatternPoint(7.75, -0.4166666666666667),
          'P12': PatternPoint(15.5, -0.8333333333333334),
          'P13': PatternPoint(7.75, 13.583333333333334),
          'P14': PatternPoint(15.5, 11.666666666666666),
        },
      );

  PatternPiece frontPiece() => piece(
        id: 'skirt_front',
        points: const {
          'P2': PatternPoint(51.5, 0.0),
          'P4': PatternPoint(51.5, 60.0),
          'P6': PatternPoint(51.5, 20.9),
          'P7': PatternPoint(26.5, 20.9),
          'P8': PatternPoint(26.5, 60.0),
          // P15-P18 are required by the full Aldrich base adapter, but their
          // coordinates are not part of this test's assertion scope.
          'P15': PatternPoint(30.25, 0.0),
          'P16': PatternPoint(30.25, -1.25),
          'P17': PatternPoint(44.416666666666664, -0.4166666666666667),
          'P18': PatternPoint(44.416666666666664, 9.583333333333334),
        },
      );

  test('combines straight-skirt basis with translated culotte reference points', () {
    const measurements = CulotteMeasurements(
      waist: 76.0,
      hip: 100.0,
      hipDepth: 20.9,
      finishedLength: 60.0,
      bodyRise: 28.7,
    );

    final geometry = const CulotteBaseGeometryBuilder().build(
      back: backPiece(),
      front: frontPiece(),
      measurements: measurements,
    );

    const tolerance = 1e-9;
    void expectPoint(String key, double x, double y) {
      final point = geometry.points[key];
      expect(point, isNotNull);
      expect(point!.x, closeTo(x, tolerance));
      expect(point.y, closeTo(y, tolerance));
    }

    // Back points are anchored at P1 = (0, 0).
    expectPoint('C0', 0.0, 0.0);
    expectPoint('C1', 0.0, 30.2);
    expectPoint('C3', 0.0, 14.1);
    expectPoint('C4', -14.5, 30.2);

    // Front points are anchored at P2 = (51.5, 0).
    expectPoint('C5', 51.5, 0.0);
    expectPoint('C6', 51.5, 30.2);
    expectPoint('C8', 51.5, 15.1);
    expectPoint('C9', 62.0, 30.2);

    // Aldrich: square down from C4/C9 to the finished hemline.
    expectPoint('BACK_INNER_HEM', -14.5, 60.0);
    expectPoint('FRONT_INNER_HEM', 62.0, 60.0);

    expect(geometry.skirtBase.backCenterHip.x, 0.0);
    expect(geometry.skirtBase.frontCenterHip.x, 51.5);
    expect(geometry.points.length, 14);
  });

  test('rejects culotte length that does not match the skirt-base hem depth', () {
    const measurements = CulotteMeasurements(
      waist: 76.0,
      hip: 100.0,
      hipDepth: 20.9,
      finishedLength: 61.0,
      bodyRise: 28.7,
    );

    expect(
      () => const CulotteBaseGeometryBuilder().build(
        back: backPiece(),
        front: frontPiece(),
        measurements: measurements,
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('Fertiglaenge'),
        ),
      ),
    );
  });
}
