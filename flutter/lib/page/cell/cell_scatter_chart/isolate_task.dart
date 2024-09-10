import 'dart:math' as math;
import 'dart:math';

import 'package:d4/d4.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_genome/chart/scale/linear_scale.dart';
import 'package:flutter_smart_genome/chart/scale/numeric_extents.dart';
import 'package:flutter_smart_genome/chart/scale/scale.dart';

import 'density_plot_matrix.dart';
import 'l_rect.dart';
import 'scatter_label_position.dart';

class CordUtil<T> {
  final int CORD_SIZE = 65536;
  int MAX_DOMAIN = 65535;

  //这个表示最小bin单元， 比如按64 来分
  Point<double>? domainBlockSize;

  late LRect domainRect;

  late List<num> fitDomainRange;

  late LinearScale _domainScaleX;
  late LinearScale _domainScaleY;

  late LinearScale xCordScale;
  late LinearScale yCordScale;

  bool isSpatial = false;
  num? spatialScaleFactor;
  double viewScale = 1.0;

  late Map<String, List> groupData;
  late Function _xScaleMapper;
  late Function _yScaleMapper;

  late LRect viewRect;
  double? maxScale;

  //分割的块数 x, y
  Point<int>? divisions;

  Point<int>? _rowRange;
  Point<int>? _colRange;

  // Map<String, GridCord<T>> _groupMatrixMap;
  GridCordGrouped<T>? _cord;
  List<double>? _scales;

  final MAX_SCREEN_COUNT = 8000; //图表可见区域最多的点的数量

  /// 缩放尺度需要合并的块
  int mergeBlockCount = 1;

  bool cartesian = false;

  ///label position
  Map<String, ScatterLabel> _groupLabelMap = {};
  List<ScatterLabel> _labels = [];

  //当前需要绘制的区域坐标
  Map<String, Float32List> _groupCords = <String, Float32List>{};

  Map<String, Float32List> get groupCords => _groupCords;

  Map<String, LRect> _groupCordsRange = {};

  Map<String, List>? _selectedCells;

  Map<String, List>? get selectedCells => _selectedCells;

  /// store user manual circled points
  Map<String, Float32List> _selectedPoints = <String, Float32List>{};

  Map<String, Float32List> get selectedPoints => _selectedPoints;

  double get domainWidth => domainRect.right - domainRect.left + 1;

  double get domainHeight => domainRect.bottom - domainRect.top + 1;

  bool _densityMode = false;

  (double minx, double maxx, double miny, double maxy, int cellCount) _statics = (0, 0, 0, 0, 0);

  double _xMapper(dynamic list) {
    List _list = list as List;
    return (_list[1]).toDouble();
  }

  double _yMapper(dynamic list) {
    List _list = list;
    return _list[2].toDouble();
  }

  CordUtil({
    required this.fitDomainRange,
    required this.domainRect,
    required this.viewRect,
    required this.groupData,
    this.isSpatial = false,
    this.spatialScaleFactor,
    this.domainBlockSize,
  }) {}

  void changeViewSize(LRect viewRect) {
    this.viewRect = viewRect;
    xCordScale = (isSpatial && spatialScaleFactor != null)
        ? LinearScale(domain: NumericExtents(0, viewRect.width), range: ScaleOutputExtent(0, viewRect.width))
        : LinearScale(
            domain: NumericExtents(domainRect.left, domainRect.right),
            range: ScaleOutputExtent(0, viewRect.width),
          );
    yCordScale = (isSpatial && spatialScaleFactor != null)
        ? LinearScale(domain: NumericExtents(0, viewRect.width), range: ScaleOutputExtent(0, viewRect.width))
        : LinearScale(
            domain: NumericExtents(domainRect.top, domainRect.bottom),
            range: ScaleOutputExtent(0, viewRect.height),
          );

    updateLabelRect();
    calculateCords();
  }

  void init() {
    _statics = countingMinMax(groupData);
    var (_minX, _maxX, _minY, _maxY, _cellCount) = _statics;

    _densityMode = _cellCount >= 600000;
    _densityMode = false;

    _domainScaleX = LinearScale(domain: NumericExtents(fitDomainRange[0], fitDomainRange[1]), range: ScaleOutputExtent(0, MAX_DOMAIN));
    _domainScaleY = LinearScale(domain: NumericExtents(fitDomainRange[2], fitDomainRange[3]), range: ScaleOutputExtent(0, MAX_DOMAIN));

    _xScaleMapper = isSpatial && spatialScaleFactor != null
        ? (List list) {
            return list[1] * spatialScaleFactor * viewScale;
          }
        : (List list) {
            return _domainScaleX.scale(list[1])!;
          };

    _yScaleMapper = isSpatial
        ? (List list) {
            return spatialScaleFactor != null ? list[2] * spatialScaleFactor * viewScale : _domainScaleY.scale(list[2]);
          }
        : (List list) {
            return (MAX_DOMAIN - _domainScaleY.scale(list[2])!);
          };

    xCordScale = (isSpatial && spatialScaleFactor != null)
        ? LinearScale(domain: NumericExtents(0, viewRect.width), range: ScaleOutputExtent(0, viewRect.width))
        : LinearScale(
            domain: NumericExtents(domainRect.left, domainRect.right),
            range: ScaleOutputExtent(0, viewRect.width),
          );
    yCordScale = (isSpatial && spatialScaleFactor != null)
        ? LinearScale(domain: NumericExtents(0, viewRect.width), range: ScaleOutputExtent(0, viewRect.width))
        : LinearScale(
            domain: NumericExtents(domainRect.top, domainRect.bottom),
            range: ScaleOutputExtent(0, viewRect.height),
          );
  }

  Future hardWork() async {
    init();

    var (_minX, _maxX, _minY, _maxY, _cellCount) = _statics;

    _parseGroupedData();

    final _blockAvgCount = _cellCount / ((CORD_SIZE / domainBlockSize!.x) * (CORD_SIZE / domainBlockSize!.y));
    double minBlockCount = sqrt(MAX_SCREEN_COUNT / _blockAvgCount);
    // print('-> max scale: ${maxScale}, avg count: ${_blockAvgCount}, minBlockCount: $minBlockCount');

    double minScale = viewRect.width / domainWidth;
    _scales = [minScale];
    int blockCount = (CORD_SIZE ~/ (domainBlockSize!.x));

    while (blockCount > minBlockCount) {
      _scales!.add(_scales!.last * 2);
      blockCount ~/= 2;
    }

    calculateCords();
  }

  void _parseGroupedData() {
    var entries = groupData.entries;
    for (var entry in entries) {
      // _parseSingleGroup(entry.key, entry.value);
      num dx, dy; //domain x, domain y
      int row, col;
      // GridCord<T> _cord = GridCord(makeMatrix<T>(), name: group);
      // _groupMatrixMap[group] = _cord;
      int count;
      for (T t in entry.value) {
        dx = _xScaleMapper(t as List);
        dy = _yScaleMapper(t);
        row = (dy / domainBlockSize!.y).floor(); // math.min(row, divisions.y - 1);
        col = (dx / domainBlockSize!.x).floor(); // math.min(, divisions.x - 1);
        count = _cord!.get(row: row, col: col, autoInit: true)?.addItem(entry.key, t) ?? 0;
        _cord!.checkMax(entry.key, _cord!.blockMaxCount, count, row, col);
      }
    }
    // updateLabelRect();
  }

  countingMinMax(Map<String, List> groupData) {
    int _cellCount = 0;
    double _maxX = 0, _maxY = 0, _minX = 0, _minY = 0;
    groupData.forEach((group, List list) {
      if (list.length == 0) return;
      _cellCount += list.length;
      for (var item in list) {
        _minX = math.min(_minX, _xMapper(item));
        _maxX = math.max(_maxX, _xMapper(item));
        _minY = math.min(_minY, _yMapper(item));
        _maxY = math.max(_maxY, _yMapper(item));
      }
    });
    _statics = (_minX, _maxX, _minY, _maxY, _cellCount);
  }

  void calculateCords() {
    _groupCords.clear();
    _groupCordsRange.clear();
    groupData.forEach((key, List list) {
      list.shuffle();
      _groupCords[key] = Float32List(list.length * 2);
      int i = 0;
      double minX = 0, minY = 0, maxX = 0, maxY = 0;
      double vx, vy;
      for (List item in list) {
        var domainPoint = (_xScaleMapper(item), _yScaleMapper(item));
        vx = xCordScale.scale(domainPoint.$1)!.toDouble();
        vy = yCordScale.scale(domainPoint.$2)!.toDouble();
        // Offset viewPoint = scale.scaleOffset(domainPoint);

        _groupCords[key]![i * 2] = vx;
        _groupCords[key]![i * 2 + 1] = vy;
        minX = math.min(minX, vx);
        minY = math.min(minY, vy);
        maxX = math.max(maxX, vx);
        maxY = math.max(maxY, vy);
        i++;
      }
      _groupCordsRange[key] = LRect.LTRB(minX, minY, maxX, maxY);
      // _groupCordsRange[key] = [minX, minY, maxX, maxY];
    });

    // Map<String, Float32List> _selectedGroupCords = {};
    _selectedCells?.forEach((key, List list) {
      _selectedPoints[key] = Float32List(list.length * 2);
      int i = 0;
      double vx, vy;
      for (List item in list) {
        var domainPoint = (_xScaleMapper(item), _yScaleMapper(item));
        vx = xCordScale.scale(domainPoint.$1)!.toDouble();
        vy = yCordScale.scale(domainPoint.$2)!.toDouble();
        // Offset viewPoint = scale.scaleOffset(domainPoint);
        _selectedPoints[key]![i * 2] = vx;
        _selectedPoints[key]![i * 2 + 1] = vy;
        i++;
      }
    });

    // return Future.value((_groupCords, _groupCordsRange, _selectedGroupCords));
  }

  Future<Map<String, Float32List>> calculateSelectedCords(Map<String, List> groupData) {
    Map<String, Float32List> _groupCords = {};
    groupData.forEach((key, List list) {
      list.shuffle();
      _groupCords[key] = Float32List(list.length * 2);
      int i = 0;
      double vx, vy;
      for (List item in list) {
        var domainPoint = (_xScaleMapper(item), _yScaleMapper(item));
        vx = xCordScale.scale(domainPoint.$1).toDouble();
        vy = yCordScale.scale(domainPoint.$2).toDouble();
        // Offset viewPoint = scale.scaleOffset(domainPoint);
        _groupCords[key]![i * 2] = vx;
        _groupCords[key]![i * 2 + 1] = vy;
        i++;
      }
    });
    return Future.value(_groupCords);
  }

  void updateLabelRect() {
    double blockViewSize = viewRect.width / divisions!.x;
    _cord?.groupMaxDensityInfo.forEach((key, info) {
      if (info.isEmpty) return;
      var rect = LRect.LTWH(info.col! * blockViewSize, info.row! * blockViewSize, blockViewSize, blockViewSize);
      _groupLabelMap[key] = ScatterLabel(key, rect.center);
    });
    if (_groupLabelMap.keys.length < 20) {
      resolveOverlaps(_groupLabelMap.values.toList(), viewRect.width, viewRect.height);
    }
  }

  List<int> _calculateFitableMaxValue(List<num> value) {
    if (value[1] > 50000 || value[3] > 50000) return [0, MAX_DOMAIN, 0, MAX_DOMAIN];
    var xabs = math.max(value[0].abs(), value[1].abs()).ceil();
    var yabs = math.max(value[2].abs(), value[3].abs()).ceil();
    return [
      value[0] < 0 ? -xabs : 0,
      xabs, // value[1].ceil(),
      value[2] < 0 ? -yabs : 0,
      yabs, //value[3].ceil(),
    ];
  }
}
