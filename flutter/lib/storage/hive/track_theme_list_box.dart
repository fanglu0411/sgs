import 'package:flutter_smart_genome/page/track/theme/integraged/default_themes_map.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/track/base/track_theme.dart';
import 'package:hive/hive.dart';
import 'package:flutter_smart_genome/storage/hive/custom_track_style_box.dart' as custom_track_styles_box;

import 'type_ids.dart';

Box<TrackTheme> _box() => Hive.box<TrackTheme>('track-themes');

initTrackTheme() async {
  if (_box().isEmpty) {
    TrackTheme.defaultTrackThemes().forEach((t) async {
      await _box().put(t.name, t);
    });
  } else if (themeVersion > BaseStoreProvider.get().getTrackThemeVersion()) {
    logger.d('themeVersion: ${themeVersion} need merge !');
    custom_track_styles_box.clear();
    var newThemes = TrackTheme.defaultTrackThemes();
    // var themes = getTrackThemes();
    // for (var theme in themes) {
    //   var mergeTheme = newThemes.firstWhere((e) => e.name == theme.name, orElse: () => null) ?? newThemes.first;
    //   theme.merge(mergeTheme);
    // }
    for (var theme in newThemes) {
      await _box().put(theme.name, theme);
    }
    await BaseStoreProvider.get().setTrackThemeVersion(themeVersion);
  }
}

List<TrackTheme> getTrackThemes() {
  return _box().values.toList();
}

TrackTheme? getTrackTheme(String name) {
  return _box().get(name);
}

Future addTrackTheme(TrackTheme theme) {
  return _box().put(theme.name, theme);
}

updateTrackTheme(TrackTheme theme) {
  return _box().put(theme.name, theme);
}

deleteTrackTheme(TrackTheme theme) {
  return _box().delete(theme.name);
}

deleteTrackThemeByName(String name) {
  return _box().delete(name);
}

Future<int> clear() => _box().clear();

class TrackThemeAdapter extends TypeAdapter<TrackTheme> {
  @override
  TrackTheme read(BinaryReader reader) {
    String name = reader.readString();
    Map<String, dynamic> map = reader.readMap().map<String, dynamic>((k, v) => MapEntry(k, v));
    return TrackTheme(name, map);
  }

  @override
  int get typeId => TRACK_THEME_LIST_TYPE_ID;

  @override
  void write(BinaryWriter writer, TrackTheme obj) {
    writer.writeString(obj.name);
    writer.writeMap(obj.persistJson);
  }
}
