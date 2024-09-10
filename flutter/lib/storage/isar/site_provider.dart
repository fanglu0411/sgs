import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/platform/platform_adapter.dart';
import 'package:flutter_smart_genome/storage/store.dart';
import 'package:isar/isar.dart';

class SiteProvider {
  static Future<SiteItem?> getSite(int siteId) async {
    Isar isar = await Store.get().isar;
    return isar.siteItems.get(siteId);
  }

  static saveSite(SiteItem site) async {
    Isar isar = await Store.get().isar;
    await isar.writeAsync((isar) => isar.siteItems.put(site..id = isar.siteItems.autoIncrement()));
  }

  static saveSites(List<SiteItem> sites) async {
    Isar isar = await Store.get().isar;
    await isar.writeAsync((isar) {
      for (var site in sites) {
        site.id = isar.siteItems.autoIncrement();
      }
      isar.siteItems.putAll(sites);
    });
  }

  static Future<List<SiteItem>> getSites() async {
    Isar isar = await Store.get().isar;
    List<SiteItem> sites = await isar.siteItems.where().findAll();
    if (sites.length == 0) {
      await saveSites(PlatformAdapter.create().getDefaultSite());
    }
    sites = await isar.siteItems.where().findAll();

    return sites;
  }

  static Future<bool> deleteSite(SiteItem site) async {
    Isar isar = await Store.get().isar;
    return await isar.writeAsync<bool>((isar) => isar.siteItems.delete(site.id));
  }

  static Future<SiteItem?> findSingleByUrl(String url) async {
    Isar isar = await Store.get().isar;
    var list = await isar.siteItems.where().urlEqualTo(url).findAllAsync();
    if (list.length > 0) {
      return list.first;
    }
    return null;
  }

  static Future<List<SiteItem>> findByUrl(String url) async {
    Isar isar = await Store.get().isar;
    return isar.siteItems.where().urlEqualTo(url).findAllAsync();
  }

  static updateSite(SiteItem site) async {
    Isar isar = await Store.get().isar;
    isar.writeAsync((isar) => isar.siteItems.put(site));
  }

  static Future<SiteItem> saveUrlNotExits(SiteItem site) async {
    Isar isar = await Store.get().isar;
    var result = await isar.siteItems.where().urlEqualTo(site.url).findAllAsync();
    if (result.length > 0) {
      return result.first;
    }
    await saveSite(site);
    return site;
  }

  static deleteAll() async {
    Isar isar = await Store.get().isar;
    await isar.writeAsync((isar) => isar.siteItems.clear());
  }
}
