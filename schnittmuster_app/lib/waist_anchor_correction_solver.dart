import 'pattern_models.dart';
import 'waist_anchor_length.dart';
import 'waist_dart_closure.dart';

class WaistAnchorCorrectionResult {
  final PatternPoint correctedSidePoint;
  final double horizontalShift;
  final double correctedMinimumLength;

  const WaistAnchorCorrectionResult({
    required this.correctedSidePoint,
    required this.horizontalShift,
    required this.correctedMinimumLength,
  });
}

class WaistAnchorCorrectionSolver {
  const WaistAnchorCorrectionSolver();

  WaistAnchorCorrectionResult solve({
    required PatternPoint centerPoint,
    required PatternPoint sidePoint,
    required List<Dart> dartsFromCenterToSide,
    required double targetLength,
    double tolerance = 0.000001,
  }) {
    final directionToCenter = (centerPoint.x - sidePoint.x).sign;
    if (directionToCenter == 0) {
      throw ArgumentError('Seitlicher Taillenpunkt muss horizontal von der Mitte getrennt sein.');
    }

    double minimumLengthFor(double shift) {
      final candidate = PatternPoint(
        sidePoint.x + directionToCenter * shift,
        sidePoint.y,
      );
      final closure = const WaistDartClosure().close(
        sidePoint: candidate,
        dartsFromCenterToSide: dartsFromCenterToSide,
      );
      return const WaistAnchorLengthCalculator()
          .calculate(
            centerPoint: centerPoint,
            closedDartMouths: closure.closedDartMouths,
            closedSidePoint: closure.closedSidePoint,
            targetLength: targetLength,
          )
          .minimumLength;
    }

    final originalLength = minimumLengthFor(0);
    if (originalLength < targetLength - tolerance) {
      throw StateError('Pflichtpunkt-Strecke ist bereits kuerzer als das Ziel.');
    }
    if ((originalLength - targetLength).abs() <= tolerance) {
      return WaistAnchorCorrectionResult(
        correctedSidePoint: sidePoint,
        horizontalShift: 0,
        correctedMinimumLength: originalLength,
      );
    }

    var low = 0.0;
    var high = 0.01;
    while (minimumLengthFor(high) > targetLength) {
      high *= 2;
      if (high > 5.0) {
        throw StateError('Taillen-Seitenpunkt konnte nicht ausreichend korrigiert werden.');
      }
    }

    for (var i = 0; i < 70; i++) {
      final mid = (low + high) / 2;
      final length = minimumLengthFor(mid);
      if (length > targetLength) {
        low = mid;
      } else {
        high = mid;
      }
    }

    final shift = (low + high) / 2;
    final corrected = PatternPoint(
      sidePoint.x + directionToCenter * shift,
      sidePoint.y,
    );
    final correctedLength = minimumLengthFor(shift);

    if ((correctedLength - targetLength).abs() > tolerance * 10) {
      throw StateError('Ziel-Laenge wurde nicht ausreichend genau erreicht.');
    }

    return WaistAnchorCorrectionResult(
      correctedSidePoint: corrected,
      horizontalShift: shift,
      correctedMinimumLength: correctedLength,
    );
  }
}
