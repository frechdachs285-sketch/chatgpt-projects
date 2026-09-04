import 'dart:math' as math;

import 'pattern_models.dart';

class WaistSidePointCorrectionResult {
  final PatternPoint originalPoint;
  final PatternPoint correctedPoint;
  final double originalLength;
  final double targetLength;
  final double horizontalShift;

  const WaistSidePointCorrectionResult({
    required this.originalPoint,
    required this.correctedPoint,
    required this.originalLength,
    required this.targetLength,
    required this.horizontalShift,
  });
}

class WaistSidePointCorrector {
  const WaistSidePointCorrector();

  WaistSidePointCorrectionResult correct({
    required PatternPoint centerPoint,
    required PatternPoint sidePoint,
    required double lengthReduction,
  }) {
    if (lengthReduction < 0) {
      throw ArgumentError('Die Laengenkorrektur darf nicht negativ sein.');
    }

    final originalLength = centerPoint.distanceTo(sidePoint);
    final targetLength = originalLength - lengthReduction;
    final verticalDifference = (sidePoint.y - centerPoint.y).abs();
    final originalHorizontalDifference = (sidePoint.x - centerPoint.x).abs();

    if (targetLength <= verticalDifference) {
      throw ArgumentError('Die Zielstrecke ist fuer die feste Taillenhoehe zu kurz.');
    }

    final targetHorizontalDifference = math.sqrt(
      targetLength * targetLength - verticalDifference * verticalDifference,
    );

    if (targetHorizontalDifference > originalHorizontalDifference) {
      throw StateError('Die Korrektur wuerde die Taillenweite vergroessern.');
    }

    final horizontalShift =
        originalHorizontalDifference - targetHorizontalDifference;
    final directionToCenter = (centerPoint.x - sidePoint.x).sign;

    final correctedPoint = PatternPoint(
      sidePoint.x + directionToCenter * horizontalShift,
      sidePoint.y,
    );

    return WaistSidePointCorrectionResult(
      originalPoint: sidePoint,
      correctedPoint: correctedPoint,
      originalLength: originalLength,
      targetLength: targetLength,
      horizontalShift: horizontalShift,
    );
  }
}
