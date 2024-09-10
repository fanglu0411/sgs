import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/mixin/track_data_mixin.dart';
import 'package:flutter_smart_genome/network/adapter/abs_feature_adapter.dart';
import 'package:flutter_smart_genome/network/adapter/bam_reads_feature_adapter.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/track/bam_reads/reads_view_options.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/base/zoom_see_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/common.dart' as cm;
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';

import 'bam_reads_track_painter.dart';

class BamReadsTrackWidget extends BaseTrackWidget {
  BamReadsTrackWidget({
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
  State<BamReadsTrackWidget> createState() => _BamReadsTrackWidgetState();
}

class _BamReadsTrackWidgetState extends State<BamReadsTrackWidget> with TrackDataMixin {
  List<BamReadsFeature>? _data;
  bool _paired = false;
  late Debounce _debounce;
  CancelFunc? _subMenu;

  late List<SettingItem> _colorByItems;
  late List<SettingItem> _filterByItems;
  late List<SettingItem> _sortByItems;
  late List<SettingItem> _groupByItems;

  late ReadsColorOption _colorByOption;
  late ReadsSortOption _sortByOption;
  late ReadsGroupOption _groupByOption;
  List<ReadsFilterOption> _readsFilters = [];

  @override
  void initState() {
    hoverDelay = 0;
    trackTotalHeight = 0;
    _debounce = Debounce(milliseconds: 5000);
    _colorByOption = ReadsColorOption.strand_default;
    _sortByOption = ReadsSortOption.start_location;
    _groupByOption = ReadsGroupOption.strand;

    _colorByItems = colorByMenus(checkedOption: _colorByOption);
    _filterByItems = filterByMenus(checked: _readsFilters);
    _sortByItems = sortByMenus(checkedOption: _sortByOption);
    _groupByItems = groupByMenus(checkedOption: _groupByOption);

    super.initState();
  }

  @override
  void initVisibleScale(TrackParams trackParams) {
    Map statics = trackParams.track.getStatic(trackParams.chrId);
    var totalFeatureCount = statics['feature_count'] ?? trackParams.chr.size / 1000.0;
    num avgLength = trackParams.chr.size / totalFeatureCount;
    blockVisibleScale = (1 / (avgLength * 2000 / 500)).clamp(0.001, 0.02);
    logger.d('static ${statics}, chr len: ${trackParams.chr.size}, _featureVisibleScale: $blockVisibleScale');
  }

  @override
  TrackViewType getTrackViewType([TrackParams? params]) {
    num targetScale = findTargetScale(params ?? widget.trackParams);
    if (targetScale >= .5) {
      return TrackViewType.feature;
    } else if (targetScale >= blockVisibleScale) {
      return TrackViewType.feature;
    }
    return TrackViewType.cartesian;
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
      return super.loadTrackData(isRefresh);
    }
  }

  @override
  void onDataLoaded(List? data) {
    if (data != null) _filterAndSort(data: data);
  }

  void _filterAndSort({required List data, bool loading = false}) {
    if (loading) {
      this.loading = true;
      setState(() {});
    }
    if (dataRangeChanged || _data == null || _data!.length == 0) {
      _data = transformData<BamReadsFeature>(data);
    }

    List<BamReadsFeature>? __data = _data;
    if (_readsFilters.length > 0) {
      //todo do filters
      // __data = _data.filter((f) => _readsFilters.contains(f.flag));
    }

    __data = __data!
        .sortedBy(readsSortFunctions[_sortByOption]!)
        .thenBy((e) => e.range.start) //
        .toList();
    // __data.sort(readsSortFunctions[_sortByOption]);

    _featureData.features = __data;
    if (loading) {
      this.loading = false;
    }
    TrackLayoutManager.clear(trackParams.track);
    setState(() {});
  }

  @override
  AbsFeatureAdapter getFeatureAdapter([TrackViewType? type]) => BamReadsFeatureAdapter(track: trackParams.track);

  int getDataLevel(TrackViewType viewType) {
    return viewType.index + 1;
  }

  @override
  List<SettingItem> getContextMenuList(hitItem) {
    return [
      if (null != hitItem) TrackMenuConfig.fromKey(TrackContextMenuKey.zoom_to_feature),
      if (widget.trackParams.pixelPerBp >= forceLoadFeatureMinScale) TrackMenuConfig.fromKey(TrackContextMenuKey.force_load_feature),
      ...TrackMenuConfig.bamReadsTrackSettings,
    ];
  }

  @override
  void registerContextMenuSettings(List<SettingItem> settings) {
    super.registerContextMenuSettings(settings);
    SettingItem? pairedItem = settings.firstOrNullWhere((element) => element.key == TrackContextMenuKey.bam_view_as);
    pairedItem?.value = _paired;
  }

  @override
  List<Widget> buildTitleActions() {
    // return super.buildTitleActions();
    return [
      Builder(builder: (context) {
        return Tooltip(
          message: 'Color by',
          child: MaterialButton(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Icon(MaterialCommunityIcons.draw, size: 16),
            minWidth: 22,
            hoverColor: Theme.of(context).colorScheme.primary.withOpacity(.3),
            onPressed: () {
              _showReadsOptionMenu(context, _colorByItems);
            },
          ),
        );
      }),
      Builder(builder: (context) {
        return Tooltip(
          message: 'Filter by',
          child: MaterialButton(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Icon(MaterialCommunityIcons.filter, size: 16),
            minWidth: 32,
            hoverColor: Theme.of(context).colorScheme.primary.withOpacity(.3),
            onPressed: () {
              _showReadsOptionMenu(context, _filterByItems);
            },
          ),
        );
      }),
      Builder(builder: (context) {
        return Tooltip(
          message: 'Sort by',
          child: MaterialButton(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(MaterialCommunityIcons.sort, size: 16),
            minWidth: 32,
            hoverColor: Theme.of(context).colorScheme.primary.withOpacity(.3),
            onPressed: () {
              _showReadsOptionMenu(context, _sortByItems);
            },
          ),
        );
      }),
      Builder(builder: (context) {
        return Tooltip(
          message: 'Group by',
          child: MaterialButton(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Icon(MaterialCommunityIcons.menu, size: 16),
            minWidth: 32,
            hoverColor: Theme.of(context).colorScheme.primary.withOpacity(.3),
            onPressed: () {
              _showReadsOptionMenu(context, _groupByItems);
            },
          ),
        );
      }),
      // Builder(builder: (context) {
      //   return Tooltip(
      //     message: 'Sort by',
      //     child: MaterialButton(
      //       padding: EdgeInsets.symmetric(horizontal: 0),
      //       child: Icon(MaterialCommunityIcons.sort, size: 16),
      //       minWidth: 22,
      //       hoverColor: Theme.of(context).colorScheme.primary.withOpacity(.3),
      //       onPressed: () {
      //         _showReadsOptionMenu(context, sortByMenus());
      //       },
      //     ),
      //   );
      // }),
    ];
  }

  void _showReadsOptionMenu(BuildContext context, List<SettingItem> items, [Rect? targetRect]) {
    if (_subMenu != null) {
      _subMenu?.call();
      _subMenu = null;
    }
    _subMenu = showAttachedWidget(
      targetContext: targetRect != null ? null : context,
      target: targetRect?.topRight,
      preferDirection: targetRect == null ? PreferDirection.bottomLeft : PreferDirection.rightTop,
      backgroundColor: targetRect == null ? menuBackgroundColor : Colors.transparent,
      attachedBuilder: (c) {
        return Material(
          color: Theme.of(context).dialogBackgroundColor,
          shape: modelShape(),
          elevation: 6,
          child: Container(
            constraints: BoxConstraints.tightFor(width: 360),
            child: SettingListWidget(
              settings: items,
              onItemChanged: _onSubMenuItemChanged,
              onItemHover: _onSubmenuHover,
            ),
          ),
        );
      },
    );
    _delayHideSubMenu();
  }

  void _onSubMenuItemChanged(SettingItem? p, SettingItem item) {
    _delayHideSubMenu();
    if (item.key is ReadsFilterOption) {
      _readsFilters = _filterByItems.where((e) => e.value).map<ReadsFilterOption>((e) => e.key).toList();
      //todo filter data
      _filterAndSort(data: trackData ?? [], loading: true);
      return;
    } else if (item.key == TrackContextMenuKey.bam_color_by) {
      _colorByOption = item.value;
      setState(() {});
    } else if (item.key == TrackContextMenuKey.bam_sort_by) {
      _sortByOption = item.value;
      _filterAndSort(data: trackData ?? [], loading: true);
    } else if (item.key == TrackContextMenuKey.bam_group_by) {
      //
    }
    _subMenu?.call();
  }

  _onSubmenuHover(SettingItem item, bool enter, Rect? menuRect) {
    if (enter) _delayHideSubMenu();
  }

  // @override
  // Future<bool> checkNeedReloadData(BamReadsTrackWidget oldWidget) async {
  //   return super.checkNeedReloadData(oldWidget);
  // }

  cm.Range get inflateRange => widget.range.inflate(widget.range.size * .1);

  Map<String, FeatureStyle> get bamReadsFeatureStyle {
    String key = _colorByOption.toString().split('.').last;
    Map<String, Color> _colorMap = trackStyle.getColorMap('color_map_$key') ?? {};
    return {
      ..._colorMap,
      ...(getTrackStyle(TrackType.ref_seq).colorMap ?? {}),
      'background': trackStyle.trackColor,
    }.map<String, FeatureStyle>((key, value) => MapEntry<String, FeatureStyle>(key, FeatureStyle(color: value, name: key, id: key)));
  }

  FeatureData<BamReadsFeature> _featureData = FeatureData([]);

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
    // print('range track view type $viewType ${widget.orientation} scale: ${widget.trackParams.pixelOfSeq}, _featureVisibleScale: $_featureVisibleScale');
    Brightness _brightness = Theme.of(context).brightness;
    bool _dark = _brightness == Brightness.dark;

    if (viewType == TrackViewType.cartesian) {
      return ZoomSeeTrackPainter(
        scale: widget.scale,
        visibleRange: widget.range,
        orientation: Axis.horizontal,
        message: 'zoom in to view reads',
        style: Theme.of(context).textTheme.bodyMedium!,
      );
    }
    // logger.d('get painter ${dataRangeChanged} ${selectedItem?.hashCode}');
    return BamReadsTrackPainter(
      orientation: widget.orientation,
      visibleRange: widget.range,
      trackHeight: trackStyle.featureHeight,
      trackData: _featureData,
      // collapseMode: trackUIConfigBean.trackMode,
//      maxHeight: bigWigStyle.trackHeight,
      styleConfig: FeatureStyleConfig(
        padding: EdgeInsets.only(top: 5),
        backgroundColor: widget.background ?? Colors.grey[200],
        blockBgColor: trackStyle.trackColor!,
        showLabel: trackStyle.showLabel,
        labelFontSize: trackStyle.fontSize,
        textColor: trackStyle.fontColor,
        groupColor: trackStyle.featureGroupColor,
        featureWidth: .5,
        featureStyles: bamReadsFeatureStyle,
        lineColor: _dark ? Colors.grey[500] : Colors.black26.withAlpha(50),
        brightness: _brightness,
        selectedColor: _dark ? Colors.white : Theme.of(context).colorScheme.primary.withAlpha(100),
      ),

      scale: widget.scale,
      track: trackParams.track..paired = _paired,
      showSubFeature: trackParams.pixelPerBp >= .5,
      // size of pixel < 1000
      selectedItem: selectedItem,
      paired: _paired,
      scaling: widget.touchScaling,
      colorOption: _colorByOption,
    );
  }

  void _delayHideSubMenu() {
    _debounce.run(() {
      _subMenu?.call();
      _subMenu = null;
    });
  }

  @override
  void onContextMenuItemHover(SettingItem item, bool enter, Rect? menuRect) {
    if (!enter) {
      _delayHideSubMenu();
      return;
    }
    if (item.key == TrackContextMenuKey.bam_color_by) {
      _showReadsOptionMenu(context, _colorByItems, menuRect);
    } else if (item.key == TrackContextMenuKey.bam_sort_by) {
      _showReadsOptionMenu(context, _sortByItems, menuRect);
    } else if (item.key == TrackContextMenuKey.bam_filter_by) {
      _showReadsOptionMenu(context, _filterByItems, menuRect);
    }
  }

  @override
  bool onContextMenuItemChanged(SettingItem? p, SettingItem item) {
    //super.onContextMenuItemChanged(item);
    if (item.key == TrackContextMenuKey.bam_view_as) {
      _paired = item.value;
      TrackLayoutManager.clear(trackParams.track);
      trackTotalHeight = 0;
      setState(() {});
    } //
    else {
      super.onContextMenuItemChanged(p, item);
    }
    return true;
  }

  @override
  void dispose() {
    super.dispose();
    _data?.clear();
    _data = null;
    _featureData.clear();
  }
}
