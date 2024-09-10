import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';

class VcfStyle extends TrackStyle {
  VcfStyle(Map map, Brightness brightness) : super(map, brightness);

  VcfStyle.empty(Brightness brightness) : super.empty(brightness);

  VcfStyle.from({
    super.brightness,
    super.darkStyleMap,
    required super.lightStyleMap,
  }) : super.from();

  static VcfStyle base() {
    return VcfStyle.from(lightStyleMap: {
      'track_max_height': {'enabled': true, 'value': 300},
      'track_height': 140.0,
      'feature_height': 12.0,
      'label_font_size': 12.0,
      'label_color': Colors.grey,
      // 'show_label': true,
      'track_color': Colors.blue,
      'feature_group_color': Color(0x6dc8d3c9),
      "color_map": {
        "SNV": Colors.purpleAccent,
        "SV": Colors.deepOrangeAccent,
        "INDEL": Colors.lightGreen,
        "MNV": Colors.tealAccent,
      },
    });
  }

  @override
  VcfStyle copy() {
    return VcfStyle(copySourceMap(), brightness);
  }
}
