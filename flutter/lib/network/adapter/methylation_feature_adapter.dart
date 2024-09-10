import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/network/adapter/abs_feature_adapter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class MethylationFeatureAdapter extends AbsFeatureAdapter<RangeFeature> {
  MethylationFeatureAdapter({required Track track, int? level}) : super(track: track, level: level);

  @override
  RangeFeature parseFeatureItemInternal(Map item) {
    return RangeFeature.fromMap(item, track!.bioType);
  }

  @override
  Iterable<Map> parseCartesianData(var _data, num _start, num _end, num? _interval) {
    Map data = _data;
    num _rangeSize = _end - _start;
    List group1Data = data[data.keys.first];
    num interval = _interval ?? _rangeSize ~/ group1Data.length;
    Iterable<String> _keys = data.keys.map((e) => '$e');
    if (_keys.any((k) => k.startsWith('p_') || k.startsWith('_'))) {
      List<String> groups = _keys.map<String>((e) => e.split('_').reversed.first).toSet().toList();
      return group1Data.mapIndexed((index, e) {
        var _pValue = groups.asMap().map((i, key) => MapEntry(key, data['p_$key'][index] ?? 0));
        var _nValue = groups.asMap().map((i, key) => MapEntry(key, data['n_$key'][index] ?? 0));
        return {
          'start': _start + index * interval,
          'end': _start + index * interval + interval,
          'pValue': _pValue,
          'nValue': _nValue,
          // ..._value,
        };
      });
    } else {
      List<String> groups = data.keys.toList() as List<String>;
      return group1Data.mapIndexed((index, e) {
        var _value = groups.asMap().map((i, key) => MapEntry(key, data[key][index] ?? 0));
        return {
          'start': _start + index * interval,
          'end': _start + index * interval + interval,
          'pValue': _value,
          'nValue': groups.asMap().map((i, key) => MapEntry(key, 0)),
          // ..._value,
        };
      });
    }
  }
}
