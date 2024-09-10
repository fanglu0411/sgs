import 'package:flutter/material.dart';
import 'package:dartx/dartx.dart';
import 'dart:math' as math;
import 'package:flutter_smart_genome/chart/base/chart_theme.dart';
import 'package:flutter_smart_genome/chart/common/common.dart';

abstract class ChartSeries<T, D> {
  ChartSeries({
    required this.xValueMapper,
    required this.yValueMapper,
    this.dataSource,
    required this.pointColorMapper,
  });
  final List<T>? dataSource;
  final ChartValueMapper<T, D> xValueMapper;
  final ChartValueMapper<T, num> yValueMapper;
  final ChartValueMapper<T, Color> pointColorMapper;

  Offset? hover;
  Rect? visibleRange;
  Matrix4? matrix4;

  String? _type;

  String? get type => _type;

  int get length => dataSource?.length ?? 0;

  set type(String? type) {
    _type = type;
  }

  List<T>? get visibleDataSource => dataSource;

  num getMaxYValue() {
    if (dataSource == null) return 0;
    Iterable<num> values = dataSource!.mapIndexed<num>((index, e) => yValueMapper(e, index));
    return values.reduce(math.max);
  }

  void render(Canvas canvas, Offset offset, Size size, ChartTheme theme);

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChartSeries && runtimeType == other.runtimeType && dataSource == other.dataSource && _type == other._type;

  @override
  int get hashCode => dataSource.hashCode ^ _type.hashCode;
}