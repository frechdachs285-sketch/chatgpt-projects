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

  WaistCorrectionDistribution distribute(WaistSeamLengthMetrics metrics) {
    final backNet = metrics.backBaselineLength;
    final frontNet = metrics.frontBaselineLength;
    final totalNet = backNet + frontNet;

    if (totalNet <= 0) {
      throw ArgumentError('Taillen-Nahtlaengen muessen groesser als 0 sein.');
    }

    final correction = metrics.halfCorrectionRequired;

    return WaistCorrectionDistribution(
      backCorrection: correction * backNet / totalNet,
      frontCorrection: correction * frontNet / totalNet,
    );
  }
}
