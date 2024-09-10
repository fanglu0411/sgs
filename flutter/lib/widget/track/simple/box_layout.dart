import 'dart:ui';

import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:dartx/dartx.dart' as dx;

class LayoutRow {
  num start;
  num end;
  int y;
  late List<int> bits;

  LayoutRow({required this.start, required this.end, required this.y}) {
    _initialize(start, end);
  }

  _initialize(num left, num right) {
    bits = List.filled((end - start) as int, 0);
  }

  bool isRangeClear(int left, int right) {
    if (right <= start || left >= end) return true;
    for (int x = left; x < right; x++) {
      if (bits[x] == 1) return false;
    }
    return true;
  }
}

class Block {
  num? start;
  num? end;
  Map<int, LayoutRow>? rows;

  Map<String, Rect>? _cacheRectMap;

  _safeRow(int y) {
    if (rows![y] == null) {
      rows![y] = LayoutRow(y: y, start: start!, end: end!);
    }
    return rows![y];
  }

  addRect(Rect rect, String id) {
    if (_cacheRectMap!.containsKey(id)) {
      var _rect = _cacheRectMap![id];

      _fillRectToRows(_rect!);
      return _rect;
    }

    if (rows!.isEmpty) {
      _fillRectToRows(rect);
      return rect;
    }

    var top = rect.top;
    int maxY = rows!.keys.max()!;
    for (; top < maxY; top += 1) {
      if (!_collides(rect, top.ceil())) break;
    }
  }

  bool _collides(Rect rect, int top) {
    var maxY = top + rect.height;
    for (int y = top; y < maxY; y += 1) {
      var row = rows![y];
      if (row != null && row.isRangeClear(rect.left.ceil(), rect.right.ceil())) return true;
    }
    return false;
  }

  _fillRectToRows(Rect rect) {}
}

class BoxLayout extends TrackLayout {
  double? viewWidth;

  void layout(List<RangeFeature> features) {}

  @override
  void clear() {}
}