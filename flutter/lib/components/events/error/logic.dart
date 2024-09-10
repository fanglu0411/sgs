import 'package:get/get.dart';

class ErrorEventItem {
  late String title;
  DateTime? time;
  dynamic error;

  ErrorEventItem({
    required this.title,
    this.error,
  }) {
    time ??= DateTime.now();
  }
}

class ErrorEventLogic extends GetxController {
  static ErrorEventLogic? safe() {
    if (Get.isRegistered<ErrorEventLogic>()) {
      return Get.find<ErrorEventLogic>();
    }
    return null;
  }

  List<ErrorEventItem> _data = [];

  int get count => _data.length;

  bool get isEmpty => count == 0;

  List<ErrorEventItem> get data => _data;

  void add(ErrorEventItem item) {
    if (_data.length > 100) {
      _data.removeAt(0);
    }
    _data.add(item);
    update();
  }

  void clear() {
    _data.clear();
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
