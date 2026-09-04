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

class PatternPath {
  final List<PathSegment> segments;
  const PatternPath(this.segments);
}

class PatternPiece {
  final String id;
  final String name;
  final Map<String, PatternPoint> points;
  final PatternPath outline;
  final List<Dart> darts;

  const PatternPiece({
    required this.id,
    required this.name,
    required this.points,
    required this.outline,
    this.darts = const [],
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
