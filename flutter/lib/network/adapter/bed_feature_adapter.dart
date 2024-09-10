
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/network/adapter/abs_feature_adapter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

class BedFeatureAdapter extends AbsFeatureAdapter<BedFeature> {
  BedFeatureAdapter({required Track track, int? level}) : super(track: track, level: level);

  @override
  bool get filterInRange => false;

  @override
  bool filterFun(BedFeature item, Range? range) {
    if (range == null) return true;
    return range.collide(item.range);
  }

  @override
  BedFeature parseFeatureItemInternal(Map item) {
    return BedFeature.fromMap(item, track!.bioType);
  }

  @override
  Iterable<Map> parseCartesianData(var _data, num _start, num _end, num? interval) {
    if (_data is Map) return super.parseCartesianData(_data, _start, _end, interval);
    List data = _data;
    return data.map<Map>((list) {
      return {
        'start': list[0],
        'end': list[1],
        'value': {'bed': list[2]},
        'strand': 1,
      };
    }).toList();
    // List data = _data;
    // num _interval = interval ?? (_end - _start) ~/ data.length;
    // return data.mapIndexed((index, p1) {
    //   return {
    //     'start': _start + index * _interval,
    //     'end': _start + index * _interval + _interval,
    //     'strand': 1,
    //     'value': {'bed': p1},
    //   };
    // });
  }
}