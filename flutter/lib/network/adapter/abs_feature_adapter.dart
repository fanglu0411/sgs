import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/network/adapter/data_adapter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

abstract class AbsFeatureAdapter<D extends Feature> extends DataAdapter<D> {
  AbsFeatureAdapter({ Track? track, int? level}) : super(track: track, trackLevel: level);
}