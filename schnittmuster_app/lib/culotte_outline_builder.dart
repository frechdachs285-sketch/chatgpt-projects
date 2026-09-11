import 'culotte_base_geometry.dart';
import 'culotte_curve_geometry.dart';
import 'pattern_models.dart';

/// Builds the Culotte v1 seam-line outlines from the confirmed tailored-skirt
/// basis and the Aldrich culotte step construction.
///
/// The existing skirt waist, darts and side seam are retained. Only the
/// original skirt hem-to-centre section is replaced by the culotte hem,
/// inner-leg line and step curve. No seam allowance is added here.
class CulotteOutlineBuilder {
  final CulotteCurveGeometry _curveGeometry;

  const CulotteOutlineBuilder({
    CulotteCurveGeometry curveGeometry = const CulotteCurveGeometry(),
  }) : _curveGeometry = curveGeometry;

  PatternPath buildBack({
    required PatternPiece skirtBack,
    required CulotteBaseGeometry geometry,
  }) {
    final p = geometry.points;
    final retained = _retainSkirtThroughSideHem(skirtBack.outline);
    final curve = _curveGeometry.backStepCurve(
      c3: p['C3']!,
      h3: p['H3']!,
      c4: p['C4']!,
    );

    return PatternPath([
      ...retained,
      LineSegment(geometry.skirtBase.sideHem, p['BACK_INNER_HEM']!),
      LineSegment(p['BACK_INNER_HEM']!, p['C4']!),
      ..._reverseSpline(curve.segments, 'culotte_back_step'),
      LineSegment(p['C3']!, p['C0']!),
    ]);
  }

  PatternPath buildFront({
    required PatternPiece skirtFront,
    required CulotteBaseGeometry geometry,
  }) {
    final p = geometry.points;
    final retained = _retainSkirtThroughSideHem(skirtFront.outline);
    final curve = _curveGeometry.frontStepCurve(
      c8: p['C8']!,
      h4: p['H4']!,
      c9: p['C9']!,
    );

    return PatternPath([
      ...retained,
      LineSegment(geometry.skirtBase.sideHem, p['FRONT_INNER_HEM']!),
      LineSegment(p['FRONT_INNER_HEM']!, p['C9']!),
      ..._reverseSpline(curve.segments, 'culotte_front_step'),
      LineSegment(p['C8']!, p['C5']!),
    ]);
  }

  List<PathSegment> _retainSkirtThroughSideHem(PatternPath outline) {
    if (outline.segments.length < 3) {
      throw StateError('Die Rock-Grundkontur ist unvollstaendig.');
    }
    // Rock v1 ends with sideHip->sideHem, sideHem->centreHem,
    // centreHem->centreWaist. Keep through sideHem and replace the last two.
    return List<PathSegment>.unmodifiable(
      outline.segments.take(outline.segments.length - 2),
    );
  }

  List<BezierSegment> _reverseSpline(
    List<dynamic> segments,
    String role,
  ) =>
      [
        for (final curve in segments.reversed)
          BezierSegment(
            start: curve.end,
            control1: curve.control2,
            control2: curve.control1,
            end: curve.start,
            role: role,
          ),
      ];
}
