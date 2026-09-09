import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_geometry.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/seam_allowance_geometry.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';
import 'package:schnittmuster_app/trouser_shaped_waistband_facing_builder.dart';
import 'package:schnittmuster_app/trouser_shaped_waistband_facing_pattern_adapter.dart';

void main() {
  const size14 = TrouserMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    bodyRise: 28.7,
    waistToFloor: 105.0,
    trouserBottomWidth: 22.0,
  );

  final draft = TrouserPatternCalculator.calculateReferencePoints(
    size14,
    sizeCode: 14,
  );
  final geometry = const TrouserShapedWaistbandFacingBuilder().build(
    draft: draft,
    facingDepthCm: 4.0,
  );
  const adapter = TrouserShapedWaistbandFacingPatternAdapter();

  test('facing cutting outline is absent when seam allowance is disabled', () {
    expect(
      adapter.front(geometry, seamAllowanceEnabled: false).cuttingOutline,
      isNull,
    );
    expect(
      adapter.back(geometry, seamAllowanceEnabled: false).cuttingOutline,
      isNull,
    );
  });

  test('facing cutting outline is present and closed when enabled', () {
    void verifyClosed(PatternPiece piece) {
      final cutting = piece.cuttingOutline;
      expect(cutting, isNotNull);
      final segments = cutting!.segments;
      expect(segments, isNotEmpty);

      for (var i = 1; i < segments.length; i++) {
        expect(
          segments[i - 1].end.distanceTo(segments[i].start),
          closeTo(0.0, 1e-9),
          reason: 'facing cutting outline must stay continuous at segment $i',
        );
      }
      expect(
        segments.last.end.distanceTo(segments.first.start),
        closeTo(0.0, 1e-9),
        reason: 'facing cutting outline must close back to its start',
      );
    }

    verifyClosed(adapter.front(geometry, seamAllowanceEnabled: true));
    verifyClosed(adapter.back(geometry, seamAllowanceEnabled: true));
  });

  test('facing upper cutting edge keeps 1.5 cm normal-offset geometry', () {
    void verifyUpper(
      PatternPiece piece,
      ShapedWaistbandFacingPieceGeometry section,
      String name,
    ) {
      final vertices = <PatternPoint>[];
      for (final segment in piece.cuttingOutline!.segments) {
        vertices.add(segment.start);
        vertices.add(segment.end);
      }

      var checked = false;
      for (var i = 0; i < section.upperSegments.length; i++) {
        final expected = _offsetCurveRight(
          section.upperSegments[i],
          TrouserShapedWaistbandFacingPatternAdapter.seamAllowanceCm,
        );
        if (expected.length < 3) continue;

        final probe = expected[expected.length ~/ 2];
        final nearest = vertices
            .map((point) => point.distanceTo(probe))
            .reduce((a, b) => a < b ? a : b);

        expect(
          nearest,
          closeTo(0.0, 1e-9),
          reason: '$name upper curve $i must retain its 1.5 cm offset',
        );
        checked = true;
      }

      expect(checked, isTrue, reason: '$name needs an interior offset point');
    }

    verifyUpper(
      adapter.front(geometry, seamAllowanceEnabled: true),
      geometry.front,
      'front facing',
    );
    verifyUpper(
      adapter.back(geometry, seamAllowanceEnabled: true),
      geometry.back,
      'back facing',
    );
  });

  test('facing cutting outline extends beyond sewing outline bounds', () {
    void verifyOutside(PatternPiece piece, String name) {
      final sewing = _bounds(piece.outline);
      final cutting = _bounds(piece.cuttingOutline!);

      expect(cutting.minX, lessThan(sewing.minX), reason: '$name left outside');
      expect(cutting.maxX, greaterThan(sewing.maxX), reason: '$name right outside');
      expect(cutting.minY, lessThan(sewing.minY), reason: '$name top outside');
      expect(cutting.maxY, greaterThan(sewing.maxY), reason: '$name bottom outside');
    }

    verifyOutside(
      adapter.front(geometry, seamAllowanceEnabled: true),
      'front facing',
    );
    verifyOutside(
      adapter.back(geometry, seamAllowanceEnabled: true),
      'back facing',
    );
  });
}

List<PatternPoint> _offsetCurveRight(
  CubicBezierCurve curve,
  double distance,
) {
  final reversed = CubicBezierCurve(
    start: curve.end,
    control1: curve.control2,
    control2: curve.control1,
    end: curve.start,
  );
  return SeamAllowanceGeometry.offsetBezierAdaptive(
    reversed,
    distance,
  ).reversed.toList();
}

_Bounds _bounds(PatternPath path) {
  final points = <PatternPoint>[];
  for (final segment in path.segments) {
    points.add(segment.start);
    points.add(segment.end);
    if (segment is BezierSegment) {
      points.add(segment.control1);
      points.add(segment.control2);
    }
  }

  var minX = points.first.x;
  var maxX = points.first.x;
  var minY = points.first.y;
  var maxY = points.first.y;
  for (final point in points.skip(1)) {
    if (point.x < minX) minX = point.x;
    if (point.x > maxX) maxX = point.x;
    if (point.y < minY) minY = point.y;
    if (point.y > maxY) maxY = point.y;
  }
  return _Bounds(minX, minY, maxX, maxY);
}

class _Bounds {
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  const _Bounds(this.minX, this.minY, this.maxX, this.maxY);
}
