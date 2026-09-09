import 'pattern_geometry.dart';
import 'pattern_models.dart';
import 'seam_allowance_geometry.dart';
import 'segmented_waist_curve.dart';
import 'trouser_dart_geometry.dart';
import 'trouser_pattern_calculator.dart';
import 'trouser_waist_length.dart';

/// Geometry for the facing used with the shaped trouser waistband extension.
///
/// Aldrich source rule (5th ed., p.98, "Faced waistbands"):
/// - trace the waist/hip area,
/// - draw the desired lower facing edge,
/// - close the darts,
/// - bring the side seams together,
/// - trace the resulting facing pattern;
/// - the facing may be cut in two sections.
///
/// App-specific digital rules for Hose-v1 extension:
/// - [facingDepthCm] is freely selectable by the user; Aldrich gives no fixed
///   centimetre value for this facing depth.
/// - The desired lower facing edge is represented as a constant-distance
///   normal offset of the smooth dart-closed waist curve.
/// - The app keeps front and back as two separate facing sections, which is
///   permitted by the source and avoids inventing an unconfirmed join layout.
class TrouserShapedWaistbandFacingBuilder {
  final TrouserDartGeometry dartGeometry;
  final TrouserWaistLengthCalculator waistLengths;
  final SegmentedWaistCurveSolver waistCurveSolver;

  const TrouserShapedWaistbandFacingBuilder({
    this.dartGeometry = const TrouserDartGeometry(),
    this.waistLengths = const TrouserWaistLengthCalculator(),
    this.waistCurveSolver = const SegmentedWaistCurveSolver(),
  });

  TrouserShapedWaistbandFacingGeometry build({
    required TrouserReferenceDraft draft,
    required double facingDepthCm,
  }) {
    if (!facingDepthCm.isFinite || facingDepthCm <= 0.0) {
      throw ArgumentError.value(
        facingDepthCm,
        'facingDepthCm',
        'must be finite and greater than 0',
      );
    }

    final lengths = waistLengths.calculate(draft);

    final frontDart = _asDart(dartGeometry.front(draft));
    final backDart30 = _asDart(dartGeometry.back30(draft));
    final backDart31 = _asDart(dartGeometry.back31(draft));

    final frontClosed = waistCurveSolver.solve(
      centerPoint: draft[10],
      sidePoint: draft[11],
      hipPoint: draft[8],
      dartsFromCenterToSide: [frontDart],
      targetLength: lengths.frontCm,
    );

    final backClosed = waistCurveSolver.solve(
      centerPoint: draft[21],
      sidePoint: draft[22],
      hipPoint: draft[25],
      dartsFromCenterToSide: [backDart30, backDart31],
      targetLength: lengths.backCm,
    );

    return TrouserShapedWaistbandFacingGeometry(
      front: _buildPieceGeometry(
        closedWaist: frontClosed,
        facingDepthCm: facingDepthCm,
      ),
      back: _buildPieceGeometry(
        closedWaist: backClosed,
        facingDepthCm: facingDepthCm,
      ),
      facingDepthCm: facingDepthCm,
    );
  }

  ShapedWaistbandFacingPieceGeometry _buildPieceGeometry({
    required SegmentedWaistCurveResult closedWaist,
    required double facingDepthCm,
  }) {
    final lowerSegments = <List<PatternPoint>>[];

    for (final upper in closedWaist.segments) {
      lowerSegments.add(
        SeamAllowanceGeometry.offsetBezierAdaptive(
          upper,
          facingDepthCm,
        ),
      );
    }

    return ShapedWaistbandFacingPieceGeometry(
      upperSegments: List.unmodifiable(closedWaist.segments),
      lowerSegments: List.unmodifiable(lowerSegments),
    );
  }

  Dart _asDart(TrouserDart dart) => Dart(
        center: dart.center,
        apex: dart.apex,
        leg1: dart.leg1,
        leg2: dart.leg2,
        width: dart.leg1.distanceTo(dart.leg2),
        length: dart.center.distanceTo(dart.apex),
      );
}

class TrouserShapedWaistbandFacingGeometry {
  final ShapedWaistbandFacingPieceGeometry front;
  final ShapedWaistbandFacingPieceGeometry back;
  final double facingDepthCm;

  const TrouserShapedWaistbandFacingGeometry({
    required this.front,
    required this.back,
    required this.facingDepthCm,
  });
}

class ShapedWaistbandFacingPieceGeometry {
  final List<CubicBezierCurve> upperSegments;
  final List<List<PatternPoint>> lowerSegments;

  const ShapedWaistbandFacingPieceGeometry({
    required this.upperSegments,
    required this.lowerSegments,
  });
}
