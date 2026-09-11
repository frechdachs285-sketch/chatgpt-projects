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

    // App consistency rule: Aldrich's C2/C7 define the finished hemline,
    // therefore they must coincide with the hem depth of the skirt basis that
    // the Culotte construction is drawn around. This introduces no new
    // construction measurement; it only prevents incompatible inputs/bases.
    const tolerance = 1e-9;
    bool samePoint(PatternPoint a, PatternPoint b) =>
        (a.x - b.x).abs() <= tolerance && (a.y - b.y).abs() <= tolerance;

    if (!samePoint(points['C2']!, skirtBase.backCenterHem) ||
        !samePoint(points['C7']!, skirtBase.frontCenterHem)) {
      throw StateError(
        'Die Culotte-Fertiglaenge stimmt nicht mit der Saumtiefe der Rock-Grundlage ueberein.',
      );
    }

    // Aldrich: square down from C4/C9 to the finished hemline.
    // These names are app-specific derived points, not Aldrich point numbers.
    points['BACK_INNER_HEM'] = PatternPoint(points['C4']!.x, points['C2']!.y);
    points['FRONT_INNER_HEM'] = PatternPoint(points['C9']!.x, points['C7']!.y);

    return CulotteBaseGeometry(
      skirtBase: skirtBase,
      points: Map<String, PatternPoint>.unmodifiable(points),
    );
  }
}
