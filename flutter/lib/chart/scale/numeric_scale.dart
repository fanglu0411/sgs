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

import 'numeric_extents.dart' show NumericExtents;
import 'scale.dart' show MutableScale, ScaleOutputExtent;

/// Scale used to convert numeric domain input units to output range units.
///
/// The input represents a continuous numeric domain which maps to a given range
/// output.  This is used to map the domain's values to the available pixel
/// range of the chart.
abstract class NumericScale<T extends num> extends MutableScale<T> {
  late NumericExtents _domainExtent;

  late ScaleOutputExtent _rangeExtent;

  NumericExtents get domain => NumericExtents(_domainExtent.min, _domainExtent.max);

  set domain(NumericExtents domain) {
    _domainExtent = domain;
  }

  @override
  set range(ScaleOutputExtent range) {
    _rangeExtent = range;
  }

  @override
  ScaleOutputExtent get range => ScaleOutputExtent(_rangeExtent.start, _rangeExtent.end);
}