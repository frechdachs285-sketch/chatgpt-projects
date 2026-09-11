import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';
import 'package:schnittmuster_app/trouser_pattern_piece_builder.dart';
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

  const seamAllowance = TrouserSeamAllowanceSettings(
    enabled: true,
    normalCm: 1.5,
    waistCm: 1.0,
    hemCm: 3.0,
  );

  const builder = TrouserPatternPieceBuilder();
  const shortsDepthY = 40.0;

  test('tailored shorts PatternPieces carry closed cutting outlines', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(
      measurements,
      sizeCode: 14,
    );

    final pieces = <PatternPiece>[
      builder.shortsLeftFront(
        draft,
        shortsDepthY: shortsDepthY,
        seamAllowance: seamAllowance,
        sizeCode: 14,
      ),
      builder.shortsRightFront(
        draft,
        shortsDepthY: shortsDepthY,
        seamAllowance: seamAllowance,
        sizeCode: 14,
      ),
      builder.shortsBack(
        draft,
        shortsDepthY: shortsDepthY,
        seamAllowance: seamAllowance,
        sizeCode: 14,
      ),
    ];

    for (final piece in pieces) {
      _expectClosed(piece.outline);
      expect(piece.cuttingOutline, isNotNull, reason: '${piece.name} missing cuttingOutline');
      _expectClosed(piece.cuttingOutline!);
    }
  });

  test('tailored shorts omit cutting outline when seam allowance is disabled', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(
      measurements,
      sizeCode: 14,
    );

    const disabled = TrouserSeamAllowanceSettings(
      enabled: false,
      normalCm: 1.5,
      waistCm: 1.0,
      hemCm: 3.0,
    );

    final pieces = <PatternPiece>[
      builder.shortsLeftFront(
        draft,
        shortsDepthY: shortsDepthY,
        seamAllowance: disabled,
        sizeCode: 14,
      ),
      builder.shortsRightFront(
        draft,
        shortsDepthY: shortsDepthY,
        seamAllowance: disabled,
        sizeCode: 14,
      ),
      builder.shortsBack(
        draft,
        shortsDepthY: shortsDepthY,
        seamAllowance: disabled,
        sizeCode: 14,
      ),
    ];

    for (final piece in pieces) {
      _expectClosed(piece.outline);
      expect(piece.cuttingOutline, isNull);
    }
  });

  test('right tailored shorts keeps the confirmed fly extension points', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(
      measurements,
      sizeCode: 14,
    );

    final right = builder.shortsRightFront(
      draft,
      shortsDepthY: shortsDepthY,
      seamAllowance: seamAllowance,
      sizeCode: 14,
    );

    expect(right.points.containsKey('FlyExtensionWaist'), isTrue);
    expect(right.points.containsKey('FlyExtensionLower'), isTrue);
    expect(right.guideLines, isNotEmpty);
    expect(right.cuttingOutline, isNotNull);
  });
}

void _expectClosed(PatternPath path) {
  expect(path.segments, isNotEmpty);

  for (var i = 0; i < path.segments.length - 1; i++) {
    expect(
      path.segments[i].end.distanceTo(path.segments[i + 1].start),
      lessThanOrEqualTo(1e-8),
      reason: 'Gap between segment $i and ${i + 1}',
    );
  }

  expect(
    path.segments.last.end.distanceTo(path.segments.first.start),
    lessThanOrEqualTo(1e-8),
    reason: 'Path is not closed',
  );
}
