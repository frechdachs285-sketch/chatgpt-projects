import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_outline_builder.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';

void main() {
  const measurements = TrouserMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    bodyRise: 28.7,
    waistToFloor: 105.0,
    trouserBottomWidth: 22.0,
  );
  const outlines = TrouserOutlineBuilder();

  List<PatternPoint> sampledContour(PatternPath path) {
    final points = <PatternPoint>[];
    for (final segment in path.segments) {
      if (segment is LineSegment) {
        if (points.isEmpty) points.add(segment.start);
        points.add(segment.end);
      } else if (segment is BezierSegment) {
        if (points.isEmpty) points.add(segment.start);
        for (var i = 1; i <= 20; i++) {
          final t = i / 20.0;
          final u = 1.0 - t;
          points.add(
            segment.start * (u * u * u) +
                segment.control1 * (3.0 * u * u * t) +
                segment.control2 * (3.0 * u * t * t) +
                segment.end * (t * t * t),
          );
        }
      }
    }
    return points;
  }

  double signedTwiceArea(List<PatternPoint> points) {
    var sum = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      sum += points[i].x * points[i + 1].y -
          points[i + 1].x * points[i].y;
    }
    return sum;
  }

  test('front and back confirmed contours have positive signed area in y-down coordinates', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final front = sampledContour(outlines.frontLowerContour(draft));
    final back = sampledContour(outlines.backLowerContour(draft));

    expect(front.first.distanceTo(front.last), lessThan(1e-9));
    expect(back.first.distanceTo(back.last), lessThan(1e-9));
    expect(signedTwiceArea(front), greaterThan(0.0));
    expect(signedTwiceArea(back), greaterThan(0.0));
  });

  test('positive signed area in y-down means piece interior is on directed right side', () {
    const rectangle = [
      PatternPoint(0.0, 0.0),
      PatternPoint(2.0, 0.0),
      PatternPoint(2.0, 1.0),
      PatternPoint(0.0, 1.0),
      PatternPoint(0.0, 0.0),
    ];
    expect(signedTwiceArea(rectangle), greaterThan(0.0));
  });
}
