import 'dart:convert';
import 'dart:math' show min;

import 'package:dio/dio.dart' show CancelToken;
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/network/adapter/data_adapter.dart';
import 'package:flutter_smart_genome/network/api/simple_request.dart' as http_util;
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/service/beans.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/digest/crc32.dart';

class JBrowseServiceDelegate extends AbsPlatformService {
  static JBrowseServiceDelegate _instance = JBrowseServiceDelegate._init();

  JBrowseServiceDelegate._init() {}

  factory JBrowseServiceDelegate() => _instance;

  @override
  Future<Map<String, Range>> findFileNameInRage({
    String host = '',
    required Range range,
    required Track track,
    required String species,
    required String chr,
    int? level,
    bool inflate = true,
  }) async {
    Map<String, Range> names = {};

    HttpResponseBean bean = await http_util.get(
      path: '/$species/tracks/${track.trackName}/$chr/trackData.json',
      cache: true,
    );

    if (!bean.success) return {};

    Map trackConfigData = await loadTrackConfig(host: host, track: track, chr: chr, species: species);
    print(trackConfigData);

    Range _inflateRange = inflate ? range.inflate(range.size * .5) : range;

    Range ncRange;
    Range? intersection;

    Map intervals = trackConfigData['intervals'];
    List nclist = intervals['nclist'];
    for (List nc in nclist) {
      ncRange = Range(start: nc[0], end: nc[1]);
      intersection = _inflateRange.intersection(ncRange);
      if (intersection != null) {
        names['lf-${nc[3]}'] = intersection;
      }
    }
    logger.d('$track range: $range, _inflateRange:$_inflateRange, files: $names');
    return names;
  }

  @override
  Future<List<ChromosomeData>> loadChromosomes({
    required String speciesId,
    String host = '',
    String? species,
    bool refresh = false,
    CancelToken? cancelToken,
  }) async {
    var chromosomeListStr;
    HttpResponseBean responseBean = await http_util.get(
      path: '${host}/$species/seq/refSeqs.json',
      cache: true,
    );
    if (responseBean.success) {
      chromosomeListStr = responseBean.bodyStr;
    }
    if (null == chromosomeListStr) return [];

    List chrList = json.decode(chromosomeListStr);
    List<ChromosomeData> chromosomes = chrList.map<ChromosomeData>((e) => ChromosomeData.fromMap(e)).toList();
    return chromosomes;
  }

  @override
  Future<RangeSequence> loadSequence({
    String host = '',
    required Range range,
    double? scale,
    Track? track,
    required String chr,
    required String species,
    int? blockLength = 20000,
  }) async {
    var refseq_dirpath = refSeqDirPath(chr);
    Future<String> _loadSequenceFile(Range range) async {
      String content = '';
      HttpResponseBean responseBean = await http_util.get(
        path: '/$species/seq/${refseq_dirpath}/${range.start}.txt',
        cache: true,
      );
      if (responseBean.success) {
        content = responseBean.bodyStr ?? '';
      }
      return content;
    }

    MapEntry<Range, List<Range>> filesEntry = findSequenceFilesInRange(
      host: host,
      range: range,
      fileSequenceLength: blockLength, //20000,
      chr: chr,
    );
    Range seqRange = filesEntry.key;
    List<String> sequences = await Future.wait<String>(filesEntry.value.map<Future<String>>(_loadSequenceFile));
    return RangeSequence(seqRange, sequences.join(''));
  }

  @override
  MapEntry<Range, List<Range>> findSequenceFilesInRange({
    String host = '',
    required Range range,
    int? fileSequenceLength = 20000,
    required String chr,
  }) {
    fileSequenceLength ??= 20000;
    var delta = range.start % fileSequenceLength;
    int start = (range.start / fileSequenceLength).ceil() - 1;
    int end = (range.end / fileSequenceLength).ceil() - 1;

    int blockStart = (range.start ~/ fileSequenceLength);
    int blockEnd = (range.end ~/ fileSequenceLength);

    List<Range> blocks = [];
    for (int block = blockStart; block < blockEnd; block++) {
      blocks.add(Range(start: block * fileSequenceLength, end: block * fileSequenceLength + fileSequenceLength));
    }
    return MapEntry<Range, List<Range>>(Range(start: blocks.first.start, end: blocks.last.end), blocks);
  }

  @override
  Future<Map> loadTrackConfig({
    String host = '',
    required Track track,
    required String chr,
    required String species,
  }) async {
    HttpResponseBean responseBean = await http_util.get(
      path: '${host}/$species/tracks/${track.trackName}/$chr/trackData.json',
      cache: true,
    );
    return responseBean.body;
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
    DataAdapter? adapter,
  }) async {
    Future<String?> loadTrackFile(String fileName) async {
      String? content;
      HttpResponseBean responseBean = await http_util.get(
        path: '/$species/tracks/${track.trackName}/$chr/$fileName.json',
        cache: true,
      );
      if (responseBean.success) {
        content = responseBean.bodyStr;
      }
      return content;
    }

    List trackDataList = [];

    //找到这个区间对应的文件，如果跨区间，则要找到夸区间的所有文件
    Map<String, Range> nameList = await findFileNameInRage(host: host, range: range, track: track, species: species, chr: chr, level: level);
//    print(nameList);

    if (scale >= 200000) {
      String? content = await loadTrackFile('hist-200000-0');
      if (content != null) {
        trackDataList = json.decode(content);
      }
    } else if (scale >= 100000) {
      String? content = await loadTrackFile('hist-100000-0');
      if (content != null) {
        trackDataList = json.decode(content);
      }
    } else {
      List<String?> _list = await Future.wait<String?>(nameList.keys.map<Future<String?>>(loadTrackFile).toList());
      _list.forEach((content) {
        if (content != null) {
          List list = json.decode(content);
          trackDataList.addAll(list);
        }
      });
      //todo more file need filter
    }

    return HttpResponseBean.fromBody(trackDataList);
  }

  @override
  Future<HttpResponseBean<List<Track>>> loadTrackList({String host = '', required String species, bool refresh = false}) async {
    HttpResponseBean responseBean = await http_util.get(
      path: '$host/$species/trackList.json?v=0.46962652825231954',
      cache: true,
      forceRefresh: refresh,
    );
    Map trackMap;
    if (!responseBean.success) {
      return HttpResponseBean.fromError(responseBean.error!);
    }
    trackMap = responseBean.body;
    List trackList = trackMap['tracks'];
    var tracks = trackList.map<Track>((e) => Track.fromMap(e)).toList();
    return HttpResponseBean.fromBody(tracks);
  }

  String refSeqDirPath(String chr) {
    String hex = Crc32.crc32(chr).toRadixString(16).toLowerCase().replaceAll('-', 'n');
    while (hex.length < 8) hex = '0' + hex;
    var dirPath = [];
    for (var i = 0; i < hex.length; i += 3) {
      dirPath.add(hex.substring(i, min(i + 3, hex.length)));
    }
    return dirPath.join('/');
  }

  @override
  Future<HttpResponseBean> createSpecies({String host = '', required Map body, Map? header}) {
    throw UnimplementedError();
  }

  @override
  Future<HttpResponseBean> deleteSpecies({String host = '', dynamic id}) {
    throw UnimplementedError();
  }

  @override
  Future<HttpResponseBean<List<Species>>> loadSpeciesList({
    String host = '',
    Map? body,
    bool forceRefresh = false,
    CancelToken? cancelToken,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<HttpResponseBean> addTrack({String host = '', required Map params}) {
    throw UnimplementedError();
  }

  @override
  Future<HttpResponseBean> deleteTrack({String host = '', dynamic trackId}) {
    throw UnimplementedError();
  }

  @override
  Future<HttpResponseBean<List>> loadBigwigData({
    required String host,
    required String speciesId,
    required Track track,
    required String chr,
    int level = 1,
    required int start,
    required int end,
    required int binSize,
    required int count,
    Map? blockMap,
    required String valueType,
    CancelToken? cancelToken,
    required DataAdapter adapter,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List> loadStaticsData({
    String host = '',
    required String speciesId,
    required Track track,
    required String chr,
    int level = 1,
    required int start,
    required int end,
    required int count,
    required Map blockMap,
    CancelToken? cancelToken,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Feature> loadFeatureDetail({
    String host = '',
    required String trackId,
    required String chrId,
    required int blockIdx,
    required String featureId,
    String? chrName,
    required String trackType,
    bool refresh = false,
    CancelToken? cancelToken,
  }) {
    // TODO: implement loadFeatureDetail
    throw UnimplementedError();
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
  }) {
    // TODO: implement loadRelationData
    throw UnimplementedError();
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
    throw UnimplementedError();
  }

  @override
  Future<HttpResponseBean<List<Track>>> loadAllTrackList({
    String host = '',
    required String species,
    bool refresh = false,
    CancelToken? cancelToken,
  }) {
    // TODO: implement loadAllTrackList
    throw UnimplementedError();
  }

  @override
  Future<HttpResponseBean> loadTrackTableData({
    String host = '',
    required String speciesId,
    required String chrId,
    required Track track,
    required int start,
    required int end,
    required int page,
    required int pageSize,
    List<dynamic>? filters,
    CancelToken? cancelToken,
  }) {
    // TODO: implement loadTrackTableData
    throw UnimplementedError();
  }

  @override
  Future<HttpResponseBean> addTracks({String host = '', required Map<dynamic, dynamic> params}) {
    throw UnimplementedError();
  }

  @override
  Future<HttpResponseBean> getSpeciesIntro({String host = '', id}) {
    throw UnimplementedError();
  }

  @override
  Future<HttpResponseBean> updateSpeciesIntro({String host = '', id, String? speciesName, required String content}) {
    throw UnimplementedError();
  }
}
