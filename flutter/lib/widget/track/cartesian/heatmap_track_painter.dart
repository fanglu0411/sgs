import 'dart:ui';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_data.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/simple_cartesian_data.dart';

import 'heatmap_style_config.dart';

class HeatMapTrackPainter extends CartesianTrackPainter<SimpleCartesianData, HeatMapStyleConfig> {
  HeatMapTrackPainter({
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
  }) : super() {
    //
    trackPaint!..style = PaintingStyle.fill;
  }

  bool diffHeight = false;

  @override
  void drawHorizontalTrack(Canvas canvas, Rect trackRect, Size size) {
    HeatMapStyleConfig _styleConfig = styleConfig;
    if (trackData.isEmpty) return;
    trackData.dataSource!.forEach((item) {
      final _rect = item.renderShape!.rect;
      if (_rect.right < trackRect.left || _rect.left > trackRect.right) {
        return; //not visible, so skip
      }
      trackPaint!.color = Color.lerp(_styleConfig.lightColor, _styleConfig.heatColor, item.value / trackData.maxValue)!;
      canvas.drawRect(_rect, trackPaint!);
    });
  }

  @override
  drawSelectedItem(Canvas canvas, CartesianDataItem? _selectedItem, Scale<num, num> valueScale) {
    super.drawSelectedItem(canvas, _selectedItem, valueScale);
    // if (null == _selectedItem) return;
    // Rect _rect = rectMap[_selectedItem.index];
    // canvas.drawRect(_rect, selectedPaint);
    // drawText(
    //   canvas,
    //   text: ' ${_selectedItem.value} ',
    //   style: TextStyle(
    //     color: Colors.white,
    //     fontSize: 14,
    //     backgroundColor: Colors.black87,
    //   ),
    //   offset: Offset(_rect.right, _rect.top),
    //   textAlign: TextAlign.center,
    //   width: 50,
    // );
  }

  @override
  void drawHorizontalAxis(Canvas canvas, Rect trackRect, Size size) {
    // do nothing
    //super.drawHorizontalAxis(canvas, trackRect, size);
  }

  @override
  void drawVerticalTrack(Canvas canvas, Rect trackRect, Size size) {}

  @override
  bool painterChanged(AbstractTrackPainter painter) {
    return super.painterChanged(painter);
  }

  @override
  bool hitTest(Offset position) {
    int index = findHitItem(position);
//    print('bar painter hit test $position , index $index');
    if (index >= 0) return true;
//    return false; //不能return false， 否则事件没法传递
    return super.hitTest(position);
  }
}
