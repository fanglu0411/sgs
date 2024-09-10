import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/sgs_service_delegate.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

class EqtlTrackLogic extends GetxController {
  static EqtlTrackLogic? safe(String tag) {
    if (Get.isRegistered<EqtlTrackLogic>(tag: tag)) {
      return Get.find<EqtlTrackLogic>(tag: tag);
    }
    return null;
  }

  static notifyTargetGene(String gene) {
    var tacks = SgsAppService.get()!.selectedTracks.where((e) => e.trackType == TrackType.eqtl);
    for (var track in tacks) {
      EqtlTrackLogic.safe(track.id!)?.searchSnpByFeature(gene);
    }
  }

  Track track;

  EqtlTrackLogic(this.track) {}

  Map<String, List<Feature>> searchedFeatureSnp = {};

  String? feature;

  List<Feature> get featureSnpList => feature == null ? [] : searchedFeatureSnp[feature] ?? [];

  void clearFeature() {
    feature = null;
    searchedFeatureSnp.clear();
    update();
  }

  @override
  void onInit() {
    super.onInit();
  }

  Future searchSnpByFeature(String feature) async {
    var site = SgsAppService.get()!.site!;
    this.feature = feature;
    var resp = await SgsServiceDelegate().searchSnpByFeature(host: site.url, speciesId: site.currentSpeciesId!, track: track, feature: feature);
    if (resp.success) {
      searchedFeatureSnp[feature] = resp.body!;
      update();
    }
  }
}
