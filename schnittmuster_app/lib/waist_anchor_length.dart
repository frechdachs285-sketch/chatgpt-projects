import 'pattern_models.dart';

class WaistAnchorLengthMetrics {
  final double minimumLength;
  final double targetLength;

  const WaistAnchorLengthMetrics({
    required this.minimumLength,
    required this.targetLength,
  });

  double get excess => minimumLength - targetLength;
  bool get isFeasibleWithoutMovingAnchors => excess <= 0;
}

class WaistAnchorLengthCalculator {
  const WaistAnchorLengthCalculator();

  WaistAnchorLengthMetrics calculate({
    required PatternPoint centerPoint,
    required List<PatternPoint> closedDartMouths,
    required PatternPoint closedSidePoint,
    required double targetLength,
  }) {
    final anchors = <PatternPoint>[
      centerPoint,
      ...closedDartMouths,
      closedSidePoint,
    ];

    var minimumLength = 0.0;
    for (var i = 0; i < anchors.length - 1; i++) {
      minimumLength += anchors[i].distanceTo(anchors[i + 1]);
    }

    return WaistAnchorLengthMetrics(
      minimumLength: minimumLength,
      targetLength: targetLength,
    );
  }
}
