import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/chart/scale/value_sale_type.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/service/cache_service.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/xy_plot_style_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/monotone.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/ticker_paint_mixin.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'package:dartx/dartx.dart' as dx;

class MethylationTrackPainter extends AbstractTrackPainter<FeatureData, XYPlotStyleConfig> with TickerPainterMixin {
  late Paint _paint;
  late Paint _bgPaint;
  late Paint _blockPaint;
  late Paint _selectedPaint;

  late Paint featurePaint;

  double inflateValue = 1;

  late bool densityMode;
  late bool cartesianType;
  late ValueScaleType valueScaleType;
  bool hasNegativeValue = false;

  double? customMaxValue;

  MethylationTrackPainter({
    required super.trackData, // may be data in a range
    required super.styleConfig,
    required super.scale, // the scale by the hole chromosome
    required super.visibleRange,
    required super.track,
    super.orientation,
    super.showSubFeature,
    super.collapseMode,
    super.selectedItem,
    super.scaling,
    double? trackHeight,
    this.densityMode = false,
    this.cartesianType = false,
    this.valueScaleType = ValueScaleType.LINEAR,
    this.customMaxValue,
  }) : super(
          rowHeight: trackHeight,
        ) {
    featurePaint = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.square;

    _paint = Paint()
      ..color = Colors.green[200]!
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..strokeWidth = 1;

    _bgPaint = Paint();
    _blockPaint = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round;

    _selectedPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1
      ..isAntiAlias = true
      ..color = styleConfig.selectedColor;

    this.maxHeight = trackHeight;
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
    // if (styleConfig.backgroundColor != null) {
    //   drawRect(canvas, _bgPaint..color = styleConfig.backgroundColor, rect);
    // }

    if (trackData.isEmpty) return;
    List<Feature> _visibleFeatures = trackData.features!.where((f) => inVisibleRange(f)).toList();
    trackData.features!.forEach((f) => f
      ..rect = null
      ..groupRect = null);
    if ((_visibleFeatures.length ?? 0) == 0) {
      return;
    }
    drawAsCartesian(canvas, _visibleFeatures);
    drawHorizontalAxis(canvas, painterRect, size);
    checkSelectedItem(canvas);
  }

  drawHorizontalAxis(canvas, painterRect, size) {
    drawAxis(
      canvas: canvas,
      trackRect: painterRect,
      size: size,
      tickers: findConformtableTickers(painterRect, valueScale: _valueScale),
      styleConfig: styleConfig,
      drawText: drawText,
    );
  }

  @override
  bool onEmptyPaint(Canvas canvas, Size size) {
    //super.onEmptyPaint(canvas, size);
    return true;
  }

  List<num> _valueRange = [0, 0];

  void set _deepMaxValue(num max) => CacheService.get()!.setDeepMaxValue(trackData.track!, max);

  num get _deepMaxValue => CacheService.get()!.getDeepMaxValue(trackData.track!);

  num get rulerMaxValue => tickerRange.last;
  Scale<num, num>? _valueScale;
  Scale<num, num>? _deepValueScale;
  double? _maxHeight;

  void drawAsCartesian(Canvas canvas, List<Feature> visibleFeatures) {
    Rect _rect;
    double _height;
    Color _color;
    Rect blockRect;

    double _left, _right;

    hasNegativeValue = true;
    List<Feature> _visibleFeatures = trackData.features!.where((f) => inVisibleRange(f)).toList();
    if ((_visibleFeatures.length ?? 0) == 0) {
      return;
    }
    _valueRange.last = customMaxValue ?? _visibleFeatures.maxBy((f) => (f['value'] ?? 0).abs())?['value'] ?? 1.0;
    setTickerRange(_valueRange, hasNegativeValue: hasNegativeValue);

    _deepMaxValue = visibleFeatures.maxBy((f) => (f['deep'] ?? 0))?['deep'] ?? 0;
    // print('$_deepMaxValue');
    // bool negValue = true; //trackData.features.any((f) => (f['value'] ?? 0) < 0);
    double _bottom = hasNegativeValue ? painterRect.center.dy : painterRect.bottom;
    _maxHeight = hasNegativeValue ? painterRect.height / 2 : painterRect.height;
    _valueScale = _adjustValueScaleType();
    _deepValueScale = _adjustValueScaleType([0, _deepMaxValue]);

    Color _splitColor = styleConfig.brightness == Brightness.dark ? Colors.white38 : Colors.black38;
    if (hasNegativeValue) {
      _bgPaint
        ..color = _splitColor
        ..strokeWidth = .5;
      canvas.drawLine(painterRect.centerLeft, painterRect.centerRight, _bgPaint);
    }
    List<Offset> deepPointsP = [];
    List<Offset> deepPointsN = [];
    Color _deepColor = styleConfig.colorMap['deeps'] ?? Colors.black54;
    int index = 0;
    num _value;
    num _deep;
    int _strandValue;
    for (Feature feature in _visibleFeatures) {
      index++;
      feature.rect = null;
      feature.groupRect = null;
      _value = feature['value'] ?? 0;
      _deep = feature['deep'] ?? 0;
      if (_value == 0 && _deep == 0) continue;
      _strandValue = (feature['strand'] == '+' ? 1 : -1);
      _value *= _strandValue;

      _height = _valueScale!.scale(_value.abs()) as double;
      if (_height < .5) _height = .5;

      _left = scale[feature.range.start]!;
      _right = scale[feature.range.end]!;
      if (_right - _left < 1) _right = _left + 1;

      _rect = (_value > 0)
          ? Rect.fromLTRB(_left, _bottom - _height, _right, _bottom) //
          : Rect.fromLTRB(_left, _bottom, _right, _bottom + _height);

//      blockRect = feature['value'] > 0
//          ? Rect.fromLTRB(scale[feature.range.start], _bottom - _maxHeight, scale[feature.range.end], _bottom)
//          : Rect.fromLTRB(scale[feature.range.start], _bottom, scale[feature.range.end], _bottom + _maxHeight);
      blockRect = Rect.fromLTRB(_left, painterRect.top, _right, painterRect.bottom);
      feature.rect = _rect;
      feature.groupRect = blockRect;

      _color = styleConfig.colorMap[feature['type']]!;
      // _color = scaleColor(_color, _value);
//      if (!densityMode) drawRect(canvas, _blockPaint..color = styleConfig.blockBgColor, blockRect);
      if (_value != 0) {
        drawRect(
          canvas,
          _value > 0
              ? Rect.fromCenter(center: blockRect.center - Offset(0, blockRect.height / 4), width: blockRect.width, height: blockRect.height / 2) //
              : Rect.fromCenter(center: blockRect.center + Offset(0, blockRect.height / 4), width: blockRect.width, height: blockRect.height / 2),
          featurePaint..color = _color.withOpacity(.10),
        );
        drawRect(canvas, _rect, featurePaint..color = _color);
      }

      num deepHeight = _deepValueScale!.scale(_deep)! * _strandValue;
      Offset deepOffset = Offset(_rect.left, _bottom - deepHeight);
      if (feature.strand > 0) {
        deepPointsP.add(Offset(_rect.center.dx, deepOffset.dy));
      } else {
        deepPointsN.add(Offset(_rect.center.dx, deepOffset.dy));
      }
      canvas.drawLine(
          deepOffset,
          Offset(_rect.right, deepOffset.dy),
          featurePaint
            ..strokeWidth = 1.5
            ..color = _deepColor);
      // deepPoints.add(Offset(_rect.center.dx, deepOffset.dy));
    }

    // featurePaint
    //   ..color = _deepColor
    //   ..strokeWidth = 1.0
    //   ..style = PaintingStyle.stroke
    //   ..strokeCap = StrokeCap.round;
    // drawPath(canvas, deepPointsP);
    // drawPath(canvas, deepPointsN);
  }

  void drawPath(Canvas canvas, List<Offset> points) {
    Path path = MonotoneX.addCurve(Path()..moveTo(points.first.dx, points.first.dy), points);
    canvas.drawPath(path, featurePaint);
  }

  Color scaleColor(Color color, num value) {
    if (valueScaleType == ValueScaleType.LOG || valueScaleType == ValueScaleType.POW_HALF) {
      return color.withAlpha((_valueScale!.scale(value.abs())! / _valueScale!.scale(_valueRange.last)! * 255).toInt());
    }
    return color;
  }

  Scale<num, num> _adjustValueScaleType([List<num>? values = null]) {
    Scale<num, num> _valueScale;
    var domain = values ?? List.from(niceRange);
    var range = [.0, _maxHeight!];
    switch (valueScaleType) {
      case ValueScaleType.LINEAR:
        _valueScale = ScaleLinear.number(domain: domain, range: range);
        break;
      case ValueScaleType.LOG:
        _valueScale = scaleLogFixed(domain: domain, range: range);
        break;
      case ValueScaleType.POW_HALF:
        _valueScale = ScalePow.number(domain: domain, range: range)..exponent = .5;
        break;
      default:
        _valueScale = ScaleLinear.number(domain: domain, range: range);
        break;
    }
    return _valueScale;
  }

  void checkSelectedItem(Canvas canvas) {
    if (null == selectedItem) return;
    Feature feature = selectedItem;
    Rect? _rect = feature.rect;
    if (_rect == null) return;

    drawRect(canvas, _rect, _selectedPaint);
    canvas.drawLine(feature.groupRect!.bottomCenter, feature.groupRect!.topCenter, _selectedPaint);
    double width = 200;
    double rowHeight = 18;

    TextStyle _style = TextStyle(
      fontSize: 14,
      color: styleConfig.isDark ? Colors.white : Colors.white,
      fontFamily: MONOSPACED_FONT,
      fontFamilyFallback: MONOSPACED_FONT_BACK,
    );

    List<String> labels = [formatLabelValue(feature['value'], 2), formatLabelValue(feature['deep'], 2)];
    String maxValue = labels.maxBy((v) => '${v}'.length)!;
    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(text: maxValue, style: _style),
    )..layout();
    width = textPainter.width + 10;

    double typeRectWidth = 26;
    var _tooltipRect = Rect.fromLTWH(_rect.right, 5, width + typeRectWidth + 2, rowHeight * 2);
    if (_tooltipRect.right > rect.right) {
      _tooltipRect = _tooltipRect.translate(rect.right - _tooltipRect.right, 0);
    }
    var __tooltipRect = RRect.fromRectAndRadius(
      _tooltipRect.inflate(2),
      Radius.circular(3),
    );
    if (!kIsWeb) canvas.drawShadow(Path()..addRRect(__tooltipRect), _selectedPaint.color, 8, true);
    canvas.drawRRect(__tooltipRect, _selectedPaint);
    canvas.drawRRect(
        __tooltipRect,
        _bgPaint
          ..style = PaintingStyle.stroke
          ..color = styleConfig.primaryColor!);

    int row = 0;
    canvas.drawRect(
      Rect.fromLTWH(_tooltipRect.left, _tooltipRect.top + row * rowHeight, typeRectWidth, rowHeight),
      featurePaint..color = styleConfig.colorMap[feature['type']] ?? Colors.grey,
    );
    drawText(
      canvas,
      text: '${feature['type']}',
      offset: Offset(_tooltipRect.left, row * rowHeight + 8),
      style: TextStyle(fontSize: 10),
      width: typeRectWidth,
      textAlign: TextAlign.center,
    );

    drawText(
      canvas,
      text: labels[0],
      style: _style,
      width: width,
      textAlign: TextAlign.start,
      offset: Offset(_tooltipRect.left + typeRectWidth + 2, _tooltipRect.top + row * rowHeight + 1),
    );
    row++;
    canvas.drawRect(
      Rect.fromLTWH(_tooltipRect.left, _tooltipRect.top + row * rowHeight, typeRectWidth, rowHeight),
      featurePaint..color = styleConfig.colorMap['deeps'] ?? Colors.grey,
    );
    drawText(
      canvas,
      text: 'deep',
      offset: Offset(_tooltipRect.left, row * rowHeight + 8),
      style: TextStyle(fontSize: 10),
      width: typeRectWidth,
      textAlign: TextAlign.center,
    );
    drawText(
      canvas,
      text: labels[1],
      style: _style,
      width: width,
      textAlign: TextAlign.start,
      offset: Offset(_tooltipRect.left + typeRectWidth + 2, _tooltipRect.top + row * rowHeight + 1),
    );
  }

  String formatLabelValue(num value, [int fixed = 0]) {
    String label;
    if (value is int) {
      label = '${value}';
    } else {
      label = value.toStringAsFixed(fixed);
    }
    return label;
  }

  @override
  findHitItem(Offset position) {
    if (!trackData.hasFeature) {
      hitItem = null;
      return hitItem;
    }
    hitItem = trackData.features!.firstOrNullWhere((feature) => feature.groupRect?.contains(position) ?? false);
    return hitItem;
  }

  @override
  bool hitTest(Offset position) {
    var item = findHitItem(position);
    if (item != null) return true;
    return super.hitTest(position);
  }

  @override
  bool painterChanged(AbstractTrackPainter painter) {
    return super.painterChanged(painter);
  }
}
