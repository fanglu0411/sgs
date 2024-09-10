import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/network/adapter/abs_feature_adapter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class GffFeatureAdapter extends AbsFeatureAdapter<GffFeature> {
  GffFeatureAdapter({required Track track, int? level}) : super(track: track, level: level);
  @override
  GffFeature parseFeatureItemInternal(Map item) {
    return GffFeature.fromMap(item, track!.bioType);
  }

  @override
  Iterable<Map> parseCartesianData(var _data, num _start, num _end, num? interval) {
    if (_data is Map) return super.parseCartesianData(_data, _start, _end, interval);
    List data = _data;
    return data.map<Map>((list) {
      return {
        'start': list[0],
        'end': list[1],
        'value': {'count': list[2]},
        'strand': 1,
      };
    }).toList();
  }
}