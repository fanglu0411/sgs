import 'dart:io';

import 'package:flutter_smart_genome/util/device_info.dart';

Directory getUserDirectory() {
  var dir = Directory.current;

  if (DeviceOS.isWindows) return dir;

  //macos or linux
  // while (dir.parent.path != '/Users') {
  //   dir = dir.parent;
  // }
  // print('user dir: ${dir.path}');
  return dir;
}

int binarySearchBy<E, K>(List<E> sortedList, K Function(E element) keyOf, int Function(K, K) compare, E value, [int start = 0, int? end]) {
  end = RangeError.checkValidRange(start, end, sortedList.length);
  var min = start;
  var max = end;
  var key = keyOf(value);
  while (min < max) {
    var mid = min + ((max - min) >> 1);
    var element = sortedList[mid];
    var comp = compare(keyOf(element), key);
    if (comp == 0) return mid;
    if (comp < 0) {
      min = mid + 1;
    } else {
      max = mid;
    }
  }
  return -1;
}
