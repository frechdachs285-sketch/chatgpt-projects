import 'pattern_geometry.dart';
import 'pattern_models.dart';
import 'seam_allowance_geometry.dart';
import 'segmented_waist_curve.dart';
import 'trouser_dart_geometry.dart';
import 'trouser_pattern_calculator.dart';
import 'trouser_waist_length.dart';

/// Geometry for the below-waist shaped waistband extension.
///
/// Source rule: Aldrich 5th ed., p.98 - shaped waistbands are developed from
/// the garment waist area and the waist darts are closed to create the shape.
///
/// App-specific digital rule for this extension:
/// - [waistbandDepthCm] is freely selectable by the user.
/// - The lower waistband edge is constructed as a constant-distance normal
///   offset of the smooth, dart-closed waist curve.
///
/// The confirmed Hose-v1 straight waistband builder is intentionally not
/// modified by this class.
class TrouserShapedWaistbandBuilder {
  final TrouserDartGeometry dartGeometry;
  final TrouserWaistLengthCalculator waistLengths;
  final SegmentedWaistCurveSolver waistCurveSolver;

  const TrouserShapedWaistbandBuilder({
    this.dartGeometry = const TrouserDartGeometry(),
    this.waistLengths = const TrouserWaistLengthCalculator(),
    this.waistCurveSolver = const SegmentedWaistCurveSolver(),
  });

  TrouserShapedWaistbandGeometry build({
    required TrouserReferenceDraft draft,
    required double waistbandDepthCm,
  }) {
    if (!waistbandDepthCm.isFinite || waistbandDepthCm <= 0.0) {
      throw ArgumentError.value(
        waistbandDepthCm,
        'waistbandDepthCm',
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

    return TrouserShapedWaistbandGeometry(
      front: _buildPieceGeometry(
        closedWaist: frontClosed,
        waistbandDepthCm: waistbandDepthCm,
      ),
      back: _buildPieceGeometry(
        closedWaist: backClosed,
        waistbandDepthCm: waistbandDepthCm,
      ),
      waistbandDepthCm: waistbandDepthCm,
    );
  }

  ShapedWaistbandPieceGeometry _buildPieceGeometry({
    required SegmentedWaistCurveResult closedWaist,
    required double waistbandDepthCm,
  }) {
    final lowerSegments = <List<PatternPoint>>[];

    for (final upper in closedWaist.segments) {
      // Upper segments run from centre toward side. For the confirmed trouser
      // draft orientation, the positive left-hand normal of this direction
      // points toward the trouser body. The previous reversal selected the
      // opposite normal and was caught by the explicit P8/P25 direction test.
      final offset = SeamAllowanceGeometry.offsetBezierAdaptive(
        upper,
        waistbandDepthCm,
      );
      lowerSegments.add(offset);
    }

    return ShapedWaistbandPieceGeometry(
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

class TrouserShapedWaistbandGeometry {
  final ShapedWaistbandPieceGeometry front;
  final ShapedWaistbandPieceGeometry back;
  final double waistbandDepthCm;

  const TrouserShapedWaistbandGeometry({
    required this.front,
    required this.back,
    required this.waistbandDepthCm,
  });
}

class ShapedWaistbandPieceGeometry {
  final List<CubicBezierCurve> upperSegments;
  final List<List<PatternPoint>> lowerSegments;

  const ShapedWaistbandPieceGeometry({
    required this.upperSegments,
    required this.lowerSegments,
  });
}
