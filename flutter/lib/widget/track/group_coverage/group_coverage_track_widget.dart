import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/mixin/track_data_mixin.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/base/xy_plot_style_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/group_coverage/group_coverage_track_painter.dart';
import 'package:dartx/dartx.dart' as cm;
import 'package:get/get.dart';

import 'group_coverage_logic.dart';
import 'group_coverage_track_data.dart';

class GroupCoverageTrackWidget extends BaseTrackWidget {
  final ValueChanged<Feature>? onZoomToRange;

  GroupCoverageTrackWidget({
    Key? key,
    required super.site,
    required super.scale,
    required super.trackParams,
    required super.range,
    double? maxHeight,
    super.background,
    super.orientation,
    this.onZoomToRange,
    super.onRemoveTrack,
    super.gestureBuilder,
    super.eventCallback,
    super.touchScaling,
    super.touchScale,
    super.fixTitle,
  }) : super(
          key: key,
          containerHeight: maxHeight,
        );

  @override
  State<GroupCoverageTrackWidget> createState() => _GroupCoverageTrackWidgetState();
}

class _GroupCoverageTrackWidgetState extends State<GroupCoverageTrackWidget> with TrackDataMixin {
  late GroupCoverageLogic _logic;

  @override
  void initState() {
    _logic = Get.put(GroupCoverageLogic(), tag: widget.trackParams.track.parent!.id);

    stackGroup = _logic.categories;
    _logic.groupObs.addListener(_onGroupChange);
    hoverDelay = 0;
    defaultContextStyle..splitChart = true;
    customTrackStyle.splitChart = true;
    // barWidth = 1;
    super.initState();
  }

  void init(TrackParams params) {
    super.init(params);
    _logic.init(widget.trackParams);
    Map statics = trackParams.track.getStatic(trackParams.chrId);
    cartesianMaxValue = prettyNumber(statics['max_value']) ?? 100;
    if (!customTrackStyle.customMaxValue.enabled) {
      customTrackStyle.customMaxValue = customTrackStyle.customMaxValue.copy(value: cartesianMaxValue);
    }
  }

  @override
  void initVisibleScale(TrackParams trackParams) {
    //do nothing
    blockVisibleScale = 1 / 20;
  }

  @override
  TrackViewType getTrackViewType([TrackParams? params]) {
    num targetScale = findTargetScale(params);
    if (targetScale < blockVisibleScale) {
      return TrackViewType.cartesian;
    }
    return TrackViewType.feature;
  }

  List<RangeFeature>? _data;
  GroupCoverageTrackData _featureData = GroupCoverageTrackData(<Map>[]);

  @override
  Future loadTrackData([bool isRefresh = false]) async {
    cancelToken?.cancel();
    await Future.delayed(Duration(milliseconds: 200));

    TrackViewType _viewType = getTrackViewType();
    // if (_viewType == TrackViewType.cartesian) {
    Range _inflateRange = widget.range;
    int _start = _inflateRange.start.toInt(), _end = _inflateRange.end.toInt(), count;

    // _start = widget.range.start.toInt();
    // _end = widget.range.end.toInt();
    count = desiredBarCount();

    trackData = isRefresh || _viewType != viewType ? <Map>[] : trackData;
    selectedItem = isRefresh || _viewType != viewType ? null : selectedItem;
    loading = true;
    setState(() {});
    cancelToken = CancelToken();
    var _data = await loadGroupCoverageData<Map>(
      host: widget.site.url,
      speciesId: trackParams.speciesId,
      track: trackParams.track,
      chr: trackParams.chrId,
      level: getDataLevel(_viewType),
      start: _start,
      end: _end,
      count: count,
      blockMap: _viewType == TrackViewType.cartesian ? cartesianBlockMap! : calculateExpandsBlockMap(_start, _end),
      groupName: _logic.currentGroup,
      cancelToken: cancelToken,
      valueType: trackStyle.cartesianValueType,
    );
    if (_viewType == TrackViewType.cartesian) {
      if (_data.length > 0) {
        Map? firstValue = _data.first['value'];
        if (null != firstValue) stackGroup = firstValue.keys.map<String>((e) => '$e').toList();
      }
    } else {
      stackGroup = _data.map<String>((e) => e['group']).toList();
    }
    if (!mounted) return;
    setState(() {
      loading = false;
      error = null;
      if (_viewType != viewType) trackTotalHeight = 0;
      trackData = _data;
      viewType = _viewType;
      cancelToken = null;
    });
    notifyDataViewer();
    // } else {
    //   return super.loadTrackData(isRefresh);
    // }
  }

  @override
  List<SettingItem> getContextMenuList(hitItem) {
    return TrackMenuConfig.groupCoverageTrackSettings;
//    if (null == hitItem) {
//      return TrackMenuConfig.bigWigTrackSettings;
//    }
    //return super.getContextMenuList(hitItem);
  }

  @override
  void registerContextMenuSettings(List<SettingItem> settings) {
    super.registerContextMenuSettings(settings);
    // SettingItem valueScaleItem = settings.firstOrNullWhere((element) => element.key == TrackContextMenuKey.value_scale_type);
    // valueScaleItem?.value = _valueScaleType;
  }

  @override
  List<Widget> buildTitleActions() {
    return [
      SizedBox(width: 10),
      Builder(builder: (c) {
        return OutlinedButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 4),
            elevation: 0,
          ),
          onPressed: () => showGroupDialog(c),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Color By: ${_logic.currentGroup}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300)),
              Icon(Icons.arrow_drop_down, size: 16),
            ],
          ),
        );
      }),
      // ...super.buildTitleActions(),
    ];
  }

  Track get track => widget.trackParams.track;

  void showGroupDialog(BuildContext c) {
    showAttachedWidget(
        targetContext: c,
        preferDirection: PreferDirection.bottomLeft,
        attachedBuilder: (c) {
          Iterable<Widget> children = _logic.matrix!.groups.map((e) {
            return RadioListTile<String>(
              value: e,
              title: Text(e),
              groupValue: _logic.currentGroup,
              contentPadding: EdgeInsets.symmetric(horizontal: 4),
              dense: true,
              onChanged: (e) {
                c.call();
                onColorByGroupChange(e!);
              },
            );
          });
          double height = children.length * 50.0;
          if (height > 200) height = 200;
          return Material(
            elevation: 6,
            color: Theme.of(context).dialogBackgroundColor,
            shape: modelShape(),
            child: Container(
              constraints: BoxConstraints(minHeight: height, maxHeight: height, maxWidth: 200, minWidth: 100),
              child: ListView(
                itemExtent: 50,
                padding: EdgeInsets.zero,
                children: ListTile.divideTiles(tiles: children, context: context).toList(),
              ),
            ),
          );
        });
  }

  @override
  Future<bool> checkNeedReloadData(GroupCoverageTrackWidget oldWidget) async {
//    if (trackData == null || trackData.isEmpty) return true;
//    return false;
    bool reload = widget.range != oldWidget.range || trackData == null || trackData!.isEmpty;
    // if (reload) cancelToken?.cancel();
    return reload;
    // return super.checkNeedReloadData();
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
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
    //print('range track view type $viewType ${widget.orientation} scale: ${widget.trackParams.scale}');
    Brightness _brightness = Theme.of(context).brightness;
    bool _dark = _brightness == Brightness.dark;
    Color _primaryColor = Theme.of(context).primaryColor;
    double? maxValue = trackStyle.customMaxValue.enableValueOrNull;

    if (viewType == TrackViewType.cartesian) {
      return super.getBigwigTrackPainter();
    }

    _featureData.groupData = trackData as List<Map>;
//    logger.d('get painter ${dataRangeChanged} ${selectedItem?.hashCode}');
    return GroupCoverageTrackPainter(
      orientation: widget.orientation,
      visibleRange: widget.range,
      trackHeight: trackStyle.trackHeight * (stackGroup?.length ?? 1),
      // : trackStyle.trackHeight,
      trackData: _featureData,
      // collapseMode: trackUIConfigBean.trackMode,
//      maxHeight: bigWigStyle.trackHeight,
//       densityMode: trackStyle.densityMode,
      styleConfig: XYPlotStyleConfig(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        backgroundColor: widget.background ?? Colors.grey[200],
        blockBgColor: _dark ? Colors.grey.withAlpha(50) : Colors.grey.withAlpha(50),
        brightness: _brightness,
        selectedColor: _primaryColor.withAlpha(50),
        primaryColor: _primaryColor,
        colorMap: colorMap,
      ),
      splitMode: true,
      scale: widget.scale,
      track: trackParams.track,
      showSubFeature: trackParams.bpPerPixel < 120,
      // size of pixel < 1000
      selectedItem: selectedItem,
      cartesianType: viewType == TrackViewType.cartesian,
      valueScaleType: trackStyle.valueScaleType,
      customMaxValue: maxValue,
    );
  }

  @override
  bool onContextMenuItemChanged(SettingItem? p, SettingItem item) {
    //super.onContextMenuItemChanged(item);
    return super.onContextMenuItemChanged(p, item);
  }

  List exportData() {
    if (viewType == TrackViewType.cartesian) {
      return trackData!.map((map) {
        Map value = map['value'];
        return {...map, ...value}..remove('value');
      }).toList();
    }
    return trackData!.flatMap((group) {
      List list = group['data'];
      return list.map((e) => {'group': group['group'], ...e.json});
    }).toList();
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
    _data?.clear();
    _data = null;
    _featureData.clear();
  }

  void _onGroupChange() {
    onColorByGroupChange(_logic.groupObs.value, true);
  }

  void onColorByGroupChange(String group, [bool fromToolbar = false]) {
    _logic.currentGroup = group;
    _logic.clearData();
    stackGroup = _logic.categories;
    _logic.update();
    loadTrackData(true).catchError((e) {
      print(e);
    });
  }
}
