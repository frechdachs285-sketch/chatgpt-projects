import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/culotte_base_geometry.dart';
import 'package:schnittmuster_app/culotte_measurements.dart';
import 'package:schnittmuster_app/culotte_outline_builder.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/skirt_pattern_calculator.dart';

void main() {
  const measurements = Measurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    skirtLength: 60.0,
  );
  const culotteMeasurements = CulotteMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    finishedLength: 60.0,
    bodyRise: 28.7,
  );

  PatternPoint pointOf(Map<String, PatternPoint> points, String key) => points[key]!;

  void expectSamePoint(PatternPoint actual, PatternPoint expected) {
    expect(actual.x, closeTo(expected.x, 1e-9));
    expect(actual.y, closeTo(expected.y, 1e-9));
  }

  void expectContinuousAndClosed(PatternPath path) {
    expect(path.segments, isNotEmpty);
    for (var i = 0; i < path.segments.length - 1; i++) {
      expectSamePoint(path.segments[i].end, path.segments[i + 1].start);
    }
    expectSamePoint(path.segments.last.end, path.segments.first.start);
  }

  test('back Culotte outline is continuous, closed and uses confirmed step points', () {
    final skirt = SkirtPatternCalculator().calculate(
      measurements,
      const ConstructionValues(),
      seamAllowance: const SeamAllowanceSettings(enabled: false),
    );
    expect(skirt.isValid, isTrue);

    final geometry = const CulotteBaseGeometryBuilder().build(
      back: skirt.back!,
      front: skirt.front!,
      measurements: culotteMeasurements,
    );
    final outline = const CulotteOutlineBuilder().buildBack(
      skirtBack: skirt.back!,
      geometry: geometry,
    );

    expectContinuousAndClosed(outline);

    final p = geometry.points;
    final innerHem = pointOf(p, 'BACK_INNER_HEM');
    final c4 = pointOf(p, 'C4');
    final c3 = pointOf(p, 'C3');
    final c0 = pointOf(p, 'C0');

    final hem = outline.segments.whereType<LineSegment>().firstWhere(
      (s) => (s.start.x - geometry.skirtBase.sideHem.x).abs() < 1e-9 &&
          (s.start.y - geometry.skirtBase.sideHem.y).abs() < 1e-9,
    );
    expectSamePoint(hem.end, innerHem);

    final inseam = outline.segments.whereType<LineSegment>().firstWhere(
      (s) => (s.start.x - innerHem.x).abs() < 1e-9 &&
          (s.start.y - innerHem.y).abs() < 1e-9,
    );
    expectSamePoint(inseam.end, c4);

    final step = outline.segments.whereType<BezierSegment>().where(
      (s) => s.role == 'culotte_back_step',
    ).toList();
    expect(step.length, 2);
    expectSamePoint(step.first.start, c4);
    expectSamePoint(step.last.end, c3);

    final center = outline.segments.last as LineSegment;
    expectSamePoint(center.start, c3);
    expectSamePoint(center.end, c0);
  });

  test('front Culotte outline is continuous, closed and uses confirmed step points', () {
    final skirt = SkirtPatternCalculator().calculate(
      measurements,
      const ConstructionValues(),
      seamAllowance: const SeamAllowanceSettings(enabled: false),
    );
    expect(skirt.isValid, isTrue);

    final geometry = const CulotteBaseGeometryBuilder().build(
      back: skirt.back!,
      front: skirt.front!,
      measurements: culotteMeasurements,
    );
    final outline = const CulotteOutlineBuilder().buildFront(
      skirtFront: skirt.front!,
      geometry: geometry,
    );

    expectContinuousAndClosed(outline);

    final p = geometry.points;
    final innerHem = pointOf(p, 'FRONT_INNER_HEM');
    final c9 = pointOf(p, 'C9');
    final c8 = pointOf(p, 'C8');
    final c5 = pointOf(p, 'C5');

    final hem = outline.segments.whereType<LineSegment>().firstWhere(
      (s) => (s.start.x - geometry.skirtBase.sideHem.x).abs() < 1e-9 &&
          (s.start.y - geometry.skirtBase.sideHem.y).abs() < 1e-9,
    );
    expectSamePoint(hem.end, innerHem);

    final inseam = outline.segments.whereType<LineSegment>().firstWhere(
      (s) => (s.start.x - innerHem.x).abs() < 1e-9 &&
          (s.start.y - innerHem.y).abs() < 1e-9,
    );
    expectSamePoint(inseam.end, c9);

    final step = outline.segments.whereType<BezierSegment>().where(
      (s) => s.role == 'culotte_front_step',
    ).toList();
    expect(step.length, 2);
    expectSamePoint(step.first.start, c9);
    expectSamePoint(step.last.end, c8);

    final center = outline.segments.last as LineSegment;
    expectSamePoint(center.start, c8);
    expectSamePoint(center.end, c5);
  });
}
