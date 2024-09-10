import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/page/track/track_ui_config_bean.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/util/lru_cache.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'dart:math' show max;

import 'layout_base.dart';

class FeatureMatrix {
  late List<List<String?>> _matrix;
  late int rows;
  late int columns;

  FeatureMatrix.create({int row = 200, required int column}) {
    this.rows = row;
    this.columns = column;
    _matrix = List.generate(row, (r) => List.generate(column, (c) => null));
  }

  String? get(int row, int column) {
    return _matrix[row][column];
  }

  void set(int row, int column, String value) {
    _matrix[row][column] = value;
  }

  addRows(int rows) {
    List<List<String?>> newRows = List.generate(rows, (r) => List.generate(columns, (c) => null));
    _matrix.addAll(newRows);
  }

  List<String?> findRowRange(int row, int colStart, int colEnd) {
    return _matrix[row].sublist(colStart, colEnd + 1);
  }

  void findLocate(int colStart, int colEnd, String id) {
    int row = 0;
    List<String?> range;
    bool find = false;
    while (row < rows) {
      range = findRowRange(row, colStart, colEnd);
      if (range.every((e) => e == null)) {
        find == true;
        range.forEach((e) => e = id);
        break;
      }
      row++;
    }
    if (find) return;
    row++;
    addRows(200);
    range = findRowRange(row, colStart, colEnd);
    range.forEach((e) => e = id);
  }
}

class RowFeature {
  late int row;
  late List<BedFeature> features;

  RowFeature({required this.row}) {
    features = [];
  }

  add(BedFeature feature) {
    features.add(feature);
  }

  bool get isEmpty => features.isEmpty;

  bool get isNotEmpty => features.isNotEmpty;

  BedFeature? get last => features.length > 0 ? features.last : null;
}

class FastBedFeatureLayout extends TrackLayout {
  LruCache<String, BlockPosition> _blockCache = LruCache<String, BlockPosition>(10000);
  LruCache<int, Rect> _rowLastItemCache = LruCache<int, Rect>(10000);

  Map<int, RowFeature> _rowFeatures = {};

  Map<int, RowFeature> get rowFeatures => _rowFeatures;

  int maxRow = 0;

  FastBedFeatureLayout() {}

  clear() {
    int length = _blockCache.length;
    _blockCache.clear();
    _rowLastItemCache.clear();
    _rowFeatures.clear();
    maxHeight = 0;
    maxRow = 0;
    print('${this.runtimeType} clear => $length');
  }

  void calculate({
    required List<Feature> features,
    required double rowHeight,
    required double rowSpace,
    required Scale<num, num> scale,
    required Axis orientation,
    required TrackCollapseMode collapseMode,
    required bool showLabel,
    required double labelFontSize,
    required Range visibleRange,
    required bool showSubFeature,
    bool showChildrenLabel = false,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    if ((features.length) == 0) return;

    _rowLastItemCache.clear();
    _rowFeatures.clear();
    bool _horizontal = orientation == Axis.horizontal;
    //print('scale $scale visible range: $visibleRange');
    Feature feature;

//    print('-feature: ${_featureRowMap.keys}');

    features.sort((a, b) {
      // int _a = _featureBlockMap[a.id] ?? -1;
      // int _b = _featureBlockMap[b.id] ?? -1;
      // if (_a >= 0 && _b >= 0) return a.range.start - b.range.start;
      // if (_a >= 0) return -1;
      // if (_b >= 0) return 1;
      // if (a.range.intersection(b.range) != null) {
      //   return (b.range.size - a.range.size).toInt();
      // }

      return (a.range.start - b.range.start).toInt();
//      return _featureRowMap[a.id] == null ? 1 : -1;
    });
    // print(features.map((e) => e.id).toList().join('\n'));

    double _labelHeight = labelFontSize + 2;
    bool _showLabel = showLabel && showSubFeature;
    bool _showChildrenLabel = _showLabel && showChildrenLabel;
    rowSpace = _showChildrenLabel ? rowSpace : 6;
    double groupHeight = rowHeight;
    double featureHeight = rowHeight;

    if (_showLabel) {
      groupHeight = rowHeight + _labelHeight;
    } else {
      groupHeight = rowHeight;
    }
    Range range;
    var _startTime = DateTime.now();
    for (int i = 0; i < features.length; i++) {
      feature = features[i];
      feature.index = i;

      range = feature.range;
      double start = scale.scale(range.start)!;
      double end = scale.scale(range.end)!;

      num _maxRangeEnd = feature.range.end;
      num _minRangeStart = feature.range.start;

      double _blockEnd = scale[_maxRangeEnd] as double;
      double _blockStart = scale[_minRangeStart] as double;
      // double _width = _blockEnd - _blockStart;

      double textWidth = measureTextWidth(feature.name, labelFontSize);
      feature.labelWidth = textWidth;
      double _maxEnd = _showLabel ? max(_blockEnd, textWidth + _blockStart) : _blockEnd;
      // if (!_showLabel) _maxEnd = max(_maxEnd, start + measureTextWidth(feature.name, labelFontSize));

      Rect _groupRect = _findFeatureTop(feature, Rect.fromLTRB(start, padding.top, _maxEnd, padding.top + groupHeight), 6);
      Rect fRect = Rect.fromLTRB(start, _groupRect.top, end, _groupRect.top + featureHeight);

      bool setGroup = _showLabel;
      feature.groupRect = setGroup ? _groupRect : null;
      feature.rect = fRect;

      _injectFeatureRect(feature, fRect, _horizontal, rowHeight, rowSpace, scale, collapseMode, showLabel, labelFontSize);
      BlockPosition _position = BlockPosition(rowCount: 1, rect: _groupRect, featureId: feature.uniqueId);
      _blockCache[feature.uniqueId] = _position;
    }

    maxHeight = (_rowFeatures.length + 1) * (groupHeight + rowSpace) + rowSpace;
    var _endLayout = DateTime.now();
    logger.d('bed layout ${features.length} cost: ${(_endLayout.millisecondsSinceEpoch - _startTime.millisecondsSinceEpoch) / 1000}');
  }

  Rect _findFeatureTop(Feature feature, Rect rect, double rowSpace) {
    int? _findRow;
    Rect _rowLastRect;
    int rows = _rowFeatures.length;

    RowFeature? rowFeature;
    for (int i = 0; i < rows; i++) {
      rowFeature = _rowFeatures[i];
      if (rowFeature == null) {
        _findRow = i;
        rowFeature = RowFeature(row: i);
        _rowFeatures[i] = rowFeature;
        break;
      }
      _rowLastRect = rowFeature.last!.groupRect ?? rowFeature.last!.rect!;
      if (_rowLastRect.right < rect.left) {
        _findRow = i;
        break;
      }
    }
    //not found;
    if (_findRow == null) {
      _findRow = rows;
      rowFeature = RowFeature(row: _findRow);
      _rowFeatures[_findRow] = rowFeature;
    }

    double top = _findRow * (rect.height + rowSpace) + rect.top;
    rect = Rect.fromLTWH(rect.left, top, rect.width, rect.height);
    rowFeature!.add(feature as BedFeature);

    // _rowLastItemCache[_findRow] = rect;

    return rect;
  }

  bool _rangeInteract(Rect rect, List<BlockPosition>? _positions) {
    if (null == _positions || _positions.isEmpty) return false;
    bool interact = false;
    for (BlockPosition position in _positions) {
      if (position.rect.overlaps(rect)) {
        interact = true;
        break;
      }
    }
    return interact;
  }

  double _findMaxHeight(Iterable<BlockPosition> blockPositions, bool _horizontal) {
    if (_horizontal) {
      return blockPositions.reduce((value, element) => value.rect.bottom > element.rect.bottom ? value : element).rect.bottom;
    } else {
      return blockPositions.reduce((value, element) => value.rect.right > element.rect.right ? value : element).rect.right;
    }
  }

  double _injectFeatureRect(
    Feature feature,
    Rect rect,
    bool _horizontal,
    double rowHeight,
    double rowSpace,
    Scale<num, num> scale,
    TrackCollapseMode collapseMode,
    bool showLabel,
    double labelFontSize,
  ) {
    if (!feature.hasSubFeature) return 0;
    for (Feature feature in feature.subFeatures!) {
      feature.rect = _horizontal
          ? Rect.fromLTRB(scale[feature.range.start]!, rect.top, scale[feature.range.end]!, rect.bottom) //
          : Rect.fromLTRB(rect.left, scale[feature.range.start]!, rect.right, scale[feature.range.end]!);
      if (feature.subFeatures != null) {
        _injectFeatureRect(feature, feature.rect!, _horizontal, rowHeight, rowSpace, scale, collapseMode, showLabel, labelFontSize);
      }
    }
    return 0;
  }
}
