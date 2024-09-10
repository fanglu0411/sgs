import 'dart:math' as math;

import 'package:d4/d4.dart' as d4;
import 'package:dartx/dartx.dart' as dx;
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/axis_direction.dart';

mixin TickerPainterMixin {
  List<num> _tickerRange = [0, 0];
  int tickerCount = 5;

  List<num> _niceRange = [0, 0];

  List<num> get niceRange => _niceRange;

  List<num> get tickerRange => _tickerRange;

  // void set tickerRange(List<num> range) => _tickerRange = List.from(range);

  void setTickerRange(List<num> range, {bool nice = true, bool hasNegativeValue = false, int ticks = 5}) {
    var dom = nice ? d4.nice(range.first, range.last, ticks) : (range.first, range.last);
    var (min, count) = hasNegativeValue ? (-dom.$2, ticks * 2) : (dom.$1, ticks);
    tickerCount = count;
    _tickerRange = [min, dom.$2];
    _niceRange = [dom.$1, dom.$2];
  }

  (num min, num max) logNice(List<num> range) {
    var _nice = d4.nice(range.first, range.last, 5);
    if (range.first > 1) {
      range.first = 1;
      range.last = _nice.$2;
    } else if (range.last < 1) {
      range.first = range.first * .75;
      range.last = 1;
    } else {
      range.last = _nice.$2;
    }
    return (range.first, range.last);
  }

  /// make tickers
  List<TickItem> findConformtableTickers(
    Rect rect, {
    d4.Scale<num, num>? valueScale,
  }) {
    var ts = valueScale != null && valueScale is d4.ScaleLog ? [valueScale.domain.first, valueScale.domain.last] : d4.ticks(_tickerRange.first, _tickerRange.last, tickerCount);
    if (ts.length <= 1) return [];
    double x = rect.center.dx;
    double _startY = valueScale != null ? rect.top + valueScale.call(valueScale.domain.last)!.toDouble() : rect.bottom;
    double valueSize = rect.height * (1 / (_tickerRange.last - _tickerRange.first));
    double interval = (ts.second - ts.first).toDouble();
    double tickerSize = interval * valueSize;

    return ts.mapIndexed((i, t) {
      var offset = valueScale != null
          ? Offset(x, _startY - valueScale.call(t)!) //
          : Offset(x, _startY - tickerSize * i);
      return TickItem(
        t,
        valueScale?.call(t) ?? t,
        offset,
        tickerSize,
        showLabel: ts.length <= 2 || tickerSize >= 20 || (i % 2 == 0),
      );
    }).toList();
  }

  // draw axis and tickers
  void drawAxis({
    required Canvas canvas,
    required Rect trackRect,
    required Size size,
    required List<TickItem> tickers,
    required StyleConfig styleConfig,
    required Function drawText,
    bool drawZeroValue = true,
  }) {
    if (tickers.length == 0) return;

    final _axisPositions = axisPositions(trackRect);
    Path path = Path()
      ..moveTo(_axisPositions[0].dx, _axisPositions[0].dy)
      ..lineTo(_axisPositions[1].dx, _axisPositions[1].dy);

    Color _color = styleConfig.brightness == Brightness.dark ? Colors.white70 : Colors.black38;

    bool _hasNegValue = tickers.any((t) => t.value < 0);

    tickers.forEachIndexed((v, index) {
      path
        ..moveTo(_axisPositions[0].dx, v.offset.dy)
        ..relativeLineTo(5, 0);

      if (!v.showLabel || (v.value == 0 && !drawZeroValue)) return;

      drawText.call(
        canvas,
        text: formatTicker(v),
        offset: Offset(_axisPositions[0].dx, v.offset.dy) + Offset(8.0, -7),
        style: TextStyle(color: _color, fontSize: 12, fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK),
        width: 100.0,
        textAlign: TextAlign.start,
      );
    });
    var paint = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, paint);
  }

  String formatTicker(TickItem tick) {
    return tick.valueStr;
  }

  List<Offset> axisPositions(Rect rect) {
    switch (SgsConfigService.get()!.axisDirection) {
      case TrackAxisDirection.left:
        return [rect.bottomLeft, rect.topLeft];
      case TrackAxisDirection.center:
        return [rect.bottomCenter, rect.topCenter];
      case TrackAxisDirection.right:
        return [rect.bottomRight, rect.topRight];
    }
  }
}

class TickItem {
  num value;
  Offset offset;
  double tickSize;
  bool showLabel;
  num scaleValue;

  String get valueStr => formatValue(value);

  String get scaledValueStr => formatValue(scaleValue);

  String formatValue(num value) {
    String label;
    if (value.abs() > 10000) {
      label = '${value ~/ 1000}k';
    } else if (value.abs() > 1000) {
      label = '${value ~/ 1000}k';
    } else if (value > 1) {
      label = value % 1 > 0 ? value.toStringAsFixed(1) : value.toStringAsFixed(0);
    } else {
      label = value.toStringAsPrecision(1);
    }
    return label;
  }

  TickItem(
    this.value,
    this.scaleValue,
    this.offset,
    this.tickSize, {
    this.showLabel = true,
  });

  @override
  String toString() {
    return 'TickItem{value: $value, ${scaleValue}, showLabel:${showLabel}, offset: $offset}';
  }
}
