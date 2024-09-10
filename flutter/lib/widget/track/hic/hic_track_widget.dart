import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/mixin/track_data_mixin.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/stack_data.dart';
import 'package:flutter_smart_genome/widget/track/hic/hic_style_config.dart';
import 'package:flutter_smart_genome/widget/track/hic/hic_style.dart';

import 'hic_data.dart';
import 'hic_track_painter.dart';

class HicTrackWidget extends BaseTrackWidget {
  HicTrackWidget({
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
  State<HicTrackWidget> createState() => _HicTrackWidgetState();
}

enum HicDisplayMode {
  heatmap,
  flatArc,
  arc,
}

enum HicNormalize {
  VC,
  VC_SQRT,
  KR,
}

class _HicTrackWidgetState extends State<HicTrackWidget> with TrackDataMixin {
  late HicMatrix _matrix;
  late HicData _hicData;

  double? _maxValue;
  double? _minValue;

  double binSizePixel = 10;
  HicNormalize? _normalize;

  /// the best fitted resolution, find from #binSizeList
  late double _resolution;
  List<double> _resolutions = [
    2.5 * 1000000,
    1.0 * 1000000,
    500 * 1000,
    250 * 1000,
    100 * 1000,
    50 * 1000,
    25 * 1000,
    10 * 1000,
    5 * 1000,
    2.5 * 100,
    10 * 100,
    5 * 100,
    // 1 * 1000,
    // .5 * 100,
  ];

  @override
  void initState() {
    blockPixels = 2000;
    _resolution = findHicResolution(widget.trackParams.bpPerPixel);
    _matrix = HicMatrix.fromList(trackData, _resolution);
    _hicData = HicData(matrix: _matrix)..setRange(widget.range);
    super.initState();
  }

  void init(TrackParams trackParams) {
    // super.init(trackParams);
    Map statics = trackParams.track.getStatic(trackParams.chrId);
    List? binMaps = statics['bin_maps'];
    if (null != binMaps && binMaps.length > 0) {
      _resolutions = binMaps.map<double>((e) => double.parse(e['bin_length'])).toList();
    }
  }

  @override
  void initVisibleScale(TrackParams trackParams) {
    // do nothing
  }

  @override
  TrackViewType getTrackViewType([TrackParams? params]) {
    return TrackViewType.cartesian;
//    return super.getTrackViewType();
  }

  @override
  void checkDidUpdateWidget(HicTrackWidget oldWidget) {
    // double _pixelOfRangeDelta = oldWidget.trackParams.pixelOfSeq - widget.trackParams.pixelOfSeq;
    // logger.d(_pixelOfRangeDelta * 10000);
    if (!widget.touchScaling) {
      var resolution = findHicResolution(widget.trackParams.bpPerPixel);
      if (_resolution != resolution) {
        _resolution = resolution;
        _matrix = HicMatrix.fromList(null, _resolution);
        _hicData = HicData(matrix: _matrix);
      }
      _hicData.setRange(widget.range);
    }
    super.checkDidUpdateWidget(oldWidget);
  }

  Map<int, Map> calculateBlockMap([TrackParams? params]) {
    TrackParams trackParams = params ?? widget.trackParams;
    // num targetScale = findTargetScale(trackParams);
    // double fixedSizeOfPix = 1 / targetScale;
    double blockSize = _resolution * blockPixels / binSizePixel;

    //fix block size to times of min bar width
    var delta = blockSize % _resolution;
    if (delta > 0 && delta < blockSize) blockSize -= delta;

    int blockCount = (trackParams.chr.size / blockSize).ceil();
    //logger.d('fixedSizeOfPix: $fixedSizeOfPix, blockSize: $blockSize, blockCount: $blockCount');

    Map<int, Map> blockMap = List.generate(blockCount, (index) => index).asMap().map<int, Map>((key, value) {
      double start = key * blockSize;
      double end = start + blockSize - 1;
      return MapEntry(key, {
        'idxStart': start ~/ _resolution,
        // 'end': end <= trackParams.chr.rangeEnd ? end : trackParams.chr.rangeEnd,
        'idxEnd': end ~/ _resolution,
        'idxStart2': start ~/ _resolution,
        'idxEnd2': end ~/ _resolution,
        'start': start,
        'end': end,
        'blockSize': blockSize,
      });
    });
    // print(blockMap);
    return blockMap;
  }

  @override
  Future loadTrackData([bool isRefresh = false]) async {
    cancelToken?.cancel('cancel request track data');
    await Future.delayed(Duration(milliseconds: 200));

    TrackViewType _viewType = getTrackViewType();

    // Range _inflateRange = trackParams.chr.range;
    // int _start = _inflateRange.start.toInt(), _end = _inflateRange.end.toInt(), count;
    //
    // _start = widget.range.start.toInt();
    // _end = widget.range.end.toInt();
    // count = desiredBarCount();

    trackData = isRefresh || _viewType != viewType ? [] : trackData;
    selectedItem = isRefresh || _viewType != viewType ? null : selectedItem;
    loading = true;
    error = null;
    cancelToken = CancelToken();
    setState(() {});
    _normalize ??= HicNormalize.values[(customTrackStyle ?? trackStyle).get('hic_normalize') ?? 0];
    HttpResponseBean<List> _response = await AbsPlatformService.get()!.loadHicData(
      host: widget.site.url,
      speciesId: trackParams.speciesId,
      track: trackParams.track,
      chr1: trackParams.chrId,
      chr2: trackParams.chrId,
      idxStart: _hicData.idxStart!,
      idxEnd: _hicData.idxEnd!,
      idxStart2: _hicData.idxStart!,
      idxEnd2: _hicData.idxEnd!,
      resolution: _resolution,
      normalize: _normalize!.name,
      blockMap: null,
      //calculateBlockMap(),
      cancelToken: cancelToken,
    );
    // print(_data);
    if (!mounted) return;

    if (_response.success) {
      _matrix
        ..binSize = _resolution
        ..setDataSource(_response.body);
      _hicData.setRange(widget.range);
    }

    setState(() {
      loading = false;
      error = _response.error?.message;
      // _hicData.message = _response.message;
      if (_viewType != viewType) trackTotalHeight = 0;
      trackData = _response.body ?? [];
      viewType = _viewType;
      cancelToken = null;
    });
    notifyDataViewer();
  }

  @override
  Future<bool> checkNeedReloadData(HicTrackWidget oldWidget) async {
    return true;
    return widget.range != oldWidget.range || trackData == null;
    // return super.checkNeedReloadData();
  }

  @override
  List<SettingItem> getContextMenuList(hitItem) {
    return TrackMenuConfig.hicTrackSettings;
    // return super.getContextMenuList(hitItem);
  }

  @override
  List<Widget> buildTitleActions() {
    return [
      Container(
        child: Text(' Resolution:${_resolution.toInt()}'),
      ),
    ];
    return super.buildTitleActions();
  }

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
    Brightness _brightness = Theme.of(context).brightness;
    bool _dark = _brightness == Brightness.dark;
    // if (viewType == TrackViewType.cartesian) {
    //   return ZoomSeeTrackPainter(
    //     orientation: Axis.horizontal,
    //   );
    // }
    // if (viewType == TrackViewType.block || viewType == TrackViewType.feature) {
    // if (dataRangeChanged || _data == null) {
    //   _data = transformData<RangeFeature>(trackData);
    // }

    EdgeInsets padding = widget.orientation == Axis.horizontal
        ? EdgeInsets.only(top: 5) //
        : EdgeInsets.only(right: 10);

    _hicData
      ..filterMaxValue = customTrackStyle.customMaxValue.enableValueOrNull
      ..filterMinValue = customTrackStyle.customMinValue.enableValueOrNull;

    HicStyle _hicStyle = trackStyle as HicStyle;

    return HicTrackPainter(
      orientation: widget.orientation,
      visibleRange: widget.range,
      trackHeight: trackStyle.trackMaxHeight.enableValueOrNull,
      pixelOfSeq: trackParams.pixelPerBp,
      trackData: _hicData,
      displayMode: _hicStyle.displayMode,
      // collapseMode: _vcfStyle.trackMode,
      styleConfig: HicStyleConfig(
        padding: padding,
        backgroundColor: widget.background ?? Colors.grey[200],
        textColor: trackStyle.fontColor,
        color: trackColor,
        featureWidth: .5,
        lineColor: _dark ? Colors.grey[500] : Colors.black26.withAlpha(50),
        brightness: _brightness,
        selectedColor: _dark ? Colors.white : Theme.of(context).colorScheme.primary,
      ),
      scale: widget.scale,
      track: trackParams.track,
      showSubFeature: viewType == TrackViewType.feature,
      //_showLabel(), // size of pixel < 1000
      selectedItem: selectedItem,
      scaling: widget.touchScaling,
    );
    // }
    // return EmptyTrackPainter(orientation: widget.orientation, brightness: _brightness);
  }

  @override
  bool onContextMenuItemChanged(SettingItem? p, SettingItem item) {
    return super.onContextMenuItemChanged(p, item);
  }

  @override
  void onMenuChangeCallback(SettingItem? parent, SettingItem item) {
    if (item.key == TrackContextMenuKey.track_max_height || item.key == TrackContextMenuKey.hic_view_type) {
      trackTotalHeight = 0;
      TrackLayoutManager().getTrackLayout(widget.trackParams.track).maxHeight = 0;
    } else if (item.key == TrackContextMenuKey.hic_normalize) {
      _normalize = item.value;
      loadTrackData(true);
    }
  }

  @override
  void onContextMenuItemTap(SettingItem item, Rect menuRect, [dynamic target]) async {
    super.onContextMenuItemTap(item, menuRect, target);
  }

  @override
  Widget tooltipBuilder(BuildContext context, item, cancel) {
    if (item is StackDataItem) {
      var colorMap = trackStyle.colorMap!;
      List<Widget> children = item.value.keys
          .map((key) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${item.formatKey(key)} ',
                    style: TextStyle(fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK, backgroundColor: colorMap[key]),
                  ),
                  Text(': ${item.value[key]}', style: TextStyle(fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK)),
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

  double findHicResolution(double rangePerPix) {
    double blockRange = rangePerPix * binSizePixel;
    int i = 0;
    while (i < _resolutions.length && (_resolutions[i] / rangePerPix).floor() > binSizePixel) {
      if (i >= _resolutions.length - 1) break;
      i++;
    }
    if (_resolutions[i] / rangePerPix < binSizePixel) i--;
    i = i.clamp(0, _resolutions.length - 1);
    return _resolutions[i];
  }
}
