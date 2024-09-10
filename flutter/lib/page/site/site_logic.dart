import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/platform/platform_adapter.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

import 'package:get/get.dart';

class SiteLogic extends GetxController {
  static List<SiteItem> defSite() {
    return PlatformAdapter.create().getDefaultSite();
  }

  List<SiteItem> _list = [
//    SiteItem(name: 'Local Server', url: 'http://192.168.100.122:5000', speciesList: ['Bombyx_mori', 'mouse', 'mouse']),
  ];

  SiteItem? _currentSite;

  List<SiteItem> get sites => _list;

  SiteItem? get currentSite => _currentSite;
  bool _loading = false;

  bool get loading => _loading;

  @override
  void onReady() {
    super.onReady();
    //load sites
    loadSites();
  }

  loadSites({bool userSetting = false}) async {
    _loading = true;
    update();
    _list = await BaseStoreProvider.get().getSiteList();
    if (!userSetting) {
      _currentSite = await BaseStoreProvider.get().getCurrentSite() ?? (_list.length > 0 ? _list.first : null);
    }
    _loading = false;
    update();
  }

  addSite(SiteItem site) async {
    _loading = true;
    update();
    await BaseStoreProvider.get().addSite(site);
    _list = await BaseStoreProvider.get().getSiteList();
    await Future.delayed(Duration(milliseconds: 300));
    _loading = false;
    update();
  }

  editSite(SiteItem site) async {
    _loading = true;
    update();
    await BaseStoreProvider.get().updateSite(site);
    _list = await BaseStoreProvider.get().getSiteList();
    _loading = false;
    update();
  }

  deleteSite(SiteItem site) async {
    _loading = true;
    // await BaseStoreProvider.get().deleteSite(site);
    await BaseStoreProvider.get().deleteSite(site);
    _list = await BaseStoreProvider.get().getSiteList();
    _loading = false;
    update();
  }

  changeSpecies(SiteItem site, {bool userSetting = false, Species? species}) {
    _currentSite = site;
    update();
    if (!userSetting && species != null) {
      SgsAppService.get()!.changeSiteSpecies(_currentSite!);
    }
  }
}
