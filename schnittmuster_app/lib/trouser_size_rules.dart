/// Aldrich size-dependent constants used by the classic tailored trouser block.
///
/// Source: Winifred Aldrich, Metric Pattern Cutting for Women's Wear,
/// 5th ed., pp. 100-101.
///
/// Hose v1 intentionally supports only size codes for which every required
/// size-dependent rule is explicitly stated in the source. Size 26 is not
/// enabled here because the 4-13 increment is not stated for size 26.
class TrouserSizeRules {
  final int sizeCode;
  final double frontCrotchGuideCm;
  final double backCrotchGuideCm;
  final double kneeOuterIncrementCm;

  const TrouserSizeRules._({
    required this.sizeCode,
    required this.frontCrotchGuideCm,
    required this.backCrotchGuideCm,
    required this.kneeOuterIncrementCm,
  });

  static const supportedSizeCodes = <int>[6, 8, 10, 12, 14, 16, 18, 20, 22, 24];

  static TrouserSizeRules forSizeCode(int sizeCode) {
    if (!supportedSizeCodes.contains(sizeCode)) {
      throw ArgumentError(
        'Unsupported Aldrich trouser size code: $sizeCode. '
        'Supported: 6, 8, 10, 12, 14, 16, 18, 20, 22, 24.',
      );
    }

    final frontGuide = switch (sizeCode) {
      6 || 8 => 2.75,
      10 || 12 || 14 => 3.0,
      16 || 18 || 20 => 3.25,
      22 || 24 => 3.5,
      _ => throw StateError('Unreachable size code.'),
    };

    final backGuide = switch (sizeCode) {
      6 || 8 => 4.0,
      10 || 12 || 14 => 4.25,
      16 || 18 || 20 => 4.5,
      22 || 24 => 4.75,
      _ => throw StateError('Unreachable size code.'),
    };

    final kneeOuterIncrement = switch (sizeCode) {
      6 || 8 || 10 || 12 || 14 => 1.3,
      16 || 18 || 20 => 1.5,
      22 || 24 => 1.7,
      _ => throw StateError('Unreachable size code.'),
    };

    return TrouserSizeRules._(
      sizeCode: sizeCode,
      frontCrotchGuideCm: frontGuide,
      backCrotchGuideCm: backGuide,
      kneeOuterIncrementCm: kneeOuterIncrement,
    );
  }
}
