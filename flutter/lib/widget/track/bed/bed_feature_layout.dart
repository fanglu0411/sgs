import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/page/track/track_ui_config_bean.dart';
import 'package:flutter_smart_genome/util/lru_cache.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/layout_base.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'dart:math' show max;
import 'package:flutter_smart_genome/extensions/rect_extension.dart';

class BedFeatureLayout extends TrackLayout {
  // Map<String, BlockPosition> _featureBlockMap = {};
  LruCache<String, BlockPosition> _blockCache = LruCache<String, BlockPosition>(1000);

  BedFeatureLayout() {}

  clear() {
    int length = _blockCache.length;
    _blockCache.clear();
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
    bool showChildrenLabel = false,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    if ((features.length) == 0) return;

    bool _horizontal = orientation == Axis.horizontal;
    //print('scale $scale visible range: $visibleRange');
    Feature feature;

    // _featureBlockMap.clear();
    // _charWidth = measureTextWidth('A', labelFontSize);

//    print('-feature: ${_featureRowMap.keys}');

    features.sort((a, b) {
      // int _a = _featureBlockMap[a.id] ?? -1;
      // int _b = _featureBlockMap[b.id] ?? -1;
      // if (_a >= 0 && _b >= 0) return a.range.start - b.range.start;
      // if (_a >= 0) return -1;
      // if (_b >= 0) return 1;
      if (a.range.intersection(b.range) != null) {
        return (b.range.size - a.range.size).toInt();
      }

      return (a.range.start - b.range.start).toInt();
//      return _featureRowMap[a.id] == null ? 1 : -1;
    });
    // print(features.map((e) => e.id).toList().join('\n'));

    double _labelHeight = labelFontSize + 2;
    bool _showLabel = showLabel && showSubFeature;
    bool _showChildrenLabel = _showLabel && showChildrenLabel;
    rowSpace = _showChildrenLabel ? rowSpace : 6;

    var _startTime = DateTime.now();
    for (int i = 0; i < features.length; i++) {
      feature = features[i];
      feature.index = i;

      Range range = feature.range;
      double start = scale[range.start]!;
      double end = scale[range.end]!;

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
        if (_showLabel) {
          if (_showChildrenLabel) {
            groupHeight = ((_childrenCount + 1) * rowHeight + (_childrenCount + 1) * rowSpace);
          } else {
            groupHeight = ((_childrenCount + 1) * rowHeight + (_childrenCount) * rowSpace + _labelHeight);
          }
        } else {
          groupHeight = ((_childrenCount + 1) * rowHeight + (_childrenCount) * rowSpace);
        }
      } else {
        if (_showLabel) {
          groupHeight = rowHeight + _labelHeight;
        } else {
          groupHeight = rowHeight;
        }
      }

      Rect _groupRect = _findFeatureTop(feature, Rect.fromLTRB(start, padding.top, _maxEnd, padding.top + groupHeight), 6);
      Rect fRect = Rect.fromLTRB(start, _groupRect.top, end, _groupRect.top + featureHeight);

      bool setGroup = _showLabel || _childrenCount > 0;
      feature.groupRect = setGroup ? _groupRect : null;
      feature.rect = fRect;

      _injectFeatureRect(feature, fRect, _horizontal, rowHeight, rowSpace, scale, collapseMode, showLabel, labelFontSize);
      BlockPosition _position = BlockPosition(rowCount: _childrenCount + 1, rect: _groupRect, featureId: feature.uniqueId);
      _blockCache[feature.uniqueId] = _position;
    }

    num _maxHeight = _findMaxHeight(_blockCache.values, _horizontal);
    maxHeight = _maxHeight + rowSpace;
    var _endLayout = DateTime.now();
    print('bed layout ${features.length} cost: ${(_endLayout.millisecondsSinceEpoch - _startTime.millisecondsSinceEpoch) / 1000}');
  }

  Rect _findFeatureTop(Feature feature, Rect rect, double rowSpace) {
    Rect _rect = Rect.fromLTRB(rect.left, rect.top, rect.right, rect.bottom);
    BlockPosition? position = _blockCache[feature.uniqueId];

    if (position != null) {
      return Rect.fromLTRB(rect.left, position.rect.top, rect.right, position.rect.top + rect.height);
    }

    List<BlockPosition> _horCollides = [];
    List<String> keys = _blockCache.keys.toList();

    for (String id in keys) {
      position = _blockCache[id];
      if (_rect.overlaps(position!.rect)) {
        _rect = Rect.fromLTWH(rect.left, position.rect.bottom, rect.width, rect.height).translate(0, rowSpace);
      }
      if (_rect.overlapsHorizontal(position.rect)) {
        _horCollides.add(position);
      }
    }
    // print('_horCollides: ${_horCollides.length}');
    for (BlockPosition p in _horCollides) {
      if (_rect.overlaps(p.rect)) {
        _rect = Rect.fromLTWH(rect.left, p.rect.bottom, rect.width, rect.height).translate(0, rowSpace);
      }
    }
    return _rect;
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

  bool _rangeInteract(Rect rect, List<BlockPosition> _positions) {
    if (_positions.isEmpty) return false;
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
          double labelWidth = measureTextWidth(feature.name, labelFontSize);
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
          ? Rect.fromLTRB(scale[feature.range.start]!, rect.top, scale[feature.range.end]!, rect.bottom) //
          : Rect.fromLTRB(rect.left, scale[feature.range.start]!, rect.right, scale[feature.range.end]!);
      if (feature.subFeatures != null) {
        _injectFeatureRect(feature, feature.rect!, _horizontal, rowHeight, rowSpace, scale, collapseMode, showLabel, labelFontSize);
      }
    }
    return 0;
  }
}
