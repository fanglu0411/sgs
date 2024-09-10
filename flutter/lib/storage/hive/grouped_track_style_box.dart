import 'package:dartx/dartx.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';
import 'package:hive/hive.dart';

import 'type_ids.dart';

Box<TrackStyle> _box() => Hive.box<TrackStyle>('grouped-track-styles');

/// grouped style
Future setGroupedTrackStyle(String speciesId, TrackStyle? style) async {
  if (null == style) {
    await _box().delete(speciesId);
  } else {
    await _box().put(speciesId, style);
  }
}

Map<String, TrackStyle> getGroupedTrackStyleMap(String speciesId) {
  return _box().toMap().filterKeys((k) => k.startsWith(speciesId)).map<String, TrackStyle>((k, v) => MapEntry(k, v));
}

TrackStyle? getGroupedTrackStyle(String speciesId) {
  return _box().get(speciesId, defaultValue: null);
}

Future<int> clear() => _box().clear();

class TrackStyleAdapter extends TypeAdapter<TrackStyle> {
  @override
  TrackStyle read(BinaryReader reader) {
    Map map = reader.readMap();
    return TrackStyle(map);
  }

  @override
  int get typeId => TRACK_STYLE_TYPE_ID;

  @override
  void write(BinaryWriter writer, TrackStyle obj) {
    writer.writeMap(obj.toPersistMap());
  }
}
