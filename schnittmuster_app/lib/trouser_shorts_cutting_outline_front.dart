import 'pattern_models.dart';
import 'trouser_cutting_outline_builder.dart';
import 'trouser_cutting_outline_p10_transition.dart';
import 'trouser_cutting_outline_p11_transition.dart';
import 'trouser_cutting_outline_p6_transition.dart';
import 'trouser_fly.dart';
import 'trouser_pattern_calculator.dart';
import 'trouser_seam_allowance.dart';

extension TrouserFrontShortsCuttingOutline on TrouserCuttingOutlineBuilder {
  /// Builds the front Tailored-Shorts cutting outline from the true closed
  /// shorts seam outline.
  ///
  /// The straight shorts hem is intentionally classified here as hem allowance
  /// because LineSegment has no role field in the shared pattern model.
  PatternPath buildFrontShortsCuttingOutline({
    required PatternPath outline,
    required TrouserReferenceDraft draft,
    required TrouserSeamAllowanceSettings settings,
    required double shortsDepthY,
    TrouserFlyGeometry? fly,
  }) {
    if (!settings.enabled) {
      throw ArgumentError('Hose-v1 seam allowance is disabled.');
    }
    if (!settings.isValid) {
      throw ArgumentError('Invalid Hose-v1 seam allowance settings.');
    }

    final parts = <TrouserOffsetPart>[];
    for (final segment in outline.segments) {
      final allowance = _frontShortsAllowance(
        segment,
        settings: settings,
        draft: draft,
        shortsDepthY: shortsDepthY,
        fly: fly,
      );
      parts.add(TrouserOffsetPart(
        source: segment,
        allowanceCm: allowance,
        points: offsetSegment(segment, distanceCm: allowance),
      ));
    }

    final hemIndex = parts.indexWhere((part) =>
        part.source is LineSegment &&
        (part.source.start.y - shortsDepthY).abs() <= 1e-8 &&
        (part.source.end.y - shortsDepthY).abs() <= 1e-8);
    final inseamIndex = _frontShortsRoleIndex(parts, 'front_inseam');
    final lowerInseamIndex =
        hemIndex >= 0 && hemIndex + 1 < inseamIndex ? hemIndex + 1 : null;
    final firstCrotchIndex = _frontShortsRoleIndex(parts, 'front_crotch');
    final lastCrotchIndex = _frontShortsLastRoleIndex(parts, 'front_crotch');
    final topIndex = parts.length - 2;
    final waistIndex = parts.length - 1;
    final flyLowerIndex = fly == null ? null : lastCrotchIndex + 1;
    final flyOuterIndex = fly == null ? null : lastCrotchIndex + 2;

    final expectedInseamIndex = hemIndex + (lowerInseamIndex == null ? 1 : 2);
    if (hemIndex <= 0 ||
        inseamIndex != expectedInseamIndex ||
        inseamIndex + 1 != firstCrotchIndex ||
        (lowerInseamIndex != null &&
            parts[lowerInseamIndex].source is! LineSegment) ||
        (fly == null && lastCrotchIndex + 1 != topIndex)) {
      throw StateError('Unexpected front Tailored-Shorts contour order.');
    }

    if (fly != null) {
      if (flyLowerIndex == null ||
          flyOuterIndex == null ||
          topIndex != lastCrotchIndex + 3) {
        throw StateError('Unexpected front Tailored-Shorts fly contour order.');
      }
    }

    final joins = <PatternPoint>[];
    for (var i = 0; i < parts.length; i++) {
      final next = (i + 1) % parts.length;
      if (i == hemIndex - 1) {
        joins.add(curveLineTransition(parts[i], parts[next]));
      } else if (i == hemIndex) {
        if (lowerInseamIndex == null) {
          joins.add(lineCurveTransition(parts[i], parts[next]));
        } else {
          joins.add(lineLineTransition(parts[i], parts[next]));
        }
      } else if (lowerInseamIndex != null && i == lowerInseamIndex) {
        joins.add(lowerUpperInseamTransition(parts[i], parts[next]));
      } else if (i == inseamIndex) {
        joins.add(upperInseamCrotchTransition(parts[i], parts[next]));
      } else if (i == lastCrotchIndex) {
        joins.add(frontCrotchTopTransition(parts[i], parts[next]));
      } else if (fly != null &&
          (i == flyLowerIndex || i == flyOuterIndex)) {
        joins.add(lineLineTransition(parts[i], parts[next]));
      } else if (i == topIndex) {
        joins.add(frontP10Transition(parts[i], parts[next]));
      } else if (i == waistIndex) {
        joins.add(frontP11Transition(parts[i], parts[next]));
      } else {
        joins.add(_frontShortsSharedOffsetEndpoint(parts[i], parts[next]));
      }
    }

    final closedPoints = <PatternPoint>[];
    for (var i = 0; i < parts.length; i++) {
      final start = joins[(i - 1 + parts.length) % parts.length];
      final end = joins[i];
      final trimmed = _frontShortsTrimOffsetPart(parts[i].points, start, end);
      if (closedPoints.isEmpty) {
        closedPoints.addAll(trimmed);
      } else {
        _frontShortsAppendWithoutDuplicate(closedPoints, trimmed);
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

double _frontShortsAllowance(
  PathSegment segment, {
  required TrouserSeamAllowanceSettings settings,
  required TrouserReferenceDraft draft,
  required double shortsDepthY,
  required TrouserFlyGeometry? fly,
}) {
  if (segment is LineSegment &&
      (segment.start.y - shortsDepthY).abs() <= 1e-8 &&
      (segment.end.y - shortsDepthY).abs() <= 1e-8) {
    return settings.hemCm;
  }

  if (segment is LineSegment) {
    final isBaseWaist = segment.start.distanceTo(draft[10]) <= 1e-9 &&
        segment.end.distanceTo(draft[11]) <= 1e-9;
    final isFlyTop = fly != null &&
        segment.start.distanceTo(fly.extensionWaist) <= 1e-9 &&
        segment.end.distanceTo(fly.waistCenterFront) <= 1e-9;
    if (isBaseWaist || isFlyTop) return settings.waistCm;
  }

  return settings.normalCm;
}

int _frontShortsRoleIndex(List<TrouserOffsetPart> parts, String role) {
  final index = parts.indexWhere((part) =>
      part.source is BezierSegment &&
      (part.source as BezierSegment).role == role);
  if (index < 0) throw StateError('Missing $role offset part.');
  return index;
}

int _frontShortsLastRoleIndex(List<TrouserOffsetPart> parts, String role) {
  for (var i = parts.length - 1; i >= 0; i--) {
    final source = parts[i].source;
    if (source is BezierSegment && source.role == role) return i;
  }
  throw StateError('Missing $role offset part.');
}

PatternPoint _frontShortsSharedOffsetEndpoint(
  TrouserOffsetPart first,
  TrouserOffsetPart second,
) {
  if ((first.allowanceCm - second.allowanceCm).abs() > 1e-12) {
    throw StateError('Unclassified Tailored-Shorts seam-allowance transition.');
  }
  final a = first.points.last;
  final b = second.points.first;
  if (a.distanceTo(b) > 1e-8) {
    throw StateError('Tailored-Shorts offset parts do not meet exactly.');
  }
  return a;
}

List<PatternPoint> _frontShortsTrimOffsetPart(
  List<PatternPoint> points,
  PatternPoint start,
  PatternPoint end,
) {
  if (points.length < 2) {
    throw StateError('Offset part must contain at least two points.');
  }

  final startLocation = _frontShortsLocateOnPolyline(points, start);
  final endLocation = _frontShortsLocateOnPolyline(points, end);
  if (startLocation != null &&
      endLocation != null &&
      startLocation.position > endLocation.position + 1e-9) {
    throw StateError('Tailored-Shorts offset joins occur in reversed order.');
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

void _frontShortsAppendWithoutDuplicate(
  List<PatternPoint> target,
  List<PatternPoint> source,
) {
  var start = 0;
  if (target.last.distanceTo(source.first) <= 1e-9) start = 1;
  for (var i = start; i < source.length; i++) {
    target.add(source[i]);
  }
}

_FrontShortsPolylineLocation? _frontShortsLocateOnPolyline(
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
      return _FrontShortsPolylineLocation(i, clamped);
    }
  }
  return null;
}

class _FrontShortsPolylineLocation {
  final int segment;
  final double t;
  const _FrontShortsPolylineLocation(this.segment, this.t);

  double get position => segment + t;
}
