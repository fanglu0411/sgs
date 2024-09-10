import 'dart:ui' as ui;

import 'package:d4/d4.dart' as d4;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/chart/scale/value_sale_type.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/xy_plot_style_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/ticker_paint_mixin.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'package:dartx/dartx.dart' as dx;

class BigWigTrackPainter extends AbstractTrackPainter<FeatureData, XYPlotStyleConfig> with TickerPainterMixin {
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

  bool useAbsLog = true; // 直接将只做log运算后， 进行UI 高度 的线性scale

  bool get isAbsLogScale => useAbsLog && valueScaleType == ValueScaleType.LOG && !hasNegativeValue;

  BigWigTrackPainter({
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
    required double trackHeight,
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

    List<Feature> _visibleFeatures = trackData.features!.where((f) => inVisibleRange(f)).toList();
    trackData.features!.forEach((f) => f
      ..rect = null
      ..groupRect = null);
    if ((_visibleFeatures.length) == 0) {
      return;
    }
    hasNegativeValue = trackData.features!.any((f) => (f['value'] ?? 0) < 0);

    // if (cartesianType) {
    //   drawAsCartesian(canvas, _visibleFeatures);
    // } else {
    drawAsFeature(canvas, _visibleFeatures, hasNegativeValue);
    // if (hasNegativeValue) {
    //   drawAsFeature(canvas, _visibleFeatures, hasNegativeValue);
    // } else {
    //   _drawAsFeatureFast(canvas, _visibleFeatures, hasNegativeValue);
    // }
    // }
    drawHorizontalAxis(canvas, painterRect, size);
    checkSelectedItem(canvas);
  }

  @override
  bool onEmptyPaint(Canvas canvas, Size size) {
    //super.onEmptyPaint(canvas, size);
    return true;
  }

  List<num> _valueRange = [0, 0];

  d4.Scale<num, num>? _valueScale;
  double? _maxHeight;

  void drawAsFeature(Canvas canvas, List<Feature> visibleFeatures, bool negValue) {
    Rect _rect;
    double _height;
    Color _color;
    Rect blockRect;

    var _maxValue = customMaxValue ?? visibleFeatures.maxBy((f) => (f['value'] ?? 0).abs())?['value'] ?? 0;
    _valueRange.last = _maxValue!.abs();
    if (isAbsLogScale) {
      num _min = visibleFeatures.map((e) => e['value'] ?? 0).filter((e) => e != 0).min() ?? 0;
      _valueRange.first = _min;
      var (min, max) = logNice(_valueRange);
      _valueRange
        ..first = min
        ..last = max;
    }

    setTickerRange(_valueRange, hasNegativeValue: hasNegativeValue, nice: !isAbsLogScale);

    // bool negValue = trackData.features.any((f) => (f['value'] ?? 0) < 0);
    if (negValue) canvas.drawLine(painterRect.centerLeft, painterRect.centerRight, _paint..color = Colors.grey[100]!);
    _maxHeight = negValue ? painterRect.height / 2 : painterRect.height;

    _adjustValueScaleType();
    double _bottom = negValue ? painterRect.center.dy : painterRect.bottom;
    if (isAbsLogScale) {
      _bottom = painterRect.top + _valueScale!.scale(_valueScale!.domainMax)!;
    }
    double _left, _right;

    Map<String, Path> strandBarPaths = {
      '+': Path(),
      '-': Path(),
    };

    String _valueStrand;
    for (Feature feature in visibleFeatures) {
      feature.rect = null;
      feature.groupRect = null;

      num _value = feature['value'] ?? 0;
      _height = _valueScale!.call(_value.abs())!.toDouble(); // height 可能是负数
      if (_height.isNaN || _height == 0) continue;
      if (_height > 0 && _height < .5) _height = .5;

      _valueStrand = _height > 0 ? "+" : '-';

      _left = scale[feature.range.start]!;
      _right = scale[feature.range.end]!;
      _rect = (_value > 0)
          ? Rect.fromLTRB(_left, _bottom - _height, _right, _bottom) //
          : Rect.fromLTRB(_left, _bottom, _right, _bottom + _height);
      blockRect = Rect.fromLTRB(_left, painterRect.top, _right, painterRect.bottom);

      feature.rect = _rect;
      feature.groupRect = blockRect;
      strandBarPaths[_valueStrand]!.addRect(_rect);

      // _color = styleConfig.colorMap[_value > 0 ? '+' : '-']!;
      // drawRect(canvas, _rect, featurePaint..color = _color);
    }

    for (var strand in strandBarPaths.keys) {
      _color = styleConfig.colorMap[strand]!;
      canvas.drawPath(strandBarPaths[strand]!, featurePaint..color = _color);
    }
  }

  void _drawAsFeatureFast(Canvas canvas, List<Feature> visibleFeatures, bool negValue) {
    Rect _rect;
    double _height;
    Color _color;
    Rect blockRect;

    num _maxValue = customMaxValue ?? visibleFeatures.maxBy((f) => (f['value'] ?? 0).abs())?['value'] ?? 0;
    _valueRange.last = _maxValue.abs();
    setTickerRange(_valueRange, hasNegativeValue: hasNegativeValue);

    // bool negValue = trackData.features.any((f) => (f['value'] ?? 0) < 0);
    if (negValue) canvas.drawLine(painterRect.centerLeft, painterRect.centerRight, _paint..color = Colors.grey);
    double _bottom = negValue ? painterRect.center.dy : painterRect.bottom;
    _maxHeight = negValue ? painterRect.height / 2 : painterRect.height;
    _adjustValueScaleType();

    double _left, _right;
    int index = -1;
    Path _path = Path();
    List<Offset> points = [];
    for (Feature feature in visibleFeatures) {
      index++;
      feature.rect = null;
      feature.groupRect = null;
      // if (!inVisibleRange(feature)) continue;

      num _value = feature['value'] ?? 0;

      bool breaked = (index > 0 && visibleFeatures[index - 1].range.end < feature.range.start);
      if ((_value == 0 || breaked) && points.length > 0) {
        points.add(Offset(points.last.dx, _bottom));
        _path
          ..lineTo(points.last.dx, _bottom)
          ..close();
        canvas.drawPath(_path, featurePaint..color = styleConfig.colorMap['+']!);
        points.clear();
        _path.reset();
        if (_value == 0) continue;
      }

      _height = _valueScale!.call(_value.abs()) as double;
      // _height = _height.abs();
      if (_height < .5) _height = .5;

      _left = scale[feature.range.start]!;
      _right = scale[feature.range.end]!;
      _rect = (_value > 0)
          ? Rect.fromLTRB(_left, _bottom - _height, _right, _bottom) //
          : Rect.fromLTRB(_left, _bottom, _right, _bottom + _height);
      blockRect = Rect.fromLTRB(_left, painterRect.top, _right, painterRect.bottom);

      feature.rect = _rect;
      feature.groupRect = blockRect;
      // _color = styleConfig.colorMap[_value > 0 ? '+' : '-'];

      if (_rect.width <= 1) {
        Offset point = _rect.topCenter;
        if (points.length == 0) {
          _path.moveTo(point.dx, _bottom);
          points.add(Offset(point.dx, _bottom));
        }
        _path.lineTo(point.dx, point.dy);
        points.add(point);
      } else {
        if (points.length == 0) {
          _path.moveTo(_left, _bottom);
          points.add(Offset(_left, _bottom));
        }
        points
          ..add(Offset(_left, _rect.top))
          ..add(Offset(_right, _rect.top));
        _path
          ..lineTo(_left, _rect.top)
          ..lineTo(_right, _rect.top);
      }
      if (index == visibleFeatures.length - 1) {
        points.add(Offset(points.last.dx, _bottom));
        _path
          ..lineTo(points.last.dx, _bottom)
          ..close();
        canvas.drawPath(_path, featurePaint..color = styleConfig.colorMap['+']!);
        points.clear();
        _path.reset();
      }
    }
    // _path.addPolygon(points, true);
    // canvas.drawPath(_path, featurePaint..color = styleConfig.colorMap['+']);
  }

  void drawAsCartesian(Canvas canvas, List<Feature> visibleFeatures) {
    Rect _rect;
    double _height;
    Color _color;
    Rect blockRect;

    double _left, _right;

    List<Feature> _visibleFeatures = trackData.features!.where((f) => inVisibleRange(f)).toList();
    if ((_visibleFeatures.length) == 0) {
      return;
    }
    var _maxValue = customMaxValue ?? _visibleFeatures.maxBy((f) => (f['value'] ?? 0).abs())?['value'] ?? 0;
    _valueRange.last = _maxValue!.abs();
    setTickerRange(_valueRange, hasNegativeValue: hasNegativeValue);

    double _bottom = hasNegativeValue ? painterRect.center.dy : painterRect.bottom;
    _maxHeight = hasNegativeValue ? painterRect.height / 2 : painterRect.height;
    _adjustValueScaleType();

    int index = 0;
    bool _overflow;
    num _value;
    for (Feature feature in _visibleFeatures) {
      index++;
      feature.rect = null;
      feature.groupRect = null;

      _value = feature['value'] ?? 0;
      if (_value == 0) continue;

      _height = _valueScale!.call(_value.abs()) as double;
      //if (densityMode && _height < 0) _height = _height.abs();
      _overflow = valueScaleType == ValueScaleType.MAX_LIMIT && _maxValue! > 1000 && _value.abs() > niceRange.last;
      if (_height < .5) _height = .5;

      _left = scale[feature.range.start]!;
      _right = scale[feature.range.end]!;

      _rect = (_value > 0)
          ? Rect.fromLTRB(_left, _bottom - _height, _right, _bottom) //
          : Rect.fromLTRB(_left, _bottom, _right, _bottom + _height);

//      blockRect = feature['value'] > 0
//          ? Rect.fromLTRB(scale[feature.range.start], _bottom - _maxHeight, scale[feature.range.end], _bottom)
//          : Rect.fromLTRB(scale[feature.range.start], _bottom, scale[feature.range.end], _bottom + _maxHeight);
      blockRect = Rect.fromLTRB(_left, painterRect.top, _right, painterRect.bottom);

      feature.rect = _rect;
      feature.groupRect = blockRect;

      _color = styleConfig.colorMap[_value > 0 ? '+' : '-']!;
      _color = scaleColor(_color, _value);
//      if (!densityMode) drawRect(canvas, _blockPaint..color = styleConfig.blockBgColor, blockRect);
      drawRect(canvas, _rect, featurePaint..color = _color);
      if (_overflow) {
        double maxRadius = _rect.width / 2;
        double _radius = (_value.abs() - niceRange.last) / (_maxValue! - niceRange.last) * maxRadius;
        canvas.drawCircle(_rect.topCenter + Offset(0, -maxRadius - 2), _radius.clamp(1.0, maxRadius), featurePaint);
      }
    }
  }

  Color scaleColor(Color color, num value) {
    if (valueScaleType == ValueScaleType.LOG || valueScaleType == ValueScaleType.POW_HALF) {
      return color.withAlpha((_valueScale!.call(value.abs())! / _valueScale!.call(_valueRange.last)! * 255).toInt());
    }
    return color;
  }

  void _adjustValueScaleType() {
    // Scale<double> _valueScale;
    var domain = [...niceRange];
    var range = [0, _maxHeight!];
    switch (valueScaleType) {
      case ValueScaleType.LINEAR:
        _valueScale = d4.ScaleLinear.number(domain: domain, range: range);
        break;
      case ValueScaleType.LOG:
        if (useAbsLog) {
          var _s = d4.ScaleLog.number(domain: domain, range: [0, 1]);
          var p = _s.scale(1)!.toDouble();
          if (domain.first >= 1) {
            range = [0, _maxHeight!];
          } else if (domain.last <= 1) {
            range = [-_maxHeight!, 0];
          } else {
            range = [-maxHeight! * p, _maxHeight! * (1 - p)];
          }
          _valueScale = d4.ScaleLog.number(domain: domain, range: range);
        } else {
          _valueScale = scaleLogFixed(domain: domain, range: range);
        }
        break;
      case ValueScaleType.POW_HALF:
        _valueScale = d4.ScalePow.number(domain: domain, range: range)..exponent = .5;
        break;
      default:
        _valueScale = d4.ScaleLinear.number(domain: domain, range: range);
        break;
    }
    // return _valueScale;
  }

  void checkSelectedItem(Canvas canvas) {
    if (null == selectedItem) return;
    Feature feature = selectedItem;
    if (feature.rect == null) return;
    drawRect(canvas, feature.rect!, _selectedPaint);
    canvas.drawLine(feature.groupRect!.bottomCenter, feature.groupRect!.topCenter, _selectedPaint);
    double width = 220;
    double _height = 30;
    TextStyle _style = TextStyle(
      fontSize: 13,
      color: styleConfig.isDark ? Colors.white70 : Colors.black87,
      fontFamily: MONOSPACED_FONT,
      fontFamilyFallback: MONOSPACED_FONT_BACK,
    );
    String _text = 'Position: ${feature.range.print()}\n   Value: ${formatLabelValue(feature['value'] ?? 0, 5)} ';
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: _text, style: _style),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    width = textPainter.width;
    _height = textPainter.height;

    var _tooltipRect = Rect.fromLTWH(feature.rect!.topCenter.dx - width / 2, 5, width + 4, _height + 4);
    if (_tooltipRect.right > rect.right) {
      _tooltipRect = _tooltipRect.translate(rect.right - _tooltipRect.right, 0);
    }
    if (_tooltipRect.left < rect.left) {
      _tooltipRect = _tooltipRect.translate(rect.left - _tooltipRect.left, 0);
    }
    var __tooltipRect = RRect.fromRectAndRadius(_tooltipRect.inflate(4), Radius.circular(3));
    if (!kIsWeb) canvas.drawShadow(Path()..addRRect(__tooltipRect), _selectedPaint.color, 8, true);
    canvas.drawRRect(__tooltipRect, _selectedPaint);
    canvas.drawRRect(
        __tooltipRect,
        _bgPaint
          ..style = PaintingStyle.stroke
          ..color = styleConfig.primaryColor!);

    drawText(
      canvas,
      text: _text,
      style: _style,
      width: width,
      textAlign: TextAlign.start,
      offset: _tooltipRect.topLeft,
    );
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

  String formatLabelValue(num value, [int fixed = 5]) {
    String label;
    if (value is int || value == 0) {
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
