import 'pattern_models.dart';

class WaistConstructionMetrics {
  final double targetHalfWaist;
  final double projectedBackWaist;
  final double projectedFrontWaist;
  final double dartIntake;

  const WaistConstructionMetrics({
    required this.targetHalfWaist,
    required this.projectedBackWaist,
    required this.projectedFrontWaist,
    required this.dartIntake,
  });

  double get netProjectedWaist =>
      projectedBackWaist + projectedFrontWaist - dartIntake;

  double get differenceToTarget => netProjectedWaist - targetHalfWaist;

  bool matchesTarget({double tolerance = 0.000001}) =>
      differenceToTarget.abs() <= tolerance;
}

class WaistConstructionMetricsCalculator {
  const WaistConstructionMetricsCalculator();

  WaistConstructionMetrics calculate({
    required Measurements measurements,
    required ConstructionValues construction,
    required PatternPiece back,
    required PatternPiece front,
  }) {
    final p1 = back.points['P1'];
    final p9 = back.points['P9'];
    final p2 = front.points['P2'];
    final p15 = front.points['P15'];

    if (p1 == null || p9 == null || p2 == null || p15 == null) {
      throw ArgumentError('Taillen-Konstruktionspunkte fehlen.');
    }

    final projectedBackWaist = (p9.x - p1.x).abs();
    final projectedFrontWaist = (p2.x - p15.x).abs();
    final dartIntake = [
      ...back.darts,
      ...front.darts,
    ].fold<double>(0, (sum, dart) => sum + dart.width);

    return WaistConstructionMetrics(
      targetHalfWaist: (measurements.waist + construction.waistEase) / 2,
      projectedBackWaist: projectedBackWaist,
      projectedFrontWaist: projectedFrontWaist,
      dartIntake: dartIntake,
    );
  }
}
