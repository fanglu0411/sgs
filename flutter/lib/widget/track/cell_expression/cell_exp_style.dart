import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';

class CellExpStyle extends TrackStyle {
  CellExpStyle(Map map, Brightness brightness) : super(map, brightness);

  CellExpStyle.empty(Brightness brightness) : super.empty(brightness);

  CellExpStyle.from({
    Brightness? brightness,
    Map<String, dynamic>? darkStyleMap,
    required Map<String, dynamic> lightStyleMap,
  }) : super.from(
          lightStyleMap: lightStyleMap,
          darkStyleMap: darkStyleMap,
        );

  static CellExpStyle base() {
    return CellExpStyle.from(
      lightStyleMap: {
        'color_map': {},
        'feature_height': 40.0,
        'show_label': true,
        'label_font_size': 12.0,
        'label_color': Colors.black87,
        'show_legends': false,
        'bar_width': 4.0,
      },
      darkStyleMap: {
        'color_map': {},
        'feature_height': 40.0,
        'show_label': true,
        'label_font_size': 12.0,
        'label_color': Colors.white70,
        'show_legends': false,
        'bar_width': 4.0,
      },
    );
  }

  CellExpStyle copy() {
    return CellExpStyle(copySourceMap(), brightness);
  }
}
