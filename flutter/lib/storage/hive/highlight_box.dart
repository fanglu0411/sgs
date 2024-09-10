import 'package:flutter_smart_genome/bean/highlight_range.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'type_ids.dart';

Box<HighlightRange> _box() => Hive.box<HighlightRange>('highlights');

List<HighlightRange> loadHighlights() {
  return _box().values.toList();
}

Future addHighlight(HighlightRange highlight) async {
  await _box().put(highlight.storeKey, highlight);
}

Future deleteHighlight(HighlightRange highlight) async {
  return _box().delete(highlight.storeKey);
}

Future<int> clear() => _box().clear();

void delete() => _box().deleteFromDisk();

class HighlightAdapter extends TypeAdapter<HighlightRange> {
  @override
  HighlightRange read(BinaryReader reader) {
    Map map = reader.readMap();
    return HighlightRange(map);
  }

  @override
  int get typeId => HIGHLIGHT_ID;

  @override
  void write(BinaryWriter writer, HighlightRange obj) {
    writer.writeMap(obj.source);
  }
}