import 'pattern_geometry.dart';
import 'pattern_models.dart';
import 'seam_allowance_geometry.dart';
import 'segmented_waist_curve.dart';
import 'waist_curve_unfolder.dart';

class SkirtCuttingOutlineBuilder {
  const SkirtCuttingOutlineBuilder();

  PatternPath build({
    required bool isBack,
    required SegmentedWaistCurveResult closedWaist,
    required List<Dart> dartsFromCenterToSide,
    required CubicBezierCurve sideCurve,
    required PatternPoint hipPoint,
    required PatternPoint sideHemPoint,
    required PatternPoint centerHemPoint,
    required PatternPoint centerWaistPoint,
    required SeamAllowanceSettings settings,
    double curveMaxDeviation = 0.01,
  }) {
    if (!settings.enabled) {
      throw ArgumentError('Nahtzugabe ist deaktiviert.');
    }
    if (!curveMaxDeviation.isFinite || curveMaxDeviation <= 0) {
      throw ArgumentError.value(
        curveMaxDeviation,
        'curveMaxDeviation',
        'muss endlich und groesser als 0 sein',
      );
    }

    final waist = _buildWaistEdge(
      isBack: isBack,
      closedWaist: closedWaist,
      dartsFromCenterToSide: dartsFromCenterToSide,
      distance: settings.waist,
      maxDeviation: curveMaxDeviation,
    );

    final sideCurvePoints = _offsetCurve(
      sideCurve,
      settings.side,
      leftSide: !isBack,
      maxDeviation: curveMaxDeviation,
    );
    final lowerSidePoints = _offsetLine(
      LineSegment(hipPoint, sideHemPoint),
      settings.side,
      leftSide: !isBack,
    );
    final side = _mergeTangential(sideCurvePoints, lowerSidePoints);

    final hem = _offsetLine(
      LineSegment(sideHemPoint, centerHemPoint),
      settings.hem,
      leftSide: !isBack,
    );

    final centerDistance = isBack ? settings.backCenter : settings.frontCenter;
    final center = _offsetLine(
      LineSegment(centerHemPoint, centerWaistPoint),
      centerDistance,
      leftSide: !isBack,
    );

    final closedPoints = _joinClosedEdges([waist, side, hem, center]);
    final segments = <PathSegment>[];
    for (var i = 1; i < closedPoints.length; i++) {
      segments.add(LineSegment(closedPoints[i - 1], closedPoints[i]));
    }
    return PatternPath(segments);
  }

  List<PatternPoint> _buildWaistEdge({
    required bool isBack,
    required SegmentedWaistCurveResult closedWaist,
    required List<Dart> dartsFromCenterToSide,
    required double distance,
    required double maxDeviation,
  }) {
    final closedOffsetSegments = [
      for (final curve in closedWaist.segments)
        _offsetCurve(
          curve,
          distance,
          leftSide: !isBack,
          maxDeviation: maxDeviation,
        ),
    ];

    final unfolded = const WaistCurveUnfolder().unfoldSampledSegments(
      closedSegments: closedOffsetSegments,
      dartsFromCenterToSide: dartsFromCenterToSide,
    );

    final points = <PatternPoint>[];
    for (final segment in unfolded) {
      if (points.isEmpty) {
        points.addAll(segment);
      } else {
        // The straight connection between the two unfolded endpoints is the
        // cutting edge across the opened dart mouth.
        points.addAll(segment);
      }
    }
    return points;
  }

  List<PatternPoint> _offsetCurve(
    CubicBezierCurve curve,
    double distance, {
    required bool leftSide,
    required double maxDeviation,
  }) {
    if (leftSide) {
      return SeamAllowanceGeometry.offsetBezierAdaptive(
        curve,
        distance,
        maxDeviation: maxDeviation,
      );
    }

    final reversed = CubicBezierCurve(
      start: curve.end,
      control1: curve.control2,
      control2: curve.control1,
      end: curve.start,
    );
    return SeamAllowanceGeometry.offsetBezierAdaptive(
      reversed,
      distance,
      maxDeviation: maxDeviation,
    ).reversed.toList();
  }

  List<PatternPoint> _offsetLine(
    LineSegment line,
    double distance, {
    required bool leftSide,
  }) {
    if (leftSide) {
      final offset = SeamAllowanceGeometry.offsetLine(line, distance);
      return [offset.start, offset.end];
    }

    final reversed = LineSegment(line.end, line.start);
    final offset = SeamAllowanceGeometry.offsetLine(reversed, distance);
    return [offset.end, offset.start];
  }

  List<PatternPoint> _mergeTangential(
    List<PatternPoint> first,
    List<PatternPoint> second, {
    double tolerance = 0.00001,
  }) {
    if (first.last.distanceTo(second.first) > tolerance) {
      throw StateError('Tangentiale Offset-Kanten treffen nicht exakt zusammen.');
    }
    return [...first, ...second.skip(1)];
  }

  List<PatternPoint> _joinClosedEdges(List<List<PatternPoint>> edges) {
    if (edges.length < 3) {
      throw ArgumentError('Eine geschlossene Kontur braucht mindestens drei Kanten.');
    }

    final joins = <PatternPoint>[];
    for (var i = 0; i < edges.length; i++) {
      final current = edges[i];
      final next = edges[(i + 1) % edges.length];
      joins.add(SeamAllowanceGeometry.joinOffsetEdges(current, next));
    }

    final result = <PatternPoint>[];
    for (var i = 0; i < edges.length; i++) {
      final edge = List<PatternPoint>.from(edges[i]);
      final previousJoin = joins[(i - 1 + edges.length) % edges.length];
      final nextJoin = joins[i];
      edge[0] = previousJoin;
      edge[edge.length - 1] = nextJoin;

      if (result.isEmpty) {
        result.addAll(edge);
      } else {
        result.addAll(edge.skip(1));
      }
    }

    if (result.last.distanceTo(result.first) > 0.000001) {
      result.add(result.first);
    }
    return result;
  }
}
