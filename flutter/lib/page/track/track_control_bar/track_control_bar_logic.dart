import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:get/get.dart';

class TrackControlBarLogic extends GetxController {
  static TrackControlBarLogic? safe([String tag = '1']) {
    if (Get.isRegistered<TrackControlBarLogic>(tag: tag)) {
      return Get.find<TrackControlBarLogic>(tag: tag);
    }
    return null;
  }

  Range? _range;

  void set range(Range? range) => _range = range;

  Range? get range => _range;

  updateRange(Range range) {
    _range = range;
    update();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
