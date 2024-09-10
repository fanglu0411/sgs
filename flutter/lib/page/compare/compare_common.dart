import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';

class CompareItem {
  String? type;

  String speciesName;
  String speciesId;
  ChromosomeData chr;
  var item;

  String get title {
    if (item is Feature) {
      return item.name ?? item.featureId;
    }
    return '${item}';
  }

  String get subTitle {
    return '${speciesName} / chr:${chr.chrName}';
  }

  CompareItem({this.type, required this.speciesName, required this.speciesId, required this.chr, required this.item});
}

class PointValue {
  String name;
  double value;
  double? value2;

  PointValue(this.name, this.value, [this.value2]);
}

class XYTrackData extends TrackData {
  List<PointValue>? dataSource;

  XYTrackData({Track? track, this.dataSource}) : super(track: track);

  @override
  bool get isEmpty {
    return dataSource == null || dataSource!.isEmpty;
  }

  @override
  void clear() {
    dataSource?.clear();
  }
}

class GroupXYTrackData extends TrackData {
  Map<String, List<PointValue>>? groupDataSource;

  GroupXYTrackData({Track? track, this.groupDataSource}) : super(track: track);

  @override
  bool get isEmpty {
    return groupDataSource == null || groupDataSource!.isEmpty;
  }

  @override
  void clear() {
    groupDataSource?.clear();
  }
}