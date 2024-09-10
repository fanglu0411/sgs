import 'dart:ui';

import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

class RangeSequence {
  final Range range;
  final String? sequence;

  RangeSequence(this.range, this.sequence);

  String? subSequence(Range range) {
    if (sequence == null || sequence!.length == 0) return null;
    int start = (range.start - this.range.start).toInt();
    int end = (start + range.size).toInt() + 1;
    if (start < 0) start = 0;
    if (end > sequence!.length) end = sequence!.length;
    return sequence!.substring(start, end);
  }

  @override
  String toString() {
    return 'RangeSequence{range: $range, sequence: $sequence}';
  }
}

class Peak extends RangeFeature {
  Peak(List arr)
      : super.fromMap({
          'id': arr[0],
          'start': arr[1],
          'end': arr[2],
        }, 'peak_track');
}

class PeakPair extends RangeFeature {
  // num left, right;

  Path? linkPath;

  PeakPair.array(List list)
      : super.fromMap({
          'start': list[0],
          'end': list[1],
          'value': list.length > 2 ? list[2] : 1.0,
          'peak1': list.length > 3 ? list[3] : null,
          'peak2': list.length > 3 ? list[4] : null,
        }, 'peak-track', 'peak-pair') {}

  double get value => this['value'];

  String get peak1 => this['peak1'];

  String get peak2 => this['peak2'];
}