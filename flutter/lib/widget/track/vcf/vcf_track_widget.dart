import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/mixin/track_data_mixin.dart';
import 'package:flutter_smart_genome/network/adapter/abs_feature_adapter.dart';
import 'package:flutter_smart_genome/network/adapter/range_feature_adapter.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/empty_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/stack_bar_style_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/stack_bar_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/stack_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';
import 'package:flutter_smart_genome/widget/track/vcf/vcf_track_painter.dart';

class VcfTrackWidget extends BaseTrackWidget {
  VcfTrackWidget({
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
  State<VcfTrackWidget> createState() => _VcfTrackWidgetState();
}

class _VcfTrackWidgetState extends State<VcfTrackWidget> with TrackDataMixin {
  @override
  void initState() {
    super.initState();
  }

  void init(TrackParams trackParams) {
    super.init(trackParams);
    Map statics = trackParams.track.getStatic(trackParams.chrId);
    cartesianMaxValue = prettyNumber(statics['max_value']) ?? 100;
    if (!customTrackStyle.customMaxValue.enabled) {
      customTrackStyle.customMaxValue = customTrackStyle.customMaxValue.copy(value: cartesianMaxValue);
    }
  }

  @override
  void initVisibleScale(TrackParams trackParams) {
    Map statics = trackParams.track.getStatic(trackParams.chrId);
    var totalFeatureCount = statics['feature_count'] ?? trackParams.chr.size / 200.0;
    // _histogramBarSize = statics['basic_histogram_step_length'] ?? 1000;
    logger.d('${trackParams.track.trackName} $statics, total feature count ${totalFeatureCount}, chr len: ${trackParams.chr.size}');
    num _avgFeatureLength = statics['average_f_length'] ?? 1; //trackParams.chr.size / totalFeatureCount; // (totalFeatureCount * 1.0).clamp(100, 200000); // chrLength / totalFeatureCount;
    // var _avgByChr = trackParams.chr.size / totalFeatureCount;
    // var __visibleScale = (20.0 / _avgByChr);
    // var __visibleScale = (1 / (_avgFeatureLength * 1500 / 2000.0)).clamp(0.001, 0.1);
    blockVisibleScale = (10.0 / _avgFeatureLength).clamp(0.0005, .004);

    // if (customTrackStyle.forceVisibleScale != null && customTrackStyle.forceVisibleScale! < blockVisibleScale) {
    //   blockVisibleScale = customTrackStyle.forceVisibleScale!;
    // }
    // _featureVisibleScale = barWidth / _histogramBarSize;

    var chrSize = trackParams.chr.size;
    if (chrSize >= 1.5 * 100000000) //1.5亿
      blockVisibleScale = 1 / 2500;
    else if (chrSize >= 1 * 100000000) //1.5亿
      blockVisibleScale = 1 / 2500;
    else if (chrSize >= 2 * 10000000) //2千万
      blockVisibleScale = 1 / 2500;
    else if (chrSize >= 1 * 10000000) //1千万
      blockVisibleScale = 1 / 1000;
    else
      blockVisibleScale = 1 / 1000;

    logger.d('featureVisibleScale => $blockVisibleScale ,');
  }

  double get blockDensityBreak {
    var chrSize = widget.trackParams.chr.size;
    if (chrSize > 200000000) return 1.5;
    if (chrSize > 100000000) return 2.0;
    if (chrSize > 50000000) return 1.5;
    if (chrSize > 10000000) return 2.0;
    if (chrSize > 5000000) return 2.0;
    if (chrSize > 1000000) return 3.5;
    if (chrSize > 100000) return 5.0;
    return 10.0;
  }

  @override
  TrackViewType getTrackViewType([TrackParams? params]) {
    return super.getTrackViewType(params);
    TrackParams trackParams = params ?? widget.trackParams;
    double targetScale = findTargetScale(trackParams);
    logger.d('targetScale:$targetScale, _featureVisibleScale:${blockVisibleScale}, ${featureScreenDensity(trackParams)} chr size:${trackParams.chr.size}');
    if (trackParams.chr.size < 60000) {
      if (targetScale <= 0.5) {
        return TrackViewType.block;
      }
      return TrackViewType.feature;
    }

    //cartesian -> block -> feature
    var featureVisibleScale = trackParams.zoomConfig.nextLevel(blockVisibleScale, 3);
    //小 -> 中 ->  大
    if (targetScale < blockVisibleScale) {
      return TrackViewType.cartesian;
    } else if (targetScale < featureVisibleScale) {
      return TrackViewType.block;
    } else {
      return TrackViewType.feature;
    }
  }

  @override
  Future loadTrackData([bool isRefresh = false]) async {
    TrackViewType _viewType = getTrackViewType();
    if (_viewType == TrackViewType.cartesian) {
      return loadBigwigData(isRefresh);
      Range _inflateRange = trackParams.chr.range;
      int _start = _inflateRange.start.toInt(), _end = _inflateRange.end.toInt(), count;

      _start = widget.range.start.toInt();
      _end = widget.range.end.toInt();
      count = desiredBarCount();

      trackData = isRefresh || _viewType != viewType ? [] : trackData;
      selectedItem = isRefresh || _viewType != viewType ? null : selectedItem;
      loading = true;
      cancelToken?.cancel();
      cancelToken = CancelToken();
      setState(() {});
      List _data = await AbsPlatformService.get()!.loadStaticsData(
        host: widget.site.url,
        speciesId: trackParams.speciesId,
        track: trackParams.track,
        chr: trackParams.chrId,
        start: _start,
        end: _end,
        count: count,
        blockMap: cartesianBlockMap!,
        cancelToken: cancelToken,
      );
      // print(_data);
      if (!mounted) return;
      setState(() {
        loading = false;
        error = null;
        if (_viewType != viewType) trackTotalHeight = 0;
        trackData = _data;
        viewType = _viewType;
        cancelToken = null;
      });
      notifyDataViewer();
    } else {
      return super.loadTrackData(isRefresh);
    }
  }

//   @override
//   Future<bool> checkNeedReloadData(VcfTrackWidget oldWidget) async {
// //    if (trackData == null || trackData.isEmpty) return true;
// //    return false;
//     if (viewType == TrackViewType.cartesian) {
//       bool reload = !widget.touchScaling || trackData == null || trackData!.isEmpty;
//       // if (reload) cancelToken?.cancel();
//       return reload;
//     }
//     return super.checkNeedReloadData(oldWidget);
//   }

  @override
  AbsFeatureAdapter getFeatureAdapter([TrackViewType? type]) {
    return RangeFeatureAdapter(track: trackParams.track, level: getDataLevel(type ?? viewType!));
  }

  List<RangeFeature>? _data;
  FeatureData _featureData = FeatureData([]);

  @override
  List<SettingItem> getContextMenuList(hitItem) {
    if (viewType == TrackViewType.cartesian) {
      return [
        if (null != hitItem) TrackMenuConfig.fromKey(TrackContextMenuKey.zoom_to_feature),
        if (widget.trackParams.pixelPerBp >= forceLoadFeatureMinScale) TrackMenuConfig.fromKey(TrackContextMenuKey.force_load_feature),
        ...TrackMenuConfig.vcfCartesianTrackSettings,
      ];
    }
    return TrackMenuConfig.vcfTrackSettings;
    // return super.getContextMenuList(hitItem);
  }

  @override
  Map<String, Color> get colorMap {
    Map<String, Color> _colorMap = originColorMap;
    return {
      ..._colorMap,
      'insertion': _colorMap['INDEL']!,
      'deletion': _colorMap['INDEL']!,
      'DEL': _colorMap['INDEL']!,
      'INS': _colorMap['INDEL']!,
      'INS,DEL': _colorMap['INDEL']!,
      'DEL,INS': _colorMap['INDEL']!,
      'variant density': customTrackStyle.trackColor ?? trackStyle.trackColor!,
    };
  }

  Map<String, Color> get originColorMap {
    return <String, Color>{
      ...trackStyle.colorMap!,
      ...(customTrackStyle.colorMap ?? {}),
    };
  }

  Map<String, FeatureStyle> get vcfFeatureStyle {
    return colorMap.map<String, FeatureStyle>((key, value) => MapEntry<String, FeatureStyle>(key, FeatureStyle(color: value, id: key, name: key)));
  }

  @override
  void registerContextMenuSettings(List<SettingItem> settings) {
    super.registerContextMenuSettings(settings);
  }

  String _labelKey() {
    double targetScale = findTargetScale();
    return targetScale >= blockVisibleScale * 4 * 4 ? 'alt_detail' : 'feature_name';
  }

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
    //print('range track view type $viewType ${widget.orientation} scale: ${widget.trackParams.scale}');
    Brightness _brightness = Theme.of(context).brightness;
    bool _dark = _brightness == Brightness.dark;

    if (viewType == TrackViewType.cartesian) {
      return super.getBigwigTrackPainter();
      double height = max(trackStyle.trackHeight, 120.0);
      EdgeInsets padding = widget.orientation == Axis.horizontal
          ? EdgeInsets.only(top: 22) //
          : EdgeInsets.only(right: 10);

      // CartesianTrackType cartesianTrackType = CartesianTrackType.bar;
      List<Map> _data = transformData<Map>(trackData!);

      return StackBarTrackPainter(
        trackData: StackData(
          values: _data,
          dataRange: widget.range,
          hasRange: true,
          scale: widget.scale,
        ),
        styleConfig: StackBarStyleConfig(
          backgroundColor: widget.background,
          padding: padding,
          brightness: _brightness,
          colorMap: colorMap,
          primaryColor: Theme.of(context).colorScheme.primary,
          selectedColor: _dark ? Theme.of(context).colorScheme.primary.withAlpha(50) : Theme.of(context).colorScheme.primary.withAlpha(100),
        ),
        height: height,
        visibleRange: widget.range,
        scale: widget.scale,
        orientation: widget.orientation,
        selectedItem: selectedItem,
      );
    }
    if (viewType == TrackViewType.block || viewType == TrackViewType.feature) {
      if (dataRangeChanged || _data == null) {
        _data = transformData<RangeFeature>(trackData ?? []);
      }
      _featureData.features = _data!.where((e) => e.range.collide(widget.range)).toList();
      _featureData.message = loading ? null : 'No feature in this range';
      // logger.d('get painter ${_data}');
      return VcfTrackPainter(
        orientation: widget.orientation,
        visibleRange: widget.range,
        trackHeight: trackStyle.featureHeight,
        trackData: _featureData,
        // collapseMode: _vcfStyle.trackMode,
        styleConfig: FeatureStyleConfig(
          padding: EdgeInsets.only(top: 5),
          backgroundColor: widget.background ?? Colors.grey[200],
          blockBgColor: trackStyle.trackColor!,
          showLabel: trackStyle.showLabel,
          labelFontSize: trackStyle.fontSize,
          textColor: trackStyle.fontColor,
          groupColor: trackStyle.featureGroupColor,
          featureWidth: .5,
          featureStyles: vcfFeatureStyle,
          lineColor: _dark ? Colors.grey[500] : Colors.black26.withAlpha(50),
          brightness: _brightness,
          selectedColor: _dark ? Colors.white : Theme.of(context).colorScheme.primary.withAlpha(100),
        ),
        scale: widget.scale,
        track: trackParams.track,
        showSubFeature: viewType == TrackViewType.feature,
        //_showLabel(), // size of pixel < 1000
        labelKey: _labelKey(),
        selectedItem: selectedItem,
      );
    }
    return EmptyTrackPainter(
      orientation: widget.orientation,
      brightness: _brightness,
      scale: widget.scale,
      visibleRange: widget.range,
    );
  }

  @override
  bool onContextMenuItemChanged(SettingItem? p, SettingItem item) {
    return super.onContextMenuItemChanged(p, item);
  }

  @override
  void onContextMenuItemTap(SettingItem item, Rect menuRect, [dynamic target]) async {
    super.onContextMenuItemTap(item, menuRect, target);
  }

  @override
  bool get showCartesianToolTip => false;

  @override
  Widget tooltipBuilder(BuildContext context, item, cancel) {
    if (item is StackDataItem) {
      var colorMap = trackStyle.colorMap!;
      List<Widget> children = item.value.keys
          .map((key) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${item.formatKey(key)} ', style: TextStyle(fontFamily: 'Courier New', backgroundColor: colorMap[key])),
                  Text(': ${item.value[key]}', style: TextStyle(fontFamily: 'Courier New')),
                ],
              ))
          .toList();
      return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );
    }
    return super.tooltipBuilder(context, item, cancel);
  }

  @override
  void dispose() {
    super.dispose();
    _data?.clear();
    _data = null;
    _featureData.clear();
  }
}
