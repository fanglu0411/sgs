import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';

class MethylationStyle extends TrackStyle {
  MethylationStyle(Map map, Brightness brightness) : super(map, brightness);

  MethylationStyle.empty(Brightness brightness) : super.empty(brightness);

  MethylationStyle.from({
    Brightness? brightness,
    Map<String, dynamic>? darkStyleMap,
    required Map<String, dynamic> lightStyleMap,
  }) : super.from(
          lightStyleMap: lightStyleMap,
          darkStyleMap: darkStyleMap,
        );

  static MethylationStyle base() {
    return MethylationStyle.from(lightStyleMap: {
      'color_map': {
        'CG': Color(0xff1591e2),
        'CHG': Colors.orange,
        'CHH': Colors.purple,
        'deeps': Colors.grey,
      },
      'track_height': 140.0,
      'density_mode': false,
    });
  }

  bool get densityMode => this['density_mode'];

  void set densityMode(bool densityMode) => this['density_mode'] = densityMode;

  @override
  MethylationStyle copy() {
    return MethylationStyle(copySourceMap(), brightness);
  }
}
