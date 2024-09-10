import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/chart/base/chart_theme.dart';
import 'package:flutter_smart_genome/chart/painter/base_painter.dart';
import 'package:flutter_smart_genome/chart/series/xy_series.dart';

abstract class SeriesPainter extends BasePainter {
  EdgeInsets? seriesPadding;
  ValueNotifier<Offset>? courserValue;

  SeriesPainter({
    required ChartTheme theme,
    this.seriesPadding = EdgeInsets.zero,
    XySeries<dynamic, dynamic>? series,
    List<XySeries<dynamic, dynamic>>? seriesList,
    this.courserValue,
  }) : super(theme: theme) {
    if (seriesList != null) {
      this.series = seriesList;
    } else {
      this.series = [
        if (series != null) series,
      ];
    }
  }

  late List<XySeries<dynamic, dynamic>> series;
  Size? _size;

  @override
  void paint(Canvas canvas, Size size) {
    if (seriesPadding != EdgeInsets.zero) {
      _size = Size(size.width - seriesPadding!.horizontal, size.height - seriesPadding!.vertical);
    } else {
      _size = size;
    }
    renderChartSeries(canvas, Rect.fromLTWH(seriesPadding!.left, seriesPadding!.top, _size!.width, _size!.height));
  }

  renderChartSeries(Canvas canvas, Rect rect);

  @override
  bool shouldRepaint(SeriesPainter oldDelegate) {
    if (series.length != oldDelegate.series.length) {
      return true;
    }
    return listEquals(series, oldDelegate.series);
  }
}