import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/network/adapter/data_adapter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class BamCoverageAdapter extends DataAdapter<Map> {
  BamCoverageAdapter({required Track track, int? level}) : super(track: track, trackLevel: level);
  @override
  Map parseFeatureItemInternal(Map item) {
    num start = item['position'];
    Map value = item
      ..remove('position')
      ..remove('children')
      ..remove('sub_features');
    return {
      'start': start,
      'end': start + 1,
      'value': value,
    };
  }

  @override
  Iterable<Map> parseCartesianData(var _data, num _start, num _end, num? interval) {
    List data = _data;
    num _interval = interval ?? (_end - _start) ~/ data.length;
    return data.mapIndexed((index, p1) {
      return {
        'start': _start + index * _interval,
        'end': _start + index * _interval + _interval,
        'value': {'coverage': p1},
      };
    });
  }
}