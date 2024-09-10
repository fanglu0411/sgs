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
import 'package:flutter_smart_genome/widget/track/peak/peak_track_data.dart';

import 'peak_track_painter.dart';

class PeakTrackWidget extends BaseTrackWidget {
  PeakTrackWidget({
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
  State<PeakTrackWidget> createState() => _PeakTrackWidgetState();
}

class _PeakTrackWidgetState extends State<PeakTrackWidget> with TrackDataMixin {
  List<PeakPair>? _data;
  bool _coAccessibility = true;

  @override
  void initState() {
    hoverDelay = 0;
    trackTotalHeight = 0;
    super.initState();
  }

  void init(TrackParams trackParams) {
    super.init(trackParams);
  }

  @override
  void initVisibleScale(TrackParams trackParams) {
    blockVisibleScale = .001;
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
    return loadPeaks(
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
    return [
      if (null != hitItem) TrackMenuConfig.fromKey(TrackContextMenuKey.zoom_to_feature),
      ...TrackMenuConfig.peakTrackSettings,
    ];
  }

  @override
  void registerContextMenuSettings(List<SettingItem> settings) {
    super.registerContextMenuSettings(settings);
    SettingItem? pairedItem = settings.firstOrNullWhere((element) => element.key == TrackContextMenuKey.peak_co_access);
    Track? coTrack = trackParams.track.parent!.children?.firstOrNullWhere((t) => t.isCoAccess);
    pairedItem?.value = coTrack?.checked ?? false;
  }

  @override
  List<Widget> buildTitleActions() {
    return [];
  }

  Range get inflateRange => widget.range.inflate(widget.range.size * .1);

  Map<String, FeatureStyle> get peakFeatureStyle {
    Map<String, Color> _colorMap = trackStyle.colorMap ?? {};
    return {
      ..._colorMap,
      'peak': trackStyle.trackColor,
    }.map<String, FeatureStyle>((key, value) => MapEntry<String, FeatureStyle>(key, FeatureStyle(color: value, name: '', id: '')));
  }

  PeakTrackData _featureData = PeakTrackData(features: []);

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
    // print('range track view type $viewType ${widget.orientation} scale: ${widget.trackParams.pixelOfSeq}, _featureVisibleScale: $_featureVisibleScale');
    Brightness _brightness = Theme.of(context).brightness;
    bool _dark = _brightness == Brightness.dark;

    if (viewType == TrackViewType.cartesian) {
      return ZoomSeeTrackPainter(
        scale: widget.scale,
        visibleRange: widget.range,
        orientation: Axis.horizontal,
        message: 'zoom in to view peaks',
        style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 14, fontWeight: FontWeight.w300),
      );
    }
    if (dataRangeChanged || _data == null || _data!.length == 0) {
      // _data = transformData<PeakPair>(trackData);
    }
    _featureData.features = trackData as List<Peak> ?? [];
//    logger.d('get painter ${dataRangeChanged} ${selectedItem?.hashCode}');
    return PeakTrackPainter(
      orientation: widget.orientation,
      visibleRange: widget.range,
      trackHeight: trackStyle.featureHeight ?? 10,
      trackData: _featureData,
      // collapseMode: trackUIConfigBean.trackMode,
//      maxHeight: bigWigStyle.trackHeight,
      styleConfig: FeatureStyleConfig(
        padding: EdgeInsets.only(top: 5),
        backgroundColor: widget.background ?? Colors.grey[200],
        blockBgColor: trackStyle.trackColor ?? Colors.green,
        showLabel: trackStyle.showLabel,
        labelFontSize: trackStyle.fontSize,
        textColor: trackStyle.fontColor,
        groupColor: trackStyle.featureGroupColor,
        featureWidth: .5,
        featureStyles: peakFeatureStyle,
        lineColor: _dark ? Colors.grey[500] : Colors.black26.withAlpha(50),
        brightness: _brightness,
        selectedColor: _dark ? Colors.white : Theme.of(context).colorScheme.primary,
      ),
      scale: widget.scale,
      track: trackParams.track..paired = _coAccessibility,
      showSubFeature: trackParams.pixelPerBp >= .5,
      // size of pixel < 1000
      selectedItem: selectedItem,
      paired: _coAccessibility,
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
      var coTrack = trackParams.track.parent!.children?.firstOrNullWhere((t) => t.isCoAccess);
      if (coTrack != null) {
        SgsAppService.get()!.sendEvent(ToggleTrackSelectionEvent(coTrack, _coAccessibility));
      }
    } //
    else {
      super.onContextMenuItemChanged(p, item);
    }
    return true;
  }

  @override
  bool get showCartesianToolTip => super.showCartesianToolTip;

  @override
  void onItemTap(item, Offset offset) {
    //super.onItemTap(item, offset);
    //do nothing
  }

  @override
  void dispose() {
    super.dispose();
    _data?.clear();
    _data = null;
    _featureData.clear();
  }
}
