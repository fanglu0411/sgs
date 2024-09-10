// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_smart_genome/cell/data_category.dart';
// import 'package:d4_scale/d4_scale.dart';
// import 'package:flutter_smart_genome/chart/scale/numeric_extents.dart';
// import 'package:flutter_smart_genome/chart/scale/point.dart';
// import 'package:flutter_smart_genome/chart/scale/scale.dart';
// import 'package:flutter_smart_genome/chart/scale/vector_linear_scale.dart';
// import 'package:flutter_smart_genome/extensions/rect_extension.dart';
// import 'dart:math' show Random, max, min, pow, sqrt;
// import 'package:dartx/dartx.dart' as dx;
// import 'package:flutter_smart_genome/d3/color/schemes.dart' as colorScheme;
// import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/legend_colors.dart';
// import 'package:get/get.dart';
//
// class DensityGroupPlotMatrix<T> {
//   final int CORD_SIZE = 65536;
//   //这个表示最小bin单元， 比如按64 来分
//   Point3 domainBlockSize;
//
//   //分割的块数 x, y
//   Point3 divisions;
//
//   Point3 _rowRange;
//   Point3 _colRange;
//
//   Map<String, GridCord<T>> _groupMatrixMap;
//
//   List<double> _scales;
//
//   /// 缩放尺度需要合并的块
//   int mergeBlocks = 1;
//
//   Map<String, List> groupData;
//   Rect viewRect;
//   Rect domainRange;
//   Vector3LinearScale _scale;
//   Vector3LinearScale get scale => _scale;
//
//   Map<String, Path> _groupPath;
//
//   //当前需要绘制的区域坐标
//   Map<String, Float32List> _groupCords = {};
//   Map<String, Float32List> get groupCords => _groupCords;
//
//   getGroupCords(String group) {
//     return _groupCords[group];
//   }
//
//   ///label position
//   Map<String, Rect> _groupLabelRectMap;
//   Map<String, Rect> get groupLabelRectMap => _groupLabelRectMap;
//
//   double maxScale;
//
//   static final MAX_DOMAIN = 65535;
//
//   final MAX_SCREEN_COUNT = 8000; //图表可见区域最多的点的数量
//
//   Map<String, DataCategory> legendMap;
//
//   Map<String, Path> get groupPath => _groupPath;
//
//   List<DataCategory> get legends => legendMap?.values?.toList();
//
//   List categories;
//
//   num _cellCount;
//   int get cellCount => _cellCount.toInt();
//
//   LinearScale _domainScale;
//
//   double _min = 0;
//   double _max = 0;
//   int _fitMax;
//
//   LinearScale get domainScale => _domainScale;
//
//   num _xMapper(T list) {
//     List _list = list as List;
//     return _list[1];
//   }
//
//   num _yMapper(T list) {
//     List _list = list as List;
//     return _list[2];
//   }
//
//   num _xScaleMapper(List list) {
//     return _domainScale.scale(list[1]);
//     // return list[1];
//   }
//
//   num _yScaleMapper(List list) {
//     return _domainScale.scale(list[2]);
//     // return list[2];
//   }
//
//   DensityGroupPlotMatrix({
//     required Map<String, List> groupData,
//     required this.viewRect,
//     required this.domainRange,
//     required this.categories,
//     this.domainBlockSize,
//   }) {
//     _scale = Vector3LinearScale(
//       domainMin: Point3.fromOffset(domainRange.topLeft),
//       domainMax: Point3.fromOffset(domainRange.bottomRight),
//       rangeMin: Point3.xy(0, 0),
//       rangeMax: Point3.xy(viewRect.width, viewRect.height),
//     );
//
//     var _maxItem, _minItem;
//     // var random = Random();
//     // var values = groupData.values;
//     // for (var list in values) {
//     //   var _list = list.map<List>((e) {
//     //     List _e = e;
//     //     e[1] += random.nextDouble();
//     //     e[2] += random.nextDouble();
//     //     return _e;
//     //   }).toList();
//     //   list.addAll(_list);
//     // }
//     groupData.forEach((group, List list) {
//       _maxItem = list.maxBy((item) => max(_xMapper(item), _yMapper(item)));
//       _max = max(_max, max(_xMapper(_maxItem), _yMapper(_maxItem)));
//       _minItem = list.minBy((item) => min(_xMapper(item), _yMapper(item)));
//       _min = min(_min, min(_xMapper(_minItem), _yMapper(_minItem)));
//     });
//     _fitMax = _calculateFitableMaxValue(max(_min.abs(), _max.abs()));
//     print('---->>> min: $_min, max:$_max, fit max: $_fitMax');
//     _domainScale = LinearScale(domain: NumericExtents(_min < 0 ? -_fitMax : 0, _fitMax), range: ScaleOutputExtent(0, MAX_DOMAIN));
//
//     _groupPath = groupData.map((key, value) => MapEntry(key, Path()));
//
//     _cellCount = groupData.values.sumBy((List list) => list.length);
//     maxScale = ((_cellCount / MAX_SCREEN_COUNT) * 32).clamp(32.0, (MAX_DOMAIN + 1) / 64);
//
//     var colors = Get.isDarkMode ? colorScheme.schemeRainbowDark(categories.length) : colorScheme.schemeRainbowLight(categories.length);
//     var _clusters = List.generate(colors.length, (i) => DataCategory(name: categories[i], value: categories[i], color: colors[i]));
//     legendMap = _clusters.asMap().map((key, category) => MapEntry(category.value, category));
//     _groupLabelRectMap = {};
//
//     domainBlockSize ??= Point3.xy(32.0, 32.0);
//     divisions = Point3(domainWidth ~/ domainBlockSize.x, domainHeight ~/ domainBlockSize.y);
//
//     _rowRange = Point3(0, rowCount - 1);
//     _colRange = Point3(0, colCount - 1);
//     _groupMatrixMap?.clear();
//     _groupMatrixMap = {};
//
//     _parseGroupedData(groupData);
//
//     final _blockAvgCount = _cellCount / ((CORD_SIZE / domainBlockSize.x) * (CORD_SIZE / domainBlockSize.y));
//     // print('max scale: ${maxScale}, avg count: ${_blockAvgCount}');
//
//     double minBlockCount = sqrt(MAX_SCREEN_COUNT / _blockAvgCount);
//
//     double minScale = viewRect.width / domainWidth;
//     _scales = [minScale];
//     int blockCount = (CORD_SIZE ~/ (domainBlockSize.x));
//
//     while (blockCount > minBlockCount) {
//       _scales.add(_scales.last * 2);
//       blockCount ~/= 2;
//     }
//     print(_scales);
//   }
//
//   void _parseGroupedData(Map<String, List> data) {
//     var entries = data.entries;
//     for (var entry in entries) {
//       _parseSingleGroup(entry.key, entry.value);
//     }
//
//     double blockViewSize = viewRect.width / divisions.x;
//     _groupMatrixMap.forEach((key, cord) {
//       _groupLabelRectMap[key] = Rect.fromLTWH(cord.maxCountCol * blockViewSize, cord.maxCountRow * blockViewSize, blockViewSize, blockViewSize);
//     });
//   }
//
//   void _parseSingleGroup(String group, List cords) {
//     _cellCount += cords.length;
//     num dx, dy; //domain x, domain y
//     int row, col;
//
//     GridCord<T> _cord = GridCord(makeMatrix<T>(), name: group);
//     _groupMatrixMap[group] = _cord;
//
//     int count;
//     for (T t in cords) {
//       dx = _xScaleMapper(t as List);
//       dy = MAX_DOMAIN - _yScaleMapper(t as List);
//
//       row = (dy / domainBlockSize.y).floor(); // math.min(row, divisions.y - 1);
//       col = (dx / domainBlockSize.x).floor(); // math.min(, divisions.x - 1);
//       count = _cord.get(row: row, col: col, autoInit: true).addItem(t);
//       _cord.checkMax(count, row, col);
//     }
//   }
//
//   List<List<CordBlock<T>>> makeMatrix<T>() {
//     return List.generate(divisions.y, (r) => List.generate(divisions.x, (c) => null));
//   }
//
//   int get rowCount => divisions.x;
//   int get colCount => divisions.y;
//   double get domainWidth => domainRange.right - domainRange.left + 1;
//   double get domainHeight => domainRange.bottom - domainRange.top + 1;
//
//   int _calculateFitableMaxValue(num value) {
//     return value.ceil();
//     int j = 1;
//     int e = pow(2, j);
//     while (e < value) {
//       j++;
//       e = pow(2, j);
//     }
//     return e;
//   }
//
//   int _calculateFitableMinValue(num value) {
//     return value.floor();
//     int j = 1;
//     int e = pow(2, j);
//     while (e < value) {
//       j++;
//       e = pow(2, j);
//     }
//     return e;
//   }
//
//   void changeLegends(LegendColor legendColor) {
//     // var colors = colorScheme.schemeColors([legendColor.start, legendColor.end], categories.length);
//     // var _clusters = List.generate(colors.length, (i) => DataCategory(name: categories[i], value: categories[i], color: colors[i]));
//     // legendMap = _clusters.asMap().map((key, category) => MapEntry(category.value, category));
//   }
//
//   void changeViewSize(Rect viewRect) {
//     this.viewRect = viewRect;
//     _scale = Vector3LinearScale(
//       domainMin: Point3.fromOffset(domainRange.topLeft),
//       domainMax: Point3.fromOffset(domainRange.bottomRight),
//       rangeMin: Point3.xy(0, 0),
//       rangeMax: Point3.xy(viewRect.width, viewRect.height),
//     );
//   }
//
//   bool groupChecked(String group) {
//     return legendMap[group]?.checked ?? false;
//   }
//
//   Color getGroupColor(String group) {
//     return legendMap[group]?.drawColor ?? Colors.grey.withAlpha(100);
//   }
//
//   List<String> get orderedGroup {
//     return legendMap.keys.sortedBy((e) => legendMap[e].checked ? 1 : -1);
//   }
//
//   forEach(Function callback) async {
//     List groups = orderedGroup;
//
//     for (var group in groups) {
//       _groupMatrixMap[group].forEach(group, _rowRange, _colRange, mergeBlocks, callback);
//     }
//   }
//
//   void transform2(Matrix4 matrix, Rect targetRect, double radius) {
//     double _scale = matrix.getMaxScaleOnAxis();
//     int __scale = _scale.floor();
//     Rect domainRect = scale.revertRect(targetRect);
//
//     int minRow = domainRect.top ~/ domainBlockSize.y;
//     int maxRow = min((domainRect.bottom / domainBlockSize.y).ceil(), divisions.y - 1);
//
//     int minCol = domainRect.left ~/ domainBlockSize.x;
//     int maxCol = min((domainRect.right / domainBlockSize.y).ceil(), divisions.y - 1);
//
//     _rowRange = Point3(minRow, maxRow);
//     _colRange = Point3(minCol, maxCol);
//
//     // print('row: ${_rowRange}, col: ${_colRange}');
//     int scaleTimes = __scale ~/ 2;
//
//     mergeBlocks = 1;
//     if (_scales.length > scaleTimes) {
//       mergeBlocks = 2 * (_scales.length - scaleTimes);
//     }
//
//     if (mergeBlocks > 1) {
//       _rowRange = Point3(max((minRow / mergeBlocks).floor() - 1, 0), (maxRow / mergeBlocks).ceil() + 1);
//       _colRange = Point3(max((minCol / mergeBlocks).floor() - 1, 0), (maxCol / mergeBlocks).ceil() + 1);
//     } else {
//       var entries = _groupMatrixMap.entries;
//       List<double> _cords = [];
//       num _x, _y;
//       for (var entry in entries) {
//         _cords = [];
//         entry.value.loopRange(_rowRange, _colRange, (cord, CordBlock block) {
//           if (block == null) return;
//           List data = block.list;
//           if (data != null && data.length > 0) {
//             data.forEach((e) {
//               _x = scale.scaleX(_xScaleMapper(e));
//               _y = scale.scaleY(MAX_DOMAIN - _yScaleMapper(e));
//
//               _cords.addAll([_x, _y]);
//             });
//           }
//         });
//         _groupCords[entry.key] = Float32List.fromList(_cords);
//       }
//     }
//     // print('combined: row: ${_rowRange}, col: ${_colRange}');
//     // print('combine count: ${combineCount}, __scale:$__scale');
//   }
//
//   void transform(Matrix4 matrix4, Rect targetRect, double radius) {
//     var _domainRect = scale.revertRect(targetRect);
//     // double _scale = matrix4.getMaxScaleOnAxis();
//     // var domOfPixel = 65536 / (viewRect.width * _scale);
//     // print('targetRect: $targetRect, scale: $_scale, domOfPixel:$domOfPixel');
//
//     Rect pointRect;
//     double sx, sy;
//     groupData.forEach((key, List list) {
//       // Path path = Path();
//       if (_groupCords[key] == null) {
//         _groupCords[key] = Float32List(list.length * 2);
//       }
//       int i = 0;
//       for (List item in list) {
//         var domainPoint = Point3.xy(_xScaleMapper(item), MAX_DOMAIN - _yScaleMapper(item));
//         if (!_domainRect.contains(domainPoint.offset)) continue;
//
//         Offset viewPoint = scale.scaleXY(domainPoint);
//         _groupCords[key][i * 2] = viewPoint.dx;
//         _groupCords[key][i * 2 + 1] = viewPoint.dy;
//
//         i++;
//         // pointRect = Rect.fromCircle(center: scaledDomainPoint, radius: radius);
//         // if (_scale * radius * 2 <= 1) {
//         //   path.addRect(pointRect);
//         // } else {
//         // path.addOval(pointRect);
//         // }
//       }
//       // _groupPath[key] = path;
//     });
//
//     // print(groupData.values.first);
//     // print(_groupCords.entries.first.value);
//   }
//
//   String find(Offset position, Matrix4 matrix) {
//     position = position.transformInvert(matrix);
//     var cat;
//     for (String key in _groupPath.keys) {
//       var path = _groupPath[key];
//       if (path.contains(position)) {
//         cat = key;
//         break;
//       }
//     }
//     return cat;
//   }
// }
//
// class GridCord<T> {
//   String name;
//
//   num blockMaxCount = 0;
//   int maxCountCol = 0;
//   int maxCountRow = 0;
//
//   checkMax(num count, int row, int col) {
//     if (blockMaxCount < count) {
//       maxCountCol = col;
//       maxCountRow = row;
//       blockMaxCount = count;
//     }
//   }
//
//   GridCord(this._matrix, {required this.name});
//
//   List<List<CordBlock<T>>> _matrix;
//   List<List<CordBlock<T>>> get matrix => _matrix;
//
//   int get rowCount => _matrix.length;
//   int get colCount => _matrix.first.length;
//
//   CordBlock<T> get({required int row, required int col, bool autoInit = false}) {
//     if (_matrix[row][col] == null && autoInit) _matrix[row][col] = CordBlock(col, row);
//     return _matrix[row][col];
//   }
//
//   Color blockColor(CordBlock block, Color color) {
//     return color.withOpacity((block.count / blockMaxCount).clamp(0.0, 1.0));
//     // return Color.lerp(Colors.white, color, block.count / blockMaxCount);
//   }
//
//   loopRange(Point3 _rowRange, Point3 _colRange, Function callback) {
//     for (int row = _rowRange.x.toInt(); row < _rowRange.y; row++) {
//       for (int col = _colRange.x.toInt(); col < _colRange.y; col++) {
//         callback?.call(this, this.get(row: row, col: col));
//       }
//     }
//   }
//
//   forEach(String group, Point3 _rowRange, Point3 _colRange, int mergeBlocks, Function callback) {
//     for (int row = _rowRange.x.toInt(); row < _rowRange.y; row++) {
//       for (int col = _colRange.x.toInt(); col < _colRange.y; col++) {
//         if (mergeBlocks > 1) {
//           var rect = Rect.fromLTWH(
//             col * mergeBlocks * 1.0,
//             row * mergeBlocks * 1.0,
//             mergeBlocks.toDouble(),
//             mergeBlocks.toDouble(),
//           );
//           callback?.call(this, CordBlock(col, row)..count = sumRange(rect));
//         } else {
//           // await _loadBinData(_matrixData[row][col]);
//           callback?.call(this, this.get(row: row, col: col));
//         }
//       }
//     }
//   }
//
//   int sumRange(Rect rangeRect) {
//     int count = 0;
//     for (int row = rangeRect.top.toInt(); row < rangeRect.bottom; row++) {
//       for (int col = rangeRect.left.toInt(); col < rangeRect.right; col++) {
//         if (row >= rowCount || col >= colCount) continue;
//         count += (this.get(row: row, col: col)?.count ?? 0);
//       }
//     }
//     return count;
//   }
// }
//
// class CordBlock<T> {
//   List<T> list;
//
//   int x;
//   int y;
//
//   Offset getOffset(Offset blockSize) {
//     return Offset(x * blockSize.dx, y * blockSize.dy);
//   }
//
//   Rect getRect(Size blockSize) {
//     return Rect.fromLTWH(x * blockSize.width, y * blockSize.height, blockSize.width, blockSize.height);
//   }
//
//   CordBlock(this.x, this.y);
//
//   bool get isNotEmpty => (count) > 0;
//   bool get isEmpty => list == null;
//
//   int count = 0;
//
//   add(T t) {
//     count++;
//   }
//
//   int addItem(T t) {
//     if (null == list) {
//       list = [t];
//     } else {
//       list.add(t);
//     }
//     count++;
//     return count;
//   }
//
//   operator [](int i) {
//     if (list == null || i >= list.length) return null;
//     return list[i];
//   }
//
//   @override
//   String toString() {
//     return '${count}';
//   }
// }
