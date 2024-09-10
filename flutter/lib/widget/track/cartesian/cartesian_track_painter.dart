import 'package:d4/d4.dart' as d4;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/chart/scale/value_sale_type.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_data.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/monotone.dart';
import 'dart:math' show pi, max, pow, log, exp;
import 'package:flutter_smart_genome/widget/track/cartesian/ticker_paint_mixin.dart';

enum CartesianChartType {
  bar,
  linear,
  area,
  heatmap,
  plot,
}

enum StackMode {
  stack,
  overlap,
}

typedef void TooltipPainter(Canvas canvas, Rect barRect, CartesianDataItem _selectedItem, d4.Scale<num, num> valueScale);

typedef R TooltipMapper<R, D>(D item);

class RenderShape {
  Color? color;
  Rect rect;

  RenderShape(this.color, this.rect);
}

class RectShape extends RenderShape {
  RectShape({Color? color, required Rect rect}) : super(color, rect);
}

class CircleShape extends RenderShape {
  CircleShape({Color? color, required Rect rect, required this.radius}) : super(color, rect);
  double radius;
}

class Segment {
  late List<Rect> bars;

  Segment() {
    bars = [];
  }

  int get length => bars.length;

  void add(Rect bar) {
    bars.add(bar);
  }

  Path? getSegPath(int direction) {
    if (bars.length == 0) return null;

    if (length == 1) {
      var left = direction > 0 ? bars.first.topLeft : bars.first.bottomLeft;
      var right = direction > 0 ? bars.first.topRight : bars.first.bottomRight;
      return Path()
        ..moveTo(left.dx, left.dy)
        ..lineTo(right.dx, right.dy);
    } else if (length == 2) {
      var left = direction > 0 ? bars.first.topLeft : bars.first.bottomLeft;
      var right = direction > 0 ? bars.last.topRight : bars.last.bottomRight;
      return Path()
        ..moveTo(left.dx, left.dy)
        ..lineTo(right.dx, right.dy);
    }

    List<Offset> points = bars.map((bar) => direction > 0 ? bar.topCenter : bar.bottomCenter).toList();
    Path path = MonotoneX.addCurve(Path()..moveTo(points.first.dx, points.first.dy), points);
    return path;
  }

  Path? getSegAreaPath(int direction) {
    if (bars.length == 0) return null;
    if (length == 1) {
      return Path()..addRect(bars.first);
    } else if (length == 2) {
      return Path()
        ..addRect(bars.first)
        ..addRect(bars.last);
    }

    Path path = Path();
    // if(direction > 0){
    path.moveTo(bars.first.topCenter.dx, bars.first.topCenter.dy);
    MonotoneX.addCurve(path, bars.map((e) => e.topCenter).toList());
    path.lineTo(bars.last.bottomCenter.dx, bars.last.bottomCenter.dy);
    MonotoneX.addCurve(path, bars.map((e) => e.bottomCenter).toList(), true);
    // }else{
    //
    // }
    path.close();
    return path;
  }

  @override
  String toString() {
    return 'Segment{bars: $bars}';
  }
}

class Segments {
  late List<Segment> segments;

  Segment? current;

  Segments() {
    segments = [Segment()];
  }

  void addRect(Rect rect) {
    if (current == null) {
      current = Segment();
      segments.add(current!);
    }
    current!.add(rect);
  }

  void broken() {
    current = null;
  }

  void finish() {}

  int get length => segments.length;

  void add(Segment segment) {
    segments.add(segment);
  }

  Segment operator [](i) {
    return segments[i];
  }

  @override
  String toString() {
    return 'Segments{segments: $segments}';
  }
}

abstract class CartesianTrackPainter<D extends CartesianData, C extends StyleConfig> extends AbstractTrackPainter<D, C> with TickerPainterMixin {
  ValueScaleType? valueScaleType;
  double? customMaxValue;
  late LogType logType;

  CartesianTrackPainter({
    required super.trackData, // may be data in a range
    required super.styleConfig,
    required super.scale, // the scale by the hole chromosome
    super.orientation,
    super.selectedItem,
    required super.visibleRange,
    double? height,
    super.onItemTap,
    this.chartType = CartesianChartType.bar,
    this.valueScaleType = ValueScaleType.LINEAR,
    this.customMaxValue,
    super.cursor,
    this.logType = LogType.LOG10,
  }) : super() {
    trackPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1
      ..isAntiAlias = true;

    bgPaint = Paint();

    selectedPaint = Paint()
      ..color = styleConfig.selectedColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    maxHeight = height ?? 120;
  }

  late CartesianChartType chartType;
  Paint? trackPaint;
  Paint? selectedPaint;
  Paint? bgPaint;
  late Rect trackRect;
  List<int> visibleRangeIndex = [];

  late num _rulerMaxValue;
  late d4.Scale<num, num> _valueScale;
  bool hasNegativeValue = false;
  Path? barPath;
  List<num> _valueRange = [0, 0];

  List<num> get valueRange => _valueRange;

  d4.Scale<num, num> get valueScale => _valueScale;

  void set valueScale(d4.Scale<num, num> scale) => _valueScale = scale;

  num get maxValue => _valueRange.last;

  void set maxValue(num value) => _valueRange.last = value;

  // num _minValue = 0;
  num get minValue => _valueRange.first;

  void set minValue(num min) => _valueRange.first = min;

  bool useAbsLog = true; // 直接将只做log运算后， 进行UI 高度 的线性scale

  bool get isAbsLogScale => useAbsLog && valueScaleType == ValueScaleType.LOG && !hasNegativeValue;

  @override
  void initWithSize(Size size) {
    var _trackRect = Rect.fromLTWH(0, 0, size.width, maxHeight!);
    trackRect = styleConfig.padding != null ? styleConfig.padding!.deflateRect(_trackRect) : _trackRect;
    super.initWithSize(size);
  }

  // Map<int, RenderShape> renderShapeMap = {};

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
    drawBackground(canvas, size);
    if (trackData.isEmpty) return;
    calculateItemRect(trackRect, size);
    drawHorizontalTrack(canvas, trackRect, size);
    drawHorizontalAxis(canvas, trackRect, size);
    drawSelectedItem(canvas, selectedItem, _valueScale);
  }

  d4.Scale<num, num> adjustValueScaleType({double? height, List<num>? values, List<double>? range}) {
    final maxHeight = height ?? (hasNegativeValue ? trackRect.height / 2 : trackRect.height);
    d4.Scale<num, num> _valueScale;
    var numericExtents = values ?? List.from(niceRange);
    var scaleOutputExtent = range ?? [0, maxHeight];
    switch (valueScaleType) {
      case ValueScaleType.LINEAR:
        _valueScale = d4.ScaleLinear.number(domain: numericExtents, range: scaleOutputExtent);
        break;
      case ValueScaleType.LOG:
        if (isAbsLogScale) {
          var _s = d4.ScaleLog.number(domain: numericExtents, range: [0, 1]);
          var p = _s.scale(1)!.toDouble();
          if (numericExtents.first >= 1) {
            // scaleOutputExtent = [maxHeight * p, maxHeight * (1 - p)];
            scaleOutputExtent = [0, maxHeight];
          } else if (numericExtents.last <= 1) {
            // scaleOutputExtent = [maxHeight * p, maxHeight * (1 - p)];
            scaleOutputExtent = [-maxHeight, 0];
          } else {
            scaleOutputExtent = [-maxHeight * p, maxHeight * (1 - p)];
          }
          _valueScale = d4.ScaleLog.number(domain: numericExtents, range: scaleOutputExtent);
        } else {
          // scaleOutputExtent = [-maxHeight / 2, maxHeight / 2];
          _valueScale = scaleLogFixed(domain: numericExtents, range: scaleOutputExtent);
        }
        break;
      case ValueScaleType.POW_HALF:
        _valueScale = d4.ScalePow.number(domain: numericExtents, range: scaleOutputExtent)..exponent = .5;
        break;
      default:
        _valueScale = d4.ScaleLinear.number(domain: numericExtents, range: scaleOutputExtent);
        break;
    }
    return _valueScale;
  }

  Color itemColor(C styleConfig, CartesianDataItem item) => Colors.blue;

  Color? scaleColor(Color? color, num value) {
    if (null == color) return color;
    if (valueScaleType == ValueScaleType.LOG || valueScaleType == ValueScaleType.POW_HALF) {
      return color.withAlpha((_valueScale.call(value.abs())! / _valueScale.call(maxValue)! * 255).toInt());
    }
    return color;
  }

  void drawHorizontalAxis(Canvas canvas, Rect trackRect, Size size) {
    drawAxis(
      canvas: canvas,
      trackRect: trackRect,
      size: size,
      tickers: findConformtableTickers(trackRect, valueScale: _valueScale),
      styleConfig: styleConfig,
      drawText: drawText,
    );
  }

  void drawVerticalTrack(Canvas canvas, Rect trackRect, Size size);

  void drawHorizontalTrack(Canvas canvas, Rect trackRect, Size size);

  num countingMaxValue() {
    var _max = (max(trackData.maxValue.abs(), trackData.minValue.abs()) * 1.25);
    if (_max == 0) _max = 1.0;
    return _max;
  }

  void calculateItemRect(Rect trackRect, Size size) {
    CartesianData _barData = trackData;
    hasNegativeValue = _barData.dataSource!.any((f) => (f.value ?? 0) < 0);
    if (trackData.isEmpty) return;
    barPath = Path();
    _valueRange.last = customMaxValue ?? countingMaxValue();
    setTickerRange(_valueRange, hasNegativeValue: hasNegativeValue);
    _valueScale = adjustValueScaleType();
    var range = scale.range;
    double barWidth = scale.rangeWidth / _barData.size;
    bool hasRange = _barData.hasRange;
    Rect _rect;
    double top;
    double padding = 0;
    double left, right;
    CartesianDataItem dataItem;

    if (hasNegativeValue) {
      num bottom = trackRect.center.dy;
      for (int i = 0; i < _barData.size; i++) {
        dataItem = _barData[i];
        double valueHeight = valueScale.call(dataItem.value.abs()) as double;
        if (dataItem.value < 0) valueHeight = -valueHeight;
        top = bottom - valueHeight;
        left = hasRange ? scale[dataItem.start!] as double : scale.rangeMin + i * barWidth + padding;
        right = hasRange ? scale[dataItem.end!] as double : left + barWidth;
        if (styleConfig.fixValue) {
          left = left.ceilToDouble();
          right = right.ceilToDouble();
        }
        _rect = Rect.fromLTWH(left, top, right - left - padding, valueHeight);
        var shape = RectShape(color: scaleColor(itemColor(styleConfig, dataItem), dataItem.value)!, rect: _rect);
        // renderShapeMap[i] = shape;
        dataItem.renderShape = shape;
        barPath!.addRect(_rect);
      }
    } else {
      for (int i = 0; i < _barData.size; i++) {
        dataItem = _barData[i];
        double valueHeight = valueScale.call(dataItem.value) as double;
        top = trackRect.bottom - valueHeight;
        left = hasRange ? scale[dataItem.start!] as double : scale.rangeMin + i * barWidth + padding;
        right = hasRange ? scale[dataItem.end!] as double : left + barWidth;
        if (styleConfig.fixValue) {
          left = left.ceilToDouble();
          right = right.ceilToDouble();
        }
        _rect = Rect.fromLTRB(left, top, right, trackRect.bottom);
        var shape = RectShape(color: scaleColor(itemColor(styleConfig, dataItem), dataItem.value)!, rect: _rect);
        // renderShapeMap[i] = shape;
        dataItem.renderShape = shape;
        barPath!.addRect(_rect);
      }
    }
  }

  void drawSelectedItem(Canvas canvas, CartesianDataItem? _selectedItem, d4.Scale<num, num> valueScale) {
    if (_selectedItem == null) return;
    RenderShape? _renderShape = _selectedItem.renderShape;
    if (_renderShape == null) return;

    Rect _rect = _renderShape.rect;
    canvas.drawRect(_rect, selectedPaint!);
    canvas.drawLine(_rect.bottomCenter, Offset(_rect.center.dx, 5), selectedPaint!);

    TextStyle _style = TextStyle(
      fontSize: 13,
      color: styleConfig.isDark ? Colors.white70 : Colors.black54,
      fontFamily: MONOSPACED_FONT,
      fontFamilyFallback: MONOSPACED_FONT_BACK,
    );
    String _text = '${_selectedItem.tooltip}';

    TextPainter textPainter = TextPainter(
      text: TextSpan(text: _text, style: _style),
      textDirection: TextDirection.ltr,
    )..layout();
    double _tipWidth = textPainter.width;
    double _height = textPainter.height;

    var _tooltipRect = Rect.fromLTWH(_rect.topCenter.dx - _tipWidth / 2, 5, _tipWidth, _height + 4);
    if (_tooltipRect.right > rect.right) {
      _tooltipRect = _tooltipRect.translate(rect.right - _tooltipRect.right, 0);
    }
    if (_tooltipRect.left < rect.left) {
      _tooltipRect = _tooltipRect.translate(rect.left - _tooltipRect.left, 0);
    }
    var __tooltipRect = RRect.fromRectAndRadius(_tooltipRect.inflate(4), Radius.circular(3));
    if (!kIsWeb) canvas.drawShadow(Path()..addRRect(__tooltipRect), selectedPaint!.color, 8, true);
    canvas.drawRRect(__tooltipRect, selectedPaint!);
    canvas.drawRRect(
        __tooltipRect,
        bgPaint!
          ..style = PaintingStyle.stroke
          ..color = styleConfig.primaryColor!);
    drawText(
      canvas,
      text: _text,
      style: _style,
      offset: _tooltipRect.topLeft,
      textAlign: TextAlign.start,
      width: _tipWidth,
    );
  }

  void drawBackground(Canvas canvas, Size size) {
    if (styleConfig.backgroundColor != null) {
      canvas.drawRect(rect, bgPaint!..color = styleConfig.backgroundColor!);
    }
  }

  double get valueMaxSize => orientation == Axis.vertical ? trackRect.width : trackRect.height;

  @override
  bool painterChanged(AbstractTrackPainter painter) {
    return super.painterChanged(painter);
  }

  @override
  dynamic findHitItem(Offset position) {
    int index = trackData.dataSource!.indexWhere((item) {
      Rect rect = item.renderShape.rect;
      return position.dx >= rect.left && position.dx <= rect.right;
//      return rect.contains(position);
    });
    hitItem = index >= 0 ? trackData[index] : null;
    hitRect = index >= 0 ? trackData.dataSource![index].renderShape.rect : null;
    // print('hit item $hitItem ${index} ${hitRect}');
    return index;
  }

  @override
  bool hitTest(Offset position) {
    int index = findHitItem(position);
    if (index >= 0) return true;
//    return false; //不能return false， 否则事件没法传递
    return super.hitTest(position);
  }

  paintToolTip(CartesianDataItem item) {}
}
