import 'package:dartx/dartx.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_data.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_track_painter.dart';
import '../common.dart' as cm;

class PositionDataItem<S extends RenderShape> extends CartesianDataItem<num, Feature, S> {
  num value2;

  PositionDataItem(super.index, super.value, this.value2, {super.source, super.start, super.end});

  @override
  String get tooltip {
    return 'Position: ${start}\n       p: ${value}';
  }

  @override
  String toString() {
    return '${source},renderShape: ${renderShape}';
  }
}

class PositionedData<SH extends RenderShape> extends CartesianData<PositionDataItem<SH>, Feature> {
  PositionedData({
    required List<Feature> values,
    super.track,
    Scale<num, num>? scale,
    cm.Range? visibleRange,
    super.hasRange = false,
    super.message,
  }) : super() {
    initData(values, track, scale, visibleRange);
  }

  num minValue2 = 0;
  num maxValue2 = 0;

  int get size => dataSource?.length ?? 0;

  PositionDataItem<SH> operator [](index) {
    return dataSource![index];
  }

  @override
  void clear() {
    dataSource?.clear();
  }

  @override
  PositionDataItem<SH> combineValueMapper(int index, List<Feature> list) {
    throw UnimplementedError();
  }

  @override
  void initData(List<Feature> values, Track? track, Scale<num, num>? scale, cm.Range? dataRange) {
    super.initData(values, track, scale, dataRange);
    maxValue = this.dataSource!.length > 0 ? this.dataSource!.maxBy((e) => e.value)!.value : 0;
    minValue = this.dataSource!.length > 0 ? this.dataSource!.minBy((e) => e.value)!.value : 0;

    maxValue2 = this.dataSource!.length > 0 ? this.dataSource!.maxBy((e) => e.value)!.value2 : 0;
    minValue2 = this.dataSource!.length > 0 ? this.dataSource!.minBy((e) => e.value)!.value2 : 0;
  }

  @override
  PositionDataItem<SH> valueMapper(int index, Feature value) {
    return PositionDataItem(
      index,
      value['p'] ?? value['p_value'],
      value['p'] ?? value['p_value'],
      start: value['bp'],
      end: value['bp'] + 1,
      source: value,
    );
  }
}
