import 'dart:math' as math show max, min;

abstract class Scale<D> {
  D scale(num x) => this[x];

  D operator [](num domainValue);

  D reverse(double pixelLocation);

  bool canTranslate(D domainValue);

  ScaleOutputExtent get range;

  int get rangeWidth;

  double get rangeBand;

  double get stepSize;

  /// Returns the stepSize domain value.
  double get domainStepSize;

  /// Returns true if the given [rangeValue] point is within the output range.
  ///
  /// Not to be confused with the start and end of the domain.
  bool isRangeValueWithinViewport(double rangeValue);

  /// Returns the current viewport scale.
  ///
  /// A scale of 1.0 would map the data directly to the output range, while a
  /// value of 2.0 would map the data to an output of double the range so you
  /// only see half the data in the viewport.  This is the equivalent to
  /// zooming.  Its value is likely >= 1.0.
  double get viewportScalingFactor;

  /// Returns the current pixel viewport offset
  ///
  /// The translate is used by the scale function when it applies the scale.
  /// This is the equivalent to panning.  Its value is likely <= 0 to pan the
  /// data to the left.
  double get viewportTranslatePx;

  /// Returns a mutable copy of the scale.
  ///
  /// Mutating the returned scale will not effect the original one.
  MutableScale<D> copy();
}

/// Mutable extension of the [Scale] definition.
///
/// Used for converting data from the dataset to some range (likely pixel range)
/// of the area to draw on.
///
/// [D] the domain class type for the values passed in.
abstract class MutableScale<D> extends Scale<D> {
  /// Reset the domain for this [Scale].
  void resetDomain();

  /// Reset the viewport settings for this [Scale].
  void resetViewportSettings();

  /// Sets the output range to use for the scale's conversion.
  ///
  /// The range start is mapped to the domain's min and the range end is
  /// mapped to the domain's max for the conversion using the domain nicing
  /// function.
  ///
  /// [extent] is the extent of the range which will likely be the pixel
  /// range of the drawing area to convert to.
  set range(ScaleOutputExtent extent);

  ScaleOutputExtent get range;

  /// Configures the zoom and translate.
  ///
  /// [viewportScale] is the zoom factor to use, likely >= 1.0 where 1.0 maps
  /// the complete data extents to the output range, and 2.0 only maps half the
  /// data to the output range.
  ///
  /// [viewportTranslatePx] is the translate/pan to use in pixel units,
  /// likely <= 0 which shifts the start of the data before the edge of the
  /// chart giving us a pan.
  void setViewportSettings(double viewportScale, double viewportTranslatePx);
}

/// Tuple of the output for a scale in pixels from [start] to [end] inclusive.
///
/// It is different from [Extent] because it focuses on start and end and not
/// min and max, meaning that start could be greater or less than end.
class ScaleOutputExtent {
  final num start;
  final num end;

  const ScaleOutputExtent(this.start, this.end);

  num get min => math.min(start, end);

  num get max => math.max(start, end);

  bool containsValue(double value) => value >= min && value <= max;

  /// Returns the difference between the extents.
  ///
  /// If the [end] is less than the [start] (think vertical measure axis), then
  /// this will correctly return a negative value.
  num get diff => end - start;

  /// Returns the width of the extent.
  num get width => diff.abs();

  @override
  bool operator ==(other) => other is ScaleOutputExtent && start == other.start && end == other.end;

  @override
  int get hashCode => start.hashCode + (end.hashCode * 31);

  @override
  String toString() => "ScaleOutputRange($start, $end)";
}

abstract class Extents<D> {}