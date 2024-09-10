import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/chart/scale/value_sale_type.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/xy_plot_style_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/ticker_paint_mixin.dart';
import 'package:dartx/dartx.dart' as dx;
import 'group_coverage_track_data.dart';

class GroupCoverageTrackPainter extends AbstractTrackPainter<GroupCoverageTrackData, XYPlotStyleConfig> with TickerPainterMixin {
  Paint? _paint;
  Paint? _bgPaint;
  Paint? _blockPaint;
  Paint? _selectedPaint;

  Paint? featurePaint;

  double inflateValue = 1;

  bool? densityMode;
  bool cartesianType;
  late ValueScaleType valueScaleType;
  bool hasNegativeValue = false;

  double? customMaxValue;
  late bool splitMode;
  bool showLabel;
  bool showAxis;
  double _groupPadding = 10;

  List<num> _valueRange = [0, 0];

  num get _rulerMaxValue => tickerRange.last;
  Scale<num, num>? _valueScale;
  double? _maxHeight;

  ValueChanged<double>? onGetMaxValue;

  GroupCoverageTrackPainter({
    required super.trackData, // may be data in a range
    required super.styleConfig,
    required super.scale, // the scale by the hole chromosome
    required super.visibleRange,
    super.track,
    super.orientation,
    super.showSubFeature,
    super.selectedItem,
    super.collapseMode,
    required double trackHeight,
    this.densityMode = false,
    this.cartesianType = false,
    this.valueScaleType = ValueScaleType.LINEAR,
    this.customMaxValue,
    this.splitMode = true,
    this.showLabel = true,
    this.showAxis = true,
    this.onGetMaxValue,
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

  Map<String, Rect> _groupRectMap = {};

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
    if (styleConfig.backgroundColor != null) {
      drawRect(canvas, rect, _bgPaint!..color = styleConfig.backgroundColor!);
    }

    if (trackData.isEmpty) return;

    var groupMax = trackData.groupData!.map((group) {
      List<RangeFeature> list = group['data'];
      var maxItem = list.maxBy((f) => (f['value'] ?? 0).abs());
      if (maxItem != null) return maxItem['value'].abs();
      return 0;
    });
    _valueRange.last = customMaxValue ?? groupMax.max();
    setTickerRange(_valueRange, hasNegativeValue: hasNegativeValue);

    onGetMaxValue?.call(_valueRange.last.toDouble());
    int i = -1;
    var groupHeight = painterRect.height / trackData.groups.length;
    Rect _paintRect = splitMode ? Rect.fromLTWH(painterRect.left, painterRect.top, painterRect.width, groupHeight) : painterRect;
    for (Map group in trackData.groupData!) {
      i++;
      String _group = '${group['group']}';
      List list = group['data'];
      list.forEach((f) => (f as RangeFeature)
        ..rect = null
        ..groupRect = null);
      List<Feature> _visibleFeatures = list.where((f) => inVisibleRange(f)).toList() as List<Feature>;

      Rect __groupRect = splitMode ? _paintRect.translate(0, i * groupHeight) : _paintRect;
      _groupRectMap[group['group']] = __groupRect;
      if (i % 2 == 0) {
        _bgPaint!
          ..style = PaintingStyle.fill
          ..color = styleConfig.isDark ? Colors.black12 : Colors.grey[200]!;
        drawRect(canvas, __groupRect, _bgPaint!);
      }

      if (showLabel) {
        Color _color = styleConfig.brightness == Brightness.dark ? Colors.white70 : Colors.black87;
        drawText(
          canvas,
          text: _group,
          style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12, color: _color),
          offset: __groupRect.topLeft + Offset(4, 6),
        );
      }
      _drawBaseLine(canvas, __groupRect);

      // if ((_visibleFeatures?.length ?? 0) == 0) {
      //   continue;
      // }
      Rect _dataRect = splitMode && _groupPadding > 0 ? Rect.fromLTRB(__groupRect.left, __groupRect.top + _groupPadding, __groupRect.right, __groupRect.bottom) : __groupRect;

      if (cartesianType) {
        drawAsCartesian(canvas, _visibleFeatures, _dataRect);
      } else {
        hasNegativeValue = false; // trackData.features.any((f) => (f['value'] ?? 0) < 0);
        if (hasNegativeValue) {
          drawAsFeature(canvas, _visibleFeatures, hasNegativeValue, _dataRect);
        } else {
          _drawAsFeatureFast(canvas, _group, _visibleFeatures, hasNegativeValue, _dataRect);
        }
      }
      if (showAxis) drawHorizontalAxis(canvas, _dataRect, size);
      checkSelectedItem(canvas);
    }
  }

  @override
  bool onEmptyPaint(Canvas canvas, Size size) {
    //super.onEmptyPaint(canvas, size);
    return true;
  }

  void drawAsFeature(Canvas canvas, List<Feature> visibleFeatures, bool negValue, Rect painterRect) {
    Rect _rect;
    double _height;
    Color _color;
    Rect blockRect;

    // _maxValue = customMaxValue ?? visibleFeatures.maxBy((f) => (f['value'] ?? 0).abs())['value'] ?? 0;
    // _maxValue = _maxValue.abs();
    // _rulerMaxValue = _maxValue;

    // bool negValue = trackData.features.any((f) => (f['value'] ?? 0) < 0);
    if (negValue) canvas.drawLine(painterRect.centerLeft, painterRect.centerRight, _paint!..color = Colors.grey);
    double _bottom = negValue ? painterRect.center.dy : painterRect.bottom;
    _maxHeight = negValue ? painterRect.height / 2 : painterRect.height;
    _adjustValueScaleType();

    double _left, _right;

    for (Feature feature in visibleFeatures) {
      feature.rect = null;
      feature.groupRect = null;
      // if (!inVisibleRange(feature)) continue;

      num _value = feature['value'] ?? 0;
      _height = _valueScale!.scale(_value.abs())!; //_maxHeight * (_value / _maxValue);
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
      _color = styleConfig.colorMap[_value > 0 ? '+' : '-']!;

      //if (!densityMode) drawRect(canvas, _blockPaint..color = styleConfig.blockBgColor, blockRect);
      drawRect(canvas, _rect, featurePaint!..color = _color);
    }
  }

  void _drawAsFeatureFast(Canvas canvas, String group, List<Feature> visibleFeatures, bool negValue, Rect painterRect) {
    Rect _rect;
    double _height;
    Color _color;
    Rect blockRect;

    // _maxValue = customMaxValue ?? visibleFeatures.maxBy((f) => (f['value'] ?? 0).abs())['value'] ?? 0;
    // _rulerMaxValue = _maxValue;

    // bool negValue = trackData.features.any((f) => (f['value'] ?? 0) < 0);
    if (negValue) canvas.drawLine(painterRect.centerLeft, painterRect.centerRight, _paint!..color = Colors.grey);
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

      bool breakeed = (index > 0 && visibleFeatures[index - 1].range.end < feature.range.start);
      if ((_value == 0 || breakeed) && points.length > 0) {
        points.add(Offset(points.last.dx, _bottom));
        _path
          ..lineTo(points.last.dx, _bottom)
          ..close();
        canvas.drawPath(_path, featurePaint!..color = styleConfig.colorMap[group]!);
        points.clear();
        _path.reset();
        if (_value == 0) continue;
      }

      _height = _valueScale!.scale(_value.abs())!;
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
        canvas.drawPath(_path, featurePaint!..color = styleConfig.colorMap[group]!);
        points.clear();
        _path.reset();
      }
    }
    // _path.addPolygon(points, true);
    // canvas.drawPath(_path, featurePaint..color = styleConfig.colorMap['+']);
  }

  void _drawBaseLine(Canvas canvas, Rect painterRect) {
    Color _color = styleConfig.brightness == Brightness.dark ? Colors.white38 : Colors.black38;
    _bgPaint!
      ..strokeWidth = .5
      ..style = PaintingStyle.stroke
      ..color = _color;
    canvas.drawLine(painterRect.bottomLeft, painterRect.bottomRight, _bgPaint!);
  }

  void drawAsCartesian(Canvas canvas, List<Feature> _visibleFeatures, Rect painterRect) {
    Rect _rect;
    double _height;
    Color _color;
    Rect blockRect;

    double _left, _right;
    if ((_visibleFeatures.length) == 0) {
      return;
    }
    // _maxValue = customMaxValue ?? _visibleFeatures.maxBy((f) => (f['value'] ?? 0).abs())['value'] ?? 0;
    // _maxValue = _maxValue.abs();
    // _rulerMaxValue = _maxValue;

    //todo neg value
    bool negValue = false; // trackData.features.any((f) => (f['value'] ?? 0) < 0);
    double _bottom = negValue ? painterRect.center.dy : painterRect.bottom;
    _maxHeight = negValue ? painterRect.height / 2 : painterRect.height;
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

      _height = _valueScale!.scale(_value.abs())!;
      //if (densityMode && _height < 0) _height = _height.abs();
      _overflow = valueScaleType == ValueScaleType.MAX_LIMIT && _valueRange.last > 1000 && _value.abs() > _rulerMaxValue;
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
      drawRect(canvas, _rect, featurePaint!..color = _color);
      if (_overflow) {
        double maxRadius = _rect.width / 2;
        double _radius = (_value.abs() - _rulerMaxValue) / (_valueRange.last - _rulerMaxValue) * maxRadius;
        canvas.drawCircle(_rect.topCenter + Offset(0, -maxRadius - 2), _radius.clamp(1.0, maxRadius), featurePaint!);
      }
    }
  }

  Color scaleColor(Color color, num value) {
    if (valueScaleType == ValueScaleType.LOG || valueScaleType == ValueScaleType.POW_HALF) {
      return color.withAlpha((_valueScale!.scale(value.abs())! / _valueScale!.scale(_valueRange.last)! * 255).toInt());
    }
    return color;
  }

  void _adjustValueScaleType() {
    List<num> domain = List.from(niceRange);
    switch (valueScaleType) {
      case ValueScaleType.LINEAR:
        _valueScale = ScaleLinear.number(domain: domain, range: [0.0, _maxHeight!]);
        break;
      case ValueScaleType.LOG:
        _valueScale = scaleLogFixed(domain: domain, range: [0.0, _maxHeight!]);
        break;
      case ValueScaleType.POW_HALF:
        _valueScale = ScalePow.number(domain: domain, range: [.0, _maxHeight!])..exponent = .5;
        break;
      default:
        _valueScale = ScaleLinear.number(domain: domain, range: [0.0, _maxHeight!]);
        break;
    }
  }

  void checkSelectedItem(Canvas canvas) {
    if (null == selectedItem) return;
    Feature feature = selectedItem;
    if (feature.rect == null) return;
    drawRect(canvas, feature.rect!, _selectedPaint!);
    canvas.drawLine(feature.groupRect!.bottomCenter, feature.groupRect!.topCenter, _selectedPaint!);
    double width = 220;
    double _height = 30;
    TextStyle _style = TextStyle(
      fontSize: 13,
      color: styleConfig.isDark ? Colors.white70 : Colors.black87,
      fontFamily: MONOSPACED_FONT,
      fontFamilyFallback: MONOSPACED_FONT_BACK,
    );
    String _text = 'Position: ${feature.range.print()}\n   Value: ${formatLabelValue(feature['value'] ?? 0, 2)} ';
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: _text, style: _style),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    width = textPainter.width;
    _height = textPainter.height;

    var _tooltipRect = Rect.fromLTWH(feature.rect!.topCenter.dx - width / 2, 8, width + 4, _height + 4);
    if (_tooltipRect.right > rect.right) {
      _tooltipRect = _tooltipRect.translate(rect.right - _tooltipRect.right, 0);
    }
    if (_tooltipRect.left < rect.left) {
      _tooltipRect = _tooltipRect.translate(rect.left - _tooltipRect.left, 0);
    }
    var __tooltipRect = RRect.fromRectAndRadius(_tooltipRect.inflate(4), Radius.circular(5));
    if (!kIsWeb) canvas.drawShadow(Path()..addRRect(__tooltipRect), _selectedPaint!.color, 4, true);
    canvas.drawRRect(__tooltipRect, _selectedPaint!);
    // canvas.drawRRect(
    //     __tooltipRect,
    //     _bgPaint
    //       ..style = PaintingStyle.stroke
    //       ..strokeWidth = 1
    //       ..color = styleConfig.primaryColor);

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
      drawZeroValue: false,
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
    if (trackData.isEmpty) {
      hitItem = null;
      return hitItem;
    }

    for (Map group in trackData.groupData!) {
      if (_groupRectMap[group['group']]?.contains(position) ?? false) {
        List<RangeFeature> list = group['data'];
        hitItem = list.firstOrNullWhere((feature) => feature.groupRect?.contains(position) ?? false);
        return hitItem;
      }
    }

    // hitItem = trackData.features.firstWhere((feature) => feature.groupRect?.contains(position) ?? false, orElse: () => null);
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
