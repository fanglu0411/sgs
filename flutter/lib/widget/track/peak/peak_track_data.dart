import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/service/beans.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart' as cm;

class PeakTrackData extends TrackData {
  List<Peak> features;

  PeakTrackData({
    required this.features,
    Track? track,
    cm.Range? dataRange,
  }) : super(
    track: track,
    dataRange: dataRange,
  );

  filterAndPrepare(cm.Range visibleRange, {dx.Function1<Feature, String>? distinctBy}) {
    // print('-feature:-- ${features.map((e) => e.json).toList().join('\n')}');
    features = features
        .where((f) => visibleRange.intersection(f.range) != null)
        .distinctBy(distinctBy ?? (f) => f.featureId)
        .sortedBy((f) => f.range.start)
//        .thenBy((element) => element.range.size)
//        .thenBy((element) => element.children?.length ?? 0)
        .toList();
  }

  @override
  bool get isEmpty => features.isEmpty ?? true;

  @override
  void clear() {
    features.clear();
  }
}