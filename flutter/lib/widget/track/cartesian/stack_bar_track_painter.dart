import 'dart:math' as math;
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/chart/extensions/geometry_extensions.dart';
import 'package:flutter_smart_genome/chart/scale/value_sale_type.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/service/cache_service.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_data.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/monotone.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/stack_bar_style_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/stack_data.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/ticker_paint_mixin.dart';
import 'package:get/get.dart';
import 'cartesian_track_painter.dart';

class StackBarTrackPainter extends CartesianTrackPainter<StackData, StackBarStyleConfig> {
  StackBarTrackPainter({
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
    this.coverageStyle = CartesianChartType.bar,
    this.sumMode = false,
    this.showGroupLabel = true,
    this.stackMode = StackMode.stack,
  }) : super() {}

  late bool showGroupLabel;
  late bool sumMode;
  late bool splitMode;
  late bool drawCoverage;
  late CartesianChartType coverageStyle;
  late StackMode stackMode;

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
    var _max;
    if (_stackData.hasCoverage && _stackData.useSameScale!) {
      _max = (math.max(_stackData.absCoverageMaxValue, _stackData.absMaxValue) * 1.05).toPrecision(2);
    } else {
      _max = ((splitMode ? _stackData.absGroupMaxValue : _stackData.absMaxValue) * 1.05).toPrecision(2);
    }
    if (_max == 0) _max = 1;
    return _max;
  }

  @override
  void drawHorizontalTrack(Canvas canvas, Rect trackRect, Size size) {
    StackData _stackData = trackData;
    if (_stackData.isEmpty) return;

    if (splitMode) {
      drawHorizontalSplitTrack(canvas, trackRect, size);
      return;
    }

    bool hasRange = _stackData.hasRange;
    double barWidth = scale.rangeWidth / _stackData.size;
    bool hasCoverage = _stackData.hasCoverage;

    valueRange.last = customMaxValue ?? countingMaxValue();
    hasNegativeValue = _stackData.dataSource!.any((e) => e.strand == -1);

    if (isAbsLogScale) {
      num _min = _stackData.dataSource?.map((e) => e.sum(_stackData.coverage)).filter((e) => e != 0).min() ?? 0;
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
      _deepValueScale = adjustValueScaleType(values: [0, _deepMaxValue]);
    }

    StackBarStyleConfig _styleConfig = styleConfig;
    Map<String, Color> _colorMap = _styleConfig.colorMap;
    StackDataItem _stackItem;

    double bottom, padding = 0, stackHeight, left, right, valueHeight;
    double baseY = hasNegativeValue ? trackRect.center.dy : trackRect.bottom;
    if (isAbsLogScale) {
      baseY = trackRect.top + valueScale.scale(valueScale.domainMax)!;
    }
    // print('base y: ${baseY}');
    Rect _rect;

    List<String> groups = _stackData.dataSource![0].groups;
    if (hasCoverage) groups.remove(_stackData.coverage);
    _stackGroup = groups;

    Map<int, Segments> coverageSegments = {};

    Segments strandSegments(strand) {
      if (coverageSegments[strand] == null) coverageSegments[strand] = Segments();
      return coverageSegments[strand]!;
    }

    // Function1<num, num> valueMapper = isAbsLogScale ? (num v) => math.log(v) : (num v) => v;
    Function1<num, num> valueMapper = (num v) => v;

    Map<String, Path> groupPathMap = Map.fromIterable(groups, value: (k) => Path());
    for (int i = 0; i < _stackData.size; i++) {
      _stackItem = _stackData.dataSource![i];

      left = hasRange ? scale[_stackItem.start!]!.roundToDouble() : scale.rangeMin + i * barWidth + padding;
      right = hasRange ? scale[_stackItem.end!]!.roundToDouble() : left + barWidth;
      if (hasRange) barWidth = right - left;
      if (right < trackRect.left || left > trackRect.right) {
        continue; //not visible, so skip
      }

      ///draw coverage bar
      if (hasCoverage) {
        valueHeight = (_deepValueScale ?? valueScale).scale(valueMapper(_stackItem[_stackData.coverage!]))! * _stackItem.strand;
        if (!valueHeight.isNaN && valueHeight != 0) {
          _rect = Rect.fromLTWH(left + padding, _stackItem.strandP ? baseY - valueHeight : baseY, barWidth - padding, valueHeight.abs());
          if (coverageStyle == CartesianChartType.bar) {
            canvas.drawRect(_rect, trackPaint!..color = _colorMap[_stackData.coverage] ?? Colors.grey);
          }
          strandSegments(_stackItem.strand).addRect(_rect);
        } else {
          strandSegments(_stackItem.strand).broken();
        }
      }

      stackHeight = valueScale.scale(valueMapper(_stackItem.sum(_stackData.coverage)))!;
      // print('stack height: $stackHeight, ${valueScale.domain} => ${valueScale.range}');
      if (stackHeight.isInfinite || stackHeight.isNaN || stackHeight == 0) {
        continue;
      }

      // double totalHeight = hasCoverage ? math.max(valueScale.scale(valueMapper(_stackItem.bgValue)) as double, stackHeight) : stackHeight;
      _stackItem.renderShape = RectShape(
        rect: Rect.fromLTWH(left, _stackItem.strandP ? baseY - stackHeight : baseY, barWidth - padding, stackHeight.abs()),
      );

      if (sumMode) {
        canvas.drawRect(_stackItem.renderShape!.rect, trackPaint!..color = _styleConfig.primaryColor!);
        continue;
      }

      String key;
      bottom = baseY;
      // draw stack item
      // List _groups = _stackItem.strand == -1 ? groups.reversed.toList() : groups;
      List _groups = groups.reversed.toList();
      for (int n = 0; n < _groups.length; n++) {
        key = _groups[n];
        // if (key == _stackData.coverage) continue;
        valueHeight = valueScale.scale(valueMapper(_stackItem[key]))! * _stackItem.strand;
        // print('valueHeight: ${valueHeight} <- ${key}: ${_stackItem[key]}');
        if (valueHeight.isNaN || valueHeight == 0 || valueHeight.isInfinite) {
          continue;
        }
        _rect = valueHeight > 0
            ? Rect.fromLTWH(left + padding, bottom - valueHeight, barWidth - padding, valueHeight) //
            : Rect.fromLTWH(left + padding, bottom, barWidth - padding, -valueHeight);
        // print('${_stackItem[key]}, valueHeight: ${valueHeight}, ${_rect}');
        groupPathMap[key]!.addRect(_rect);
        // canvas.drawRect(_rect, trackPaint!..color = _colorMap[key] ?? Colors.grey);
        if (stackMode == StackMode.stack) bottom -= valueHeight;
      }
    }

    for (var group in groupPathMap.keys) {
      canvas.drawPath(groupPathMap[group]!, trackPaint!..color = _colorMap[group] ?? Colors.grey);
    }

    if (hasCoverage && coverageStyle == CartesianChartType.linear) {
      bgPaint!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = _colorMap[_stackData.coverage] ?? Colors.grey;

      for (var strand in coverageSegments.keys) {
        var segments = coverageSegments[strand]!;
        for (int i = 0; i < segments.length; i++) {
          var path = segments[i].getSegPath(strand);
          if (path != null) canvas.drawPath(path, bgPaint!);
        }
      }
    }
    bgPaint!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..color = styleConfig.brightness == Brightness.dark ? Colors.white12 : Colors.black26;
    if (hasNegativeValue) canvas.drawLine(painterRect.centerLeft, painterRect.centerRight, bgPaint!);
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
              __labelValue = item.formatValue(_data);
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
      fontSize: 12,
      color: Colors.white,
      fontFamily: MONOSPACED_FONT,
      fontFamilyFallback: MONOSPACED_FONT_BACK,
    );
    if (_value.length == 0) {
      return;
    }
    String maxValue = _value.values.maxBy((v) => '${v}'.length) + '';
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
          Rect.fromLTWH(_tooltipRect.left, _tooltipRect.top + row * rowHeight, typeRectWidth, rowHeight),
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

    StackBarStyleConfig _styleConfig = styleConfig;
    bool hasCoverage = _stackData.hasCoverage;
    List<String> groups = _stackData.dataSource![0].groups;
    if (hasCoverage) groups.remove(_stackData.coverage);
    _stackGroup = groups;
    int groupCount = groups.length;

    bool hasRange = _stackData.hasRange;
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
    setTickerRange(valueRange, hasNegativeValue: hasNegativeValue, nice: !isAbsLogScale);

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
          ..color = _styleConfig.isDark ? Colors.black12 : Colors.grey[50]!;
        drawRect(canvas, __groupRect, bgPaint!);
      }
    }

    Rect _rect;
    Map<String, Color> _colorMap = _styleConfig.colorMap;
    double padding = 0, stackHeight, left, right, valueHeight;
    StackDataItem _stackItem;

    // List<Rect> _coverageRectP = [];
    // List<Rect> _coverageRectN = [];

    Map<int, Segments> coverageSegments = {};
    Segments strandSegments(strand) {
      if (coverageSegments[strand] == null) coverageSegments[strand] = Segments();
      return coverageSegments[strand]!;
    }

    Map<String, Path> groupRectPathMap = Map.fromIterable(groups, value: (k) => Path());

    _drawGroupsBaseLine(canvas);

    canvas.save();
    canvas.translate(0, trackRect.top);
    for (int i = 0; i < _stackData.size; i++) {
      double baseY = hasNegativeValue ? _singleGroupHeight / 2 : _singleGroupHeight - _groupPadding.bottom;
      if (isAbsLogScale) {
        baseY = valueScale.scale(valueScale.domainMax)!;
      }

      _stackItem = _stackData.dataSource![i];

      left = hasRange ? scale[_stackItem.start!] as double : scale.rangeMin + i * barWidth + padding;
      right = hasRange ? scale[_stackItem.end!] as double : left + barWidth;
      if (hasRange) barWidth = right - left;
      if (right < trackRect.left || left > trackRect.right) {
        continue; //not visible, so skip
      }

      stackHeight = valueScale.scale(_stackItem.sum(_stackData.coverage))!;

      ///draw coverage bar
      if (hasCoverage) {
        valueHeight = (_deepValueScale ?? valueScale).scale(_stackItem[_stackData.coverage!])! * _stackItem.strand;
        if (!valueHeight.isNaN && valueHeight != 0) {
          _rect = Rect.fromLTWH(
            left + padding,
            valueHeight > 0 ? baseY - valueHeight : baseY,
            barWidth - padding,
            valueHeight.abs(),
          );
          strandSegments(_stackItem.strand).addRect(_rect);
        } else {
          strandSegments(_stackItem.strand).broken();
        }
      }

      // double totalHeight = hasCoverage ? math.max(valueScale.scale(_stackItem.bgValue), stackHeight) : stackHeight;

      _stackItem.renderShape = RectShape(rect: Rect.fromLTWH(left, trackRect.top, barWidth - padding, trackRect.bottom));

      String key;
      // draw stack item
      List _groups = groups;
      for (int n = 0; n < _groups.length; n++) {
        key = _groups[n];
        // if (key == _stackData.coverage) continue; //already filtered
        valueHeight = valueScale.scale(_stackItem[key])! * _stackItem.strand;
        if (valueHeight.isNaN || valueHeight == 0) {
          baseY += _singleGroupHeight;
          continue;
        }
        _rect = Rect.fromLTWH(
          left + padding,
          valueHeight > 0 ? baseY - valueHeight : baseY,
          barWidth - padding,
          valueHeight.abs(),
        );
        groupRectPathMap[key]!.addRect(_rect);
        // canvas.drawRect(_rect, trackPaint!..color = _colorMap[key] ?? Colors.grey);
        baseY += _singleGroupHeight;
      }
    }

    for (var group in groupRectPathMap.keys) {
      canvas.drawPath(groupRectPathMap[group]!, trackPaint!..color = _colorMap[group] ?? Colors.grey);
    }

    canvas.restore();

    if (hasCoverage && coverageStyle == CartesianChartType.linear) {
      canvas.save();
      bgPaint!
        ..style = PaintingStyle.stroke
        ..color = _colorMap[_stackData.coverage] ?? Colors.grey;
      canvas.translate(0, trackRect.top);
      for (int i = 0; i < groups.length; i++) {
        if (hasNegativeValue) {
          canvas.translate(0, (i) * _singleGroupHeight / 2 + i > 0 ? _singleGroupHeight : 0);
        } else {
          canvas.translate(0, (i) * _singleGroupHeight);
        }

        for (var strand in coverageSegments.keys) {
          var segments = coverageSegments[strand]!;
          for (int i = 0; i < segments.length; i++) {
            var path = segments[i].getSegPath(strand);
            if (path != null) canvas.drawPath(path, bgPaint!);
          }
        }
      }
      canvas.restore();
    }
  }

  _drawGroupsBaseLine(Canvas canvas) {
    Color _color = styleConfig.brightness == Brightness.dark ? Colors.white12 : Colors.black26;
    Color _labelColor = styleConfig.brightness == Brightness.dark ? Colors.white70 : Colors.black87;
    bgPaint!
      ..strokeWidth = 1.0
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

  Rect _getTickerRect(Rect rect, EdgeInsets padding) {
    return Rect.fromLTWH(rect.left, rect.top + padding.top, rect.width, rect.height - padding.bottom - padding.top);
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
