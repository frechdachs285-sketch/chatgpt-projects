import 'trouser_dart_geometry.dart';
import 'trouser_pattern_calculator.dart';

class TrouserFinishedWaistLengths {
  final double frontCm;
  final double backCm;

  const TrouserFinishedWaistLengths({
    required this.frontCm,
    required this.backCm,
  });

  /// One front plus one back piece = half of the garment waist.
  double get halfGarmentCm => frontCm + backCm;

  /// Two fronts plus two backs = complete garment waist.
  double get fullGarmentCm => halfGarmentCm * 2.0;
}

/// Finished Hose-v1 waist seam lengths after the confirmed darts are closed.
///
/// The waist seams are the straight Aldrich lines P10-P11 (front) and
/// P21-P22 (back). Dart intake is removed from those seam lengths exactly;
/// no curve approximation or additional construction value is introduced.
class TrouserWaistLengthCalculator {
  final TrouserDartGeometry darts;

  const TrouserWaistLengthCalculator({
    this.darts = const TrouserDartGeometry(),
  });

  TrouserFinishedWaistLengths calculate(TrouserReferenceDraft draft) {
    final frontDart = darts.front(draft);
    final backDart30 = darts.back30(draft);
    final backDart31 = darts.back31(draft);

    final front = draft[10].distanceTo(draft[11]) -
        frontDart.leg1.distanceTo(frontDart.leg2);
    final back = draft[21].distanceTo(draft[22]) -
        backDart30.leg1.distanceTo(backDart30.leg2) -
        backDart31.leg1.distanceTo(backDart31.leg2);

    if (front <= 0.0 || back <= 0.0) {
      throw StateError('Finished trouser waist length must be positive.');
    }

    return TrouserFinishedWaistLengths(frontCm: front, backCm: back);
  }
}
