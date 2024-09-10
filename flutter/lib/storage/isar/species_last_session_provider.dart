import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/storage/store.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

class SpeciesLastSessionProvider {
  ///find session by url, current species
  static Future<TrackSession?> findSession(SiteItem site) async {
    Isar isar = await Store.get().isar;
    if (site.currentSpeciesId == null) return null;
    return isar.trackSessions
            .where()
            .autoSaveEqualTo(true)
            .siteIdEqualTo(site.id)
            .speciesIdEqualTo(site.currentSpeciesId!) //
            .findFirst() ?? //
        isar.trackSessions
            .where()
            .autoSaveEqualTo(true)
            .urlEqualTo(site.url)
            .speciesIdEqualTo(site.currentSpeciesId!) //
            .findFirst();
  }

  static Future<int> autoIncrement() async {
    Isar isar = await Store.get().isar;
    return isar.trackSessions.autoIncrement();
  }

  static saveSession(TrackSession session) async {
    Isar isar = await Store.get().isar;
    session.id = isar.trackSessions.autoIncrement();
    await isar.writeAsync((isar) => isar.trackSessions.put(session));
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

  static Future<List<TrackSession>> getSessions() async {
    Isar isar = await Store.get().isar;
    var sessions = isar.trackSessions.where().autoSaveEqualTo(true).findAll();
    return sessions;
  }

  static Future<bool> deleteSession(TrackSession session) async {
    Isar isar = await Store.get().isar;
    return await isar.writeAsync<bool>((isar) => isar.trackSessions.delete(session.id));
  }

  static Future<List<TrackSession>> findByUrl(String url) async {
    Isar isar = await Store.get().isar;
    return isar.trackSessions.where().autoSaveEqualTo(true).urlEqualTo(url).findAllAsync();
  }

  static updateSession(TrackSession session) async {
    Isar isar = await Store.get().isar;
    try {
      session.id;
    } catch (e) {
      session.id = isar.trackSessions.autoIncrement();
      isar.printError(info: 'update session error! id not set!');
    }
    isar.writeAsync((isar) => isar.trackSessions.put(session));
  }

  static deleteAll() async {
    Isar isar = await Store.get().isar;
    await isar.writeAsync((isar) => isar.trackSessions.where().autoSaveEqualTo(true).deleteAll());
  }
}
