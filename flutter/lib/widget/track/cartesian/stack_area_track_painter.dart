import 'dart:math' as math;
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/service/cache_service.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_data.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/monotone.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/stack_bar_style_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/stack_data.dart';
import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/widget/track/cartesian/ticker_paint_mixin.dart';
import 'package:get/get.dart';
import 'cartesian_track_painter.dart';

class StackAreaTrackPainter extends CartesianTrackPainter<StackData, StackBarStyleConfig> {
  StackAreaTrackPainter({
    required super.trackData, // may be data in a range
    required super.styleConfig,
    required super.scale, // the scale by the hole chromosome
    required super.visibleRange,
    super.orientation,
    super.selectedItem,
    super.valueScaleType,
    super.cursor,
    super.customMaxValue,
    super.onItemTap,
    super.height = 200.0,
    this.drawCoverage = true,
    this.splitMode = false,
    this.tooltipMapper,
    this.coverageStyle = CartesianChartType.area,
    this.areaMode = true,
    this.showGroupLabel = true,
  }) : super() {}

  late bool showGroupLabel;
  late bool areaMode;
  late bool splitMode;
  late bool drawCoverage;
  late CartesianChartType coverageStyle;

  void set _deepMaxValue(num max) => CacheService.get()!.setDeepMaxValue(trackData.track!, max);

  num get _deepMaxValue => CacheService.get()!.getDeepMaxValue(trackData.track!);

  Scale<num, num>? _deepValueScale;
  TooltipMapper<Map, StackDataItem>? tooltipMapper;

  List<String>? _stackGroup;
  List<Rect> _groupRect = [];
  EdgeInsets _groupPadding = EdgeInsets.only(top: 10, bottom: 10);

  @override
  void calculateItemRect(Rect trackRect, Size size) {
    //super.calculateItemRect(trackRect, size);
  }

  @override
  num countingMaxValue() {
    StackData _stackData = trackData;
    if (_stackData.hasCoverage && _stackData.useSameScale!) {
      return (math.max(_stackData.absCoverageMaxValue, _stackData.absMaxValue) * 1.25).toPrecision(2);
    }
    return ((splitMode ? _stackData.absGroupMaxValue : _stackData.absMaxValue) * 1.25).toPrecision(2);
  }

  @override
  void drawHorizontalTrack(Canvas canvas, Rect trackRect, Size size) {
    if (splitMode) {
      drawHorizontalSplitTrack(canvas, trackRect, size);
      return;
    }
    StackData _stackData = trackData;
    if (_stackData.isEmpty) return;

    bool hasRange = _stackData.hasRange;
    var range = scale.range;
    double barWidth = scale.rangeWidth / _stackData.size;
    bool hasCoverage = _stackData.hasCoverage;
    valueRange.last = customMaxValue ?? countingMaxValue();
    hasNegativeValue = _stackData.dataSource!.any((e) => e.strand == -1);
    if (isAbsLogScale) {
      num _min = _stackData.dataSource?.map((e) => e.sum()).filter((e) => e != 0).min() ?? 0;
      valueRange.first = _min;
      var (min, max) = logNice(valueRange);
      valueRange
        ..first = min
        ..last = max;
    }
    setTickerRange(valueRange, hasNegativeValue: hasNegativeValue, nice: !isAbsLogScale);

    valueScale = adjustValueScaleType();
    // print('${niceRange}, ${valueScale.domain}, ${valueScale.range}');
    if (hasCoverage) {
      var __deepMaxValue = _stackData.coverageMaxValue;
      if (__deepMaxValue == 0) __deepMaxValue = 1.0;
      _deepMaxValue = __deepMaxValue;
      _deepValueScale = adjustValueScaleType(values: [0, _deepMaxValue!]);
    }
    Rect _rect;
    List<String> groups = _stackData.dataSource![0].groups;
    // if (hasCoverage) groups.remove(_stackData.coverage);
    _stackGroup = groups;

    StackBarStyleConfig _styleConfig = styleConfig;
    double bottom, padding = 0, stackHeight, left, right, valueHeight;
    StackDataItem _stackItem;
    double baseY = hasNegativeValue ? trackRect.center.dy : trackRect.bottom;
    if (isAbsLogScale) {
      baseY = trackRect.top + valueScale.scale(valueScale.domainMax)!;
    }

    Map<String, Color> _colorMap = _styleConfig.colorMap;

    Map<String, Segments> _groupSegmentsP = Map.fromIterable(_stackGroup!, key: (k) => k, value: (k) => Segments());
    Map<String, Segments> _groupSegmentsN = Map.fromIterable(_stackGroup!, key: (k) => k, value: (k) => Segments());

    for (int i = 0; i < _stackData.size; i++) {
      _stackItem = _stackData.dataSource![i];

      left = hasRange ? scale[_stackItem.start!] as double : scale.rangeMin + i * barWidth + padding;
      right = hasRange ? scale[_stackItem.end!] as double : left + barWidth;
      if (hasRange) barWidth = right - left;
      if (right < trackRect.left || left > trackRect.right) {
        // continue; //not visible, so skip
      }
      stackHeight = valueScale.call(_stackItem.sum(_stackData.coverage))!.toDouble();

      _stackItem.renderShape = !stackHeight.isNaN && stackHeight != 0
          ? RectShape(
              rect: Rect.fromLTWH(
                left,
                stackHeight > 0 ? baseY - stackHeight : baseY,
                barWidth - padding,
                stackHeight.abs(),
              ),
            )
          : null;

      String _group;
      bottom = baseY;
      // draw stack item
      List _groups = _stackItem.strand == -1 ? groups.reversed.toList() : groups;

      for (int n = 0; n < _groups.length; n++) {
        _group = _groups[n];
        var segments = _stackItem.strandP ? _groupSegmentsP : _groupSegmentsN;

        valueHeight = (hasCoverage && _group == _stackData.coverage ? _deepValueScale : valueScale)!.scale(_stackItem[_group])! * _stackItem.strand;
        if (!valueHeight.isNaN && valueHeight != 0) {
          bottom = _group == _stackData.coverage ? baseY : bottom;
          _rect = Rect.fromLTWH(
            left + padding,
            valueHeight > 0 ? bottom - valueHeight : bottom,
            barWidth - padding,
            valueHeight.abs(),
          );
          segments[_group]!.addRect(_rect);
          // if (_group != _stackData.coverage) bottom -= valueHeight;
        } else {
          segments[_group]!.broken();
        }
        if (_group != _stackData.coverage) bottom -= valueHeight;
      }
    }

    if (hasCoverage && coverageStyle == CartesianChartType.bar) {
      drawCoverageBar(canvas, _groupSegmentsP[_stackData.coverage], _colorMap[_stackData.coverage] ?? Colors.grey);
      drawCoverageBar(canvas, _groupSegmentsN[_stackData.coverage], _colorMap[_stackData.coverage] ?? Colors.grey);
    }

    trackPaint!
      ..strokeWidth = styleConfig.borderWidth
      ..style = areaMode ? PaintingStyle.fill : PaintingStyle.stroke;

    if (hasCoverage) groups.sort((a, b) => a == _stackData.coverage ? 0 : a.compareTo(b));

    groups.forEachIndexed((group, index) {
      if (hasCoverage && group == _stackData.coverage && coverageStyle == CartesianChartType.bar) return;
      _drawGroupSegments(canvas, group, _groupSegmentsP[group]!, 1, _colorMap[group] ?? Colors.grey);
      _drawGroupSegments(canvas, group, _groupSegmentsN[group]!, -1, _colorMap[group] ?? Colors.grey);
    });
  }

  void drawCoverageBar(Canvas canvas, Segments? segments, Color color) {
    Path coverageBars = Path();
    var bars = segments?.segments.map((seg) => seg.bars).flatten() ?? [];
    for (var bar in bars) {
      coverageBars.addRect(bar);
    }
    canvas.drawPath(coverageBars, trackPaint!..color = color);
  }

  void _drawGroupSegments(Canvas canvas, String group, Segments segments, int direction, Color color) {
    if (segments.length == 0) return;
    late Path path;
    for (Segment segment in segments.segments) {
      if (segment.length == 0) continue;
      path = areaMode ? segment.getSegAreaPath(direction)! : segment.getSegPath(direction)!;
      canvas.drawPath(path, trackPaint!..color = color);
    }
  }

  void drawPath(Canvas canvas, List<Offset> points) {
    if (points.length == 0) return;
    Path path = MonotoneX.addCurve(Path()..moveTo(points.first.dx, points.first.dy), points);
    canvas.drawPath(path, bgPaint!);
  }

  Map _defaultTooltipMapper(StackDataItem item) {
    return item.source == null
        ? item.value.map((key, value) {
            return MapEntry(key, item.formatValue(value));
          })
        : item.value.map((key, value) {
            var _data = item.source![key];
            String __labelValue;
            if (_data != null && _data is List) {
              __labelValue = '${item.formatValue(value)} (+ ${item.formatValue(_data[0])}, - ${item.formatValue(_data[1])})';
            } else {
              __labelValue = item.formatValue(_data).padLeft(5);
            }
            return MapEntry(key, __labelValue);
          });
  }

  @override
  void drawSelectedItem(Canvas canvas, CartesianDataItem? selectedItem, Scale<num, num> valueScale) {
    if (selectedItem == null) return;

    var renderShape = selectedItem.renderShape; //renderShapeMap[_selectedItem.index];
    if (renderShape == null) return;

    StackDataItem stackDataItem = selectedItem as StackDataItem;

    var _rect = renderShape.rect;
    if (splitMode) {
      canvas.drawLine(_rect.topCenter, _rect.bottomCenter, selectedPaint!);
    } else {
      canvas.drawRect(_rect, selectedPaint!);
    }

    StackBarStyleConfig _styleConfig = styleConfig;
    Map<String, Color> _colorMap = _styleConfig.colorMap;

    Map _value = (tooltipMapper ?? _defaultTooltipMapper).call(stackDataItem);
    _value.removeWhere((key, value) => stackDataItem.value[key] == 0);
    if (hasNegativeValue) _value['strand'] = stackDataItem.strand == 1 ? 'strand(+)' : 'strand(-)';

    double width = 200;
    double rowHeight = 18;

    TextStyle _style = TextStyle(
      fontSize: 14,
      color: Colors.white,
      fontFamily: MONOSPACED_FONT,
      fontFamilyFallback: MONOSPACED_FONT_BACK,
    );

    String maxValue = _value.values.maxBy((v) => '${v}'.length);
    String maxKey = _value.keys.maxBy((v) => '${v}'.length) + '';
    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(text: maxValue, style: _style),
    )..layout();
    width = textPainter.width + 10;
    double typeRectWidth = maxKey.length * _style.fontSize! * .6;
    var _tooltipRect = Rect.fromLTWH(_rect.right + 4, trackRect.top, width + typeRectWidth + 4, rowHeight * _value.length);
    if (_tooltipRect.right > rect.right) {
      _tooltipRect = _tooltipRect.translate(rect.right - _tooltipRect.right, 0);
    }
    var __tooltipRect = RRect.fromRectAndRadius(
      _tooltipRect.inflate(2),
      Radius.circular(3),
    );
    if (!kIsWeb) canvas.drawShadow(Path()..addRRect(__tooltipRect), selectedPaint!.color, 8, true);
    canvas.drawRRect(__tooltipRect, selectedPaint!);
    canvas.drawRRect(
        __tooltipRect,
        bgPaint!
          ..style = PaintingStyle.stroke
          ..color = styleConfig.primaryColor!);

    int row = 0;
    _value.forEach((key, value) {
      if (key != 'strand') {
        canvas.drawRect(
          Rect.fromLTWH(_tooltipRect.left, _tooltipRect.top + row * rowHeight, 16, rowHeight),
          trackPaint!..color = _colorMap[key] ?? Colors.grey,
        );
        drawText(
          canvas,
          text: key,
          style: _style,
          offset: Offset(_tooltipRect.left, _tooltipRect.top + row * rowHeight + 1),
          textAlign: TextAlign.center,
          width: typeRectWidth,
        );
      }
      drawText(
        canvas,
        text: value,
        style: _style,
        offset: Offset(_tooltipRect.left + typeRectWidth + 4, _tooltipRect.top + row * rowHeight + 1),
        textAlign: TextAlign.left,
        width: width,
      );
      row++;
    });
  }

  void drawHorizontalSplitTrack(Canvas canvas, Rect trackRect, Size size) {
    StackData _stackData = trackData;
    if (_stackData.isEmpty) return;

    bool hasCoverage = _stackData.hasCoverage;
    List<String> groups = _stackData.dataSource![0].groups;
    if (hasCoverage) groups.remove(_stackData.coverage);
    _stackGroup = groups;
    int groupCount = groups.length;

    bool hasRange = _stackData.hasRange;
    var range = scale.range;
    double barWidth = scale.rangeWidth / _stackData.size;

    valueRange.last = customMaxValue ?? countingMaxValue();
    hasNegativeValue = _stackData.dataSource!.any((e) => e.strand == -1);
    if (isAbsLogScale) {
      valueRange.first = _stackData.groupMinValue;
      var (min, max) = logNice(valueRange);
      valueRange
        ..first = min
        ..last = max;
    }
    setTickerRange(valueRange, hasNegativeValue: hasNegativeValue);

    _groupPadding = hasNegativeValue ? EdgeInsets.only(top: 10, bottom: 10) : EdgeInsets.only(top: 10);
    double _singleGroupHeight = trackRect.height / groupCount;
    final maxHeight = (hasNegativeValue ? _singleGroupHeight / 2 : _singleGroupHeight);
    final dataHeight = groupCount > 1 ? maxHeight - _groupPadding.vertical : maxHeight;
    valueScale = adjustValueScaleType(height: dataHeight);
    if (hasCoverage) {
      var __deepMaxValue = _stackData.coverageMaxValue;
      if (__deepMaxValue == 0) __deepMaxValue = 1.0;
      _deepMaxValue = __deepMaxValue;
      _deepValueScale = adjustValueScaleType(height: dataHeight, values: [0, _deepMaxValue!]);
    }

    Rect r = Rect.fromLTWH(trackRect.left, trackRect.top, trackRect.width, _singleGroupHeight);
    _groupRect.clear();
    for (int i = 0; i < _stackGroup!.length; i++) {
      var __groupRect = r.translate(0, i * _singleGroupHeight);
      _groupRect.add(__groupRect);
      if (i % 2 == 0) {
        bgPaint!
          ..style = PaintingStyle.fill
          ..color = styleConfig.isDark ? Colors.black12 : Colors.grey[200]!;
        drawRect(canvas, __groupRect, bgPaint!);
      }
    }

    Rect _rect;
    StackBarStyleConfig _styleConfig = styleConfig;
    Map<String, Color> _colorMap = _styleConfig.colorMap;
    double bottom, padding = 0, stackHeight, left, right, valueHeight;
    StackDataItem _stackItem;

    double __height = hasNegativeValue ? trackRect.height / 2 : trackRect.height;

    Map<String, Segments> _groupSegmentsP = Map.fromIterable(_stackGroup!, key: (k) => k, value: (k) => Segments());
    Map<String, Segments> _groupSegmentsN = Map.fromIterable(_stackGroup!, key: (k) => k, value: (k) => Segments());

    _drawGroupsBaseLine(canvas);
    // canvas.save();
    // canvas.translate(0, trackRect.top);
    for (int i = 0; i < _stackData.size; i++) {
      double baseY = hasNegativeValue ? _singleGroupHeight / 2 : _singleGroupHeight - _groupPadding.bottom;
      if (isAbsLogScale) {
        baseY = _groupPadding.top + valueScale.scale(valueScale.domainMax)!;
      }
      bottom = baseY;
      _stackItem = _stackData.dataSource![i];

      left = hasRange ? scale[_stackItem.start!] as double : scale.rangeMin + i * barWidth + padding;
      right = hasRange ? scale[_stackItem.end!] as double : left + barWidth;
      if (hasRange) barWidth = right - left;
      if (right < trackRect.left || left > trackRect.right) {
        continue; //not visible, so skip
      }
      stackHeight = valueScale.call(_stackItem.sum(_stackData.coverage!)) as double;
      double totalHeight = hasCoverage ? math.max(valueScale.call(_stackItem.bgValue) as double, stackHeight) : stackHeight;
      _stackItem.renderShape = RectShape(rect: Rect.fromLTWH(left, trackRect.top, barWidth - padding, trackRect.bottom));

      String _group;
      List _groups = groups;
      for (int n = 0; n < _groups.length; n++) {
        _group = _groups[n];
        valueHeight = valueScale.call(_stackItem[_group])!.toDouble() * _stackItem.strand;
        if (!valueHeight.isNaN && valueHeight != 0) {
          _rect = Rect.fromLTWH(
            left + padding,
            valueHeight > 0 ? bottom - valueHeight : bottom,
            barWidth - padding,
            valueHeight.abs(),
          );
          _stackItem.strandP ? _groupSegmentsP[_group]!.addRect(_rect) : _groupSegmentsP[_group]!.addRect(_rect);
        } else {
          _stackItem.strandP ? _groupSegmentsP[_group]!.broken() : _groupSegmentsP[_group]!.broken();
        }
        bottom += _singleGroupHeight;
        // canvas.drawRect(_rect, trackPaint..color = _colorMap[key] ?? Colors.grey);
      }
    }
    // canvas.restore();
    Color _color;
    if (hasCoverage && coverageStyle == CartesianChartType.linear) {
      canvas.save();
      canvas.translate(0, trackRect.top);
      trackPaint!.style = PaintingStyle.stroke;
      _color = _colorMap[_stackData.coverage] ?? Colors.grey;
      for (int i = 0; i < groups.length; i++) {
        if (hasNegativeValue) {
          canvas.translate(0, (i) * _singleGroupHeight / 2 + i > 0 ? _singleGroupHeight : 0);
        } else {
          canvas.translate(0, (i) * _singleGroupHeight);
        }
        _drawGroupSegments(canvas, _stackData.coverage!, _groupSegmentsP[_stackData.coverage]!, 1, _color);
        _drawGroupSegments(canvas, _stackData.coverage!, _groupSegmentsN[_stackData.coverage]!, -1, _color);
      }
    }

    trackPaint!
      ..strokeWidth = styleConfig.borderWidth
      ..style = areaMode ? PaintingStyle.fill : PaintingStyle.stroke;
    canvas.save();
    canvas.translate(0, trackRect.top);

    for (String group in groups) {
      _color = _colorMap[group] ?? Colors.grey;
      _drawGroupSegments(canvas, group, _groupSegmentsP[group]!, 1, _color);
      _drawGroupSegments(canvas, group, _groupSegmentsN[group]!, -1, _color);
    }
    canvas.restore();
  }

  @override
  void drawHorizontalAxis(Canvas canvas, Rect trackRect, Size size) {
    int _groupCount = splitMode ? _stackGroup!.length : 1;
    Rect _groupRect = Rect.fromLTWH(trackRect.left, trackRect.top, trackRect.width, trackRect.height / _groupCount);

    Rect _tickerRect = _groupCount > 1 ? _getTickerRect(_groupRect, _groupPadding) : _groupRect;
    List<TickItem> tickers = findConformtableTickers(_tickerRect, valueScale: valueScale);

    canvas.save();
    // canvas.translate(0, trackRect.top);
    for (int i = 0; i < _groupCount; i++) {
      if (i > 0) canvas.translate(0, _groupRect.height);
      drawAxis(
        canvas: canvas,
        trackRect: _tickerRect,
        size: size,
        tickers: tickers,
        styleConfig: styleConfig,
        drawText: drawText,
        drawZeroValue: !splitMode,
      );
    }
    canvas.restore();
  }

  Rect _getTickerRect(Rect rect, EdgeInsets padding) {
    Rect _rect = rect;
    if (padding.top > 0) {
      _rect = Rect.fromLTWH(rect.left, rect.top + padding.top, rect.width, rect.height - padding.top);
    }
    if (padding.bottom > 0) {
      _rect = Rect.fromLTWH(_rect.left, _rect.top, _rect.width, _rect.height - padding.bottom);
    }
    return _rect;
  }

  _drawGroupsBaseLine(Canvas canvas) {
    Color _color = styleConfig.brightness == Brightness.dark ? Colors.white12 : Colors.black26;
    Color _labelColor = styleConfig.brightness == Brightness.dark ? Colors.white70 : Colors.black87;
    bgPaint!
      ..strokeWidth = .5
      ..style = PaintingStyle.stroke
      ..color = _color;

    int _groupCount = splitMode ? _stackGroup!.length : 1;
    Rect __tickerRect = Rect.fromLTWH(trackRect.left, trackRect.top, trackRect.width, trackRect.height / _groupCount);

    for (int i = 0; i < _groupCount; i++) {
      if (i > 0) __tickerRect = __tickerRect.translate(0, __tickerRect.height);
      canvas.drawLine(__tickerRect.bottomLeft, __tickerRect.bottomRight, bgPaint!);

      if (showGroupLabel)
        drawText(
          canvas,
          text: _stackGroup![i],
          style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12, color: _labelColor),
          offset: __tickerRect.topLeft + Offset(4, 6),
        );
    }
  }

  @override
  void drawVerticalTrack(Canvas canvas, Rect trackRect, Size size) {}

  @override
  bool painterChanged(AbstractTrackPainter painter) {
    return super.painterChanged(painter);
  }

  @override
  dynamic findHitItem(Offset position) {
    // if (renderShapeMap.keys.length == 0) return -1;
    StackData _stackData = trackData;
    // int startIndex = renderShapeMap.keys.first;

    int index;
    if (splitMode) {
      bool strandP = hasNegativeValue
          ? _groupRect.any((e) {
              return position.dy <= (e.top + e.height / 2) && position.dy >= e.top;
            })
          : true;
      index = _stackData.dataSource!.indexWhere((item) {
        Rect? rect = item.renderShape?.rect;
        if (rect == null || item.strandP != strandP) return false;
        return position.dx >= rect.left && position.dx <= rect.right;
      });
    } else {
      index = _stackData.dataSource!.indexWhere((item) {
        Rect? rect = item.renderShape?.rect;
        if (rect == null) return false;
        bool inHor = position.dx >= rect.left && position.dx <= rect.right;
        if (hasNegativeValue) {
          bool inVertical = item.strandP ? position.dy <= rect.bottom : position.dy >= rect.top;
          return inHor && inVertical;
        }
        return inHor;
        // return rect?.contains(position) ?? false;
      });
    }

    hitItem = index >= 0 ? trackData[index] : null;
//    print('hit item $hitItem');
    return index;
  }

  @override
  bool hitTest(Offset position) {
    int index = findHitItem(position);
//    print('bar painter hit test $position , index $index');
    if (index >= 0) return true;
//    return false; //不能return false，否则事件没法传递
    return super.hitTest(position);
  }
}
