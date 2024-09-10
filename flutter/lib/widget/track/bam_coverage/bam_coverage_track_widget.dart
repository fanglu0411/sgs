import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/gene.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/mixin/track_data_mixin.dart';
import 'package:flutter_smart_genome/network/adapter/bam_coverage_adapter.dart';
import 'package:flutter_smart_genome/network/adapter/data_adapter.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/bam_coverage/bam_coverage_style.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/stack_bar_style_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/stack_bar_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/stack_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:dartx/dartx.dart' as cm;

class BamCoverageTrackWidget extends BaseTrackWidget {
  BamCoverageTrackWidget({
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
  State<BamCoverageTrackWidget> createState() => _BamCoverageTrackWidgetState();
}

class _BamCoverageTrackWidgetState extends State<BamCoverageTrackWidget> with TrackDataMixin {
  List<Map>? _data;

  // Map _blockMap;

  @override
  void initState() {
    // _blockMap = calculateBlockMap(widget.trackParams);
    hoverDelay = 0;
    barWidth = 2;
    super.initState();
  }

  init(TrackParams trackParams) {
    super.init(trackParams);
    Map statics = trackParams.track.getStatic(trackParams.chrId);
    cartesianMaxValue = prettyNumber(statics['max_value']) ?? 1000;
    if (!customTrackStyle.customMaxValue.enabled) {
      customTrackStyle.customMaxValue = customTrackStyle.customMaxValue.copy(value: cartesianMaxValue);
    }
  }

  @override
  void initVisibleScale(TrackParams trackParams) {
    blockVisibleScale = .5;
  }

  @override
  TrackViewType getTrackViewType([TrackParams? params]) {
    num targetScale = findTargetScale(params ?? trackParams);
    if (targetScale < blockVisibleScale) {
      return TrackViewType.cartesian;
    }
    return TrackViewType.feature;
  }

  @override
  Map<String, Color> get colorMap => {
        ...trackStyle.colorMap!,
        ...(customTrackStyle.colorMap ?? {}),
      };

  @override
  Future loadTrackData([bool isRefresh = false]) async {
    TrackViewType _viewType = getTrackViewType();
    if (_viewType == TrackViewType.cartesian) {
      return loadBigwigData(isRefresh);
    } else {
      super.loadTrackData(isRefresh);
    }
  }

  DataAdapter getFeatureAdapter([TrackViewType? type]) => BamCoverageAdapter(track: trackParams.track);

  Map _calculateReadsBlockMap(int start, int end) {
    Range _chrRange = trackParams.chr.range;
    int blockSize = 2000;
    Map _blocks = {};
    int _d = start ~/ blockSize;
    int _start = _d * blockSize;
    int _end = _start + blockSize;
    _blocks[_d++] = Range(start: _start, end: _end).toJson()..['blockSize'] = blockSize;
    while (end > _end) {
      _start += blockSize;
      _end += blockSize;
      if (_end > _chrRange.end) _end = _chrRange.end.toInt();
      _blocks[_d++] = {
        'start': _start,
        'end': _end,
        'blockSize': blockSize,
      };
    }
    // logger.d('start: $start, end:$end');
    // logger.d(_blocks.toString());
    return _blocks;
  }

  @override
  Map calculateBlockMap([TrackParams? params]) {
    return super.calculateBlockMap(params);
    TrackParams trackParams = params ?? widget.trackParams;
    num targetScale = findTargetScale(trackParams);
    double fixedSizeOfPix = 1 / targetScale;
    double blockSize = fixedSizeOfPix * blockPixels;
    int blockCount = (trackParams.chr.size / blockSize).ceil();

    Map blockMap = List.generate(blockCount, (index) => index).asMap().map((key, value) {
      double start = key * blockSize;
      double end = start + blockSize;
      return MapEntry(key, {
        'start': start,
        'end': end <= trackParams.chr.rangeEnd ? end : trackParams.chr.rangeEnd,
        'blockSize': blockSize,
      });
    });
    return blockMap;
  }

  @override
  List<SettingItem> getContextMenuList(var hitItem) {
    return [
      if (null != hitItem) TrackMenuConfig.fromKey(TrackContextMenuKey.zoom_to_feature),
      ...TrackMenuConfig.bamTrackSettings,
    ];
    // return super.getContextMenuList(hitItem);
  }

  @override
  void registerContextMenuSettings(List<SettingItem> settings) {
    super.registerContextMenuSettings(settings);
    // SettingItem valueScaleItem = settings.firstOrNullWhere((element) => element.key == TrackContextMenuKey.value_scale_type);
    // valueScaleItem?.value = _valueScaleType;
  }

  @override
  List<Widget> buildTitleActions() {
    return super.buildTitleActions();
  }

  @override
  int desiredBarCount() {
    return super.desiredBarCount();
    // return math.max((blockPixels ~/ barWidth), 200);
  }

  // @override
  // Future<bool> checkNeedReloadData(BamCoverageTrackWidget oldWidget) async {
  //   if (viewType == TrackViewType.cartesian) {
  //     bool reload = !widget.touchScaling || trackData == null || trackData!.isEmpty;
  //     // if (reload) cancelToken?.cancel();
  //     return reload;
  //   }
  //   return super.checkNeedReloadData(oldWidget);
  // }

  Range get inflateRange => widget.range.inflate(widget.range.size * .1);

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
    //print('range track view type $viewType ${widget.orientation} scale: ${widget.trackParams.scale}');
    Brightness _brightness = Theme.of(context).brightness;
    bool _dark = _brightness == Brightness.dark;
    if (viewType == TrackViewType.cartesian) {
      return super.getBigwigTrackPainter();
    }

    // if (dataRangeChanged || _data == null || _data.length == 0) {
    _data = transformData<Map>(trackData!);
    // }
    EdgeInsets padding = widget.orientation == Axis.horizontal
        ? EdgeInsets.only(top: 5) //
        : EdgeInsets.only(right: 10);
    return StackBarTrackPainter(
      trackData: StackData(
        values: _data!,
        dataRange: widget.range,
        hasRange: true,
        scale: widget.scale,
        coverage: 'coverage',
        saveSourceData: true,
      ),
      styleConfig: StackBarStyleConfig(
        backgroundColor: widget.background,
        padding: padding,
        brightness: _brightness,
        colorMap: colorMap,
        primaryColor: Theme.of(context).colorScheme.primary,
        selectedColor: _dark ? Theme.of(context).colorScheme.primary.withAlpha(50) : Theme.of(context).colorScheme.primary.withAlpha(100),
      ),
      visibleRange: widget.range,
      height: trackStyle.trackHeight,
      scale: widget.scale,
      orientation: widget.orientation,
      selectedItem: selectedItem,
      tooltipMapper: _tooltipMapper,
      coverageStyle: CartesianChartType.bar,
    );

//    logger.d('get painter ${dataRangeChanged} ${selectedItem?.hashCode}');
//     return BamCoverageTrackPainter(
//       orientation: widget.orientation!,
//       visibleRange: widget.range,
//       trackHeight: trackStyle.trackHeight,
//       trackData: FeatureData(_data!),
//       // collapseMode: trackUIConfigBean.trackMode,
// //      maxHeight: bigWigStyle.trackHeight,
// //       densityMode: trackStyle.densityMode,
//       styleConfig: XYPlotStyleConfig(
//         padding: EdgeInsets.only(top: 30, bottom: 10),
//         backgroundColor: widget.background ?? Colors.grey[200],
//         blockBgColor: _dark ? Colors.grey.withAlpha(50) : Colors.grey.withAlpha(50),
//         brightness: _brightness,
//         selectedColor: Theme.of(context).colorScheme.primary.withAlpha(50),
//         colorMap: trackStyle.colorMap!,
//       ),
//       scale: widget.scale,
//       track: trackParams.track,
//       showSubFeature: trackParams.bpPerPixel < 120,
//       // size of pixel < 1000
//       selectedItem: selectedItem,
//       cartesianType: viewType == TrackViewType.cartesian,
//       valueScaleType: trackStyle.valueScaleType,
//     );
  }

  Map _tooltipMapper(StackDataItem item) {
    return item.source == null
        ? item.value.map((key, value) {
            return MapEntry(key, item.formatValue(value).padLeft(5).padRight(3));
          })
        : item.value.map((key, value) {
            var _data = item.source![key];
            String __labelValue;
            if (_data != null && _data is List && _data.length > 1) {
              __labelValue = '${item.formatValue(value).padRight(2)} (+ ${item.formatValue(_data[0]).padRight(2)}, - ${item.formatValue(_data[1]).padRight(2)})';
            } else {
              __labelValue = item.formatValue(_data).padLeft(5);
            }
            return MapEntry(key, __labelValue);
          });
  }

  @override
  bool onContextMenuItemChanged(SettingItem? p, SettingItem item) {
    //super.onContextMenuItemChanged(item);
    if (item.key == TrackContextMenuKey.densityMode) {
      BamCoverageStyle _coverageStyle = trackStyle as BamCoverageStyle;
      _coverageStyle.densityMode = item.value;
      setState(() {});
    } else if (item.key == TrackContextMenuKey.track_color) {
      // trackStyle.setColorMapEntry('coverage', item.value);
      customTrackStyle.setColorMapEntry('coverage', item.value);
      setState(() {});
    } else {
      super.onContextMenuItemChanged(p, item);
    }
    return true;
  }

  @override
  void onContextMenuItemTap(SettingItem item, Rect menuRect, [dynamic target]) async {
    if (item.key == TrackContextMenuKey.gene_info) {
      if (target is Feature) {
        Feature feature = target;
        var geneInfo = GeneInfo(
          gid: feature.featureId,
          chrId: trackParams.chrId,
          speciesId: trackParams.speciesId,
          species: trackParams.speciesName,
          chrName: trackParams.chr.chrName,
          name: feature.name,
          range: feature.range,
        );
        Navigator.of(context).pushNamed(RoutePath.gene_detail, arguments: [geneInfo, 'info']);
      }
    } else {
      super.onContextMenuItemTap(item, menuRect, target);
    }
  }

  @override
  D dataItemMapper<D>(var item) {
    return item;
  }

  @override
  bool get showCartesianToolTip => false;

  @override
  Widget tooltipBuilder(BuildContext context, item, cancel) {
    if (item is StackDataItem) {
      var colorMap = trackStyle.colorMap!;
      int keyMaxLength = item.groups.maxBy((e) => e.length)!.length;
      List<Widget> children = item.value.keys
          .map((key) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${item.formatKey(key, keyMaxLength)} ',
                    style: TextStyle(fontFamily: 'Courier New', backgroundColor: colorMap[key]),
                  ),
                  Text(': ${item.formatValue(item.value[key])}', style: TextStyle(fontFamily: 'Courier New')),
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
  }
}
