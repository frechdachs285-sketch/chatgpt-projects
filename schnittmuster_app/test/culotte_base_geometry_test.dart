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

  test('combines straight-skirt basis with translated culotte reference points', () {
    final back = piece(
      id: 'skirt_back',
      points: const {
        'P1': PatternPoint(0.0, 0.0),
        'P3': PatternPoint(0.0, 60.0),
        'P5': PatternPoint(0.0, 20.9),
        'P7': PatternPoint(26.5, 20.9),
        'P8': PatternPoint(26.5, 60.0),
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

    const measurements = CulotteMeasurements(
      waist: 76.0,
      hip: 100.0,
      hipDepth: 20.9,
      finishedLength: 60.0,
      bodyRise: 28.7,
    );

    final geometry = const CulotteBaseGeometryBuilder().build(
      back: back,
      front: front,
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
}
