/// Culotte-v1 seam allowance configuration.
///
/// These are app-side cutting-outline values. They do not alter the confirmed
/// Aldrich seam line and are deliberately kept separate from Hose-v1 settings.
class CulotteSeamAllowanceSettings {
  final bool enabled;

  /// Side seam, inner-leg seam, crotch seam and centre seam allowance in cm.
  final double normalCm;

  /// Waist-edge allowance in cm.
  final double waistCm;

  /// Hem allowance in cm.
  final double hemCm;

  const CulotteSeamAllowanceSettings({
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

/// Reuses the already tested digital offset tolerance from Hose v1.
/// 0.01 cm = 0.1 mm. This is an app engineering rule, not an Aldrich value.
const double culotteSeamAllowanceToleranceCm = 0.01;
