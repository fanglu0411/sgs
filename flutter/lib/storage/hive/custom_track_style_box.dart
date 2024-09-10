import 'package:flutter_smart_genome/widget/track/base/track_style.dart';
import 'package:hive/hive.dart';

Box _box() => Hive.box('custom-track-styles');

Future setCustomTrackStyles(String speciesId, Map<String, TrackStyle> styles) async {
  var json = styles.map((key, style) => MapEntry(key, style.toPersistMap()));
  await _box().put(speciesId, json);
}

Map<String, TrackStyle> getCustomTrackStyles(String speciesId) {
  Map map = _box().get(speciesId, defaultValue: {});
  return map.map<String, TrackStyle>((key, json) => MapEntry(key, TrackStyle(json)));
}

Future<int> clear() => _box().clear();