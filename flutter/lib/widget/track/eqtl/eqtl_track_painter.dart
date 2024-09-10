import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:d4_scale/d4_scale.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

import 'package:flutter_smart_genome/chart/scale/value_sale_type.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/xy_plot_style_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/PositionedData.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_data.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/ticker_paint_mixin.dart';
import 'package:isar/isar.dart';

class EQTLTrackPainter extends CartesianTrackPainter<PositionedData<CircleShape>, XYPlotStyleConfig> {
  double inflateValue = 1;

  double radius;
  String? filterGene;

  Path _path = Path();
  Path _pathSelected = Path();

  Map<int, Path> _pathByRadius = {};

  EQTLTrackPainter({
    required super.trackData, // may be data in a range
    required super.styleConfig,
    required super.scale, // the scale by the hole chromosome
    required super.visibleRange,
    super.orientation,
    super.selectedItem,
    // super.scaling,
    required double trackHeight,
    super.valueScaleType = ValueScaleType.LOG,
    super.customMaxValue = 1.0,
    this.radius = 5,
    this.filterGene,
    super.logType = LogType.NEG_LOG10,
  }) : super(
          height: trackHeight,
        ) {
    this.maxHeight = trackHeight;
    _pathByRadius = Map.fromIterables(List.generate(radius.toInt(), (index) => index + 1), List.generate(radius.toInt(), (index) => Path()));
    _points = Map.fromIterables(List.generate(radius.toInt(), (index) => index + 1), List.generate(radius.toInt(), (index) => []));
    useAbsLog = false;
  }

  Scale<num, num>? _valueScale2;
  Scale<num, num>? _opacityScale;

  @override
  void initWithSize(ui.Size size) {
    super.initWithSize(size);
    trackRect = Rect.fromLTWH(trackRect.left, trackRect.top + radius, trackRect.width, trackRect.height - radius);
  }

  @override
  String formatTicker(TickItem tick) {
    return tick.formatValue(-log(tick.value) / ln10);
    return super.formatTicker(tick);
  }

  @override
  void calculateItemRect(Rect trackRect, Size size) {
    CartesianData _barData = trackData;
    hasNegativeValue = false; //_barData.dataSource!.any((f) => (f.value ?? 0) < 0);
    if (trackData.isEmpty) return;
    barPath = Path();

    valueRange.last = customMaxValue ?? countingMaxValue();
    valueRange.first = trackData.minValue;
    // setTickerRange([0, -log(valueRange.first) / ln10], nice: false);
    setTickerRange(valueRange, nice: false);

    valueScale = adjustValueScaleType(values: [valueRange.last, valueRange.first]);
    _valueScale2 = scaleLogFixed(domain: [valueRange.first, valueRange.last], range: [radius, 1]);
    _opacityScale = scaleLogFixed(domain: [radius, 1], range: [1.0, 0.1]);
    double barWidth = scale.rangeWidth / _barData.size;
    bool hasRange = _barData.hasRange;
    Rect _rect;
    double top;
    double padding = 0;
    double left, right;
    PositionDataItem<CircleShape> dataItem;
    double _radius;

    for (int i = 0; i < _barData.size; i++) {
      dataItem = _barData[i];
      double valueHeight = valueScale.scale(dataItem.value) as double;
      top = trackRect.bottom - valueHeight;
      left = hasRange ? scale[dataItem.start!] as double : scale.rangeMin + i * barWidth + padding;
      right = hasRange ? scale[dataItem.end!] as double : left + barWidth;
      if (styleConfig.fixValue) {
        left = left.ceilToDouble();
        right = right.ceilToDouble();
      }
      _rect = Rect.fromLTRB(left, top, right, trackRect.bottom);
      _radius = _valueScale2!.scale(dataItem.value)!;
      var shape = CircleShape(color: scaleColor(itemColor(styleConfig, dataItem), dataItem.value), rect: _rect, radius: _radius);
      // renderShapeMap[i] = shape;
      dataItem.renderShape = shape;
      barPath!.addRect(_rect);
    }
  }

  @override
  drawHorizontalTrack(Canvas canvas, Rect trackRect, Size size) {
    // canvas.drawLine(Offset(trackRect.left, trackRect.bottom), Offset(trackRect.right, trackRect.bottom), trackPaint!);
    if ((trackData.dataSource?.length ?? 0) > 20000) {
      drawHorizontalTrackFast(canvas, trackRect, size);
      return;
    }

    for (var e in _pathByRadius.entries) {
      e.value.reset();
    }
    _pathSelected.reset();
    _path.reset();
    Offset off = Offset(0, 0);
    double _circleSize;
    trackData.dataSource!.forEach((PositionDataItem<CircleShape> item) {
      var _rect = item.renderShape!.rect;
      if (_rect.right < trackRect.left || _rect.left > trackRect.right) {
        return; //not visible, so skip
      }
      _circleSize = item.renderShape!.radius * 2;
      ((filterGene != null && filterGene == item.source!['gene'])
              ? _pathSelected
              :
              // _pathByRadius[item.renderShape!.radius.round()]
              _path)
          .addOval(Rect.fromCenter(center: _rect.topCenter + off, width: _circleSize, height: _circleSize));
    });

    // Map<int, List> groupedData = trackData.dataSource!.groupBy((e) => e.renderShape!.radius.round());

    if (filterGene != null) {
      trackPaint!
        ..style = ui.PaintingStyle.fill
        ..color = Colors.grey[400]!;
      canvas.drawPath(_path, trackPaint!);
      trackPaint!
        ..style = ui.PaintingStyle.fill
        ..color = styleConfig.primaryColor!;
      canvas.drawPath(_pathSelected, trackPaint!);
      trackPaint!
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.black45;
      canvas.drawPath(_pathSelected, trackPaint!);
    } else {
      trackPaint!..style = ui.PaintingStyle.fill;
      canvas.drawPath(_path, trackPaint!..color = styleConfig.primaryColor!);
    }
  }

  Map<int, List<double>> _points = {};

  void drawHorizontalTrackFast(Canvas canvas, Rect trackRect, Size size) {
    for (var e in _points.entries) {
      e.value.clear();
    }
    _pathSelected.reset();

    Offset off = Offset(0, 0);
    double _circleSize;

    trackData.dataSource!.forEach((PositionDataItem<CircleShape> item) {
      var _rect = item.renderShape!.rect;
      if (_rect.right < trackRect.left || _rect.left > trackRect.right) {
        return; //not visible, so skip
      }
      _circleSize = item.renderShape!.radius * 2;

      if (null != filterGene && filterGene == item.source!['gene']) {
        _pathSelected.addOval(Rect.fromCenter(center: _rect.topCenter + off, width: _circleSize, height: _circleSize));
      } else {
        if (_points[item.renderShape!.radius.round()] == null) _points[item.renderShape!.radius.round()] = [];
        _points[item.renderShape!.radius.round()]?.addAll([_rect.topCenter.dx, _rect.topCenter.dy]);
      }
    });

    if (filterGene != null) {
      trackPaint!
        ..color = styleConfig.primaryColor!.withOpacity(.3)
        ..style = ui.PaintingStyle.fill;
      for (int radius in _points.keys) {
        trackPaint!..strokeWidth = (radius * 2).toDouble();
        canvas.drawRawPoints(ui.PointMode.points, Float32List.fromList(_points[radius]!), trackPaint!);
      }
      trackPaint!
        ..style = ui.PaintingStyle.fill
        ..color = styleConfig.primaryColor!;
      canvas.drawPath(_pathSelected, trackPaint!);
      trackPaint!
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.black45;
      canvas.drawPath(_pathSelected, trackPaint!);
    } else {
      trackPaint!
        ..color = styleConfig.primaryColor!
        // ..strokeCap = ui.StrokeCap.square
        // ..strokeJoin = ui.StrokeJoin.miter
        ..style = ui.PaintingStyle.fill;
      for (int radius in _points.keys) {
        trackPaint!..strokeWidth = (radius * 2).toDouble();
        canvas.drawRawPoints(ui.PointMode.points, Float32List.fromList(_points[radius]!), trackPaint!);
      }
    }
  }

  @override
  ui.Color itemColor(XYPlotStyleConfig styleConfig, CartesianDataItem item) {
    if (filterGene != null) return filterGene == item.source['gene'] ? styleConfig.primaryColor! : Colors.grey[400]!;
    return styleConfig.primaryColor!;
  }

  @override
  Color scaleColor(Color? color, num value) {
    return color ?? Colors.blue;
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
  void drawSelectedItem(Canvas canvas, CartesianDataItem? _selectedItem, Scale<num, num> valueScale) {
    if (_selectedItem == null) return;
    PositionDataItem __selectedItem = _selectedItem as PositionDataItem;
    Offset off = Offset(0, 0);
    var _rect = _selectedItem.renderShape!.rect;
    trackPaint!..style = ui.PaintingStyle.fill;
    canvas.drawCircle(
      _rect.topCenter + off,
      _valueScale2!.scale(__selectedItem.value2)!, //radius
      trackPaint!..color = styleConfig.selectedColor.withOpacity(1.0),
    );
    trackPaint!..style = ui.PaintingStyle.stroke;
    canvas.drawCircle(
      _rect.topCenter + off,
      _valueScale2!.scale(__selectedItem.value2)!, //radius
      trackPaint!..color = Colors.black,
    );
    drawTooltip(
      canvas,
      tooltip(_selectedItem),
      Offset(_selectedItem.renderShape!.rect.center.dx + 15, rect.top + 5),
      selectedPaint!,
    );
  }

  String tooltip(PositionDataItem item) {
    return '     snp: ${item.source?['snp']}\nPosition: ${item.start}\n       p: ${item.value}';
  }

  @override
  findHitItem(Offset position) {
    if ((trackData.dataSource?.length ?? 0) > 20000) {
      return -1;
    }
    Offset off = Offset(0, 0);
    var index = (trackData.dataSource ?? []).indexWhere((f) {
      if (f.renderShape == null) return false;
      var rect = f.renderShape!.rect;
      return Rect.fromCenter(center: rect.topCenter + off, width: 10, height: 10).contains(position);
      return rect.left - 10 <= position.dx && rect.right + 10 >= position.dx;
    });
    if (index >= 0) hitItem = trackData.dataSource![index];
    return index;
  }

  @override
  bool painterChanged(AbstractTrackPainter painter) {
    return super.painterChanged(painter);
  }

  @override
  void drawVerticalTrack(Canvas canvas, Rect trackRect, Size size) {}
}
