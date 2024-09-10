import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/service/beans.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart' as cm;

class PeakPairTrackData extends TrackData {
  List<PeakPair> features;

  double? _customMin, _customMax;

  PeakPairTrackData({
    required this.features,
    Track? track,
    cm.Range? dataRange,
  }) : super(
          track: track,
          dataRange: dataRange,
        );

  set customMin(double? min) => _customMin = min;

  set customMax(double? max) => _customMax = max;

  late double _min, _max;

  double get min => _min;

  double get max => _max;

  filterAndPrepare(cm.Range visibleRange, {dx.Function1<Feature, String>? distinctBy}) {
    // print('-feature:-- ${features.map((e) => e.json).toList().join('\n')}');
    _min = features.minBy((f) => f.value)?.value ?? 0;
    _max = features.maxBy((f) => f.value)?.value ?? 0;

    features = features
        .filter(valueFilterFunction ?? (t) => true)
        .where((f) => visibleRange.contains(f.range.start) || visibleRange.contains(f.range.end))
        // .distinctBy(distinctBy ?? (f) => f.id)
        .sortedBy((f) => f.range.start)
//        .thenBy((element) => element.range.size)
//        .thenBy((element) => element.children?.length ?? 0)
        .toList();
  }

  dx.Function1<PeakPair, bool>? get valueFilterFunction {
    if (_customMax != null && _customMin != null) {
      return _filterMixMax;
    }
    if (_customMax != null) {
      return _filterMax;
    }
    if (_customMin != null) {
      return _filterMix;
    }
    return null;
  }

  bool _filterMax(PeakPair b) {
    return b.value <= _customMax!;
  }

  bool _filterMix(PeakPair b) {
    return b.value >= _customMin!;
  }

  bool _filterMixMax(PeakPair b) {
    return b.value >= _customMin! && b.value <= _customMax!;
  }

  @override
  bool get isEmpty => features.isEmpty ?? true;

  @override
  void clear() {
    features.clear();
  }
}