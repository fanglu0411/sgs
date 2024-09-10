import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter_smart_genome/cell/point_data_matrix.dart';
import 'package:flutter_smart_genome/chart/scale/point.dart';
import 'package:path_provider/path_provider.dart';

class MatrixDataParser<T> {
  ValueMapper<T> xMapper;
  ValueMapper<T> yMapper;

  List<Point3<double>> dataRange;

  //这个表示文件分割的最小单元，比如文件可能按3000来分
  late Point3<double> domainDensity;
  late Point3<int> divisions;

  //这个表示最小bin单元， 比如按100 来分
  late Point3<double> minDomainDensity;
  late Point3<int> minDivisions;

  Directory? docDir;

  int? _rowCount;
  int? _colCount;

  Point3? _rowRange;
  Point3? _colRange;

  Point3? _dataMin;
  Point3? _dataMax;
  Set? __clusterSet;
  int _lineCount = 0;

  int _fileBlockBinSize = 100;
  DateTime? _parseStart;

  var levelMap = {
    'avg_count': 5,
    'list': [
      [
        //row data
      ],
      [
        //row data
      ],
      [
        //row data
      ]
    ],
    'level': 3,
    'division': [400, 400],
  };

  Map<String, int> _blockCountMap = {};
  Map<String, List<List>> _binMap = {};

  List<List<CordBlock>>? _pointBinMatrix;
  List<List<CordBlock>>? _minBinMatrix;

  MatrixDataParser({
    required this.dataRange,
    required this.xMapper,
    required this.yMapper,
  });

  // size per pixel
  // 65535 pix 400 / 65535 --> 1
  // start from scale = 0.1 || .5  to => view width / 65536
  // then find the perfect scale (each block has proper count, maybe 10)

  // count scales
  //  scale = 0.1 => division = xx

  // min block size(100,100)
  // total block = 65536  / 100 + 1

  parse(Stream<List<int>> stream) async {
    await _prepare();
    _parseStart = DateTime.now();
    stream
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(LineSplitter()) // Convert stream to individual lines.
        .listen(
      _parseLine,
      onDone: _complete,
      onError: (e) {
        print(e.toString());
      },
    );
  }

  double get domainWidth => dataRange[1].x - dataRange[0].x;

  double get domainHeight => dataRange[1].y - dataRange[0].y;

  _prepare() async {
    __clusterSet?.clear();
    __clusterSet = Set();
    _dataMin = null;
    _dataMax = null;

    _blockCountMap.clear();
    _blockCountMap = {};

    domainDensity = Point3(3000.0, 3000.0, .0);
    divisions = Point3<int>(domainWidth ~/ domainDensity.x + 1, domainHeight ~/ domainDensity.y + 1, 0);
    _rowCount = divisions.x;
    _colCount = divisions.y;
    _rowRange = Point3(0, _rowCount! - 1, 0);
    _colRange = Point3(0, _colCount! - 1, 0);
    _pointBinMatrix = List.generate(_rowCount!, (row) => List.generate(_colCount!, (col) => CordBlock(col, row)));

    minDomainDensity = Point3(100.0, 100.0, .0);
    minDivisions = Point3(domainWidth ~/ minDomainDensity.x + 1, domainHeight ~/ minDomainDensity.y + 1, 0);
    var _minRowCount = divisions.x;
    var _minColCount = divisions.y;
    var _minRowRange = Point3(0, _rowCount! - 1, 0);
    // _colRange = Point3(0, _colCount - 1);
    _minBinMatrix = List.generate(_minRowCount, (row) => List.generate(_minColCount, (col) => CordBlock(col, row)));

    _lineCount = 0;

    docDir = await getApplicationDocumentsDirectory();
    print('divisions: $divisions');

    // _matrixData = List.generate(divisions.y, (r) => List.generate(divisions.x, (c) => PointRowBlock(c, r)));
  }

  void _parseLine(String line) async {
    _lineCount++;
    var cols = line.split(RegExp('	'));
    if (cols.length != 3) return;

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
      cluster.join(''),
      double.tryParse(cols[1]), //x
      double.tryParse(cols[2]), //y
    ];

    __clusterSet!.add(item[1]);

    num dx, dy; //domain x, domain y
    int binRow, binCol, minBinRow, minBinCol;

    dx = xMapper.call(item as T) - dataRange[0].x;
    dy = yMapper.call(item as T) - dataRange[0].y;

    binRow = math.min((dy / domainDensity.y).floor(), divisions.y - 1);
    binCol = math.min((dx / domainDensity.x).floor(), divisions.x - 1);
    _pointBinMatrix![binRow][binCol].add(item as T);

    minBinRow = math.min((dy / minDomainDensity.y).floor(), minDivisions.y - 1);
    minBinCol = math.min((dx / minDomainDensity.x).floor(), minDivisions.x - 1);
    _minBinMatrix![binRow][binCol].add(item as T);

    int scaleLevel = 1;
    String key = '$scaleLevel-$binRow-$binCol';
    if (_binMap[key] == null) {
      _binMap[key] = [item];
    } else {
      _binMap[key]!.add(item);
    }
    if (_binMap[key]!.length >= 40) {
      await _updateFile(key, _binMap[key]!);
      _binMap[key] = [];
    }
    _blockCountMap[key] = ((_blockCountMap[key] ?? 0) + 1);
  }

  _complete() {
    _binMap.forEach((key, value) async {
      await _updateFile(key, _binMap[key]!);
      _binMap[key] = [];
    });
    print('File is now closed. read line:$_lineCount');
    print('parse cost time: ${Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - _parseStart!.millisecondsSinceEpoch)}');
  }

  Future _updateFile(String key, List<List> dataSet) async {
    String fileName = 'bin-$key.csv';
    String filePath = '${docDir!.path}/sgs/cell/$fileName';
    // print('update file $filePath');
    File file = File(filePath);
    if (!file.existsSync()) {
      await file.create(recursive: true);
    }
    await file.openWrite(mode: FileMode.append)
      ..writeln(dataSet.map((item) => item.join('	')).join('\n'))
      ..close();
  }

  /// todo need batch update
  /// block file format
  /// #level row col count
  /// # x   y  value   category
  /// >bin row col
  ///  1   2   1.5     cat1
  ///  2   4   .6      cat4
  /// >bin row2 col2
  ///  3   3   .8      cat3
  ///
  void _batchUpdateFile(int scale, int blockRow, int blockCol, List<List> dataSets) {
    String fileName = 'block-$scale-$blockRow-$blockCol.csv';
    String filePath = '${getApplicationDocumentsDirectory()}/$fileName';
    File file = File(filePath);
    file.openWrite(mode: FileMode.append)
      ..writeln(dataSets.map((e) => e.join('\t')).join('\n'))
      ..close();
  }

  /// get block row and col by bin row and bin col
  Point3 _binToBlock(int row, int col) {
    int blockCols = _colCount! ~/ _fileBlockBinSize;
    if (_colCount! % _fileBlockBinSize > 0) blockCols++;

    int blockRows = _rowCount! ~/ _fileBlockBinSize;
    if (_rowCount! % _fileBlockBinSize > 0) blockRows++;

    int blockRow = row ~/ _fileBlockBinSize;
    int blockCol = col ~/ _fileBlockBinSize;

    //the index of block
    int blockIndex = blockRow * blockCols + blockCol;

    // blockPosition
    return Point3(blockCol, blockRow, 0);
  }

  Point3 _blockToPos(int blockIndex) {
    int blockCols = _colCount! ~/ _fileBlockBinSize;
    if (_colCount! % _fileBlockBinSize > 0) blockCols++;

    int blockRows = _rowCount! ~/ _fileBlockBinSize;
    if (_rowCount! % _fileBlockBinSize > 0) blockRows++;

    return Point3(blockIndex ~/ _fileBlockBinSize, blockIndex % _fileBlockBinSize, 0);
  }
}
