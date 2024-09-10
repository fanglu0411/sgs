import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

class SequenceData extends TrackData {
  String sequence;

  Range range;
  Range sequenceRange;

  SequenceData({required this.sequence, required this.range, required this.sequenceRange});

  operator [](int start) {
    int index = (start - sequenceRange.start).toInt();
    if (index < sequence.length && index >= 0) {
      return sequence[index];
    }
    return null;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is SequenceData && runtimeType == other.runtimeType && sequence == other.sequence && range == other.range;

  @override
  int get hashCode => sequence.hashCode ^ range.hashCode;

  @override
  bool get isEmpty => sequence == null;

  @override
  String toString() {
    return 'SequenceData{range: $range, sequenceRange: $sequenceRange, length:${sequence.length}, sequence: $sequence }';
  }

  @override
  void clear() {}
}