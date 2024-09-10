import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/mixin/track_data_mixin.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/empty_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

class GroupedTrackWidget extends BaseTrackWidget {
  final ValueChanged<Feature>? onZoomToRange;

  GroupedTrackWidget({
    Key? key,
    required super.site,
    required super.scale,
    required super.trackParams,
    required super.range,
    super.background,
    super.orientation,
    this.onZoomToRange,
    super.onRemoveTrack,
    super.gestureBuilder,
    super.eventCallback,
    super.touchScaling,
    super.touchScale,
    super.fixTitle,
    double? maxHeight,
  }) : super(
          key: key,
          containerHeight: maxHeight,
        );

  @override
  State<GroupedTrackWidget> createState() => _GroupedTrackWidgetState();
}

class _GroupedTrackWidgetState extends State<GroupedTrackWidget> with TrackDataMixin {
  @override
  void checkDidUpdateWidget(GroupedTrackWidget oldWidget) {
    // super.checkDidUpdateWidget(oldWidget);
    // do nothing
  }

  @override
  void initState() {
    hoverDelay = 0;
    super.initState();
  }

  @override
  void initVisibleScale(TrackParams trackParams) {
    //do nothing
  }

  @override
  Future loadTrackData([bool isRefresh = false]) async {
    //do nothing
  }

  @override
  List<SettingItem> getContextMenuList(hitItem) {
    return TrackMenuConfig.rootTrackSettings;
//    if (null == hitItem) {
//      return TrackMenuConfig.bigWigTrackSettings;
//    }
    return super.getContextMenuList(hitItem);
  }

  @override
  void registerContextMenuSettings(List<SettingItem> settings) {
    super.registerContextMenuSettings(settings);
    // SettingItem valueScaleItem = settings.firstOrNullWhere((element) => element.key == TrackContextMenuKey.value_scale_type);
    // valueScaleItem?.value = _valueScaleType;
  }

  @override
  TrackViewType getTrackViewType([TrackParams? params]) {
//    double _sale = 1 / (trackParams.pixelOfRange / TrackUIConfig.MIN_SEQ_SIZE);
    num targetScale = findTargetScale(params);
    if (targetScale < 1 / 20) {
      return TrackViewType.cartesian;
    }
    return TrackViewType.feature;
  }

  @override
  List<Widget> buildTitleActions() {
    return [
      ...super.buildTitleActions(),
    ];
  }

  @override
  bool needLoadData() => false;

  @override
  Future<bool> checkNeedReloadData(GroupedTrackWidget oldWidget) async {
    return false;
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
  Widget? buildTrackOverlay() {
    return null;
  }

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
    // Brightness _brightness = Theme.of(context).brightness;
    // bool _dark = _brightness == Brightness.dark;
    Color _primaryColor = Theme.of(context).colorScheme.primary;

    return EmptyTrackPainter(
      scale: widget.scale,
      orientation: widget.orientation,
      visibleRange: widget.range,
      label: '',
    );
  }

  @override
  bool onContextMenuItemChanged(SettingItem? p, SettingItem item) {
    //super.onContextMenuItemChanged(item);
    return super.onContextMenuItemChanged(p, item);
  }

  @override
  bool get showCartesianToolTip => false;

  @override
  void onItemTap(item, Offset offset) {
    if (item is CartesianDataItem) {
      super.onItemTap(item, offset);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
