import 'dart:math' as math;

import 'pattern_models.dart';
import 'trouser_pattern_calculator.dart';

/// One Aldrich trouser dart described by its centre on the waistline,
/// two waistline legs and its apex.
class TrouserDart {
  final PatternPoint center;
  final PatternPoint leg1;
  final PatternPoint leg2;
  final PatternPoint apex;

  const TrouserDart({
    required this.center,
    required this.leg1,
    required this.leg2,
    required this.apex,
  });
}

/// Exact dart construction from Aldrich 5th ed., p.100.
class TrouserDartGeometry {
  const TrouserDartGeometry();

  /// Front: dart on the line from P0, width 2 cm, length 10 cm.
  TrouserDart front(TrouserReferenceDraft d) => _dart(
        center: d[0],
        waistStart: d[10],
        waistEnd: d[11],
        width: 2.0,
        length: 10.0,
      );

  /// Back: P30, perpendicular to P21-P22, width 2 cm, length 12 cm.
  TrouserDart back30(TrouserReferenceDraft d) => _dart(
        center: d[30],
        waistStart: d[21],
        waistEnd: d[22],
        width: 2.0,
        length: 12.0,
      );

  /// Back: P31, perpendicular to P21-P22, width 2 cm, length 10 cm.
  TrouserDart back31(TrouserReferenceDraft d) => _dart(
        center: d[31],
        waistStart: d[21],
        waistEnd: d[22],
        width: 2.0,
        length: 10.0,
      );

  TrouserDart _dart({
    required PatternPoint center,
    required PatternPoint waistStart,
    required PatternPoint waistEnd,
    required double width,
    required double length,
  }) {
    final dx = waistEnd.x - waistStart.x;
    final dy = waistEnd.y - waistStart.y;
    final waistLength = math.sqrt(dx * dx + dy * dy);
    final ux = dx / waistLength;
    final uy = dy / waistLength;

    final halfWidth = width / 2.0;
    final leg1 = PatternPoint(
      center.x - ux * halfWidth,
      center.y - uy * halfWidth,
    );
    final leg2 = PatternPoint(
      center.x + ux * halfWidth,
      center.y + uy * halfWidth,
    );

    // Choose the perpendicular that points down into the pattern (positive y).
    var nx = -uy;
    var ny = ux;
    if (ny < 0.0) {
      nx = -nx;
      ny = -ny;
    }
    final apex = PatternPoint(
      center.x + nx * length,
      center.y + ny * length,
    );

    return TrouserDart(center: center, leg1: leg1, leg2: leg2, apex: apex);
  }
}
