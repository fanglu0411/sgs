import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class ChromosomeData extends TrackData {
  int chrNum = 0;
  late String id;

  late Range range;

  int? center;

  late String chrName;

  int? blockLength;

  ChromosomeData({required this.range, this.center, required this.chrName});

  ChromosomeData.fromMap(Map map) {
    this.id = '${map['chr_id']}';
    //this.range = Range(start: map['start'], end: map['end']);
    // this.range = Range(start: 0.0, end: map['length'] * 1.0);
    this.range = Range(start: 1.0, end: map['length'] * 1.0); // start with 1
    this.chrName = map['chr_name'];
    this.blockLength = map['sequence_block_length'];
  }

  toJson() {
    return {
      'start': range.start,
      'end': range.end,
      'name': chrName,
      'length': range.size,
      'blockLength': blockLength,
    };
  }

  ChromosomeData copy({String? id, Range? range, int? center, String? chrName}) {
    return ChromosomeData(
      range: range ?? this.range,
      center: center ?? this.center,
      chrName: chrName ?? this.chrName,
    )
      ..id = id ?? this.id
      ..blockLength = this.blockLength;
  }

  double get rangeStart => range.start;

  double get rangeEnd => range.end;

  double get size => range.size;

  String get sizeStr => range.lengthStr;

  @override
  String toString() {
    return 'ChromosomeData{$chrNum, id: ${id}, chrName: $chrName, range: $range, blockLength:$blockLength}';
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChromosomeData && runtimeType == other.runtimeType && range == other.range && center == other.center && chrName == other.chrName;

  @override
  int get hashCode => range.hashCode ^ center.hashCode ^ chrName.hashCode;

  @override
  bool get isEmpty {
    return false;
  }

  @override
  void clear() {}
}
