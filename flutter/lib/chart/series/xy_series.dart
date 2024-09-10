import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/chart/common/common.dart';
import 'package:flutter_smart_genome/chart/series/chart_series.dart';

abstract class XySeries<T, D> extends ChartSeries<T, D> {
  XySeries({
    required List<T> dataSource,
    required ChartValueMapper<T, D> xValueMapper,
    required ChartValueMapper<T, num> yValueMapper,
    required ChartValueMapper<T, Color> pointColorMapper,
  }) : super(
          xValueMapper: xValueMapper,
          yValueMapper: yValueMapper,
          dataSource: dataSource,
          pointColorMapper: pointColorMapper,
        );

  @override
  bool operator ==(Object other) => identical(this, other) || other is XySeries && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}