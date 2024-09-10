import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter_smart_genome/cell/data_category.dart';
import 'package:flutter_smart_genome/chart/scale/vector_scale_ext.dart';
import 'package:flutter_smart_genome/util/file_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/chart/scale/point.dart';
import 'package:flutter_smart_genome/chart/scale/vector_linear_scale.dart';
import 'package:flutter_smart_genome/widget/upload/platform_entry.dart';

import 'package:flutter_smart_genome/extensions/rect_extension.dart';

import 'package:flutter_smart_genome/d3/color/schemes.dart' as colorScheme;

typedef num ValueMapper<T>(T t);
typedef Color ColorMapper<T>(T t);
typedef List LineMapper(String t);

///
///this class store point data using matrix with by rows and columns
///for combine data with scale
///
class DensityCords<T> {
  final int CORD_SIZE = 65536;

  List<T>? source;

  Vector3LinearScale? _scale;

  //这个表示最小bin单元， 比如按100 来分
  Point3<double>? domainBlockSize;

  //分割的块数 x, y
  Point3<int>? divisions;

  // List<List<CordBlock<T>>> _matrixData;
  Map<String, GridCord<T>>? _groupMatrixMap;

  //这个表示最小文件分割最小单元 比如 3000
  Point3<double>? storeDomainBlockSize;
  Point3<int>? storeDivisions;

  ValueMapper<T> xMapper;
  ValueMapper<T> yMapper;
  ColorMapper<T> colorMapper;

  Map<dynamic, DataCategory> clusterMap = {};

  Rect? domainRange;

  late Rect viewRect;

  int get rowCount => divisions!.x;

  int get colCount => divisions!.y;

  Point3<int>? _rowRange;
  Point3<int>? _colRange;

  Set? __clusterSet;
  Directory? workDir;
  Directory? _docDir;
  DateTime? _parseStart;
  int _cordCount = 0;

  Map<String, List<List>> _blockMap = {};

  List<double>? _scales;

  Vector3LinearScale? get scale => _scale;

  // List<List<CordBlock<T>>> get dataMatrix => _matrixData;

  UploadFileItem? _fileItem;

  double? _maxScale;

  double? get maxScale => _maxScale;

  double? _blockAvgCount;

  final MAX_SCREEN_COUNT = 8000; //图表可见区域最多的点的数量

  double get domainWidth => domainRange!.right - domainRange!.left + 1;

  double get domainHeight => domainRange!.bottom - domainRange!.top + 1;

  //数量最大的那一块数量
  // int _blockMaxCount = 0;

  /// 缩放尺度需要合并的块
  int mergeBlocks = 1;

  GridCord<T> getCord(String group) {
    return _groupMatrixMap![group]!;
  }

  DensityCords.loadAsync({
    required this.viewRect,
    required this.xMapper,
    required this.yMapper,
    required this.colorMapper,
    required this.domainBlockSize,
    required this.domainRange,
  }) {}

  DensityCords.fromGroupedData({
    required Map<String, List> data,
    required this.viewRect,
    required this.xMapper,
    required this.yMapper,
    required this.colorMapper,
    this.domainBlockSize,
    required this.domainRange,
  }) {
    _scale = Vector3LinearScale(
      domainMin: Point3(domainRange!.left, domainRange!.top, 0),
      domainMax: Point3(domainRange!.right, domainRange!.bottom, 0),
      rangeMin: Point3(.0, .0, .0),
      rangeMax: Point3(viewRect.width, viewRect.height, .0),
    );

    init();
    _parseGroupedData(data);
  }

  // domain range [0, 1]
  // view range   [0, 100]
  // cut the view to (width / density) * (width / density) blocks
  ///
  DensityCords({
    required this.source,
    required this.viewRect,
    required this.xMapper,
    required this.yMapper,
    required this.colorMapper,
    this.domainBlockSize,
    this.domainRange,
  }) {
    if (domainRange == null) {
      _calculateDataRange();
    }
    _scale = Vector3LinearScale(
      domainMin: Point3(domainRange!.left, domainRange!.top, 0),
      domainMax: Point3(domainRange!.right, domainRange!.bottom, 0),
      rangeMin: Point3(.0, .0, .0),
      rangeMax: Point3(viewRect.width, viewRect.height, .0),
    );

    init();
    _parseData();
  }

  void _parseData() {
    var _cord = GridCord(makeMatrix(), name: 'def-group');
    _groupMatrixMap!['def-group'] = _cord;

    num dx, dy; //domain x, domain y
    int row, col;
    int count;
    for (T t in source!) {
      dx = xMapper.call(t) - domainRange!.topLeft.dx;
      dy = yMapper.call(t) - domainRange!.topLeft.dy;
      row = math.min((dy / domainBlockSize!.y).floor(), divisions!.y - 1);
      col = math.min((dx / domainBlockSize!.x).floor(), divisions!.x - 1);
      count = _cord.get(row: row, col: col).addItem(t);
      // _matrixData[row][col].addItem(t);
      _cord.blockMaxCount = math.max(count, _cord.blockMaxCount);
    }
    _cordCount = source!.length;
    source?.clear();
    source = null;
    //todo call parse finish
  }

  void _parseGroupedData(Map<String, List> data) {
    var entries = data.entries;
    for (var entry in entries) {
      _parseSingleGroup(entry.key, entry.value);
    }
    _onParseFinish(data.keys.toList());
  }

  void _parseSingleGroup(String group, List cords) {
    _cordCount += cords.length;
    num dx, dy; //domain x, domain y
    int row, col;

    var _cord = GridCord(makeMatrix(), name: group);
    _groupMatrixMap![group] = _cord;

    int count;
    for (T t in cords) {
      dx = xMapper.call(t) - domainRange!.topLeft.dx;
      dy = yMapper.call(t) - domainRange!.topLeft.dy;
      row = (dy / domainBlockSize!.y).floor(); // math.min(row, divisions.y - 1);
      col = (dx / domainBlockSize!.x).floor(); // math.min(, divisions.x - 1);
      count = _cord.get(row: row, col: col).addItem(t);
      // _matrixData[row][col].addItem(t);
      // _blockMaxCount = math.max(_cord.get(row: row, col: col).count, _blockMaxCount);
      _cord.blockMaxCount = math.max(_cord.blockMaxCount, count);
    }
  }

  num revert(double range) {
    return _scale!.revertXY(Offset(range, range)).x;
  }

  void init() {
    _scale = Vector3LinearScale(
      domainMin: Point3(domainRange!.left, domainRange!.top, 0),
      domainMax: Point3(domainRange!.right, domainRange!.bottom, 0),
      rangeMin: Point3(.0, .0, .0),
      rangeMax: Point3(viewRect.width, viewRect.height, .0),
    );
    // domainDensity = Point3.xy(_scale.rangeX / divisions.x, _scale.rangeY / divisions.y);
    domainBlockSize ??= Point3(32.0, 32.0, .0);
    divisions = Point3<int>(domainWidth ~/ domainBlockSize!.x, domainHeight ~/ domainBlockSize!.y, 0);

    storeDomainBlockSize = Point3(1024.0, 1024.0, .0);
    storeDivisions = Point3<int>(domainWidth ~/ storeDomainBlockSize!.x, domainHeight ~/ storeDomainBlockSize!.y, 0);

    _rowRange = Point3(0, rowCount - 1, 0);
    _colRange = Point3(0, colCount - 1, 0);

    // _matrixData?.clear();
    // _matrixData = List.generate(divisions.y, (r) => List.generate(divisions.x, (c) => CordBlock(c, r)));

    _groupMatrixMap?.clear();
    _groupMatrixMap = {};

    print('divisions: $divisions, store divisions: $storeDivisions');
  }

  List<List<CordBlock<T>>> makeMatrix() {
    return List.generate(divisions!.y, (r) => List.generate(divisions!.x, (c) => CordBlock(c, r)));
  }

  transform(Matrix4 matrix) {
    double _scale = matrix.getMaxScaleOnAxis();
    int __scale = _scale.floor();

    Rect _rect = viewRect.transform(matrix);
    Rect domainRect = scale!.revertRect(_rect);

    int minRow = domainRect.top ~/ domainBlockSize!.y;
    int maxRow = math.min((domainRect.bottom / domainBlockSize!.y).ceil(), divisions!.y - 1);

    int minCol = domainRect.left ~/ domainBlockSize!.x;
    int maxCol = math.min((domainRect.right / domainBlockSize!.y).ceil(), divisions!.y - 1);

    _rowRange = Point3(minRow, maxRow, 0);
    _colRange = Point3(minCol, maxCol, 0);

    // print('row: ${_rowRange}, col: ${_colRange}');
    int scaleTimes = __scale ~/ 2;

    mergeBlocks = 1;
    if (_scales!.length > scaleTimes) {
      mergeBlocks = 2 * (_scales!.length - scaleTimes);
    }

    if (mergeBlocks > 1) {
      _rowRange = Point3(math.max((minRow / mergeBlocks).floor() - 1, 0), (maxRow / mergeBlocks).ceil() + 1, 0);
      _colRange = Point3(math.max((minCol / mergeBlocks).floor() - 1, 0), (maxCol / mergeBlocks).ceil() + 1, 0);
    } else {
      // _loadRangeBinData();
    }
    // print('combined: row: ${_rowRange}, col: ${_colRange}');
    // print('combine count: ${combineCount}, __scale:$__scale');
  }

  Color getGroupColor(String group) {
    return clusterMap[group]!.color;
  }

  forEach(Function callback) async {
    var entries = _groupMatrixMap!.entries;
    for (var entry in entries) {
      entry.value.forEach(entry.key, _rowRange!, _colRange!, mergeBlocks, callback);
    }
    // if (null == _groupMatrixMap) return;
    // for (int row = _rowRange.x.toInt(); row < _rowRange.y; row++) {
    //   for (int col = _colRange.x.toInt(); col < _colRange.y; col++) {
    //     if (mergeBlocks > 1) {
    //       var rect = Rect.fromLTWH(
    //         col * mergeBlocks * 1.0,
    //         row * mergeBlocks * 1.0,
    //         mergeBlocks.toDouble(),
    //         mergeBlocks.toDouble(),
    //       );
    //       callback?.call(CordBlock(col, row)..count = sumRange(rect), row, col);
    //     } else {
    //       // await _loadBinData(_matrixData[row][col]);
    //       callback?.call(_matrixData[row][col], row, col);
    //     }
    //   }
    // }
  }

  List _fileCached = [];

  Future _loadRangeBinData() async {
    var combineCount = storeDomainBlockSize!.x / domainBlockSize!.x;
    Point3<int> __rowRange = Point3(math.max((_rowRange!.x / combineCount).floor() - 1, 0), (_rowRange!.y / combineCount).ceil() + 1, 0);
    Point3<int> __colRange = Point3(math.max((_colRange!.x / combineCount).floor() - 1, 0), (_colRange!.y / combineCount).ceil() + 1, 0);

    for (int row = __rowRange.x; row < __rowRange.y; row++) {
      for (int col = __colRange.x; col < __colRange.y; col++) {
        String fileName = 'bin-1-$row-$col.csv';
        if (_fileCached.contains(fileName)) continue;
        String filePath = '${_docDir!.path}/$fileName';
        File file = File(filePath);
        if (!file.existsSync()) continue;
        print('load file: ${filePath}');
        String content = await FileUtil.readFile(file: filePath);
        // content.split('\n').forEach(_parseBinLine);
        _fileCached.add(fileName);
      }
    }
  }

  // _parseBinLine(String line) {
  //   var cols = line.split(RegExp('	'));
  //   if (cols.length != 4) return;
  //   List item = [
  //     cols[0],
  //     cols[1],
  //     double.tryParse(cols[2]), //x
  //     double.tryParse(cols[3]), //y
  //   ];
  //
  //   num dx, dy; //domain x, domain y
  //   int row, col, storeBinRow, storeBinCol;
  //
  //   dx = xMapper.call(item as T) - domainRange.topLeft.dx;
  //   dy = yMapper.call(item as T) - domainRange.topLeft.dy;
  //
  //   row = math.min((dy / domainBlockSize.y).floor(), divisions.y - 1);
  //   col = math.min((dx / domainBlockSize.x).floor(), divisions.x - 1);
  //   _matrixData[row][col].addItem(item as T);
  // }

  // operator [](List arr) {
  //   if (null == _matrixData) return null;
  //   if (arr.length == 2 && arr.first < _matrixData.length) {
  //     var row = _matrixData[arr.first];
  //     if (row.length < arr.last) {
  //       return row[arr.last];
  //     }
  //   }
  //   return null;
  // }

  _prepare() async {
    if (workDir == null) {
      var _docDir = await getApplicationDocumentsDirectory();
      workDir = Directory('${_docDir.path}/sgs/cell');
    }
    _docDir = Directory('${workDir!.path}/${_fileItem!.name.hashCode}');
    if (_docDir!.existsSync()) _docDir!.deleteSync(recursive: true);
    _docDir!.create();

    __clusterSet?.clear();
    __clusterSet = Set();
    _cordCount = 0;

    init();
  }

  parse(
    UploadFileItem fileItem, {
    LineMapper? lineMapper,
    Function? onFinish,
  }) async {
    _fileItem = fileItem;
    await _prepare();
    _parseStart = DateTime.now();
    fileItem
        .openStream()
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(LineSplitter()) // Convert stream to individual lines.
        .listen(
      _parseLine,
      onDone: () {
        _complete();
        onFinish?.call();
      },
      onError: (e) {
        print(e.toString());
      },
    );
  }

  List _groups = List.generate(10, (index) => 'Group${index + 1}');

  _parseLine(String line) async {
    var cols = line.split(RegExp('	'));
    if (cols.length != 3) return;
    _cordCount++;
    List cluster;
    if (cols[0].contains('_')) {
      cluster = cols[0].split('_')
        ..removeAt(0)
        ..removeLast();
    } else {
      cluster = cols[0].split('\.')..removeLast();
    }

    List item = [
      cols[0],
      double.tryParse(cols[1]), //x
      double.tryParse(cols[2]), //y
    ];

    var _cluster = cluster.join('');
    _cluster = _groups[math.Random().nextInt(10)];
    __clusterSet!.add(_cluster);

    num dx, dy; //domain x, domain y
    int row, col, storeBinRow, storeBinCol;

    dx = xMapper.call(item as T) - domainRange!.topLeft.dx;
    dy = yMapper.call(item as T) - domainRange!.topLeft.dy;

    row = math.min((dy / domainBlockSize!.y).floor(), divisions!.y - 1);
    col = math.min((dx / domainBlockSize!.x).floor(), divisions!.x - 1);

    var _cord = _groupMatrixMap![_cluster];
    if (_cord == null) {
      _cord = GridCord(makeMatrix(), name: _cluster);
      _groupMatrixMap![_cluster] = _cord;
    }

    var count = _cord.get(row: row, col: col).addItem(item as T);
    // _matrixData[row][col].addItem(item as T);
    // _blockMaxCount = math.max(count, _blockMaxCount);
    _cord.blockMaxCount = math.max(_cord.blockMaxCount, count);

    // storeBinRow = math.min((dy / storeDomainBlockSize.y).floor(), storeDivisions.y - 1);
    // storeBinCol = math.min((dx / storeDomainBlockSize.x).floor(), storeDivisions.x - 1);
    // _storeBinMatrix[storeBinRow][storeBinCol].add(item as T);
    //
    // int scaleLevel = 1;
    // String key = '$scaleLevel-$storeBinRow-$storeBinCol';
    // if (_blockMap[key] == null) {
    //   _blockMap[key] = [item];
    // } else {
    //   _blockMap[key].add(item);
    // }
    // if (_blockMap[key].length >= 500) {
    //   await _updateFile(key, _blockMap[key]);
    //   _blockMap[key] = [];
    // }
  }

  _onParseFinish(List clusterList) {
    var colors = colorScheme.schemeRainbow(clusterList.length);
    // colors = colorScheme.schemeBlueRed(clusterList.length);
    // colors = colorScheme.schemeGreenOrg(clusterList.length);
    var _clusters = List.generate(
      clusterList.length,
      (i) => DataCategory(name: clusterList[i], value: clusterList[i], color: colors[i]),
    );
    clusterMap = Map.fromIterables(clusterList, _clusters);

    _maxScale = ((_cordCount / MAX_SCREEN_COUNT) * 32).clamp(32.0, CORD_SIZE / 64);

    _blockAvgCount = _cordCount / ((CORD_SIZE / domainBlockSize!.x) * (CORD_SIZE / domainBlockSize!.y));
    // print('max scale: ${maxScale}, avg count: ${_blockAvgCount}');

    double minBlockCount = math.sqrt(MAX_SCREEN_COUNT / _blockAvgCount!);

    // double maxCombineScale = 0.1;
    double minScale = viewRect.width / domainWidth;
    _scales = [minScale];

    int blockCount = (CORD_SIZE ~/ (domainBlockSize!.x));

    while (blockCount > minBlockCount) {
      _scales!.add(_scales!.last * 2);
      blockCount ~/= 2;
    }
    print(_scales);
    print('clusters: ${clusterList}');
  }

  _complete() {
    // _blockMap.forEach((key, value) async {
    //   await _updateFile(key, _blockMap[key]);
    //   _blockMap[key] = [];
    // });

    List clusterList = __clusterSet!.toList();

    _onParseFinish(clusterList);

    // transform(Matrix4.identity()..scale(1, 1));
    print('File is now closed. read line:$_cordCount');
    print('parse cost time: ${Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - _parseStart!.millisecondsSinceEpoch)}');
  }

  void _updateFile(String key, List<List> dataSet) async {
    String fileName = 'bin-$key.csv';
    String filePath = '${_docDir!.path}/$fileName';
    // print('update file $filePath');
    File file = File(filePath);
    if (!file.existsSync()) {
      await file.create(recursive: true);
    }
    await file.openWrite(mode: FileMode.append)
      ..writeln(dataSet.map((item) => item.join('	')).join('\n'))
      ..close();
  }

  _calculateDataRange() {
    if (source == null) return;
    num x, y;
    double maxX = 0, maxY = 0;
    double minX = 0, minY = 0;
    source!.forEach((T t) {
      x = xMapper.call(t);
      y = yMapper.call(t);
      maxX = math.max(x.toDouble(), maxX);
      maxY = math.max(y.toDouble(), maxY);
      minX = math.min(x.toDouble(), minX);
      minY = math.min(y.toDouble(), minY);
    });
    domainRange = Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  int sortByColor(a, b) => (colorMapper(a) == Colors.grey ? 0 : 1) - (colorMapper(b) == Colors.grey ? 0 : 1);

  @override
  String toString() {
    return 'PointDataMatrix{source: $source, _matrixData: ${_cordCount}, divisions: $divisions, viewSize: $viewRect}';
  }
}

class GridCord<T> {
  String name;

  int blockMaxCount = 0;

  GridCord(this._matrix, {required this.name});

  List<List<CordBlock<T>>> _matrix;

  List<List<CordBlock<T>>> get matrix => _matrix;

  int get rowCount => _matrix.length;

  int get colCount => _matrix.first.length;

  CordBlock<T> get({required int row, required int col}) {
    return _matrix[row][col];
  }

  Color blockColor(CordBlock block, Color color) {
    return color.withOpacity((block.count / blockMaxCount).clamp(0.0, 1.0));
    // return Color.lerp(Colors.white, color, block.count / blockMaxCount);
  }

  forEach(String group, Point3 _rowRange, Point3 _colRange, int mergeBlocks, Function callback) {
    for (int row = _rowRange.x.toInt(); row < _rowRange.y; row++) {
      for (int col = _colRange.x.toInt(); col < _colRange.y; col++) {
        if (mergeBlocks > 1) {
          var rect = Rect.fromLTWH(
            col * mergeBlocks * 1.0,
            row * mergeBlocks * 1.0,
            mergeBlocks.toDouble(),
            mergeBlocks.toDouble(),
          );
          callback.call(this, CordBlock(col, row)..count = sumRange(rect), row, col);
        } else {
          // await _loadBinData(_matrixData[row][col]);
          callback.call(this, this.get(row: row, col: col), row, col);
        }
      }
    }
  }

  int sumRange(Rect rangeRect) {
    int count = 0;
    for (int row = rangeRect.top.toInt(); row < rangeRect.bottom; row++) {
      for (int col = rangeRect.left.toInt(); col < rangeRect.right; col++) {
        if (row >= rowCount || col >= colCount) continue;
        count += this.get(row: row, col: col).count;
      }
    }
    return count;
  }
}

class CordBlock<T> {
  List<T>? list;

  int x;
  int y;

  Offset getOffset(Offset blockSize) {
    return Offset(x * blockSize.dx, y * blockSize.dy);
  }

  Rect getRect(Size blockSize) {
    return Rect.fromLTWH(x * blockSize.width, y * blockSize.height, blockSize.width, blockSize.height);
  }

  CordBlock(this.x, this.y);

  bool get isNotEmpty => (count) > 0;

  bool get isEmpty => list == null;

  int count = 0;

  add(T t) {
    count++;
  }

  int addItem(T t) {
    if (null == list) {
      list = [t];
    } else {
      list!.add(t);
    }
    count++;
    return count;
  }

  operator [](int i) {
    if (list == null || i >= list!.length) return null;
    return list![i];
  }

  @override
  String toString() {
    return '${count}';
  }
}
