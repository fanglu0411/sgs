
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_track_painter.dart';

enum TrackCollapseMode {
  expand,
  collapse,
}

class TrackUIConfigBean {
  TrackCollapseMode? trackMode;

  CartesianChartType? cartesianTrackType;

  Color? trackColor;
  double? trackHeight;

  bool showLegends = false;

  bool showLabel = true;
  double? labelFontSize;
  Color? textColor;
  Color? featureGroupBackground;

  TrackUIConfigBean.fromSettings(List<SettingItem> items) {
    items.forEach(fromSetting);
  }

  fromSetting(SettingItem item) {
    if (item.key == TrackContextMenuKey.track_collapse_mode) {
      trackMode = item.value;
    }
    if (item.key == TrackContextMenuKey.track_color) {
      trackColor = item.value;
    }
    if (item.key == TrackContextMenuKey.track_height) {
      trackHeight = item.value;
    }
    if (item.key == TrackContextMenuKey.cartesian_chart_type) {
      cartesianTrackType = item.value;
    }
    if (item.key == TrackContextMenuKey.feature_legends_visible) {
      showLegends = item.value;
    }

    if (item.key == TrackContextMenuKey.feature_group_color) {
      featureGroupBackground = item.value;
    }

    if (item.key == TrackContextMenuKey.show_label) {
      showLabel = item.value;
    }

    if (item.key == TrackContextMenuKey.label_font_size) {
      labelFontSize = item.value;
    }
    if (item.key == TrackContextMenuKey.label_font_color) {
      textColor = item.value;
    }
  }

  registerSettings(List<SettingItem> settings) {
    for (SettingItem item in settings) {
      if (item.key == TrackContextMenuKey.track_collapse_mode) {
        item.value = trackMode;
      }
      if (item.key == TrackContextMenuKey.track_color) {
        item.value = trackColor;
      }
      if (item.key == TrackContextMenuKey.track_height) {
        item.value = trackHeight;
      }
      if (item.key == TrackContextMenuKey.cartesian_chart_type) {
        item.value = cartesianTrackType;
      }
      if (item.key == TrackContextMenuKey.feature_legends_visible) {
        item.value = showLegends;
      }

      if (item.key == TrackContextMenuKey.show_label) {
        item.value = showLabel;
      }

      if (item.key == TrackContextMenuKey.label_font_size) {
        item.value = labelFontSize;
      }
      if (item.key == TrackContextMenuKey.label_font_color) {
        item.value = textColor;
      }

      if (item.key == TrackContextMenuKey.feature_group_color) {
        item.value = featureGroupBackground;
      }
    }
  }

  TrackUIConfigBean.fromMap(Map map) {
    int trackMode = map['track_mode'] ?? 0;
    int _cartesianTrackType = map['cartesian_type'] ?? CartesianChartType.bar.index;
    String _color = map['track_color'];
    String _textColor = map['text_color'] ?? 'ff000000';
    String _groupColor = map['group_color'] ?? '3000ff00';

    this.trackMode = TrackCollapseMode.values[trackMode];
    this.cartesianTrackType = CartesianChartType.values[_cartesianTrackType];
    this.trackColor = Color(int.parse(_color, radix: 16));
    this.trackHeight = map['track_height'];
    this.showLegends = map['show_legends'];
    this.showLabel = map['show_label'] ?? false;
    this.labelFontSize = map['label_font_size'] ?? 10.0;
    this.textColor = Color(int.parse(_textColor, radix: 16));
    this.featureGroupBackground = Color(int.parse(_groupColor, radix: 16));
  }
  Map toPersistMap() {
    return {
      'track_mode': trackMode?.index ?? TrackCollapseMode.expand.index,
      'cartesian_type': cartesianTrackType!.index,
      'track_color': '${trackColor!.value.toRadixString(16).padLeft(8, '0')}',
      'track_height': trackHeight,
      'show_legends': showLegends,
      'show_label': showLabel,
      'label_font_size': labelFontSize,
      'text_color': '${textColor!.value.toRadixString(16).padLeft(8, '0')}',
      'group_color': '${featureGroupBackground!.value.toRadixString(16).padLeft(8, '0')}',
    };
  }

  Map toMap() {
    return {
      'track_mode': trackMode,
      'cartesian_type': cartesianTrackType,
      'track_color': trackColor,
      'track_height': trackHeight,
      'show_legends': showLegends,
      'show_label': showLabel,
      'label_font_size': labelFontSize,
      'text_color': textColor,
      'group_color': featureGroupBackground,
    };
  }

  TrackUIConfigBean.defaultValue([List<String> tracks = const []]) {
    trackMode = TrackCollapseMode.expand;
    cartesianTrackType = CartesianChartType.bar;
    trackColor = Color(0xffac4f48);
    trackHeight = 10.0;
    showLegends = false;
    labelFontSize = 10.0;
    showLabel = false;
    textColor = Colors.black;
    featureGroupBackground = Colors.green.withAlpha(30);
  }

  @override
  String toString() {
    return 'TrackUIConfigBean{trackMode: $trackMode, cartesianTrackType: $cartesianTrackType, trackColor: $trackColor, trackHeight: $trackHeight, showLegends: $showLegends, showLabel: $showLabel, labelFontSize: $labelFontSize}';
  }
}