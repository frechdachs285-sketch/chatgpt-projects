import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';
import 'package:schnittmuster_app/trouser_shaped_waistband_builder.dart';
import 'package:schnittmuster_app/trouser_shaped_waistband_pattern_adapter.dart';

void main() {
  const size14 = TrouserMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    bodyRise: 28.7,
    waistToFloor: 105.0,
    trouserBottomWidth: 22.0,
  );

  test('adapter keeps confirmed shaped waistband geometry unchanged', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(
      size14,
      sizeCode: 14,
    );
    const builder = TrouserShapedWaistbandBuilder();
    const adapter = TrouserShapedWaistbandPatternAdapter();

    final geometry = builder.build(
      draft: draft,
      waistbandDepthCm: 4.0,
    );
    final front = adapter.front(geometry, sizeCode: 14);
    final back = adapter.back(geometry, sizeCode: 14);

    expect(front.cuttingOutline, isNull);
    expect(back.cuttingOutline, isNull);
    expect(front.darts, isEmpty);
    expect(back.darts, isEmpty);
    expect(front.guideLines, isEmpty);
    expect(back.guideLines, isEmpty);

    expect(front.outline.segments.first.start.distanceTo(
      geometry.front.upperSegments.first.start,
    ), closeTo(0.0, 1e-12));
    expect(back.outline.segments.first.start.distanceTo(
      geometry.back.upperSegments.first.start,
    ), closeTo(0.0, 1e-12));

    expect(
      geometry.front.upperSegments.first.start.distanceTo(
        geometry.front.lowerSegments.first.first,
      ),
      closeTo(4.0, 1e-9),
    );
    expect(
      geometry.back.upperSegments.first.start.distanceTo(
        geometry.back.lowerSegments.first.first,
      ),
      closeTo(4.0, 1e-9),
    );
  });

  test('adapter creates one continuous closed outline for front and back', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(
      size14,
      sizeCode: 14,
    );
    const builder = TrouserShapedWaistbandBuilder();
    const adapter = TrouserShapedWaistbandPatternAdapter();

    final geometry = builder.build(
      draft: draft,
      waistbandDepthCm: 4.0,
    );

    void verifyClosed(PatternPiece piece) {
      expect(piece.outline.segments, isNotEmpty);
      final segments = piece.outline.segments;

      for (var i = 1; i < segments.length; i++) {
        expect(
          segments[i - 1].end.distanceTo(segments[i].start),
          closeTo(0.0, 1e-9),
          reason: 'outline must stay continuous at segment $i',
        );
      }

      expect(
        segments.last.end.distanceTo(segments.first.start),
        closeTo(0.0, 1e-9),
        reason: 'outline must close back to its start',
      );

      for (final segment in segments) {
        expect(segment.start.x.isFinite, isTrue);
        expect(segment.start.y.isFinite, isTrue);
        expect(segment.end.x.isFinite, isTrue);
        expect(segment.end.y.isFinite, isTrue);
        if (segment is BezierSegment) {
          expect(segment.control1.x.isFinite, isTrue);
          expect(segment.control1.y.isFinite, isTrue);
          expect(segment.control2.x.isFinite, isTrue);
          expect(segment.control2.y.isFinite, isTrue);
        }
      }
    }

    verifyClosed(adapter.front(geometry));
    verifyClosed(adapter.back(geometry));
  });

  test('adapter keeps expected upper Bezier segment counts', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(
      size14,
      sizeCode: 14,
    );
    const builder = TrouserShapedWaistbandBuilder();
    const adapter = TrouserShapedWaistbandPatternAdapter();

    final geometry = builder.build(
      draft: draft,
      waistbandDepthCm: 4.0,
    );

    final front = adapter.front(geometry);
    final back = adapter.back(geometry);

    expect(
      front.outline.segments.whereType<BezierSegment>().length,
      2,
    );
    expect(
      back.outline.segments.whereType<BezierSegment>().length,
      3,
    );
  });
}
