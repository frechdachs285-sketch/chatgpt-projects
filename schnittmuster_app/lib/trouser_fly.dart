import 'pattern_models.dart';
import 'trouser_pattern_calculator.dart';

/// Digital product rule for the Hose-v1 classic front fly.
///
/// This is deliberately NOT attributed to the Aldrich classic tailored
/// trouser block. Aldrich pages 100/101 do not define a fly construction.
/// The 4.0 cm width is a Hose-v1 product decision, informed separately by
/// fly-front construction references. The lower end is derived from the
/// existing front crotch geometry instead of using an invented fixed length.
class TrouserFlySettings {
  static const double widthCm = 4.0;

  const TrouserFlySettings._();
}

class TrouserFlyGeometry {
  final PatternPoint waistCenterFront;
  final PatternPoint lowerEnd;
  final double widthCm;

  const TrouserFlyGeometry({
    required this.waistCenterFront,
    required this.lowerEnd,
    required this.widthCm,
  });

  double get lengthCm => waistCenterFront.distanceTo(lowerEnd);
}

class TrouserFlyBuilder {
  const TrouserFlyBuilder();

  TrouserFlyGeometry build(TrouserReferenceDraft draft) {
    // P10 is the centre-front waist point. P6 is the confirmed junction
    // between the straight centre-front section and the front crotch curve.
    // Therefore the fly length follows the actual draft geometry.
    return TrouserFlyGeometry(
      waistCenterFront: draft[10],
      lowerEnd: draft[6],
      widthCm: TrouserFlySettings.widthCm,
    );
  }
}
