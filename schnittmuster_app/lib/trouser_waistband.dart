/// Confirmed Hose-v1 straight waistband rules.
///
/// Source basis: Aldrich straight waistband construction.
/// The finished width of 4.0 cm is a confirmed Hose-v1 product decision,
/// within the source range of 2.5-6.0 cm.
class TrouserWaistbandSettings {
  /// Finished waistband width in centimetres.
  static const double finishedWidthCm = 4.0;

  /// Cut width before seam allowances: twice the finished width.
  static const double cutWidthWithoutSeamAllowanceCm =
      finishedWidthCm * 2.0;

  /// Underlap/extension in centimetres.
  static const double underlapCm = 4.0;

  const TrouserWaistbandSettings._();
}
