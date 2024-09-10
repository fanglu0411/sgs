import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';

class SeqStyle extends TrackStyle {
  SeqStyle(Map map, Brightness brightness) : super(map, brightness);

  SeqStyle.empty(Brightness brightness) : super.empty(brightness);

  SeqStyle.from({
    Brightness? brightness,
    Map<String, dynamic>? darkStyleMap,
    required Map<String, dynamic> lightStyleMap,
  }) : super.from(
          lightStyleMap: lightStyleMap,
          darkStyleMap: darkStyleMap,
        );

  static SeqStyle defaultStyle() {
    return SeqStyle.from(lightStyleMap: {
      'color_map': {
        'A': Colors.green,
        'T': Colors.red,
        'C': Colors.blue,
        'G': Colors.orange,
      },
      'label_font_size': 10.0,
    });
  }

  @override
  SeqStyle copy() {
    return SeqStyle(copySourceMap(), brightness);
  }
}
