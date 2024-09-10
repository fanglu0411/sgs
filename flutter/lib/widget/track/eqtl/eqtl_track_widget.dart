import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/chart/scale/value_sale_type.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/mixin/track_data_mixin.dart';
import 'package:flutter_smart_genome/network/adapter/data_adapter.dart';
import 'package:flutter_smart_genome/network/adapter/eqtl_feature_adapter.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/base/zoom_see_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/PositionedData.dart';
import 'package:flutter_smart_genome/widget/track/eqtl/eqtl_style.dart';
import 'package:flutter_smart_genome/widget/track/eqtl/eqtl_track_logic.dart';
import 'package:flutter_smart_genome/widget/track/eqtl/eqtl_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/xy_plot_style_config.dart';
import 'package:get/get.dart';

class EQTLTrackWidget extends BaseTrackWidget {
  EQTLTrackWidget({
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
  State<EQTLTrackWidget> createState() => _EQTLTrackWidgetState();
}

class _EQTLTrackWidgetState extends State<EQTLTrackWidget> with TrackDataMixin {
  late EqtlTrackLogic _logic;

  @override
  void initState() {
    _logic = Get.put(EqtlTrackLogic(widget.trackParams.track), tag: trackParams.trackId);
    defaultContextStyle = EQTLStyle.from(lightStyleMap: {
      'custom_max_value': {"enabled": true, "value": 0.05},
      'value_scale_type': ValueScaleType.LOG.index,
    }, brightness: Brightness.light);
    hoverDelay = 0;
    // barWidth = 1;
    super.initState();
  }

  void init(TrackParams trackParams) {
    super.init(trackParams);
  }

  @override
  void initVisibleScale(TrackParams trackParams) {
    super.initVisibleScale(trackParams);
  }

  @override
  Future<bool> dataBlockChange(EQTLTrackWidget oldWidget, TrackViewType viewTypeNew) {
    return Future.value(oldWidget.range != widget.range);
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
      return loadBigwigData(isRefresh);
    }
  }

  @override
  List<Widget> buildTitleActions() {
    {
      return [
        if (_logic.feature != null)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).colorScheme.primary),
              shape: BoxShape.rectangle,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            padding: EdgeInsets.only(left: 6),
            alignment: Alignment.center,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(_logic.feature!, style: TextStyle(fontSize: 11)),
                IconButton(
                  icon: Icon(Icons.close),
                  tooltip: 'Clear',
                  iconSize: 14,
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(width: 24, height: 20),
                  onPressed: () {
                    _logic.clearFeature();
                  },
                ),
              ],
            ),
          ),
      ];
    }
  }

  double get blockDensityBreak {
    // var chrSize = widget.trackParams.chr.size;
    // if (chrSize > 100000000) return 5.0;
    // if (chrSize > 50000000) return 5.0;
    // if (chrSize > 10000000) return 5.0;
    // if (chrSize > 5000000) return 5.0;
    // if (chrSize > 1000000) return 5.0;
    // if (chrSize > 100000) return 5.0;
    return 100.0;
  }

  @override
  TrackViewType getTrackViewType([TrackParams? params]) {
    return super.getTrackViewType(params);
    num targetScale = findTargetScale(params);
    if (targetScale < blockVisibleScale) {
      return TrackViewType.cartesian;
    }
    return TrackViewType.feature;
  }

  @override
  DataAdapter getFeatureAdapter([TrackViewType? type]) => EQTLFeatureAdapter(track: trackParams.track);

  @override
  List<SettingItem> getContextMenuList(hitItem) {
    return TrackMenuConfig.eqtlTrackSettings;
  }

  Scale<num, num> get visibleScale {
    var range = widget.range;
    return ScaleLinear.number(
      domain: [range.start, range.end],
      range: [widget.scale[range.start]!, widget.scale[range.end]!],
    );
  }

  @override
  Widget trackWidgetWrapper(Widget child) {
    return GetBuilder(
      tag: trackParams.trackId,
      init: _logic,
      builder: (c) => child,
    );
  }

  List filterData(double? min, double? max) {
    var data = trackData ?? [];
    if (min != null) data = data.where((d) => d['p'] >= min).toList();
    if (max != null) data = data.where((d) => d['p'] <= max).toList();
    return data;
  }

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
    //print('range track view type $viewType ${widget.orientation} scale: ${widget.trackParams.scale}');
    Brightness _brightness = Theme.of(context).brightness;
    bool _dark = _brightness == Brightness.dark;
    Color _primaryColor = Theme.of(context).colorScheme.primary;
    if (viewType == TrackViewType.cartesian) {
      return ZoomSeeTrackPainter(
        visibleRange: widget.range,
        scale: widget.scale,
        orientation: widget.orientation,
        style: Theme.of(context).textTheme.bodySmall!,
        message: 'Zoom in to view eqtl',
        height: 120,
      );
    }
    double? maxValue = customTrackStyle.customMaxValue.enableValueOrNull;
    double? minValue = customTrackStyle.customMinValue.enableValueOrNull;
    return EQTLTrackPainter(
      orientation: widget.orientation!,
      visibleRange: widget.range,
      trackHeight: trackStyle.trackHeight,
      trackData: PositionedData(
        values: transformData<Feature>(filterData(minValue, maxValue)),
        hasRange: true,
        message: 'No data in this range!',
      ),
//      maxHeight: bigWigStyle.trackHeight,
      styleConfig: XYPlotStyleConfig(
        padding: EdgeInsets.only(top: 5, bottom: 5),
        backgroundColor: widget.background ?? Colors.grey[200],
        blockBgColor: _dark ? Colors.grey.withAlpha(50) : Colors.grey.withAlpha(50),
        brightness: _brightness,
        selectedColor: _primaryColor.withAlpha(100),
        primaryColor: trackColor,
        colorMap: colorMap ?? {},
      ),
      scale: widget.scale,
      filterGene: _logic.feature,
      // track: trackParams.track,
      selectedItem: selectedItem,
      // valueScaleType: customTrackStyle.valueScaleType, //use log scale
      radius: (trackStyle.get('radius') ?? 4.0).toDouble(),
      customMaxValue: maxValue,
    );
  }

  @override
  bool onContextMenuItemChanged(SettingItem? p, SettingItem item) {
    bool r = super.onContextMenuItemChanged(p, item);
    if (item.key == TrackContextMenuKey.radius) {
      trackStyle['radius'] = item.value;
      setState(() {});
    }
    return r;
  }

  @override
  bool get showCartesianToolTip => false;

  @override
  void onItemTap(item, Offset offset) {
    PositionDataItem? _item = item;
    if (_item == null) return;
    super.onItemTap(_item.source, offset);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
