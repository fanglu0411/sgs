import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/network/core/http_error.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:get/get.dart';

class SpeciesLogic extends GetxController {
  late SiteItem _site;

  bool _loading = false;
  HttpError? _error;
  List<Species> _data = [];

  List<Species> get data => _data;
  Debounce? _debounce;

  bool get loading => _loading;

  HttpError? get error => _error;

  bool get isEmpty => _data.isEmpty;

  void set site(SiteItem site) => _site = site;

  SpeciesLogic(SiteItem site) {
    _site = site;
    _debounce = Debounce(milliseconds: 10000);
  }

  @override
  void onReady() {
    super.onReady();
    loadData(true);
  }

  loadData([bool showLoading = false]) async {
    _loading = true;
    _error = null;
    if (showLoading) {
      update();
    }

    final _result = await AbsPlatformService.get(_site)!.loadSpeciesList(
      host: _site.url,
      forceRefresh: true,
    );

    _loading = false;
    if (_result.success) {
      _data = _result.body!;
      if (_data.any((e) => !(e.statusDone || e.statusError))) {
        _debounceRefreshList();
      }
    } else {
      _error = _result.error;
    }
    update();
  }

  void _debounceRefreshList() {
    _debounce?.run(() => loadData());
  }

  void deleteSpecies(Species species) async {
    var func = BotToast.showLoading();
    final _result = await AbsPlatformService.get(_site)!.deleteSpecies(host: _site.url, id: species.id);
    func.call();
    if (_result.success) {
      showToast(text: 'Delete Success');
      loadData();
    } else {
      showToast(text: '${_result.error}');
    }
  }
}
