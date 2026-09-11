/// Input values needed for the Aldrich simple culotte construction.
///
/// Rock v1 remains unchanged. These values are kept in a separate model so
/// Culotte v1 can add `bodyRise` without modifying the existing rock model.
class CulotteMeasurements {
  final double waist;
  final double hip;
  final double hipDepth;
  final double finishedLength;
  final double bodyRise;

  const CulotteMeasurements({
    required this.waist,
    required this.hip,
    required this.hipDepth,
    required this.finishedLength,
    required this.bodyRise,
  });
}
