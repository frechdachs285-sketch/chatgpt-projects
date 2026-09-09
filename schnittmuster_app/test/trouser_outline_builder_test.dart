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

  final draft = TrouserPatternCalculator.calculateReferencePoints(measurements);
  const builder = TrouserOutlineBuilder();

  void expectContinuous(PatternPath path, {double tolerance = 1e-9}) {
    for (var i = 0; i < path.segments.length - 1; i++) {
      final a = path.segments[i];
      final b = path.segments[i + 1];
      expect(a.end.distanceTo(b.start), lessThanOrEqualTo(tolerance));
    }
  }

  void expectClosed(PatternPath path, {double tolerance = 1e-9}) {
    expectContinuous(path, tolerance: tolerance);
    expect(path.segments.last.end.distanceTo(path.segments.first.start), lessThanOrEqualTo(tolerance));
  }

  test('front contour is continuous and closed through P6-P10-P11', () {
    final path = builder.frontLowerContour(draft);
    expect(path.segments, isNotEmpty);
    expect(path.segments.first.start.distanceTo(draft[11]), lessThan(1e-9));
    expect(path.segments[path.segments.length - 2].start.distanceTo(draft[6]), lessThan(1e-9));
    expect(path.segments[path.segments.length - 2].end.distanceTo(draft[10]), lessThan(1e-9));
    expect(path.segments.last.start.distanceTo(draft[10]), lessThan(1e-9));
    expect(path.segments.last.end.distanceTo(draft[11]), lessThan(1e-9));
    expectClosed(path);
  });

  test('back contour is continuous and closed through P21-P22', () {
    final path = builder.backLowerContour(draft);
    expect(path.segments, isNotEmpty);
    expect(path.segments.first.start.distanceTo(draft[22]), lessThan(1e-9));
    expect(path.segments.last.start.distanceTo(draft[21]), lessThan(1e-9));
    expect(path.segments.last.end.distanceTo(draft[22]), lessThan(1e-9));
    expectClosed(path);
  });

  test('front and back contours include confirmed hem and crotch roles', () {
    final front = builder.frontLowerContour(draft);
    final back = builder.backLowerContour(draft);
    expect(front.segments.whereType<BezierSegment>().any((s) => s.role == 'front_hem'), isTrue);
    expect(front.segments.whereType<BezierSegment>().any((s) => s.role == 'front_crotch'), isTrue);
    expect(back.segments.whereType<BezierSegment>().any((s) => s.role == 'back_hem'), isTrue);
    expect(back.segments.whereType<BezierSegment>().any((s) => s.role == 'back_crotch'), isTrue);
  });

  test('explicit size 14 keeps reference crotch contours exactly unchanged', () {
    final defaultFront = builder.frontLowerContour(draft);
    final size14Front = builder.frontLowerContour(draft, sizeCode: 14);
    final defaultBack = builder.backLowerContour(draft);
    final size14Back = builder.backLowerContour(draft, sizeCode: 14);

    void samePath(PatternPath a, PatternPath b) {
      expect(a.segments.length, b.segments.length);
      for (var i = 0; i < a.segments.length; i++) {
        expect(a.segments[i].start.distanceTo(b.segments[i].start), lessThan(1e-12));
        expect(a.segments[i].end.distanceTo(b.segments[i].end), lessThan(1e-12));
        if (a.segments[i] is BezierSegment && b.segments[i] is BezierSegment) {
          final aa = a.segments[i] as BezierSegment;
          final bb = b.segments[i] as BezierSegment;
          expect(aa.control1.distanceTo(bb.control1), lessThan(1e-12));
          expect(aa.control2.distanceTo(bb.control2), lessThan(1e-12));
        }
      }
    }

    samePath(defaultFront, size14Front);
    samePath(defaultBack, size14Back);
  });

  test('selected Aldrich size changes crotch curves while preserving endpoints', () {
    final front14 = builder.frontLowerContour(draft, sizeCode: 14);
    final front24 = builder.frontLowerContour(draft, sizeCode: 24);
    final back14 = builder.backLowerContour(draft, sizeCode: 14);
    final back24 = builder.backLowerContour(draft, sizeCode: 24);

    final f14 = front14.segments.whereType<BezierSegment>().where((s) => s.role == 'front_crotch').toList();
    final f24 = front24.segments.whereType<BezierSegment>().where((s) => s.role == 'front_crotch').toList();
    final b14 = back14.segments.whereType<BezierSegment>().where((s) => s.role == 'back_crotch').toList();
    final b24 = back24.segments.whereType<BezierSegment>().where((s) => s.role == 'back_crotch').toList();

    expect(f14.first.start.distanceTo(f24.first.start), lessThan(1e-12));
    expect(f14.last.end.distanceTo(f24.last.end), lessThan(1e-12));
    expect(b14.first.start.distanceTo(b24.first.start), lessThan(1e-12));
    expect(b14.last.end.distanceTo(b24.last.end), lessThan(1e-12));

    expect(f14.any((s) => f24.every((t) => s.control1.distanceTo(t.control1) > 1e-9)), isTrue);
    expect(b14.any((s) => b24.every((t) => s.control1.distanceTo(t.control1) > 1e-9)), isTrue);
  });
}
