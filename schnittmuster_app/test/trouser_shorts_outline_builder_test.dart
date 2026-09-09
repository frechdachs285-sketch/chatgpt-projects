import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';
import 'package:schnittmuster_app/trouser_shorts_outline_builder.dart';

void main() {
  const measurements = TrouserMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    bodyRise: 28.7,
    waistToFloor: 105.0,
    trouserBottomWidth: 22.0,
  );

  const builder = TrouserShortsOutlineBuilder();

  test('front tailored shorts outline is closed and has a straight hem', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(
      measurements,
      sizeCode: 14,
    );
    const shortsDepthY = 40.0;

    final outline = builder.front(
      draft,
      shortsDepthY: shortsDepthY,
      sizeCode: 14,
    );

    _expectClosed(outline);

    final hemSegments = outline.segments.where((segment) {
      return segment.start.y == shortsDepthY && segment.end.y == shortsDepthY;
    }).toList();

    expect(hemSegments.length, 1);
    expect(hemSegments.single, isA<LineSegment>());
    expect(hemSegments.single.start.y, closeTo(shortsDepthY, 1e-9));
    expect(hemSegments.single.end.y, closeTo(shortsDepthY, 1e-9));
  });

  test('back tailored shorts outline is closed and midpoint is 1 cm lower', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(
      measurements,
      sizeCode: 14,
    );
    const shortsDepthY = 40.0;

    final outline = builder.back(
      draft,
      shortsDepthY: shortsDepthY,
      sizeCode: 14,
    );

    _expectClosed(outline);

    final hem = outline.segments.whereType<BezierSegment>().singleWhere(
          (segment) => segment.role == 'back_hem',
        );

    expect(hem.start.y, closeTo(shortsDepthY, 1e-9));
    expect(hem.end.y, closeTo(shortsDepthY, 1e-9));

    final midpoint = PatternPoint(
      0.125 * hem.start.x +
          0.375 * hem.control1.x +
          0.375 * hem.control2.x +
          0.125 * hem.end.x,
      0.125 * hem.start.y +
          0.375 * hem.control1.y +
          0.375 * hem.control2.y +
          0.125 * hem.end.y,
    );

    expect(midpoint.y, closeTo(shortsDepthY + 1.0, 1e-9));
  });
}

void _expectClosed(PatternPath outline) {
  expect(outline.segments, isNotEmpty);

  for (var i = 0; i < outline.segments.length - 1; i++) {
    expect(
      outline.segments[i].end.distanceTo(outline.segments[i + 1].start),
      lessThanOrEqualTo(1e-8),
      reason: 'Gap between segment $i and ${i + 1}',
    );
  }

  expect(
    outline.segments.last.end.distanceTo(outline.segments.first.start),
    lessThanOrEqualTo(1e-8),
    reason: 'Outline is not closed',
  );
}
