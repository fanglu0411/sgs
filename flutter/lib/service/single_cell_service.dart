import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/network/adapter/base_feature_adapter.dart';
import 'package:flutter_smart_genome/network/core/http_error.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/service/beans.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/network/api/simple_request.dart' as http_util;
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:dartx/dartx.dart' as dx;

Future<HttpResponseBean> addSingleCell({
  String host = '',
  required Map data,
}) {
  return http_util.postJson(
    path: '${host}/api/sc/add',
    data: data,
    cache: false,
  );
}

Future<HttpResponseBean> confirmClusters({
  String host = '',
  required String scId,
  required List clusters,
  CancelToken? cancelToken,
}) {
  return http_util.postJson(
    path: '${host}/api/sc/add/complete/transcript',
    data: {'sc_id': scId, 'cell_meta_columns': clusters},
    cache: false,
    cancelToken: cancelToken,
  );
}

Future<HttpResponseBean<Map>> loadAllPotentialClusters({
  String host = '',
  required String scId,
}) async {
  var resp = await http_util.postJson(
    path: '${host}/api/sc/cell/column/all',
    data: {'sc_id': scId},
    cache: false,
  );
  if (resp.success) {
    Map clusters = resp.body!['cell_meta_columns'];
    return HttpResponseBean<Map>.fromBody(clusters);
  }
  return HttpResponseBean<Map>.fromError(resp.error!);
}

Future<HttpResponseBean> deleteSingleCell({
  String host = '',
  required String scId,
}) {
  return http_util.postJson(
    path: '${host}/api/sc/delete',
    data: {'sc_id': scId},
    cache: false,
  );
}

///
/// single cell track list
///
Future<HttpResponseBean<List<Track>>> loadCellTrackList({
  String host = '',
  required String speciesId,
  bool refresh = false,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean<Map> responseBean = await http_util.postJson(
    path: '${host}/api/sc/list',
    data: {'species_id': speciesId},
    cache: true,
    forceRefresh: refresh,
    duration: Duration(hours: 1),
    responseType: ResponseType.plain,
    cancelToken: cancelToken,
  );
  if (!responseBean.success) {
    return HttpResponseBean<List<Track>>.fromError(responseBean.error!);
  }
  try {
    Map trackMap = responseBean.body!;
    List trackList = trackMap['sc_list'] ?? [];
    List<Track> tracks = trackList.map<Track>((e) => Track.fromMap({...e, 'bio_type': 'sc'})).toList();
    return HttpResponseBean<List<Track>>.fromBody(tracks);
  } catch (e) {
    return HttpResponseBean<List<Track>>.error(e);
  }
}

///
/// single cell expression track data
///
Future<HttpResponseBean<List<CellExpFeature>>> loadCellExpData({
  String host = '',
  required Track track,
  required String chrId,
  required Range range,
  required String groupName,
  CancelToken? cancelToken,
}) async {
  Future<List<CellExpFeature>> _loadBlockData(int block) async {
    HttpResponseBean responseBean = await http_util.postJson(
      path: '${host}/api/track/data',
      data: {
        'sc_id': track.scId,
        'track_id': track.id,
        'track_type': track.bioType,
        'chr_id': chrId,
        'group_name': groupName,
        'block_index': block,
      },
      cache: true,
      cancelToken: cancelToken,
    );
    if (responseBean.success && responseBean.body != null) {
      Map body = responseBean.body is String ? json.decode(responseBean.body) : responseBean.body;
      List expressions = body[groupName] ?? [];
      return expressions.map<CellExpFeature>((e) => CellExpFeature.fromMap(e, track.bioType)).toList();
    }
    return [];
  }

  Map<int, Range> blocks = findBlocksInRange(track, chrId, range);
  Iterable<List<CellExpFeature>> _list = await Future.wait<List<CellExpFeature>>(blocks.keys.map<Future<List<CellExpFeature>>>(_loadBlockData).toList());
  List<CellExpFeature> data = _list.flatten().toList();
  return HttpResponseBean<List<CellExpFeature>>.fromBody(data);
}

Map<int, Range> findBlocksInRange(Track track, String chrId, Range range) {
  Map statics = (track.statics ?? []).firstWhere((s) => s['chr_id'] == chrId, orElse: () => {});
  num? blockStep = statics['block_step'];
  if (null == blockStep) throw Exception('block info not set!');
  int block = range.start ~/ blockStep;
  num _start = block * blockStep;
  num _end = _start + blockStep;

  Map<int, Range> blocks = {};

  blocks[block] = Range(start: _start, end: _end);
  while (_end < range.end) {
    block++;
    _start = block * blockStep;
    _end = _start + blockStep;
    blocks[block] = Range(start: _start, end: _end);
  }
  return blocks;
}

///
/// load cell plot data
///
Future<HttpResponseBean> loadCellPlotData({
  String host = '',
  required Track track,
  required String matrixId,
  required String groupName,
  required String plotType,
  // required bool cartesian,
  bool refresh = false,
  CancelToken? cancelToken,
  ProgressCallback? onReceiveProgress,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/cell/group',
    data: {
      'track_id': track.id,
      'sc_id': track.scId,
      'mod_id': matrixId,
      'group_name': groupName,
      'plot_name': plotType,
    },
    receiveTimeOut: Duration(seconds: 5 * 60),
    cache: true,
    forceRefresh: refresh,
    cancelToken: cancelToken,
    onReceiveProgress: onReceiveProgress,
  );
  if (resp.success) {
    Map body = resp.body is String ? json.decode(resp.body) : resp.body;
    Map? data = body['cell_plot_data'];
    if (data == null) {
      return HttpResponseBean.error(body);
    }
    Map<String, List> map = data.map<String, List>((key, value) => MapEntry(key, value));
    return HttpResponseBean.fromBody(map);
  }
  return HttpResponseBean.fromError(resp.error!);
}

///
/// load cell plot data
///
Future<HttpResponseBean> loadSpatialPlotData({
  String host = '',
  required Track track,
  required String matrixId,
  required String groupName,
  required String spatialKey,
  bool refresh = false,
  CancelToken? cancelToken,
  ProgressCallback? onReceiveProgress,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/spatial/spot',
    data: {
      'sc_id': track.scId,
      'mod_id': matrixId,
      'column_name': groupName,
      'spatial_key': spatialKey,
    },
    receiveTimeOut: Duration(seconds: 5 * 60),
    forceRefresh: refresh,
    cache: true,
    cancelToken: cancelToken,
    onReceiveProgress: onReceiveProgress,
  );
  var body = resp.body is String ? json.decode(resp.body) : resp.body;
  if (resp.success) {
    Map? data = body['cell_plot_data'];
    if (data == null) {
      return HttpResponseBean.error(body);
    }
    Map<String, List> map = data.map<String, List>((key, value) => MapEntry(key, value));
    return HttpResponseBean.fromBody(map);
  }
  return HttpResponseBean.fromError(resp.error!);
}

///
/// load feature(gene, peak) plot data
///
Future<HttpResponseBean> loadFeaturePlotData({
  String host = '',
  required Track track,
  required List features,
  required String plotType,
  required String matrixId,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/cell/feature',
    data: {
      'sc_id': track.scId,
      'track_id': track.id,
      'features': features,
      'plot_name': plotType,
      'mod_id': matrixId,
    },
    receiveTimeOut: Duration(seconds: 5 * 60),
    cache: true,
    cancelToken: cancelToken,
  );
  if (resp.success) {
    var body = resp.body is String ? json.decode(resp.body) : resp.body;
    List? data = body['cell_plot_data'];
    if (data == null) return HttpResponseBean.error(body);
    return HttpResponseBean.fromBody(data);
  }
  return HttpResponseBean.fromError(resp.error!);
}

///
/// load marker features list
///
Future<HttpResponseBean> loadCellMarkerFeatures({
  String host = '',
  required Track track,
  required String? groupName,
  required String? groupValue,
  required String plotType,
  required String matrixId,
  required String? orderBy,
  required String? order,
  required int pageNumber,
  required int pageSize,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/marker/feature/table',
    data: {
      'track_id': track.id,
      'sc_id': track.scId,
      'mod_id': matrixId,
      'column_name': groupName,
      'column_value': groupValue,
      'order_by': order == null ? null : orderBy,
      'order': orderBy == null ? null : order,
      'plot_name': plotType,
      'page_num': pageNumber,
      'page_size': pageSize,
    },
    cache: true,
    cancelToken: cancelToken,
    receiveTimeOut: Duration(seconds: 3 * 60),
  );
  return resp;
}

/// search marker features
Future<HttpResponseBean> searchMarkerFeature({
  String host = '',
  required Track track,
  required String matrixId,
  required String column,
  required String keyword,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/marker/search',
    data: {
      'track_id': track.id,
      'sc_id': track.scId,
      'mod_id': matrixId,
      'column_name': column,
      'marker_name': keyword,
    },
    cache: false,
    cancelToken: cancelToken,
    receiveTimeOut: Duration(seconds: 3 * 60),
  );
  return resp;
}

/// marker table column filters
Future<HttpResponseBean> loadMarkerFeatureFilters({
  String host = '',
  required Track track,
  required String matrixId,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/marker/column/detail',
    data: {
      'track_id': track.id,
      'sc_id': track.scId,
      'mod_id': matrixId,
    },
    cache: true,
    cancelToken: cancelToken,
  );
  return resp;
}

///
/// load marker gene list
///
Future<HttpResponseBean> loadCellMarkerGeneList({
  String host = '',
  required Track track,
  required String groupName,
  required String? groupValue,
  required String plotType,
  required String matrixId,
  required int pageNumber,
  required int pageSize,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/marker/gene/list',
    data: {
      'track_id': track.id,
      'plot_name': plotType,
      'sc_id': track.scId,
      'group_name': groupName,
      'group_value': groupValue,
      'matrix_id': matrixId,
      'page_num': pageNumber,
      'page_size': pageSize,
    },
    cache: true,
    cancelToken: cancelToken,
    receiveTimeOut: Duration(seconds: 3 * 60),
  );
  return resp;
}

///
/// load cluster meta list
///
Future<HttpResponseBean<Map>> loadClusterMetaList({
  String host = '',
  required Track track,
  required String? groupName,
  required String? groupValue,
  required String matrixId,
  int page = 1,
  int pageSize = 20,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/cluster/meta',
    data: {
      'sc_id': track.scId,
      'mod_id': matrixId,
      'column_name': groupName,
      'column_value': groupValue,
      'page_num': page,
      'page_size': pageSize,
    },
    cache: true,
    cancelToken: cancelToken,
    receiveTimeOut: Duration(seconds: 3 * 60),
  );
  if (resp.success) {
    // var body = resp.body;
    try {
      var body = resp.body is String ? json.decode(resp.body) : resp.body;
      // List clusterMetas = body['cluster_info'];
      // List header = body['header'];
      // List<Map> metas = clusterMetas.map((e) => null).toList();
      return HttpResponseBean<Map>.fromBody(body);
    } catch (e) {
      return HttpResponseBean<Map>.error(e);
    }
  }
  return HttpResponseBean<Map>.fromError(resp.error!);
}

///
/// load marker gene plot image
///
Future<HttpResponseBean> loadFeatureImage({
  String host = '',
  required String imageId,
  required String? plotType,
  required String matrixId,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/marker/feature/image',
    data: {
      'image_id': imageId,
      'plot_name': plotType,
      'matrix_id': matrixId,
    },
    cache: false,
    cancelToken: cancelToken,
  );
  if (resp.success) {
    var body = resp.body;
    return HttpResponseBean.fromBody(body);
  }
  return HttpResponseBean.fromError(resp.error!);
}

///
/// batch load marker images
Future<HttpResponseBean> loadMarkerGeneImages({
  String host = '',
  required List imageIds,
  required String plotType,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/marker/features/images',
    data: {
      'image_ids': imageIds,
      'plot_name': plotType,
    },
    cache: false,
    cancelToken: cancelToken,
  );
  return resp;
}

///
/// load marker gene plot image
///
Future<HttpResponseBean> searchGene({
  String host = '',
  required String speciesId,
  required String feature,
  required Track track,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    // path: '${host}/api/sc/gene/search',
    path: '${host}/api/sc/feature/location',
    data: {
      'sp_id': speciesId,
      'species_id': speciesId,
      'sc_id': track.scId,
      'feature_name': feature,
    },
    cache: false,
    cancelToken: cancelToken,
  );
  return resp;
  // if (resp.success) {
  //   var body = resp.body;
  //   return HttpResponseBean.fromBody(body);
  // }
  // return HttpResponseBean.error(resp.message);
}

///
/// batch load compare gene images
Future<HttpResponseBean> loadCompareFeatureImages({
  String host = '',
  required String scId,
  required List genes,
  required String matrix,
  required String group,
  required String chartType,
  required String? plotType,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/compare/$chartType',
    data: {
      'sc_id': scId,
      'mod_id': matrix,
      'feature_names': genes,
      'column_name': group,
      'plot_name': plotType,
    },
    cache: false,
    cancelToken: cancelToken,
  );
  // if (resp.success) {
  //   Map body = resp.body;
  //   var images = body[body.keys.first];
  //   if (chartType == 'heatmap' || chartType == 'dotplot') images = [body];
  //   return HttpResponseBean.fromBody(images);
  // }
  return resp;
}

///
/// batch load gene structures
Future<HttpResponseBean> loadGeneStructures({
  String host = '',
  required String scId,
  required List<String> features,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/compare/gene_structure',
    data: {
      'sc_id': scId,
      'feature_names': features,
    },
    cache: false,
    cancelToken: cancelToken,
  );
  if (resp.success) {
    Map body = resp.body;
    // print(body);
    List features = body['gene_structure'];
    List header = body['header'];
    FeatureMetaHeaderManager()['search_gene'] = {'feature': header};
    var adapter = BaseFeatureAdapter()..header = header;
    List<RangeFeature> __features = features.map((e) {
      Map? map = adapter.itemToMap(e, header);
      return RangeFeature.fromMap(map!, 'search_gene', 'feature');
    }).toList();
    return HttpResponseBean<List<RangeFeature>>.fromBody(__features);
  }
  return resp;
}

/////// atac

///
/// peaks
Future<HttpResponseBean<List>> loadPeaks({
  String host = '',
  required Track track,
  required String chrId,
  CancelToken? cancelToken,
  required String species,
  required Range range,
}) async {
  Map<int, Range> blocks = findBlocksInRange(track, chrId, range);
  Iterable<int> _blocks = blocks.keys;
  // Iterable<int> _blocks = [1];

  Future<List<Peak>> _loadBlockPeaks(int block) async {
    HttpResponseBean resp = await http_util.postJson(
      path: '${host}/api/track/data',
      data: {
        'sc_id': track.scId,
        'track_id': track.id,
        'chr_id': chrId,
        'block_index': block,
      },
      cache: true,
      cancelToken: cancelToken,
    );
    if (resp.success) {
      Map body = resp.body is String ? json.decode(resp.body) : resp.body;
      // print(body);
      List data = body['data'] ?? [];
      List<Peak> peaks = data.where((e) => e.length > 2).map((e) => Peak(e)).toList();
      return peaks;
    }
    return [];
  }

  List<List<Peak>> _list = await Future.wait<List<Peak>>(_blocks.map<Future<List<Peak>>>(_loadBlockPeaks));
  List<Peak> data = _list.flatten().toList();
  return HttpResponseBean<List<Peak>>.fromBody(data);
}

///
/// peak pairs (co access)
Future<HttpResponseBean<List>> loadPeakPairs({
  String host = '',
  required Track track,
  required String chrId,
  CancelToken? cancelToken,
  required String species,
  required Range range,
}) async {
  Map<int, Range> blocks = findBlocksInRange(track, chrId, range);
  Iterable<int> _blocks = blocks.keys;
  // Iterable<int> _blocks = [1];

  Future<List<PeakPair>> _loadBlockPeaks(int block) async {
    HttpResponseBean resp = await http_util.postJson(
      path: '${host}/api/track/data',
      data: {
        'sc_id': track.scId,
        'track_id': track.id,
        'chr_id': chrId,
        'block_index': block,
      },
      cache: true,
      cancelToken: cancelToken,
    );
    if (resp.success) {
      Map body = resp.body is String ? json.decode(resp.body) : resp.body;
      // print(body);
      List data = body['data'] ?? [];
      List<PeakPair> peakPairs = data.where((e) => e.length >= 2).map((e) => PeakPair.array(e)).toList();
      return peakPairs;
    }
    return [];
  }

  List<List<PeakPair>> _list = await Future.wait<List<PeakPair>>(_blocks.map<Future<List<PeakPair>>>(_loadBlockPeaks));
  List<PeakPair> data = _list.flatten().toList();
  return HttpResponseBean<List<PeakPair>>.fromBody(data);
}

Future<List<T>> loadGroupCoverageData<T>({
  String host = '',
  required Track track,
  required String speciesId,
  required String chr,
  int level = 1,
  required int start,
  required int end,
  required int count,
  required Map blockMap,
  required String valueType,
  required String groupName,
  CancelToken? cancelToken,
}) async {
  if (level == 1) {
    return loadGroupCoverageDataStatics<T>(
      host: host,
      track: track,
      speciesId: speciesId,
      chr: chr,
      level: level,
      start: start,
      end: end,
      count: count,
      blockMap: blockMap,
      valueType: valueType,
      groupName: groupName,
      cancelToken: cancelToken,
    );
  } else {
    return loadGroupCoverageDataInterval<T>(
      host: host,
      track: track,
      speciesId: speciesId,
      chr: chr,
      level: level,
      start: start,
      end: end,
      count: count,
      blockMap: blockMap,
      valueType: valueType,
      groupName: groupName,
      cancelToken: cancelToken,
    );
  }
}

Future<List<T>> loadGroupCoverageDataStatics<T>({
  String host = '',
  required Track track,
  required String speciesId,
  required String chr,
  int level = 1,
  required int start,
  required int end,
  required int count,
  required Map blockMap,
  required String valueType,
  required String groupName,
  CancelToken? cancelToken,
}) async {
  /// return [{start, end ,value:{a: 1, b: 2, c:3}}, ... ]
  Future<List<Map>> _loadBlockData(Map blockInfo) async {
    num _start = blockInfo['start'];
    num _end = blockInfo['end'];
    int _count = count;
    num _rangeSize = _end - _start;
    if (_rangeSize < blockInfo['blockSize']) {
      _count = (_rangeSize / blockInfo['blockSize'] * count).ceil();
    }
    Map params = {
      'species_id': speciesId,
      'chr_id': chr,
      'track_id': track.id,
      'track_type': track.bioType,
      'ref_start': _start.toInt(),
      'ref_end': _end.toInt(),
      'level': level,
      'histo_count': _count,
      'group_name': groupName,
      'stats_type': valueType,
    };
    // print(params);
    HttpResponseBean responseBean = await http_util.postJson(
      path: '${host}/api/track/data',
      data: params,
      cache: true,
      cancelToken: cancelToken,
    );
    if (responseBean.success) {
      Map map = responseBean.body;
      var _data = map['data'];
      if (_data == null || _data.length == 0) {
        return [];
      }
      Map data = _data;
      List<String> groups = data.keys.toList().map<String>((e) => e).toSet().toList();
      // Map _data = data.map((key, value) => MapEntry(key, value));
      List group1Data = data[data.keys.first];
      if (group1Data.length == 0) return [];
      int interval = _rangeSize ~/ group1Data.length;
      return group1Data.mapIndexed<Map>((index, e) {
        var _value = groups.asMap().map((i, key) => MapEntry(key, data[key][index]));
        return {
          'start': _start + index * interval,
          'end': _start + index * interval + interval,
          'strand': 1,
          'value': _value,
          // 'nValue': null,
        };
      }).toList();
    }
    return [];
  }

  Map<String, Map> names = {};
  Range ncRange;
  Range? intersection;
  List keys = blockMap.keys.toList();
  Range _range = Range(start: start, end: end);
  for (var nc in keys) {
    ncRange = Range(start: blockMap[nc]['start'], end: blockMap[nc]['end']);
    intersection = _range.intersection(ncRange);
    if (intersection != null) {
      names['${nc}'] = blockMap[nc];
    }
  }
  Iterable<List<Map>> _list = await Future.wait<List<Map>>(names.values.map<Future<List<Map>>>(_loadBlockData).toList());
  return _list.flatten().toList() as List<T>;
}

/// level 3 [{group: [{start, end, value}, ...]
Future<List<T>> loadGroupCoverageDataInterval<T>({
  String host = '',
  required Track track,
  required String speciesId,
  required String chr,
  int level = 3,
  required int start,
  required int end,
  required int count,
  required Map blockMap,
  required String valueType,
  required String groupName,
  CancelToken? cancelToken,
}) async {
  /// return [{start, end ,value:{a: 1, b: 2, c:3}}, ... ]
  List _groups = [];
  Future<Map<String, List<RangeFeature>>> _loadBlockData(Map blockInfo) async {
    num _start = blockInfo['start'];
    num _end = blockInfo['end'];
    int _count = count;
    num _rangeSize = _end - _start;
    if (_rangeSize < blockInfo['blockSize']) {
      _count = (_rangeSize / blockInfo['blockSize'] * count).ceil();
    }
    Map params = {
      'species_id': speciesId,
      'chr_id': chr,
      'track_id': track.id,
      'track_type': track.bioType,
      'ref_start': _start.toInt(),
      'ref_end': _end.toInt(),
      'level': level,
      'histo_count': _count,
      'group_name': groupName,
      'stats_type': valueType,
    };
    // print(params);
    HttpResponseBean responseBean = await http_util.postJson(
      path: '${host}/api/track/data',
      data: params,
      cache: true,
      cancelToken: cancelToken,
    );
    if (responseBean.success) {
      Map map = responseBean.body;
      Map data = map['data'];
      List<String> groups = data.keys.toList().map<String>((e) => e).toSet().toList();
      if (_groups.length < groups.length) _groups = groups;
      if (data.length == 0) return {};
      logger.d('${track.name} => ${_start} - $_end => data length: ${data.length}, count: $count');
      var header = map['header'];
      Map metaHeaders = header is List ? {'feature': header} : header;
      FeatureMetaHeaderManager()[track.bioType] = metaHeaders;

      ///data type {a: [[start, end ,value], ...], b:[[start, end, value], ...], ...}
      var dataItems = data.map<String, List<RangeFeature>>((group, list) {
        List _list = list;
        return MapEntry<String, List<RangeFeature>>(
            group,
            _list
                .map<RangeFeature>((arr) {
                  var itemMap = Map.fromIterables(header, arr);
                  return RangeFeature.fromMap(itemMap, track.bioType);
                })
                .where((f) => f['value'] != 0)
                .toList());
      });
      return dataItems;
    }
    return {};
  }

  Map<String, Map> names = {};
  Range ncRange;
  Range? intersection;
  List keys = blockMap.keys.toList();
  Range _range = Range(start: start, end: end);
  for (var nc in keys) {
    ncRange = Range(start: blockMap[nc]['start'], end: blockMap[nc]['end']);
    intersection = _range.intersection(ncRange);
    if (intersection != null) {
      names['${nc}'] = blockMap[nc];
    }
  }

  Iterable<Map<String, List<RangeFeature>>> _list = await Future.wait<Map<String, List<RangeFeature>>>(names.values.map<Future<Map<String, List<RangeFeature>>>>(_loadBlockData).toList());
  Map<String, List<RangeFeature>> result = Map.fromIterable(_groups, key: (k) => k, value: (k) => <RangeFeature>[]);
  _list.forEach((map) {
    map.forEach((group, list) => result[group]!.addAll(list));
  });
  // result.forEach((key, value) {
  //   print("$key");
  //   print(value.map((e) => e.json).toList());
  // });

  var t = result.keys.map<T>((e) => {"group": e, 'data': result[e]} as T).toList();
  return t;
}

Future<HttpResponseBean> download({
  required String url,
  required String savePath,
  CancelToken? cancelToken,
}) async {
  return await http_util.download(
    url: url,
    savePath: savePath,
    cancelToken: cancelToken,
  );
}

Future<HttpResponseBean> getStream({
  required String url,
  CancelToken? cancelToken,
}) async {
  return await http_util.get(
    path: url,
    responseType: ResponseType.bytes,
    cancelToken: cancelToken,
  );
}

/// atac

/// load group marker peaks
@Deprecated('use feature instead')
Future<HttpResponseBean<Map>> loadMarkerPeaks({
  String host = '',
  required Track track,
  required String matrixId,
  required String? groupName,
  required String? groupValue,
  required String plotType,
  required int pageNumber,
  required int pageSize,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/marker/peak/list',
    data: {
      'sc_id': track.scId,
      'matrix_id': matrixId,
      'group_name': groupName,
      'group_value': groupValue,
      'plot_type': plotType,
      'page_num': pageNumber,
      'page_size': pageSize,
    },
    cache: true,
    cancelToken: cancelToken,
  );
  if (resp.success) {
    //{group_coverage_track_id, group_name,matrix_id, marker_peaks}
    var body = resp.body;
    return HttpResponseBean<Map>.fromBody(body);
  }
  return HttpResponseBean<Map>.fromError(resp.error!);
}

/// load group marker peak group coverage, table(小图)
Future<HttpResponseBean<List<Map>>> loadMarkerPeakGroupCoverage({
  String host = '',
  required Track track,
  required String matrixId,
  required String groupName,
  required String featureName,
  required num start,
  required num end,
  required String chrName,
  CancelToken? cancelToken,
}) async {
  var coverageTrack = track.children!.firstOrNullWhere((t) => t.trackType == TrackType.sc_group_coverage);
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/marker/peak/data',
    data: {
      'track_id': coverageTrack?.id,
      'sc_id': track.scId,
      'chr_name': chrName,
      'matrix_id': matrixId,
      'group_name': groupName,
      'feature_name': featureName,
      'ref_start': start,
      'ref_end': end,
      'level': 3,
    },
    cache: true,
    cancelToken: cancelToken,
  );
  if (resp.success) {
    //{group_coverage_track_id, group_name,matrix_id, marker_peaks}
    var map = resp.body;
    Map data = map['data'];
    if (data.length == 0) return HttpResponseBean<List<Map>>.fromBody([]);
    logger.d('${track.name} => ${start} - $end => data length: ${data.length}, count: ${data.length}');
    List header = map['header'];

    ///data type {a: [[start, end ,value], ...], b:[[start, end, value], ...], ...}
    var dataItems = data.map<String, List<RangeFeature>>((group, list) {
      List _list = list;
      return MapEntry<String, List<RangeFeature>>(
          group,
          _list
              .map<RangeFeature>((arr) {
                var itemMap = Map.fromIterables(header, arr);
                return RangeFeature.fromMap(itemMap, track.bioType);
              })
              .where((f) => f['value'] != 0)
              .toList());
    });
    var t = dataItems.keys.map<Map>((e) => {"group": e, 'data': dataItems[e]}).toList();
    return HttpResponseBean<List<Map>>.fromBody(t);
  }
  return HttpResponseBean<List<Map>>.fromError(resp.error!);
}

///
/// load marker gene list
///
@Deprecated('use feature instead')
Future<HttpResponseBean> loadMarkerMotifs({
  String host = '',
  required Track track,
  required String? groupName,
  required String? groupValue,
  required String plotType,
  required String matrixId,
  required int pageNumber,
  required int pageSize,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/marker/motif/list',
    data: {
      'track_id': track.id,
      'sc_id': track.scId,
      'matrix_id': matrixId,
      'plot_name': plotType,
      'group_name': groupName,
      'group_value': groupValue,
      'page_num': pageNumber,
      'page_size': pageSize,
    },
    cache: true,
    cancelToken: cancelToken,
  );
  //{marker_genes: []}
  return resp;
}

///
/// load motif logo data
Future<HttpResponseBean> loadMotifLogo({
  String host = '',
  required Track track,
  required String matrixId,
  required String feature,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/marker/motif/logo',
    data: {
      'track_id': track.id,
      'sc_id': track.scId,
      'mod_id': matrixId,
      'motif_name': feature,
    },
    cache: true,
    cancelToken: cancelToken,
    receiveTimeOut: Duration(seconds: 5 * 60),
  );
  return resp;
}

// load all cell expression by feature with group
Future<HttpResponseBean> loadFeatureExpressions({
  String host = '',
  required Track track,
  required String matrixId,
  required String feature,
  required String group,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/compare/feature/exp',
    data: {
      'track_id': track.id,
      'sc_id': track.scId,
      'mod_id': matrixId,
      'feature_name': feature,
      'column_name': group,
    },
    cache: true,
    cancelToken: cancelToken,
    receiveTimeOut: Duration(seconds: 5 * 60),
  );
  if (resp.success) {
    var body = resp.body is String ? json.decode(resp.body) : resp.body;
    return HttpResponseBean<List>.fromBody(body['data']);
  }
  return resp;
}

Future<HttpResponseBean> loadFeatureAvgExpressionInGroup({
  String host = '',
  required Track track,
  required String matrixId,
  required List features,
  required String group,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/compare/heatmap',
    data: {
      'track_id': track.id,
      'sc_id': track.scId,
      'mod_id': matrixId,
      'feature_names': features,
      'column_name': group,
    },
    cache: true,
    cancelToken: cancelToken,
    receiveTimeOut: Duration(minutes: 5 * 60),
  );
  if (resp.success) {
    var body = resp.body is String ? json.decode(resp.body) : resp.body;
    return HttpResponseBean.fromBody(body);
  }
  return resp;
}

@Deprecated('use image instead')
Future<HttpResponseBean> loadSpatialImage({
  String host = '',
  required Track track,
  required String matrixId,
  required String spatial,
  required String resolution,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/spatial/rgb',
    data: {
      'sc_id': track.scId,
      'mod_id': matrixId,
      'spatial_key': spatial,
      'res': resolution,
    },
    cache: true,
    cancelToken: cancelToken,
  );
  return resp;
}

Future<HttpResponseBean> loadSpatialPlot({
  String host = '',
  required Track track,
  required String matrixId,
  required String spatial,
  required String groupName,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/spatial/spot',
    data: {
      'sc_id': track.scId,
      'mod_id': matrixId,
      'group_name': groupName,
      'spatial_key': spatial,
    },
    cache: true,
    cancelToken: cancelToken,
  );
  return resp;
}

//plot data of single feature spatial
Future<HttpResponseBean> loadSpatialFeatureExpressions({
  String host = '',
  required Track track,
  required String matrixId,
  required String spatial,
  required List features,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/spatial/feature',
    data: {
      'sc_id': track.scId,
      'mod_id': matrixId,
      'spatial_key': spatial,
      'features': features,
    },
    cache: true,
    cancelToken: cancelToken,
    receiveTimeOut: Duration(seconds: 5 * 60),
  );
  if (resp.success) {
    Map body = resp.body;
    return HttpResponseBean<List>.fromBody(body['spot_data'] ?? []);
  }
  return resp;
}

///
/// meta stack bar data
///
Future<HttpResponseBean> loadMetaStatics({
  String host = '',
  required Track track,
  required String matrixId,
  required String groupBy,
  required String colorBy,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/compare/stacked_bar',
    data: {
      'sc_id': track.scId,
      'mod_id': matrixId,
      'group_by': groupBy,
      'color_by': colorBy,
    },
    cache: true,
    cancelToken: cancelToken,
  );
  return resp;
}

///
/// search gene
///
Future<HttpResponseBean> searchGeneByKeyword({
  String host = '',
  required Track track,
  required String matrixId,
  required String keyword,
  CancelToken? cancelToken,
}) async {
  HttpResponseBean resp = await http_util.postJson(
    path: '${host}/api/sc/feature/search',
    data: {
      'sc_id': track.scId,
      'mod_id': matrixId,
      'feature_name': keyword,
    },
    cache: false,
    duration: Duration(minutes: 30),
    cancelToken: cancelToken,
  );
  return resp;
}
