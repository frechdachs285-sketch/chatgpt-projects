import 'culotte_base_geometry.dart';
import 'culotte_outline_builder.dart';
import 'pattern_models.dart';

/// Converts the confirmed Culotte v1 geometry into PatternPiece objects.
///
/// Only source-confirmed skirt darts and the Culotte seam outline are carried
/// over here. No seam allowance, notches, labels or grainline are introduced.
class CulottePatternPieceBuilder {
  final CulotteOutlineBuilder _outlineBuilder;

  const CulottePatternPieceBuilder({
    CulotteOutlineBuilder outlineBuilder = const CulotteOutlineBuilder(),
  }) : _outlineBuilder = outlineBuilder;

  PatternPiece buildBack({
    required PatternPiece skirtBack,
    required CulotteBaseGeometry geometry,
  }) {
    return PatternPiece(
      id: 'culotte_back',
      name: 'Culotte Rueckenteil',
      points: Map<String, PatternPoint>.unmodifiable({
        ...skirtBack.points,
        for (final entry in geometry.points.entries) entry.key: entry.value,
      }),
      outline: _outlineBuilder.buildBack(
        skirtBack: skirtBack,
        geometry: geometry,
      ),
      darts: List<Dart>.unmodifiable(skirtBack.darts),
    );
  }

  PatternPiece buildFront({
    required PatternPiece skirtFront,
    required CulotteBaseGeometry geometry,
  }) {
    return PatternPiece(
      id: 'culotte_front',
      name: 'Culotte Vorderteil',
      points: Map<String, PatternPoint>.unmodifiable({
        ...skirtFront.points,
        for (final entry in geometry.points.entries) entry.key: entry.value,
      }),
      outline: _outlineBuilder.buildFront(
        skirtFront: skirtFront,
        geometry: geometry,
      ),
      darts: List<Dart>.unmodifiable(skirtFront.darts),
    );
  }
}
