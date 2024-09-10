import 'package:dio/dio.dart' show CancelToken;
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/network/adapter/data_adapter.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/service/beans.dart';
import 'package:flutter_smart_genome/service/jbrowse_service_delegate.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/sgs_service_delegate.dart';

import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

abstract class AbsPlatformService {
  static AbsPlatformService? get([SiteItem? site]) {
    SiteSource siteSource = (site ?? SgsAppService.get()!.site)?.source ?? SiteSource.sgs;
    switch (siteSource) {
      case SiteSource.sgs:
        return SgsServiceDelegate();
      case SiteSource.jbrowse:
        return JBrowseServiceDelegate();
      // case SiteSource.locale:
      //   return LocaleServiceDelegate();
      default:
        return SgsServiceDelegate();
    }
  }

  Future<HttpResponseBean> createSpecies({String host = '', required Map body, Map? header});

  Future<HttpResponseBean<List<Species>>> loadSpeciesList({
    String host = '',
    Map body = const {},
    bool forceRefresh = false,
    CancelToken? cancelToken,
  });

  Future<HttpResponseBean> deleteSpecies({String host = '', dynamic id});

  Future<HttpResponseBean> getSpeciesIntro({String host = '', dynamic id});

  Future<HttpResponseBean> updateSpeciesIntro({String host = '', dynamic id, String? speciesName, required String content});

  ///
  /// admin add track
  ///
  Future<HttpResponseBean> addTrack({required String host, required Map params});

  ///
  /// admin add tracks
  ///
  Future<HttpResponseBean> addTracks({required String host, required Map params});

  ///
  /// admin delete track
  ///
  Future<HttpResponseBean> deleteTrack({required String host, required dynamic trackId});

  ///
  /// track block map
  ///
  Future<Map> loadTrackConfig({
    String host = '',
    required Track track,
    required String chr,
    required String species,
  });

  ///
  /// load feature detail
  ///
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
  });

  ///
  /// load chromosome list
  ///
  Future<List<ChromosomeData>> loadChromosomes({
    String host = '',
    required String speciesId,
    bool refresh = false,
    CancelToken? cancelToken,
  });

  ///
  /// track data
  ///
  Future<HttpResponseBean<List>> loadTrackData({
    required String host,
    required Range range,
    required double scale,
    required Track track,
    required String chr,
    required String species,
    int level = 1,
    Set<String>? featureTypes,
    CancelToken? cancelToken,
    required DataAdapter adapter,
  });

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
    required Map blockMap,
    required String valueType,
    CancelToken? cancelToken,
    required DataAdapter adapter,
  });

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
  });

  ///
  /// track list
  ///
  Future<HttpResponseBean<List<Track>>> loadTrackList({required String host, required String species, bool refresh = false});

  ///
  /// all track list include single cell
  Future<HttpResponseBean<List<Track>>> loadAllTrackList({
    String host = '',
    required String species,
    bool refresh = false,
    CancelToken? cancelToken,
  });

  Future<Map<String, Range>> findFileNameInRage({
    String host = '',
    required Range range,
    required Track track,
    required String species,
    required String chr,
    int level,
    bool inflate = true,
  });

  ///
  /// ref sequence
  ///
  Future<RangeSequence> loadSequence({
    String host = '',
    required Range range,
    double? scale,
    Track? track,
    required String chr,
    required String species,
    int? blockLength,
  });

  ///
  /// find sequence files by range
  ///
  MapEntry<Range, List<Range>> findSequenceFilesInRange({
    String host = '',
    required Range range,
    int fileSequenceLength,
    required String chr,
  });

  Future<HttpResponseBean<List>> loadHicData({
    String host = '',
    required String speciesId,
    required Track track,
    required String chr1,
    required String chr2,
    required String normalize,
    required num resolution,
    Map<int, Map>? blockMap,
    required int idxStart,
    required int idxEnd,
    required int idxStart2,
    required int idxEnd2,
    CancelToken? cancelToken,
  });

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
  });

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
  });
}
