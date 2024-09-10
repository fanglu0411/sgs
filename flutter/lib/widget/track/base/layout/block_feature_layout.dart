import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/page/track/track_ui_config_bean.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'dart:math' show max;
import 'layout_base.dart';

class BlockFeatureLayout extends TrackLayout {
  Map<int, BlockPosition> rowLastBlockPositionsMap = {};
  Map<String, int> _featureRowMap = {};

  BlockFeatureLayout() {}

  clear() {
    int length = _featureRowMap.length;
    rowLastBlockPositionsMap.clear();
    _featureRowMap.clear();
    maxHeight = 0;
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
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    if ((features.length) == 0) return;

    Map<int, List<BlockPosition>> _rowFeaturePositionList = {};

    bool _horizontal = orientation == Axis.horizontal;
    //print('scale $scale visible range: $visibleRange');
    GffFeature feature;
    int _featureRow;
    double top;

//    print('-feature: ${_featureRowMap.keys}');

    features.sort((a, b) {
      int _a = _featureRowMap[a.uniqueId] ?? -1;
      int _b = _featureRowMap[b.uniqueId] ?? -1;
      if (_a >= 0 && _b >= 0) return (a.range.start - b.range.start).toInt();
      if (_a >= 0) return -1;
      if (_b >= 0) return 1;
      return (a.range.start - b.range.start).toInt();
//      return _featureRowMap[a.id] == null ? 1 : -1;
    });
    // print(features.map((e) => e.id).toList().join('\n'));

    double _labelHeight = rowSpace;
    bool _showLabel = showLabel && showSubFeature;
    rowSpace = _showLabel ? rowSpace : 6;

    for (int i = 0; i < features.length; i++) {
      feature = features[i] as GffFeature;
      feature.index = i;

      Range range = feature.range;
      double start = scale.scale(range.start)!;
      double end = scale.scale(range.end)!;

      int _childrenCount = feature.childrenCount > 0 && collapseMode == TrackCollapseMode.expand ? feature.childrenCount : 0;

      num _maxRangeEnd = feature.range.end;
      num _minRangeStart = feature.range.start;
      [feature, if (_childrenCount > 0) ...feature.children!].forEach((f) {
        if (f.range.start < _minRangeStart) _minRangeStart = f.range.start;
        if (f.range.end > _maxRangeEnd) _maxRangeEnd = f.range.end;
      });
      double _blockEnd = scale[_maxRangeEnd] as double;
      double _blockStart = scale[_minRangeStart] as double;
      double _width = _blockEnd - _blockStart;

      double _maxEnd = max(_blockEnd, _measureBlockMaxEnd([feature, if (_childrenCount > 0) ...feature.children!], scale, labelFontSize, _width, _showLabel));
      // if (!_showLabel) _maxEnd = max(_maxEnd, start + measureTextWidth(feature.name, labelFontSize));

      double groupHeight = rowHeight;
      double featureHeight = rowHeight;

      if (_childrenCount > 0) {
        groupHeight = (_childrenCount * rowHeight + (_childrenCount + 1) * rowSpace + rowHeight - 4);
      }
      // if (!_showLabel) groupHeight += _labelHeight; // 不显示label，但是要显示一个基因名

      _featureRow = _featureRowMap[feature.uniqueId] ??
          _findProperPositionRow(feature.uniqueId, _blockStart, _maxEnd, groupHeight, rowHeight, rowSpace, padding, _childrenCount, _rowFeaturePositionList) ??
          _findMaxRowInMap(_blockStart, _rowFeaturePositionList);

      top = _featureRow * rowHeight + (_featureRow) * rowSpace + padding.top;
      Rect fRect = _horizontal ? Rect.fromLTRB(start, top, end, top + featureHeight) : Rect.fromLTRB(top, start, top + featureHeight, end);

      // Rect _fRect = _horizontal ? Rect.fromLTRB(_blockStart, top, _maxEnd, top + groupHeight) : Rect.fromLTRB(top, _blockStart, top + groupHeight, _maxEnd);
      Rect _groupRect = _horizontal ? Rect.fromLTRB(_blockStart, top, _maxEnd, top + groupHeight) : Rect.fromLTRB(top, _blockStart, top + groupHeight, _blockEnd);

      feature.row = _featureRow;

      if (_childrenCount > 0) {
        feature.groupRect = _groupRect;
        feature.rect = _horizontal ? Rect.fromLTRB(start, top, end, top + rowHeight) : Rect.fromLTRB(top, start, top + rowHeight, end);
      } else {
        feature.groupRect = null;
        feature.rect = fRect;
      }

      _injectFeatureRect(feature, fRect, _horizontal, rowHeight, rowSpace, scale, collapseMode, showLabel, labelFontSize);

      BlockPosition _position = BlockPosition(row: _featureRow, rowCount: _childrenCount, rect: _groupRect, featureId: feature.uniqueId);

      void cacheRowPosition(int row, BlockPosition position) {
        if (_rowFeaturePositionList.containsKey(row)) {
          _rowFeaturePositionList[row]!.add(position);
        } else {
          _rowFeaturePositionList[row] = [position];
        }
      }

      cacheRowPosition(_featureRow, _position);

      if (_childrenCount > 0) {
        for (int n = 1; n <= _childrenCount; n++) {
          cacheRowPosition(
              _featureRow + n,
              _position.copy(
                row: _featureRow + n,
                rect: _horizontal
                    ? Rect.fromLTWH(_groupRect.left, _groupRect.top + (n * (rowSpace + rowHeight)), _groupRect.width, rowHeight)
                    : Rect.fromLTWH(_groupRect.left + (n * (rowSpace + rowHeight)), _groupRect.top, rowHeight, _groupRect.height),
                group: true,
                featureId: '${feature.children![n - 1].uniqueId}',
              ));
        }
      }
      _featureRowMap[feature.uniqueId] = _featureRow;
    }

    num _maxHeight = _rowFeaturePositionList.values.map((e) => _findMaxHeight(e, _horizontal)).reduce((a, b) => a > b ? a : b);
    maxHeight = _maxHeight + rowSpace;
  }

  double _measureBlockMaxEnd(List<Feature> features, Scale<num, num> scale, double labelFontSize, double blockWidth, bool showLabel) {
    return features.map((f) {
      double s = scale[f.range.start] as double;
      double e = scale[f.range.end] as double;
      // double maxWidth = max(e - s, blockWidth);
      double textWidth = measureTextWidth(f.name, labelFontSize);
      f.labelWidth = textWidth;
      if (showLabel && labelFontSize > 0) {
        return max(e, s + textWidth);
        // double delta = textWidth - (maxWidth);
        // return delta > 0 && textWidth > maxWidth ? e + delta : e;
      }
      return e;
    }).reduce((a, b) => a > b ? a : b);
  }

  int _findMaxRowInMap(double start, Map<int, List<BlockPosition>> map) {
    if (map.length == 0) return 0;
    return map.values.map((e) => _findMaxRow(start, e)).reduce((a, b) => a > b ? a : b);
  }

  int? _findProperPositionRow(id, start, end, height, rowHeight, rowSpace, EdgeInsets padding, childrenCount, Map<int, List<BlockPosition>> rowFeatureList) {
    bool _overlapRows(List<int> rows, Rect rect) {
      bool overlap = false;
      for (int row in rows) {
        List<BlockPosition>? _positions = rowFeatureList[row];
        if (_rangeInteract(rect, _positions)) {
          overlap = true;
          break;
        }
      }
      return overlap;
    }

    Rect rect;
    int? _row = null;
    if (rowFeatureList.keys.length == 0) return null;

    int maxRow = rowFeatureList.keys.reduce((a, b) => a > b ? a : b);

    for (int row = 0; row <= maxRow; row++) {
      if (!rowFeatureList.containsKey(row)) {
        _row = row;
        break;
      }
//      List<BlockPosition> _positions = rowFeatureList[row];
      double top = (row) * rowHeight + (row) * rowSpace + padding.top;
      rect = Rect.fromLTRB(start, top, end, top + height);

      //如果是多行，还要找下面几行是不是也没交集
      List<int> _rows = childrenCount > 0 ? List.generate(childrenCount + 1, (index) => row + index) : [row];
      if (!_overlapRows(_rows, rect)) {
        _row = row;
        break;
      }

//      if (childrenCount > 0) {
//        row += (childrenCount - 1);
//      }
    }
    if (null == _row) _row = maxRow + 1;
    //print('===============> find proper row ${id} => $_row  ${maxRow + 1}');
    return _row;
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

  int _findMaxRow(double start, Iterable<BlockPosition> blockPositions) {
    Iterable<BlockPosition> _blockPositions = blockPositions.where((p) => !(p.rect.right < start));
    if (_blockPositions.isEmpty) return 0;

    BlockPosition _position = _blockPositions.reduce((value, element) => value.row! + value.rowCount > element.row! + element.rowCount ? value : element);
    return _position.row! + _position.rowCount;
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
    if (feature.hasChildren && collapseMode == TrackCollapseMode.expand) {
      Feature cldFeature;
      double featureTopOrLeft;
      double _maxDelta = 0;
      double extra = collapseMode == TrackCollapseMode.expand ? rowHeight + rowSpace : 0;
      for (int i = 0; i < feature.children!.length; i++) {
        cldFeature = feature.children![i];
        featureTopOrLeft = (_horizontal ? rect.top + extra : rect.left + extra) + i * rowHeight + (i) * rowSpace;
        cldFeature.rect = _horizontal
            ? Rect.fromLTRB(
                scale[cldFeature.range.start] as double,
                featureTopOrLeft,
                scale[cldFeature.range.end] as double,
                featureTopOrLeft + rowHeight,
              )
            : Rect.fromLTRB(
                featureTopOrLeft,
                scale[cldFeature.range.start] as double,
                featureTopOrLeft + rowHeight,
                scale[cldFeature.range.end] as double,
              );

        if (showLabel && labelFontSize > 0) {
          double labelWidth = (feature.name).length * labelFontSize * .9;
          double _delta = labelWidth - cldFeature.rect!.width;
          if (_maxDelta < _delta) {
            _maxDelta = _delta;
          }
        }

        if (cldFeature.subFeatures != null) {
          _injectFeatureRect(
            cldFeature,
            cldFeature.rect!,
            _horizontal,
            rowHeight,
            rowSpace,
            scale,
            collapseMode,
            showLabel,
            labelFontSize,
          );
        }
      }
//      return _maxDelta;
    }

    if (!feature.hasSubFeature) return 0;
    for (Feature feature in feature.subFeatures!) {
      feature.rect = _horizontal
          ? Rect.fromLTRB(scale[feature.range.start]!, rect.top, scale[feature.range.end]!, rect.bottom)
          : Rect.fromLTRB(rect.left, scale[feature.range.start]!, rect.right, scale[feature.range.end]!);
      if (feature.subFeatures != null) {
        _injectFeatureRect(feature, feature.rect!, _horizontal, rowHeight, rowSpace, scale, collapseMode, showLabel, labelFontSize);
      }
    }
    return 0;
  }
}
