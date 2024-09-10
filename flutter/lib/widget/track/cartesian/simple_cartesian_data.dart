import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_data.dart';
import '../common.dart' as cm;

class SimpleCartesianData extends CartesianData<SimpleCartesianDataItem, dynamic> {
  SimpleCartesianData({
    List<dynamic> values = const [],
    super.track,
    Scale<num, num>? scale,
    cm.Range? visibleRange,
    super.hasRange = false,
  }) : super() {
    initData(values, track, scale, visibleRange);
  }

  num minValue = 0;
  num maxValue = 0;

  int get size => dataSource?.length ?? 0;

  SimpleCartesianDataItem operator [](index) {
    return dataSource![index];
  }

  @override
  SimpleCartesianDataItem valueMapper(int index, dynamic value) {
    if (value is num) {
      return SimpleCartesianDataItem(index, value);
    } else if (value is Map) {
      return SimpleCartesianDataItem(index, value['f_num'] ?? value['value'], start: value['start'], end: value['end']);
    }
    return SimpleCartesianDataItem(index, value);
  }

  @override
  SimpleCartesianDataItem combineValueMapper(int index, List list) {
    if (hasRange) {
      List<num> valueList = list.map<num>((e) => e['f_num'] ?? e['value']).toList();
      var minStart = list.minBy((e) => e['start'])['start'];
      var maxEnd = list.maxBy((e) => e['end'])['end'];
      return SimpleCartesianDataItem(index, valueList.sum(), start: minStart, end: maxEnd);
    } else {
      List<num> values = list as List<num>;
      return SimpleCartesianDataItem(index, values.sum());
    }
  }

  @override
  void initData(List<dynamic> values, Track? track, Scale<num, num>? scale, cm.Range? visibleRange, [bool combine = false]) {
    super.initData(values, track, scale, visibleRange);
    maxValue = this.dataSource!.length > 0 ? this.dataSource!.maxBy((element) => element.value)!.value : 0;
    minValue = this.dataSource!.length > 0 ? this.dataSource!.minBy((element) => element.value)!.value : 0;
  }

  @override
  void clear() {
    dataSource?.clear();
  }
}
