import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';
import 'package:flutter_smart_genome/widget/track/relation/relation_view_type.dart';

class InteractiveStyle extends TrackStyle {
  InteractiveStyle(Map map, Brightness brightness) : super(map, brightness);

  InteractiveStyle.empty(Brightness brightness) : super.empty(brightness);

  InteractiveStyle.from({
    Brightness brightness = Brightness.light,
    Map<String, dynamic>? darkStyleMap,
    required Map<String, dynamic> lightStyleMap,
  }) : super.from(
          lightStyleMap: lightStyleMap,
          darkStyleMap: darkStyleMap,
          brightness: brightness,
        );

  static InteractiveStyle base() {
    return InteractiveStyle.from(lightStyleMap: {
      'track_height': 120.0,
      'custom_max_value': {'enabled': false, 'value': 100.0},
      'custom_min_value': {'enabled': false, 'value': 1.0},
      'track_color': Colors.blue,
      'relation_display_mode': RelationViewType.line.index,
    });
  }

  RelationViewType get viewMode => RelationViewType.values[this['relation_display_mode'] ?? 0];

  @override
  InteractiveStyle copy() {
    return InteractiveStyle(copySourceMap(), brightness);
  }

  @override
  InteractiveStyle empty() {
    return InteractiveStyle.empty(brightness);
  }
}
