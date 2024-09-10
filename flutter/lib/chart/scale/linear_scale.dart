// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


import './numeric_extents.dart' show NumericExtents;
import './numeric_scale.dart' show NumericScale;
import './scale.dart' show ScaleOutputExtent;

/// [NumericScale] that lays out the domain linearly across the range.
///
/// A [Scale] which converts numeric domain units to a given numeric range units
/// linearly (as opposed to other methods like log scales).  This is used to map
/// the domain's values to the available pixel range of the chart using the
/// apply method.
///
/// <p>The domain extent of the scale are determined by adding all domain
/// values to the scale.  It can, however, be overwritten by calling
/// [domainOverride] to define the extent of the data.
///
/// <p>The scale can be zoomed & panned by calling either [setViewportSettings]
/// with a zoom and translate, or by setting [viewportExtent] with the domain
/// extent to show in the output range.
///
/// <p>[rangeBandConfig]: By default, this scale will map the domain extent
/// exactly to the output range in a simple ratio mapping.  If a
/// [RangeBandConfig] other than NONE is used to define the width of bar groups,
/// then the scale calculation may be altered to that there is a half a stepSize
/// at the start and end of the range to ensure that a bar group can be shown
/// and centered on the scale's result.
///
/// <p>[stepSizeConfig]: By default, this scale will calculate the stepSize as
/// being auto detected using the minimal distance between two consecutive
/// datum.  If you don't assign a [RangeBandConfig], then changing the
/// [stepSizeConfig] is a no-op.
class LinearScale<T extends num> extends NumericScale<T> {
  late double _scale;

  LinearScale({required NumericExtents domain, required ScaleOutputExtent range}) {
    this.range = range;
    this.domain = domain;
    _scale = domain.width == 0 ? 0 : range.width / domain.width;
  }

  LinearScale._copy(LinearScale other);

  @override
  LinearScale<T> copy() => new LinearScale._copy(this);

  @override
  String toString() {
    return 'LinearScale{range: $range, domain: $domain}';
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is LinearScale && runtimeType == other.runtimeType && other.domain == this.domain && other.range == this.range;

  @override
  int get hashCode => this.domain.hashCode + this.range.hashCode;

  @override
  T operator [](num domainValue) {
    // var compare = domain.compareValue(domainValue);
    // if (compare == 0) {
    //   return ((domainValue - domain.min) / domain.width * range.width) + range.start;
    // } else if (compare == -1) {
    //   return range.start - (domain.min - domainValue) / domain.width * range.width;
    // } else // if(compare == 1)
    // {
    //   return (domainValue - domain.max) / domain.width * range.width + range.end;
    // }
    return ((domainValue - domain.min) * _scale + range.start) as T;
  }

  double get domainPerRange => domain.width / rangeWidth;

  double get rangePerDomain => rangeWidth / domain.width;

  @override
  T reverse(double viewPixels) {
    final num _domain = (viewPixels - range.start) / range.width * domain.width + domain.min;
    return _domain as T;
  }

  @override
  double get rangeBand {
    return 20;
  }

  @override
  double get stepSize {
    return 10;
  }

  @override
  int get rangeWidth => (range.end - range.start).abs().toInt();

  @override
  bool canTranslate(num domainValue) {
    return true;
  }

  @override
  double get domainStepSize => 10;

  @override
  bool isRangeValueWithinViewport(double rangeValue) {
    throw UnimplementedError();
  }

  @override
  void resetDomain() {}

  @override
  void resetViewportSettings() {}

  @override
  void setViewportSettings(double viewportScale, double viewportTranslatePx) {}

  @override
  double get viewportScalingFactor => 1.0;

  @override
  double get viewportTranslatePx => .0;
}
