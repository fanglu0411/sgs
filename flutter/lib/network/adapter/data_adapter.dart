import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

import '../../widget/track/common.dart';

abstract class DataAdapter<D> {
  Track? track;
  int? trackLevel;

  late List _header;

  List get header => _header;

  Map<String, List> subHeaderMap = {};

  void set header(List header) {
    List __header = List.from(header);
    header.forEachIndexed((e, i) {
      if (e is Map) {
        String key = e.keys.first;
        __header[i] = key;
        subHeaderMap[key] = e[key];
      }
    });
    _header = __header;
  }

  void setSubFeatureHeader(String key, List header) {
    subHeaderMap[key] = header;
  }

  DataAdapter({this.track, this.trackLevel});

  Map? itemToMap(var _item, List header) {
    List item = _item;
    if (item.length != header.length) return null;
    var map = Map.fromIterables(header, item);

    /// todo 接口数据错误修正
    if (map['start'] != null && !(map['start'] is num)) return null;
    if (map['end'] != null && !(map['end'] is num)) return null;

    List _children = map['children'] ?? [];
    List? childHeader = subHeaderMap['children'];
    _children
      ..removeWhere((e) => !(e is List))
      ..removeWhere((e) => e.length == 0);
    map['children'] = _children.map<Map?>((v) => itemToMap(v, childHeader ?? header)).where((e) => e != null).toList();

    List _sub_features = map['sub_feature'] ?? map['sub_features'] ?? map['subfeature'] ?? [];
    List? subFeatureHeader = subHeaderMap['sub_feature'] ?? subHeaderMap['sub_features'] ?? subHeaderMap['subfeature'];
    _sub_features
      ..removeWhere((e) => !(e is List))
      ..removeWhere((e) => e.length == 0);
    map['sub_features'] = _sub_features.map<Map?>((v) => itemToMap(v, subFeatureHeader ?? header)).where((e) => e != null).toList();
    map
      ..remove('subfeature')
      ..remove('sub_feature');
    return map;
  }

  Map? toMap(var _item) {
    return itemToMap(_item, this.header);
  }

  bool get filterInRange => false;

  bool filterFun(D item, Range? range) {
    return true;
  }

  Iterable<D> parseFeatureData(Iterable data, {Range? range}) {
    var _data = data.map<D>(parseFeatureItem).where((e) => e != null);
    if (filterInRange) {
      _data = _data.where((d) => filterFun(d, range));
    }
    return _data;
  }

  D parseFeatureItem(var item) => parseFeatureItemInternal(toMap(item)!);

  D parseFeatureItemInternal(Map item);

  Iterable<Map> parseCartesianData(var _data, num _start, num _end, num? interval) {
    Map data = _data;
    List<String> groups = data.keys.toList().map<String>((e) => e).toSet().toList();
    List group1Data = data[data.keys.first];
    num _rangeSize = _end - _start;
    num _interval = interval ?? _rangeSize / group1Data.length;
    return group1Data.mapIndexed((index, e) {
      var _value = groups.asMap().map((i, key) => MapEntry(key, data[key][index]));
      return {
        'start': _start + index * _interval,
        'end': _start + index * _interval + _interval,
        'strand': 1,
        'value': _value,
      };
    }).toList();
  }

  Iterable<Map> parseIntervalData(Iterable data, num _start, num _end) {
    return data.map((value) => Map.fromIterables(header, [value]));
  }
}
