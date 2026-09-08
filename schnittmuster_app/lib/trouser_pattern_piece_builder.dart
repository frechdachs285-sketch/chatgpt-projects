import 'pattern_models.dart';
import 'trouser_dart_geometry.dart';
import 'trouser_outline_builder.dart';
import 'trouser_pattern_calculator.dart';

/// Builds Hose-v1 pattern pieces only from already confirmed geometry.
class TrouserPatternPieceBuilder {
  final TrouserOutlineBuilder outlines;
  final TrouserDartGeometry dartGeometry;

  const TrouserPatternPieceBuilder({
    this.outlines = const TrouserOutlineBuilder(),
    this.dartGeometry = const TrouserDartGeometry(),
  });

  PatternPiece front(TrouserReferenceDraft draft) {
    final frontDart = dartGeometry.front(draft);
    return PatternPiece(
      id: 'trouser_front',
      name: 'Vorderhose',
      points: _points(draft),
      outline: outlines.frontLowerContour(draft),
      darts: [_toDart(frontDart, width: 2.0, length: 10.0)],
      grainline: Grainline(start: draft[0], end: draft[3]),
    );
  }

  PatternPiece back(TrouserReferenceDraft draft) {
    final dart30 = dartGeometry.back30(draft);
    final dart31 = dartGeometry.back31(draft);
    return PatternPiece(
      id: 'trouser_back',
      name: 'Hinterhose',
      points: _points(draft),
      outline: outlines.backLowerContour(draft),
      darts: [
        _toDart(dart30, width: 2.0, length: 12.0),
        _toDart(dart31, width: 2.0, length: 10.0),
      ],
      grainline: Grainline(start: draft[0], end: draft[3]),
    );
  }

  Map<String, PatternPoint> _points(TrouserReferenceDraft draft) =>
      Map.unmodifiable({
        for (final entry in draft.points.entries) 'P${entry.key}': entry.value,
      });

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
