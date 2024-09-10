import 'dart:ui';

import 'package:flutter_smart_genome/chart/scale/point.dart';

extension Point3Ext on Point3 {
  Point3 fromOffset(Offset offset) {
    return Point3(offset.dx, offset.dy, 0);
  }
}
