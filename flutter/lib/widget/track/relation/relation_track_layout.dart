import 'package:dartx/dartx.dart' as dx;
import 'package:flutter/material.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/page/track/track_ui_config_bean.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

import 'interactive_data.dart';

class RelationTrackLayout extends TrackLayout {
  Map<String, int> _featureRowMap = {};

  double measureTextWidth(String text, double fontSize) {
    labelPainter!.text = TextSpan(text: text, style: TextStyle(fontSize: fontSize));
    labelPainter!.layout();
    return labelPainter!.width;
  }

  RelationTrackLayout() {
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
    required Scale<num, num> scale,
    required Axis orientation,
    required TrackCollapseMode collapseMode,
    required Range visibleRange,
    EdgeInsets padding = EdgeInsets.zero,
    required double top,
    required double bottom,
  }) {
    if ((data.data?.length ?? 0) == 0) return;

    Range pixRange1;
    Range pixRange2;

    Range visibleUiRange = Range(start: scale[visibleRange.start]!, end: scale[visibleRange.end]!);

    var valueDelta = (data.maxValue - data.minValue);
    ScaleLog<num> colorScale = scaleLogFixed(domain: [data.minValue, data.maxValue], range: [0.1, 1.0]);
    // var colorScale = ScaleLinear.number(domain: [0, data.maxValue], range: [0, 1.0]);

    double maxHeightForScale = ((bottom - top) * .3).clamp(6.0, 100.0);
    ScaleLinear<num> heightScale = ScaleLinear.number(domain: [0, data.maxValue], range: [5, maxHeightForScale]);

    for (InteractiveItem bin in data.data!) {
      pixRange1 = Range(start: scale[bin.range1.start]!, end: scale[bin.range1.end]!);
      pixRange2 = Range(start: scale[bin.range2.start]!, end: scale[bin.range2.end]!);
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
      bin.colorValue = valueDelta == 0 ? 1.0 : colorScale.call(bin.value)!.toDouble();

      bin.path = bin.getPath(top, bottom);
      bin.areaPath = bin.getAreaPath(bottom);
      bin.arcPath = bin.getArcPath(top, bottom, visibleUiRange.size, heightScale);
    }
    // print(data.data);
    // maxHeight = 140;
  }
}
