import 'culotte_base_geometry.dart';
import 'culotte_cutting_outline_builder.dart';
import 'culotte_outline_builder.dart';
import 'culotte_seam_allowance.dart';
import 'pattern_models.dart';

/// Converts the confirmed Culotte v1 geometry into PatternPiece objects.
///
/// The confirmed seam line always remains [outline]. A separate
/// [cuttingOutline] is generated only when an enabled Culotte seam-allowance
/// configuration is explicitly supplied. No notches, labels or grainline are
/// introduced here.
class CulottePatternPieceBuilder {
  final CulotteOutlineBuilder _outlineBuilder;
  final CulotteCuttingOutlineBuilder _cuttingOutlineBuilder;

  const CulottePatternPieceBuilder({
    CulotteOutlineBuilder outlineBuilder = const CulotteOutlineBuilder(),
    CulotteCuttingOutlineBuilder cuttingOutlineBuilder =
        const CulotteCuttingOutlineBuilder(),
  })  : _outlineBuilder = outlineBuilder,
        _cuttingOutlineBuilder = cuttingOutlineBuilder;

  PatternPiece buildBack({
    required PatternPiece skirtBack,
    required CulotteBaseGeometry geometry,
    CulotteSeamAllowanceSettings? seamAllowance,
  }) {
    final outline = _outlineBuilder.buildBack(
      skirtBack: skirtBack,
      geometry: geometry,
    );
    final darts = List<Dart>.unmodifiable(skirtBack.darts);
    final points = Map<String, PatternPoint>.unmodifiable({
      ...skirtBack.points,
      for (final entry in geometry.points.entries) entry.key: entry.value,
    });

    final basePiece = PatternPiece(
      id: 'culotte_back',
      name: 'Culotte Rueckenteil',
      points: points,
      outline: outline,
      darts: darts,
    );

    final cuttingOutline = seamAllowance != null && seamAllowance.enabled
        ? _cuttingOutlineBuilder.build(
            piece: basePiece,
            isBack: true,
            settings: seamAllowance,
          )
        : null;

    return PatternPiece(
      id: basePiece.id,
      name: basePiece.name,
      points: points,
      outline: outline,
      cuttingOutline: cuttingOutline,
      darts: darts,
    );
  }

  PatternPiece buildFront({
    required PatternPiece skirtFront,
    required CulotteBaseGeometry geometry,
    CulotteSeamAllowanceSettings? seamAllowance,
  }) {
    final outline = _outlineBuilder.buildFront(
      skirtFront: skirtFront,
      geometry: geometry,
    );
    final darts = List<Dart>.unmodifiable(skirtFront.darts);
    final points = Map<String, PatternPoint>.unmodifiable({
      ...skirtFront.points,
      for (final entry in geometry.points.entries) entry.key: entry.value,
    });

    final basePiece = PatternPiece(
      id: 'culotte_front',
      name: 'Culotte Vorderteil',
      points: points,
      outline: outline,
      darts: darts,
    );

    final cuttingOutline = seamAllowance != null && seamAllowance.enabled
        ? _cuttingOutlineBuilder.build(
            piece: basePiece,
            isBack: false,
            settings: seamAllowance,
          )
        : null;

    return PatternPiece(
      id: basePiece.id,
      name: basePiece.name,
      points: points,
      outline: outline,
      cuttingOutline: cuttingOutline,
      darts: darts,
    );
  }
}
