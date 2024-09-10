import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';

class BigWigStyle extends TrackStyle {
  BigWigStyle(Map map, Brightness brightness) : super(map, brightness);

  BigWigStyle.empty(Brightness brightness) : super.empty(brightness);

  BigWigStyle.from({
    Brightness? brightness,
    Map<String, dynamic>? darkStyleMap,
    required Map<String, dynamic> lightStyleMap,
  }) : super.from(
          lightStyleMap: lightStyleMap,
          darkStyleMap: darkStyleMap,
        );

  static BigWigStyle base() {
    return BigWigStyle.from(lightStyleMap: {
      'color_map': {
        '+': Color(0xff1591e2),
        '-': Colors.red,
      },
      'track_height': 80.0,
      'density_mode': false,
    });
  }

  @override
  String get cartesianValueType {
    var t = this['cartesian_value_type'] ?? 'mean';
    if (t == 'sum') t = 'max';
    return t;
  }

  bool get densityMode => this['density_mode'];

  void set densityMode(bool densityMode) => this['density_mode'] = densityMode;

  @override
  BigWigStyle copy() {
    return BigWigStyle(copySourceMap(), brightness);
  }
}
