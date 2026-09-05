import 'dart:math' as math;

class PatternPoint {
  final double x;
  final double y;

  const PatternPoint(this.x, this.y);

  PatternPoint operator +(PatternPoint other) => PatternPoint(x + other.x, y + other.y);
  PatternPoint operator -(PatternPoint other) => PatternPoint(x - other.x, y - other.y);
  PatternPoint operator *(double factor) => PatternPoint(x * factor, y * factor);

  double distanceTo(PatternPoint other) {
    final dx = other.x - x;
    final dy = other.y - y;
    return math.sqrt(dx * dx + dy * dy);
  }
}

class Measurements {
  final double waist;
  final double hip;
  final double hipDepth;
  final double skirtLength;

  const Measurements({
    required this.waist,
    required this.hip,
    required this.hipDepth,
    required this.skirtLength,
  });
}

class ConstructionValues {
  final double waistEase;
  final double hipEase;
  final double sideWaistLift;
  final double backDart1Width;
  final double backDart1Length;
  final double backDart2Width;
  final double backDart2Length;
  final double frontDartWidth;
  final double frontDartLength;

  const ConstructionValues({
    this.waistEase = 1.0,
    this.hipEase = 3.0,
    this.sideWaistLift = 1.25,
    this.backDart1Width = 2.0,
    this.backDart1Length = 14.0,
    this.backDart2Width = 2.0,
    this.backDart2Length = 12.5,
    this.frontDartWidth = 2.0,
    this.frontDartLength = 10.0,
  });
}

class SeamAllowanceSettings {
  final bool enabled;
  final double waist;
  final double side;
  final double backCenter;
  final double frontCenter;
  final double hem;

  const SeamAllowanceSettings({
    this.enabled = true,
    this.waist = 1.5,
    this.side = 1.5,
    this.backCenter = 1.5,
    this.frontCenter = 0.0,
    this.hem = 3.0,
  });
}

class Dart {
  final PatternPoint center;
  final PatternPoint apex;
  final PatternPoint leg1;
  final PatternPoint leg2;
  final double width;
  final double length;

  const Dart({
    required this.center,
    required this.apex,
    required this.leg1,
    required this.leg2,
    required this.width,
    required this.length,
  });
}

class Grainline {
  final PatternPoint start;
  final PatternPoint end;

  const Grainline({required this.start, required this.end});
}

enum NotchType { single, double }

class PatternNotch {
  final PatternPoint position;
  final NotchType type;
  final String role;

  const PatternNotch({
    required this.position,
    this.type = NotchType.single,
    required this.role,
  });
}

class PatternLabel {
  final PatternPoint position;
  final String text;

  const PatternLabel({required this.position, required this.text});
}

sealed class PathSegment {
  PatternPoint get start;
  PatternPoint get end;
}

class LineSegment extends PathSegment {
  @override
  final PatternPoint start;
  @override
  final PatternPoint end;

  LineSegment(this.start, this.end);
}

class CurveSegment extends PathSegment {
  @override
  final PatternPoint start;
  @override
  final PatternPoint end;
  final String role;

  CurveSegment({required this.start, required this.end, required this.role});
}

class BezierSegment extends PathSegment {
  @override
  final PatternPoint start;
  final PatternPoint control1;
  final PatternPoint control2;
  @override
  final PatternPoint end;
  final String role;

  BezierSegment({
    required this.start,
    required this.control1,
    required this.control2,
    required this.end,
    required this.role,
  });
}

class PatternPath {
  final List<PathSegment> segments;
  const PatternPath(this.segments);
}

class PatternPiece {
  final String id;
  final String name;
  final Map<String, PatternPoint> points;
  final PatternPath outline;
  final PatternPath? cuttingOutline;
  final List<Dart> darts;
  final Grainline? grainline;
  final List<PatternNotch> notches;
  final List<PatternLabel> labels;

  const PatternPiece({
    required this.id,
    required this.name,
    required this.points,
    required this.outline,
    this.cuttingOutline,
    this.darts = const [],
    this.grainline,
    this.notches = const [],
    this.labels = const [],
  });
}

class PatternResult {
  final PatternPiece? front;
  final PatternPiece? back;
  final List<String> errors;
  final List<String> warnings;

  const PatternResult({
    this.front,
    this.back,
    this.errors = const [],
    this.warnings = const [],
  });

  bool get isValid => errors.isEmpty && front != null && back != null;
}
