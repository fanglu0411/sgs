import 'dart:ui';

import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:dartx/dartx.dart' as dx;
import 'dart:math' show pi, min;

class InteractiveItem {
  late Range range1;
  late Range range2;
  String? name;
  late double value;
  double? colorValue;
  Path? path;
  Path? areaPath;
  Path? arcPath;

  Range? uiRange1;
  Range? uiRange2;
  Rect? arcRect;

  InteractiveItem.fromList(List item) {
    if (item[0] <= item[2]) {
      range1 = Range(start: item[0], end: item[1]);
      range2 = Range(start: item[2], end: item[3]);
    } else {
      range2 = Range(start: item[0], end: item[1]);
      range1 = Range(start: item[2], end: item[3]);
    }

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
    if (uiRange1!.size > 1) {
      _needClose = true;
      blockPath
        ..moveTo(uiRange1!.start, top) //
        ..lineTo(uiRange1!.end, top); //
    } else {
      blockPath.moveTo(uiRange1!.start, top);
    }
    if (uiRange2!.size > 1) {
      _needClose = true;
      blockPath
        ..lineTo(uiRange2!.end, bottom) //
        ..lineTo(uiRange2!.start, bottom); //
    } else {
      blockPath.lineTo(uiRange2!.start, bottom);
    }

    if (!needClose && area) {
      blockPath
        ..lineTo(uiRange1!.start, bottom)
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
    if (needClose) return path!;
    return Path.from(path!)
      ..lineTo(uiRange1!.start, bottom)
      ..close();
  }

  Path getArcPath(double top, double bottom, double uiWidth, ScaleLinear heightScale) {
    double width = (uiRange2!.center - uiRange1!.center);
    double height = (bottom - top) * .5 * (width).abs() / uiWidth + heightScale.call(value);
    // if (height < 20) height = 20.0;
    if (range1.start > range2.start) {
      print('${range1} - ${range2}');
    }
    Rect rect = (range1.start == range2.start)
        ? Rect.fromCenter(center: Offset(uiRange1!.center, top + height), width: uiRange1!.size / 2, height: height * 2)
        : Rect.fromCenter(center: Offset(uiRange1!.center + width / 2, top + height), width: width.abs(), height: height * 2);
    // if (rect.left >= 0) {
    arcRect = rect;
    return Path()
      // ..addRect(rect)
      ..moveTo(rect.left, rect.top)
      // ..quadraticBezierTo(rect.center.dx, rect.bottom + rect.height / 2, rect.right, rect.top)
      ..conicTo(rect.center.dx, rect.bottom, rect.right, rect.top, 1.8);
    // } else {
    //   Rect rect = Rect.fromCenter(center: Offset(uiRange1!.center + width / 2, top), width: width.abs(), height: height * 2);
    //   arcRect = rect;
    //   return Path()
    //     ..addRect(rect)
    //     // ..moveTo(rect.left, rect.top)
    //     // ..quadraticBezierTo(rect.center.dx, rect.bottom + rect.height / 2, rect.right, rect.top)
    //     ..arcTo(rect, 0, pi, true);
    // }
  }

  Map get json => ({
        'name': name ?? '',
        'range1': [range1.intStart, range1.intEnd],
        'range2': [range2.intStart, range2.intEnd],
        'score': value,
      });

  @override
  String toString() {
    return 'InteractiveItem{range1: $range1, range2: $range2, value: $value, colorValue: $colorValue}';
  }
}

class InteractiveData extends TrackData {
  List<InteractiveItem>? data;

  late num maxValue = 1;
  late num minValue = 1;

  InteractiveData(this.data, {num? max, num? min, String? message}) : super(message: message) {
    if (data != null && data!.length > 0) {
      maxValue = max ?? data!.maxBy((e) => e.value)!.value;
      minValue = min ?? data!.minBy((e) => e.value)!.value;
    } else {
      maxValue = max ?? 1;
      minValue = min ?? 0;
    }
  }

  @override
  bool get isEmpty => data == null || data!.length == 0;

  @override
  void clear() {
    data?.clear();
  }
}
