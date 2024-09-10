
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/network/adapter/abs_feature_adapter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

class EQTLFeatureAdapter extends AbsFeatureAdapter<Feature> {
  EQTLFeatureAdapter({required Track track, int? level}) : super(track: track, level: level);

  @override
  bool get filterInRange => false;

  @override
  bool filterFun(Feature item, Range? range) {
    if (range == null) return true;
    return range.collide(item.range);
  }

  @override
  Feature parseFeatureItemInternal(Map item) {
    return Feature.fromMap(item, track!.bioType);
  }
}