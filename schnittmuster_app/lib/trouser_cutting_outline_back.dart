import 'pattern_models.dart';
import 'trouser_cutting_outline_builder.dart';
import 'trouser_cutting_outline_p21_transition.dart';
import 'trouser_cutting_outline_p22_transition.dart';
import 'trouser_pattern_calculator.dart';
import 'trouser_seam_allowance.dart';

extension TrouserBackCuttingOutline on TrouserCuttingOutlineBuilder {
  /// Builds the complete back cutting outline from the already confirmed
  /// Hose-v1 seam contour and transition rules. The accepted adaptive offset
  /// samples are preserved as a polyline; no Bezier refit or new construction
  /// value is introduced.
  PatternPath buildBackCuttingOutline({
    required PatternPath outline,
    required TrouserReferenceDraft draft,
    required TrouserSeamAllowanceSettings settings,
  }) {
    if (!settings.enabled) {
      throw ArgumentError('Hose-v1 seam allowance is disabled.');
    }

    final parts = prepareOffsetParts(
      outline,
      settings: settings,
      frontP10: draft[10],
      frontP11: draft[11],
      backP21: draft[21],
      backP22: draft[22],
    );
    if (parts.length < 6) {
      throw StateError('Back cutting outline does not contain enough parts.');
    }

    final hemIndex = _backRoleIndex(parts, 'back_hem');
    final inseamIndex = _backRoleIndex(parts, 'back_inseam');
    final firstCrotchIndex = _backRoleIndex(parts, 'back_crotch');
    final lastCrotchIndex = _backLastRoleIndex(parts, 'back_crotch');
    final waistIndex = parts.length - 1;

    if (hemIndex <= 0 ||
        hemIndex + 2 != inseamIndex ||
        inseamIndex + 1 != firstCrotchIndex ||
        lastCrotchIndex + 1 != waistIndex) {
      throw StateError('Unexpected confirmed back contour order.');
    }

    final joins = <PatternPoint>[];
    for (var i = 0; i < parts.length; i++) {
      final next = (i + 1) % parts.length;
      if (i == hemIndex - 1) {
        joins.add(sideHemTransition(parts[i], parts[next]));
      } else if (i == hemIndex) {
        joins.add(hemLowerInseamTransition(parts[i], parts[next]));
      } else if (i == hemIndex + 1) {
        joins.add(lowerUpperInseamTransition(parts[i], parts[next]));
      } else if (i == inseamIndex) {
        joins.add(upperInseamCrotchTransition(parts[i], parts[next]));
      } else if (i == lastCrotchIndex) {
        joins.add(backP21Transition(parts[i], parts[next]));
      } else if (i == waistIndex) {
        joins.add(backP22Transition(parts[i], parts[next]));
      } else {
        joins.add(_backExactSharedOffsetEndpoint(parts[i], parts[next]));
      }
    }

    final closedPoints = <PatternPoint>[];
    for (var i = 0; i < parts.length; i++) {
      final start = joins[(i - 1 + parts.length) % parts.length];
      final end = joins[i];
      final trimmed = _backTrimOffsetPart(parts[i].points, start, end);
      if (closedPoints.isEmpty) {
        closedPoints.addAll(trimmed);
      } else {
        _backAppendWithoutDuplicate(closedPoints, trimmed);
      }
    }

    if (closedPoints.last.distanceTo(closedPoints.first) > 1e-9) {
      closedPoints.add(closedPoints.first);
    } else {
      closedPoints[closedPoints.length - 1] = closedPoints.first;
    }

    return PatternPath([
      for (var i = 1; i < closedPoints.length; i++)
        LineSegment(closedPoints[i - 1], closedPoints[i]),
    ]);
  }
}

int _backRoleIndex(List<TrouserOffsetPart> parts, String role) {
  final index = parts.indexWhere(
    (part) => part.source is BezierSegment &&
        (part.source as BezierSegment).role == role,
  );
  if (index < 0) throw StateError('Missing $role offset part.');
  return index;
}

int _backLastRoleIndex(List<TrouserOffsetPart> parts, String role) {
  for (var i = parts.length - 1; i >= 0; i--) {
    final source = parts[i].source;
    if (source is BezierSegment && source.role == role) return i;
  }
  throw StateError('Missing $role offset part.');
}

PatternPoint _backExactSharedOffsetEndpoint(
  TrouserOffsetPart first,
  TrouserOffsetPart second,
) {
  if ((first.allowanceCm - second.allowanceCm).abs() > 1e-12) {
    throw StateError('Unclassified seam-allowance transition.');
  }
  final a = first.points.last;
  final b = second.points.first;
  if (a.distanceTo(b) > 1e-8) {
    throw StateError('Tangential offset parts do not meet exactly.');
  }
  return a;
}

List<PatternPoint> _backTrimOffsetPart(
  List<PatternPoint> points,
  PatternPoint start,
  PatternPoint end,
) {
  if (points.length < 2) {
    throw StateError('Offset part must contain at least two points.');
  }

  final startLocation = _backLocateOnPolyline(points, start);
  final endLocation = _backLocateOnPolyline(points, end);
  if (startLocation != null &&
      endLocation != null &&
      startLocation.position > endLocation.position + 1e-9) {
    throw StateError('Offset joins occur in reversed order.');
  }

  final result = <PatternPoint>[start];
  final firstInterior = startLocation == null ? 0 : startLocation.segment + 1;
  final lastInterior = endLocation == null ? points.length - 1 : endLocation.segment;

  for (var i = firstInterior; i <= lastInterior && i < points.length; i++) {
    if (result.last.distanceTo(points[i]) > 1e-9) result.add(points[i]);
  }
  if (result.last.distanceTo(end) > 1e-9) {
    result.add(end);
  } else {
    result[result.length - 1] = end;
  }
  return result;
}

void _backAppendWithoutDuplicate(
  List<PatternPoint> target,
  List<PatternPoint> source,
) {
  var start = 0;
  if (target.last.distanceTo(source.first) <= 1e-9) start = 1;
  for (var i = start; i < source.length; i++) {
    target.add(source[i]);
  }
}

_BackPolylineLocation? _backLocateOnPolyline(
  List<PatternPoint> points,
  PatternPoint point,
) {
  const epsilon = 1e-8;
  for (var i = 0; i < points.length - 1; i++) {
    final a = points[i];
    final b = points[i + 1];
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    final lengthSquared = dx * dx + dy * dy;
    if (lengthSquared <= 1e-24) continue;
    final t = ((point.x - a.x) * dx + (point.y - a.y) * dy) /
        lengthSquared;
    if (t < -epsilon || t > 1.0 + epsilon) continue;
    final clamped = t.clamp(0.0, 1.0).toDouble();
    final projected = PatternPoint(a.x + clamped * dx, a.y + clamped * dy);
    if (projected.distanceTo(point) <= epsilon) {
      return _BackPolylineLocation(i, clamped);
    }
  }
  return null;
}

class _BackPolylineLocation {
  final int segment;
  final double t;
  const _BackPolylineLocation(this.segment, this.t);

  double get position => segment + t;
}
