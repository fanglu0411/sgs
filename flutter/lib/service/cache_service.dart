import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

class CacheService extends GetxService {
  static CacheService? get() {
    if (Get.isRegistered<CacheService>()) {
      return Get.find<CacheService>();
    }
    return null;
  }

  /// methylation track max deeps is always same in any scale
  static Map<String, num> deepMaxCache = {};

  void setDeepMaxValue(Track track, num max) {
    num _cacheMax = deepMaxCache[track.id] ?? 0;
    // if (max > _cacheMax) deepMaxCache[track.id!] = max;
    deepMaxCache[track.id!] = max;
  }

  num getDeepMaxValue(Track track) => deepMaxCache[track.id] ?? 0;

  Map<String, String> _projectInfoMap = {};

  void saveProjectInfo(String pid, String content) {
    _projectInfoMap[pid] = content;
  }

  String? getCacheProjectInfo(String pid) {
    return _projectInfoMap[pid];
  }

  @override
  void onInit() {
    super.onInit();
  }
}
