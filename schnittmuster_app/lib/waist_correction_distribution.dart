import 'waist_seam_length.dart';

class WaistCorrectionDistribution {
  final double backCorrection;
  final double frontCorrection;

  const WaistCorrectionDistribution({
    required this.backCorrection,
    required this.frontCorrection,
  });

  double get totalCorrection => backCorrection + frontCorrection;
}

class WaistCorrectionDistributor {
  const WaistCorrectionDistributor();

  WaistCorrectionDistribution distribute({
    required WaistSeamLengthMetrics metrics,
    required double backDartIntake,
    required double frontDartIntake,
  }) {
    final backNet = metrics.backBaselineLength - backDartIntake;
    final frontNet = metrics.frontBaselineLength - frontDartIntake;
    final totalNet = backNet + frontNet;

    if (backNet <= 0 || frontNet <= 0 || totalNet <= 0) {
      throw ArgumentError('Netto-Taillenlaengen muessen groesser als 0 sein.');
    }

    final correction = metrics.halfCorrectionRequired;

    return WaistCorrectionDistribution(
      backCorrection: correction * backNet / totalNet,
      frontCorrection: correction * frontNet / totalNet,
    );
  }
}
