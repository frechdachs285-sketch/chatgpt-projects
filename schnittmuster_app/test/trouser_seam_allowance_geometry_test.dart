import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_seam_allowance_geometry.dart';

void main() {
  const geometry = TrouserSeamAllowanceGeometry();
  const tolerance = 1e-9;

  test('horizontal line offset keeps exact distance and parallelism', () {
    final source = LineSegment(const PatternPoint(0.0, 0.0), const PatternPoint(10.0, 0.0));
    final offset = geometry.offsetLine(source, distanceCm: 1.5, side: TrouserOffsetSide.left);
    expect(offset.start.x, closeTo(0.0, tolerance));
    expect(offset.end.x, closeTo(10.0, tolerance));
    expect(offset.start.y, closeTo(1.5, tolerance));
    expect(offset.end.y, closeTo(1.5, tolerance));
    expect(offset.start.distanceTo(source.start), closeTo(1.5, tolerance));
    expect(offset.end.distanceTo(source.end), closeTo(1.5, tolerance));
  });

  test('right offset is mirrored to the opposite side', () {
    final source = LineSegment(const PatternPoint(0.0, 0.0), const PatternPoint(10.0, 0.0));
    final offset = geometry.offsetLine(source, distanceCm: 2.0, side: TrouserOffsetSide.right);
    expect(offset.start.y, closeTo(-2.0, tolerance));
    expect(offset.end.y, closeTo(-2.0, tolerance));
  });

  test('diagonal offset remains parallel and at exact perpendicular distance', () {
    final source = LineSegment(const PatternPoint(1.0, 2.0), const PatternPoint(7.0, 10.0));
    final offset = geometry.offsetLine(source, distanceCm: 1.25, side: TrouserOffsetSide.left);
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
    final source = LineSegment(const PatternPoint(3.0, 4.0), const PatternPoint(9.0, 12.0));
    final offset = geometry.offsetLine(source, distanceCm: 0.0, side: TrouserOffsetSide.left);
    expect(offset.start.distanceTo(source.start), lessThan(tolerance));
    expect(offset.end.distanceTo(source.end), lessThan(tolerance));
  });

  test('invalid distance is rejected', () {
    final source = LineSegment(const PatternPoint(0.0, 0.0), const PatternPoint(1.0, 0.0));
    expect(() => geometry.offsetLine(source, distanceCm: -0.1, side: TrouserOffsetSide.left), throwsArgumentError);
  });

  test('zero-length source line is rejected', () {
    final source = LineSegment(const PatternPoint(2.0, 2.0), const PatternPoint(2.0, 2.0));
    expect(() => geometry.offsetLine(source, distanceCm: 1.0, side: TrouserOffsetSide.left), throwsArgumentError);
  });

  test('polylinePath preserves every accepted offset point exactly', () {
    const points = <PatternPoint>[
      PatternPoint(1.0, 2.0),
      PatternPoint(3.0, 4.0),
      PatternPoint(6.0, 5.0),
      PatternPoint(8.0, 9.0),
    ];
    final path = geometry.polylinePath(points);
    expect(path.segments.length, 3);
    for (var i = 0; i < path.segments.length; i++) {
      final segment = path.segments[i] as LineSegment;
      expect(segment.start.distanceTo(points[i]), lessThan(tolerance));
      expect(segment.end.distanceTo(points[i + 1]), lessThan(tolerance));
    }
  });

  test('polylinePath rejects fewer than two points', () {
    expect(() => geometry.polylinePath(const [PatternPoint(1.0, 2.0)]), throwsArgumentError);
  });

  test('polyline-line transition returns exact intersection', () {
    const polyline = <PatternPoint>[PatternPoint(0.0, 0.0), PatternPoint(4.0, 2.0), PatternPoint(8.0, 2.0)];
    final line = LineSegment(const PatternPoint(6.0, -5.0), const PatternPoint(6.0, -4.0));
    final intersection = geometry.intersectPolylineWithLine(polyline, line);
    expect(intersection.x, closeTo(6.0, tolerance));
    expect(intersection.y, closeTo(2.0, tolerance));
  });

  test('polyline-line transition uses infinite line extension', () {
    const polyline = <PatternPoint>[PatternPoint(0.0, 0.0), PatternPoint(4.0, 0.0)];
    final line = LineSegment(const PatternPoint(2.0, 5.0), const PatternPoint(2.0, 6.0));
    final intersection = geometry.intersectPolylineWithLine(polyline, line);
    expect(intersection.x, closeTo(2.0, tolerance));
    expect(intersection.y, closeTo(0.0, tolerance));
  });

  test('polyline-line transition returns first hit in path direction', () {
    const polyline = <PatternPoint>[PatternPoint(0.0, 0.0), PatternPoint(4.0, 4.0), PatternPoint(0.0, 8.0)];
    final line = LineSegment(const PatternPoint(2.0, -1.0), const PatternPoint(2.0, 1.0));
    final intersection = geometry.intersectPolylineWithLine(polyline, line);
    expect(intersection.x, closeTo(2.0, tolerance));
    expect(intersection.y, closeTo(2.0, tolerance));
  });

  test('polyline-line transition rejects missing intersection', () {
    const polyline = <PatternPoint>[PatternPoint(0.0, 0.0), PatternPoint(1.0, 0.0)];
    final line = LineSegment(const PatternPoint(2.0, -1.0), const PatternPoint(2.0, 1.0));
    expect(() => geometry.intersectPolylineWithLine(polyline, line), throwsStateError);
  });

  test('polyline-polyline transition returns exact finite intersection', () {
    const first = <PatternPoint>[
      PatternPoint(0.0, 0.0),
      PatternPoint(4.0, 4.0),
    ];
    const second = <PatternPoint>[
      PatternPoint(0.0, 4.0),
      PatternPoint(4.0, 0.0),
    ];
    final intersection = geometry.intersectPolylines(first, second);
    expect(intersection.x, closeTo(2.0, tolerance));
    expect(intersection.y, closeTo(2.0, tolerance));
  });

  test('polyline-polyline transition returns first hit in first path direction', () {
    const first = <PatternPoint>[
      PatternPoint(0.0, 0.0),
      PatternPoint(4.0, 4.0),
      PatternPoint(0.0, 8.0),
    ];
    const second = <PatternPoint>[
      PatternPoint(2.0, -1.0),
      PatternPoint(2.0, 9.0),
    ];
    final intersection = geometry.intersectPolylines(first, second);
    expect(intersection.x, closeTo(2.0, tolerance));
    expect(intersection.y, closeTo(2.0, tolerance));
  });

  test('polyline-polyline transition does not extend finite segments', () {
    const first = <PatternPoint>[
      PatternPoint(0.0, 0.0),
      PatternPoint(1.0, 0.0),
    ];
    const second = <PatternPoint>[
      PatternPoint(2.0, -1.0),
      PatternPoint(2.0, 1.0),
    ];
    expect(() => geometry.intersectPolylines(first, second), throwsStateError);
  });

  test('polyline-polyline transition rejects too-short input', () {
    expect(
      () => geometry.intersectPolylines(
        const [PatternPoint(0.0, 0.0)],
        const [PatternPoint(0.0, 1.0), PatternPoint(1.0, 0.0)],
      ),
      throwsArgumentError,
    );
  });
}
