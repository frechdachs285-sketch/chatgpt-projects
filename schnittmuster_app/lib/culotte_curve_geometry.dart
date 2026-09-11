import 'pattern_models.dart';
import 'trouser_curve_geometry.dart';

/// Digital curve construction for Culotte v1.
///
/// The Aldrich construction supplies the end points and the 3 cm / 4 cm
/// curve-touch points. The interpolation itself is the app-specific natural
/// cubic spline already used and tested for Hose v1.
class CulotteCurveGeometry {
  final TrouserCurveBuilder _curveBuilder;

  const CulotteCurveGeometry({
    TrouserCurveBuilder curveBuilder = const TrouserCurveBuilder(),
  }) : _curveBuilder = curveBuilder;

  TrouserNaturalSpline backStepCurve({
    required PatternPoint c3,
    required PatternPoint h3,
    required PatternPoint c4,
  }) =>
      _curveBuilder.naturalSplineThrough([c3, h3, c4]);

  TrouserNaturalSpline frontStepCurve({
    required PatternPoint c8,
    required PatternPoint h4,
    required PatternPoint c9,
  }) =>
      _curveBuilder.naturalSplineThrough([c8, h4, c9]);
}
