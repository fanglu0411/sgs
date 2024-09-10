import 'dart:math';

import 'package:d4_scale/d4_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/chart/scale/value_sale_type.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

import '../common.dart';

List<HicBin> createHicBins(
  HicMatrix hicMatrix,
  Range visibleRange,
) {
  List<HicBin> bins = [];

  Map<int, Range> blocksMap = {};
  double _start = visibleRange.start;
  do {
    int index = (_start / hicMatrix.binSize).floor();
    double __start = index * hicMatrix.binSize;
    blocksMap[index] = Range(start: __start, end: __start + hicMatrix.binSize);
    _start += hicMatrix.binSize;
  } while (_start < visibleRange.end);
  List<int> idxList = blocksMap.keys.toList();

  for (int i = 0; i < idxList.length; i++) {
    for (int j = i; j < idxList.length; j++) {
      num value = hicMatrix.getValue(i, j);
      if (value == 0) continue;
      bins.add(HicBin(
        value: value,
        index1: i,
        index2: j,
        range1: blocksMap[idxList[i]]!,
        range2: blocksMap[idxList[j]]!,
      ));
    }
  }
  return bins;
}

class HicMatrix {
  // List<num> idx1;
  // List<num> idx2;
  // List<num> values;

  double binSize;

  num maxValue = 0;

  Map<String, num> _matrixMap = {};

  void setDataSource(List? sourceList) {
    if (sourceList != null && sourceList.length > 0) {
      _matrixMap.clear();
      List item;
      for (int i = 0; i < sourceList.length; i++) {
        item = sourceList[i];
        if (item[2] == 0) continue;
        _matrixMap['${item[0]}-${item[1]}'] = item[2];
        maxValue = max(maxValue, item[2]);
      }
    }
    print('matrix map length: ${_matrixMap.length}');
  }

  HicMatrix.fromList(List? sourceList, this.binSize) {
    setDataSource(sourceList);
  }

  num getValue(int idx1, int idx2) {
    String key = '${idx1}-${idx2}';
    // if (!_matrixMap.containsKey(key)) {
    //   _matrixMap[key] = Random().nextDouble();
    // }
    return _matrixMap[key] ?? 0;
  }

  bool get isEmpty => _matrixMap.isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is HicMatrix && runtimeType == other.runtimeType && binSize == other.binSize && maxValue == other.maxValue && _matrixMap == other._matrixMap;

  @override
  int get hashCode => binSize.hashCode ^ maxValue.hashCode ^ _matrixMap.hashCode;
}

class HicBin {
  Path? path;
  List<Offset>? points;
  num? value;

  double? color;

  int index1;
  int index2;

  Range range1;
  Range range2;
  bool visible;

  // Range pixRange1;
  // Range pixRange2;
  // Offset center;
  // Rect arcRect;
  Path? arcPath;

  HicBin({
    this.path,
    required this.value,
    this.color,
    required this.index1,
    required this.index2,
    required this.range1,
    required this.range2,
    this.visible = true,
  });
}

class HicData extends TrackData {
  HicMatrix matrix;
  List<HicBin> bins = [];

  List<String> binKeys = [];

  double? filterMaxValue;
  double? filterMinValue;

  num get maxValue => matrix.maxValue;

  int? idxStart;
  int? idxEnd;

  num? _rangeMaxValue;

  num? get rangeMaxValue => _rangeMaxValue;

  Scale<num, num>? _colorScale;

  HicData({
    required this.matrix,
    super.track,
    super.message = '',
  });

  bool Function(HicBin)? get valueFilterFunction {
    if (filterMaxValue != null && filterMinValue != null) {
      return _filterMixMax;
    }
    if (filterMaxValue != null) {
      return _filterMax;
    }
    if (filterMinValue != null) {
      return _filterMix;
    }
    return null;
  }

  List<HicBin> get visibleBins {
    bool Function(HicBin)? _valueFilterFunction = valueFilterFunction;
    if (null == _valueFilterFunction) return bins;
    return bins.where(_valueFilterFunction).toList();
  }

  bool _filterMax(HicBin b) {
    return b.value! <= filterMaxValue!;
  }

  bool _filterMix(HicBin b) {
    return b.value! >= filterMinValue!;
  }

  bool _filterMixMax(HicBin b) {
    return b.value! >= filterMinValue! && b.value! <= filterMaxValue!;
  }

  void setRange(Range visibleRange) {
    // print('range: ${visibleRange}, ${bins.length}, ${this.hashCode}');
    Map<int, Range> blocksMap = {};

    double _start = visibleRange.start;
    int index = (_start / matrix.binSize).floor();
    double __start = index * matrix.binSize;
    idxStart = index;

    while (__start < visibleRange.end) {
      blocksMap[index] = Range(start: __start, end: __start + matrix.binSize);
      index++;
      __start += matrix.binSize;
    }
    idxEnd = index;

    List<int> idxList = blocksMap.keys.toList();

    bins.clear();
    num? value;
    num rangeMin = 1, rangeMax = 0;
    // _colorScale = scaleLogFixed(domain: [0, maxValue], range: [.025, 1]);
    String key;
    for (int i = 0; i < idxList.length; i++) {
      for (int j = i; j < idxList.length; j++) {
        // key = '${idxList[i]}-${idxList[j]}';
        // if (binKeys.contains(key)) continue;
        // binKeys.add(key);
        value = matrix.getValue(idxList[i], idxList[j]);
        if (value == 0) continue;
        if (value > rangeMax) rangeMax = value;
        if (value < rangeMin) rangeMin = value;
        bins.add(HicBin(
          value: value,
          // color: _colorScale!.scale(value) as double,
          index1: idxList[i],
          index2: idxList[j],
          range1: blocksMap[idxList[i]]!,
          range2: blocksMap[idxList[j]]!,
        ));
      }
    }
    _rangeMaxValue = rangeMax;

    var _vs = 1.0;
    while (_vs * rangeMin < 1) {
      _vs *= 10;
    }
    // _colorScale = scaleLogFixed(domain: [rangeMin, rangeMax], range: [10, 255]);
    _colorScale = scaleLogFixed(domain: [rangeMin * _vs, rangeMax * _vs], range: [0.01, 1.0], base: 10);
    // _colorScale = ScaleThreshold.number(domain: [rangeMin * _vs, rangeMax * _vs], range: [0.01, 1.0]);
    _colorScale = ScaleSymlog.number(domain: [rangeMin * _vs, rangeMax * _vs], range: [0.01, 1.0]);

    for (var bin in bins) {
      bin.color = _colorScale!.call(bin.value! * _vs)!.toDouble();
    }
    print('bin length: ${bins.length},${_colorScale!.domain}, min: ${rangeMin}, max: ${rangeMax}, vs: ${_vs}, maxx: ${maxValue}');
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is HicData && runtimeType == other.runtimeType && matrix == other.matrix && idxStart == other.idxStart && idxEnd == other.idxEnd;

  @override
  int get hashCode => matrix.hashCode ^ idxStart.hashCode ^ idxEnd.hashCode;

  @override
  bool get isEmpty => bins.length == 0;

  @override
  void clear() {}
}
