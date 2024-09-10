import 'dart:ui';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_data.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/simple_cartesian_data.dart';

import 'dot_style_config.dart';

class DotTrackPainter extends CartesianTrackPainter<SimpleCartesianData, DotStyleConfig> {
  DotTrackPainter({
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
    this.sizeAble = false,
  }) : super() {
    //
    trackPaint!
      ..color = styleConfig.color.withAlpha(150)
      ..style = PaintingStyle.fill;
  }

  bool sizeAble;

  @override
  void initWithSize(Size size) {
    super.initWithSize(size);
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
    super.onPaint(canvas, size, painterRect);
  }

  @override
  drawHorizontalTrack(Canvas canvas, Rect trackRect, Size size) {}

  @override
  drawSelectedItem(Canvas canvas, CartesianDataItem? _selectedItem, Scale<num, num> valueScale) {
    super.drawSelectedItem(canvas, _selectedItem, valueScale);
    // if (_selectedItem == null) return;
    // Rect _rect = rectMap[_selectedItem.index];
    // double valueHeight = valueScale * trackData[_selectedItem.index].value;
    // canvas.drawCircle(_rect.topCenter, valueHeight / trackRect.height * 20, selectedPaint);
    // drawText(
    //   canvas,
    //   text: ' ${_selectedItem.value} ',
    //   style: TextStyle(
    //     color: Colors.white,
    //     fontSize: 14,
    //     backgroundColor: Colors.black87,
    //   ),
    //   offset: Offset(_rect.topCenter.dx - 25, _rect.top - 26),
    //   textAlign: TextAlign.center,
    //   width: 50,
    // );
  }

  @override
  drawVerticalTrack(Canvas canvas, Rect trackRect, Size size) {}

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
