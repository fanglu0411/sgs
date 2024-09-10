import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/page/track/track_ui_config_bean.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/layout_base.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

class VcfSampleFeatureLayout extends TrackLayout {
  Map<int, FeaturePosition> rowLastBlockPositionsMap = {};

  Map<String, int> _featureRowMap = {};

  List? sampleList;

  Map? typeCodeMap;

  double? rowHeight;
  double? rowSpace;
  EdgeInsets padding = EdgeInsets.zero;

  int get sampleCount => sampleList?.length ?? 0;

  VcfSampleFeatureLayout() {
    labelPainter = TextPainter(
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr,
    );
  }

  clear() {
    int length = _featureRowMap.length;
    rowLastBlockPositionsMap.clear();
    _featureRowMap.clear();
    maxHeight = 0;
    print('clear => $length');
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
    String labelKey = 'name',
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    int rowCount = sampleList?.length ?? 1;
    double _maxHeight = (rowHeight + rowSpace) * rowCount;
    maxHeight = _maxHeight;

    if ((features.length ?? 0) == 0) return;

    bool _horizontal = orientation == Axis.horizontal;
    //print('scale $scale visible range: $visibleRange');
    Feature feature;
    int _featureRow = 0;
    double top;

    features.sort((a, b) {
      int _a = _featureRowMap[a.uniqueId] ?? -1;
      int _b = _featureRowMap[b.uniqueId] ?? -1;
      if (_a >= 0 && _b >= 0) return (a.range.start - b.range.start).toInt();
      if (_a >= 0) return -1;
      if (_b >= 0) return 1;
      return (a.range.start - b.range.start).toInt();
//      return _featureRowMap[a.id] == null ? 1 : -1;
    });

    bool _showLabel = showLabel && labelFontSize > 0;
    // rowSpace = _showLabel ? rowSpace : 5;
    double minWidth = 2;

    for (int i = 0; i < features.length; i++) {
      feature = features[i];
      feature.index = i;

      Range range = feature.range;
      double start = scale[range.start]!;
      double end = scale[range.end]!;
      if (end - start < minWidth) {
        end = start + minWidth;
      }
      double _blockEnd = end;
      double fHeight = rowHeight;

      top = _featureRow * (rowHeight + rowSpace) + rowSpace / 2 + padding.top;
      Rect fRect = _horizontal ? Rect.fromLTRB(start, top, end, top + fHeight) : Rect.fromLTRB(top, start, top + fHeight, end);
      Rect _fRect = _horizontal ? Rect.fromLTRB(start, top, _blockEnd, top + fHeight + rowSpace) : Rect.fromLTRB(top, start, top + fHeight, _blockEnd);

      feature.row = _featureRow;
      feature.groupRect = Rect.fromLTRB(start, padding.top, end, maxHeight);
      feature.rect = fRect;
      _featureRowMap[feature.uniqueId] = _featureRow;
    }
  }

  Rect rowRect(Feature feature, int row) {
    double top = row * (rowHeight! + rowSpace!) + rowSpace! / 2 + padding.top;
    return Rect.fromLTRB(feature.rect!.left, top, feature.rect!.right, top + rowHeight!);
  }
}
