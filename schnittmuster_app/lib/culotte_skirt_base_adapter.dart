import 'pattern_models.dart';

/// Minimal Straight-Skirt basis reused by Culotte v1.
///
/// Only the already confirmed base points are exposed here. Rock-specific
/// darts, labels, notches, seam allowance and waistband data are deliberately
/// not carried into the Culotte model.
class CulotteSkirtBase {
  final PatternPoint backCenterWaist; // Rock P1
  final PatternPoint frontCenterWaist; // Rock P2
  final PatternPoint backCenterHip; // Rock P5
  final PatternPoint frontCenterHip; // Rock P6
  final PatternPoint sideHip; // Rock P7
  final PatternPoint backCenterHem; // Rock P3
  final PatternPoint frontCenterHem; // Rock P4
  final PatternPoint sideHem; // Rock P8

  const CulotteSkirtBase({
    required this.backCenterWaist,
    required this.frontCenterWaist,
    required this.backCenterHip,
    required this.frontCenterHip,
    required this.sideHip,
    required this.backCenterHem,
    required this.frontCenterHem,
    required this.sideHem,
  });
}

class CulotteSkirtBaseAdapter {
  const CulotteSkirtBaseAdapter();

  CulotteSkirtBase fromPatternPieces({
    required PatternPiece back,
    required PatternPiece front,
  }) {
    PatternPoint requirePoint(
      PatternPiece piece,
      String key,
      String pieceName,
    ) {
      final point = piece.points[key];
      if (point == null) {
        throw StateError('$pieceName: erforderlicher Grundpunkt $key fehlt.');
      }
      return point;
    }

    return CulotteSkirtBase(
      backCenterWaist: requirePoint(back, 'P1', 'Rock-Rueckenteil'),
      frontCenterWaist: requirePoint(front, 'P2', 'Rock-Vorderteil'),
      backCenterHip: requirePoint(back, 'P5', 'Rock-Rueckenteil'),
      frontCenterHip: requirePoint(front, 'P6', 'Rock-Vorderteil'),
      sideHip: requirePoint(back, 'P7', 'Rock-Rueckenteil'),
      backCenterHem: requirePoint(back, 'P3', 'Rock-Rueckenteil'),
      frontCenterHem: requirePoint(front, 'P4', 'Rock-Vorderteil'),
      sideHem: requirePoint(back, 'P8', 'Rock-Rueckenteil'),
    );
  }
}
