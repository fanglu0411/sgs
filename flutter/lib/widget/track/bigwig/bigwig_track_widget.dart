import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/mixin/track_data_mixin.dart';
import 'package:flutter_smart_genome/network/adapter/bigwig_adapter.dart';
import 'package:flutter_smart_genome/network/adapter/data_adapter.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';
import 'package:flutter_smart_genome/widget/track/bigwig/bigwig_style.dart';
import 'package:flutter_smart_genome/widget/track/bigwig/bigwig_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/xy_plot_style_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_data.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'package:dartx/dartx.dart' as cm;

class BigWigTrackWidget extends BaseTrackWidget {
  BigWigTrackWidget({
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
  State<BigWigTrackWidget> createState() => _BigwigTrackWidgetState();
}

class _BigwigTrackWidgetState extends State<BigWigTrackWidget> with TrackDataMixin {
  List<RangeFeature>? _data;
  FeatureData _featureData = FeatureData([]);

  @override
  void initState() {
    hoverDelay = 0;
    barWidth = 2;
    defaultContextStyle.cartesianValueType = 'mean';
    super.initState();
  }

  void init(TrackParams trackParams) {
    super.init(trackParams);
    Map statics = trackParams.track.getStatic(trackParams.chrId);
    cartesianMaxValue = prettyNumber(statics['max_value']) ?? 1.0;
    if (!customTrackStyle.customMaxValue.enabled) {
      customTrackStyle.customMaxValue = EnabledValue(enabled: false, value: cartesianMaxValue);
    }
  }

  @override
  void initVisibleScale(TrackParams trackParams) {
    blockVisibleScale = 1 / 20;
  }

  @override
  TrackViewType getTrackViewType([TrackParams? params]) {
    num targetScale = findTargetScale(params);
    if (targetScale < blockVisibleScale) {
      return TrackViewType.cartesian;
    }
    return TrackViewType.feature;
  }

  @override
  Future loadTrackData([bool isRefresh = false]) async {
    cancelToken?.cancel();
    // await Future.delayed(Duration(milliseconds: 200));

    TrackViewType _viewType = getTrackViewType();
    // if (_viewType == TrackViewType.cartesian) {
    int _start, _end, count;

    _start = widget.range.start.ceil();
    _end = widget.range.end.floor();
    count = desiredBarCount();

    trackData = isRefresh || _viewType != viewType ? [] : trackData;
    selectedItem = isRefresh || _viewType != viewType ? null : selectedItem;
    loading = true;
    cancelToken = CancelToken();
    setState(() {});
    var resp = await AbsPlatformService.get()!.loadBigwigData(
      host: widget.site.url,
      speciesId: trackParams.speciesId,
      track: trackParams.track,
      chr: trackParams.chrId,
      level: getDataLevel(_viewType),
      start: _start,
      end: _end,
      count: count,
      binSize: (2 ~/ findTargetScale(this.trackParams)),

      ///deprecated
      blockMap: _viewType == TrackViewType.cartesian ? cartesianBlockMap! : calculateExpandsBlockMap(_start, _end),
      cancelToken: cancelToken,
      valueType: trackStyle.cartesianValueType,
      adapter: getFeatureAdapter(_viewType),
    );
    List _data = resp.body!;
    if (!mounted) return;
    setState(() {
      loading = false;
      error = null;
      if (_viewType != viewType) trackTotalHeight = 0;
      trackData = _data;
      viewType = _viewType;
      cancelToken = null;
    });
    // } else {
    //   return super.loadTrackData(isRefresh);
    // }
  }

  @override
  DataAdapter getFeatureAdapter([TrackViewType? type]) => BigwigAdapter(track: trackParams.track);

  @override
  List<SettingItem> getContextMenuList(hitItem) {
    return TrackMenuConfig.bigWigTrackSettings;
  }

  @override
  void registerContextMenuSettings(List<SettingItem> settings) {
    SettingItem? valueTypeItem = settings.firstOrNullWhere((element) => element.key == TrackContextMenuKey.cartesian_value_type);
    valueTypeItem?.options?.removeWhere((o) => o.title == 'sum');
    super.registerContextMenuSettings(settings);
    // valueScaleItem?.value = _valueScaleType;
  }

  // @override
  // Future<bool> checkNeedReloadData(BigWigTrackWidget oldWidget) async {
  //   bool reload = !widget.touchScaling || trackData == null || trackData!.isEmpty;
  //   return reload;
  // }

  Scale<num, num> get visibleScale {
    var range = widget.range;
    return ScaleLinear.number(
      domain: [range.start, range.end],
      range: [widget.scale[range.start]!, widget.scale[range.end]!],
    );
  }

  // Range get inflateRange => widget.range.inflate(widget.range.size * .1);

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
    //print('range track view type $viewType ${widget.orientation} scale: ${widget.trackParams.scale}');
    Brightness _brightness = Theme.of(context).brightness;
    bool _dark = _brightness == Brightness.dark;
    Color _primaryColor = Theme.of(context).colorScheme.primary;

    double? maxValue = customTrackStyle.customMaxValue.enableValueOrNull;
    if (viewType == TrackViewType.cartesian) {
      return getBigwigTrackPainter();
    }

    if (dataRangeChanged || _data == null || _data!.length == 0) {
      _data = transformData<RangeFeature>(trackData!);
    }
    _featureData.features = _data;
//    logger.d('get painter ${dataRangeChanged} ${selectedItem?.hashCode}');
    Map<String, Color>? groupedColorMap = SgsConfigService.get()!.getGroupTrackColorMap(trackParams.track);
    return BigWigTrackPainter(
      orientation: widget.orientation!,
      visibleRange: widget.range,
      trackHeight: trackStyle.trackHeight,
      trackData: _featureData,
      // collapseMode: trackUIConfigBean.trackMode,
//      maxHeight: bigWigStyle.trackHeight,
//       densityMode: trackStyle.densityMode,
      styleConfig: XYPlotStyleConfig(
        padding: EdgeInsets.only(top: 10, bottom: 5),
        backgroundColor: widget.background ?? Colors.grey[200],
        blockBgColor: _dark ? Colors.grey.withAlpha(50) : Colors.grey.withAlpha(50),
        brightness: _brightness,
        selectedColor: _primaryColor.withAlpha(50),
        primaryColor: _primaryColor,
        colorMap: groupedColorMap ?? trackStyle.colorMap!,
      ),
      scale: widget.scale,
      track: trackParams.track,
      showSubFeature: trackParams.bpPerPixel < 120,
      // size of pixel < 1000
      selectedItem: selectedItem,
      cartesianType: viewType == TrackViewType.cartesian,
      valueScaleType: trackStyle.valueScaleType,
      customMaxValue: maxValue,
    );
  }

  @override
  bool onContextMenuItemChanged(SettingItem? p, SettingItem item) {
    //super.onContextMenuItemChanged(item);
    if (item.key == TrackContextMenuKey.densityMode) {
      BigWigStyle bigWigStyle = trackStyle as BigWigStyle;
      bigWigStyle.densityMode = item.value;
      setState(() {});
    } else {
      return super.onContextMenuItemChanged(p, item);
    }
    return true;
  }

  @override
  bool get showCartesianToolTip => false;

  @override
  void onItemTap(item, Offset offset) {
    if (item is CartesianDataItem) {
      super.onItemTap(item, offset);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _data?.clear();
    _data = null;
    _featureData.clear();
    // _featureData = null;
  }
}
