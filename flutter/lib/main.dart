import 'package:flutter/foundation.dart';
// import 'package:worker_manager/worker_manager.dart';

import 'entry_stub.dart' if (dart.library.html) 'entry/browser_entry.dart' if (dart.library.io) 'entry/native_entry.dart';

void main(List<String> args) async {
  // workerManager.log = kDebugMode;
  // await workerManager.init();
  root(args);
}
