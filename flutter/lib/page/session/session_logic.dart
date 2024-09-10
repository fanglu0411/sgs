import 'package:flutter_smart_genome/storage/base_store_provider.dart';
import 'package:flutter_smart_genome/storage/isar/session_list_provider.dart';

import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:get/get.dart';
import 'package:dartx/dartx.dart' as dx;

class SessionLogic extends GetxController {
  static SessionLogic? find() {
    if (Get.isRegistered<SessionLogic>()) {
      return Get.find<SessionLogic>();
    }
    return null;
  }

  TrackSession? _currentSession;

  void set currentSession(TrackSession? session) {
    _currentSession = session!.copy();
    update();
  }

  TrackSession? get currentSession => _currentSession;

  List<TrackSession> _sessions = [];

  List<TrackSession> get sessions => _sessions;

  bool get empty => _sessions.length == 0;

  @override
  void onReady() {
    super.onReady();
    loadSessionList();
  }

  loadSessionList() async {
    _sessions = await BaseStoreProvider.get().getSessionList();
    _sessions = _sessions.sortedByDescending((element) => element.saveTime!).toList();
    update();
  }

  void addSession(TrackSession session) async {
    TrackSession s = session.copy(autoSave: false);
    session..saveTime = DateTime.now().millisecondsSinceEpoch;
    BaseStoreProvider.get().addSession(s);
    _sessions = await BaseStoreProvider.get().getSessionList();
    update();
  }

  deleteSession(TrackSession session) async {
    BaseStoreProvider.get().deleteSession(session);
    _sessions = await BaseStoreProvider.get().getSessionList();
    update();
  }
}
