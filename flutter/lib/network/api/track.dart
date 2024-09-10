import 'dart:convert';
import 'dart:math' as math;
import 'package:dio/dio.dart';
// import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter_smart_genome/network/api/simple_request.dart';
import 'package:flutter_smart_genome/network/dio_helper.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/widget/track/digest/crc32.dart';

Future<HttpResponseBean> addTrack({String host = '', required Map params}) async {
  return postJson(path: '${host}/api/track/add', data: params);
}

Future<HttpResponseBean> getTrackList({String host = '', required String species, bool refresh = false}) async {
  return postJson(
    path: '${host}/api/track/list',
    data: {'species_id': species},
    cache: true,
    forceRefresh: refresh,
  );
}

Future<HttpResponseBean> deleteTrack({String host = '',required String trackId}) async {
  return postJson(
    path: '${host}/api/track/delete',
    data: {'track_id': trackId},
    cache: false,
  );
}

Future<HttpResponseBean> getJbrowseTrackList({required String species}) async {
  try {
    Response<String> response = await DioHelper().dio.get(
          '${DioHelper.browserBaseUrl}/$species/trackList.json?v=0.46962652825231954',
          options: buildCacheOptions(duration: Duration(days: 7)),
        );
    return HttpResponseBean.fromDio(response);
  } catch (e) {
    return HttpResponseBean.error(e);
  }
}

/// track 配置文件
Future<HttpResponseBean> getTrackDataConfig({String host = '', required String trackName, required String chr, required String species}) async {
  return postJson(
    path: '$host/api/track/fragment/location',
    cache: true,
    data: {
      "track_id": trackName,
      "chr_id": chr,
    },
  );
}

Future<HttpResponseBean> getJbrowseTrackDataConfig({required String trackName, required String chr, required String species}) async {
  try {
    Response<String> response = await DioHelper().dio.get(
          '${DioHelper.browserBaseUrl}/$species/tracks/$trackName/$chr/trackData.json',
          options: buildCacheOptions(duration: Duration(days: 7)),
        );
    return HttpResponseBean.fromDio(response);
  } catch (e) {
    return HttpResponseBean.error(e);
  }
//  if (null != response.data) {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    prefs.setString('track-config-$species-$chr-$trackName', json.encode(response.data));
//  }
//  return response.data;
}

Future<HttpResponseBean> getChromosomeList({String host = '', required String speciesId}) async {
  return postJson(path: '$host/api/species/chromosomes', data: {
    'species_id': speciesId,
  });
}

Future<HttpResponseBean> getJBrowseChromosomeList({required String species}) async {
  try {
    Response<String> response = await DioHelper().dio.get(
          '${DioHelper.browserBaseUrl}/$species/seq/refSeqs.json',
          options: buildCacheOptions(duration: Duration(days: 7)),
        );
    return HttpResponseBean.fromDio(response);
  } catch (e) {
    return HttpResponseBean.error(e);
  }

//  List chrList = response.data;
//  return chrList.map<ChromosomeData>((e) => ChromosomeData.fromMap(e)).toList();
}

Future<HttpResponseBean> getTrackFile({required String host,required  String fileName, required String trackName, required String chr, required String species, int? level}) async {
  return postJson(
    cache: true,
    path: '${host}/api/track/data',
    data: {
      'species_id': species,
      'user_id': 'test001',
      'track_id': trackName,
      'chr_id': chr,
      'block_index': fileName,
      'level': level,
    },
  );
}

Future<HttpResponseBean> getJbrowseTrackFile({required String fileName, required String trackName, required String chr, required String species}) async {
  try {
    Response<String> response = await DioHelper().dio.get(
          '${DioHelper.browserBaseUrl}/$species/tracks/$trackName/$chr/$fileName.json',
          options: buildCacheOptions(duration: Duration(days: 7)),
        );
    return HttpResponseBean.fromDio(response);
  } catch (e) {
    return HttpResponseBean.error(e);
  }
//  return response.data;
}

Future<HttpResponseBean> loadCustomTrackData({
  required String url,
  required String species,
  required String userId,
  required String trackId,
  required int fragment,
  required int level,
}) async {
  try {
    Response<String> response = await DioHelper().dio.post(
          '${url}',
          options: buildCacheOptions(duration: Duration(days: 7)),
          data: json.encode({
            "species_id": species,
            "user_id": userId,
            "track_id": trackId,
            "fragment_number": fragment,
            "level": level,
          }),
        );
    return HttpResponseBean.fromDio(response);
  } catch (e) {
    return HttpResponseBean.error(e);
  }
}

Future<HttpResponseBean> loadSgsSequenceFile({
  required String host,
  required String fileName,
  required String trackName,
  required String chr,
  required String species,
  bool refresh = false,
}) async {
  return postJson(
    path: '${host}/api/chromosome/block/sequence',
    data: {'species_id': species, 'chr_name': chr, 'block_index': fileName},
    cache: true,
    forceRefresh: refresh,
  );

//  return response.data;
}

Future<HttpResponseBean> getJBrowseSequenceFile({required String fileName, required String trackName, required String chr, required String species}) async {
  try {
    var refseq_dirpath = refSeqDirPath(chr);
    Response<String> response = await DioHelper().dio.get(
          '${DioHelper.browserBaseUrl}/$species/seq/${refseq_dirpath}/$fileName.txt',
          options: buildCacheOptions(duration: Duration(days: 7)),
        );
    return HttpResponseBean.fromDio(response);
  } catch (e) {
    return HttpResponseBean.error(e);
  }

//  return response.data;
}

String refSeqDirPath(String chr) {
  String hex = Crc32.crc32(chr).toRadixString(16).toLowerCase().replaceAll('-', 'n');
  while (hex.length < 8) hex = '0' + hex;
  var dirPath = [];
  for (var i = 0; i < hex.length; i += 3) {
    dirPath.add(hex.substring(i, math.min(i + 3, hex.length)));
  }
  return dirPath.join('/');
}