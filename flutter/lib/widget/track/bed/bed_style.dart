import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/feature_style_mixin.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';

class BedStyle extends TrackStyle with FeaturedStyleMixin {
  BedStyle(Map map, Brightness brightness) : super(map, brightness);

  BedStyle.empty(Brightness brightness) : super.empty(brightness);

  static BedStyle base() {
    return BedStyle({
      'light': {
        'track_max_height': {'enabled': false, 'value': 300},
        'track_height': 140.0,
        'feature_height': 12.0,
        'label_font_size': 12.0,
        'label_color': Colors.grey,
        'show_label': true,
        'track_color': Colors.blue,
        'feature_group_color': Color(0x6dc8d3c9),
        "featureStyles": {
          "line": {
            "name": "line",
            "id": "line",
            "color": Color(0xff575857),
            "alpha": 255,
            "visible": true,
            "height": .1,
            "radius": 0,
            "borderWidth": 0,
            "borderColor": "ff9e9e9e",
          },
          "base": {
            "name": "base",
            "id": "base",
            "color": Color(0xff2a9333),
            "alpha": 255,
            "visible": true,
            "height": 1.0,
            "radius": 2,
            "borderWidth": 0,
            "borderColor": "ff9e9e9e",
          },
          "thick": {
            "name": "thick",
            "id": "thick",
            "color": Color(0xb8cbd52c),
            "alpha": 255,
            "visible": true,
            "height": 1,
            "radius": 3,
            "borderWidth": 0,
            "borderColor": "ff9e9e9e",
          },
          "block": {
            "name": "block",
            "id": "block",
            "color": Color(0xd7e28529),
            "alpha": 255,
            "visible": true,
            "height": .8,
            "radius": 3,
            "borderWidth": 0,
            "borderColor": "ff9e9e9e",
          },
        },
      },
      'dark': {
        'track_max_height': {'enabled': false, 'value': 300},
        'track_height': 140.0,
        'feature_height': 12.0,
        'label_font_size': 12.0,
        'label_color': Colors.grey,
        'show_label': true,
        'track_color': Colors.blue,
        'feature_group_color': Color(0x6dc8d3c9),
        "featureStyles": {
          "line": {
            "name": "line",
            "id": "line",
            "color": Color(0xFF9E9E9E),
            "alpha": 255,
            "visible": true,
            "height": .1,
            "radius": 0,
            "borderWidth": 0,
            "borderColor": "ff9e9e9e",
          },
          "base": {
            "name": "base",
            "id": "base",
            "color": Color(0xff2a9333),
            "alpha": 255,
            "visible": true,
            "height": 1.0,
            "radius": 2,
            "borderWidth": 0,
            "borderColor": "ff9e9e9e",
          },
          "thick": {
            "name": "thick",
            "id": "thick",
            "color": Color(0xb8cbd52c),
            "alpha": 255,
            "visible": true,
            "height": 1,
            "radius": 3,
            "borderWidth": 0,
            "borderColor": "ff9e9e9e",
          },
          "block": {
            "name": "block",
            "id": "block",
            "color": Color(0xd7e28529),
            "alpha": 255,
            "visible": true,
            "height": .8,
            "radius": 3,
            "borderWidth": 0,
            "borderColor": "ff9e9e9e",
          },
        },
      }
    }, Brightness.light);
  }

  @override
  BedStyle copy() {
    return BedStyle(copySourceMap(), brightness);
  }
}