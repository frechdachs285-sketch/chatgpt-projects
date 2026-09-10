import 'pattern_models.dart';
import 'trouser_cutting_outline_back.dart';
import 'trouser_cutting_outline_builder.dart';
import 'trouser_cutting_outline_front.dart';
import 'trouser_dart_geometry.dart';
import 'trouser_fly.dart';
import 'trouser_outline_builder.dart';
import 'trouser_pattern_calculator.dart';
import 'trouser_seam_allowance.dart';
import 'trouser_shorts_cutting_outline_back.dart';
import 'trouser_shorts_cutting_outline_front.dart';
import 'trouser_shorts_outline_builder.dart';

/// Builds Hose-v1 pattern pieces only from already confirmed geometry.
class TrouserPatternPieceBuilder {
  final TrouserOutlineBuilder outlines;
  final TrouserShortsOutlineBuilder shortsOutlines;
  final TrouserDartGeometry dartGeometry;
  final TrouserCuttingOutlineBuilder cuttingOutlines;

  const TrouserPatternPieceBuilder({
    this.outlines = const TrouserOutlineBuilder(),
    this.shortsOutlines = const TrouserShortsOutlineBuilder(),
    this.dartGeometry = const TrouserDartGeometry(),
    this.cuttingOutlines = const TrouserCuttingOutlineBuilder(),
  });

  /// Legacy/base front used by existing preview/PDF callers.
  ///
  /// It intentionally remains the confirmed Aldrich-derived seam contour.
  /// Use [leftFront] and [rightFront] when physical front-side distinction is
  /// required for the asymmetric Hose-v1 fly.
  PatternPiece front(
    TrouserReferenceDraft draft, {
    TrouserSeamAllowanceSettings? seamAllowance,
    int sizeCode = 14,
  }) =>
      _frontPiece(
        draft,
        id: 'trouser_front',
        name: 'Vorderhose',
        label: 'Vorderhose',
        seamAllowance: seamAllowance,
        sizeCode: sizeCode,
      );

  PatternPiece leftFront(
    TrouserReferenceDraft draft, {
    TrouserSeamAllowanceSettings? seamAllowance,
    int sizeCode = 14,
  }) =>
      _frontPiece(
        draft,
        id: 'trouser_front_left',
        name: 'Vorderhose links',
        label: 'Vorderhose links',
        seamAllowance: seamAllowance,
        sizeCode: sizeCode,
      );

  PatternPiece rightFront(
    TrouserReferenceDraft draft, {
    TrouserSeamAllowanceSettings? seamAllowance,
    int sizeCode = 14,
  }) {
    final base = _frontPiece(
      draft,
      id: 'trouser_front_right',
      name: 'Vorderhose rechts',
      label: 'Vorderhose rechts',
      seamAllowance: null,
      sizeCode: sizeCode,
    );
    final fly = const TrouserFlyBuilder().build(draft);
    final rightOutline = _withCutOnFly(base.outline, fly);
    final cuttingOutline = seamAllowance != null && seamAllowance.enabled
        ? cuttingOutlines.buildFrontCuttingOutline(
            outline: rightOutline,
            draft: draft,
            settings: seamAllowance,
            fly: fly,
          )
        : null;

    return PatternPiece(
      id: base.id,
      name: base.name,
      points: Map.unmodifiable({
        ...base.points,
        'FlyExtensionWaist': fly.extensionWaist,
        'FlyExtensionLower': fly.extensionLower,
      }),
      outline: rightOutline,
      cuttingOutline: cuttingOutline,
      guideLines: [
        ...base.guideLines,
        LineSegment(fly.waistCenterFront, fly.lowerEnd),
      ],
      darts: base.darts,
      grainline: base.grainline,
      notches: base.notches,
      dartNotches: base.dartNotches,
      labels: base.labels,
    );
  }

  PatternPiece shortsLeftFront(
    TrouserReferenceDraft draft, {
    required double shortsDepthY,
    TrouserSeamAllowanceSettings? seamAllowance,
    int sizeCode = 14,
  }) {
    final outline = shortsOutlines.front(
      draft,
      shortsDepthY: shortsDepthY,
      sizeCode: sizeCode,
    );
    final base = _frontPieceFromOutline(
      draft,
      outline: outline,
      id: 'trouser_shorts_front_left',
      name: 'Shorts Vorderhose links',
      label: 'Shorts Vorderhose links',
      sizeCode: sizeCode,
    );
    final cuttingOutline = seamAllowance != null && seamAllowance.enabled
        ? cuttingOutlines.buildFrontShortsCuttingOutline(
            outline: outline,
            draft: draft,
            settings: seamAllowance,
            shortsDepthY: shortsDepthY,
          )
        : null;

    return PatternPiece(
      id: base.id,
      name: base.name,
      points: base.points,
      outline: base.outline,
      cuttingOutline: cuttingOutline,
      guideLines: base.guideLines,
      darts: base.darts,
      grainline: base.grainline,
      notches: base.notches,
      dartNotches: base.dartNotches,
      labels: base.labels,
    );
  }

  PatternPiece shortsRightFront(
    TrouserReferenceDraft draft, {
    required double shortsDepthY,
    TrouserSeamAllowanceSettings? seamAllowance,
    int sizeCode = 14,
  }) {
    final fly = const TrouserFlyBuilder().build(draft);
    final baseOutline = shortsOutlines.front(
      draft,
      shortsDepthY: shortsDepthY,
      sizeCode: sizeCode,
    );
    final outline = _withCutOnFly(baseOutline, fly);
    final base = _frontPieceFromOutline(
      draft,
      outline: outline,
      id: 'trouser_shorts_front_right',
      name: 'Shorts Vorderhose rechts',
      label: 'Shorts Vorderhose rechts',
      sizeCode: sizeCode,
    );
    final cuttingOutline = seamAllowance != null && seamAllowance.enabled
        ? cuttingOutlines.buildFrontShortsCuttingOutline(
            outline: outline,
            draft: draft,
            settings: seamAllowance,
            shortsDepthY: shortsDepthY,
            fly: fly,
          )
        : null;

    return PatternPiece(
      id: base.id,
      name: base.name,
      points: Map.unmodifiable({
        ...base.points,
        'FlyExtensionWaist': fly.extensionWaist,
        'FlyExtensionLower': fly.extensionLower,
      }),
      outline: base.outline,
      cuttingOutline: cuttingOutline,
      guideLines: [
        ...base.guideLines,
        LineSegment(fly.waistCenterFront, fly.lowerEnd),
      ],
      darts: base.darts,
      grainline: base.grainline,
      notches: base.notches,
      dartNotches: base.dartNotches,
      labels: base.labels,
    );
  }

  PatternPiece shortsBack(
    TrouserReferenceDraft draft, {
    required double shortsDepthY,
    TrouserSeamAllowanceSettings? seamAllowance,
    int sizeCode = 14,
  }) {
    final dart30 = dartGeometry.back30(draft);
    final dart31 = dartGeometry.back31(draft);
    final outline = shortsOutlines.back(
      draft,
      shortsDepthY: shortsDepthY,
      sizeCode: sizeCode,
    );
    final cuttingOutline = seamAllowance != null && seamAllowance.enabled
        ? cuttingOutlines.buildBackShortsCuttingOutline(
            outline: outline,
            draft: draft,
            settings: seamAllowance,
          )
        : null;

    return PatternPiece(
      id: 'trouser_shorts_back',
      name: 'Shorts Hinterhose',
      points: _points(draft),
      outline: outline,
      cuttingOutline: cuttingOutline,
      darts: [
        _toDart(dart30, width: 2.0, length: 12.0),
        _toDart(dart31, width: 2.0, length: 10.0),
      ],
      grainline: Grainline(start: draft[0], end: draft[3]),
      labels: [
        PatternLabel(
          position: _midpoint(draft[0], draft[3]),
          text: 'Shorts Hinterhose - Größe $sizeCode',
        ),
      ],
    );
  }

  PatternPath _withCutOnFly(
    PatternPath base,
    TrouserFlyGeometry fly,
  ) {
    final result = <PathSegment>[];
    var replacedCenterFront = false;

    for (final segment in base.segments) {
      final isCenterFront = segment is LineSegment &&
          segment.start.distanceTo(fly.lowerEnd) <= 1e-9 &&
          segment.end.distanceTo(fly.waistCenterFront) <= 1e-9;
      if (!isCenterFront) {
        result.add(segment);
        continue;
      }

      result.add(LineSegment(fly.lowerEnd, fly.extensionLower));
      result.add(LineSegment(fly.extensionLower, fly.extensionWaist));
      result.add(LineSegment(fly.extensionWaist, fly.waistCenterFront));
      replacedCenterFront = true;
    }

    if (!replacedCenterFront) {
      throw StateError('Hose-v1 right front is missing the P6-P10 edge.');
    }
    return PatternPath(result);
  }

  PatternPiece _frontPiece(
    TrouserReferenceDraft draft, {
    required String id,
    required String name,
    required String label,
    TrouserSeamAllowanceSettings? seamAllowance,
    required int sizeCode,
  }) {
    final outline = outlines.frontLowerContour(draft, sizeCode: sizeCode);
    final piece = _frontPieceFromOutline(
      draft,
      outline: outline,
      id: id,
      name: name,
      label: label,
      sizeCode: sizeCode,
    );
    final cuttingOutline = seamAllowance != null && seamAllowance.enabled
        ? cuttingOutlines.buildFrontCuttingOutline(
            outline: outline,
            draft: draft,
            settings: seamAllowance,
          )
        : null;

    return PatternPiece(
      id: piece.id,
      name: piece.name,
      points: piece.points,
      outline: piece.outline,
      cuttingOutline: cuttingOutline,
      guideLines: piece.guideLines,
      darts: piece.darts,
      grainline: piece.grainline,
      notches: piece.notches,
      dartNotches: piece.dartNotches,
      labels: piece.labels,
    );
  }

  PatternPiece _frontPieceFromOutline(
    TrouserReferenceDraft draft, {
    required PatternPath outline,
    required String id,
    required String name,
    required String label,
    required int sizeCode,
  }) {
    final frontDart = dartGeometry.front(draft);
    return PatternPiece(
      id: id,
      name: name,
      points: _points(draft),
      outline: outline,
      cuttingOutline: null,
      darts: [_toDart(frontDart, width: 2.0, length: 10.0)],
      grainline: Grainline(start: draft[0], end: draft[3]),
      labels: [
        PatternLabel(
          position: _midpoint(draft[0], draft[3]),
          text: '$label - Größe $sizeCode',
        ),
      ],
    );
  }

  PatternPiece back(
    TrouserReferenceDraft draft, {
    TrouserSeamAllowanceSettings? seamAllowance,
    int sizeCode = 14,
  }) {
    final dart30 = dartGeometry.back30(draft);
    final dart31 = dartGeometry.back31(draft);
    final outline = outlines.backLowerContour(draft, sizeCode: sizeCode);
    final cuttingOutline = seamAllowance != null && seamAllowance.enabled
        ? cuttingOutlines.buildBackCuttingOutline(
            outline: outline,
            draft: draft,
            settings: seamAllowance,
          )
        : null;

    return PatternPiece(
      id: 'trouser_back',
      name: 'Hinterhose',
      points: _points(draft),
      outline: outline,
      cuttingOutline: cuttingOutline,
      darts: [
        _toDart(dart30, width: 2.0, length: 12.0),
        _toDart(dart31, width: 2.0, length: 10.0),
      ],
      grainline: Grainline(start: draft[0], end: draft[3]),
      labels: [
        PatternLabel(
          position: _midpoint(draft[0], draft[3]),
          text: 'Hinterhose - Größe $sizeCode',
        ),
      ],
    );
  }

  Map<String, PatternPoint> _points(TrouserReferenceDraft draft) =>
      Map.unmodifiable({
        for (final entry in draft.points.entries) 'P${entry.key}': entry.value,
      });

  PatternPoint _midpoint(PatternPoint a, PatternPoint b) =>
      PatternPoint((a.x + b.x) / 2.0, (a.y + b.y) / 2.0);

  Dart _toDart(
    TrouserDart dart, {
    required double width,
    required double length,
  }) =>
      Dart(
        center: dart.center,
        apex: dart.apex,
        leg1: dart.leg1,
        leg2: dart.leg2,
        width: width,
        length: length,
      );
}
