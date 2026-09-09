import 'pattern_models.dart';
import 'trouser_pattern_calculator.dart';

/// Digital product rule for the Hose-v1 classic front fly.
///
/// This is deliberately NOT attributed to the Aldrich classic tailored
/// trouser block. Aldrich pages 100/101 do not define a fly construction.
/// The 4.0 cm width is a Hose-v1 product decision, informed separately by
/// fly-front construction references. The lower end is derived from the
/// existing front crotch geometry instead of using an invented fixed length.
/// The fly extension is assigned to the wearer's right front and is cut on
/// as part of that front piece. Both are explicit Hose-v1 product decisions.
class TrouserFlySettings {
  static const double widthCm = 4.0;
  static const TrouserFlySide side = TrouserFlySide.wearerRightFront;
  static const TrouserFlyArchitecture architecture =
      TrouserFlyArchitecture.cutOnExtension;

  const TrouserFlySettings._();
}

enum TrouserFlySide {
  wearerRightFront,
}

enum TrouserFlyArchitecture {
  cutOnExtension,
}

class TrouserFlyGeometry {
  final PatternPoint waistCenterFront;
  final PatternPoint lowerEnd;
  final double widthCm;
  final TrouserFlySide side;
  final TrouserFlyArchitecture architecture;

  const TrouserFlyGeometry({
    required this.waistCenterFront,
    required this.lowerEnd,
    required this.widthCm,
    required this.side,
    required this.architecture,
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
      side: TrouserFlySettings.side,
      architecture: TrouserFlySettings.architecture,
    );
  }
}
