import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/mixin/track_data_mixin.dart';
import 'package:flutter_smart_genome/network/adapter/abs_feature_adapter.dart';
import 'package:flutter_smart_genome/network/adapter/bed_feature_adapter.dart';
import 'package:flutter_smart_genome/page/track/theme/gff_style.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/empty_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/bed/bed_style.dart';
import 'package:flutter_smart_genome/widget/track/bed/bed_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/stack_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';
import 'package:dartx/dartx.dart' as cm;
import 'package:get/get.dart';

class BedTrackWidget extends BaseTrackWidget {
  BedTrackWidget({
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
  State<BedTrackWidget> createState() => _BedTrackWidgetState();
}

class _BedTrackWidgetState extends State<BedTrackWidget> with TrackDataMixin {
  @override
  void initState() {
    super.initState();
  }

  init(TrackParams trackParams) {
    super.init(trackParams);
    Map statics = trackParams.track.getStatic(trackParams.chrId);
    cartesianMaxValue = prettyNumber(statics['max_value']) ?? 100;
    if (!customTrackStyle.customMaxValue.enabled) {
      customTrackStyle.customMaxValue = customTrackStyle.customMaxValue.copy(value: cartesianMaxValue);
    }
  }

  @override
  double get blockDensityBreak {
    var chrSize = widget.trackParams.chr.size;
    if (chrSize > 100000000) return 1.65;
    if (chrSize > 50000000) return 2.0;
    if (chrSize > 10000000) return 2.5;
    if (chrSize > 5000000) return 3.0;
    if (chrSize > 1000000) return 3.5;
    if (chrSize > 100000) return 4.0;
    return 5.0;
  }

  @override
  TrackViewType getTrackViewType([TrackParams? params]) {
    TrackParams trackParams = params ?? this.trackParams;
    double _featureScreenDensity = featureScreenDensity(trackParams).toPrecision(2);
    if (_featureScreenDensity > blockDensityBreak) {
      return TrackViewType.cartesian;
    } else if (_featureScreenDensity >= blockDensityBreak / 2) {
      return TrackViewType.block;
    } else {
      return TrackViewType.feature;
    }
    // return super.getTrackViewType(params);
  }

  @override
  Future loadTrackData([bool isRefresh = false]) async {
    TrackViewType _viewType = getTrackViewType();
    if (_viewType == TrackViewType.cartesian) {
      return super.loadBigwigData(isRefresh);
    }
    return super.loadTrackData(isRefresh);
  }

  @override
  void onDataLoaded(List? data) {
    List<BedFeature> _data = data!.cast<BedFeature>();
    for (BedFeature bed in _data) {
      Feature? thick = bed.subFeatures?.firstOrNullWhere((b) => b['view_type'] == 'thick');
      List<Feature>? blocks = bed.subFeatures?.where((b) => b['view_type'] == 'block').toList();
      if (blocks == null || blocks.length == 0) blocks = [bed];
      if (thick != null && blocks.length > 0) {
        List<BedFeature> blockEns = [];
        Range? collade;
        for (var b in blocks) {
          collade = thick.range.intersection(b.range);
          if (collade != null && collade.size > 0) {
            blockEns.add(BedFeature.fromMap({'start': collade.start, 'end': collade.end, 'view_type': BedFeature.ENHANCE_BLOCK_TYPE}, 'bed'));
          }
        }
        if (blockEns.length > 0) bed.subFeatures!.addAll(blockEns);
      }
    }
  }

  @override
  AbsFeatureAdapter getFeatureAdapter([TrackViewType? type]) {
    return BedFeatureAdapter(track: trackParams.track, level: getDataLevel(type ?? viewType!));
  }

  @override
  Range getDataRange() {
    Range visibleRange = widget.range;
    // return visibleRange; //.inflate(visibleRange.size);

    double pageWidth = visibleRange.size;
    int startPage = widget.range.start ~/ pageWidth;

    var start = startPage * pageWidth;
    var end = start + 2 * pageWidth;
    Range dataRange = Range(start: start, end: end);
    return dataRange;
    // w=10, cur 22 - 32
    // page = 22 ~/ 10 = 2
  }

//   @override
//   Future<bool> checkNeedReloadData(BedTrackWidget oldWidget) async {
// //    if (trackData == null || trackData.isEmpty) return true;
// //    return false;
//     if (viewType == TrackViewType.cartesian) {
//       bool reload = !widget.touchScaling || trackData == null || trackData!.isEmpty;
//       // if (reload) cancelToken?.cancel();
//       return reload;
//     }
//     return super.checkNeedReloadData(oldWidget);
//   }

  // List<BedFeature> _data;
  FeatureData<BedFeature> _featureData = FeatureData([]);

  @override
  List<SettingItem> getContextMenuList(hitItem) {
    if (viewType == TrackViewType.cartesian) {
      return [
        if (null != hitItem) TrackMenuConfig.fromKey(TrackContextMenuKey.zoom_to_feature),
        // if (widget.trackParams.pixelPerBp >= forceLoadFeatureMinScale) TrackMenuConfig.fromKey(TrackContextMenuKey.force_load_feature),
        ...TrackMenuConfig.bedCartesianTrackSettings,
      ];
    }
    var settings = TrackMenuConfig.bedFeatureTrackSettings;
    if (settings.firstWhereOrNull((e) => e.key == 'bed_color_map') == null) {
      var colorMapItem = SettingItem.row(key: 'bed_color_map', title: 'Feature Color', children: []);
      settings.insert(2, colorMapItem);
    }
    return settings;
    // return super.getContextMenuList(hitItem);
  }

  @override
  void registerContextMenuSettings(List<SettingItem> settings) {
    super.registerContextMenuSettings(settings);
    var colorMapItem = settings.firstWhereOrNull((e) => e.key == 'bed_color_map');
    var styles = _bedFeatureStyle?.filterKeys((k) => k == 'base' || k == 'block') ?? {};
    var children = styles.keys.map((k) => SettingItem.color(title: '${k}'.capitalizeFirst, key: k, value: styles[k]!.color, fieldType: FieldType.row_color));
    colorMapItem?.children = [...children];
  }

  @override
  Map<String, Color> get colorMap {
    Map<String, Color>? cm = SgsConfigService.get()!.getGroupTrackColorMap(trackParams.track);
    return {
      'bed': cm?['__auto'] ?? customTrackStyle.trackColor ?? trackStyle.trackColor!,
    };
  }

  Map<String, FeatureStyle>? _bedFeatureStyle;

  Map<String, FeatureStyle> get bedFeatureStyle {
    if (null == _bedFeatureStyle) {
      GffStyle gffStyle = getTrackStyle(TrackType.gff) as GffStyle;
      _bedFeatureStyle = {
        ...(trackStyle as BedStyle).featureStyles,
        ...gffStyle.featureStyles,
      };
      Map<String, Color> customColorMap = customTrackStyle.getColorMap('bed_color_map') ?? {};
      for (var entry in customColorMap.entries) {
        _bedFeatureStyle?[entry.key]?.color = entry.value;
      }
    }
    return _bedFeatureStyle!;
  }

  @override
  onThemeChange() {
    _bedFeatureStyle = null;
  }

  @override
  onOtherTrackThemeChange(TrackType trackType) {
    if (trackType == TrackType.gff) {
      _bedFeatureStyle = null;
      setState(() {});
    }
  }

  double _offset = 0;

  @override
  void onScrollCallback(ScrollController controller) {
    super.onScrollCallback(controller);
    _offset = controller.offset;
  }

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
    //print('range track view type $viewType ${widget.orientation} scale: ${widget.trackParams.scale}');
    Brightness _brightness = Theme.of(context).brightness;
    bool _dark = _brightness == Brightness.dark;
    var _primaryColor = Theme.of(context).colorScheme.primary;

    if (viewType == TrackViewType.cartesian) {
      return super.getBigwigTrackPainter();
    }
    if (viewType == TrackViewType.block || viewType == TrackViewType.feature) {
      // if (dataRangeChanged || _data == null) {
      //   _data = transformData<BedFeature>(trackData);
      // }
      int d;
      if (trackData!.length > 5000) {
        d = trackData!.length ~/ 5000;
        _featureData.features = trackData!.filterIndexed((element, i) => i % d == 0).map<BedFeature>((e) => e).toList();
      } else {
        _featureData.features = trackData!.map<BedFeature>((e) => e).toList();
      }
      _featureData.message = loading ? null : 'No feature in this range';
      // logger.d('get painter ${viewType}');
      return BedTrackPainter(
        orientation: widget.orientation,
        visibleRange: widget.range,
        featureHeight: trackStyle.featureHeight ?? 20,
        trackData: _featureData,
        offset: _offset,
        viewHeight: trackMaxHeight,
        // collapseMode: _vcfStyle.trackMode,
        styleConfig: FeatureStyleConfig(
          padding: EdgeInsets.only(top: 5),
          backgroundColor: widget.background ?? Colors.grey[200],
          blockBgColor: trackStyle.featureGroupColor!,
          showLabel: trackStyle.showLabel,
          labelFontSize: trackStyle.fontSize,
          textColor: trackStyle.fontColor,
          groupColor: trackStyle.featureGroupColor,
          featureWidth: 1.0,
          featureStyles: bedFeatureStyle,
          lineColor: _dark ? Colors.grey[500] : Colors.black26.withAlpha(50),
          brightness: _brightness,
          selectedColor: _dark ? Colors.white : _primaryColor.withAlpha(100),
        ),
        scale: widget.scale,
        track: trackParams.track,
        showSubFeature: viewType == TrackViewType.feature,
        //_showLabel(), // size of pixel < 1000
        selectedItem: selectedItem,
        scaling: widget.touchScaling,
      );
    }
    return EmptyTrackPainter(
      scale: widget.scale,
      visibleRange: widget.range,
      orientation: widget.orientation,
      brightness: _brightness,
    );
  }

  @override
  bool onContextMenuItemChanged(SettingItem? p, SettingItem item) {
    return super.onContextMenuItemChanged(p, item);
  }

  @override
  void onMenuChangeCallback(SettingItem? parent, SettingItem item) {
    super.onMenuChangeCallback(parent, item);
    if (parent?.key == 'bed_color_map') {
      _bedFeatureStyle![item.key]!.color = item.value;
    }
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
                  Text('${item.formatKey(key)} ', style: TextStyle(fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK, backgroundColor: colorMap[key])),
                  Text(': ${item.value[key]}',
                      style: TextStyle(
                        fontFamily: MONOSPACED_FONT,
                        fontFamilyFallback: MONOSPACED_FONT_BACK,
                      )),
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
    // _data?.clear();
    // _data = null;
    _featureData.clear();
    _featureData.clear();
  }
}
