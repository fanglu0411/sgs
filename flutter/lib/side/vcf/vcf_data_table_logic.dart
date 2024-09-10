import 'package:dartx/dartx.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/network/core/http_error.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/side/vcf/filter_view.dart';
import 'package:flutter_smart_genome/side/vcf/operator.dart';
import 'package:flutter_smart_genome/util/lru_cache.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

class VcfDataTableLogic extends GetxController {
  Track? _track;

  static VcfDataTableLogic? safe() {
    if (Get.isRegistered<VcfDataTableLogic>()) {
      return Get.find<VcfDataTableLogic>();
    }
    return null;
  }

  Track? get track => _track;

  void set track(Track? track) {
    if (_track != track) {
      _track = track;

      _data.clear();
      _filters?.clear();
      _filters = null;
      pageCache.clear();
      _page = 1;
    }
  }

  bool _loading = false;
  HttpError? _error = null;
  List<Map> _data = [];

  bool get loading => _loading;

  HttpError? get error => _error;

  List<Map> get data => _data;

  List<FilterItem>? _filters;

  List<FilterItem>? get filters => _filters;

  int _page = 1;
  int _pageSize = 10;
  int _totalPage = 1;
  int _totalCount = 0;

  int get page => _page;

  int get pageSize => _pageSize;

  int get totalPage => _totalPage;

  int get totalCount => _totalCount;

  List _headers = [];
  List<String> _infoTags = [];

  List<FilterColumn> get filterColumns {
    return _headers.map<FilterColumn>((e) => FilterColumn(e, tags: '$e'.toLowerCase() == 'info' ? _infoTags : null)).toList();
  }

  LruCache<int, List<Map>?> pageCache = LruCache<int, List<Map>?>(100);

  List<Map>? getPageRows(int page) {
    return pageCache.get(page);
  }

  void cachePageRows(int page, List<Map>? rows) {
    if (rows == null || rows.isEmpty) return;
    pageCache.save(page, rows);
  }

  void setFilters(List<FilterItem>? filters) {
    _filters = filters;
    _page = 1;
    pageCache.clear();
  }

  @override
  void onReady() {
    super.onReady();
  }

  void setPageSize(int pageSize) {
    pageCache.clear();

    int start = _page * _pageSize;
    int __page = start ~/ _pageSize;
    _pageSize = pageSize;
    // _page = __page;
    loadData(__page, _pageSize);
  }

  Future<(List<Map>, String? error, int totalCount)> loadData(int page, int pageSize) async {
    _error = null;
    _loading = true;
    update();

    SiteItem site = SgsAppService.get()!.site!;
    var chr = SgsAppService.get()!.chr1!.id;
    var session = SgsAppService.get()!.session;
    List<Map> _filterParams = (_filters ?? []).map((f) => f.json).toList();
    var resp = await AbsPlatformService.get()!.loadTrackTableData(
      host: site.url,
      speciesId: site.currentSpeciesId!,
      chrId: chr,
      track: track!,
      filters: _filterParams,
      start: session!.range!.start.floor(),
      end: session.range!.end.floor(),
      page: page,
      pageSize: pageSize,
    );
    _loading = false;
    if (resp.success) {
      Map body = resp.body;
      List data = body['data'] ?? [];
      List header = body['header'];

      if (data.length > 0) {
        List first = data.first;
        if (header.length < first.length) {
          header.addAll(List.generate(first.length - header.length, (index) => 'col${index}'));
        }
        _data = data.map((e) => Map.fromIterables(header, e)).toList();
      } else {
        _data = [];
      }
      _headers = header;
      _infoTags = (body['info_tags'] ?? []).map<String>((e) => '$e').toList();

      _totalCount = body['rec_count'];
      _totalPage = (totalCount / _pageSize).ceil();
      _page = page;
      cachePageRows(page, _data);

      return Future.value((_data, error?.message, _totalCount));
    } else {
      _data = [];
      _error = resp.error;
      _page = page;
      return Future.value((_data, error?.message, 0));
      // update();
    }
  }

  void prepareTableData(List<Map> data, {bool cached = false}) {
    // update(['pagination']);
    update();
  }

  void filterDataTable(List<FilterItem> filters) async {
    var filterData = _data.where((e) => _filterValue(e, filters)).toList();
  }

  bool _filterValue(Map value, List<FilterItem> filters) {
    // FilterItem filter = filters.first;
    bool _result = false; // = operator(filter.operator, value[filter.column], filter.value);

    filters.forEachIndexed((filter, i) {
      bool _r = operator(filter.operator!, value[filter.column], filter.value);
      if (i == 0) {
        _result = _r;
      } else {
        if (filter.logicTo == 'and') {
          _result = _result && _r;
        } else {
          _result = _result || _r;
        }
      }
    });
    return _result;
  }
}
