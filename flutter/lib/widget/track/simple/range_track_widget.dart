import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/gene.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/mixin/track_data_mixin.dart';
import 'package:flutter_smart_genome/network/adapter/abs_feature_adapter.dart';
import 'package:flutter_smart_genome/network/adapter/gff_feature_adapter.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container_logic.dart';
import 'package:flutter_smart_genome/page/track/theme/gff_style.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/legends/ordinal_legends_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/empty_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';
import 'package:flutter_smart_genome/widget/track/simple/range_track_painter.dart';

class RangeTrackWidget extends BaseTrackWidget {
  RangeTrackWidget({
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
  State<RangeTrackWidget> createState() => _RangeTrackWidgetState();
}

class _RangeTrackWidgetState extends State<RangeTrackWidget> with TrackDataMixin {
  List<GffFeature>? _data;
  FeatureData<GffFeature> _featureData = FeatureData([]);

  @override
  void initState() {
    // barWidth = 2;
    defaultContextStyle..cartesianValueType = 'sum'; //??
    super.initState();
  }

  init(TrackParams trackParams) {
    super.init(trackParams);
    Map statics = trackParams.track.getStatic(trackParams.chrId);
    // final avgSize = trackParams.chr.size / statics['feature_count'];
    cartesianMaxValue = prettyNumber(statics['max_value']) ?? 100;
    if (!customTrackStyle.customMaxValue.enabled) {
      customTrackStyle.customMaxValue = customTrackStyle.customMaxValue.copy(value: cartesianMaxValue);
    }
  }

  @override
  List<SettingItem> getContextMenuList(hitItem) {
    if (viewType == TrackViewType.cartesian) {
      return [
        if (null != hitItem) TrackMenuConfig.fromKey(TrackContextMenuKey.zoom_to_feature),
        if (widget.trackParams.pixelPerBp >= forceLoadFeatureMinScale) TrackMenuConfig.fromKey(TrackContextMenuKey.force_load_feature),
        ...TrackMenuConfig.cartesianTrackSettings,
      ];
    }

    if (hitItem == null) return TrackMenuConfig.rangeTrackSettings;
    Feature feature = hitItem;
    if (feature is GffFeature) {
      if (feature.type == 'gene') {
        return TrackMenuConfig.geneSettings;
      }
      return TrackMenuConfig.rangeSettings;
    }

    return super.getContextMenuList(hitItem);
  }

  @override
  void registerContextMenuSettings(List<SettingItem> settings) {
    super.registerContextMenuSettings(settings);
  }

  @override
  bool onContextMenuItemChanged(SettingItem? p, SettingItem item) {
    if (item.key == TrackContextMenuKey.histogram_scale) {
      //   _featureVisibleScale = 1.0 / item.value;
    } else {
      super.onContextMenuItemChanged(p, item);
    }
    return true;
  }

  @override
  void onMenuChangeCallback(SettingItem? parent, SettingItem item) {
    super.onMenuChangeCallback(parent, item);
  }

  @override
  Widget? buildLegendWidget() {
    GffStyle _trackStyle = trackStyle as GffStyle;
    if (_trackStyle.showLegends || customTrackStyle.showLegends) {
      return Material(
        child: OrdinalLegendsWidget(
          featureHeight: _trackStyle.featureHeight ?? 20,
          featureStyles: _trackStyle.featureStyles ?? {},
        ),
      );
    }
    return null;
  }

  // @override
  // Future<bool> checkNeedReloadData(RangeTrackWidget oldWidget) async {
  //   if (viewType == TrackViewType.cartesian) {
  //     bool reload = !widget.touchScaling || trackData == null || trackData!.isEmpty;
  //     return reload;
  //   }
  //   return super.checkNeedReloadData(oldWidget);
  // }

  @override
  Future loadTrackData([bool isRefresh = false]) async {
    TrackViewType _viewType = getTrackViewType();
    if (_viewType == TrackViewType.cartesian) {
      return super.loadBigwigData(isRefresh);
    } else {
      return super.loadTrackData(isRefresh);
    }
  }

  @override
  Range getDataRange() {
    Range visibleRange = widget.range;
    double pageWidth = visibleRange.size;
    int startPage = widget.range.start ~/ pageWidth;

    Range dataRange = Range(start: startPage * pageWidth, end: startPage * pageWidth + 2 * pageWidth);
    return dataRange;
    // w=10, cur 22 - 32
    // page = 22 ~/ 10 = 2
  }

  @override
  AbsFeatureAdapter getFeatureAdapter([TrackViewType? type]) {
    return GffFeatureAdapter(track: trackParams.track, level: getDataLevel(type ?? viewType!));
  }

  @override
  Map<String, Color> get colorMap {
    Map<String, Color>? cm = SgsConfigService.get()!.getGroupTrackColorMap(trackParams.track);
    return {
      'count': cm?['__auto'] ?? customTrackStyle.trackColor ?? trackStyle.trackColor!,
    };
  }

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
//    print('range track view type $viewType ${widget.orientation} scale: ${widget.trackParams.scale}');
//    double targetScale = findTargetScale(trackParams.pixelOfRange, trackParams.zoomConfig.zoomLevels.reversed.toList());
    Brightness _brightness = Theme.of(context).brightness;
    bool _dark = _brightness == Brightness.dark;
    trackStyle..brightness = _brightness;
    if (viewType == TrackViewType.cartesian) {
      return super.getBigwigTrackPainter();
    }
    if (viewType == TrackViewType.block || viewType == TrackViewType.feature) {
      if (dataRangeChanged || _data == null) {
//        selectedItem = null;
        _data = transformData<GffFeature>(trackData ?? []);
      }
      _featureData..features = _data as List<GffFeature>;
      _featureData.message = loading ? 'Loading...' : 'No Data in this range';
      //logger.d('get painter ${dataRangeChanged} ${selectedItem?.hashCode}');
      return RangeTrackPainter(
        orientation: widget.orientation,
        visibleRange: widget.range,
        trackHeight: trackStyle.featureHeight,
        trackData: _featureData,
        collapseMode: trackStyle.collapseMode,
        styleConfig: FeatureStyleConfig(
          padding: EdgeInsets.only(top: 5),
          backgroundColor: widget.background ?? Colors.grey[200],
          blockBgColor: trackStyle.trackColor!,
          showLabel: trackStyle.showLabel,
          showChildrenLabel: customTrackStyle.showChildLabel,
          labelFontSize: trackStyle.fontSize,
          textColor: trackStyle.fontColor,
          groupColor: trackStyle.featureGroupColor,
          featureWidth: .5,
          //featureStyles: FeatureStyleConfig.generateFeatureStyles(['${trackParams.trackType}']),
          featureStyles: (trackStyle as GffStyle).featureStyles,
          lineColor: _dark ? Colors.grey[500] : Colors.black26.withAlpha(100),
          brightness: _brightness,
          selectedColor: _dark ? Colors.white : Theme.of(context).colorScheme.primary.withAlpha(180),
        ),
        scale: widget.scale,
        track: trackParams.track,
        showSubFeature: TrackViewType.feature == viewType,
        // size of pixel < 1500
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
  void onContextMenuItemTap(SettingItem item, Rect menuRect, [dynamic target]) async {
    if (item.key == TrackContextMenuKey.efp) {
      Navigator.of(context).pushNamed(RoutePath.efp);
    } else if (item.key == TrackContextMenuKey.gene_info) {
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
    } else if (item.key == TrackContextMenuKey.search_in_sc) {
      if (null != target && target is Feature) {
        if (!(TrackContainerLogic.safe()?.sideOpened(SideModel.cell) ?? false)) {
          showToast(text: 'Please open sc view panel!');
        } else if (CellPageLogic.safe()?.track == null) {
          showToast(text: 'Please select sc data source!');
        } else {
          CellPageLogic.safe()?.searchFeatureFromGff(target.name);
        }
      } else {
        showToast(text: 'Target is transcript, not gene!');
      }
    } else {
      super.onContextMenuItemTap(item, menuRect, target);
    }
  }

  @override
  bool get showCartesianToolTip => false;

  @override
  void dispose() {
    super.dispose();
    _data?.clear();
    _data = null;
    _featureData.clear();
  }
}
