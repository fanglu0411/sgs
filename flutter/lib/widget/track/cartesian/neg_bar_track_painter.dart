import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/bar_style_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/bar_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_data.dart';


class NegBarTrackPainter extends BarTrackPainter {
  NegBarTrackPainter({
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

  }) : super(

  ) {
    // trackPaint.color = styleConfig.barColor;
  }

  bool dynamicHeight;

  @override
  Color itemColor(BarStyleConfig styleConfig, CartesianDataItem item) {
    num _v = item.value;
    return styleConfig.colorMap[_v > 0 ? '+' : '-'] ?? styleConfig.barColor;
  }
}