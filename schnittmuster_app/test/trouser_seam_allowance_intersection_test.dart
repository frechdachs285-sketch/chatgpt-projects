import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_seam_allowance_geometry.dart';

void main() {
  const geometry = TrouserSeamAllowanceGeometry();
  const tolerance = 1e-9;

  test('intersects perpendicular infinite lines exactly', () {
    final horizontal = LineSegment(
      const PatternPoint(0.0, 2.0),
      const PatternPoint(4.0, 2.0),
    );
    final vertical = LineSegment(
      const PatternPoint(3.0, 0.0),
      const PatternPoint(3.0, 1.0),
    );

    final p = geometry.intersectLines(horizontal, vertical);
    expect(p.x, closeTo(3.0, tolerance));
    expect(p.y, closeTo(2.0, tolerance));
  });

  test('uses mathematical line extensions beyond segment endpoints', () {
    final first = LineSegment(
      const PatternPoint(0.0, 0.0),
      const PatternPoint(1.0, 0.0),
    );
    final second = LineSegment(
      const PatternPoint(2.0, 1.0),
      const PatternPoint(2.0, 2.0),
    );

    final p = geometry.intersectLines(first, second);
    expect(p.x, closeTo(2.0, tolerance));
    expect(p.y, closeTo(0.0, tolerance));
  });

  test('different seam allowances meet at exact offset-line corner', () {
    final sideSeam = LineSegment(
      const PatternPoint(5.0, 0.0),
      const PatternPoint(5.0, 10.0),
    );
    final hem = LineSegment(
      const PatternPoint(5.0, 10.0),
      const PatternPoint(0.0, 10.0),
    );

    final sideOffset = geometry.offsetLine(
      sideSeam,
      distanceCm: 1.5,
      side: TrouserOffsetSide.left,
    );
    final hemOffset = geometry.offsetLine(
      hem,
      distanceCm: 3.0,
      side: TrouserOffsetSide.left,
    );
    final corner = geometry.intersectLines(sideOffset, hemOffset);

    expect(corner.x, closeTo(3.5, tolerance));
    expect(corner.y, closeTo(7.0, tolerance));
  });

  test('parallel lines are rejected instead of inventing a corner', () {
    final first = LineSegment(
      const PatternPoint(0.0, 0.0),
      const PatternPoint(5.0, 0.0),
    );
    final second = LineSegment(
      const PatternPoint(0.0, 2.0),
      const PatternPoint(5.0, 2.0),
    );

    expect(
      () => geometry.intersectLines(first, second),
      throwsStateError,
    );
  });
}
