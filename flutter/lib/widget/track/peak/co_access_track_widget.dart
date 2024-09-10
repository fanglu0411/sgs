import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:flutter_smart_genome/bloc/track_config/bloc.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/mixin/track_data_mixin.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/service/beans.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/base/zoom_see_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:dartx/dartx.dart' as cm;
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';
import 'package:flutter_smart_genome/widget/track/peak/peak_pair_track_data.dart';
import 'package:flutter_smart_genome/widget/track/peak/peak_pair_track_painter.dart';

class CoAccessTrackWidget extends BaseTrackWidget {
  CoAccessTrackWidget({
    super.key,
    required super.site,
    required super.scale,
    required super.trackParams,
    required super.range,
    super.background,
    super.orientation,
    super.onZoomToRange,
    super.onRemoveTrack,
    super.gestureBuilder,
    super.eventCallback,
    super.touchScaling,
    super.touchScale,
    super.fixTitle,
    double? maxHeight,
  }) : super(
          containerHeight: maxHeight,
        );

  @override
  State<CoAccessTrackWidget> createState() => _PeakTrackWidgetState();
}

class _PeakTrackWidgetState extends State<CoAccessTrackWidget> with TrackDataMixin {
  List<PeakPair>? _data;
  bool _coAccessibility = true;
  bool _drawDown = true;

  @override
  void didUpdateWidget(CoAccessTrackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    hoverDelay = 0;
    trackTotalHeight = 0;
    super.initState();
  }

  @override
  void init(TrackParams trackParams) {
    // super.init(trackParams);
    var brothers = trackParams.track.parent?.children ?? [];
    var trackIndex = brothers.indexWhere((t) => t.id == trackParams.trackId);
    var peakIndex = brothers.indexWhere((t) => t.trackType == TrackType.peak);
    _drawDown = trackIndex > peakIndex;
  }

  @override
  void initVisibleScale(TrackParams trackParams) {
    //do nothing
    blockVisibleScale = 0.001;
  }

  @override
  TrackViewType getTrackViewType([TrackParams? params]) {
    num targetScale = findTargetScale(params ?? widget.trackParams);
    if (targetScale >= blockVisibleScale) {
      return TrackViewType.feature;
    }
    return TrackViewType.cartesian;
  }

  @override
  Future loadTrackData([bool isRefresh = false]) async {
    TrackViewType _viewType = getTrackViewType();
    if (_viewType == TrackViewType.cartesian) {
      setState(() {
        trackData = [];
        trackTotalHeight = 0;
        viewType = _viewType;
      });
    } else {
      return super.loadTrackData(isRefresh);
    }
  }

  @override
  Future<HttpResponseBean<List>> dataApi(CancelToken cancelToken, TrackViewType _viewType, Set<String> _featureTypes) async {
    return loadPeakPairs(
      host: widget.site.url,
      // scale: trackParams.rangePerPixel,
      range: widget.range,
      species: trackParams.speciesId,
      track: trackParams.track,
      chrId: trackParams.chrId,
      // level: getDataLevel(_viewType),
      cancelToken: cancelToken,
    );
  }

  int getDataLevel(TrackViewType viewType) {
    return viewType.index + 1;
  }

  @override
  List<SettingItem> getContextMenuList(hitItem) {
    return TrackMenuConfig.coAccessTrackSettings;
  }

  @override
  void registerContextMenuSettings(List<SettingItem> settings) {
    super.registerContextMenuSettings(settings);
    SettingItem? pairedItem = settings.firstOrNullWhere((element) => element.key == TrackContextMenuKey.peak_co_access);
    pairedItem?.value = _coAccessibility;
  }

  @override
  Widget? buildTrackTitle() {
    return super.buildTrackTitle();
    // if (_drawDown) return null;
    // return Divider(height: 2);
  }

  @override
  List<Widget> buildTitleActions() {
    // return super.buildTitleActions();
    return [];
  }

  // @override
  // Future<bool> checkNeedReloadData(CoAccessTrackWidget oldWidget) async {
  //   return super.checkNeedReloadData(oldWidget);
  // }

  Range get inflateRange => widget.range.inflate(widget.range.size * .1);

  PeakPairTrackData _featureData = PeakPairTrackData(features: []);

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
    // print('range track view type $viewType ${widget.orientation} scale: ${widget.trackParams.pixelOfSeq}, _featureVisibleScale: $_featureVisibleScale');
    Brightness _brightness = Theme.of(context).brightness;
    Color _primaryColor = Theme.of(context).primaryColor;
    bool _dark = _brightness == Brightness.dark;
    if (viewType == TrackViewType.cartesian) {
      return ZoomSeeTrackPainter(
        scale: widget.scale,
        visibleRange: widget.range,
        orientation: Axis.horizontal,
        message: 'zoom in to view co-access',
        style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 14, fontWeight: FontWeight.w300),
      );
    }
    if (dataRangeChanged || _data == null || _data!.length == 0) {
      // _data = transformData<PeakPair>(trackData);
    }
    _featureData.features = trackData as List<PeakPair> ?? [];
    _featureData
      ..customMin = customTrackStyle.customMinValue.enableValueOrNull
      ..customMax = customTrackStyle.customMaxValue.enableValueOrNull;
//    logger.d('get painter ${dataRangeChanged} ${selectedItem?.hashCode}');
    return PeakPairTrackPainter(
      orientation: widget.orientation,
      visibleRange: widget.range,
      trackHeight: trackStyle.trackHeight ?? 100,
      trackData: _featureData,
      styleConfig: FeatureStyleConfig(
        padding: EdgeInsets.symmetric(vertical: 4),
        backgroundColor: widget.background ?? Colors.grey[200],
        blockBgColor: trackStyle.featureGroupColor ?? Colors.green,
        showLabel: trackStyle.showLabel,
        labelFontSize: trackStyle.fontSize,
        textColor: trackStyle.fontColor,
        groupColor: trackStyle.featureGroupColor,
        featureWidth: .5,
        featureStyles: {},
        lineColor: trackStyle.trackColor,
        brightness: _brightness,
        selectedColor: _primaryColor,
        primaryColor: _primaryColor,
      ),
      scale: widget.scale,
      track: trackParams.track..paired = _coAccessibility,
      showSubFeature: trackParams.pixelPerBp >= .5,
      // size of pixel < 1000
      selectedItem: selectedItem,
      drawDown: _drawDown,
      // paired: _coAccessibility,
    );
  }

  @override
  bool onContextMenuItemChanged(SettingItem? p, SettingItem item) {
    //super.onContextMenuItemChanged(item);
    if (item.key == TrackContextMenuKey.peak_co_access) {
      _coAccessibility = item.value;
      // TrackLayoutManager.clear(trackParams.track);
      // trackTotalHeight = 0;
      // setState(() {});
      SgsAppService.get()!.sendEvent(ToggleTrackSelectionEvent(trackParams.track, _coAccessibility));
    } //
    else {
      super.onContextMenuItemChanged(p, item);
    }
    return true;
  }

  @override
  void onItemTap(item, Offset offset) {
    // super.onItemTap(item, offset);
    // showSimpleFeatureInfo(item, offset);
  }

  @override
  bool get showCartesianToolTip => true;

  @override
  void dispose() {
    super.dispose();
    _data?.clear();
    _data = null;
    _featureData.clear();
  }
}
