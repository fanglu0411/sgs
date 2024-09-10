import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/storage/store.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:isar/isar.dart';

class SessionListProvider {
  static saveSession(TrackSession session) async {
    Isar isar = await Store.get().isar;
    await isar.writeAsync((isar) => isar.trackSessions.put(session..id = isar.trackSessions.autoIncrement()));
  }

  static saveSessions(List<TrackSession> sessions) async {
    Isar isar = await Store.get().isar;
    await isar.writeAsync((isar) {
      for (var session in sessions) {
        session.id = isar.trackSessions.autoIncrement();
      }
      isar.trackSessions.putAll(sessions);
    });
  }

  static Future<List<TrackSession>> getSessions([SiteItem? site]) async {
    Isar isar = await Store.get().isar;
    return site == null ? isar.trackSessions.where().autoSaveEqualTo(false).sortBySaveTimeDesc().findAll() : isar.trackSessions.where().siteIdEqualTo(site.id).sortBySaveTimeDesc().findAll();
  }

  static Future<bool> deleteSession(TrackSession session) async {
    Isar isar = await Store.get().isar;
    return await isar.writeAsync<bool>((isar) => isar.trackSessions.delete(session.id));
  }

  static Future<List<TrackSession>> findByUrl(String url) async {
    Isar isar = await Store.get().isar;
    return isar.trackSessions.where().autoSaveEqualTo(false).urlEqualTo(url).findAllAsync();
  }

  static updateSession(TrackSession session) async {
    Isar isar = await Store.get().isar;
    isar.writeAsync((isar) => isar.trackSessions.put(session));
  }

  static deleteAll() async {
    Isar isar = await Store.get().isar;
    await isar.writeAsync((isar) => isar.trackSessions.where().autoSaveEqualTo(false).deleteAll());
  }
}
