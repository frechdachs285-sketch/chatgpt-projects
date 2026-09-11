import 'culotte_base_geometry.dart';
import 'culotte_cutting_outline_builder.dart';
import 'culotte_outline_builder.dart';
import 'culotte_seam_allowance.dart';
import 'pattern_models.dart';

class CulottePatternPieceBuilder {
  final CulotteOutlineBuilder _outlineBuilder;
  final CulotteCuttingOutlineBuilder _cuttingOutlineBuilder;

  const CulottePatternPieceBuilder({
    CulotteOutlineBuilder outlineBuilder = const CulotteOutlineBuilder(),
    CulotteCuttingOutlineBuilder cuttingOutlineBuilder =
        const CulotteCuttingOutlineBuilder(),
  })  : _outlineBuilder = outlineBuilder,
        _cuttingOutlineBuilder = cuttingOutlineBuilder;

  PatternLabel _labelFor(Grainline grainline, String text) {
    return PatternLabel(
      position: PatternPoint(
        (grainline.start.x + grainline.end.x) / 2.0,
        (grainline.start.y + grainline.end.y) / 2.0,
      ),
      text: text,
    );
  }

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
    final grainline = skirtBack.grainline;
    if (grainline == null) {
      throw StateError('Der Fadenlauf der Rock-Grundlage fehlt.');
    }
    final labels = <PatternLabel>[
      _labelFor(grainline, 'Culotte Rueckenteil'),
    ];

    final basePiece = PatternPiece(
      id: 'culotte_back',
      name: 'Culotte Rueckenteil',
      points: points,
      outline: outline,
      darts: darts,
      grainline: grainline,
      labels: labels,
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
      grainline: grainline,
      labels: labels,
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
    final grainline = skirtFront.grainline;
    if (grainline == null) {
      throw StateError('Der Fadenlauf der Rock-Grundlage fehlt.');
    }
    final labels = <PatternLabel>[
      _labelFor(grainline, 'Culotte Vorderteil'),
    ];

    final basePiece = PatternPiece(
      id: 'culotte_front',
      name: 'Culotte Vorderteil',
      points: points,
      outline: outline,
      darts: darts,
      grainline: grainline,
      labels: labels,
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
      grainline: grainline,
      labels: labels,
    );
  }
}
