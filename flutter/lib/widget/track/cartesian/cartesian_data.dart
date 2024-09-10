import 'dart:ui';

import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_track_painter.dart';
import 'package:intl/intl.dart';
import '../common.dart' as cm;
import 'dart:math' show max;

NumberFormat tooltipNumberFormat = NumberFormat("######.#####", "en_US");

abstract class CartesianDataItem<V, S, SH extends RenderShape> {
  int index;
  num? start;
  num? end;
  late V value;
  S? source;
  SH? renderShape;
  late int strand;

  Map<String, Rect> groupRectMap = {};

  CartesianDataItem(
    this.index,
    this.value, {
    this.start,
    this.end,
    this.source,
    this.strand = 1,
  });

  String get strandStr => '${strand}';

  bool get strandP => strand == 1;

  String get tooltip => hasRange ? 'Position: ${start?.toInt()} - ${end?.toInt()}\n   Value: $value' : '${value}';

  bool get hasRange => start != null && end != null;

  @override
  String toString() {
    return 'CartesianDataItem{index: $index, start: $start, end: $end, value: $value}';
  }

  String formatNumValue([int fixed = 0]) {
    String label;
    if (value is int) {
      label = '${value}';
    } else if (value is double) {
      label = (value as double).toStringAsFixed(fixed);
    } else {
      label = '${value}';
    }
    return label;
  }
}

class SimpleCartesianDataItem<T> extends CartesianDataItem<T, Map, RectShape> {
  SimpleCartesianDataItem(int index, T value, {num? start, num? end}) : super(index, value, start: start, end: end);
}

abstract class CartesianData<D, I> extends TrackData {
  CartesianData({
    Track? track,
    cm.Range? dataRange,
    this.hasRange = false,
    String? message,
  }) : super(track: track, dataRange: dataRange, message: message ?? '');

  List<D>? dataSource = [];

  num minValue = 1;
  num maxValue = 0;

  num get absMaxValue => max(minValue.abs(), maxValue.abs());

  bool hasRange = false;

  int get size => dataSource?.length ?? 0;

  Iterable<E> map<E>(E convert(D item)) {
    return dataSource!.map(convert);
  }

  D valueMapper(int index, I value);

  D combineValueMapper(int index, List<I> list);

  D operator [](i) => dataSource![i];

  void initData(List<I> values, Track? track, Scale<num, num>? scale, cm.Range? dataRange) {
    this.dataSource = values.mapIndexed<D>(valueMapper).toList();
  }

  @override
  bool operator ==(other) {
    if (!(other is CartesianData)) return false;
    if (size != other.size) return false;
    return dataSource == other.dataSource;
  }

  @override
  int get hashCode => dataSource!.length;

  @override
  bool get isEmpty {
    return dataSource == null || dataSource!.length == 0;
  }
}
