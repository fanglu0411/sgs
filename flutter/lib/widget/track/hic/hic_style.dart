import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';
import 'package:flutter_smart_genome/widget/track/hic/hic_track_widget.dart';

class HicStyle extends TrackStyle {
  HicStyle(Map map, Brightness brightness) : super(map, brightness);

  HicStyle.empty(Brightness brightness) : super.empty(brightness);

  HicStyle.from({
    super.brightness,
    super.darkStyleMap,
    required super.lightStyleMap,
  }) : super.from();

  static HicStyle base() {
    return HicStyle.from(lightStyleMap: {
      'track_max_height': {'enabled': true, 'value': 300.0},
      'custom_max_value': {'enabled': false, 'value': 100.0},
      'custom_min_value': {'enabled': false, 'value': 1.0},
      'normalize': 0, // VC, VC_SQRT, KR
      'track_color': Colors.blue,
      'hic_display_mode': HicDisplayMode.heatmap.index,
    });
  }

  HicNormalize get normalize {
    var n = this['normalize'];
    if (n == 'VC') return HicNormalize.VC;
    if (n == 'VC_SQRT') return HicNormalize.VC_SQRT;
    if (n == 'KR') return HicNormalize.KR;
    return HicNormalize.VC;
  }

  HicDisplayMode get displayMode => HicDisplayMode.values[this['hic_display_mode'] ?? 0];

  @override
  HicStyle copy() {
    return HicStyle(copySourceMap(), brightness);
  }

  @override
  HicStyle empty() {
    return HicStyle.empty(brightness);
  }
}
