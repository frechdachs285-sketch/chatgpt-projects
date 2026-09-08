import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_cutting_outline_builder.dart';
import 'package:schnittmuster_app/trouser_seam_allowance.dart';

void main() {
  const builder = TrouserCuttingOutlineBuilder();
  const settings = TrouserSeamAllowanceSettings(
    enabled: true,
    normalCm: 1.2,
    waistCm: 0.8,
    hemCm: 3.4,
  );
  const p10 = PatternPoint(1.0, 0.0);
  const p11 = PatternPoint(8.0, 0.0);
  const p21 = PatternPoint(-2.0, 1.0);
  const p22 = PatternPoint(7.0, 0.0);
  const tolerance = 1e-9;

  double allowance(PathSegment segment) => builder.allowanceForSegment(
        segment,
        settings: settings,
        frontP10: p10,
        frontP11: p11,
        backP21: p21,
        backP22: p22,
      );

  test('front and back waist use only waist allowance', () {
    expect(allowance(LineSegment(p10, p11)), settings.waistCm);
    expect(allowance(LineSegment(p21, p22)), settings.waistCm);
  });

  test('hem role uses only hem allowance', () {
    final hem = BezierSegment(
      start: const PatternPoint(8.0, 10.0),
      control1: const PatternPoint(5.0, 11.0),
      control2: const PatternPoint(-5.0, 11.0),
      end: const PatternPoint(-8.0, 10.0),
      role: 'front_hem',
    );
    expect(allowance(hem), settings.hemCm);
  });

  test('normal contour lines do not accidentally become waist allowance', () {
    final frontCenterTop = LineSegment(
      const PatternPoint(0.0, 4.0),
      p10,
    );
    final lowerInseam = LineSegment(
      const PatternPoint(-6.0, 10.0),
      const PatternPoint(-5.0, 5.0),
    );
    expect(allowance(frontCenterTop), settings.normalCm);
    expect(allowance(lowerInseam), settings.normalCm);
  });

  test('non-hem bezier uses normal allowance', () {
    final crotch = BezierSegment(
      start: const PatternPoint(0.0, 4.0),
      control1: const PatternPoint(-1.0, 5.0),
      control2: const PatternPoint(-2.0, 6.0),
      end: const PatternPoint(-3.0, 7.0),
      role: 'front_crotch',
    );
    expect(allowance(crotch), settings.normalCm);
  });

  test('invalid settings are rejected before classification', () {
    const invalid = TrouserSeamAllowanceSettings(
      enabled: true,
      normalCm: -0.1,
      waistCm: 1.0,
      hemCm: 2.0,
    );
    final segment = LineSegment(p10, p11);
    expect(
      () => builder.allowanceForSegment(
        segment,
        settings: invalid,
        frontP10: p10,
        frontP11: p11,
        backP21: p21,
        backP22: p22,
      ),
      throwsArgumentError,
    );
  });

  test('prepareOffsetParts preserves order and selects exact allowances', () {
    final normal = LineSegment(const PatternPoint(0.0, 4.0), p10);
    final waist = LineSegment(p10, p11);
    final hem = BezierSegment(
      start: const PatternPoint(8.0, 10.0),
      control1: const PatternPoint(5.0, 11.0),
      control2: const PatternPoint(-5.0, 11.0),
      end: const PatternPoint(-8.0, 10.0),
      role: 'front_hem',
    );
    final outline = PatternPath([normal, waist, hem]);

    final parts = builder.prepareOffsetParts(
      outline,
      settings: settings,
      frontP10: p10,
      frontP11: p11,
      backP21: p21,
      backP22: p22,
    );

    expect(parts, hasLength(3));
    expect(identical(parts[0].source, normal), isTrue);
    expect(identical(parts[1].source, waist), isTrue);
    expect(identical(parts[2].source, hem), isTrue);
    expect(parts[0].allowanceCm, settings.normalCm);
    expect(parts[1].allowanceCm, settings.waistCm);
    expect(parts[2].allowanceCm, settings.hemCm);
    expect(parts[0].points, hasLength(2));
    expect(parts[1].points, hasLength(2));
    expect(parts[2].points.length, greaterThanOrEqualTo(2));
  });

  test('disabled seam allowance prepares no cutting-outline parts', () {
    const disabled = TrouserSeamAllowanceSettings(
      enabled: false,
      normalCm: 1.2,
      waistCm: 0.8,
      hemCm: 3.4,
    );
    final original = LineSegment(const PatternPoint(0.0, 4.0), p10);
    final outline = PatternPath([original]);

    final parts = builder.prepareOffsetParts(
      outline,
      settings: disabled,
      frontP10: p10,
      frontP11: p11,
      backP21: p21,
      backP22: p22,
    );

    expect(parts, isEmpty);
    expect(identical(outline.segments.single, original), isTrue);
  });

  test('lineLineTransition returns exact corner of extended offset lines', () {
    final firstSource = LineSegment(
      const PatternPoint(0.0, 0.0),
      const PatternPoint(4.0, 0.0),
    );
    final secondSource = LineSegment(
      const PatternPoint(4.0, 0.0),
      const PatternPoint(4.0, 5.0),
    );
    final first = TrouserOffsetPart(
      source: firstSource,
      allowanceCm: 1.0,
      points: const [PatternPoint(0.0, 1.0), PatternPoint(4.0, 1.0)],
    );
    final second = TrouserOffsetPart(
      source: secondSource,
      allowanceCm: 2.0,
      points: const [PatternPoint(2.0, 0.0), PatternPoint(2.0, 5.0)],
    );

    final corner = builder.lineLineTransition(first, second);

    expect(corner.x, closeTo(2.0, tolerance));
    expect(corner.y, closeTo(1.0, tolerance));
  });

  test('lineLineTransition rejects a curved source part', () {
    final curve = BezierSegment(
      start: const PatternPoint(0.0, 0.0),
      control1: const PatternPoint(1.0, 0.0),
      control2: const PatternPoint(2.0, 1.0),
      end: const PatternPoint(3.0, 1.0),
      role: 'test_curve',
    );
    final line = LineSegment(
      const PatternPoint(3.0, 1.0),
      const PatternPoint(3.0, 5.0),
    );
    final first = TrouserOffsetPart(
      source: curve,
      allowanceCm: 1.0,
      points: const [PatternPoint(0.0, 1.0), PatternPoint(3.0, 2.0)],
    );
    final second = TrouserOffsetPart(
      source: line,
      allowanceCm: 1.0,
      points: const [PatternPoint(2.0, 1.0), PatternPoint(2.0, 5.0)],
    );

    expect(() => builder.lineLineTransition(first, second), throwsArgumentError);
  });
}
