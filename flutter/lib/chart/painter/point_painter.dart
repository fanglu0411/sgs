import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/chart/base/chart_theme.dart';
import 'package:flutter_smart_genome/chart/painter/series_painter.dart';
import 'package:flutter_smart_genome/chart/series/point_series.dart';

class PointPainter extends SeriesPainter {
  PointPainter({
    PointSeries<dynamic, dynamic>? series,
    required ChartTheme theme,
    EdgeInsets? seriesPadding = EdgeInsets.zero,
    ValueNotifier<Offset>? courserValue,
  }) : super(
          theme: theme,
          seriesPadding: seriesPadding,
          series: series,
          courserValue: courserValue,
        ) {
    _paint = Paint();
  }

  Paint? _paint;

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
  }

  @override
  renderChartSeries(Canvas canvas, Rect rect) {
    if (series.length == 0) return;
    //general this should be only one series
    // for this bar series is grouped support
    canvas.drawRect(rect, _paint!..color = theme.backgroundColor);
    canvas.save();
    series[0]
      ..visibleRange = rect
      ..hover = courserValue?.value
      ..render(canvas, rect.topLeft, rect.size, theme);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PointPainter oldDelegate) {
    return true;
  }
}