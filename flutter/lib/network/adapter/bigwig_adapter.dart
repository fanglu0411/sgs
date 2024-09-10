import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/network/adapter/abs_feature_adapter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class BigwigAdapter extends AbsFeatureAdapter<RangeFeature> {
  BigwigAdapter({required Track track, int? level}) : super(track: track, level: level);

  @override
  RangeFeature parseFeatureItemInternal(Map item) {
    return RangeFeature.fromMap(item, track!.bioType);
  }

  @override
  Iterable<Map> parseCartesianData(var _data, num _start, num _end, num? interval) {
    List data = _data ?? [];
    num _rangeSize = _end - _start;
    num _interval = interval ?? _rangeSize ~/ data.length;
    var __start;
    return data.mapIndexed((i, value) {
      value ??= 0;
      __start = _start + i * _interval;
      var _value = {};
      if (value case >= 0) {
        _value['+'] = value;
      } else {
        _value['-'] = value;
      }
      return {
        'value': _value,
        'strand': (value) >= 0 ? 1 : -1,
        'start': __start,
        'end': __start + _interval,
      };
    });

    return data.mapIndexed(
      (index, value) => Map.fromIterables(header, [value])
        ..addAll({
          'start': _start + index * interval!,
          'end': _start + index * interval + interval,
        }),
    );
  }
}
