import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_cutting_outline_builder.dart';
import 'package:schnittmuster_app/trouser_cutting_outline_p10_transition.dart';
import 'package:schnittmuster_app/trouser_outline_builder.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';
import 'package:schnittmuster_app/trouser_seam_allowance.dart';

void main() {
  const measurements = TrouserMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    bodyRise: 28.7,
    waistToFloor: 105.0,
    trouserBottomWidth: 22.0,
  );
  // Test fixture only. Hose-v1 has no product seam-allowance defaults.
  const settings = TrouserSeamAllowanceSettings(
    enabled: true,
    normalCm: 1.5,
    waistCm: 1.0,
    hemCm: 3.0,
  );
  const outlineBuilder = TrouserOutlineBuilder();
  const cuttingBuilder = TrouserCuttingOutlineBuilder();
  const tolerance = 1e-9;

  test('front P10 production transition equals independent line intersection', () {
    final d = TrouserPatternCalculator.calculateReferencePoints(measurements);
    final parts = cuttingBuilder.prepareOffsetParts(
      outlineBuilder.frontLowerContour(d),
      settings: settings,
      frontP10: d[10],
      frontP11: d[11],
      backP21: d[21],
      backP22: d[22],
    );

    final topIndex = _directedLineIndex(parts, d[6], d[10]);
    final waistIndex = _directedLineIndex(parts, d[10], d[11]);
    expect(waistIndex, topIndex + 1);

    final topPart = parts[topIndex];
    final waistPart = parts[waistIndex];
    expect(topPart.allowanceCm, settings.normalCm);
    expect(waistPart.allowanceCm, settings.waistCm);
    expect(topPart.allowanceCm, isNot(waistPart.allowanceCm));

    final expected = _infiniteLineIntersection(
      topPart.points[0],
      topPart.points[1],
      waistPart.points[0],
      waistPart.points[1],
    );
    final actual = cuttingBuilder.frontP10Transition(topPart, waistPart);

    expect(actual.distanceTo(expected), lessThan(tolerance));
  });
}

int _directedLineIndex(
  List<TrouserOffsetPart> parts,
  PatternPoint start,
  PatternPoint end,
) {
  for (var i = 0; i < parts.length; i++) {
    final source = parts[i].source;
    if (source is LineSegment &&
        source.start.distanceTo(start) <= 1e-9 &&
        source.end.distanceTo(end) <= 1e-9) {
      return i;
    }
  }
  throw StateError('Expected directed source line was not found.');
}

PatternPoint _infiniteLineIntersection(
  PatternPoint a,
  PatternPoint b,
  PatternPoint c,
  PatternPoint d,
) {
  final rx = b.x - a.x;
  final ry = b.y - a.y;
  final sx = d.x - c.x;
  final sy = d.y - c.y;
  final denominator = rx * sy - ry * sx;
  if (denominator.abs() <= 1e-12) {
    throw StateError('Expected fixture lines not to be parallel.');
  }
  final qpx = c.x - a.x;
  final qpy = c.y - a.y;
  final t = (qpx * sy - qpy * sx) / denominator;
  return PatternPoint(a.x + t * rx, a.y + t * ry);
}
