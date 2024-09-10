import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/chart/scale/value_sale_type.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/xy_plot_style_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/ticker_paint_mixin.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'dart:math' show pi, max, pow, log, exp;
import 'package:dartx/dartx.dart' as dx;

import 'package:get/get.dart';

class BamCoverageTrackPainter extends AbstractTrackPainter<FeatureData, XYPlotStyleConfig> with TickerPainterMixin {
  late Paint _paint;
  late Paint _bgPaint;
  late Paint _blockPaint;
  late Paint _selectedPaint;

  late Paint featurePaint;

  double inflateValue = 1;

  late bool densityMode;
  late bool cartesianType;
  late ValueScaleType valueScaleType;

  BamCoverageTrackPainter({
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
    this.valueScaleType = ValueScaleType.MAX_LIMIT,
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
    if (cartesianType) {
      drawAsCartesian(canvas, _visibleFeatures);
    } else {
      bool negValue = trackData.features!.any((f) => (f['value'] ?? 0) < 0);
      if (negValue) {
        drawAsFeature(canvas, _visibleFeatures);
      } else {
        _drawAsFeatureFast(canvas, _visibleFeatures);
      }
    }
    drawHorizontalAxis(canvas, painterRect, size);
    checkSelectedItem(canvas);
  }

  @override
  bool onEmptyPaint(Canvas canvas, Size size) {
    //super.onEmptyPaint(canvas, size);
    return true;
  }

  List<num> _valueRange = [0, 0];
  double? _valueScale;
  double? _maxHeight;

  void drawAsFeature(Canvas canvas, List<Feature> visibleFeatures) {
    Rect _rect;
    double _height;
    Color _color;
    Rect blockRect;

    _valueRange.last = visibleFeatures.maxBy((f) => (f['value'] ?? 0).abs())!['value'] ?? 0;
    setTickerRange(_valueRange);

    bool negValue = trackData.features!.any((f) => (f['value'] ?? 0) < 0);
    if (negValue) canvas.drawLine(painterRect.centerLeft, painterRect.centerRight, _paint..color = Colors.grey);
    double _bottom = negValue ? painterRect.center.dy : painterRect.bottom;
    _maxHeight = negValue ? painterRect.height / 2 : painterRect.height;

    double _left, _right;

    for (Feature feature in visibleFeatures) {
      feature.rect = null;
      feature.groupRect = null;
      // if (!inVisibleRange(feature)) continue;

      num _value = feature['value'] ?? 0;
      _height = _maxHeight! * (_value / _valueRange.last);
      _height = _height.abs();
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
      drawRect(canvas, _rect, featurePaint..color = _color, styleConfig.radius);
    }
  }

  void _drawAsFeatureFast(Canvas canvas, List<Feature> visibleFeatures) {
    Rect _rect;
    double _height;
    Color _color;
    Rect blockRect;

    _valueRange.last = visibleFeatures.maxBy((f) => (f['value'] ?? 0).abs())!['value'] ?? 0;
    setTickerRange(_valueRange);

    bool negValue = trackData.features!.any((f) => (f['value'] ?? 0) < 0);
    if (negValue) canvas.drawLine(painterRect.centerLeft, painterRect.centerRight, _paint..color = Colors.grey);
    double _bottom = negValue ? painterRect.center.dy : painterRect.bottom;
    _maxHeight = negValue ? painterRect.height / 2 : painterRect.height;

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
        canvas.drawPath(_path, featurePaint..color = styleConfig.colorMap['+']!);
        points.clear();
        _path.reset();
        if (_value == 0) continue;
      }

      _height = _maxHeight! * (_value / _valueRange.last);
      _height = _height.abs();
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
        _path
          ..lineTo(_left, _rect.top)
          ..lineTo(_right, _rect.top);
        points
          ..add(Offset(_left, _rect.top))
          ..add(Offset(_right, _rect.top));
      }
      if (index == visibleFeatures.length - 1) {
        _path
          ..lineTo(points.last.dx, _bottom)
          ..close();
        canvas.drawPath(_path, featurePaint..color = styleConfig.colorMap['+']!);
        points.clear();
        _path.reset();
      }
    }
  }

  void drawAsCartesian(Canvas canvas, Iterable<Feature> visibleFeatures) {
    Rect _rect;
    double _height;
    Color _color;
    Rect blockRect;

    double _left, _right;

    List<Feature> _visibleFeatures = trackData.features!.where((f) => inVisibleRange(f)).toList();
    if ((_visibleFeatures.length) == 0) {
      return;
    }
    var _maxValue = _visibleFeatures.maxBy((f) => (f['value'] ?? 0).abs())!['value'] ?? 0;
    _valueRange.last = _maxValue!.abs();
    setTickerRange(_valueRange);

    bool negValue = trackData.features!.any((f) => (f['value'] ?? 0) < 0);
    double _bottom = negValue ? painterRect.center.dy : painterRect.bottom;
    _maxHeight = negValue ? painterRect.height / 2 : painterRect.height;

    _valueScale = _maxHeight! / tickerRange.last;
    _adjustValueScaleType(_visibleFeatures);

    int index = 0;
    bool _overflow;
    num _value;
    for (Feature feature in _visibleFeatures) {
      index++;
      feature.rect = null;
      feature.groupRect = null;

      _value = feature['value'] ?? 0;
      if (_value == 0) continue;

      _height = _valueScale! * _valueScaled(_value.abs());
      //if (densityMode && _height < 0) _height = _height.abs();
      _overflow = valueScaleType == ValueScaleType.MAX_LIMIT && _maxValue! > 1000 && _value.abs() > tickerRange.last;
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
      if (valueScaleType == ValueScaleType.LOG) _color = _color.withAlpha((log(_value.abs()) / log(_maxValue!) * 255).toInt());
//      if (!densityMode) drawRect(canvas, _blockPaint..color = styleConfig.blockBgColor, blockRect);
      drawRect(canvas, _rect, featurePaint..color = _color, styleConfig.radius);
      if (_overflow) {
        double maxRadius = _rect.width / 2;
        double _radius = (_value.abs() - tickerRange.last) / (_maxValue! - tickerRange.last) * maxRadius;
        canvas.drawCircle(_rect.topCenter + Offset(0, -maxRadius - 2), _radius.clamp(1.0, maxRadius), featurePaint);
      }
    }
  }

  _adjustValueScaleType(List<Feature> features) {
    switch (valueScaleType) {
      case ValueScaleType.LINEAR:
        //do nothing
        break;
      case ValueScaleType.MAX_LIMIT:
        if (_valueRange.last <= 1000) return;
        //double avg = features.averageBy((f) => f['value'] ?? 0);
        // _rulerMaxValue = _valueRange.last! * (_valueScale! < 0.005 ? _valueScale! / 0.005 : .6);
        _valueScale = _maxHeight! / niceRange.last;
        break;
      case ValueScaleType.LOG:
        _valueScale = _maxHeight! / log(niceRange.last);
        break;
      default:
        break;
    }
  }

  num _valueScaled(num value) {
    switch (valueScaleType) {
      case ValueScaleType.LINEAR:
        return value;
      case ValueScaleType.MAX_LIMIT:
        return value > niceRange.last ? niceRange.last : value;
      case ValueScaleType.LOG:
        return log(value);
      default:
        return value;
    }
  }

  void checkSelectedItem(Canvas canvas) {
    if (null == selectedItem) return;
    Feature feature = selectedItem!;
    if (feature.rect == null) return;
    drawRect(canvas, feature.rect!, _selectedPaint, styleConfig.radius);
    canvas.drawLine(feature.groupRect!.bottomCenter, feature.groupRect!.topCenter, _selectedPaint);
    double width = 200;
    TextStyle _style = TextStyle(fontSize: 12, color: Colors.white, backgroundColor: Colors.black87);
    String _text = ' ${formatLabelValue(feature['value'] ?? 0, 2)} ';
    if (kIsWeb) {
      TextPainter textPainter = TextPainter(text: TextSpan(text: _text, style: _style))..layout();
      width = textPainter.width;
    }
    drawText(
      canvas,
      text: _text,
      style: _style,
      width: width,
      textAlign: TextAlign.center,
      offset: feature.groupRect!.topCenter + Offset(-width / 2, 0),
    );
  }

  void drawHorizontalAxis(Canvas canvas, Rect trackRect, Size size) {
    drawAxis(
      canvas: canvas,
      trackRect: trackRect,
      size: size,
      tickers: findConformtableTickers(trackRect),
      styleConfig: styleConfig,
      drawText: drawText,
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
    hitItem = trackData.features!.firstWhereOrNull((feature) => feature.groupRect?.contains(position) ?? false);
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
