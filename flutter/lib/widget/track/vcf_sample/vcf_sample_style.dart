import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';

class VcfSampleStyle extends TrackStyle {
  VcfSampleStyle(Map map, Brightness brightness) : super(map, brightness);

  VcfSampleStyle.empty(Brightness brightness) : super.empty(brightness);

  VcfSampleStyle.from({
    super.brightness,
    super.darkStyleMap,
    required super.lightStyleMap,
  }) : super.from();

  static VcfSampleStyle base() {
    return VcfSampleStyle.from(lightStyleMap: {
      'color_map': {
        '0': Colors.grey,
        '1': Colors.lightBlue,
        '2': Colors.lightGreen,
      },
      'track_max_height': {'enabled': true, 'value': 300},
      'feature_height': 12.0,
      'label_font_size': 12.0,
      'label_color': Colors.grey,
      'feature_group_color': Colors.green.withOpacity(.3),
      'show_label': true,
      'track_color': Colors.blue,
    });
  }

  @override
  VcfSampleStyle copy() {
    return VcfSampleStyle(copySourceMap(), brightness);
  }
}
