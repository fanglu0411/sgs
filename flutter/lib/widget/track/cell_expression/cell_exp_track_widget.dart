import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/mixin/track_data_mixin.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/legends/ordinal_legends_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/empty_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/base/zoom_see_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cell_expression/cell_exp_style_config.dart';
import 'package:flutter_smart_genome/widget/track/cell_expression/cell_exp_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';
import 'package:get/get.dart';

import 'cell_exp_logic.dart';

class CellExpTrackWidget extends BaseTrackWidget {
  CellExpTrackWidget({
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
  State<CellExpTrackWidget> createState() => _CellExpTrackWidgetState();
}

class _CellExpTrackWidgetState extends State<CellExpTrackWidget> with TrackDataMixin {
  late CellExpLogic logic;

  @override
  void initState() {
    logic = Get.put(CellExpLogic(), tag: widget.trackParams.track.parent!.id);
    logic.groupObs.addListener(_onGroupChange);
    super.initState();
  }

  @override
  void init(TrackParams params) {
    super.init(params);
    logic.init(params);
  }

  @override
  void initVisibleScale(TrackParams trackParams) {
    //do in logic.init
  }

  @override
  TrackViewType getTrackViewType([TrackParams? params]) {
    TrackParams trackParams = params ?? this.trackParams;
    double sizeOfPixel = trackParams.bpPerPixel;
    double targetScale = findTargetScale(trackParams);
    // logger.d('rangeOfPixel: $sizeOfPixel,pixOfSeq:${trackParams.pixelOfSeq}, targetScale:${targetScale}, _featureVisibleScale: $_featureVisibleScale');
    if (trackParams.chr.size <= 60000) {
      if (targetScale == trackParams.zoomConfig.zoomLevels.first) {
        return TrackViewType.block;
      }
      return TrackViewType.feature;
    }

    if (targetScale >= logic.featureVisibleScale) {
      return TrackViewType.feature;
    }
    if (targetScale >= logic.featureVisibleScale / 5) {
      return TrackViewType.block;
    }
    return TrackViewType.cartesian;
  }

  void _onGroupChange() {
    onColorByGroupChange(logic.groupObs.value, true);
  }

  Track get track => widget.trackParams.track;

  @override
  Widget trackWidgetWrapper(Widget child) {
    var _child = GetBuilder(
      init: logic,
      tag: trackParams.trackId,
      builder: (logic) => child,
    );
    return super.trackWidgetWrapper(_child);
  }

  @override
  void checkDidUpdateWidget(CellExpTrackWidget oldWidget) {
    viewType = getTrackViewType(widget.trackParams);
    super.checkDidUpdateWidget(oldWidget);
  }

  @override
  List<SettingItem> getContextMenuList(hitItem) {
    if (hitItem == null) return TrackMenuConfig.cellExpTrackSettings;
    return TrackMenuConfig.rangeSettings;
  }

  @override
  Widget? buildLegendWidget() {
    if (viewType == TrackViewType.cartesian) return null;
    if (!trackStyle.showLegends || colorMap.length == 0) return null;
    Map<String, FeatureStyle> featureStyles = colorMap.map((key, value) => MapEntry(key, FeatureStyle(color: value, name: '', id: '')));
    return Material(
      child: OrdinalLegendsWidget(
        featureHeight: 20,
        featureStyles: featureStyles,
      ),
    );
  }

  @override
  List<Widget> buildTitleActions() {
    if (viewType == TrackViewType.cartesian) return [];
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
              Text('Color By: ${logic.currentGroup}', style: TextStyle(fontSize: 13)),
              Icon(Icons.arrow_drop_down, size: 16),
            ],
          ),
        );
      }),
      SizedBox(width: 10),
      Tooltip(
        message: logic.hideNone ? 'Show all gene' : 'Hide none expression gene',
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size(30, 22),
          ),
          child: Icon(logic.hideNone ? Icons.filter_alt : Icons.filter_alt_outlined, size: 14),
          onPressed: () {
            setState(() {
              logic.hideNone = !logic.hideNone;
              if (!logic.hideNone) TrackLayoutManager.clear(trackParams.track);
            });
          },
        ),
      ),
      SizedBox(width: 10),
      Tooltip(
        message: trackStyle.showLegends ? 'Hide Legends' : 'Show Legends',
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size(30, 22),
          ),
          child: Icon(trackStyle.showLegends ? Icons.legend_toggle : Icons.legend_toggle, size: 14),
          onPressed: () {
            setState(() {
              trackStyle.showLegends = !trackStyle.showLegends;
            });
          },
        ),
      ),
    ];
    // return super.buildTitleActions();
  }

  void showGroupDialog(BuildContext c) {
    showAttachedWidget(
        targetContext: c,
        preferDirection: PreferDirection.bottomLeft,
        attachedBuilder: (c) {
          MatrixBean matrix = track.matrixList!.first;
          Iterable<Widget> children = matrix.groups.map((e) {
            return RadioListTile<String>(
              value: e,
              title: Text(e),
              groupValue: logic.currentGroup,
              contentPadding: EdgeInsets.symmetric(horizontal: 4),
              dense: true,
              onChanged: (e) {
                c.call();
                onColorByGroupChange(e!);
              },
            );
          });
          double height = children.length * 50.0;
          if (height >= 200) height = 200;
          return Material(
            elevation: 6,
            color: Theme.of(context).dialogBackgroundColor,
            shape: modelShape(),
            child: Container(
              constraints: BoxConstraints(minHeight: height, maxHeight: height, maxWidth: 200, minWidth: 100),
              child: ListView(
                itemExtent: 50,
                children: ListTile.divideTiles(tiles: children, context: context).toList(),
              ),
            ),
          );
        });
  }

  void onColorByGroupChange(String group, [bool fromToolbar = false]) {
    logic.currentGroup = group;
    logic.clearData();
    logic.update();
    loadTrackData(true).catchError((e) {
      print(e);
    });
    // if (!fromToolbar) CellPageLogic.safe()!.changeGroup(group, trackId: trackParams.trackId);
  }

  @override
  Future<bool> checkNeedReloadData(CellExpTrackWidget oldWidget) async {
    TrackViewType _viewType = getTrackViewType();
    if (_viewType == TrackViewType.cartesian) {
      trackData = [];
      error = null;
      loading = false;
      return false;
    }
    return super.checkNeedReloadData(oldWidget);
  }

  @override
  Future loadTrackData([bool isRefresh = false]) async {
    TrackViewType _viewType = getTrackViewType();
    if (_viewType == TrackViewType.cartesian) {
      viewType = _viewType;
      loading = false;
      error = null;
      trackData = [];
      setState(() {});
      // return super.loadBigwigData(isRefresh);
    } else {
      return super.loadTrackData(isRefresh);
    }
  }

  @override
  Future<HttpResponseBean<List>> dataApi(CancelToken cancelToken, TrackViewType _viewType, Set<String> _featureTypes) async {
    return loadCellExpData(
      host: widget.site.url,
      track: trackParams.track,
      chrId: trackParams.chrId,
      range: widget.range,
      groupName: logic.currentGroup,
      cancelToken: cancelToken,
    );
  }

  @override
  Map<String, Color> get colorMap {
    return logic.colorMap!;
    // Map<String, Color> _colorMap = trackStyle.colorMap;
    // List categories = track.cellGroup[logic.currentGroup];
    // if (_colorMap == null || !listEquals(_colorMap.keys.toList(), categories)) {
    //   List<Color> colors = safeSchemeColor(categories.length, s: .8, v: .65);
    //   Map<String, Color> _defColorMap = categories.asMap().map<String, Color>((idx, key) {
    //     return MapEntry(key, colors[idx]);
    //   });
    //   trackStyle.colorMap = _defColorMap;
    //   customTrackStyle.colorMap = _defColorMap;
    // }
    // return trackStyle.colorMap?.map((key, value) => MapEntry('${key}', value));
  }

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
//    print('range track view type $viewType ${widget.orientation} scale: ${widget.trackParams.scale}');
//    double targetScale = findTargetScale(trackParams.pixelOfRange, trackParams.zoomConfig.zoomLevels.reversed.toList());
    Brightness _brightness = Theme.of(context).brightness;
    bool _dark = _brightness == Brightness.dark;
    trackStyle..brightness = _brightness;
    Color _primaryColor = Theme.of(context).colorScheme.primary;
    if (viewType == TrackViewType.cartesian) {
      return ZoomSeeTrackPainter(
        scale: widget.scale,
        visibleRange: widget.range,
        message: 'Zoom in to view expressions',
        style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 14, fontWeight: FontWeight.w300),
        height: 60,
      );
    }
    if (viewType == TrackViewType.block || viewType == TrackViewType.feature) {
      if (dataRangeChanged || logic.dataEmpty) {
//        selectedItem = null;
        logic.data = transformData<CellExpFeature>(trackData ?? []);
      }
      logic.featureData..features = logic.data;
      logic.featureData.message = loading ? 'Loading...' : 'No Data in this range';
      //logger.d('get painter ${dataRangeChanged} ${selectedItem?.hashCode}');
      return CellExpTrackPainter(
        orientation: widget.orientation,
        visibleRange: widget.range,
        featureHeight: trackStyle.featureHeight,
        trackData: logic.featureData,
        collapseMode: trackStyle.collapseMode,
        styleConfig: CellExpStyleConfig(
          padding: EdgeInsets.only(top: 5),
          backgroundColor: widget.background ?? Colors.grey[200],
          // blockBgColor: trackStyle.trackColor,
          showLabel: trackStyle.showLabel,
          labelFontSize: trackStyle.fontSize,
          labelColor: trackStyle.fontColor!,
          primaryColor: _primaryColor,
          colorMap: colorMap,
          brightness: _brightness,
          selectedColor: _dark ? Colors.white : Theme.of(context).colorScheme.primary,
          barWidth: trackStyle['bar_width'],
        ),
        categories: logic.matrix!.getClusters(logic.currentGroup),
        scale: widget.scale,
        track: trackParams.track,
        showSubFeature: true,
        // size of pixel < 1500
        selectedItem: selectedItem,
      );
    }
    return EmptyTrackPainter(
      scale: widget.scale,
      visibleRange: widget.range,
      orientation: widget.orientation,
      brightness: _brightness,
      label: loading ? '' : "",
    );
  }

  @override
  void onItemTap(item, Offset offset) {
    // super.onItemTap(item, offset);
    if (item == null) return;
    CellExpFeature feature = item;
    CellPageLogic.safe()?.onTapFeature(feature.name);
  }

  @override
  void onContextMenuItemTap(SettingItem item, Rect menuRect, [dynamic target]) async {
    if (item.key == TrackContextMenuKey.efp) {
      Navigator.of(context).pushNamed(RoutePath.efp);
    } else {
      super.onContextMenuItemTap(item, menuRect, target);
    }
  }

  @override
  Feature itemInfoTransform(Feature feature) {
    List values = feature['exp_value'];

    Map _map = Map.from(feature.json);
    _map.remove('exp_value');
    Map exp = Map.fromIterables(logic.categories, values);
    _map['exp_value'] = exp;
    return Feature.fromMap(_map, feature.trackType!);
  }

  @override
  bool get showCartesianToolTip => false;

  @override
  void dispose() {
    Get.delete<CellExpLogic>();
    super.dispose();
  }
}
