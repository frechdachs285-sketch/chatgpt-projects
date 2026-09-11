import 'culotte_measurements.dart';
import 'culotte_pattern_calculator.dart';
import 'culotte_skirt_base_adapter.dart';
import 'pattern_models.dart';

/// Combined Culotte v1 base geometry.
///
/// This joins the confirmed Straight-Skirt basis with the source-based
/// Culotte construction points. The local Culotte point systems are only
/// translated into the Rock coordinate system; no additional shaping rules
/// are introduced here.
class CulotteBaseGeometry {
  final CulotteSkirtBase skirtBase;
  final Map<String, PatternPoint> points;

  const CulotteBaseGeometry({
    required this.skirtBase,
    required this.points,
  });
}

class CulotteBaseGeometryBuilder {
  final CulotteSkirtBaseAdapter _baseAdapter;
  final CulottePatternCalculator _pointCalculator;

  const CulotteBaseGeometryBuilder({
    CulotteSkirtBaseAdapter baseAdapter = const CulotteSkirtBaseAdapter(),
    CulottePatternCalculator pointCalculator = const CulottePatternCalculator(),
  })  : _baseAdapter = baseAdapter,
        _pointCalculator = pointCalculator;

  CulotteBaseGeometry build({
    required PatternPiece back,
    required PatternPiece front,
    required CulotteMeasurements measurements,
  }) {
    final skirtBase = _baseAdapter.fromPatternPieces(back: back, front: front);
    final local = _pointCalculator.calculatePoints(measurements);

    PatternPoint translate(PatternPoint point, PatternPoint origin) =>
        PatternPoint(point.x + origin.x, point.y + origin.y);

    final points = <String, PatternPoint>{};

    for (final key in ['C0', 'C1', 'C2', 'C3', 'C4', 'H3']) {
      points[key] = translate(local[key]!, skirtBase.backCenterWaist);
    }
    for (final key in ['C5', 'C6', 'C7', 'C8', 'C9', 'H4']) {
      points[key] = translate(local[key]!, skirtBase.frontCenterWaist);
    }

    return CulotteBaseGeometry(
      skirtBase: skirtBase,
      points: Map<String, PatternPoint>.unmodifiable(points),
    );
  }
}
