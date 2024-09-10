import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';

class BamCoverageStyle extends TrackStyle {
  BamCoverageStyle(Map map, Brightness brightness) : super(map, brightness);

  BamCoverageStyle.empty(Brightness brightness) : super.empty(brightness);

  BamCoverageStyle.from({
    Brightness? brightness,
    Map<String, dynamic>? darkStyleMap,
    required Map<String, dynamic> lightStyleMap,
  }) : super.from(
          lightStyleMap: lightStyleMap,
          darkStyleMap: darkStyleMap,
        );

  static BamCoverageStyle base() {
    return BamCoverageStyle.from(lightStyleMap: {
      'color_map': {
        'A': Colors.green,
        'T': Colors.red,
        'C': Colors.blue,
        'G': Colors.orange,
        'coverage': Colors.grey,
      },
      'track_color': Colors.grey,
      'track_height': 140.0,
      'density_mode': false,
    });
  }

  bool get densityMode => this['density_mode'];

  void set densityMode(bool densityMode) => this['density_mode'] = densityMode;

  @override
  BamCoverageStyle copy() {
    return BamCoverageStyle(copySourceMap(), brightness);
  }
}
