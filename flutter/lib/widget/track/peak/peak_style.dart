import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';

class PeakStyle extends TrackStyle {
  PeakStyle(Map map, Brightness brightness) : super(map, brightness);

  PeakStyle.empty(Brightness brightness) : super.empty(brightness);

  PeakStyle.from({
    super.brightness,
    super.darkStyleMap,
    required super.lightStyleMap,
  }) : super.from();

  static PeakStyle base() {
    return PeakStyle.from(lightStyleMap: {
      'line_color': Colors.grey,
      'track_color': Colors.blue,
      'track_max_height': {'enabled': false, 'value': 300},
      'feature_height': 8.0,
      'track_height': 120.0,
      'label_font_size': 12.0,
      'label_color': Colors.black,
      'show_label': true,
    });
  }

  @override
  PeakStyle copy() {
    return PeakStyle(copySourceMap(), brightness);
  }
}
