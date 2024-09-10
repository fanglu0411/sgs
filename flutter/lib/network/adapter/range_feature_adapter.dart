import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/network/adapter/abs_feature_adapter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class RangeFeatureAdapter extends AbsFeatureAdapter<RangeFeature> {
  RangeFeatureAdapter({required Track track, int? level}) : super(track: track, level: level);
  @override
  RangeFeature parseFeatureItemInternal(Map item) {
    return RangeFeature.fromMap(item, track!.bioType);
  }

  // @override
  // Iterable<BedFeature> parseData(Iterable data, {Range range}) {
  //   Iterable<BedFeature> list = super.parseData(data);
  //   return list.where((f) => f.range == null || range.collide(f.range));
  // }
}