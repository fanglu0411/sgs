import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';

class EQTLStyle extends TrackStyle {
  EQTLStyle(Map map, Brightness brightness) : super(map, brightness);

  EQTLStyle.empty(Brightness brightness) : super.empty(brightness);

  EQTLStyle.from({
    Brightness? brightness,
    Map<String, dynamic>? darkStyleMap,
    required Map<String, dynamic> lightStyleMap,
  }) : super.from(
          lightStyleMap: lightStyleMap,
          darkStyleMap: darkStyleMap,
        );

  static EQTLStyle base() {
    return EQTLStyle.from(lightStyleMap: {
      'track_color': Color(0x1044ec),
      'track_height': 80.0,
      'custom_max_value': {'enabled': true, 'value': 0.05},
      'value_scale_type': 2,
      'radius': 10,
    });
  }

  double get radius => this['radius'] ?? 10;

  void set radius(double radius) => this['radius'] = radius;

  @override
  EQTLStyle copy() {
    return EQTLStyle(copySourceMap(), brightness);
  }
}
