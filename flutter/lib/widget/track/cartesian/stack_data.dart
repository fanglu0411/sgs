import 'dart:ui';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_track_painter.dart';
import 'dart:math' show max, min;

import '../common.dart' as cm;
import 'cartesian_data.dart';

class StackDataItem extends CartesianDataItem<Map<String, num>, Map, RectShape> {
  num bgValue;

  StackDataItem(
    int index,
    Map<String, num> valueMap, {
    super.start,
    super.end,
    this.bgValue = 0,
    super.source,
    super.strand = 1,
  }) : super(index, valueMap);

  List<String> get groups => value.keys.toList();

  num? _sum;

  num operator [](String key) {
    return value[key] ?? 0;
  }

  num sum([String? extra]) {
    if (_sum != null) return _sum!;
    _sum = 0;
    value.forEach((key, value) {
      if (key != extra) _sum = _sum! + (value);
    });
    return _sum!;
  }

  num max([String? extra]) {
    return value.map((key, value) => MapEntry(key, key == extra ? 0 : value)).values.max()!;
  }

  num min([String? extra]) {
    return (extra != null ? value.filterKeys((k) => k != extra) : value).values.filter((e) => e != 0).min() ?? 0;
    // return value.map((key, value) => MapEntry(key, key == extra ? 0 : value)).values.min()!;
  }

  String formatValue(var value) {
    if (value is num) {
      return tooltipNumberFormat.format(value);
      if (value == 0) return '0';
      if (value is int) return '${value}';
      if (value % 1 == 0) return '${value.toInt()}';
      return value.toStringAsFixed(5);
    }
    return '$value';
  }

  String formatKey(String key, [int maxLength = 5]) {
    return key.padLeft(maxLength, ' ');
  }

  String get tooltip => value.map((key, value) => MapEntry(key, '${formatKey(key)}: ${formatValue(value)}')).values.join('\n');
}

class StackData extends CartesianData<StackDataItem, Map> {
  String? coverage;
  late bool saveSourceData;
  num coverageMaxValue = 0;
  num coverageMinValue = 0;

  num get absCoverageMaxValue => max(coverageMaxValue.abs(), coverageMinValue.abs());

  late num groupMaxValue;
  late num groupMinValue;

  num get absGroupMaxValue => max(groupMaxValue.abs(), groupMinValue.abs());

  /// use same scale to coverage and stack item
  bool? useSameScale;

  bool get hasCoverage => coverage != null;

  Map<String, List<Rect>>? groupSegments;

  StackData({
    required List<Map> values,
    super.track,
    Scale<num, num>? scale,
    super.dataRange,
    super.hasRange,
    this.coverage,
    this.saveSourceData = false,
    this.useSameScale = true,
    super.message,
  }) {
    initData(values, track, scale, dataRange);
  }

  @override
  StackDataItem valueMapper(int index, Map map) {
    num start = map['start'] ?? map['histogram_start'];
    num end = map['end'];
    // Map _map = {...map}..remove('histogram_start')..remove('start')..remove('end')..remove('strand');
    Map valueMap = {...map['value']};
    var __coverage = hasCoverage ? (valueMap[coverage] ?? 0) : 0;
    num _coverage = __coverage is List ? __coverage.sumBy((e) => e) : __coverage;
    // if(hasCoverage) _map..remove(coverage);
    return StackDataItem(
      index,
      valueMap.map<String, num>((key, value) {
        double _v = value is List ? value.sumBy((e) => e * 1.0) : (value ?? 0) * 1.0;
        return MapEntry(key, _v);
      }),
      start: start,
      end: end,
      bgValue: _coverage,
      source: saveSourceData ? valueMap : null,
      strand: map['strand'] ?? 1,
    );
  }

  @override
  StackDataItem combineValueMapper(int index, List<Map> subList) {
    //todo
    Map<String, num> sumMap = {};
    Iterable keys = subList[0].keys;
    keys.forEachIndexed((k, i) {
      sumMap[k] = subList.sumBy((e) => e[k]);
    });
    return StackDataItem(index, sumMap);
  }

  void initData(List<Map> values, Track? track, Scale<num, num>? scale, cm.Range? dataRange) {
    super.initData(values, track, scale, dataRange);
    if (dataSource!.length == 0) return;
    if (null != coverage) {
      coverageMaxValue = dataSource!.maxBy((e) => e.bgValue)!.bgValue;
      coverageMinValue = dataSource!.map((e) => e.bgValue).filter((e) => e != 0).min() ?? 0;
      maxValue = dataSource!.maxBy((e) => e.sum(coverage))!.sum(coverage);
      minValue = dataSource!.map((e) => e.sum(coverage)).filter((e) => e != 0).min() ?? 0;
      groupMaxValue = dataSource!.maxBy((e) => e.max(coverage))!.max(coverage);
      groupMinValue = dataSource!.map((e) => e.min(coverage)).filter((e) => e != 0).min() ?? 0;
    } else {
      maxValue = dataSource!.map((e) => e.sum()).max() ?? 1;
      minValue = dataSource!.map((e) => e.sum()).filter((e) => e != 0).min() ?? 0;
      groupMaxValue = dataSource!.map((e) => e.max()).max() ?? 1;
      groupMinValue = dataSource!.map((e) => e.min()).filter((e) => e != 0).min() ?? 0;
    }
  }

  num minExceptZero(List<num> list) {
    return list.filter((e) => e != 0).min() ?? 0;
  }

  @override
  void clear() {
    dataSource?.clear();
  }
}
