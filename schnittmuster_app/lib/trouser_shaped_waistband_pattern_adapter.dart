import 'pattern_models.dart';
import 'trouser_shaped_waistband_builder.dart';

/// Converts the already confirmed shaped-waistband geometry into ordinary
/// [PatternPiece] objects so the existing 1:1 PDF tiling pipeline can be reused
/// later without changing the confirmed trouser pieces.
///
/// This adapter adds no seam allowance and changes no construction geometry.
/// It only converts the confirmed upper curves and lower offset polylines into
/// one closed sewing-outline path per section.
class TrouserShapedWaistbandPatternAdapter {
  const TrouserShapedWaistbandPatternAdapter();

  PatternPiece front(
    TrouserShapedWaistbandGeometry geometry, {
    int sizeCode = 14,
  }) =>
      _piece(
        id: 'trouser_shaped_waistband_front',
        name: 'Geformter Bund vorn',
        section: geometry.front,
        sizeCode: sizeCode,
      );

  PatternPiece back(
    TrouserShapedWaistbandGeometry geometry, {
    int sizeCode = 14,
  }) =>
      _piece(
        id: 'trouser_shaped_waistband_back',
        name: 'Geformter Bund hinten',
        section: geometry.back,
        sizeCode: sizeCode,
      );

  PatternPiece _piece({
    required String id,
    required String name,
    required ShapedWaistbandPieceGeometry section,
    required int sizeCode,
  }) {
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

    final outline = _closedOutline(section);
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
      labels: [
        PatternLabel(
          position: labelPosition,
          text: '$name - Größe $sizeCode',
        ),
      ],
    );
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

    // Close the side edge from the upper side point to the lower side point.
    final upperSide = section.upperSegments.last.end;
    final lowerSide = section.lowerSegments.last.last;
    segments.add(LineSegment(upperSide, lowerSide));

    // Lower edge must be traversed in reverse to make one closed contour:
    // side -> centre.
    for (var segmentIndex = section.lowerSegments.length - 1;
        segmentIndex >= 0;
        segmentIndex--) {
      final lower = section.lowerSegments[segmentIndex];
      for (var i = lower.length - 1; i > 0; i--) {
        segments.add(LineSegment(lower[i], lower[i - 1]));
      }
    }

    // Close the centre edge back to the start of the upper curve.
    final lowerCentre = section.lowerSegments.first.first;
    final upperCentre = section.upperSegments.first.start;
    segments.add(LineSegment(lowerCentre, upperCentre));

    return PatternPath(List.unmodifiable(segments));
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
