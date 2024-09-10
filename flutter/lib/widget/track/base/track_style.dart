import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/chart/scale/value_sale_type.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/page/track/track_ui_config_bean.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/hic/hic_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/painter/base_persist_style.dart';
import 'package:flutter_smart_genome/widget/track/relation/relation_view_type.dart';

///
///this class is a base class for the style of a single track
///
class TrackStyle extends BasePersistStyle {
  /// from persist map
  TrackStyle(Map _persistStyleMap, [Brightness brightness = Brightness.light, bool useBrightness = true]) : super(_persistStyleMap, brightness);

  TrackStyle.from({
    Brightness brightness = Brightness.light,
    Map? darkStyleMap,
    required Map lightStyleMap,
  }) : super.from(
          brightness: brightness,
          darkStyleMap: darkStyleMap,
          lightStyleMap: lightStyleMap,
        );

  TrackStyle.empty(Brightness brightness) : super.empty(brightness);

  Map<String, Color>? get colorMap => this.getColorMap('color_map');

  void set colorMap(Map<String, Color>? map) => this['color_map'] = map;

  double get trackHeight => getDouble('track_height') ?? 120.0;

  void set trackHeight(double height) => this['track_height'] = height;

  String get cartesianValueType => this['cartesian_value_type'] ?? 'mean';

  void set cartesianValueType(String type) => this['cartesian_value_type'] = type;

  EnabledValue<double> get trackMaxHeight {
    var maxHeight = this['track_max_height'];
    if (maxHeight != null && maxHeight is Map) {
      return EnabledValue<double>.fromMap(maxHeight);
    }
    return EnabledValue<double>(enabled: false, value: maxHeight ?? 600.0);
  }

  void set trackMaxHeight(EnabledValue<double> maxHeight) => this['track_max_height'] = maxHeight.json;

  Color? get trackColor => getColor('track_color');

  void set trackColor(Color? color) => this['track_color'] = color;

  double? get featureHeight => getDouble('feature_height');

  void set featureHeight(double? height) => this['feature_height'] = height;

  double get fontSize => getDouble('label_font_size') ?? 14;

  void set fontSize(double size) => this['label_font_size'] = size;

  Color? get fontColor => getColor('label_color');

  void set fontColor(Color? color) => this['label_color'] = color;

  bool get showLabel => this['show_label'] ?? false;

  void set showLabel(bool show) => this['show_label'] = show;

  bool get showChildLabel => this['show_child_label'] ?? false;

  Color? get featureGroupColor => getColor('feature_group_color');

  TrackCollapseMode get collapseMode => TrackCollapseMode.values[this['collapse_mode'] ?? 0];

  void set collapseMode(TrackCollapseMode collapseMode) => this['collapse_mode'] = collapseMode.index;

  bool get showLegends => this['show_legends'] ?? false;

  void set showLegends(bool show) => this['show_legends'] = show;

  bool get dataInCurrentView => this['data_in_current_view'] ?? false;

  void set dataInCurrentView(bool v) => this['data_in_current_view'] = v;

  double? get forceVisibleScale => this['forceFeatureScale'];

  set forceVisibleScale(double? scale) => this['forceFeatureScale'] = scale;

  CartesianChartType get cartesianChartType => CartesianChartType.values[this['cartesian_chart_type'] ?? 0];

  void set cartesianChartType(CartesianChartType type) => this['cartesian_chart_type'] = type.index;

  ValueScaleType get valueScaleType => ValueScaleType.values[this['value_scale_type'] ?? 0];

  void set valueScaleType(ValueScaleType valueScaleType) => this['value_scale_type'] = valueScaleType.index;

  bool get splitChart => this['split_chart'] ?? false;

  void set splitChart(bool split) => this['split_chart'] = split;

  EnabledValue<double> get customMaxValue {
    var v = this['custom_max_value'];
    if (v != null && v is Map) {
      return EnabledValue<double>.fromMap(v);
    }
    return EnabledValue<double>(enabled: false, value: v);
  }

  void set customMaxValue(EnabledValue<double> value) => this['custom_max_value'] = value.json;

  EnabledValue<double> get customMinValue {
    var v = this['custom_min_value'];
    if (v != null && v is Map) {
      return EnabledValue<double>.fromMap(v);
    }
    return EnabledValue<double>(enabled: false, value: v ?? 0);
  }

  void set customMinValue(EnabledValue<double> value) => this['custom_min_value'] = value.json;

  void setColorMapEntry(String key, Color color) {
    if (this['color_map'] == null) this['color_map'] = {};
    this['color_map'][key] = color;
  }

  bool get hasColorMap {
    return colorMapListKeys.length > 0;
    Map? _colorMap = this.colorMap;
    return null != _colorMap && _colorMap.length > 0;
  }

  double? getDouble(String key) {
    var value = this[key];
    if (value == null) return value;
    if (value is int) {
      return value.toDouble();
    }
    return value;
  }

  List<SettingItem> toSettingList() {
    /// 这些设置不保存在theme里面
    List ignoreKeys = [
      'track_max_height',
      'collapse_mode',
      'show_label',
      'show_child_label',
      // 'cartesian_chart_type',
      'value_scale_type',
      'show_legends',
      'density_mode',
      'custom_max_value',
      'custom_min_value',
      'max_value',
    ];
    Map<String, TrackContextMenuKey> _contextKeyMap = menuKeyMap.map<String, TrackContextMenuKey>((key, value) => MapEntry(value, key));
    Iterable settingKeys = styleMap.keys.where((element) => !ignoreKeys.contains(element));
    List<SettingItem> settings = TrackMenuConfig.fromKeys(settingKeys
        .map<TrackContextMenuKey?>((e) {
          if ('$e'.startsWith('color_map')) return TrackContextMenuKey.color_map;
          return _contextKeyMap[e];
        })
        .where((e) => e != null)
        .toList());
    registerSettings(settings);
    return settings;
  }

  /// set style from setting items
  fromSettings(List<SettingItem> items) {
    items.forEach(fromSetting);
  }

  /// set style item from setting item
  fromSetting(SettingItem item, {SettingItem? parent, bool addIfNone = false}) {
    var value = item.value;
    // var es = [CartesianChartType , TrackCollapseMode , ValueScaleType , HicDisplayMode , HicNormalize, RelationViewType];
    if (value is Enum) {
      value = value.index;
    }
    if (parent != null) {
      var k = menuKeyMap[parent.key] ?? parent.key;
      if (this.containsKey(k) || addIfNone) {
        this[k] ??= {};
        this[k][item.key] = value;
      }
    } else {
      var k = menuKeyMap[item.key] ?? item.key;
      if (k is TrackContextMenuKey) k = k.name;
      if (this.containsKey(k) || addIfNone) {
        this[k] = value;
      }
    }
  }

  /// register value to settings
  registerSettings(List<SettingItem> settings) {
    String? settingKey;
    for (SettingItem item in settings) {
      settingKey = menuKeyMap[item.key];
      if (null == settingKey || !containsKey(settingKey)) continue;
      if (item.key == TrackContextMenuKey.color_map) {
        item.children = colorMapSettingItems();
      } else if (settingKey.contains('color')) {
        item.value = getColor(settingKey);
      } else if (settingKey == 'collapse_mode') {
        item.value = TrackCollapseMode.values[this[settingKey] ?? 0];
      } else if (settingKey == 'cartesian_chart_type') {
        item.value = CartesianChartType.values[this[settingKey] ?? 0];
      } else if (settingKey == 'cartesian_value_type') {
        item.value = this.cartesianValueType;
      } else if (settingKey == 'value_scale_type') {
        item.value = ValueScaleType.values[this[settingKey] ?? 0];
      } else if (settingKey == 'hic_display_mode') {
        item.value = HicDisplayMode.values[this[settingKey] ?? 0];
      } else if (settingKey == 'hic_normalize') {
        item.value = HicNormalize.values[this[settingKey] ?? 0];
      } else if (settingKey == 'relation_display_mode') {
        item.value = RelationViewType.values[this[settingKey] ?? 0];
      } else if (settingKey == 'stack_mode') {
        item.value = StackMode.values[this[settingKey] ?? 0];
      } else {
        item.value = this[settingKey];
      }
    }
  }

  List<SettingItem> colorMapSettingItems() {
    Map<String, Color>? _colorMap = colorMap!;
    return _colorMap.keys.map((k) {
      return SettingItem.color(title: k, key: k, value: _colorMap[k], fieldType: FieldType.row_color);
    }).toList();
  }

  void persist() async {
    // await BaseStoreProvider.get().setFeatureTheme(this);
  }

  // @override
  // String toString() {
  //   return '${this.json}';
  // }

  @override
  TrackStyle copy() {
    return TrackStyle(copySourceMap(), brightness);
  }

  TrackStyle empty() {
    return TrackStyle.empty(brightness);
  }
}

class EnabledValue<T> {
  late bool _enabled;
  T? _value;

  EnabledValue({required bool enabled, T? value}) {
    _enabled = enabled;
    _value = value;
  }

  bool get enabled => _enabled;

  T? get value => _value;

  EnabledValue.fromMap(Map map) {
    _enabled = map['enabled'];
    num a = map['value'] ?? 0;
    var d = a.toDouble();
    _value = d as T;
  }

  T? get enableValueOrNull => _enabled ? _value : null;

  Map get json => toMap();

  EnabledValue<T> copy({bool? enabled, T? value}) {
    return EnabledValue<T>(enabled: enabled ?? _enabled, value: value ?? _value);
  }

  Map toMap() {
    return {
      'enabled': _enabled,
      'value': _value,
    };
  }

  @override
  String toString() {
    return 'EnabledValue{_enabled: $_enabled, _value: $_value}';
  }
}
