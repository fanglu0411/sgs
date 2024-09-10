import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_smart_genome/cell/data_category.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/chart/scale/point.dart';
import 'package:flutter_smart_genome/chart/scale/vector_scale_ext.dart';
import 'package:flutter_smart_genome/chart/scale/vector_linear_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:dartx/dartx.dart' as dx;
import 'package:d4/d4.dart' as d4;
import 'package:flutter_smart_genome/extensions/common_extensions.dart';
import 'package:flutter_smart_genome/extensions/d4_extension.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/legend_colors.dart';

import 'l_rect.dart';

class GenePlotMatrix<T> {
  final int GROUPED_BREAKPOINT = 300000;
  List genePlotData;

  Map<String, List>? groupedData;

  /// 当细胞数大于30万的时候分组缓存坐标，加速绘制速度
  Map<String, Float32List> _groupCords = {};

  Map<String, Float32List> get groupCords => _groupCords;

  LRect viewRect;
  LRect domainRange;
  late Vector3LinearScale _scale;

  Map<String, Path>? _groupPath;

  // late double maxScale;

  final MAX_SCREEN_COUNT = 8000; //图表可见区域最多的点的数量

  Vector3LinearScale get scale => _scale;

  Map<String, Path>? get groupPath => _groupPath;

  List<DataCategory>? get legends => legendMap?.values.toList();
  Map<String, DataCategory>? legendMap;

  late LegendColor _legendColor;

  LegendColor get legendColor => _legendColor;

  late ScaleSequential<String> _colorScale;

  late int _cellCount;

  int get cellCount => _cellCount;

  late Scale<num, num> _domainScale;
  late Scale<num, num>? _domainScaleY;

  Scale<num, num> get domainScale => _domainScale;

  Scale<num, num> get domainScaleY => _domainScaleY ?? _domainScale;

  // store each group cord range
  Map<String, Rect> _groupCordsRange = {};

  bool isSpatial = false;

  double _xMapper(List list) {
    return list[2];
  }

  double _yMapper(List list) {
    return list[3];
  }

  double _xScaleMapper(List list) {
    return domainScale.scale(list[2])!;
  }

  double _yScaleMapper(List list) {
    return isSpatial ? domainScaleY.scale(list[3])! : 65535.0 - domainScaleY.scale(list[3])!;
  }

  bool get isGrouped => true; //_cellCount >= GROUPED_BREAKPOINT;
  bool computeCord;

  GenePlotMatrix({
    required this.genePlotData,
    required this.viewRect,
    required this.domainRange,
    required Scale<num, num> domainScale,
    Scale<num, num>? domainScaleY,
    this.isSpatial = false,
    this.computeCord = true,
    required LegendColor legendColor,
  }) {
    _scale = Vector3LinearScale(
      domainMin: Point3(domainRange.left, domainRange.top, 0),
      domainMax: Point3(domainRange.right, domainRange.bottom, 0),
      rangeMin: Point3(.0, .0, .0),
      rangeMax: Point3(viewRect.width, viewRect.height, .0),
    );

    _cellCount = genePlotData.length;
    // maxScale = ((_cellCount / MAX_SCREEN_COUNT) * 32).clamp(32.0, 65536 / 64);

    // genePlotData.sort((a, b) => a[1].compareTo(b[1]));
    double minValue = 0; // genePlotData.first[1] * 1.0;
    // double maxValue = _cellCount > 0 ? genePlotData.last[1] * 1.0 : 1.0;
    num maxValue = genePlotData.maxBy((e) => e[1])?[1] ?? 1.0;
    // if (minValue == maxValue && minValue > 0) minValue = 0.0;
    if (maxValue == 0) maxValue = 1.0;

    var niceValueRange = d4.nice(minValue, maxValue, 10);
    // minValue = niceValueRange.$1.toDouble(); //min is always 0
    maxValue = niceValueRange.$2.toDouble();

    _domainScale = domainScale; // ?? LinearScale(domain: NumericExtents(minValue, maxValue), range: ScaleOutputExtent(0, 65535));
    _domainScaleY = domainScaleY; // ?? LinearScale(domain: NumericExtents(minValue, maxValue), range: ScaleOutputExtent(0, 65535));
    _legendColor = legendColor
      ..min = minValue
      ..max = maxValue.toDouble();
    _colorScale = d4.ScaleSequential(domain: [minValue, maxValue], interpolator: legendColor.interpolate);
    print('min value: ${minValue}, max value: ${maxValue}');

    // changeLegends(legendColor ?? legendColors.first);

    List<num> ticks = d4.ticks(minValue, maxValue, 10);

    Map<String, dx.DoubleRange> clusters = {};
    int count = ticks.length;
    // double avg = (maxValue - minValue) == 0 ? maxValue : ((maxValue - minValue) / count);
    // for (int i = 0; i < count; i++) {
    //   double start = minValue + i * avg;
    //   dx.DoubleRange range = dx.DoubleRange(start, i < count - 1 ? (start + avg) : maxValue * 1.0);
    //   clusters['[${start.toStringAsPrecision(2)}-${range.endInclusive.toStringAsPrecision(2)})'] = range;
    // }

    num avg = (maxValue - minValue) == 0 ? maxValue : (ticks.second - ticks.first).toDouble();
    clusters['${minValue}'] = dx.DoubleRange(minValue, minValue);
    for (int i = 0; i < count - 1; i++) {
      num start = ticks[i], end = ticks[i + 1];
      dx.DoubleRange range = dx.DoubleRange(start.toDouble(), end.toDouble());
      clusters['(${start.toStringAsPrecision(3)}-${range.endInclusive.toStringAsPrecision(3)}]'] = range;
    }

    List<String> _clusters = clusters.keys.toList();

    //给坐标点分组以提高性能
    // if (_cellCount >= GROUPED_BREAKPOINT) {
    groupedData = Map.fromIterables(_clusters, List.generate(_clusters.length, (index) => []));

    int rangeIndex;
    String __cluster;
    for (List item in genePlotData) {
      // cell, value , x, y
      if (item[1] == minValue) {
        __cluster = _clusters[0];
      } else {
        rangeIndex = ((item[1] - minValue) ~/ avg) + 1;
        __cluster = _clusters[rangeIndex.clamp(0, _clusters.length - 1)];
      }
      // groupedData[__cluster]!.add([item[0], item[2], item[3], item[1]]);
      groupedData![__cluster]!.add(item);
    }

    if (computeCord) initPositions();

    legendMap = clusters.toMap().map((key, value) {
      var value = clusters[key]!.endInclusive;
      return MapEntry(
          key,
          DataCategory(
            name: key,
            color: getValueColor(value),
            value: value,
            count: groupedData![key]!.length,
          ));
    });
    // }
  }

  void changeLegends(LegendColor legendColor) {
    _legendColor = legendColor;
    _colorScale..interpolator = legendColor.interpolate;
    // _colorScale = ScaleSequential(domain: _colorScale.domain, interpolator: legendColor.interpolate!);
    // _colorScale = ScaleSequential(domain: _colorScale.domain, interpolator: d4.interpolateRgb(legendColor.startHex, legendColor.endHex));
    if (isGrouped) {
      legendMap!.forEach((k, c) {
        c.color = getValueColor(c.value);
      });
    }
    // legends = List.generate(11, (index) {
    //   var value = _colorScale.reverse(index * .1);
    //   return DataCategory(name: '${value.toStringAsFixed(2)}', color: getValueColor(value), focused: true);
    // });
  }

  void changeSelection(DataCategory cat) {
    // if (cat.focused) {
    //   if (_selectedCells == null) {
    //     _selectedCells = {};
    //   }
    //   if (_selectedCells?.containsKey(cat.name) ?? false) {
    //     _selectedCells![cat.name]!.addAll(groupData![cat.name]!);
    //     _selectedPoints!.addAll(groupCords[cat.name]!.toList());
    //   } else {
    //     _selectedCells![cat.name] = groupData![cat.name]!.toList();
    //     _selectedPoints = groupCords[cat.name]!;
    //   }
    // } else {
    //   if (_selectedCells?.containsKey(cat.name) ?? false) {
    //     _selectedCells!.remove(cat.name);
    //     _selectedPoints = null;
    //   }
    // }
  }

  void clear() {
    _groupCords.clear();
    groupedData?.clear();
    _groupCordsRange.clear();
    genePlotData.clear();
    _groupPath?.clear();
  }

  void changeViewSize(LRect viewRect) {
    this.viewRect = viewRect;
    _scale = Vector3LinearScale(
      domainMin: Point3(domainRange.left, domainRange.top, 0),
      domainMax: Point3(domainRange.right, domainRange.bottom, 0),
      rangeMin: Point3(.0, .0, .0),
      rangeMax: Point3(viewRect.width, viewRect.height, .0),
    );
    initPositions();
  }

  void initPositions() {
    _groupCords.clear();
    _groupCordsRange.clear();
    groupedData!.forEach((key, List list) {
      _groupCords[key] = Float32List(list.length * 2);
      int i = 0;
      double minX = 0, minY = 0, maxX = 0, maxY = 0;
      var domX, domY;
      for (List item in list) {
        domX = _xScaleMapper(item);
        domY = _yScaleMapper(item);
        Offset viewPoint = scale.scaleXY(domX, domY);
        _groupCords[key]![i * 2] = viewPoint.dx;
        _groupCords[key]![i * 2 + 1] = viewPoint.dy;
        minX = min(minX, viewPoint.dx);
        minY = min(minY, viewPoint.dy);
        maxX = max(maxX, viewPoint.dx);
        maxY = max(maxY, viewPoint.dy);
        i++;
      }
      _groupCordsRange[key] = Rect.fromLTRB(minX, minY, maxX, maxY);
    });
  }

  Color getValueColor(num value) {
    String c = _colorScale.call(value)!;
    return d4.Color.tryParse(c)!.flutterColor;
  }

  void _drawGroupedPoints(Canvas canvas, Paint paint, Rect targetRect, double radius, {int samplingCount = 0, double opacity = 1.0}) {
    var sortedLegends = legends!.sortedBy((e) => e.focused ? 1 : -1);
    double percent;
    for (var legend in sortedLegends) {
      Float32List? originList = groupCords[legend.name];
      if (originList == null) return;

      percent = originList.length / 2 / cellCount;
      var len = min(2 * (samplingCount * percent).clamp(2000, 200000).toInt(), originList.length);
      // print('${legend}, ${len / 2}');
      if (samplingCount > 0) originList = originList.sublist(0, len);

      canvas.drawRawPoints(
        PointMode.points,
        originList,
        paint..color = legend.drawColor.withOpacity(opacity),
      );
    }
  }

  void _drawPoints(Canvas canvas, Paint paint, Rect targetRect, double radius) {
    var _domainRect = scale.revertRect(targetRect);
    // double _scale = matrix4.getMaxScaleOnAxis();

    var pointRect;
    var color;
    double x, y;
    for (List item in genePlotData) {
      x = _xScaleMapper(item);
      y = _yScaleMapper(item);
      if (!_domainRect.contains(Offset(x, y))) continue;

      Offset scaledDomainPoint = scale.scaleXY(x, y);
      pointRect = Rect.fromCircle(center: scaledDomainPoint, radius: radius);
      color = getValueColor(item[1]);

      // if (_scale * radius * 2 <= 4) {
      //   //draw rect
      //   canvas.drawRect(pointRect, paint..color = color);
      // } else {
      //draw oval
      canvas.drawOval(pointRect, paint..color = color);
      //path.addOval(pointRect);
      // }
    }
  }

  void transformAndDraw(Canvas canvas, Paint paint, Rect targetRect, double radius, {int samplingCount = 0, double opacity = 1.0}) {
    // _drawPoints(canvas, paint, matrix4, targetRect, radius);
    if (_groupCords.length > 0) {
      _drawGroupedPoints(canvas, paint, targetRect, radius, samplingCount: samplingCount, opacity: opacity);
    } else {
      _drawPoints(canvas, paint, targetRect, radius);
    }
  }

  //search item by cursor point
  List? searchInCords(Offset scenePoint, double pointSize) {
    List? result;
    for (String key in _groupCords.keys) {
      int length = _groupCords[key]!.length;
      if (length == 0) continue;
      if (!_groupCordsRange[key]!.contains(scenePoint)) continue;

      for (int i = 0; i < _groupCords[key]!.length; i += 2) {
        var rect = Rect.fromCenter(center: Offset(_groupCords[key]![i], _groupCords[key]![i + 1]), width: pointSize, height: pointSize);
        if (rect.contains(scenePoint)) {
          var index = i ~/ 2;
          // result = [key, index, groupedData![key]![index]];
          result = groupedData![key]![index];
          break;
        }
      }
      if (result != null) break;
    }
    return result;
  }
}
