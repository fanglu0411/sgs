import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';

class GroupCoverageStyle extends TrackStyle {
  GroupCoverageStyle(Map map, Brightness brightness) : super(map, brightness);

  GroupCoverageStyle.empty(Brightness brightness) : super.empty(brightness);

  GroupCoverageStyle.from({
    Brightness? brightness,
    Map<String, dynamic>? darkStyleMap,
    required Map<String, dynamic> lightStyleMap,
  }) : super.from(
          lightStyleMap: lightStyleMap,
          darkStyleMap: darkStyleMap,
        );

  static GroupCoverageStyle base() {
    return GroupCoverageStyle.from(lightStyleMap: {
      'track_height': 50.0,
      'track_max_height': {'enabled': true, 'value': 500},
    });
  }

  @override
  GroupCoverageStyle copy() {
    return GroupCoverageStyle(copySourceMap(), brightness);
  }
}
