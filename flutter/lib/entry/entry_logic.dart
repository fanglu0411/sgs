import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:get/get.dart';

class EntryLogic extends GetxController {
  static EntryLogic get() {
    return Get.find<EntryLogic>();
  }

  EntryLogic() {
    _loading = true;
  }

  @override
  void onReady() {
    super.onReady();
    _check();
  }

  check() {
    _loading = true;
    update();
  }

  _check() async {
    _loading = !SgsConfigService.get()!.ready;
    if (!_loading) {
      update();
    }
  }

  late bool _loading;

  bool get loading => _loading;

  String? _error;

  String? get error => _error;

  void show() {
    _loading = false;
    update();
  }

  void onError(String msg) {
    _loading = false;
    _error = msg;
  }
}
