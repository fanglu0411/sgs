import 'dart:convert';

import 'package:dio/dio.dart' show CancelToken;
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/network/adapter/base_feature_adapter.dart';
import 'package:flutter_smart_genome/network/adapter/data_adapter.dart';
import 'package:flutter_smart_genome/network/adapter/eqtl_feature_adapter.dart';
import 'package:flutter_smart_genome/network/api/simple_request.dart' as http_util;
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/service/beans.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/widget/track/vcf_sample/vcf_sample_feature_layout.dart';

class SgsServiceDelegate extends AbsPlatformService {
  static SgsServiceDelegate _instance = SgsServiceDelegate._init();

  SgsServiceDelegate._init() {}

  factory SgsServiceDelegate() => _instance;

  Future<HttpResponseBean> createSpecies({String host = '', required Map body, Map? header}) {
    return http_util.postJson(
      path: '${host}/api/species/add',
      data: body,
    );
  }

  Future<HttpResponseBean<List<Species>>> loadSpeciesList({
    String host = '',
    Map body = const {},
    bool forceRefresh = false,
    CancelToken? cancelToken,
  }) async {
    HttpResponseBean resp = await http_util.postJson(
      path: '${host}/api/species/list',
      data: body,
      cache: true,
      forceRefresh: forceRefresh,
      cancelToken: cancelToken,
    );
    if (resp.success) {
      // print(json.encode(resp.body));
      List _list = resp.body['species_list'];
      List<Species> species = _list.map<Species>((map) => Species.fromMap(map)).toList();
      // species.add(Species(
      //   'test',
      //   status: 'done',
      // )..id = '5be19640fcd048cda466a398d3b9fce6');
      return HttpResponseBean<List<Species>>.fromBody(species);
    }
    return HttpResponseBean<List<Species>>.fromError(resp.error!);
  }

  /// project intro page
  Future<HttpResponseBean> getSpeciesIntro({String host = '', dynamic id}) {
    return http_util.postJson(
      path: '${host}/api/species/info/get',
      data: {"species_id": '$id'},
    );
  }

  // update project intro page
  Future<HttpResponseBean> updateSpeciesIntro({String host = '', dynamic id, String? speciesName, required String content}) {
    return http_util.postJson(
      path: '${host}/api/species/info/update',
      data: {
        "species_id": '$id',
        "species_name": speciesName,
        'species_info': content,
      },
    );
  }

  Future<HttpResponseBean> deleteSpecies({String host = '', dynamic id}) {
    return http_util.postJson(
      path: '${host}/api/species/delete',
      data: {"species_id": '$id'},
    );
  }

  @override
  Future<HttpResponseBean> addTrack({required String host, required Map params}) {
    return http_util.postJson(
      path: '${host}/api/track/add',
      data: params,
    );
  }

  @override
  Future<HttpResponseBean> addTracks({required String host, required Map params}) {
    return http_util.postJson(
      path: '${host}/api/track/add',
      data: params,
    );
  }

  @override
  Future<HttpResponseBean> deleteTrack({String host = '', dynamic trackId}) {
    return http_util.postJson(
      path: '${host}/api/track/delete',
      data: {'track_id': trackId},
    );
  }

  @override
  Future<Map<String, Range>> findFileNameInRage({
    String host = '',
    required Range range,
    required Track track,
    required String species,
    required String chr,
    int level = 1,
    bool inflate = true,
  }) async {
    Map<String, Range> names = {};

    Map trackConfigData = await loadTrackConfig(host: host, track: track, chr: chr, species: species);
    Map _levelBlocks;
    if (level == 1) {
      _levelBlocks = trackConfigData['histo_mapping'] ?? {};
    } else if (level == 2) {
      _levelBlocks = trackConfigData['basic_mapping'] ?? trackConfigData['expand_mapping'] ?? trackConfigData['expand_feature_block_mapping'] ?? {};
    } else {
      _levelBlocks = trackConfigData['expand_mapping'] ?? trackConfigData['expand_feature_block_mapping'] ?? {};
    }
//    print('track:$track, chr:$chr');
    logger.d(_levelBlocks);
//    List _levels = trackConfigData['data'];

//    Map levelData = _levels.firstWhere((element) => element['zoom_level'] == level, orElse: () => {});
    num? blockStep = _levelBlocks['block_step'];
    num? blockCount = _levelBlocks['block_count'];
    Map? levelRange = _levelBlocks['block_locations'];

    if (levelRange == null) {
      if (blockStep != null && blockStep != 0) {
        int block = range.start ~/ blockStep;
        num _start = block * blockStep;
        num _end = _start + blockStep;

        names['$block'] = Range(start: _start, end: _end);
        while (_end < range.end) {
          block++;
          _start = block * blockStep;
          _end = _start + blockStep;
          names['$block'] = Range(start: _start, end: _end);
        }
      }
      return names;
    }

    Range _inflateRange = inflate ? range.inflate(range.size * .1) : range;

    Range ncRange;
    Range? intersection;
    List keys = levelRange.keys.toList().sortedBy((e) => int.parse(e));
    for (var nc in keys) {
      ncRange = Range(start: levelRange[nc][0], end: levelRange[nc][1]);
      intersection = _inflateRange.intersection(ncRange);
      if (intersection != null) {
        names['${nc}'] = ncRange;
      }
    }
//    logger.d('level:$level, $track, range: $range, _inflateRange:$_inflateRange, files: $names');
    return names;
  }

  MapEntry<Range, List<Range>> findSequenceFilesInRange({
    String host = '',
    required Range range,
    int? fileSequenceLength,
    required String chr,
  }) {
    /// 不分块
    if (null == fileSequenceLength) {
      return MapEntry<Range, List<Range>>(range.copy(), [range.copy()]);
    }

    var delta = range.start % fileSequenceLength;
    int blockStart = (range.start ~/ fileSequenceLength);
    int blockEnd = (range.end ~/ fileSequenceLength);

    List<Range> blocks = [];
    for (int block = blockStart; block <= blockEnd; block++) {
      blocks.add(Range(start: block * fileSequenceLength, end: block * fileSequenceLength + fileSequenceLength));
    }

    return MapEntry<Range, List<Range>>(Range(start: blocks.first.start, end: blocks.last.end), blocks);
  }

  @override
  Future<List<ChromosomeData>> loadChromosomes({
    required String speciesId,
    String host = '',
    bool refresh = false,
    CancelToken? cancelToken,
  }) async {
    HttpResponseBean responseBean = await http_util.postJson(
      path: '$host/api/species/chromosomes',
      data: {'species_id': speciesId},
      cache: true,
      forceRefresh: refresh,
      cancelToken: cancelToken,
    );
    if (responseBean.success) {
      List chrList = responseBean.body['chromsomes'];
      List<ChromosomeData> chromosomes = chrList.map<ChromosomeData>((e) => ChromosomeData.fromMap(e)).toList();
      if (chromosomes.length < 2) {
        return chromosomes;
      }
      RegExp reg = RegExp(r'chr([0-9]+)([\D0-9]*)');
      chromosomes.forEach((c) {
        var matches = reg.firstMatch(c.chrName);
        if (matches != null && matches.groupCount > 1) {
          c.chrNum = int.tryParse(matches.group(1)!) ?? 0;
        }
      });
      return chromosomes //
          .sortedBy((c) => c.chrName)
          .thenBy((c) => c.chrNum)
          .sortedBy((c) => c.chrName.length) //
          .thenBy((c) => c.chrNum)
          .toList();
    }
    return [];
  }

  @override
  Future<RangeSequence> loadSequence({
    String host = '',
    required Range range,
    double? scale,
    Track? track,
    required String chr,
    required String species,
    int? blockLength,
  }) async {
    Future<String> _loadSequenceFile(Range range) async {
      HttpResponseBean responseBean = await http_util.postJson(
        path: '$host/api/chromosome/block/sequence',
        data: {
          'species_id': species,
          'chr_id': chr,
          // 'block_index': fileName,
          'start': range.start,
          'end': range.end,
        },
        cache: true,
      );
      if (responseBean.success) {
        Map body = responseBean.body;
        String seq = body['sequence'];
        return seq;
        // return seq.substring(seq.indexOf('\n') + 1);
        // return seq.replaceFirst(RegExp('${chr}>\n'), '');
      }
      return List.generate(blockLength!, (index) => '').join('');
    }

    MapEntry<Range, List<Range>> blocks = findSequenceFilesInRange(
      host: host,
      range: range,
      fileSequenceLength: blockLength,
      chr: chr,
    );
    // logger.d(blocks);
    Range seqRange = blocks.key;
    List<String> sequences = await Future.wait<String>(blocks.value.map<Future<String>>(_loadSequenceFile));
    // logger.d('length: ${sequences.map((e) => e.length).join(', ')}');
    return RangeSequence(seqRange, sequences.join(''));
  }

  @override
  Future<Map> loadTrackConfig({
    String host = '',
    required Track track,
    required String chr,
    required String species,
  }) async {
    HttpResponseBean responseBean = await http_util.postJson(
      path: '$host/api/track/fragment/location',
      cache: true,
      data: {
        "track_id": track.id,
        "chr_id": chr,
      },
    );
    if (responseBean.success) {
      return responseBean.body;
    }
    return {};
  }

  @override
  Future<HttpResponseBean<List>> loadTrackData({
    String host = '',
    required Range range,
    required double scale,
    required Track track,
    required String chr,
    required String species,
    int level = 1,
    Set<String>? featureTypes,
    CancelToken? cancelToken,
    required DataAdapter adapter,
  }) async {
    Future<Iterable> loadTrackData(String fileName, Range blockRange) async {
      HttpResponseBean responseBean = await http_util.postJson(
        path: '${host}/api/track/data/compress',
        data: {
          'species_id': species,
          'track_id': track.id,
          'track_type': track.bioType,
          'chr_id': chr,
          'block_index': fileName,
          'level': level,
          'ref_start': blockRange.start,
          'ref_end': blockRange.end,
          'binsize': -1,
        },
        cache: true,
        cancelToken: cancelToken,
      );
      if (responseBean.success && responseBean.body != null && responseBean.bodyStr!.length > 0) {
        Map map = responseBean.body is String ? json.decode(responseBean.body) : responseBean.body;
        List? data = map['data'] ?? map['block_data'];
        if (data == null) return [];
        var metaHeader = map['header'];
        var subHeader = map['sub_header'];
        logger.d('${track.trackName}, ${track.bioType}, level: $level, count: ${data.length}');
        if (track.isVcfSample && level == 3) {
          VcfSampleFeatureLayout layout = TrackLayoutManager().getTrackLayout(track) as VcfSampleFeatureLayout;
          layout.sampleList ??= map['sample_names'];
          layout.typeCodeMap ??= map['sample_geno_type_code'];
        }
        adapter
          ..trackLevel = level
          ..header = metaHeader;
        if (subHeader != null) {
          adapter.setSubFeatureHeader('sub_feature', subHeader);
        }
        Map metaHeaders = metaHeader is List ? {'feature': metaHeader} : metaHeader;
        if (metaHeader is List && metaHeader.any((e) => e is Map)) {
          List mapMetas = metaHeader.where((e) => e is Map).toList();
          mapMetas.forEach((m) {
            Map _m = m;
            metaHeaders[_m.entries.first.key] = _m.entries.first.value;
          });
        }
        if (subHeader != null) {
          metaHeaders['sub_feature'] = subHeader;
        }
        FeatureMetaHeaderManager()[track.bioType] = metaHeaders;
        return adapter.parseFeatureData(data.where((arr) => arr.length > 0), range: range);
        // List<Feature> features = data
        //     .where((arr) => arr.length > 0)
        //     .map(adapter.parseItem ?? (list) => Feature(list, track.bioType)) //
        //     .where((f) => f.range == null || range.collide(f.range)) //
        //     .toList();
      }
      return [];
    }

    //找到这个区间对应的文件，如果跨区间，则要找到夸区间的所有文件
    Map<String, Range> nameList = await findFileNameInRage(host: host, range: range, track: track, species: species, chr: chr, level: level);
    // logger.d('${track.trackName} =====> blocks $range');
    // logger.d(nameList);
    Iterable<Iterable> _list = await Future.wait<Iterable>(
      nameList.keys.map<Future<Iterable>>((key) => loadTrackData(key, nameList[key]!)),
    );
    List data = _list.flatten().toList();
    return HttpResponseBean.fromBody(data);
  }

  @override
  Future<HttpResponseBean<List<Track>>> loadAllTrackList({
    String host = '',
    required String species,
    bool refresh = false,
    CancelToken? cancelToken,
  }) async {
    return loadTrackList(host: host, species: species, refresh: refresh, cancelToken: cancelToken);
  }

  @override
  Future<HttpResponseBean<List<Track>>> loadTrackList({
    String host = '',
    required String species,
    bool refresh = false,
    CancelToken? cancelToken,
  }) async {
    HttpResponseBean responseBean = await http_util.postJson(
      path: '${host}/api/track/list',
      data: {'species_id': species},
      cache: true,
      forceRefresh: refresh,
      cancelToken: cancelToken,
    );
    if (!responseBean.success) {
      return HttpResponseBean.fromError(responseBean.error!);
    }
    Map trackMap = responseBean.body;
    // print(json.encode(trackMap));
    List trackList = trackMap['tracks'] ?? [];

    var tracks = trackList.map<Track>((e) {
      return Track.fromMap(e);
    }).toList();
    return HttpResponseBean.fromBody(tracks);
  }

  @override
  Future<HttpResponseBean<List>> loadBigwigData({
    String host = '',
    required Track track,
    required String speciesId,
    required String chr,
    int level = 1,
    required int start,
    required int end,
    required int binSize,
    required int count,
    required Map blockMap,
    required String valueType,
    CancelToken? cancelToken,
    required DataAdapter adapter,
  }) async {
    Future<Iterable> _loadBlockData(Map blockInfo) async {
      num _start = blockInfo['start'];
      num _end = blockInfo['end'];
      num? interval = blockInfo['interval']; //第三层级没有
      int _count = count;
      num _rangeSize = _end - _start;
      num? binSize = blockInfo['binSize']; //第三层级没有
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
        'binsize': binSize,
        'level': level,
        'histo_count': _count, //deprecated, use binsize instead
        'stats_type': valueType,
      };
      HttpResponseBean responseBean = await http_util.postJson(
        path: '${host}/api/track/data',
        data: params,
        cache: true,
        cancelToken: cancelToken,
      );
      if (responseBean.success) {
        Map map = responseBean.body;
        if (map['header'] is List) {
          var header = map['header'];
          Map metaHeaders = header is List ? {'feature': header} : header;
          FeatureMetaHeaderManager()[track.bioType] = metaHeaders;
          adapter.header = header;
        }
        adapter.trackLevel = level;

        if (level == 1) {
          var data = map['data'];
          if (map['data'] == null || map['data'].length == 0) {
            return [];
          }

          return adapter.parseCartesianData(data, _start, _end, interval);

          //   // print(map);
          //   if (track.isBed) {
          //     List data = map['data'];
          //     int interval = _rangeSize ~/ data.length;
          //     return data.mapIndexed((index, p1) {
          //       return {
          //         'start': _start + index * interval,
          //         'end': _start + index * interval + interval,
          //         'pValue': {'bed': p1},
          //         'nValue': null,
          //       };
          //     }).toList();
          //   } //
          //   else if (track.isMethylation) {
          //     Map data = map['data'];
          //     List group1Data = data[data.keys.first];
          //     int interval = _rangeSize ~/ group1Data.length;
          //     Iterable<String> _keys = data.keys.map((e) => '$e');
          //     if (_keys.any((k) => k.startsWith('p_') || k.startsWith('_'))) {
          //       List<String> groups = _keys.map<String>((e) => e.split('_').reversed.first).toSet().toList();
          //       return group1Data.mapIndexed((index, e) {
          //         var _value = groups.asMap().map((i, key) => MapEntry(key, data['p_$key'][index] ?? 0));
          //         return {
          //           'start': _start + index * interval,
          //           'end': _start + index * interval + interval,
          //           'pValue': _value,
          //           'nValue': groups.asMap().map((i, key) => MapEntry(key, data['n_$key'][index] ?? 0)),
          //           // ..._value,
          //         };
          //       }).toList();
          //     } else {
          //       List<String> groups = data.keys.toList();
          //       return group1Data.mapIndexed((index, e) {
          //         var _value = groups.asMap().map((i, key) => MapEntry(key, data[key][index] ?? 0));
          //         return {
          //           'start': _start + index * interval,
          //           'end': _start + index * interval + interval,
          //           'pValue': _value,
          //           'nValue': groups.asMap().map((i, key) => MapEntry(key, 0)),
          //           // ..._value,
          //         };
          //       }).toList();
          //     }
          //   } else if (!track.isBigWig) {
          //     Map data = map['data'];
          //     List<String> groups = data.keys.toList().map<String>((e) => e).toSet().toList();
          //     // Map _data = data.map((key, value) => MapEntry(key, value));
          //     List group1Data = data[data.keys.first];
          //     int interval = _rangeSize ~/ group1Data.length;
          //     return group1Data.mapIndexed((index, e) {
          //       var _value = groups.asMap().map((i, key) => MapEntry(key, data[key][index]) ?? 0);
          //       return {
          //         'start': _start + index * interval,
          //         'end': _start + index * interval + interval,
          //         'pValue': _value,
          //         'nValue': null,
          //       };
          //     }).toList();
          //   }
        } else {
          List data = map['data'];
          return adapter.parseFeatureData(data, range: Range(start: start, end: end));
        }

        // List data = map['data'];
        // if (data.length == 0) return [];
        // logger.d('${track.trackName} => bigwig => data length: ${data.length}, count: $count');
        //
        // int interval = _rangeSize ~/ data.length;
        //
        // if (level == 3) {
        //   var dataItems = data.map((arr) => header.asMap().map((index, key) => MapEntry(key, arr[index])));
        //   return dataItems.toList();
        // }
        //
        // var dataItems = data.mapIndexed(
        //   (index, arr) => header.asMap().map((i, key) => MapEntry(key, arr ?? 0))
        //     ..addAll({
        //       'start': _start + index * interval,
        //       'end': _start + index * interval + interval,
        //     }),
        // );
        // // print('data: ${data.length}');
        // dataItems = dataItems.where((e) => e['start'] >= start && e['end'] <= end);
        // return dataItems.toList();
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
    Iterable<Iterable> _list = await Future.wait<Iterable>(names.values.map<Future<Iterable>>(_loadBlockData).toList());
    List list = _list.flatten().toList();
    return HttpResponseBean<List>.fromBody(list);
  }

  @override
  Future<List> loadStaticsData({
    String host = '',
    required Track track,
    required String chr,
    required String speciesId,
    int level = 1,
    required int start,
    required int end,
    required int count,
    required Map blockMap,
    CancelToken? cancelToken,
  }) async {
    Future<List> _loadBlockData(Map blockInfo) async {
      num _start = blockInfo['start'];
      num _end = blockInfo['end'];
      int _count = count;
      num _rangeSize = _end - _start;
      if (_rangeSize < blockInfo['blockSize']) {
        _count = (_rangeSize / blockInfo['blockSize'] * count).ceil();
      }
      Map params = {
        'level': level,
        'track_id': track.id,
        'species_id': speciesId,
        'chr_id': chr,
        'block_index': 0,
        'track_type': track.bioType,
        'ref_start': _start.toInt(),
        'ref_end': _end.toInt(),
        'histo_count': _count,
      };
      HttpResponseBean responseBean = await http_util.postJson(
        path: '${host}/api/track/data',
        data: params,
        cache: true,
        cancelToken: cancelToken,
      );
      if (responseBean.success) {
        Map map = responseBean.body;
        List? data = map['data'];
        if ((data?.length ?? 0) == 0) return [];
        List header = map['header'];
        int interval = _rangeSize ~/ data!.length;
        // int responseInterval = data[1][0] - data[0][0];
        //print('interval: $interval, responseInterval:$responseInterval');
        // if (interval != responseInterval) interval = responseInterval;
        // print('interval: $interval');
        logger.d('${track.trackName} => static ${count} _count:$_count <=> data: ${data.length}');
        var dataItems = data.mapIndexed((index, item) {
          Map _map = header.asMap().map((i, key) => MapEntry(key, item is List ? item[i] ?? 0 : item));
          num start = _map['histogram_start'] ?? _map['histo_start'] ?? _map['position'] ?? _start + index * interval; // range.start.ceil() + index * interval;
          return _map
            ..remove('histogram_start')
            ..remove('histo_start')
            ..remove('position')
            ..addAll({
              'start': start,
              'end': start + interval,
            });
        });
        dataItems = dataItems.where((e) => e['start'] >= start && e['end'] <= end);
        return dataItems.toList();
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
    Iterable<List> _list = await Future.wait<List>(names.values.map<Future<List>>(_loadBlockData).toList());
    logger.d(names);
    // logger.d(_list.map((e) => e.length).toList());
    // print(_list);
    return _list.flatten().toList();
  }

  @override
  Future<Feature?> loadFeatureDetail({
    String host = '',
    required String chrId,
    required String chrName,
    required int blockIdx,
    required String trackId,
    required String featureId,
    required String trackType,
    bool refresh = false,
    CancelToken? cancelToken,
  }) async {
    Map params = {
      'block_index': blockIdx,
      'track_id': trackId,
      'track_type': trackType,
      'feature_id': featureId,
      'chr_id': chrId,
      'chr_name': chrName,
    };
    HttpResponseBean responseBean = await http_util.postJson(
      path: '${host}/api/track/feature_detail/compress',
      data: params,
      cache: false,
      cancelToken: cancelToken,
    );
    if (responseBean.success) {
      Map data = responseBean.body is String ? json.decode(responseBean.body) : responseBean.body;
      if (!data.containsKey('data') || !data.containsKey('header')) {
        return Feature.fromMap(data, trackType, 'detail');
      }
      List? list = data['data'];
      // print(json.encode(data));
      if (list == null || list.isEmpty) return null;
      List meta = data['header'];
      var adapter = BaseFeatureAdapter()..header = meta;
      FeatureMetaHeaderManager()[trackType]!['detail'] = meta;
      // if (meta.length > list.length) meta.removeAt(0);

      if (trackType == 'eqtl') {
        var feature = Feature.fromMap({'children': list.map((e) => adapter.itemToMap(e, meta)).toList()}, 'eqtl');
        return feature;
      }

      var map = adapter.itemToMap(list, meta);
      if (map == null) return null;
      return RangeFeature.fromMap(map, trackType, 'detail');
    }
    return null;
  }

  @override
  Future<HttpResponseBean<List>> loadHicData({
    String host = '',
    required String speciesId,
    required Track track,
    required String chr1,
    required String chr2,
    required num resolution,
    required String normalize,
    Map<int, Map>? blockMap,
    required int idxStart,
    required int idxEnd,
    required int idxStart2,
    required int idxEnd2,
    CancelToken? cancelToken,
  }) async {
    Future<HttpResponseBean<List>> _loadBlockData(Map blockInfo) async {
      Map params = {
        'species_id': speciesId,
        'track_id': track.id,
        'track_type': track.bioType,
        'chr1_id': chr1,
        'chr2_id': chr2,
        'normalize': normalize,
        'bin_level': resolution.toInt(),
        'chr1_bin_start': blockInfo['idxStart'],
        'chr1_bin_end': blockInfo['idxEnd'],
        'chr2_bin_start': blockInfo['idxStart2'],
        'chr2_bin_end': blockInfo['idxEnd2'],
        // 'chr1_bin_start': idxStart, // blockInfo['idxStart'],
        // 'chr1_bin_end': idxEnd, //blockInfo['idxEnd'],
        // 'chr2_bin_start': idxStart2, //blockInfo['idxStart'],
        // 'chr2_bin_end': idxEnd2, //blockInfo['idxEnd'],
      };
      HttpResponseBean responseBean = await http_util.postJson(
        path: '${host}/api/track/data',
        data: params,
        cache: true,
        cancelToken: cancelToken,
      );

      if (!responseBean.success) {
        return HttpResponseBean<List>.fromError(responseBean.error!);
      }
      // print(responseBean.body);
      Map body = responseBean.body;
      if (body['error'] != null) {
        return HttpResponseBean<List>.error(ArgumentError(body['error']));
      }

      List bin1 = body['chr1_bin_list'];
      List bin2 = body['chr2_bin_list'];
      List values = body['value_list'];
      List list = bin1.mapIndexed<List>((index, e) => [e, bin2[index], values[index]]).toList();
      return HttpResponseBean.fromBody(list);
    }

    return await _loadBlockData({
      'idxStart': idxStart,
      'idxEnd': idxEnd,
      'idxStart2': idxStart2,
      'idxEnd2': idxEnd2,
    });

    // List<Map> includeBlocks = (blockMap ?? {}).values.where((e) {
    //   return (idxStart >= e['idxStart'] && idxStart <= e['idxEnd']) || //
    //       (idxEnd >= e['idxStart'] && idxEnd <= e['idxEnd']);
    // }).toList();
    // logger.d(includeBlocks);
    //
    // if (blockMap == null) {
    //   includeBlocks = [
    //     {
    //       'idxStart': idxStart,
    //       'idxEnd': idxEnd,
    //       'idxStart2': idxStart2,
    //       'idxEnd2': idxEnd2,
    //     }
    //   ];
    // }
    // Iterable<List> _list = await Future.wait<List>(includeBlocks.map<Future<List>>(_loadBlockData).toList());
    // return _list.where((element) => element != null).flatten().toList();
  }

  @override
  Future<HttpResponseBean<List>> loadInteractiveData({
    String host = '',
    required String speciesId,
    required Track track,
    required String chr1,
    required String chr2,
    required int idxStart,
    required int idxEnd,
    required int idxStart2,
    required int idxEnd2,
    CancelToken? cancelToken,
  }) async {
    Map params = {
      'species_id': speciesId,
      'track_id': track.id,
      'track_type': track.bioType,
      'chr1_id': chr1,
      'chr2_id': chr2,
      'chr1_start': idxStart,
      'chr1_end': idxEnd,
      'chr2_start': idxStart2,
      'chr2_end': idxEnd2,
    };
    HttpResponseBean responseBean = await http_util.postJson(
      path: '${host}/api/track/data',
      data: params,
      cache: true,
      cancelToken: cancelToken,
    );
    if (!responseBean.success) {
      return HttpResponseBean<List>.error(responseBean.error);
    }
    Map body = responseBean.body;
    List data = body['data'];
    // print(data);
    return HttpResponseBean<List>.fromBody(data);
  }

  Future<Map> loadGlobalInteractiveData({
    String host = '',
    required String speciesId,
    required Track track,
    required String chr,
    CancelToken? cancelToken,
  }) async {
    Map params = {
      'species_id': speciesId,
      'track_id': track.id,
      'track_type': track.bioType,
      'chr_id': chr,
    };
    HttpResponseBean responseBean = await http_util.postJson(
      path: '${host}/api/track/interactive_circle',
      data: params,
      cache: true,
      cancelToken: cancelToken,
    );
    if (!responseBean.success) {
      return {};
    }
    Map body = responseBean.body;
    return body['data'];
  }

  static Future<HttpResponseBean> searchGene({
    String host = '',
    required String speciesId,
    required String keyword,
    required int count,
    CancelToken? cancelToken,
  }) async {
    Map params = {
      'species_id': speciesId,
      'gene_id': keyword,
      'result_count': count,
    };
    HttpResponseBean responseBean = await http_util.postJson(
      path: '${host}/api/search/gene',
      data: params,
      cache: false,
      cancelToken: cancelToken,
    );
    return responseBean;
  }

  /// search in track
  static Future<HttpResponseBean> searchTrackFeature({
    String host = '',
    required String speciesId,
    required String chrId,
    required String trackId,
    required String keyword,
    required int page,
    required int count,
    CancelToken? cancelToken,
  }) async {
    Map params = {
      'species_id': speciesId,
      'track_id': trackId,
      'chr_id': chrId,
      'keyword': keyword,
      'page_num': page,
      'page_size': count,
    };
    HttpResponseBean responseBean = await http_util.postJson(
      path: '${host}/api/search/track/feature',
      data: params,
      cache: false,
      cancelToken: cancelToken,
    );
    return responseBean;
  }

  Future<HttpResponseBean<List<Feature>>> searchSnpByFeature({
    String host = '',
    required String speciesId,
    required Track track,
    required String feature,
    CancelToken? cancelToken,
  }) async {
    HttpResponseBean responseBean = await http_util.postJson(
      path: '${host}/api/sc/eqtl/snp',
      data: {
        'species_id': speciesId,
        'track_id': track.id,
        'feature_name': feature,
      },
      cache: false,
      cancelToken: cancelToken,
    );
    if (!responseBean.success) return HttpResponseBean<List<Feature>>.fromError(responseBean.error!);

    Map map = responseBean.body;
    DataAdapter<Feature> eqtlAdapter = EQTLFeatureAdapter(track: track, level: 3);
    List header = map['header'];
    eqtlAdapter.header = header;
    List<Feature> features = eqtlAdapter.parseFeatureData(map['data']).toList();
    return HttpResponseBean<List<Feature>>.fromBody(features);
  }

  @override
  Future<HttpResponseBean> loadTrackTableData({
    String host = '',
    required String speciesId,
    required Track track,
    required String chrId,
    required int start,
    required int end,
    required int page,
    required int pageSize,
    List? filters,
    CancelToken? cancelToken,
  }) async {
    Map params = {
      'species_id': speciesId,
      'track_id': track.id,
      'track_type': track.bioType,
      'chr_id': chrId,
      'start': start,
      'end': end,
      'filters': filters ?? [],
      'page_num': page,
      'page_size': pageSize,
    };
    return http_util.postJson(
      // path: '${host}/api/track/table',
      path: '${host}/api/track/vcf/filter_track_table',
      data: params,
      cache: true,
      cancelToken: cancelToken,
    );
  }
}
