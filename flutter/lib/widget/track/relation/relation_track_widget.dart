import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/mixin/track_data_mixin.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/relation/hic_relation/global_circle_interactive_widget.dart';
import 'package:flutter_smart_genome/widget/track/relation/interactive_data.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:dartx/dartx.dart' as cm;

import 'hic_relation_style_config.dart';
import 'relation_track_painter.dart';
import 'relation_view_type.dart';

class RelationTrackWidget extends BaseTrackWidget {
  RelationTrackWidget({
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
  State<RelationTrackWidget> createState() => HicRelationWidgetState();
}

class HicRelationWidgetState extends State<RelationTrackWidget> with TrackDataMixin {
  List<InteractiveItem> _interactives = [];
  List<InteractiveItem> _viewData = [];
  num _maxValue = 0;
  num _minValue = 0;

  @override
  void initState() {
    blockPixels = 2000;
    super.initState();
  }

  void init(TrackParams params) {
    super.init(trackParams);
  }

  @override
  void initVisibleScale(TrackParams trackParams) {
    //do nothing
  }

  @override
  TrackViewType getTrackViewType([TrackParams? params]) {
    return TrackViewType.cartesian;
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
      speciesId: trackParams.speciesId,
      track: trackParams.track,
      chr1: trackParams.chrId,
      chr2: trackParams.chrId,
      idxStart: (widget.range.start).floor(),
      //_hicData.idxStart,
      idxEnd: (widget.range.end).floor(),
      // _hicData.idxEnd,
      idxStart2: (widget.range.start).floor(),
      //_hicData.idxStart,
      idxEnd2: (widget.range.end).floor(),
      // _hicData.idxEnd,
      cancelToken: cancelToken,
    );
    bool _canceled = _response.error != null && _response.error!.type == DioErrorType.cancel;

    if (_response.success) {
      List _data = _response.body ?? [];
      _data = _data.sortedByDescending((e) => e[4]);
      _interactives = transformData<InteractiveItem>(_data);
      if (_data.isNotEmpty) {
        _maxValue = _interactives.first.value;
        _minValue = _interactives.last.value;
        // _maxValue = max(_maxValue, _interactives.first.value);
        // _minValue = min(_minValue, _interactives.last.value);
      }
      _viewData = _getViewData();
      trackData = _viewData;
    } else if (!_canceled) {
      _interactives = [];
      _viewData = [];
      trackData = null;
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

  _filterInCurrentViewData() {
    _viewData = _getViewData();
    trackData = _viewData;
  }

  @override
  Future<bool> checkNeedReloadData(RelationTrackWidget oldWidget) async {
    bool reload = !widget.touchScaling || trackData == null || trackData!.isEmpty;
    return reload;
  }

  @override
  List<SettingItem> getContextMenuList(hitItem) {
    return TrackMenuConfig.interactiveSettings.where((e) => e.key != TrackContextMenuKey.relation_view_type).toList();
    // return super.getContextMenuList(hitItem);
  }

  @override
  void registerContextMenuSettings(List<SettingItem> settings) {
    super.registerContextMenuSettings(settings);
    SettingItem? inCurrentView = settings.firstOrNullWhere((e) => e.key == TrackContextMenuKey.data_current_view);
    inCurrentView?.value = customTrackStyle.dataInCurrentView ?? false;
  }

  @override
  List exportData() {
    return _viewData.map((e) => e.json).toList();
    return super.exportData();
  }

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
    Brightness _brightness = Theme.of(context).brightness;
    Color _primaryColor = Theme.of(context).colorScheme.primary;
    bool _dark = _brightness == Brightness.dark;
    Color _bgColor = _dark ? Colors.grey[800]! : Colors.white;

    // if (_interactives.isEmpty) {
    //   return EmptyTrackPainter(
    //     orientation: widget.orientation,
    //     brightness: _brightness,
    //     label: loading ? 'loading' : 'No relation in this range',
    //   );
    // }

    EdgeInsets padding = widget.orientation == Axis.horizontal
        ? EdgeInsets.only(top: 5) //
        : EdgeInsets.only(right: 10);
    // List<InteractiveItem> _data = getViewData();

    // InteractiveStyle _style = trackStyle as InteractiveStyle;

    return RelationTrackPainter(
      orientation: widget.orientation,
      visibleRange: widget.range,
      trackHeight: trackStyle.trackHeight,
      pixelOfSeq: trackParams.pixelPerBp,
      trackData: InteractiveData(_viewData, max: _maxValue, min: _minValue, message: error ?? 'No relation in this range'),
      // collapseMode: _vcfStyle.trackMode,
      styleConfig: HicRelationConfig(
        padding: padding,
        backgroundColor: widget.background ?? _bgColor,
        textColor: trackStyle.fontColor,
        featureWidth: .5,
        lineColor: trackColor,
        brightness: _brightness,
        selectedColor: _primaryColor,
        primaryColor: _primaryColor,
      ),
      scale: widget.scale,
      track: trackParams.track,
      selectedItem: selectedItem,
      viewMode: SgsAppService.get()!.paired ? RelationViewType.line : RelationViewType.arc, // _style.viewMode,
    );

    // return EmptyTrackPainter(orientation: widget.orientation, brightness: _brightness);
  }

  List<InteractiveItem> _getViewData() {
    List<InteractiveItem> _data = _interactives;
    if (customTrackStyle.customMaxValue.enabled) {
      _data = _data.where((e) => e.value <= (customTrackStyle.customMaxValue.value as double)).toList();
    }
    if (customTrackStyle.customMinValue.enabled) {
      _data = _data.where((e) => e.value >= (customTrackStyle.customMinValue.value as double)).toList();
    }

    _data = _data
        .where((e) => customTrackStyle.dataInCurrentView
            ? (e.range1.collide(widget.range) && e.range2.collide(widget.range)) //
            : (e.range1.collide(widget.range) || e.range2.collide(widget.range)))
        .toList();

    _data = _data.takeFirst(min(1000, _data.length));
    logger.d('${_data.length}');
    return _data.reversed.toList();
  }

  @override
  D dataItemMapper<D>(item) {
    List _item = item;
    return InteractiveItem.fromList(_item) as D;
  }

  @override
  void onMenuChangeCallback(SettingItem? parent, SettingItem item) {
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

  @override
  bool onContextMenuItemChanged(SettingItem? p, SettingItem item) {
    if (item.key == TrackContextMenuKey.data_current_view) {
      customTrackStyle.dataInCurrentView = item.value;
      _filterInCurrentViewData();
      setState(() {});
      return true;
    }
    var result = super.onContextMenuItemChanged(p, item);
    return result;
  }

  void _showCircleViewDialog() async {
    var dialog = AlertDialog(
      title: Text('Circle View'),
      contentPadding: EdgeInsets.symmetric(vertical: 40, horizontal: 40),
      content: GlobalCircleInteractiveWidget(
        site: widget.site,
        chr: trackParams.chr,
        track: trackParams.track,
      ),
    );
    showDialog(context: context, builder: (c) => dialog);
  }
}
