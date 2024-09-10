import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/chart/bar_chart/bar_data.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/bar_style_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_data.dart';

import 'cartesian_track_painter.dart';

class BarTrackPainter extends CartesianTrackPainter<BarData, BarStyleConfig> {
  BarTrackPainter({
    required super.trackData, // may be data in a range
    required super.styleConfig,
    required super.scale, // the scale by the hole chromosome
    required super.visibleRange,
    super.orientation,
    super.selectedItem,
    super.valueScaleType,
    super.cursor,
    super.customMaxValue,
    super.onItemTap,
    super.height,
    this.dynamicHeight = false,
  }) : super() {
    trackPaint!
      ..color = styleConfig.barColor
      ..isAntiAlias = true
      // ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 0;
  }

  bool dynamicHeight;

  @override
  void drawHorizontalTrack(Canvas canvas, Rect trackRect, Size size) {
    // canvas.drawLine(Offset(trackRect.left, trackRect.bottom), Offset(trackRect.right, trackRect.bottom), trackPaint);
    if (trackData.isEmpty) return;
    BarStyleConfig _styleConfig = styleConfig;
    trackData.dataSource!.forEach((item) {
      var _rect = item.renderShape!.rect;
      if (_rect.right < trackRect.left || _rect.left > trackRect.right) {
        return; //not visible, so skip
      }
      canvas.drawRect(_rect, trackPaint!..color = itemColor(_styleConfig, item));
    });
  }

  @override
  Color itemColor(BarStyleConfig styleConfig, CartesianDataItem item) {
    return styleConfig.barColor;
  }

  @override
  void drawVerticalTrack(Canvas canvas, Rect trackRect, Size size) {}

  @override
  bool hitTest(Offset position) {
    int index = findHitItem(position);
//    print('bar painter hit test $position , index $index');
    if (index >= 0) return true;
//    return false; //不能return false， 否则事件没法传递
    return super.hitTest(position);
  }
}
