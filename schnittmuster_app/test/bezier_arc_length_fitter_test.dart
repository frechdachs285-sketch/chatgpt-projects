import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/bezier_arc_length_fitter.dart';
import 'package:schnittmuster_app/pattern_models.dart';

void main() {
  test('Bezier-Fitter trifft eine vorgegebene Bogenlaenge', () {
    const fitter = CubicBezierArcLengthFitter();
    final curve = fitter.fit(
      start: const PatternPoint(0, 0),
      end: const PatternPoint(10, -1),
      startTangent: const PatternPoint(1, 0),
      endTangent: const PatternPoint(1, -0.2),
      targetLength: 10.2,
    );

    expect(curve.start, const PatternPoint(0, 0));
    expect(curve.end, const PatternPoint(10, -1));
    expect(curve.arcLength(), closeTo(10.2, 0.00001));
  });

  test('Bezier-Fitter lehnt Ziel unter direkter Strecke ab', () {
    const fitter = CubicBezierArcLengthFitter();

    expect(
      () => fitter.fit(
        start: const PatternPoint(0, 0),
        end: const PatternPoint(10, 0),
        startTangent: const PatternPoint(1, 0),
        endTangent: const PatternPoint(1, 0),
        targetLength: 9.9,
      ),
      throwsArgumentError,
    );
  });
}
