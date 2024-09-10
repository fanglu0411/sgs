import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_genome/extensions/common_extensions.dart';

///
/// this class persist theme style config
/// support dark/light brightness, and auto switch
///
class BasePersistStyle {
  late Brightness brightness;
  bool useBrightness = true;

  Map __persistStyleMap = {};

  /// from persist map
  BasePersistStyle(this.__persistStyleMap, [this.brightness = Brightness.light, this.useBrightness = true]) {}

  BasePersistStyle.from({
    this.brightness = Brightness.light,
    Map? darkStyleMap,
    required Map lightStyleMap,
  }) {
    __persistStyleMap = {
      'dark': darkStyleMap ?? Map.from(lightStyleMap),
      'light': lightStyleMap,
    };
  }

  BasePersistStyle.empty(Brightness brightness) {
    this.brightness = brightness;
    __persistStyleMap = {
      'dark': <dynamic, dynamic>{
        // 'colorMap': {},
      },
      'light': <dynamic, dynamic>{
        // 'colorMap': {},
      },
    };
  }

  Map get styleMap {
    // if (!useBrightness) return __persistStyleMap;
    String _brightness = brightness == Brightness.dark ? 'dark' : 'light';
    return __persistStyleMap[_brightness];
  }

  Map get lightStyleMap => __persistStyleMap['light'];

  Map get darkStyleMap => __persistStyleMap['dark'];

  Map<String, Color>? getColorMap(String key) {
    Map? _map = styleMap[key];
    return _map?.map<String, Color>((key, value) => MapEntry('$key', _parseColor(value)!));
  }

  void setColorMap(String key, Map<String, Color> colorMap) {
    styleMap[key] = colorMap;
  }

  List get colorMapListKeys => styleMap.keys.where((k) => '$k'.startsWith('color_map')).toList();

  Color? getColor(String key) {
    var value = this[key];
    return _parseColor(value);
  }

  bool containsKey(String key) => styleMap.containsKey(key);

  Color? _parseColor(value) {
    if (value == null) return null;
    if (value is Color) return value;
    if (value is int) {
      return Color(value);
    }
    Color _c = Color(int.parse('${value}', radix: 16));
    return _c;
  }

  /// @key support [.] eg: a.b.color
  void setColor(String key, Color color) {
    List arr = key.split('.');
    if (arr.length == 1) {
      styleMap[key] = color.value;
      return;
    }

    Map map = this[arr.sublist(0, arr.length - 1).join('.')];
    map[arr.last] = color.value;
  }

  dynamic operator [](String k) {
    return getValue(k, brightness);
  }

  dynamic get(String key) {
    return getValue(key, brightness);
  }

  void addItem(String key, value) {
    List arr = key.split('.');
    if (arr.length == 1) {
      lightStyleMap[key] = value;
      darkStyleMap[key] = value;
      return;
    }
    Map map = getValue(arr.sublist(0, arr.length - 1).join('.'), Brightness.light);
    map[arr.last] = value;
    Map map2 = getValue(arr.sublist(0, arr.length - 1).join('.'), Brightness.dark);
    map2[arr.last] = value;
  }

  void deleteItem(String key) {
    List arr = key.split('.');
    if (arr.length == 1) {
      lightStyleMap.remove(key);
      darkStyleMap.remove(key);
      return;
    }
    Map map = getValue(arr.sublist(0, arr.length - 1).join('.'), Brightness.light);
    map.remove(arr.last);
    Map map2 = getValue(arr.sublist(0, arr.length - 1).join('.'), Brightness.dark);
    map2.remove(arr.last);
  }

  ///@k support [.] eg: a.b.foo
  dynamic getValue(String? k, Brightness brightness) {
    if (k == null) return null;
    List arr = k.split('.');
    int i = 0;
    var v = null; //= styleMap[arr[i]];
    if (v == null && brightness == Brightness.light) {
      v = lightStyleMap[arr[i]] ?? darkStyleMap[arr[i]];
    } else if (v == null && brightness == Brightness.dark) {
      v = darkStyleMap[arr[i]] ?? lightStyleMap[arr[i]];
    }

    if (v == null) return null;

    while (++i < arr.length && v is Map) {
      v = v[arr[i]];
    }
    return v;
  }

  operator []=(k, value) {
    if (k == null) return;
    styleMap[k] = value;
  }

  Map<String, Color> toColorMap([String? key]) {
    Map _map = null != key ? styleMap[key] : styleMap;
    return _map.map<String, Color>((key, value) => MapEntry(key, _parseColor(value)!));
  }

  Map toPersistMap([Map? map]) {
    return (map ?? __persistStyleMap).map((key, value) {
      return MapEntry(key, _persistMap(value));
    });
  }

  Map get json => __persistStyleMap;

  Map _persistMap(Map map) {
    return map.map((key, value) {
      var _value = value;
      if (value is Map) {
        _value = _persistMap(value);
      } else if (value is Color) {
        _value = value.hexString;
      }
      return MapEntry(key, _value);
    });
  }

  Map get persistMap => __persistStyleMap;

  BasePersistStyle copy() {
    return BasePersistStyle(toPersistMap(), brightness);
  }

  Map copySourceMap() {
    return copyMap(__persistStyleMap);
  }

  Map copyMap(Map map) {
    return map.map((key, value) {
      var _value = value;
      if (value is Map) {
        _value = copyMap(value);
      }
      return MapEntry(key, _value);
    });
  }

  BasePersistStyle merge(BasePersistStyle? persistStyle) {
    if (null == persistStyle) {
      return this;
    }
    _mergeMap(__persistStyleMap, persistStyle.__persistStyleMap);
    return this;
    // Map map = Map.from(__persistStyleMap);
    // map = _mergeMap(map, persistStyle.__persistStyleMap);
    // __persistStyleMap
    // return BasePersistStyle(map, brightness);
  }

  Map _mergeMap(Map map1, Map map2) {
    map2.forEach((key, value) {
      if (map1.containsKey(key) && value is Map) {
        map1[key] = _mergeMap(map1[key], value);
      } else {
        map1[key] = value;
      }
    });
    return map1;
  }

  @override
  String toString() {
    return 'BasePersistStyle{$styleMap}';
  }
}