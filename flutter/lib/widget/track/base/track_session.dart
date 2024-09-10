import 'dart:math';

import 'package:dartx/dartx.dart' as dx;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_genome/base/app_layout.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/network/dio_helper.dart';
import 'package:flutter_smart_genome/platform/platform_adapter.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';
import 'package:flutter_smart_genome/storage/isar/site_provider.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:isar/isar.dart';

part 'track_session.g.dart';

RegExp urlRegexp = RegExp(r'^(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]$');

Future<String?> validateSessionUrl(String? url) async {
  if (null == url) return null;
  if (url.startsWith('sgs://')) url = url.substring(6).replaceFirst('https//', 'https://');
  if (url.contains('app=SGS_SHARE')) {
    return url;
  }
  if (urlRegexp.hasMatch(url)) {
    try {
      var resp = await DioHelper().thirdDio.get(
            url,
            options: Options(
              followRedirects: false,
            ),
          );
      if (resp.statusCode! >= 300 && resp.statusCode! < 400) {
        var headers = resp.headers;
        String? originUrl = headers.value('location');
        return originUrl;
      }
    } catch (e) {
      if (e is DioException) {
        var headers = e.response!.headers;
        String? originUrl = headers.value('location');
        return originUrl;
      }
    }
    return null;
  }
  return null;
}

class ShareSession {
  late TrackSession session;
  late String url;

  ShareSession({required this.session, required this.url});

  static Future<ShareSession> fromSessionUrl(String url) async {
    Uri uri = Uri.parse(Uri.decodeFull(url.replaceAll('/#', '')));
    Map<String, String> params = uri.queryParameters;

    String? _serverName = params['sn'];
    String _serverHost = uri.origin + uri.path;
    _serverHost = _serverHost.endsWith('/') ? _serverHost.substring(0, _serverHost.length - 1) : _serverHost;
    String? _spsName = params['pn'];
    String? _speciesId = params['pid'];
    List<String> _tracks = (params['tracks'] ?? '').split(',').map((s) => '$s:1').toList();
    String? _chrId = params['chr'];
    String? _chrId2 = params['chr2'];
    String? _chrName = params['cn'];
    String? _chrName2 = params['cn2'];
    String? scId = params['scid'];
    List<double?> _range = (params['rg'] ?? '').split(',').map((e) => double.tryParse(e)).toList();
    SiteItem _site = SiteItem(url: _serverHost, name: _serverName);
    _site.currentSpeciesId = _speciesId;
    _site.currentSpecies = _spsName;
    // _site = await SiteProvider.saveUrlNotExits(_site);

    int _appLayout = int.tryParse(params['layout'] ?? '0') ?? 0;
    AppLayout layout = AppLayout.values[_appLayout % AppLayout.values.length];

    TrackSession session = TrackSession(
      siteId: _site.id,
      url: _site.url,
      chrId: _chrId,
      chrName: _chrName,
      speciesName: _spsName,
      speciesId: _speciesId!,
      tracks: _tracks,
      range: _range.length == 2 ? Range(start: _range[0]!, end: _range[1]!) : null,
      appLayout: layout,
      scId: scId,
    );

    return ShareSession(session: session, url: uri.toString());
  }
}

@collection
class TrackSession {
  @Id()
  late int id;

  late int siteId;
  late String url;

  List<String>? tracks;
  String? chrId;
  String? chrName;
  String? speciesName;
  late String speciesId;
  AppLayout? appLayout;
  String? scId;

  /// auto save species last session
  late bool autoSave;

  @Ignore()
  Range? get range => rangeList != null && rangeList!.length > 1 ? Range(start: rangeList!.first, end: rangeList!.last) : null;

  int? saveTime;
  int? updateTime;

  void set range(Range? range) {
    if (range == null) {
      rangeList = null;
    } else {
      rangeList = [range.start, range.end];
    }
  }

  List<double>? rangeList;

  TrackSession({
    required this.siteId,
    required this.url,
    required this.speciesId,
    required this.speciesName,
    this.chrName,
    this.chrId,
    this.tracks,
    this.autoSave = true,
    this.appLayout,
    this.scId,
    Range? range,
  }) {
    saveTime = DateTime.now().millisecondsSinceEpoch;
    updateTime = DateTime.now().millisecondsSinceEpoch;
    if (range != null) rangeList = [range.start, range.end];
    id = Random().nextInt(99999);
  }

  Future<String> toShareUrl() async {
    var site = kIsWeb ? null : await BaseStoreProvider.get().findSiteByUrl(url);
    Map params = {
      'app': 'SGS_SHARE',
      'sn': site?.name,
      'pid': speciesId,
      'pn': speciesName,
      'scid': scId,
      'chr': chrId,
      'cn': chrName,
      'rg': range?.print(','),
      'layout': appLayout?.index ?? SgsConfigService.get()!.appLayout.index,
      'tracks': (tracks ?? []).where((t) => t.endsWith(":1")).map((e) => e.split(':')[0]).join(','), // only add checked track
    };
    String __url = kIsWeb ? PlatformAdapter.create().getLocationUrl().split('?')[0] : '${site?.url ?? url}/home';
    final query = params.entries.filter((e) => e.value != null).map((e) => '${e.key}=${e.value}').join('&');
    return '${__url}?${query}';
  }

  static Future<TrackSession?> fromUrl(String url) async {
    Uri uri = Uri.parse(Uri.decodeFull(url));
    Map<String, String> params = uri.queryParameters;

    String? _serverName = params['sn'];
    String _serverHost = uri.origin;

    var _cacheSite = await BaseStoreProvider.get().findSiteByUrl(_serverHost);
    SiteItem site = _cacheSite ?? SiteItem(url: _serverHost, name: _serverName);

    String? speciesId = params['pid'];
    if (speciesId == null || speciesId.length == 0) return null;

    String? species = params['pn'] ?? '-';
    String? scId = params['scid'];
    List<String> tracks = (params['tracks'] ?? '').split(',').map((s) => '$s:1').toList();
    String? chrId = params['chr'];
    String? chrName = params['cn'];
    String? chrId2 = params['chr2'];
    String? chrName2 = params['cn2'];
    List<double?> _range = (params['rg'] ?? '').split(',').map((e) => double.tryParse(e)).toList();
    Range? range = _range.length == 2 ? Range(start: _range[0]!, end: _range[1]!) : null;

    site.currentSpeciesId = speciesId;
    site.currentSpecies = species;

    int _appLayout = int.tryParse(params['layout'] ?? '0') ?? 0;
    AppLayout layout = AppLayout.values[_appLayout % AppLayout.values.length];

    return TrackSession(
      siteId: site.id,
      url: site.url,
      speciesName: species,
      speciesId: speciesId,
      chrId: chrId,
      chrName: chrName,
      range: range,
      tracks: tracks,
      appLayout: layout,
      scId: scId,
    );
  }

  Map toMap() {
    return {
      'id': id,
      'siteId': siteId,
      'url': url,
      'tracks': tracks,
      'chr': chrName,
      'chrId': chrId,
      'species': speciesName,
      'speciesId': speciesId,
      'scid': scId,
      'range': range == null ? null : '${range?.start}--${range?.end}',
      'saveTime': saveTime,
      'updateTime': updateTime,
      'autoSave': autoSave,
      'layout': appLayout?.index,
    };
  }

  TrackSession.fromMap(Map map) {
    id = map['id'] ?? Random().nextInt(99999);
    siteId = map['siteId']!;
    url = map['url'];
    List? _tracks = map['tracks'];
    tracks = _tracks != null ? _tracks.map((e) => '$e').toList() : null;
    speciesName = map['species'];
    speciesId = map['speciesId'];
    chrId = map['chrId'];
    chrName = map['chr'];
    scId = map['scid'];

    // int _appLayout = int.tryParse(map['layout'] ?? '0') ?? 0;
    // AppLayout layout = AppLayout.values[_appLayout % AppLayout.values.length];

    String? _range = map['range'];
    if (_range != null) {
      List<double?> rge = _range.split('--').map((e) => double.tryParse(e)).toList();
      if (rge[0] != null && rge[1] != null) rangeList = [rge[0]!, rge[1]!];
    }
    saveTime = map['saveTime'];
    updateTime = map['updateTime'];
    autoSave = map['autoSave'];
  }

  @override
  String toString() {
    return 'TrackSession{id: $id, siteId: $siteId, url: $url, tracks: $tracks, chrId: $chrId, chrName: $chrName, speciesName: $speciesName, speciesId: $speciesId, appLayout: $appLayout, scId: $scId, autoSave: $autoSave, saveTime: $saveTime, updateTime: $updateTime, rangeList: $rangeList}';
  }

  TrackSession copy({
    int? siteId,
    String? url,
    String? chrId,
    String? chrName,
    String? species,
    String? speciesId,
    List<String>? tracks,
    Range? range,
    bool? autoSave,
  }) {
    return TrackSession(
      siteId: siteId ?? this.siteId,
      url: url ?? this.url,
      speciesId: speciesId ?? this.speciesId,
      speciesName: species ?? this.speciesName,
      chrId: chrId ?? this.chrId,
      chrName: chrName ?? this.chrName,
      tracks: tracks ?? tracks,
      range: range ?? this.range,
      autoSave: autoSave ?? this.autoSave,
    )..saveTime = DateTime.now().millisecondsSinceEpoch;
  }

  @Ignore()
  String get key => '${hashCode}';

  @Ignore()
  String get storeKey => 's-${siteId.hashCode ^ chrId.hashCode ^ speciesId.hashCode ^ range.hashCode}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackSession &&
          runtimeType == other.runtimeType &&
          siteId == other.siteId &&
          tracks == other.tracks &&
          chrId == other.chrId &&
          chrName == other.chrName &&
          speciesName == other.speciesName &&
          speciesId == other.speciesId &&
          range == other.range &&
          autoSave == other.autoSave &&
          saveTime == other.saveTime &&
          updateTime == other.updateTime;

  @override
  int get hashCode =>
      siteId.hashCode ^ tracks.hashCode ^ chrId.hashCode ^ chrName.hashCode ^ speciesName.hashCode ^ speciesId.hashCode ^ range.hashCode ^ saveTime.hashCode ^ updateTime.hashCode ^ autoSave.hashCode;
}
