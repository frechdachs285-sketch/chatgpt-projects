import 'dart:math' as math;

import 'pattern_geometry.dart';
import 'pattern_models.dart';
import 'segmented_waist_curve.dart';
import 'skirt_cutting_outline_builder.dart';
import 'waist_curve_unfolder.dart';

class MeasurementsValidator {
  List<String> validate(Measurements m) {
    final errors = <String>[];
    if (m.waist <= 0) errors.add('Der Taillenumfang muss groesser als 0 sein.');
    if (m.hip <= 0) errors.add('Der Hueftumfang muss groesser als 0 sein.');
    if (m.hipDepth <= 0) errors.add('Die Huefttiefe muss groesser als 0 sein.');
    if (m.skirtLength <= 0) errors.add('Die Rocklaenge muss groesser als 0 sein.');
    if (m.hipDepth >= m.skirtLength) errors.add('Die Rocklaenge muss groesser als die Huefttiefe sein.');
    return errors;
  }
}

class SkirtPatternCalculator {
  final MeasurementsValidator validator = MeasurementsValidator();

  PatternResult calculate(
    Measurements m,
    ConstructionValues c, {
    SeamAllowanceSettings seamAllowance = const SeamAllowanceSettings(),
  }) {
    final errors = validator.validate(m);
    if (errors.isNotEmpty) return PatternResult(errors: errors);
    final p = _calculatePoints(m, c);
    final backDart1 = _createDart(center: p['P11']!, apex: p['P13']!, waistStart: p['P1']!, waistEnd: p['P10']!, width: c.backDart1Width, length: c.backDart1Length);
    final backDart2 = _createDart(center: p['P12']!, apex: p['P14']!, waistStart: p['P1']!, waistEnd: p['P10']!, width: c.backDart2Width, length: c.backDart2Length);
    final frontDart = _createDart(center: p['P17']!, apex: p['P18']!, waistStart: p['P2']!, waistEnd: p['P16']!, width: c.frontDartWidth, length: c.frontDartLength);

    final targetPieceWaist = (m.waist + c.waistEase) / 4;
    const waistSolver = SegmentedWaistCurveSolver();
    const waistUnfolder = WaistCurveUnfolder();
    final closedBackWaist = waistSolver.solve(centerPoint: p['P1']!, sidePoint: p['P10']!, hipPoint: p['P7']!, dartsFromCenterToSide: [backDart1, backDart2], targetLength: targetPieceWaist);
    final closedFrontWaist = waistSolver.solve(centerPoint: p['P2']!, sidePoint: p['P16']!, hipPoint: p['P7']!, dartsFromCenterToSide: [frontDart], targetLength: targetPieceWaist);
    final backWaistCurves = waistUnfolder.unfold(closedCurve: closedBackWaist, dartsFromCenterToSide: [backDart1, backDart2]);
    final frontWaistCurves = waistUnfolder.unfold(closedCurve: closedFrontWaist, dartsFromCenterToSide: [frontDart]);
    final curveBuilder = const SideSeamCurveBuilder();
    final backSideCurve = curveBuilder.build(start: closedBackWaist.correctedSidePoint, end: p['P7']!);
    final frontSideCurve = curveBuilder.build(start: closedFrontWaist.correctedSidePoint, end: p['P7']!);

    const cuttingBuilder = SkirtCuttingOutlineBuilder();
    final PatternPath? backCuttingOutline = seamAllowance.enabled
        ? cuttingBuilder.build(
            isBack: true,
            closedWaist: closedBackWaist,
            dartsFromCenterToSide: [backDart1, backDart2],
            sideCurve: backSideCurve,
            hipPoint: p['P7']!,
            sideHemPoint: p['P8']!,
            centerHemPoint: p['P3']!,
            centerWaistPoint: p['P1']!,
            settings: seamAllowance,
          )
        : null;
    final PatternPath? frontCuttingOutline = seamAllowance.enabled
        ? cuttingBuilder.build(
            isBack: false,
            closedWaist: closedFrontWaist,
            dartsFromCenterToSide: [frontDart],
            sideCurve: frontSideCurve,
            hipPoint: p['P7']!,
            sideHemPoint: p['P8']!,
            centerHemPoint: p['P4']!,
            centerWaistPoint: p['P2']!,
            settings: seamAllowance,
          )
        : null;

    final back = PatternPiece(
      id: 'skirt_back', name: 'Rock Rueckenteil',
      points: {for (final key in ['P1','P3','P5','P7','P8','P9','P10','P11','P12','P13','P14']) key: p[key]!},
      darts: [backDart1, backDart2],
      grainline: _grainline(centerX: p['P1']!.x, sideX: p['P8']!.x, skirtLength: m.skirtLength),
      notches: [PatternNotch(position: p['P7']!, role: 'side_hip')],
      labels: [_pieceLabel(centerX: p['P1']!.x, sideX: p['P8']!.x, skirtLength: m.skirtLength, text: 'Rock - Rueckenteil')],
      outline: PatternPath([
        _bezierSegment(backWaistCurves[0], 'waist'), LineSegment(backDart1.leg1, backDart1.apex), LineSegment(backDart1.apex, backDart1.leg2),
        _bezierSegment(backWaistCurves[1], 'waist'), LineSegment(backDart2.leg1, backDart2.apex), LineSegment(backDart2.apex, backDart2.leg2),
        _bezierSegment(backWaistCurves[2], 'waist'), _bezierSegment(backSideCurve, 'sideSeam'), LineSegment(p['P7']!, p['P8']!), LineSegment(p['P8']!, p['P3']!), LineSegment(p['P3']!, p['P1']!),
      ]),
      cuttingOutline: backCuttingOutline,
    );

    final front = PatternPiece(
      id: 'skirt_front', name: 'Rock Vorderteil',
      points: {for (final key in ['P2','P4','P6','P7','P8','P15','P16','P17','P18']) key: p[key]!},
      darts: [frontDart],
      grainline: _grainline(centerX: p['P2']!.x, sideX: p['P8']!.x, skirtLength: m.skirtLength),
      notches: [PatternNotch(position: p['P7']!, role: 'side_hip')],
      labels: [_pieceLabel(centerX: p['P2']!.x, sideX: p['P8']!.x, skirtLength: m.skirtLength, text: 'Rock - Vorderteil')],
      outline: PatternPath([
        _bezierSegment(frontWaistCurves[0], 'waist'), LineSegment(frontDart.leg1, frontDart.apex), LineSegment(frontDart.apex, frontDart.leg2),
        _bezierSegment(frontWaistCurves[1], 'waist'), _bezierSegment(frontSideCurve, 'sideSeam'), LineSegment(p['P7']!, p['P8']!), LineSegment(p['P8']!, p['P4']!), LineSegment(p['P4']!, p['P2']!),
      ]),
      cuttingOutline: frontCuttingOutline,
    );
    return PatternResult(front: front, back: back);
  }

  Grainline _grainline({required double centerX, required double sideX, required double skirtLength}) {
    final x = (centerX + sideX) / 2;
    return Grainline(start: PatternPoint(x, skirtLength * 0.25), end: PatternPoint(x, skirtLength * 0.75));
  }

  PatternLabel _pieceLabel({required double centerX, required double sideX, required double skirtLength, required String text}) {
    final x = (centerX + sideX) / 2;
    final y = skirtLength * 0.82;
    return PatternLabel(position: PatternPoint(x, y), text: text);
  }

  BezierSegment _bezierSegment(CubicBezierCurve curve, String role) => BezierSegment(start: curve.start, control1: curve.control1, control2: curve.control2, end: curve.end, role: role);

  Map<String, PatternPoint> _calculatePoints(Measurements m, ConstructionValues c) {
    final width = m.hip / 2 + c.hipEase / 2;
    final sideX = m.hip / 4 + c.hipEase / 2;
    final quarterWaistWithEase = (m.waist + c.waistEase) / 4;
    final backWaistX = quarterWaistWithEase + c.backDart1Width + c.backDart2Width;
    final frontWaistDistance = quarterWaistWithEase + c.frontDartWidth;
    final frontWaistX = width - frontWaistDistance;
    final p = <String, PatternPoint>{
      'P1': const PatternPoint(0,0), 'P2': PatternPoint(width,0), 'P3': PatternPoint(0,m.skirtLength), 'P4': PatternPoint(width,m.skirtLength),
      'P5': PatternPoint(0,m.hipDepth), 'P6': PatternPoint(width,m.hipDepth), 'P7': PatternPoint(sideX,m.hipDepth), 'P8': PatternPoint(sideX,m.skirtLength),
      'P9': PatternPoint(backWaistX,0), 'P10': PatternPoint(backWaistX,-c.sideWaistLift), 'P15': PatternPoint(frontWaistX,0), 'P16': PatternPoint(frontWaistX,-c.sideWaistLift),
    };
    final backVector = p['P10']! - p['P1']!;
    p['P11'] = p['P1']! + backVector * (1/3); p['P12'] = p['P1']! + backVector * (2/3);
    p['P13'] = _dartApex(p['P11']!, backVector, c.backDart1Length); p['P14'] = _dartApex(p['P12']!, backVector, c.backDart2Length);
    final frontVector = p['P16']! - p['P2']!;
    p['P17'] = p['P2']! + frontVector * (1/3); p['P18'] = _dartApex(p['P17']!, frontVector, c.frontDartLength);
    return p;
  }

  PatternPoint _dartApex(PatternPoint center, PatternPoint waistVector, double length) {
    final vectorLength = math.sqrt(waistVector.x * waistVector.x + waistVector.y * waistVector.y);
    var normal = PatternPoint(-waistVector.y / vectorLength, waistVector.x / vectorLength);
    if (normal.y < 0) normal = normal * -1;
    return center + normal * length;
  }

  Dart _createDart({required PatternPoint center, required PatternPoint apex, required PatternPoint waistStart, required PatternPoint waistEnd, required double width, required double length}) {
    final v = waistEnd - waistStart;
    final len = math.sqrt(v.x * v.x + v.y * v.y);
    final direction = PatternPoint(v.x / len, v.y / len);
    final halfWidth = width / 2;
    return Dart(center: center, apex: apex, leg1: center - direction * halfWidth, leg2: center + direction * halfWidth, width: width, length: length);
  }
}
