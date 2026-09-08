import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_seam_allowance_geometry.dart';

void main() {
  const geometry = TrouserSeamAllowanceGeometry();
  const tolerance = 1e-9;

  test('horizontal line offset keeps exact distance and parallelism', () {
    final source = LineSegment(
      const PatternPoint(0.0, 0.0),
      const PatternPoint(10.0, 0.0),
    );

    final offset = geometry.offsetLine(
      source,
      distanceCm: 1.5,
      side: TrouserOffsetSide.left,
    );

    expect(offset.start.x, closeTo(0.0, tolerance));
    expect(offset.end.x, closeTo(10.0, tolerance));
    expect(offset.start.y, closeTo(1.5, tolerance));
    expect(offset.end.y, closeTo(1.5, tolerance));
    expect(offset.start.distanceTo(source.start), closeTo(1.5, tolerance));
    expect(offset.end.distanceTo(source.end), closeTo(1.5, tolerance));
  });

  test('right offset is mirrored to the opposite side', () {
    final source = LineSegment(
      const PatternPoint(0.0, 0.0),
      const PatternPoint(10.0, 0.0),
    );

    final offset = geometry.offsetLine(
      source,
      distanceCm: 2.0,
      side: TrouserOffsetSide.right,
    );

    expect(offset.start.y, closeTo(-2.0, tolerance));
    expect(offset.end.y, closeTo(-2.0, tolerance));
  });

  test('diagonal offset remains parallel and at exact perpendicular distance', () {
    final source = LineSegment(
      const PatternPoint(1.0, 2.0),
      const PatternPoint(7.0, 10.0),
    );

    final offset = geometry.offsetLine(
      source,
      distanceCm: 1.25,
      side: TrouserOffsetSide.left,
    );

    final sourceDx = source.end.x - source.start.x;
    final sourceDy = source.end.y - source.start.y;
    final offsetDx = offset.end.x - offset.start.x;
    final offsetDy = offset.end.y - offset.start.y;
    final cross = sourceDx * offsetDy - sourceDy * offsetDx;

    expect(cross, closeTo(0.0, tolerance));
    expect(offset.start.distanceTo(source.start), closeTo(1.25, tolerance));
    expect(offset.end.distanceTo(source.end), closeTo(1.25, tolerance));
  });

  test('zero distance returns an identical line', () {
    final source = LineSegment(
      const PatternPoint(3.0, 4.0),
      const PatternPoint(9.0, 12.0),
    );

    final offset = geometry.offsetLine(
      source,
      distanceCm: 0.0,
      side: TrouserOffsetSide.left,
    );

    expect(offset.start.distanceTo(source.start), lessThan(tolerance));
    expect(offset.end.distanceTo(source.end), lessThan(tolerance));
  });

  test('invalid distance is rejected', () {
    final source = LineSegment(
      const PatternPoint(0.0, 0.0),
      const PatternPoint(1.0, 0.0),
    );

    expect(
      () => geometry.offsetLine(
        source,
        distanceCm: -0.1,
        side: TrouserOffsetSide.left,
      ),
      throwsArgumentError,
    );
  });

  test('zero-length source line is rejected', () {
    final source = LineSegment(
      const PatternPoint(2.0, 2.0),
      const PatternPoint(2.0, 2.0),
    );

    expect(
      () => geometry.offsetLine(
        source,
        distanceCm: 1.0,
        side: TrouserOffsetSide.left,
      ),
      throwsArgumentError,
    );
  });
}
