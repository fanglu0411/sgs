import 'package:d4_scale/d4_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/page/track/track_ui_config_bean.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

import 'interactive_data.dart';

class HicRelationLayout extends TrackLayout {
  Map<String, int> _featureRowMap = {};

  HicRelationLayout() {
    labelPainter = TextPainter(
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr,
    );
  }

  clear() {
    int length = _featureRowMap.length;
    _featureRowMap.clear();
    maxHeight = 0;
    print('clear => $length');
  }

  void calculate({
    required InteractiveData data,
    required Scale<num, num> scale1,
    required Scale<num, num> scale2,
    required Axis orientation,
    required TrackCollapseMode collapseMode,
    required Range visibleRange1,
    required Range visibleRange2,
    double? pixelsOfSeq1,
    double? pixelsOfSeq2,
    EdgeInsets padding = EdgeInsets.zero,
    required double top,
    required double bottom,
  }) {
    if ((data.data?.length ?? 0) == 0) return;

    Range pixRange1;
    Range pixRange2;

    for (InteractiveItem bin in data.data!) {
      pixRange1 = Range(start: scale1.scale(bin.range1.start)!, end: scale1[bin.range1.end]!);
      pixRange2 = Range(start: scale2[bin.range2.start]!, end: scale2[bin.range2.end]!);
      if (pixRange1.size < 1) {
        pixRange1.end = pixRange1.start + 1;
      }
      if (pixRange2.size < 1) {
        pixRange2.end = pixRange2.start + 1;
      }
      // pixRange1 = Range.fromSize(start: scale1[bin.range1.start], width: max(scale1[bin.range1.size], 1.0));
      // pixRange2 = Range.fromSize(start: scale2[bin.range2.start], width: max(scale2[bin.range2.size], 1.0));
      bin.uiRange1 = pixRange1;
      bin.uiRange2 = pixRange2;
      bin.colorValue = bin.value / data.maxValue;

      bin.path = bin.getPath(top, bottom);
      bin.areaPath = bin.getAreaPath(bottom);
    }
    // maxHeight = 140;
  }
}
