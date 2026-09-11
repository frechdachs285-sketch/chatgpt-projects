import 'pattern_models.dart';

/// Confirmed Aldrich tailored-skirt basis reused by Culotte v1.
///
/// Only the source-confirmed construction points P1-P18 are exposed here.
/// Rock-specific labels, notches, seam allowance, waistband and other app
/// extras are deliberately not carried into the Culotte model.
class CulotteSkirtBase {
  final PatternPoint p1;
  final PatternPoint p2;
  final PatternPoint p3;
  final PatternPoint p4;
  final PatternPoint p5;
  final PatternPoint p6;
  final PatternPoint p7;
  final PatternPoint p8;
  final PatternPoint p9;
  final PatternPoint p10;
  final PatternPoint p11;
  final PatternPoint p12;
  final PatternPoint p13;
  final PatternPoint p14;
  final PatternPoint p15;
  final PatternPoint p16;
  final PatternPoint p17;
  final PatternPoint p18;

  const CulotteSkirtBase({
    required this.p1,
    required this.p2,
    required this.p3,
    required this.p4,
    required this.p5,
    required this.p6,
    required this.p7,
    required this.p8,
    required this.p9,
    required this.p10,
    required this.p11,
    required this.p12,
    required this.p13,
    required this.p14,
    required this.p15,
    required this.p16,
    required this.p17,
    required this.p18,
  });

  PatternPoint get backCenterWaist => p1;
  PatternPoint get frontCenterWaist => p2;
  PatternPoint get backCenterHem => p3;
  PatternPoint get frontCenterHem => p4;
  PatternPoint get backCenterHip => p5;
  PatternPoint get frontCenterHip => p6;
  PatternPoint get sideHip => p7;
  PatternPoint get sideHem => p8;
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
      p1: requirePoint(back, 'P1', 'Rock-Rueckenteil'),
      p2: requirePoint(front, 'P2', 'Rock-Vorderteil'),
      p3: requirePoint(back, 'P3', 'Rock-Rueckenteil'),
      p4: requirePoint(front, 'P4', 'Rock-Vorderteil'),
      p5: requirePoint(back, 'P5', 'Rock-Rueckenteil'),
      p6: requirePoint(front, 'P6', 'Rock-Vorderteil'),
      p7: requirePoint(back, 'P7', 'Rock-Rueckenteil'),
      p8: requirePoint(back, 'P8', 'Rock-Rueckenteil'),
      p9: requirePoint(back, 'P9', 'Rock-Rueckenteil'),
      p10: requirePoint(back, 'P10', 'Rock-Rueckenteil'),
      p11: requirePoint(back, 'P11', 'Rock-Rueckenteil'),
      p12: requirePoint(back, 'P12', 'Rock-Rueckenteil'),
      p13: requirePoint(back, 'P13', 'Rock-Rueckenteil'),
      p14: requirePoint(back, 'P14', 'Rock-Rueckenteil'),
      p15: requirePoint(front, 'P15', 'Rock-Vorderteil'),
      p16: requirePoint(front, 'P16', 'Rock-Vorderteil'),
      p17: requirePoint(front, 'P17', 'Rock-Vorderteil'),
      p18: requirePoint(front, 'P18', 'Rock-Vorderteil'),
    );
  }
}
