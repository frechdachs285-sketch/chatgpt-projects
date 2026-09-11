import 'culotte_seam_allowance.dart';
import 'pattern_geometry.dart';
import 'pattern_models.dart';
import 'seam_allowance_geometry.dart';
import 'waist_curve_unfolder.dart';

/// Builds the Culotte-v1 cutting outline from the already confirmed seam-line
/// PatternPiece. The seam line itself is never modified.
///
/// Digital rules reused from the existing app infrastructure:
/// - tolerance-controlled normal offsets for cubic Beziers;
/// - exact line intersections for corner joins;
/// - the already tested dart-waist unfolding used by Rock v1.
///
/// No Aldrich construction value is introduced here.
class CulotteCuttingOutlineBuilder {
  const CulotteCuttingOutlineBuilder();

  PatternPath build({
    required PatternPiece piece,
    required bool isBack,
    required CulotteSeamAllowanceSettings settings,
  }) {
    if (!settings.enabled) {
      throw ArgumentError('Nahtzugabe ist deaktiviert.');
    }
    if (!settings.isValid) {
      throw ArgumentError('Ungueltige Culotte-Nahtzugabe.');
    }

    final waistSegments = piece.outline.segments
        .whereType<BezierSegment>()
        .where((segment) => segment.role == 'waist')
        .toList();
    if (waistSegments.length != piece.darts.length + 1) {
      throw StateError('Culotte-Taillenkontur und Abnaeher passen nicht zusammen.');
    }

    final sideCurve = piece.outline.segments
        .whereType<BezierSegment>()
        .where((segment) => segment.role == 'sideSeam')
        .toList();
    if (sideCurve.length != 1) {
      throw StateError('Culotte-Seitenkurve ist nicht eindeutig.');
    }

    final stepRole = isBack ? 'culotte_back_step' : 'culotte_front_step';
    final stepCurves = piece.outline.segments
        .whereType<BezierSegment>()
        .where((segment) => segment.role == stepRole)
        .toList();
    if (stepCurves.length != 2) {
      throw StateError('Culotte-Schrittkurve ist nicht vollstaendig.');
    }

    final sideCurveIndex = piece.outline.segments.indexOf(sideCurve.single);
    if (sideCurveIndex < 0 || sideCurveIndex + 1 >= piece.outline.segments.length) {
      throw StateError('Culotte-Seitenkontur ist unvollstaendig.');
    }
    final lowerSide = piece.outline.segments[sideCurveIndex + 1];
    if (lowerSide is! LineSegment) {
      throw StateError('Untere Culotte-Seitennaht fehlt.');
    }

    final lowerSideIndex = sideCurveIndex + 1;
    final hemIndex = lowerSideIndex + 1;
    final innerLegIndex = hemIndex + 1;
    if (innerLegIndex >= piece.outline.segments.length) {
      throw StateError('Culotte-Saum oder Innenbein fehlt.');
    }
    final hem = piece.outline.segments[hemIndex];
    final innerLeg = piece.outline.segments[innerLegIndex];
    if (hem is! LineSegment || innerLeg is! LineSegment) {
      throw StateError('Culotte-Saum oder Innenbein ist nicht geradlinig.');
    }

    final center = piece.outline.segments.last;
    if (center is! LineSegment) {
      throw StateError('Culotte-Mittellinie fehlt.');
    }

    final leftSide = !isBack;

    final waistClosedOffsets = [
      for (final segment in waistSegments)
        _offsetBezier(
          segment,
          settings.waistCm,
          leftSide: leftSide,
        ),
    ];
    final waistUnfolded = const WaistCurveUnfolder().unfoldSampledSegments(
      closedSegments: waistClosedOffsets,
      dartsFromCenterToSide: piece.darts,
    );
    final waist = <PatternPoint>[
      for (final segment in waistUnfolded) ...segment,
    ];

    final side = _mergeTangential(
      _offsetBezier(sideCurve.single, settings.normalCm, leftSide: leftSide),
      _offsetLine(lowerSide, settings.normalCm, leftSide: leftSide),
    );

    final hemEdge = _offsetLine(hem, settings.hemCm, leftSide: leftSide);
    final innerLegEdge = _offsetLine(
      innerLeg,
      settings.normalCm,
      leftSide: leftSide,
    );

    var stepEdge = _offsetBezier(
      stepCurves.first,
      settings.normalCm,
      leftSide: leftSide,
    );
    stepEdge = _mergeTangential(
      stepEdge,
      _offsetBezier(
        stepCurves.last,
        settings.normalCm,
        leftSide: leftSide,
      ),
    );

    final centerEdge = _offsetLine(
      center,
      settings.normalCm,
      leftSide: leftSide,
    );

    final closedPoints = _joinClosedEdges([
      waist,
      side,
      hemEdge,
      innerLegEdge,
      stepEdge,
      centerEdge,
    ]);

    return PatternPath([
      for (var i = 1; i < closedPoints.length; i++)
        LineSegment(closedPoints[i - 1], closedPoints[i]),
    ]);
  }

  List<PatternPoint> _offsetBezier(
    BezierSegment segment,
    double distance, {
    required bool leftSide,
  }) {
    CubicBezierCurve asCurve(BezierSegment s) => CubicBezierCurve(
          start: s.start,
          control1: s.control1,
          control2: s.control2,
          end: s.end,
        );

    if (leftSide) {
      return SeamAllowanceGeometry.offsetBezierAdaptive(
        asCurve(segment),
        distance,
        maxDeviation: culotteSeamAllowanceToleranceCm,
      );
    }

    final reversed = BezierSegment(
      start: segment.end,
      control1: segment.control2,
      control2: segment.control1,
      end: segment.start,
      role: segment.role,
    );
    return SeamAllowanceGeometry.offsetBezierAdaptive(
      asCurve(reversed),
      distance,
      maxDeviation: culotteSeamAllowanceToleranceCm,
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
      throw StateError('Tangentiale Culotte-Offsetkanten treffen nicht zusammen.');
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
      edge[0] = joins[(i - 1 + edges.length) % edges.length];
      edge[edge.length - 1] = joins[i];
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
