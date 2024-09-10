import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class GroupCoverageTrackData extends TrackData {
  List<Map>? groupData;

  List get groups => groupData!.map((e) => e['group']).toList();

  GroupCoverageTrackData(this.groupData, {String? message}) : super(message: message);

  @override
  bool get isEmpty => groupData == null || groupData!.isEmpty;

  @override
  void clear() {
    groupData?.clear();
  }
}