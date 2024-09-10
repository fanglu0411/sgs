import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/chart/scale/value_sale_type.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/mixin/track_data_mixin.dart';
import 'package:flutter_smart_genome/network/adapter/data_adapter.dart';
import 'package:flutter_smart_genome/network/adapter/methylation_feature_adapter.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/base/xy_plot_style_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/methylation/methylation_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'package:dartx/dartx.dart' as cm;

class MethylationTrackWidget extends BaseTrackWidget {
  MethylationTrackWidget({
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
  State<MethylationTrackWidget> createState() => _MethylationTrackWidgetState();
}

class _MethylationTrackWidgetState extends State<MethylationTrackWidget> with TrackDataMixin {
  List<RangeFeature>? _data;
  StackMode _stackMode = StackMode.stack;

  @override
  void initState() {
    hoverDelay = 0;
    barCoverageKey = 'deeps';
    barWidth = 1;
    super.initState();
  }

  void init(TrackParams trackParams) {
    defaultContextStyle
      ..valueScaleType = ValueScaleType.LINEAR
      ..cartesianValueType = 'max';
    super.init(trackParams);
    Map statics = trackParams.track.getStatic(trackParams.chrId);
    cartesianMaxValue = prettyNumber(statics['max_value']) ?? 1.0;
    if (!customTrackStyle.customMaxValue.enabled) {
      customTrackStyle.customMaxValue = customTrackStyle.customMaxValue.copy(value: cartesianMaxValue);
    }
  }

  @override
  void initVisibleScale(TrackParams trackParams) {
    blockVisibleScale = 1 / 100;
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
    // TrackViewType _viewType = getTrackViewType();
    // if (_viewType == TrackViewType.cartesian) {
    return super.loadBigwigData(isRefresh);
    // }
  }

  @override
  DataAdapter getFeatureAdapter([TrackViewType? type]) => MethylationFeatureAdapter(track: trackParams.track);

  @override
  List<SettingItem> getContextMenuList(hitItem) {
    var settings = TrackMenuConfig.methyTrackSettings;
    if (viewType == TrackViewType.feature) {
      settings = settings.where((s) => s.key != TrackContextMenuKey.stack_chart_split && s.key != TrackContextMenuKey.stack_mode).toList();
    }
    return settings;
  }

  @override
  Future<bool> dataBlockChange(MethylationTrackWidget oldWidget, TrackViewType viewTypeNew) {
    return Future.value(oldWidget.range != widget.range);
  }

  Scale<num, num> get visibleScale {
    var range = widget.range;
    return ScaleLinear.number(
      domain: [range.start, range.end],
      range: [widget.scale[range.start]!, widget.scale[range.end]!],
    );
  }

  Range get inflateRange => widget.range.inflate(widget.range.size * .1);

  @override
  AbstractTrackPainter<TrackData, StyleConfig>? getForegroundPainter() {
    return null;
  }

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
    //print('range track view type $viewType ${widget.orientation} scale: ${widget.trackParams.scale}');
    Brightness _brightness = Theme.of(context).brightness;
    bool _dark = _brightness == Brightness.dark;
    Color _primaryColor = Theme.of(context).colorScheme.primary;

    double? maxValue = trackStyle.customMaxValue.enableValueOrNull;
    if (viewType == TrackViewType.cartesian) {
      return super.getBigwigTrackPainter(
        useSameScale: false,
        coverageType: CartesianChartType.linear,
        stackMode: _stackMode,
      );
    }

    if (dataRangeChanged || _data == null || _data!.length == 0) {
      _data = transformData<RangeFeature>(trackData!);
    }
//    logger.d('get painter ${dataRangeChanged} ${selectedItem?.hashCode}');
    return MethylationTrackPainter(
      orientation: widget.orientation,
      visibleRange: widget.range,
      trackHeight: trackStyle.trackHeight,
      trackData: FeatureData(_data!, track: trackParams.track),
      // collapseMode: trackUIConfigBean.trackMode,
//      maxHeight: bigWigStyle.trackHeight,
//       densityMode: trackStyle.densityMode,
      styleConfig: XYPlotStyleConfig(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        backgroundColor: widget.background ?? Colors.grey[200],
        blockBgColor: _dark ? Colors.grey.withAlpha(50) : Colors.grey.withAlpha(50),
        brightness: _brightness,
        primaryColor: _primaryColor,
        selectedColor: Theme.of(context).colorScheme.primary.withAlpha(50),
        colorMap: colorMap,
      ),
      scale: widget.scale,
      track: trackParams.track,
      showSubFeature: trackParams.bpPerPixel < 120,
      // size of pixel < 1000
      selectedItem: selectedItem,
      cartesianType: true,
      valueScaleType: trackStyle.valueScaleType,
      customMaxValue: maxValue,
    );
  }

  @override
  bool onContextMenuItemChanged(SettingItem? p, SettingItem item) {
    return super.onContextMenuItemChanged(p, item);
  }

  @override
  void onMenuChangeCallback(SettingItem? parent, SettingItem item) {
    super.onMenuChangeCallback(parent, item);
    if (item.key == TrackContextMenuKey.stack_mode) {
      _stackMode = item.value;
    }
  }

  @override
  List<D> transformData<D>(List data) {
    if (TrackViewType.cartesian == viewType) {
      data = data
          .flatMap((e) => [
                {
                  'start': e['start'],
                  'end': e['end'],
                  'strand': 1,
                  'value': e['pValue'],
                },
                {
                  'start': e['start'],
                  'end': e['end'],
                  'strand': -1,
                  'value': e['nValue'],
                },
              ])
          .toList();
    }
    return super.transformData(data);
  }

  @override
  bool get showCartesianToolTip => false;
}
