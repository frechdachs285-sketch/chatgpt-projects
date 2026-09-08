/// Hose-v1 seam allowance configuration.
///
/// The confirmed Aldrich seam line remains untouched. These values are used
/// only for a separate cutting outline that will be generated in a later step.
class TrouserSeamAllowanceSettings {
  final bool enabled;

  /// Side seam, inseam and crotch seam allowance in centimetres.
  final double normalCm;

  /// Waist edge allowance in centimetres.
  final double waistCm;

  /// Hem allowance in centimetres.
  final double hemCm;

  const TrouserSeamAllowanceSettings({
    this.enabled = false,
    required this.normalCm,
    required this.waistCm,
    required this.hemCm,
  });

  bool get isValid =>
      normalCm.isFinite &&
      waistCm.isFinite &&
      hemCm.isFinite &&
      normalCm >= 0.0 &&
      waistCm >= 0.0 &&
      hemCm >= 0.0;
}

/// Maximum allowed numerical deviation of a generated offset curve from the
/// requested constant seam allowance distance.
///
/// 0.01 cm = 0.1 mm.
const double trouserSeamAllowanceToleranceCm = 0.01;
