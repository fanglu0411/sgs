import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/components/range_info_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:flutter_smart_genome/widget/track/vcf_sample/sample_detail_widgets.dart';
import 'package:get/get.dart';
// import 'package:velocity_x/velocity_x.dart';

class FeatureDetailViewState {
  final Feature feature;
  final Track track;
  final ChromosomeData chr;
  final String speciesId;
  final String? rootFeatureId;

  FeatureDetailViewState(this.feature, this.rootFeatureId, this.track, this.chr, this.speciesId);

  @override
  List<Object> get props => [feature];
}

class FeatureDetailLogic extends GetxController {
  static FeatureDetailLogic? safe() {
    if (Get.isRegistered<FeatureDetailLogic>()) {
      return Get.find<FeatureDetailLogic>();
    }
    return null;
  }

  FeatureDetailViewState? _detailState;

  FeatureDetailViewState? get detailState => _detailState;

  setDetail(FeatureDetailViewState state) {
    _detailState = state;
    update();
  }
}

class FeatureDetailSide extends StatefulWidget {
  final FeatureDetailViewState? detailState;

  const FeatureDetailSide({Key? key, this.detailState}) : super(key: key);

  @override
  _FeatureDetailSideState createState() => _FeatureDetailSideState();
}

class _FeatureDetailSideState extends State<FeatureDetailSide> {
  FeatureDetailLogic? logic;

  @override
  void initState() {
    super.initState();
    logic = FeatureDetailLogic.safe();
    if (logic == null) {
      logic = Get.put(FeatureDetailLogic());
    }
    if (widget.detailState != null)
      Future.delayed(Duration(microseconds: 200)).then((c) {
        logic!.setDetail(widget.detailState!);
      });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeatureDetailLogic>(
      init: logic,
      autoRemove: false,
      builder: (logic) => builder(context, logic),
    );
  }

  Widget builder(BuildContext context, FeatureDetailLogic logic) {
    var state = logic.detailState;
    if (state == null) {
      return Container();
    }
    Feature feature = state.feature;
    if (state.track.isVcfSample || state.track.isVcfCoverage) {
      // VcfSampleFeatureLayout layout = TrackLayoutManager().getTrackLayout(state.track);
      return SampleDetailWidget(
        feature: feature,
        // samples: layout.sampleList,
        // variantMap: layout.typeCodeMap,
        track: state.track,
        chr: state.chr,
      );
    }

    return RangeInfoWidget(
      key: Key('${feature.hashCode}'),
      feature: feature,
      rootFeatureId: state.rootFeatureId,
      chr: state.chr,
      species: state.speciesId,
      track: state.track,
      asPage: false,
    );
  }
}