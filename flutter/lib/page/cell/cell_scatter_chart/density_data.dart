import 'package:flutter/material.dart';
import 'dart:math';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/chart/scale/vector_linear_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/chart/scale/vector_scale_ext.dart';

class DensityPlot {
  late Map<String, List> _sourceMap;
  late Rect viewRect;

  late int binCount;

  late Vector3LinearScale _scale;

  ///密度分组
  Map<String, List<List<DensityBin>>> densityMap = {};

  /// 每个分组密度最大的位置bin
  Map<String, DensityBin> maxMap = {};

  ///每个分组密度最大的位置rect
  Map<String, Rect>? _labelRect;

  Map<String, Rect>? get labelRect => _labelRect;

  late double _binSize;

  Scale<num, double> domainScale;

  double _xMapper(List list) {
    return list[1];
  }

  double _yMapper(List list) {
    return list[2];
  }

  double _xScaleMapper(List list) {
    return domainScale.scale(list[1])!;
  }

  double _yScaleMapper(List list) {
    return domainScale.scale(list[2])!;
  }

  DensityPlot(
    this._sourceMap, {
    required this.viewRect,
    required Vector3LinearScale valueScale,
    required this.domainScale,
    this.binCount = 50,
  }) {
    _scale = valueScale;

    _binSize = viewRect.width / binCount;
    _sourceMap.forEach((key, List list) {
      _densityPlot(key, list);
    });
    _labelRect = parseGroupRect();
  }

  setViewRect(Rect rect, Vector3LinearScale valueScale) {
    _scale = valueScale;
    viewRect = rect;
    _binSize = viewRect.width / binCount;
    _sourceMap.forEach((key, List list) {
      _densityPlot(key, list);
    });
    _labelRect = parseGroupRect();
  }

  ///
  /// calculate density of each group
  ///
  void _densityPlot(String group, List data) {
    var bins = List<List<DensityBin>>.generate(binCount, (row) => List<DensityBin>.generate(binCount, (col) => DensityBin(row: row, col: col)));
    DensityBin? maxBin = null;
    for (List item in data) {
      Offset point = _scale.scaleXY(_xScaleMapper(item), 65535 - _yScaleMapper(item));
      int col = min((point.dx / _binSize).floor(), binCount - 1);
      int row = min((point.dy / _binSize).floor(), binCount - 1);
      bins[row][col].value++;
      if (maxBin == null || bins[row][col].value > maxBin.value) {
        maxBin = bins[row][col];
      }
    }
    densityMap[group] = bins;
    maxMap[group] = maxBin!;
  }

  Map<String, Rect> parseGroupRect() {
    return maxMap.map<String, Rect>((key, bin) {
      return MapEntry(key, Rect.fromLTWH(bin.col * _binSize, bin.row * _binSize, _binSize, _binSize));
    });
  }
}

class DensityBin {
  int col, row;
  int value;

  DensityBin({required this.col, required this.row, this.value = 0});

  @override
  String toString() {
    return 'DensityBin{col: $col, row: $row, value: $value}';
  }
}
