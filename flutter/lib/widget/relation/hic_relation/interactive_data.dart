import 'dart:ui';

import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:dartx/dartx.dart' as dx;

class InteractiveItem {
  late Range range1;
  late Range range2;
  String? name;
  late num value;
  late double colorValue;
  late Path path;
  late Path areaPath;

  late Range uiRange1;
  late Range uiRange2;

  InteractiveItem.fromList(List item) {
    range1 = Range(start: item[0], end: item[1]);
    range2 = Range(start: item[2], end: item[3]);
    value = item[4];
    if (item.length >= 6) {
      name = item[5];
    }
  }

  bool _needClose = false;

  bool get needClose => _needClose;

  Path getPath(double top, double bottom, [bool area = false]) {
    var blockPath = Path();
    _needClose = false;
    if (uiRange1.size > 2) {
      _needClose = true;
      blockPath
        ..moveTo(uiRange1.start, top + 2) //
        ..lineTo(uiRange1.end, top + 2); //
    } else {
      blockPath.moveTo(uiRange1.start, top);
    }
    if (uiRange2.size > 2) {
      _needClose = true;
      blockPath
        ..lineTo(uiRange2.end, bottom) //
        ..lineTo(uiRange2.start, bottom); //
    } else {
      blockPath.lineTo(uiRange2.start, bottom);
    }

    if (!needClose && area) {
      blockPath
        ..lineTo(uiRange1.start, bottom)
        ..close();
    }

    // needClose = true;
    // blockPath
    //   ..moveTo(uiRange1.start, top) //
    //   ..lineTo(uiRange1.end, top) //
    //   ..lineTo(uiRange2.end, bottom) //
    //   ..lineTo(uiRange2.start, bottom);
    if (needClose) blockPath.close();
    return blockPath;
  }

  Path getAreaPath(double bottom) {
    if (needClose) return path;
    return Path.from(path)
      ..lineTo(uiRange1.start, bottom)
      ..close();
  }

  @override
  String toString() {
    return 'InteractiveItem{range1: $range1, range2: $range2, value: $value}';
  }
}

class InteractiveData extends TrackData {
  List<InteractiveItem>? data;

  late num maxValue = 0;
  late num minValue = 0;

  InteractiveData(this.data, {num? max, String? message}) : super(message: message) {
    if (data != null && data!.length > 0) {
      maxValue = max ?? data!.maxBy((e) => e.value)!.value;
      minValue = data!.minBy((e) => e.value)!.value;
    }
  }

  @override
  bool get isEmpty => data == null || data!.length == 0;

  @override
  void clear() {
    data?.clear();
  }
}
