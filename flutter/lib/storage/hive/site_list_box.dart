import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/page/site/site_logic.dart';
import 'package:hive/hive.dart';
import 'package:dartx/dartx.dart' as dx;

import 'type_ids.dart';

Box<SiteItem> _box() => Hive.box<SiteItem>('sites');

checkInit(List<SiteItem> sites) async {
  if (_box().isEmpty) {
    await _box().putAll(Map.fromIterables(sites.map((e) => e.sid), sites));
  }
}

Future<List<SiteItem>> getSites() async {
  var sites = _box().values.toList();
  return sites
      .sortedByDescending((e) => e.isDemoServer ? 1 : 0)
      .thenByDescending((s) => s.createTime!) //
      .toList();
}

Future addSiteList(List<SiteItem> sites) async {
  sites.forEach((site) async {
    await _box().put(site.url, site);
  });
}

Future addSiteItem(SiteItem site) async {
  await _box().put(site.sid, site);
}

Future updateSiteItem(SiteItem site) {
  return _box().put(site.sid, site);
}

Future deleteSite(SiteItem site) {
  return _box().delete(site.sid);
}

Future<int> clear() => _box().clear();

class SiteAdapter extends TypeAdapter<SiteItem> {
  @override
  SiteItem read(BinaryReader reader) {
    Map map = reader.readMap();
    return SiteItem.fromMap(map);
  }

  @override
  int get typeId => SITE_LIST_TYPE_ID;

  @override
  void write(BinaryWriter writer, SiteItem obj) {
    writer.writeMap(obj.toMap());
  }
}
