import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/pattern_models.dart';
import 'package:schnittmuster_app/trouser_pattern_calculator.dart';
import 'package:schnittmuster_app/trouser_pattern_piece_builder.dart';
import 'package:schnittmuster_app/trouser_seam_allowance.dart';

void main() {
  const measurements = TrouserMeasurements(
    waist: 76.0,
    hip: 100.0,
    hipDepth: 20.9,
    bodyRise: 28.7,
    waistToFloor: 105.0,
    trouserBottomWidth: 22.0,
  );
  const seamAllowance = TrouserSeamAllowanceSettings(
    enabled: true,
    normalCm: 1.5,
    waistCm: 1.0,
    hemCm: 3.0,
  );

  test('diagnoses theoretical versus geometry-occupied trouser PDF tiles', () {
    final draft = TrouserPatternCalculator.calculateReferencePoints(
      measurements,
      sizeCode: 14,
    );
    const builder = TrouserPatternPieceBuilder();
    final pieces = <PatternPiece>[
      builder.leftFront(draft, seamAllowance: seamAllowance, sizeCode: 14),
      builder.rightFront(draft, seamAllowance: seamAllowance, sizeCode: 14),
      builder.back(draft, seamAllowance: seamAllowance, sizeCode: 14),
    ];

    var theoreticalTotal = 0;
    var occupiedTotal = 0;
    for (final piece in pieces) {
      final result = _diagnosePiece(piece);
      theoreticalTotal += result.theoretical;
      occupiedTotal += result.occupied;
      // ignore: avoid_print
      print(
        '${piece.id}: theoretical=${result.theoretical}, '
        'geometryOccupied=${result.occupied}, '
        'avoidable=${result.theoretical - result.occupied}',
      );
      expect(result.occupied, lessThanOrEqualTo(result.theoretical));
      expect(result.occupied, greaterThan(0));
    }

    // This is deliberately diagnostic only. It establishes the measurable
    // upper bound for a Rock-v1-style tile filter without changing production
    // PDF code or asserting an unverified target page count.
    // ignore: avoid_print
    print(
      'Trouser garment tiles: theoretical=$theoreticalTotal, '
      'geometryOccupied=$occupiedTotal, '
      'potentiallyAvoidable=${theoreticalTotal - occupiedTotal}',
    );
  });
}

const _tileWidthMm = 190.0;
const _tileHeightMm = 240.0;
const _tileOverlapMm = 10.0;
const _piecePaddingMm = 15.0;

_TileDiagnostic _diagnosePiece(PatternPiece piece) {
  final bounds = _pieceBoundsLikeExporter(piece);
  final pieceWidthMm = bounds.width * 10.0;
  final pieceHeightMm = bounds.height * 10.0;
  final canvasWidthMm = pieceWidthMm + 2 * _piecePaddingMm;
  final canvasHeightMm = pieceHeightMm + 2 * _piecePaddingMm;
  final originX = _piecePaddingMm - bounds.minX * 10.0;
  final originY = _piecePaddingMm - bounds.minY * 10.0;
  final stepX = _tileWidthMm - _tileOverlapMm;
  final stepY = _tileHeightMm - _tileOverlapMm;
  final cols = math.max(1, ((canvasWidthMm - _tileWidthMm) / stepX).ceil() + 1);
  final rows = math.max(1, ((canvasHeightMm - _tileHeightMm) / stepY).ceil() + 1);

  final geometryBoxes = <_Bounds>[];
  void addPath(PatternPath path) {
    for (final segment in path.segments) {
      final points = <PatternPoint>[
        segment.start,
        segment.end,
        if (segment is BezierSegment) segment.control1,
        if (segment is BezierSegment) segment.control2,
      ];
      geometryBoxes.add(_boundsOf(points));
    }
  }

  addPath(piece.outline);
  if (piece.cuttingOutline != null) addPath(piece.cuttingOutline!);

  var occupied = 0;
  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      final tile = _Bounds(
        col * stepX,
        row * stepY,
        col * stepX + _tileWidthMm,
        row * stepY + _tileHeightMm,
      );
      final hit = geometryBoxes.any((boxCm) {
        final boxMm = _Bounds(
          originX + boxCm.minX * 10.0,
          originY + boxCm.minY * 10.0,
          originX + boxCm.maxX * 10.0,
          originY + boxCm.maxY * 10.0,
        );
        return _overlaps(tile, boxMm);
      });
      if (hit) occupied++;
    }
  }

  return _TileDiagnostic(rows * cols, occupied);
}

_Bounds _pieceBoundsLikeExporter(PatternPiece piece) {
  final points = <PatternPoint>[
    ...piece.points.values,
    for (final dart in piece.darts) ...[dart.leg1, dart.leg2, dart.apex],
    for (final segment in piece.outline.segments) ...[
      segment.start,
      segment.end,
      if (segment is BezierSegment) ...[segment.control1, segment.control2],
    ],
    if (piece.cuttingOutline != null)
      for (final segment in piece.cuttingOutline!.segments) ...[
        segment.start,
        segment.end,
        if (segment is BezierSegment) ...[segment.control1, segment.control2],
      ],
    for (final guide in piece.guideLines) ...[guide.start, guide.end],
    if (piece.grainline != null) ...[piece.grainline!.start, piece.grainline!.end],
    for (final label in piece.labels) label.position,
  ];
  return _boundsOf(points);
}

_Bounds _boundsOf(List<PatternPoint> points) {
  var minX = points.first.x;
  var maxX = points.first.x;
  var minY = points.first.y;
  var maxY = points.first.y;
  for (final point in points.skip(1)) {
    minX = math.min(minX, point.x);
    maxX = math.max(maxX, point.x);
    minY = math.min(minY, point.y);
    maxY = math.max(maxY, point.y);
  }
  return _Bounds(minX, minY, maxX, maxY);
}

bool _overlaps(_Bounds a, _Bounds b) =>
    a.minX < b.maxX && a.maxX > b.minX && a.minY < b.maxY && a.maxY > b.minY;

class _TileDiagnostic {
  final int theoretical;
  final int occupied;
  const _TileDiagnostic(this.theoretical, this.occupied);
}

class _Bounds {
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;
  const _Bounds(this.minX, this.minY, this.maxX, this.maxY);
  double get width => maxX - minX;
  double get height => maxY - minY;
}
