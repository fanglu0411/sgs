import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_genome/cell/data_category.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/chart/scale/point.dart';
import 'package:flutter_smart_genome/chart/scale/vector_scale_ext.dart';
import 'package:flutter_smart_genome/chart/scale/vector_linear_scale.dart';
import 'dart:math' show Point, Random, max, min, sqrt;
import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/scatter_label_position.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/track/base/types.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

import 'l_rect.dart';

class DensityGroupPlotMatrix<T> {
  final int CORD_SIZE = 65536;

  //这个表示最小bin单元， 比如按64 来分
  Point<double>? domainBlockSize;

  bool _densityMode = false;

  bool get enableDensityMode => _densityMode;

  //分割的块数 x, y
  Point<int>? divisions;

  Point<int>? _rowRange;
  Point<int>? _colRange;

  // Map<String, GridCord<T>> _groupMatrixMap;
  GridCordGrouped<T>? _cord;

  List<double>? _scales;

  /// 缩放尺度需要合并的块
  int mergeBlockCount = 1;

  Map<String, List> groupData;
  LRect viewRect;
  LRect domainRange;

  late Vector3LinearScale _scale;

  Vector3LinearScale get scale => _scale;

  Map<String, Path>? _groupPath;

  //当前需要绘制的区域坐标
  Map<String, Float32List> _groupCords = <String, Float32List>{};

  Map<String, Float32List> get groupCords => _groupCords;

  Map<String, LRect> _groupCordsRange = {};

  getGroupCords(String group) {
    return _groupCords[group];
  }

  ///label position
  Map<String, ScatterLabel> _groupLabelMap = {};
  List<ScatterLabel> _labels = [];

  Map<String, ScatterLabel> get groupLabelMap => _groupLabelMap;

  Map<String, List>? _selectedCells;

  /// store user manual circled points
  Map<String, Float32List> _selectedPoints = <String, Float32List>{};

  Map<String, List>? get selectedCells => _selectedCells;

  void clearSelectedCells() {
    _selectedCells?.clear();
    _selectedCells = null;
    // _selectedPoints?.clear();
    _selectedPoints.clear();
  }

  Map<String, Float32List> get selectedPoints => _selectedPoints;

  double? maxScale;

  static final MAX_DOMAIN = 65535;

  final MAX_SCREEN_COUNT = 8000; //图表可见区域最多的点的数量

  // Map<String, DataCategory>? legendMap;

  Map<String, Path>? get groupPath => _groupPath;

  // List<DataCategory>? get legends => legendMap?.values?.toList();

  List<String> categories;

  // num _cellCount = 0;

  bool cartesian = false;

  bool isSpatial = false;
  num? spatialScaleFactor;

  (int x, int y, SpatialCordScaleType cordScaleBy)? cordMaxValue;

  int get cellCount => _statics.$5;

  late Scale<num, num> _domainScaleX;
  late Scale<num, num> _domainScaleY;

  // double _maxX = 0, _maxY = 0, _minX = 0, _minY = 0;
  (double minx, double maxx, double miny, double maxy, int cellCount) _statics = (0, 0, 0, 0, 0);

  late List<int> _fitMax;

  Scale<num, num> get domainScale => _domainScaleX;

  Scale<num, num> get domainScaleY => _domainScaleY;

  late dx.Function1<List, double> _xScaleMapper;
  late dx.Function1<List, double> _yScaleMapper;

  double _xMapper(dynamic list) {
    List _list = list as List;
    return (_list[1]).toDouble();
  }

  double _yMapper(dynamic list) {
    List _list = list;
    return _list[2].toDouble();
  }

  // double _xScaleMapper(List list) {
  //   return _domainScaleX.scale(list[1])!;
  //   // return list[1];
  // }

  // double _yScaleMapper(List list) {
  //   return isSpatial ? _domainScaleY.scale(list[2])! : (MAX_DOMAIN - _domainScaleY.scale(list[2])!);
  //   // return list[2];
  // }

  // Map<String, List<vm.Vector3>> pointsMap = {};

  late double viewScale;

  DensityGroupPlotMatrix({
    required this.groupData,
    required this.viewRect,
    required this.domainRange,
    required this.categories,
    required Map<String, DataCategory> legendMap,
    this.isSpatial = false,
    // required this.cartesian,
    this.domainBlockSize,
    this.cordMaxValue,
    this.spatialScaleFactor,
    this.viewScale = 1.0,
  }) {}

  Future init(Map<String, DataCategory> legendMap) async {
    //sort data
    for (String key in groupData.keys) {
      legendMap[key]?.count = groupData[key]!.length;
      groupData[key] = groupData[key]!.sortedBy((e) => e[1]).thenBy((e) => e[2]).toList();
    }

    _groupPath = groupData.map((key, value) => MapEntry(key, Path()));

    countingMinMax();
    // _statics = await cordUtil.countingMinMax(groupData);
    var (_minX, _maxX, _minY, _maxY, _cellCount) = _statics;
    List<int> dataMax = _calculateFitableMaxValue([_minX, _maxX, _minY, _maxY]);
    _fitMax = fitDataRangeForSpatial(dataMax) ?? dataMax;
    logger.d('---->> dataMax: $dataMax, calculated: ${cordMaxValue} fit max: $_fitMax, ${viewRect}');

    _densityMode = _cellCount >= 600000;
    _densityMode = false;

    initScales();

    maxScale = ((_cellCount / MAX_SCREEN_COUNT) * 32).clamp(32.0, (MAX_DOMAIN + 1) / 64);
    _groupLabelMap = {};

    // if (_densityMode) {
    domainBlockSize ??= Point(256.0, 256.0);
    divisions = Point<int>(domainWidth ~/ domainBlockSize!.x, domainHeight ~/ domainBlockSize!.y);
    _rowRange = Point<int>(0, rowCount - 1);
    _colRange = Point<int>(0, colCount - 1);
    _cord = GridCordGrouped(makeMatrix(), categories);

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

    _parseGroupedData(groupData);
    updateLabelRect();
    await initialPointPosition();
  }

  void initScales() {
    _scale = isSpatial && spatialScaleFactor != null
        ? Vector3LinearScale(
            domainMin: Point3.xyz(0, 0, 0),
            domainMax: Point3.xyz(viewRect.width, viewRect.height, 0),
            rangeMin: Point3(0.0, 0.0, 0.0),
            rangeMax: Point3(viewRect.width, viewRect.height, .0),
          )
        : Vector3LinearScale(
            domainMin: Point3(domainRange.left, domainRange.top, 0),
            domainMax: Point3(domainRange.right, domainRange.bottom, 0),
            rangeMin: Point3(0.0, 0.0, 0.0),
            rangeMax: Point3(viewRect.width, viewRect.height, .0),
          );

    _domainScaleX = ScaleLinear.number(domain: [_fitMax[0], _fitMax[1]], range: [.0, MAX_DOMAIN]);
    _domainScaleY = ScaleLinear.number(domain: [_fitMax[2], _fitMax[3]], range: [.0, MAX_DOMAIN]);

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
  }

  List<int>? fitDataRangeForSpatial(List<int> dataMax) {
    List<int>? targetCordRange = null;
    if (cordMaxValue != null) {
      var (int x, int y, SpatialCordScaleType cordScaleBy) = cordMaxValue!;
      switch (cordScaleBy) {
        case SpatialCordScaleType.width:
          if (dataMax[1] < x) {
            targetCordRange = [0, x, 0, x];
          } else {
            targetCordRange = [dataMax[0], dataMax[1], dataMax[0], dataMax[1]];
          }
          break;
        case SpatialCordScaleType.height:
          if (dataMax[3] < y) {
            targetCordRange = [0, y, 0, y];
          } else {
            targetCordRange = [dataMax[2], dataMax[3], dataMax[2], dataMax[3]];
          }
          break;
        case SpatialCordScaleType.both:
          targetCordRange = [
            0,
            dataMax[1] < x ? x : dataMax[1],
            0,
            dataMax[3] < y ? y : dataMax[3],
          ];
          break;
      }
    }
    return targetCordRange;
  }

  countingMinMax() {
    int _cellCount = 0;
    double _maxX = 0, _maxY = 0, _minX = 0, _minY = 0;
    groupData.forEach((group, List list) {
      if (list.length == 0) return;
      _cellCount += list.length;
      for (var item in list) {
        _minX = min(_minX, _xMapper(item));
        _maxX = max(_maxX, _xMapper(item));
        _minY = min(_minY, _yMapper(item));
        _maxY = max(_maxY, _yMapper(item));
      }
    });
    _statics = (_minX, _maxX, _minY, _maxY, _cellCount);
  }

  void _parseGroupedData(Map<String, List> data) {
    var entries = data.entries;
    for (var entry in entries) {
      num dx, dy; //domain x, domain y
      int row, col;
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

  Future initialPointPosition() async {
    _groupCords.clear();
    _groupCordsRange.clear();
    groupData.forEach((key, List list) {
      list.shuffle();
      _groupCords[key] = Float32List(list.length * 2);
      int i = 0;
      double minX = 0, minY = 0, maxX = 0, maxY = 0;
      // double vx, vy;
      for (List item in list) {
        // Offset domainPoint = Offset(_xScaleMapper(item), _yScaleMapper(item));
        Point<double> viewPoint = scale.scalePoint(_xScaleMapper(item), _yScaleMapper(item));
        _groupCords[key]![i * 2] = viewPoint.x;
        _groupCords[key]![i * 2 + 1] = viewPoint.y;
        minX = min(minX, viewPoint.x);
        minY = min(minY, viewPoint.y);
        maxX = max(maxX, viewPoint.x);
        maxY = max(maxY, viewPoint.y);
        i++;
      }
      _groupCordsRange[key] = LRect.LTRB(minX, minY, maxX, maxY);
    });

    _selectedCells?.forEach((key, List list) {
      int i = 0;
      List<double> findPoints = List.empty(growable: true);
      for (List item in list) {
        // Offset domainPoint = Offset(_xScaleMapper(item), _yScaleMapper(item));
        Point<double> viewPoint = scale.scalePoint(_xScaleMapper(item), _yScaleMapper(item));
        findPoints.add(viewPoint.x);
        findPoints.add(viewPoint.y);
        i++;
      }
      _selectedPoints[key] = Float32List.fromList(findPoints);
    });
  }

  List<List<CordBlockGrouped<T>?>> makeMatrix<T>() {
    return List.generate(divisions!.y, (r) => List.generate(divisions!.x, (c) => null));
  }

  int get rowCount => divisions!.x;

  int get colCount => divisions!.y;

  double get domainWidth => domainRange.right - domainRange.left + 1;

  double get domainHeight => domainRange.bottom - domainRange.top + 1;

  List<int> _calculateFitableMaxValue(List<num> value) {
    if (value[1] > 50000 || value[3] > 50000) return [0, MAX_DOMAIN, 0, MAX_DOMAIN];
    var xabs = max(value[0].abs(), value[1].abs()).ceil();
    var yabs = max(value[2].abs(), value[3].abs()).ceil();
    return [
      value[0] < 0 ? -xabs : 0,
      xabs, // value[1].ceil(),
      value[2] < 0 ? -yabs : 0,
      yabs, //value[3].ceil(),
    ];
  }

  void changeViewSize(LRect viewRect) {
    this.viewRect = viewRect;
    _scale = isSpatial && spatialScaleFactor != null
        ? Vector3LinearScale(
            domainMin: Point3.xyz(0, 0, 0),
            domainMax: Point3.xyz(viewRect.width, viewRect.height, 0),
            rangeMin: Point3(0.0, 0.0, 0.0),
            rangeMax: Point3(viewRect.width, viewRect.height, .0),
          )
        : Vector3LinearScale(
            domainMin: Point3(domainRange.left, domainRange.top, 0),
            domainMax: Point3(domainRange.right, domainRange.bottom, 0),
            rangeMin: Point3(0.0, 0.0, 0.0),
            rangeMax: Point3(viewRect.width, viewRect.height, .0),
          );
    updateLabelRect();
    initialPointPosition();
  }

  forEach(int mergeBlock, dx.Function1<CordBlockGrouped<T>?, void> callback) {
    if (mergeBlockCount > 1) {
      _cord!.forEachMerge(_rowRange!, _colRange!, mergeBlockCount, callback);
    } else {
      _cord!.forEach(_rowRange!, _colRange!, callback);
    }
  }

  void transform2(Matrix4 matrix, LRect targetRect, double radius) {
    if (!enableDensityMode) {
      transform(matrix, targetRect, radius);
      return;
    }

    double _scale = matrix.getMaxScaleOnAxis();
    int __scale = _scale.floor();
    LRect domainRect = scale.revertLRect(targetRect);

    int minRow = domainRect.top ~/ domainBlockSize!.y;
    int maxRow = min((domainRect.bottom / domainBlockSize!.y).ceil(), divisions!.y - 1);

    int minCol = domainRect.left ~/ domainBlockSize!.x;
    int maxCol = min((domainRect.right / domainBlockSize!.y).ceil(), divisions!.y - 1);

    _rowRange = Point(minRow, maxRow);
    _colRange = Point(minCol, maxCol);

    int scaleTimes = __scale ~/ 2;
    // print('scale Times: ${scaleTimes}, scales: ${_scales}, scale: ${_scale}, radius: $radius');

    mergeBlockCount = 1;
    if (_scales!.length > scaleTimes) {
      mergeBlockCount = 2 * (_scales!.length - scaleTimes);
    }
    // print('row: ${_rowRange}, col: ${_colRange}, mergeBlocks: $mergeBlocks');

    if (mergeBlockCount > 1) {
      Point blockSize = Point(viewRect.width / divisions!.x, viewRect.height / divisions!.y);
      // 不用合并 col row
      // _rowRange = Point3(max((minRow / mergeBlocks).floor() - 1, 0), (maxRow / mergeBlocks).ceil() + 1);
      // _colRange = Point3(max((minCol / mergeBlocks).floor() - 1, 0), (maxCol / mergeBlocks).ceil() + 1);
      _groupPath!.forEach((key, value) => value.reset());
      LRect rect;

      _cord!.forEachMerge(_rowRange!, _colRange!, mergeBlockCount, (CordBlockGrouped? block) {
        if (null != block && block.count > 0) {
          rect = block.getRect(blockSize, mergeBlockCount);
          block.groupCountMap.forEach((group, count) {
            if (count > 0) _groupPath![group]!.addRect(Rect.fromLTRB(rect.left, rect.top, rect.right, rect.bottom));
          });
        }
      });
    } else {
      double _x, _y;
      Map<String, List<double>> _cordsMap = Map.fromIterables(categories.map<String>((e) => e), categories.map<List<double>>((e) => <double>[]));
      _cord!.forEach(_rowRange!, _colRange!, (CordBlockGrouped? block) {
        if (block == null) return;
        block.groupList.forEach((group, data) {
          if (data != null && data.length > 0) {
            data.forEach((e) {
              _x = scale.scaleX(_xScaleMapper(e));
              _y = scale.scaleY(_yScaleMapper(e));
              _cordsMap[group]!.addAll([_x, _y]);
            });
          }
        });
      });

      _cordsMap.forEach((key, list) {
        _groupCords[key] = Float32List.fromList(list);
      });
    }
    // print('combined: row: ${_rowRange}, col: ${_colRange}');
    // print('combine count: ${combineCount}, __scale:$__scale');
  }

  void findCellByPath(Matrix4 matrix4, Path path) {
    var startTime = DateTime.now();

    Map<String, List<List>> findTargets = {};
    List<double> findPoints = List.empty(growable: true);
    groupData.forEach((key, List list) {
      int i = 0;
      double vx, vy;
      for (List item in list) {
        // Offset domainPoint = Offset(_xScaleMapper(item), _yScaleMapper(item));
        // Point<double> viewPoint = scale.scalePoint(_xScaleMapper(item), _yScaleMapper(item));
        Offset viewPoint = scale.scaleXY(_xScaleMapper(item), _yScaleMapper(item));
        if (path.contains(viewPoint)) {
          findTargets[key] ??= [];
          findTargets[key]!.add(item);
          findPoints.add(viewPoint.dx);
          findPoints.add(viewPoint.dy);
        }
        i++;
      }
    });
    if (findPoints.isNotEmpty) {
      _selectedCells = findTargets;
      String key = 'path-${Random().nextInt(10000)}-${Random().nextInt(10000)}';
      _selectedPoints[key] = Float32List.fromList(findPoints);
    } else {
      // _selectedCells = null;
      // _selectedPoints = null;
    }
    debugPrint('find cost : ${DateTime.now().millisecondsSinceEpoch - startTime.millisecondsSinceEpoch} ms');
  }

  void transform(Matrix4 matrix4, LRect targetRect, double radius) {
    // var _domainRect = scale.revertRect(targetRect);
    // double _scale = matrix4.getMaxScaleOnAxis();
    // var domOfPixel = 65536 / (viewRect.width * _scale);
    // print('targetRect: $targetRect, scale: $_scale, domOfPixel:$domOfPixel');
    groupData.forEach((key, List list) {
      if (_groupCords[key] == null) {
        _groupCords[key] = Float32List(list.length * 2);
      } else {
        return;
      }
      int i = 0;
      for (List item in list) {
        // Offset domainPoint = Offset(_xScaleMapper(item), _yScaleMapper(item));
        // if (!_domainRect.contains(domainPoint.offset)) continue;
        Point<double> viewPoint = scale.scalePoint(_xScaleMapper(item), _yScaleMapper(item));
        _groupCords[key]![i * 2] = viewPoint.x;
        _groupCords[key]![i * 2 + 1] = viewPoint.y;
        i++;
      }
    });
  }

  searchInCords(Point scenePoint, double pointSize) {
    List? result;
    for (String key in _groupCords.keys) {
      int length = _groupCords[key]!.length;
      if (length == 0) continue;
      if (!_groupCordsRange[key]!.contains(scenePoint)) continue;

      for (int i = 0; i < _groupCords[key]!.length; i += 2) {
        var rect = LRect.fromCenter(center: Point(_groupCords[key]![i], _groupCords[key]![i + 1]), width: pointSize, height: pointSize);
        if (rect.contains(scenePoint)) {
          var index = i ~/ 2;
          result = [key, index, groupData[key]![index]];
          break;
        }
      }
      if (result != null) break;
    }
    return result;
  }

  List? find(Point scenePoint, Matrix4 matrix, double pointSize) {
    return searchInCords(scenePoint, pointSize);
  }

  /// 这里不用处理，scatter绘制的时候 自动根据 cat.focused 绘制是否选中颜色
  void changeSelection(DataCategory cat) {
    // do nothing
  }

  void dispose() {
    _cord?.clear();
    _cord = null;
    groupData.clear();
    _groupCords.clear();
    _selectedCells?.clear();
    _selectedPoints.clear();
    _groupLabelMap.clear();
    _labels.clear();
  }

  clear() {
    _cord?.clear();
    _cord = null;
    _groupCords.clear();
    _labels.clear();
    // _groupCords = null;
  }
}

class MaxDensityInfo {
  int count = 0;
  int? col;
  int? row;

  bool get isEmpty => count == 0;

  MaxDensityInfo({this.col, this.row, this.count = 0});

  @override
  String toString() {
    return 'MaxDensityInfo{count: $count, col: $col, row: $row}';
  }
}

class GridCordGrouped<T> {
  int blockMaxCount = 0;
  int maxCountCol = 0;
  int maxCountRow = 0;

  late Map<String, MaxDensityInfo> groupMaxDensityInfo;

  GridCordGrouped(this._blockMatrix, List<String> category) {
    groupMaxDensityInfo = Map.fromIterables(category, category.map((e) => MaxDensityInfo()));
  }

  List<List<CordBlockGrouped<T>?>> _blockMatrix;

  List<List<CordBlockGrouped<T>?>> get matrix => _blockMatrix;

  int get rowCount => _blockMatrix.length;

  int get colCount => _blockMatrix.first.length;

  checkMax(String group, int totalCount, int groupCount, int row, int col) {
    if (groupMaxDensityInfo[group]!.count <= groupCount) {
      groupMaxDensityInfo[group]!.col = col;
      groupMaxDensityInfo[group]!.row = row;
      groupMaxDensityInfo[group]!.count = groupCount;
    }
    if (blockMaxCount < totalCount) {
      maxCountCol = col;
      maxCountRow = row;
      blockMaxCount = totalCount;
    }
  }

  CordBlockGrouped<T>? get({required int row, required int col, bool autoInit = false}) {
    try {
      if (_blockMatrix[row][col] == null && autoInit) _blockMatrix[row][col] = CordBlockGrouped(x: col, y: row);
      return _blockMatrix[row][col];
    } catch (e) {
      return null;
    }
  }

  Color blockGroupedColor(String group, CordBlockGrouped block, Color color) {
    return color.withOpacity((block.groupCount(group) / groupMaxDensityInfo[group]!.count).clamp(0.0, 1.0));
  }

  Color blockColor(CordBlockGrouped block, Color color) {
    return color.withOpacity((block.count / blockMaxCount).clamp(0.0, 1.0));
    // return Color.lerp(Colors.white, color, block.count / blockMaxCount);
  }

  ///合并 后 循环
  forEachMerge(Point<int> _rowRange, Point<int> _colRange, int mergeBlocks, dx.Function1<CordBlockGrouped<T>, void> callback) {
    for (int row = _rowRange.x.toInt(); row < _rowRange.y; row += mergeBlocks) {
      for (int col = _colRange.x.toInt(); col < _colRange.y; col += mergeBlocks) {
        // callback?.call(this, CordBlockGrouped(x: col, y: row)..count = sumRange(rect));
        callback.call(mergeBlockCount(col, row, mergeBlocks));
      }
    }
  }

  forEach(Point _rowRange, Point _colRange, dx.Function1<CordBlockGrouped<T>?, void> callback) {
    for (int row = _rowRange.x.toInt(); row < _rowRange.y; row++) {
      for (int col = _colRange.x.toInt(); col < _colRange.y; col++) {
        callback.call(this.get(row: row, col: col));
      }
    }
  }

  int sumRange(LRect rangeRect) {
    int count = 0;
    for (int row = rangeRect.top.toInt(); row < rangeRect.bottom; row++) {
      for (int col = rangeRect.left.toInt(); col < rangeRect.right; col++) {
        if (row >= rowCount || col >= colCount) continue;
        count += (this.get(row: row, col: col)?.count ?? 0);
      }
    }
    return count;
  }

  CordBlockGrouped<T> mergeBlockCount(int _col, int _row, int mergeBlocks) {
    var mergedBlock = CordBlockGrouped<T>(x: _col, y: _row);
    CordBlockGrouped? block = null;
    for (int row = _row; row < (_row + mergeBlocks); row++) {
      for (int col = _col; col < _col + mergeBlocks; col++) {
        if (row >= rowCount || col >= colCount) continue;
        block = this.get(row: row, col: col);
        if (null == block) continue;
        int? _count;
        for (var entry in block.groupCountMap.entries) {
          _count = mergedBlock.groupCountMap[entry.key];
          if (_count == null) {
            mergedBlock.groupCountMap[entry.key] = entry.value;
          } else {
            mergedBlock.groupCountMap[entry.key] = _count + entry.value;
          }
        }
        block.groupCountMap.forEach((group, count) {});
        mergedBlock.count += block.count;
      }
    }
    return mergedBlock;
  }

  void clear() {
    _blockMatrix.clear();
    // _blockMatrix = null;
  }

  @override
  String toString() {
    String s = 'row: ${_blockMatrix.length}, col: ${_blockMatrix.first.length}\n';
    // for (var row in _blockMatrix) {
    //   s += row.join(', ');
    // }
    return s;
  }
}

class CordBlockGrouped<T> {
  Map<String, List<T>?> groupList = {};
  int x;
  int y;

  int count = 0;

  Map<String, int> groupCountMap = {};

  CordBlockGrouped({required this.x, required this.y}) {}

  Point getOffset(Point blockSize) {
    return Point(x * blockSize.x, y * blockSize.y);
  }

  LRect getRect(Point blockSize, int mergeBlocks) {
    return LRect.LTWH(x * blockSize.x * 1.0, y * blockSize.y * 1.0, blockSize.x * mergeBlocks * 1.0, blockSize.y * mergeBlocks * 1.0);
  }

  int addItem(String group, T t) {
    if (groupList[group] == null) groupList[group] = [];
    groupList[group]!.add(t);
    count++;

    if (groupCountMap[group] == null) groupCountMap[group] = 0;
    groupCountMap[group] = groupCountMap[group]! + 1;

    return groupList[group]!.length;
  }

  int groupCount(String group) => groupList[group]?.length ?? 0;

  @override
  String toString() {
    return 'CordBlockGrouped{x: $x, y: $y, count: $count}';
  }
}
