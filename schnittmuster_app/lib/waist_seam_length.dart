import 'pattern_models.dart';

class WaistSeamLengthMetrics {
  final double targetHalfWaist;
  final double backBaselineLength;
  final double frontBaselineLength;
  final double dartIntake;

  const WaistSeamLengthMetrics({
    required this.targetHalfWaist,
    required this.backBaselineLength,
    required this.frontBaselineLength,
    required this.dartIntake,
  });

  double get netHalfWaist =>
      backBaselineLength + frontBaselineLength - dartIntake;

  double get halfCorrectionRequired => netHalfWaist - targetHalfWaist;

  double get fullCorrectionRequired => halfCorrectionRequired * 2;
}

class WaistSeamLengthCalculator {
  const WaistSeamLengthCalculator();

  WaistSeamLengthMetrics calculate({
    required Measurements measurements,
    required ConstructionValues construction,
    required PatternPiece back,
    required PatternPiece front,
  }) {
    final p1 = back.points['P1'];
    final p10 = back.points['P10'];
    final p2 = front.points['P2'];
    final p16 = front.points['P16'];

    if (p1 == null || p10 == null || p2 == null || p16 == null) {
      throw ArgumentError('Taillen-Nahtpunkte fehlen.');
    }

    final dartIntake = [
      ...back.darts,
      ...front.darts,
    ].fold<double>(0, (sum, dart) => sum + dart.width);

    return WaistSeamLengthMetrics(
      targetHalfWaist: (measurements.waist + construction.waistEase) / 2,
      backBaselineLength: p1.distanceTo(p10),
      frontBaselineLength: p2.distanceTo(p16),
      dartIntake: dartIntake,
    );
  }
}
