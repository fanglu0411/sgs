import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/network/adapter/abs_feature_adapter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class BaseFeatureAdapter extends AbsFeatureAdapter<Feature> {
  BaseFeatureAdapter({ Track? track, int? level}) : super(track: track, level: level);

  @override
  Feature parseFeatureItemInternal(Map item) {
    return Feature.fromMap(item, track!.bioType);
  }

  @override
  Iterable<Map> parseCartesianData(var data, num _start, num _end, num? interval) {
    throw UnimplementedError();
  }
}