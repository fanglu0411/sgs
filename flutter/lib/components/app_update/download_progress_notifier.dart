import 'package:flutter/foundation.dart';

class DownloadProgressNotifier extends ChangeNotifier {
  double progress = 0;
  late String versionName;
  late List updates;

  updateVersion({required String versionName, required List updates}) {
    this.versionName = versionName;
    this.updates = updates;
  }

  updateProgress(double progress) {
    this.progress = progress;
    notifyListeners();
  }
}