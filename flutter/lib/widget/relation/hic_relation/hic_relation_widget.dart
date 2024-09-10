import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/widget/relation/base/base_relation_widget.dart';
import 'package:flutter_smart_genome/widget/relation/base/relation_mixin.dart';
import 'package:flutter_smart_genome/widget/relation/base/relation_params.dart';
import 'package:flutter_smart_genome/widget/relation/hic_relation/global_circle_interactive_widget.dart';
import 'package:flutter_smart_genome/widget/relation/hic_relation/interactive_data.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/empty_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:dartx/dartx.dart' as cm;

import 'hic_relation_style_config.dart';
import 'hic_relation_painter.dart';

class HicRelationWidget extends BaseRelationWidget {
  final ValueChanged<Feature>? onZoomToRange;

  HicRelationWidget({
    Key? key,
    required SiteItem site,
    required Track track,
    // required LinearScale scale1,
    // required LinearScale scale2,
    required RelationParams relationParams,
    Color? background,
    Axis orientation = Axis.horizontal,
    this.onZoomToRange,
    ValueChanged<Track>? onRemoveTrack,
    GestureDetector? gestureBuilder,
    GestureDetector? gestureBuilder2,
    TrackWidgetEventCallback? trackEventCallback,
    bool? touchScaling,
    bool? fixTitle,
    double? maxHeight,
  }) : super(
          key: key,
          site: site,
          track: track,
          // scale1: scale1,
          // scale2: scale2,
          relationParams: relationParams,
          background: background,
          orientation: orientation,
          eventCallback: trackEventCallback,
          // touchScaling: touchScaling,
          containerHeight: maxHeight,
          gestureBuilder: gestureBuilder,
          gestureBuilder2: gestureBuilder2,
        );

  @override
  State<HicRelationWidget> createState() => HicRelationWidgetState();
}

class HicRelationWidgetState extends State<HicRelationWidget> with RelationMixin {
  // double _featureVisibleScale;
  // num _histogramBarSize;

  List<InteractiveItem> _interactives = [];
  List<InteractiveItem> _viewData = [];
  num _maxValue = 0;

  @override
  void initState() {
    blockPixels = 2000;
    viewType = TrackViewType.cartesian;
    super.initState();
  }

  @override
  void checkDidUpdateWidget(HicRelationWidget oldWidget) {
    // double _pixelOfRangeDelta = oldWidget.trackParams.pixelOfSeq - widget.trackParams.pixelOfSeq;
    // logger.d(_pixelOfRangeDelta * 10000);
    if (widget.chrChanged(oldWidget)) {
      // changed chr
    }
    super.checkDidUpdateWidget(oldWidget);
  }

  @override
  Map<int, Map> calculateBlockMap([RelationParams? params]) {
    RelationParams trackParams = params ?? widget.relationParams;
    if (!trackParams.prepared) return {};
    return {};
  }

  @override
  Future loadTrackData([bool isRefresh = false]) async {
    cancelToken?.cancel();
    await Future.delayed(Duration(milliseconds: 200));

    cancelToken = CancelToken();
    trackData = isRefresh ? [] : trackData;
    selectedItem = isRefresh ? null : selectedItem;
    loading = true;
    error = null;
    setState(() {});
    HttpResponseBean<List> _response = await AbsPlatformService.get()!.loadInteractiveData(
      host: widget.site.url,
      speciesId: relationParams.speciesId!,
      track: widget.track,
      chr1: relationParams.chr1.id,
      chr2: relationParams.chr2.id,
      idxStart: (relationParams.range1.start).floor(),
      //_hicData.idxStart,
      idxEnd: (relationParams.range1.end).floor(),
      // _hicData.idxEnd,
      idxStart2: (relationParams.range2!.start).floor(),
      //_hicData.idxStart,
      idxEnd2: (relationParams.range2!.end).floor(),
      // _hicData.idxEnd,
      cancelToken: cancelToken,
    );
    bool _canceled = _response.error != null && _response.error!.type == DioErrorType.cancel;
    if (_response.success) {
      List _data = _response.body ?? [];
      _data = _data.sortedByDescending((e) => e[4]);
      _interactives = transformData<InteractiveItem>(_data);
      if (!_interactives.isEmpty) _maxValue = max(_maxValue, _interactives.first.value);
      _viewData = _getViewData();
      trackData = _viewData;
    } else if (!_canceled) {
      _interactives = [];
      _viewData = [];
      trackData = [];
    }
    if (!mounted) return;
    setState(() {
      // trackData = _data;
      loading = false;
      error = _canceled ? null : _response.error?.message;
      cancelToken = null;
    });
    notifyDataViewer();
  }

  @override
  Future<bool> checkNeedReloadData() async {
    bool reload = !widget.touchScaling || trackData == null || trackData!.isEmpty;
    return reload && relationParams.prepared;
  }

  @override
  List<SettingItem> getContextMenuList(hitItem) {
    return TrackMenuConfig.interactiveSettings.where((e) => e.key != TrackContextMenuKey.relation_view_type).toList();
    // return super.getContextMenuList(hitItem);
  }

  @override
  void registerContextMenuSettings(List<SettingItem> settings) {
    super.registerContextMenuSettings(settings);
  }

  @override
  List<Widget> buildTitleActions() {
    return super.buildTitleActions();
  }

  @override
  TrackViewType getTrackViewType([RelationParams? params]) {
    return TrackViewType.cartesian;
  }

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
    Brightness _brightness = Theme.of(context).brightness;
    Color _primaryColor = Theme.of(context).colorScheme.primary;
    bool _dark = _brightness == Brightness.dark;
    Color _bgColor = _dark ? Colors.grey[900]! : Colors.white;

    if (!relationParams.prepared) {
      return EmptyTrackPainter(
        scale: widget.relationParams.scale1,
        visibleRange: widget.relationParams.range1,
        orientation: widget.orientation,
        brightness: _brightness,
        label: 'loading',
      );
    }

    EdgeInsets padding = widget.orientation == Axis.horizontal
        ? EdgeInsets.only(top: 22) //
        : EdgeInsets.only(right: 10);
    // List<InteractiveItem> _data = getViewData();

    return HicRelationPainter(
      orientation: widget.orientation,
      visibleRange: relationParams.range1,
      visibleRange2: relationParams.range2!,
      trackHeight: trackStyle.trackHeight,
      pixelOfSeq: relationParams.pixelPerSeq1,
      pixelOfSeq2: relationParams.pixelPerSeq2!,
      trackData: InteractiveData(_viewData, max: _maxValue, message: 'No relation in this range'),
      // collapseMode: _vcfStyle.trackMode,
      styleConfig: HicRelationConfig(
        padding: padding,
        backgroundColor: widget.background ?? _bgColor,
        textColor: trackStyle.fontColor,
        featureWidth: .5,
        lineColor: trackStyle.trackColor,
        brightness: _brightness,
        selectedColor: _primaryColor,
        primaryColor: _primaryColor,
      ),
      linearScale: relationParams.scale1,
      linearScale2: relationParams.scale2!,
      track: widget.track,
      selectedItem: selectedItem,
      chr1: relationParams.chr1.chrName,
      chr2: relationParams.chr2.chrName,
    );

    // return EmptyTrackPainter(orientation: widget.orientation, brightness: _brightness);
  }

  List<InteractiveItem> _getViewData() {
    List<InteractiveItem> _data = _interactives;
    if (customTrackStyle.customMaxValue.enabled) {
      _data = _data.where((e) => e.value <= customTrackStyle.customMaxValue.value!).toList();
    }
    if (customTrackStyle.customMinValue.enabled) {
      _data = _data.where((e) => e.value >= customTrackStyle.customMinValue.value!).toList();
    }
    _data = _data.takeFirst(min(1000, _data.length));
    return _data.reversed.toList();
  }

  @override
  D dataItemMapper<D>(item) {
    List _item = item;
    return InteractiveItem.fromList(_item) as D;
  }

  void onMenuChangeCallback(SettingItem? parentItem, SettingItem item) {
    if (item.key == TrackContextMenuKey.max_value || item.key == TrackContextMenuKey.min_value) {
      _viewData = _getViewData();
    }
  }

  @override
  void onContextMenuItemTap(SettingItem item, Rect menuRect, [dynamic target]) async {
    if (item.key == TrackContextMenuKey.interactive_circle_view) {
      _showCircleViewDialog();
    } else {
      super.onContextMenuItemTap(item, menuRect, target);
    }
  }

  void _showCircleViewDialog() async {
    var dialog = AlertDialog(
      title: Text('Circle View'),
      contentPadding: EdgeInsets.symmetric(vertical: 40, horizontal: 40),
      content: GlobalCircleInteractiveWidget(
        site: widget.site,
        chr: relationParams.chr1,
        track: widget.track,
      ),
    );
    showDialog(context: context, builder: (c) => dialog);
  }

  // @override
  // Widget tooltipBuilder(BuildContext context, item, cancel) {
  //   if (item is StackDataItem) {
  //     var colorMap = trackStyle.colorMap;
  //     List children = item.value.keys
  //         .map((key) => Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(
  //                   '${item.formatKey(key)} ',
  //                   style: TextStyle(fontFamily: 'Courier New', backgroundColor: colorMap[key]),
  //                 ),
  //                 Text(': ${item.value[key]}', style: TextStyle(fontFamily: 'Courier New')),
  //               ],
  //             ))
  //         .toList();
  //     return Container(
  //       padding: EdgeInsets.all(10),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         mainAxisSize: MainAxisSize.min,
  //         children: children,
  //       ),
  //     );
  //   }
  //   return super.tooltipBuilder(context, item, cancel);
  // }

  void updateRange(Range range) {}

  void updateParams(RelationParams params, [bool touching = true]) {
    relationParams = params;
    if (!touching) {
      // print('range change: ${params.range1}');
      debouncedLoadTrackData();
    } else {
      setState(() {});
    }
  }
}
