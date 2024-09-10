import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';

class BamReadsStyle extends TrackStyle {
  BamReadsStyle(Map map, Brightness brightness) : super(map, brightness);

  BamReadsStyle.empty(Brightness brightness) : super.empty(brightness);

  BamReadsStyle.from({
    Brightness brightness = Brightness.light,
    Map<String, dynamic>? darkStyleMap,
    required Map<String, dynamic> lightStyleMap,
  }) : super.from(
          lightStyleMap: lightStyleMap,
          darkStyleMap: darkStyleMap,
          brightness: brightness,
        );

  static BamReadsStyle base() {
    return BamReadsStyle.from(lightStyleMap: {
      'color_map': {
        '+': Colors.red.shade200.withOpacity(.8),
        '-': Colors.blue.shade200.withOpacity(.8),
      },
      'track_color': Colors.blue,
      'track_max_height': {'enabled': false, 'value': 300},
      'feature_height': 8.0,
      'label_font_size': 12.0,
      'label_color': Colors.black,
      'feature_group_color': Colors.green.withOpacity(.3),
      'show_label': true,
    });
  }

  @override
  BamReadsStyle copy() {
    return BamReadsStyle(copySourceMap(), brightness);
  }
}
