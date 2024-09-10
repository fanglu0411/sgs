import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart' as cm;
import 'package:dartx/dartx.dart';

class FeatureData<F extends Feature> extends TrackData {
  FeatureData(this._originFeatures, {super.track, super.message}) {
    features = this._originFeatures;
  }

  List<F>? features;
  late List<F> _originFeatures;

  bool get hasFeature => features != null && features!.isNotEmpty;

  int get featureCount => features?.length ?? 0;

  Feature operator [](int index) {
    return features![index];
  }

  distinct({Function1<Feature, String>? distinctBy}) {
    features = features!.distinctBy(distinctBy ?? (f) => f.uniqueId).toList();
  }

  filterAndPrepare(cm.Range visibleRange, {Function1<Feature, String>? distinctBy}) {
    // print('-feature:-- ${features.map((e) => e.json).toList().join('\n')}');
    features = features!
        // .where((f) => visibleRange.collide(f.range)) //
        .distinctBy(distinctBy ?? (f) => f.uniqueId)
        .sortedBy((f) => f.range.start)
        .toList();
  }

  filter(List<String> featureTypes) {
    if (featureTypes.length == 0) return;
//    features = _originFeatures.where((element) => featureTypes.contains(element.type)).toList();
  }

  @override
  bool get isEmpty => features == null || features!.isEmpty;

  @override
  void clear() {
    features?.clear();
    features = null;
  }
}
