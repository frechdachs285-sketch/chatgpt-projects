import 'dart:math' as math;

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
  final PatternPoint extensionWaist;
  final PatternPoint extensionLower;
  final double widthCm;
  final TrouserFlySide side;
  final TrouserFlyArchitecture architecture;

  const TrouserFlyGeometry({
    required this.waistCenterFront,
    required this.lowerEnd,
    required this.extensionWaist,
    required this.extensionLower,
    required this.widthCm,
    required this.side,
    required this.architecture,
  });

  double get lengthCm => waistCenterFront.distanceTo(lowerEnd);

  PatternPath get extensionOutline => PatternPath([
        LineSegment(waistCenterFront, extensionWaist),
        LineSegment(extensionWaist, extensionLower),
        LineSegment(extensionLower, lowerEnd),
      ]);
}

class TrouserFlyBuilder {
  const TrouserFlyBuilder();

  TrouserFlyGeometry build(TrouserReferenceDraft draft) {
    // P10 is the centre-front waist point. P6 is the confirmed junction
    // between the straight centre-front section and the front crotch curve.
    // Therefore the fly length follows the actual draft geometry.
    final waistCenterFront = draft[10];
    final lowerEnd = draft[6];

    final dx = lowerEnd.x - waistCenterFront.x;
    final dy = lowerEnd.y - waistCenterFront.y;
    final length = math.sqrt(dx * dx + dy * dy);
    if (length == 0) {
      throw StateError('Hose-v1 fly requires distinct P10 and P6 points.');
    }

    // Build the cut-on edge at an exact 4.0 cm perpendicular distance from
    // the P10-P6 centre-front line. The sign is kept as an explicit digital
    // convention for the already confirmed wearer's-right-front piece.
    final offsetX = -dy / length * TrouserFlySettings.widthCm;
    final offsetY = dx / length * TrouserFlySettings.widthCm;
    final extensionWaist = PatternPoint(
      waistCenterFront.x + offsetX,
      waistCenterFront.y + offsetY,
    );
    final extensionLower = PatternPoint(
      lowerEnd.x + offsetX,
      lowerEnd.y + offsetY,
    );

    return TrouserFlyGeometry(
      waistCenterFront: waistCenterFront,
      lowerEnd: lowerEnd,
      extensionWaist: extensionWaist,
      extensionLower: extensionLower,
      widthCm: TrouserFlySettings.widthCm,
      side: TrouserFlySettings.side,
      architecture: TrouserFlySettings.architecture,
    );
  }
}
