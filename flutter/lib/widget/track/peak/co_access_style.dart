import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';

class CoAccessStyle extends TrackStyle {
  CoAccessStyle(Map map, Brightness brightness) : super(map, brightness);

  CoAccessStyle.empty(Brightness brightness) : super.empty(brightness);

  CoAccessStyle.from({
    super.brightness,
    super.darkStyleMap,
    required super.lightStyleMap,
  }) : super.from();

  static CoAccessStyle base() {
    return CoAccessStyle.from(lightStyleMap: {
      'track_color': Colors.blue,
      'track_height': 100.0,
      'track_max_height': {'enabled': false, 'value': 300},
      'custom_min_value': {'enabled': false, 'value': 0},
      'custom_max_value': {'enabled': false, 'value': 1},
    });
  }

  @override
  CoAccessStyle copy() {
    return CoAccessStyle(copySourceMap(), brightness);
  }
}
