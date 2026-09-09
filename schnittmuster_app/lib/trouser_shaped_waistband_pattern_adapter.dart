import 'pattern_geometry.dart';
import 'pattern_models.dart';
import 'seam_allowance_geometry.dart';
import 'trouser_shaped_waistband_builder.dart';

/// Converts the already confirmed shaped-waistband geometry into ordinary
/// [PatternPiece] objects so the existing 1:1 PDF tiling pipeline can be reused
/// without changing the confirmed trouser pieces.
///
/// Confirmed Hose-v1 app rule:
/// - when seam allowance is enabled, the shaped waistband gets a 1.5 cm
///   cutting outline outside its unchanged sewing outline;
/// - 1.5 cm is an app-specific digital rule, not an Aldrich rule.
class TrouserShapedWaistbandPatternAdapter {
  static const double seamAllowanceCm = 1.5;

  const TrouserShapedWaistbandPatternAdapter();

  PatternPiece front(
    TrouserShapedWaistbandGeometry geometry, {
    int sizeCode = 14,
    bool seamAllowanceEnabled = false,
  }) =>
      _piece(
        id: 'trouser_shaped_waistband_front',
        name: 'Geformter Bund vorn',
        section: geometry.front,
        sizeCode: sizeCode,
        seamAllowanceEnabled: seamAllowanceEnabled,
      );

  PatternPiece back(
    TrouserShapedWaistbandGeometry geometry, {
    int sizeCode = 14,
    bool seamAllowanceEnabled = false,
  }) =>
      _piece(
        id: 'trouser_shaped_waistband_back',
        name: 'Geformter Bund hinten',
        section: geometry.back,
        sizeCode: sizeCode,
        seamAllowanceEnabled: seamAllowanceEnabled,
      );

  PatternPiece _piece({
    required String id,
    required String name,
    required ShapedWaistbandPieceGeometry section,
    required int sizeCode,
    required bool seamAllowanceEnabled,
  }) {
    _validateSection(name, section);

    final outline = _closedOutline(section);
    final cuttingOutline = seamAllowanceEnabled
        ? _closedCuttingOutline(section, seamAllowanceCm)
        : null;
    final bounds = _bounds(section);
    final labelPosition = PatternPoint(
      (bounds.minX + bounds.maxX) / 2.0,
      (bounds.minY + bounds.maxY) / 2.0,
    );

    return PatternPiece(
      id: id,
      name: name,
      points: const {},
      outline: outline,
      cuttingOutline: cuttingOutline,
      labels: [
        PatternLabel(
          position: labelPosition,
          text: '$name - Größe $sizeCode',
        ),
      ],
    );
  }

  void _validateSection(
    String name,
    ShapedWaistbandPieceGeometry section,
  ) {
    if (section.upperSegments.isEmpty || section.lowerSegments.isEmpty) {
      throw StateError('$name has no geometry');
    }
    if (section.upperSegments.length != section.lowerSegments.length) {
      throw StateError('$name upper/lower segment count mismatch');
    }
    for (final lower in section.lowerSegments) {
      if (lower.length < 2) {
        throw StateError('$name lower segment has fewer than two points');
      }
    }
  }

  PatternPath _closedOutline(ShapedWaistbandPieceGeometry section) {
    final segments = <PathSegment>[];

    // Confirmed upper sewing edge: centre -> side.
    for (final curve in section.upperSegments) {
      segments.add(
        BezierSegment(
          start: curve.start,
          control1: curve.control1,
          control2: curve.control2,
          end: curve.end,
          role: 'shapedWaistbandUpper',
        ),
      );
    }

    // Close the side edge from upper side to lower side.
    final upperSide = section.upperSegments.last.end;
    final lowerSide = section.lowerSegments.last.last;
    segments.add(LineSegment(upperSide, lowerSide));

    // Lower sewing edge: side -> centre.
    for (var segmentIndex = section.lowerSegments.length - 1;
        segmentIndex >= 0;
        segmentIndex--) {
      final lower = section.lowerSegments[segmentIndex];
      for (var i = lower.length - 1; i > 0; i--) {
        segments.add(LineSegment(lower[i], lower[i - 1]));
      }
    }

    // Centre edge: lower centre -> upper centre.
    final lowerCentre = section.lowerSegments.first.first;
    final upperCentre = section.upperSegments.first.start;
    segments.add(LineSegment(lowerCentre, upperCentre));

    return PatternPath(List.unmodifiable(segments));
  }

  PatternPath _closedCuttingOutline(
    ShapedWaistbandPieceGeometry section,
    double distance,
  ) {
    // The confirmed closed contour runs with the waistband interior on its
    // left side: upper centre->side, side upper->lower, lower side->centre,
    // centre lower->upper. Therefore the outside is the right-hand side of
    // every directed edge.
    final upperEdges = <List<PatternPoint>>[
      for (final curve in section.upperSegments)
        _offsetCurveRight(curve, distance),
    ];
    final upper = _joinSequentialEdges(upperEdges);

    final upperSide = section.upperSegments.last.end;
    final lowerSide = section.lowerSegments.last.last;
    final side = _offsetLineRight(
      LineSegment(upperSide, lowerSide),
      distance,
    );

    final lowerEdges = <List<PatternPoint>>[];
    for (var segmentIndex = section.lowerSegments.length - 1;
        segmentIndex >= 0;
        segmentIndex--) {
      final lower = section.lowerSegments[segmentIndex];
      for (var i = lower.length - 1; i > 0; i--) {
        lowerEdges.add(
          _offsetLineRight(LineSegment(lower[i], lower[i - 1]), distance),
        );
      }
    }
    final lower = _joinSequentialEdges(lowerEdges);

    final lowerCentre = section.lowerSegments.first.first;
    final upperCentre = section.upperSegments.first.start;
    final centre = _offsetLineRight(
      LineSegment(lowerCentre, upperCentre),
      distance,
    );

    final closedPoints = _joinClosedEdges([upper, side, lower, centre]);
    return PatternPath([
      for (var i = 1; i < closedPoints.length; i++)
        LineSegment(closedPoints[i - 1], closedPoints[i]),
    ]);
  }

  List<PatternPoint> _offsetCurveRight(
    CubicBezierCurve curve,
    double distance,
  ) {
    final reversed = CubicBezierCurve(
      start: curve.end,
      control1: curve.control2,
      control2: curve.control1,
      end: curve.start,
    );
    return SeamAllowanceGeometry.offsetBezierAdaptive(
      reversed,
      distance,
    ).reversed.toList();
  }

  List<PatternPoint> _offsetLineRight(
    LineSegment line,
    double distance,
  ) {
    final reversed = LineSegment(line.end, line.start);
    final offset = SeamAllowanceGeometry.offsetLine(reversed, distance);
    return [offset.end, offset.start];
  }

  List<PatternPoint> _joinSequentialEdges(
    List<List<PatternPoint>> edges, {
    double endpointTolerance = 0.00001,
  }) {
    if (edges.isEmpty) {
      throw ArgumentError('At least one edge is required.');
    }

    final result = List<PatternPoint>.from(edges.first);
    for (var i = 1; i < edges.length; i++) {
      final next = List<PatternPoint>.from(edges[i]);
      if (result.last.distanceTo(next.first) <= endpointTolerance) {
        result.addAll(next.skip(1));
        continue;
      }

      final join = SeamAllowanceGeometry.joinOffsetEdges(result, next);
      result[result.length - 1] = join;
      next[0] = join;
      result.addAll(next.skip(1));
    }
    return result;
  }

  List<PatternPoint> _joinClosedEdges(List<List<PatternPoint>> edges) {
    final joins = <PatternPoint>[];
    for (var i = 0; i < edges.length; i++) {
      joins.add(
        SeamAllowanceGeometry.joinOffsetEdges(
          edges[i],
          edges[(i + 1) % edges.length],
        ),
      );
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

  _SectionBounds _bounds(ShapedWaistbandPieceGeometry section) {
    final points = <PatternPoint>[];
    for (final curve in section.upperSegments) {
      points.addAll([
        curve.start,
        curve.control1,
        curve.control2,
        curve.end,
      ]);
    }
    for (final lower in section.lowerSegments) {
      points.addAll(lower);
    }

    var minX = points.first.x;
    var maxX = points.first.x;
    var minY = points.first.y;
    var maxY = points.first.y;
    for (final point in points.skip(1)) {
      if (point.x < minX) minX = point.x;
      if (point.x > maxX) maxX = point.x;
      if (point.y < minY) minY = point.y;
      if (point.y > maxY) maxY = point.y;
    }
    return _SectionBounds(minX, minY, maxX, maxY);
  }
}

class _SectionBounds {
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  const _SectionBounds(this.minX, this.minY, this.maxX, this.maxY);
}
