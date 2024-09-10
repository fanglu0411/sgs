import 'dart:math';

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

part 'site_item.g.dart';

enum SiteSource {
  sgs,
  jbrowse,
  locale,
}

@collection
class SiteItem {
  @Id()
  late int id;

  @Ignore()
  String get sid => '$id'; // '${url.hashCode}';

  late SiteSource source;

  String? name;
  late String url;

  String? currentSpecies;
  String? currentSpeciesId;

  int? createTime;
  int? updateTime;

  late bool isDemoServer;

  @Ignore()
  bool get editable => !isDemoServer;

  @Ignore()
  String get safeName => nameEmpty ? url : name!;

  SiteItem({
    this.name,
    required this.url,
    this.source = SiteSource.sgs,
    this.isDemoServer = false,
  }) {
    createTime = DateTime.now().millisecondsSinceEpoch;
    id = (url + '-${createTime}').hashCode;
  }

  @Ignore()
  bool get nameEmpty => name == null || name!.length == 0;

  Map asMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'source': source.index,
      'isDemoServer': isDemoServer,
      'currentSpecies': currentSpecies,
      'currentSpeciesId': currentSpeciesId,
      'createTime': createTime,
      'updateTime': updateTime,
    };
  }

  SiteItem.fromMap(Map map) {
    name = map['name'];
    url = map['url'];
    createTime = map['createTime'];
    updateTime = map['updateTime'];
    int _source = map['source'] ?? 0;
    source = SiteSource.values[_source];
    id = map['id'] ?? '$url-${createTime}'.hashCode;
    currentSpecies = map['currentSpecies'];
    currentSpeciesId = map['currentSpeciesId'];
    isDemoServer = map['isDemoServer'] ?? false;
  }

  @Ignore()
  bool get isSgs => source == SiteSource.sgs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SiteItem &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          name == other.name &&
          url == other.url &&
          currentSpecies == other.currentSpecies &&
          currentSpeciesId == other.currentSpeciesId &&
          createTime == other.createTime &&
          updateTime == other.updateTime &&
          isDemoServer == other.isDemoServer;

  @override
  int get hashCode => source.hashCode ^ name.hashCode ^ url.hashCode ^ currentSpecies.hashCode ^ currentSpeciesId.hashCode ^ createTime.hashCode ^ updateTime.hashCode ^ isDemoServer.hashCode;

  SiteItem copy() {
    return SiteItem(
      name: name,
      url: url,
      source: source,
    )
      ..currentSpeciesId = currentSpeciesId
      ..currentSpecies = currentSpecies
      ..updateTime = DateTime.now().millisecondsSinceEpoch
      ..createTime = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  String toString() {
    return 'SiteItem{id: $sid, name: $name, url: $url, isDemoServer: $isDemoServer, currentSpecies: $currentSpecies, currentSpeciesId: $currentSpeciesId}';
  }

  Map toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'source': source.index,
      'isDemoServer': isDemoServer,
      'currentSpecies': currentSpecies,
      'currentSpeciesId': currentSpeciesId,
      'createTime': createTime,
      'updateTime': updateTime,
    };
  }
}
