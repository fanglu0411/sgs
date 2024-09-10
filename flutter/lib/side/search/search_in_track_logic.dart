import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/sgs_service_delegate.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:get/get.dart';

class SearchResultItem {
  // late String chrId;
  // late String featureId;
  late String featureName;
  late num start;
  late num end;

  ///
  SearchResultItem.fromMap(Map map) {
    // chrId = map['chr_id'];
    // featureId = map['feature_id'];
    featureName = map['feature_name'];
    start = map['start'];
    end = map['end'];
  }

  Range get range => Range(start: start, end: end);
}

class SearchInTrackLogic extends GetxController {
  static SearchInTrackLogic? get(Track track, {bool autoPut = true}) {
    if (Get.isRegistered<SearchInTrackLogic>(tag: track.id)) {
      return Get.find<SearchInTrackLogic>(tag: track.id);
    }
    if (autoPut) {
      return Get.put(SearchInTrackLogic(track), tag: track.id);
    }
    return null;
  }

  Track track;
  int page = 1;
  int pageSize = 10;
  bool loading = false;
  String? error;

  List<SearchResultItem>? data;
  int _count = 135;

  int get count => _count;

  bool get dataEmpty => data == null || data!.length == 0;

  String? _searchKeyword;

  SearchInTrackLogic(this.track) {}

  @override
  void onReady() {
    super.onReady();
  }

  void search(String keyword, {int page = 1}) async {
    var speciesId = SgsAppService.get()!.session!.speciesId;
    var chr = SgsAppService.get()!.chr1;
    var site = SgsAppService.get()!.site;

    if (site == null || chr == null) {
      return;
    }

    _searchKeyword = keyword;
    loading = true;
    error = null;
    update([track.id!]);

    var resp = await SgsServiceDelegate.searchTrackFeature(
      host: site.url,
      speciesId: speciesId,
      chrId: chr.id,
      trackId: track.id!,
      keyword: keyword,
      page: page,
      count: pageSize,
    );

    loading = false;
    if (resp.success) {
      List _data = resp.body['data'] ?? [];
      List _header = resp.body['header'];
      // List _header = ['start', 'end', 'feature_name'];
      // _count = resp.body['records_count'];
      data = _data.map((e) {
        return SearchResultItem.fromMap(Map.fromIterables(_header, e));
      }).toList();
      error = null;
    } else {
      error = resp.error!.message;
    }
    update([track.id!]);
  }

  void onPageChange(int page) {
    this.page = page;
    search(_searchKeyword!, page: page);
  }
}
