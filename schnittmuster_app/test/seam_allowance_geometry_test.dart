import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_geometry.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/seam_allowance_geometry.dart';

void main() {
  test('Horizontale Linie wird exakt parallel versetzt', () {
    final original = LineSegment(
      const PatternPoint(0, 0),
      const PatternPoint(10, 0),
    );

    final offset = SeamAllowanceGeometry.offsetLine(original, 1.5);

    expect(offset.start.x, closeTo(0, 0.000001));
    expect(offset.end.x, closeTo(10, 0.000001));
    expect(offset.start.y, closeTo(1.5, 0.000001));
    expect(offset.end.y, closeTo(1.5, 0.000001));
    expect(
      SeamAllowanceGeometry.parallelDistance(original, offset),
      closeTo(1.5, 0.000001),
    );
  });

  test('Vertikale Linie wird exakt parallel versetzt', () {
    final original = LineSegment(
      const PatternPoint(2, 3),
      const PatternPoint(2, 13),
    );

    final offset = SeamAllowanceGeometry.offsetLine(original, 3.0);

    expect(offset.start.x, closeTo(-1.0, 0.000001));
    expect(offset.end.x, closeTo(-1.0, 0.000001));
    expect(offset.start.y, closeTo(3, 0.000001));
    expect(offset.end.y, closeTo(13, 0.000001));
    expect(
      SeamAllowanceGeometry.parallelDistance(original, offset),
      closeTo(3.0, 0.000001),
    );
  });

  test('Diagonale Linie behaelt Richtung und exakten Abstand', () {
    final original = LineSegment(
      const PatternPoint(0, 0),
      const PatternPoint(3, 4),
    );

    final offset = SeamAllowanceGeometry.offsetLine(original, 2.0);

    final originalDx = original.end.x - original.start.x;
    final originalDy = original.end.y - original.start.y;
    final offsetDx = offset.end.x - offset.start.x;
    final offsetDy = offset.end.y - offset.start.y;

    expect(offsetDx, closeTo(originalDx, 0.000001));
    expect(offsetDy, closeTo(originalDy, 0.000001));
    expect(
      SeamAllowanceGeometry.parallelDistance(original, offset),
      closeTo(2.0, 0.000001),
    );
  });

  test('Null-Zugabe laesst die Linie unveraendert', () {
    final original = LineSegment(
      const PatternPoint(1, 2),
      const PatternPoint(7, 9),
    );

    final offset = SeamAllowanceGeometry.offsetLine(original, 0.0);

    expect(offset.start.distanceTo(original.start), lessThan(0.000001));
    expect(offset.end.distanceTo(original.end), lessThan(0.000001));
  });

  test('Negative Zugabe wird abgewiesen', () {
    final original = LineSegment(
      const PatternPoint(0, 0),
      const PatternPoint(10, 0),
    );

    expect(
      () => SeamAllowanceGeometry.offsetLine(original, -1.0),
      throwsArgumentError,
    );
  });

  test('Null-Linie wird abgewiesen', () {
    final original = LineSegment(
      const PatternPoint(4, 4),
      const PatternPoint(4, 4),
    );

    expect(
      () => SeamAllowanceGeometry.offsetLine(original, 1.5),
      throwsArgumentError,
    );
  });

  test('Bezier-Stuetzpunkte liegen exakt 1,5 cm auf der Normalen', () {
    const curve = CubicBezierCurve(
      start: PatternPoint(0, 0),
      control1: PatternPoint(4, 1),
      control2: PatternPoint(6, 8),
      end: PatternPoint(10, 10),
    );
    const samples = 200;
    const distance = 1.5;

    final offset = SeamAllowanceGeometry.offsetBezierSamples(
      curve,
      distance,
      samples: samples,
    );

    expect(offset.length, samples + 1);

    for (var i = 0; i <= samples; i++) {
      final t = i / samples;
      expect(
        SeamAllowanceGeometry.sampleOffsetDistance(curve, offset[i], t),
        closeTo(distance, 0.000001),
        reason: 'Abstand bei t=$t',
      );

      final base = curve.pointAt(t);
      final tangent = curve.derivativeAt(t);
      final offsetVector = offset[i] - base;
      final dot = tangent.x * offsetVector.x + tangent.y * offsetVector.y;
      expect(dot, closeTo(0, 0.000001), reason: 'Normale bei t=$t');
    }
  });

  test('Bezier-Nullzugabe liefert die Originalpunkte', () {
    const curve = CubicBezierCurve(
      start: PatternPoint(0, 0),
      control1: PatternPoint(2, 0),
      control2: PatternPoint(4, 4),
      end: PatternPoint(6, 4),
    );
    const samples = 40;

    final offset = SeamAllowanceGeometry.offsetBezierSamples(
      curve,
      0,
      samples: samples,
    );

    for (var i = 0; i <= samples; i++) {
      expect(
        offset[i].distanceTo(curve.pointAt(i / samples)),
        lessThan(0.000001),
      );
    }
  });

  test('Bezier-Offset weist ungueltige Parameter ab', () {
    const curve = CubicBezierCurve(
      start: PatternPoint(0, 0),
      control1: PatternPoint(2, 0),
      control2: PatternPoint(4, 4),
      end: PatternPoint(6, 4),
    );

    expect(
      () => SeamAllowanceGeometry.offsetBezierSamples(curve, -1, samples: 20),
      throwsArgumentError,
    );
    expect(
      () => SeamAllowanceGeometry.offsetBezierSamples(curve, 1.5, samples: 0),
      throwsArgumentError,
    );
  });
}
