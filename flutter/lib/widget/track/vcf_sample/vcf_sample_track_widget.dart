import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/mixin/track_data_mixin.dart';
import 'package:flutter_smart_genome/network/adapter/abs_feature_adapter.dart';
import 'package:flutter_smart_genome/network/adapter/range_feature_adapter.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/empty_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/base/zoom_see_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';
import 'package:flutter_smart_genome/extensions/common_extensions.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';

import 'vcf_sample_feature_layout.dart';
import 'vcf_sample_track_painter.dart';

class VcfSampleTrackWidget extends BaseTrackWidget {
  VcfSampleTrackWidget({
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
        ) {}

  @override
  State<VcfSampleTrackWidget> createState() => _VcfSampleTrackWidgetState();
}

class _VcfSampleTrackWidgetState extends State<VcfSampleTrackWidget> with TrackDataMixin {
  List<RangeFeature>? _data;
  FeatureData _featureData = FeatureData([]);

  @override
  void initState() {
    trackTotalHeight = 22;
    defaultContextStyle..showLabel = true;
    super.initState();
  }

  @override
  void init(TrackParams trackParams) {
    super.init(trackParams);
  }

  @override
  void initVisibleScale(TrackParams trackParams) {
    Map statics = (trackParams.track.parent ?? trackParams.track).getStatic(trackParams.chrId);
    var totalFeatureCount = statics['feature_count'] ?? trackParams.chr.size / 200.0;
    // logger.d('${trackParams.track.trackName} $statics, total feature count ${totalFeatureCount}, chr len: ${trackParams.chr.size}');
    num _avgFeatureLength = statics['average_f_length'] ?? trackParams.chr.size / totalFeatureCount; // (totalFeatureCount * 1.0).clamp(100, 200000); // chrLength / totalFeatureCount;
    // var _visibleScale = (20.0 / _avgFeatureLength);
    blockVisibleScale = (10.0 / _avgFeatureLength).clamp(0.0005, .004);
    // blockVisibleScale = _visibleScale.clamp(0.001, .05);
    // _featureVisibleScale = (1 / (_avgFeatureLength * 1500 / 2000.0)).clamp(0.001, 0.1);

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
  }

  @override
  TrackViewType getTrackViewType([TrackParams? params]) {
    TrackParams trackParams = params ?? this.trackParams;
    // double sizeOfPixel = trackParams.rangePerPixel;
    double targetScale = findTargetScale(trackParams);
    // print('sizeOfPixel: $sizeOfPixel, rangePercent:${targetScale}, chr size:${trackParams.chr.size}');
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
  Widget? buildTrackTitle() {
    return null;
    // return super.buildTrackTitle();
  }

  @override
  AbsFeatureAdapter getFeatureAdapter([TrackViewType? type]) {
    return RangeFeatureAdapter(track: trackParams.track, level: getDataLevel(type ?? viewType!));
  }

  @override
  List<SettingItem> getContextMenuList(hitItem) {
    if (null == hitItem) {
      return TrackMenuConfig.vcfSampleTrackSettings;
    }
    return super.getContextMenuList(hitItem);
  }

  Map<String, FeatureStyle> get vcfFeatureStyle {
    Map<String, Color> _colorMap = trackStyle.colorMap!;
    return _colorMap.map<String, FeatureStyle>((key, value) => MapEntry<String, FeatureStyle>('$key', FeatureStyle(color: value, id: '', name: '')));
  }

  @override
  void registerContextMenuSettings(List<SettingItem> settings) {
    super.registerContextMenuSettings(settings);
    // VcfSampleFeatureLayout featureLayout = TrackLayoutManager().getTrackLayout(trackParams.track);
    // Map codeNameMap = featureLayout.typeCodeMap;
    // SettingItem seqItem = settings.firstOrNullWhere((element) => element.key == TrackContextMenuKey.color_map);
    // Map<String, Color> _colorMap = trackStyle.colorMap;
    // seqItem?.children?.forEach((s) {
    //   s.value = _colorMap['${s.key}'];
    // });
  }

  @override
  List<Widget> buildTitleActions() {
    Map<String, Color> _colorMap = trackStyle.colorMap ?? {};
    return _colorMap.keys
        .map((e) => Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(e, style: TextStyle(color: Colors.white70, fontSize: 12)),
              color: _colorMap[e],
            ))
        .toList();
  }

  bool _showLabel() {
    double targetScale = findTargetScale();
    if (trackParams.chr.size < 60000) {
      return targetScale > 0.1;
    }
    return targetScale > 0.005;
  }

  double _position = 0;

  @override
  void onScrollCallback(ScrollController controller) {
    super.onScrollCallback(controller);
    setState(() {
      _position = controller.offset;
    });
  }

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
    //print('range track view type $viewType ${widget.orientation} scale: ${widget.trackParams.scale}');
    Brightness _brightness = Theme.of(context).brightness;
    bool _dark = _brightness == Brightness.dark;
    if (viewType == TrackViewType.cartesian) {
      _position = 0;
      return ZoomSeeTrackPainter(
        visibleRange: widget.range,
        scale: widget.scale,
        orientation: Axis.horizontal,
        message: 'Zoom in to view vcf samples',
        style: TextStyle(fontSize: 14, color: _dark ? Colors.white : Colors.black87),
      );
    }
    if (viewType == TrackViewType.block || viewType == TrackViewType.feature) {
      if (dataRangeChanged || _data == null) {
        _data = transformData<RangeFeature>(trackData!);
      }
      _featureData.features = _data!;
      _featureData.message = loading ? 'Loading...' : 'No feature in this range';
//      logger.d('get painter ${_data}');
      return VcfSampleTrackPainter(
        orientation: widget.orientation,
        visibleRange: widget.range,
        featureHeight: trackStyle.featureHeight,
        trackHeight: trackMaxHeight,
        trackData: _featureData,
        // collapseMode: trackUIConfigBean.trackMode,
        offset: _position,
        trackHover: mouseInTrack,
        styleConfig: FeatureStyleConfig(
          // padding: EdgeInsets.only(top: 22),
          // backgroundColor: _dark ? Colors.grey[800] : Colors.grey[200],
          blockBgColor: trackStyle.trackColor!,
          showLabel: trackStyle.showLabel,
          labelFontSize: trackStyle.fontSize,
          textColor: trackStyle.fontColor,
          groupColor: trackStyle.featureGroupColor,
          featureWidth: .5,
          featureStyles: vcfFeatureStyle,
          lineColor: _dark ? Colors.grey[100] : Colors.black87,
          brightness: _brightness,
          selectedColor: _dark ? Colors.white : Theme.of(context).colorScheme.primary,
        ),
        scale: widget.scale,
        track: trackParams.track,
        showSampleName: customTrackStyle.showLabel ?? true,
        showSubFeature: _showLabel(),
        // size of pixel < 1000
        labelKey: viewType == TrackViewType.feature ? 'alt_detail' : 'alt_type',
        selectedItem: selectedItem,
      );
    }
    return EmptyTrackPainter(orientation: widget.orientation, brightness: _brightness, visibleRange: widget.range, scale: widget.scale);
  }

  @override
  bool onContextMenuItemChanged(SettingItem? p, SettingItem item) {
    // super.onContextMenuItemChanged(item);
    Map _cm = trackStyle['colorMap'] ?? {};
    VcfSampleFeatureLayout featureLayout = TrackLayoutManager().getTrackLayout(trackParams.track) as VcfSampleFeatureLayout;
    Map codeNameMap = featureLayout.typeCodeMap!;
    String idx = '${codeNameMap[item.key]}';
    if (_cm.keys.contains(idx)) {
      Color _color = item.value;
      _cm[idx] = _color.hexString;
      // trackStyle.setColorMapEntry('${idx}', _color);
      customTrackStyle.setColorMapEntry(idx, _color);
      setState(() {});
    } else {
      return super.onContextMenuItemChanged(p, item);
    }
    return true;
  }

  @override
  void onContextMenuItemTap(SettingItem item, Rect menuRect, [dynamic target]) async {
    super.onContextMenuItemTap(item, menuRect, target);
  }

  @override
  bool showMoreInfo(Feature feature) => false;

  @override
  Feature itemInfoTransform(Feature feature) {
    Map map = feature.toJson();
    Map _map = Map.from(map);
    _map..remove('sample_geno_types');
    return Feature.fromMap(_map, trackParams.trackTypeStr!);
  }

  @override
  Widget? infoRowItemBuilder(BuildContext context, String key, value) {
    if (key == 'statistic') {
      Map _cm = trackStyle.colorMap!;
      VcfSampleFeatureLayout featureLayout = TrackLayoutManager().getTrackLayout(trackParams.track) as VcfSampleFeatureLayout;
      Map codeNameMap = featureLayout.typeCodeMap!;
      Widget _row(key, List items) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                color: _cm['${codeNameMap[key] ?? 0}'],
                child: SizedBox(width: 10, height: 10),
              ),
              Expanded(child: SelectableText(' ${key}')),
              ...items.map((e) => Expanded(child: SelectableText('$e', textAlign: TextAlign.end))),
            ],
          ),
        ).withBottomBorder(color: Theme.of(context).dividerColor);
      }

      if (value is Map) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: value.keys.map((k) => _row(k, value[k])).toList(),
          ),
        );
      }
      return Text('$key: $value');
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    _data?.clear();
    _data = null;
    _featureData.clear();
  }
}
