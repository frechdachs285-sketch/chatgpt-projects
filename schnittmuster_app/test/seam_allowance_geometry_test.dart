import 'package:flutter_test/flutter_test.dart';
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
}
