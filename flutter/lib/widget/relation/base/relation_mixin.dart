import 'dart:math' show max, pow;
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart' show CancelToken;
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bloc/sgs_context/sgs_browse_logic.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/components/range_info_widget.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/d3/color/schemes.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container_logic.dart';
import 'package:flutter_smart_genome/page/track/feature_search_widget.dart';
import 'package:flutter_smart_genome/page/track/track_title_widget.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/side/data_viewer_side.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/util/widget_util.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/relation/base/base_relation_widget.dart';
import 'package:flutter_smart_genome/widget/relation/base/relation_params.dart';
import 'package:flutter_smart_genome/widget/sider/horizontal_sider.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_theme.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:dartx/dartx.dart' as dx;
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';

mixin RelationMixin<T extends BaseRelationWidget> on State<T> {
  late RelationParams relationParams;
  bool _loading = false;
  String? _error;
  List? _trackData;

  late GlobalKey _paintKey;
  late GlobalKey _repaintBoundaryKey;

  Scale<num, num>? _linearScale;

  TrackViewType? viewType;

  double trackTotalHeight = 50;

  double get trackMaxHeight => trackStyle.trackMaxHeight.enableValueOrNull ?? 0;

  late Debounce dataDebounce;
  late Debounce _hoverDebounce;
  late Debounce _mouseScrollDebounce;

  int hoverDelay = 0;

  Map<String, Range>? _fileMap;
  MapEntry<Range, List<String>>? _seqRangeFileEntry;

  List<String> featureTypes = [];

  /// 一个柱的像素宽度
  double barWidth = 2;

  ///一个block表示的图像宽度
  double blockPixels = 2048;

  Offset? _mousePosition;

  CancelFunc? _simpleInfoCancel;

  Scale<num, num>? get linearScale => _linearScale;

  set linearScale(Scale<num, num>? linearScale) {
    _linearScale = linearScale;
  }

  List? get trackData => _trackData;

  set trackData(List? data) => _trackData = data;

  bool get loading => _loading;

  set loading(bool loading) => _loading = loading;

  set error(String? error) => _error = error;

  bool dataRangeChanged = false;

  ScrollController? _scrollController;
  bool mouseInTrack = false;

  GestureDetector? gestureCallback;

  GlobalKey<TrackTitleWidgetState> _trackTitleKey = GlobalKey<TrackTitleWidgetState>();
  CancelToken? cancelToken;

  bool focused = false;
  double cartesianMaxValue = 100;
  Map? cartesianBlockMap;

  bool _splitChart = false;

  bool get splitChart => _splitChart;
  String? barCoverageKey = null;
  List<String>? _stackGroup;
  String cartesianValueType = 'sum';

  List<String>? get stackGroup => _stackGroup;

  TrackTheme get trackTheme {
    return SgsBrowseLogic.safe()!.trackTheme!..brightness = Get.theme.brightness;
  }

  /// track 样式配置 合并自定义配置后的结果
  TrackStyle? _trackStyle;

  //获取当前track样式，合并后的结果
  TrackStyle get trackStyle {
    if (null == _trackStyle) {
      var globalTrackStyleCopy = trackTheme.getTrackStyle(widget.track.trackType).copy();
      globalTrackStyleCopy.merge(customTrackStyle);
      _trackStyle = globalTrackStyleCopy;
    }
    return _trackStyle!;
  }

  TrackStyle get customTrackStyle => SgsConfigService.get()!.getCustomTrackStyle(widget.track)..brightness = Theme.of(context).brightness;

  TrackStyle getTrackStyle(TrackType trackType) {
    return trackTheme.getTrackStyle(trackType);
  }

  Map<String, Color>? get colorMap {
    if (_stackGroup != null) {
      Map<String, Color>? _colorMap = trackStyle.colorMap;
      if (_colorMap == null || !listEquals(_colorMap.keys.toList(), _stackGroup)) {
        List<Color> colors = safeSchemeColor(_stackGroup!.length, s: .8, v: .65);
        Map<String, Color> _defColorMap = Map.fromIterables(_stackGroup!, colors);
        // _stackGroup!.asMap().map<String, Color>((idx, key) {
        //   return MapEntry(key, colors[idx]);
        // });
        trackStyle.colorMap = {..._defColorMap, ...(_colorMap ?? {})};
        trackTheme.setTrackStyle(widget.track.trackType, trackStyle);
        // BlocProvider.of<SgsContextBloc>(context).setTrackTheme(trackTheme);
        SgsBrowseLogic.safe()?.changeTheme(trackTheme, TrackType.interactive, false);
      }
    }
    return trackStyle.colorMap?.map((key, value) => MapEntry('${key}', value));
  }

  bool needLoadData() => true;

  void debounceCheckNeedLoadData() {
    dataDebounce.run(() {
      checkNeedReloadData().then((value) {
        dataRangeChanged = value;
        // logger.d('${widget.track.trackName} need load data ${value}');
        if (value && mounted) {
          loadTrackData(false).catchError(_onLoadDataError);
        } else {}
      });
    });
  }

  Future<bool> checkNeedReloadData() async {
    if (!relationParams.prepared) return false;
    if (_trackData == null || _trackData!.isEmpty) return true;

    if (widget.touchScaling) return false;

    if (_loading) {
      cancelToken?.cancel('user interrupt');
      cancelToken = null;
      // _loading = false;
      _fileMap = {};
      return true;
    }
    return false;
  }

  void debouncedLoadTrackData([bool isRefresh = false]) {
    dataDebounce.run(() {
      loadTrackData(isRefresh).catchError(_onLoadDataError);
    });
  }

  notifyDataViewer({bool needToggle = false, bool expanded = false}) {
    if (needToggle) {
      // BlocProvider.of<SgsContextBloc>(context).add(SgsContextToggleSideEvent(SideModel.data, expanded));
      TrackContainerLogic.safe()?.setSide(SideModel.data, expanded);
    }
    if (SgsConfigService.get()!.dataActiveTrack?.id == widget.track.id) {
      // BlocProvider.of<SgsContextBloc>(context).add(SgsContextDataViewEvent(_trackData));
      DataViewerLogic.safe()?.setData(_trackData, track: widget.track);
    }
  }

  Future loadTrackData([bool isRefresh = false]) async {}

  List<String> parseFeatureTypes(List data) => [];

  Map calculateBlockMap([RelationParams params]);

  List<D> transformData<D>(List data) {
    return data.map<D>(dataItemMapper).toList();
  }

  D dataItemMapper<D>(var item) => item;

  @override
  void initState() {
    _paintKey = GlobalKey();
    _repaintBoundaryKey = GlobalKey();
    dataDebounce = Debounce(milliseconds: 300);
    relationParams = widget.relationParams;
    _hoverDebounce = Debounce(milliseconds: hoverDelay);
    _mouseScrollDebounce = Debounce(milliseconds: 100);
    SgsBrowseLogic.safe()?.themeChangeObserver.addListener(_onThemeChange);
    super.initState();
    _scrollController = ScrollController();
    _scrollController!.addListener(() {
      onScrollCallback(_scrollController!);
    });
    cartesianBlockMap = calculateBlockMap(relationParams);
    checkNeedReloadData().then((v) {
      if (v) loadTrackData(true).catchError(_onLoadDataError);
    });
  }

  _onThemeChange() {
    var s = SgsBrowseLogic.safe()!.themeChangeObserver.value!;
    if (s.trackType == null || s.trackType == widget.track.trackType) {
      var __trackStyle = s.trackTheme!.getTrackStyle(widget.track.trackType).copy();
      __trackStyle.merge(customTrackStyle);
      _trackStyle = __trackStyle;
      // _trackStyle.merge(__trackStyle);
      // clearCustomTrackStyle();
      setState(() {});
    }
  }

  void _onLoadDataError(e) {
    logger.e('load track data error: $e');
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = '$e';
    });
  }

  void onScrollCallback(ScrollController controller) {}

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    checkDidUpdateWidget(oldWidget);
  }

  void checkDidUpdateWidget(T oldWidget) {
    // TrackViewType _type = getTrackViewType(widget.relationParams);
    if (widget.relationParams.zoomConfig2 == null || relationParams.zoomConfig2 == null) return;
    if (!widget.touchScaling && findTargetScale() != findTargetScale(widget.relationParams)) {
      cartesianBlockMap = calculateBlockMap(widget.relationParams);
    }

    if (relationParams != widget.relationParams || oldWidget.touchScaling != widget.touchScaling) {
      relationParams = widget.relationParams;
      debounceCheckNeedLoadData();
    }
  }

  @override
  void dispose() {
    SgsBrowseLogic.safe()?.themeChangeObserver.removeListener(_onThemeChange);
    _scrollController?.dispose();
    dataDebounce.dispose();
    _mouseScrollDebounce.dispose();
    BotToast.cleanAll();
    super.dispose();
  }

  Widget? buildTrackOverlay() {
    if (widget.touchScaling) return null;
    if (_loading || _error != null) {
      Widget _child;
      if (_error != null) {
        _child = Text(_error!);
      } else
      //if ((_trackData == null || _loading))
      {
        _child = CustomSpin(color: Theme.of(context).colorScheme.primary);
      }
      return Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.symmetric(vertical: 20),
        // color: Colors.black12.withAlpha(5),
        child: _child,
      );
    }
    return null;
  }

  Widget? _checkInitWidget() {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    trackStyle..brightness = Theme.of(context).brightness; //ensure track style init
    Widget _widget = _checkInitWidget() ?? _buildPaint();
    Widget? legendWidget = buildLegendWidget();
    var children = [_widget, if (legendWidget != null) legendWidget];
    Widget _trackWidget = children.length > 1 ? Column(mainAxisSize: MainAxisSize.min, children: children) : children.first;
    double _maxHeight = widget.containerHeight ?? trackMaxHeight;

    _trackWidget = trackWidgetWrapper(_trackWidget);
    // return _trackWidget;
    Widget? title = buildTrackTitle();
    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: Container(
        child: null == title ? _trackWidget : Stack(children: [_trackWidget, title]),
      ),
    );
  }

  Widget? buildLegendWidget() => null;

  Widget trackWidgetWrapper(Widget child) {
    return child;
    // return BlocListener<SgsContextBloc, SgsContextState>(
    //   listenWhen: (p, c) => c is SgsContextFeatureThemeChangeState,
    //   listener: (p, c) {
    //     SgsContextFeatureThemeChangeState s = c;
    //     if (s.trackType == null || s.trackType == widget.track.trackType) {
    //       var __trackStyle = s.trackTheme.getTrackStyle(widget.track.trackType).copy();
    //       __trackStyle.merge(customTrackStyle);
    //       _trackStyle = __trackStyle;
    //       // _trackStyle.merge(__trackStyle);
    //       // clearCustomTrackStyle();
    //       setState(() {});
    //     }
    //   },
    //   child: child,
    // );
  }

  void _checkHover(PointerHoverEvent event) {
    mouseInTrack = true;
    _run() {
      RenderBox box = _paintKey.currentContext!.findRenderObject() as RenderBox;
      final _mousePosition = box.globalToLocal(event.position);

      final result = BoxHitTestResult();
      //if no hit, cant return false,
      bool hit = box.hitTest(result, position: _mousePosition); //tap down already hit test

      RenderCustomPaint _customPaint = box as RenderCustomPaint;
      AbstractTrackPainter _painter = _customPaint.painter as AbstractTrackPainter;
      var _selectedItem = _painter.hitItem;
      if (selectedItem != _selectedItem) {
        //print('hover ${_mousePosition} ${selectedItem?.hashCode} ?= ${_selectedItem?.hashCode}');
        selectedItem = _selectedItem;
        _cursor = _selectedItem != null ? SystemMouseCursors.click : SystemMouseCursors.basic;
        setState(() {});
      }
      // onItemTap(selectedItem, event.position);
    }

    if (viewType == TrackViewType.cartesian || hoverDelay == 0) {
      _run();
    } else {
      _hoverDebounce.run(_run);
    }
  }

  Widget? buildTrackTitle() {
    List<Widget> _leftItems = [
      MaterialButton(
        minWidth: 22,
        child: Icon(Icons.close, size: 14),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        color: Theme.of(context).colorScheme.primary.withAlpha(20),
        focusColor: Theme.of(context).colorScheme.primary.withAlpha(200),
        hoverColor: Theme.of(context).colorScheme.primary.withAlpha(200),
        splashColor: Theme.of(context).colorScheme.primary.withAlpha(200),
        elevation: 0,
        highlightElevation: 0,
        focusElevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        onPressed: () => widget.eventCallback?.call('hideTrack', widget.track),
      ).tooltip(' Hide Track '),
      Builder(
        builder: (context) {
          return MaterialButton(
            minWidth: 40,
            elevation: 0,
            highlightElevation: 0,
            focusElevation: 0,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            color: Theme.of(context).colorScheme.primary.withAlpha(20),
            focusColor: Theme.of(context).colorScheme.primary.withAlpha(200),
            hoverColor: Theme.of(context).colorScheme.primary.withAlpha(200),
            splashColor: Theme.of(context).colorScheme.primary.withAlpha(200),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.track.trackName}',
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w200),
                ),
                Icon(Icons.keyboard_arrow_down, size: 14),
                SizedBox(width: 4),
              ],
            ),
            onPressed: () {
              showTrackContextMenu(targetContext: context, preferDirection: PreferDirection.rightTop);
            },
          );
        },
      ),
    ];
    return Container(
      constraints: BoxConstraints.tightFor(height: TRACK_TITLE_HEIGHT),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(15)),
            clipBehavior: Clip.antiAlias,
            child: Row(mainAxisSize: MainAxisSize.min, children: _leftItems),
          ),
          ...buildTitleActions(),
          if (_loading)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: CustomSpin(color: Theme.of(context).colorScheme.primary),
            ),
//          Spacer(),
//          if (!isMobile(context)) ...buildTitleActions(),
        ],
      ),
    );
  }

  List<Widget> buildTitleActions() {
    if (viewType == TrackViewType.cartesian) {
      Map<String, Color> _colorMap = colorMap ?? {};
      return _colorMap.keys
          .where((k) => _stackGroup == null || _stackGroup!.contains(k))
          .map((e) => Container(
                padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                child: Text(e, style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w300)),
                color: _colorMap[e],
              ))
          .toList();
    }
    return [
//      Builder(builder: (context) {
//        return IconButton(
//          padding: EdgeInsets.symmetric(horizontal: 0),
//          iconSize: 16,
//          icon: Icon(MaterialCommunityIcons.settings),
//          tooltip: 'More settings',
//          onPressed: () {
//            showTrackContextMenu(targetContext: context, preferDirection: PreferDirection.bottomLeft);
//          },
//        );
//      }),
    ];
  }

  dynamic selectedItem;

  Widget _buildPaint() {
    var painter = getTrackPainter();
    double _trackTotalHeight = painter.maxHeight ?? trackStyle.trackHeight;
    _trackTotalHeight = max(_trackTotalHeight, widget.containerHeight ?? 0);
    // print('${widget.track.trackName} _h: ${_trackTotalHeight}, h: ${trackTotalHeight}');
    trackTotalHeight = max(trackTotalHeight, _trackTotalHeight);
    // }

    var constraints = widget.orientation == Axis.horizontal
        ? BoxConstraints.expand(height: trackTotalHeight) //
        : BoxConstraints.expand(width: trackTotalHeight);
    Widget _widget = Listener(
      onPointerSignal: _onPointerSignal,
      child: GestureDetector(
        trackpadScrollCausesScale: true,
        onLongPressStart: mobilePlatform() ? _onTrackLongPressOrSecondaryPress : null,
        onSecondaryTapUp: mobilePlatform() ? null : _onTrackLongPressOrSecondaryPress,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        // onDoubleTap: widget.gestureBuilder?.onDoubleTap,
        // onTap: widget.gestureBuilder?.onTap,
        // onTapDown: widget.gestureBuilder?.onTapDown,
        onTapUp: (details) {
          //not use
          RenderBox box = _paintKey.currentContext!.findRenderObject() as RenderBox;
          //final offset = box.globalToLocal(details.globalPosition);
          final result = BoxHitTestResult();
          // if no hit, cant return false,
          bool hit = box.hitTest(result, position: details.localPosition); //tap down already hit test

          RenderCustomPaint _customPaint = box as RenderCustomPaint;
          AbstractTrackPainter _painter = _customPaint.painter as AbstractTrackPainter;
          var _selectedItem = _painter.hitItem;
          // print('tap up ${details.localPosition} ${selectedItem?.hashCode} ?= ${_selectedItem?.hashCode} ${_painter.hitRect}');
          if (selectedItem != _selectedItem) {
            selectedItem = _selectedItem;
            setState(() {});
          }
          if (_selectedItem == null) focused = !focused;
          Offset targetPosition = _painter.hitRect != null ? box.localToGlobal(_painter.hitRect!.topCenter) : details.globalPosition;
          onItemTap(selectedItem, targetPosition);
        },
        child: ClipRect(
          child: Container(
            constraints: constraints,
            color: widget.background,
            child: CustomPaint(
              painter: painter,
              foregroundPainter: getForegroundPainter(),
              key: _paintKey,
              child: buildTrackOverlay(),
            ),
          ),
        ),
      ),
    );
    _widget = MouseRegion(
      cursor: selectedItem != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: _widget,
      onHover: _checkHover,
      onExit: (v) {
        selectedItem = null;
        mouseInTrack = false;
        setState(() {});
      },
    );
    return _widget;
  }

  // mouse scroll event
  void _onPointerSignal(s) {
    if (s is PointerScrollEvent) {
      Offset scrollOffset = s.scrollDelta;
      GestureDetector? _gestureBuilder = getGestureDetector(s.localPosition.dy);
      if (_gestureBuilder == null) return;

      if (!_mouseScrollStarted) {
        var startDetails = ScaleStartDetails(
          focalPoint: s.position,
          localFocalPoint: s.localPosition,
        );
        _gestureBuilder.onScaleStart?.call(startDetails);
      }
      _mouseScrollStarted = true;

      final double scaleChange = 1.0 - s.scrollDelta.dy / 1000.0;
      var updateDetails = ScaleUpdateDetails(
        focalPoint: s.position,
        localFocalPoint: s.localPosition,
        rotation: 0.0,
        scale: scaleChange,
        horizontalScale: 1.0,
        verticalScale: 1.0,
      );
      _gestureBuilder.onScaleUpdate?.call(updateDetails);
      _mouseScrollDebounce?.run(_finishMouseScroll, milliseconds: 100);
    }
  }

  GestureDetector? getGestureDetector(double dy) {
    var _height = trackStyle.trackHeight;
    if (dy <= 40 + 20) {
      _lastGesture = 1;
      return widget.gestureBuilder;
    } else if (dy >= _height - 60) {
      _lastGesture = 2;
      return widget.gestureBuilder2;
    }
    _lastGesture = 0;
    return null;
  }

  int _lastGesture = 1;

  void _onScaleStart(ScaleStartDetails details) {
    getGestureDetector(details.localFocalPoint.dy)?.onScaleStart?.call(details);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    getGestureDetector(details.localFocalPoint.dy)?.onScaleUpdate?.call(details);
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_lastGesture == 1) {
      widget.gestureBuilder?.onScaleEnd?.call(details);
    } else if (_lastGesture == 2) {
      widget.gestureBuilder2?.onScaleEnd?.call(details);
    }
  }

  bool _mouseScrollStarted = false;

  void _finishMouseScroll() {
    _onScaleEnd(ScaleEndDetails());
    _mouseScrollStarted = false;
  }

  SystemMouseCursor _cursor = SystemMouseCursors.basic;

  void onItemTap(dynamic item, Offset offset) {
    _simpleInfoCancel?.call();
    if (item is CartesianDataItem) {
      if (!showCartesianToolTip) return;
      _simpleInfoCancel = showAttachedWidget(
        preferDirection: PreferDirection.topCenter,
        target: offset + Offset(0, -10),
        attachedBuilder: (cancel) {
          return Material(
            elevation: 6,
            shape: modelShape(),
            child: tooltipBuilder(context, item, cancel),
          );
        },
      );
    }
  }

  Widget itemInfoWidgetBuilder(BuildContext context, Feature feature, [cancel]) {
    return Container(
      constraints: BoxConstraints.tightFor(width: 340),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showMoreInfo(feature))
              ListTile(
                title: Text('${feature.name}'),
                trailing: IconButton(
                  icon: Icon(Icons.chevron_right),
                  // tooltip: 'More detail',
                  onPressed: () {
                    if (cancel != null) {
                      cancel();
                    } else {
                      Navigator.of(context).pop();
                    }
                    onContextMenuItemTap(SettingItem.button(key: TrackContextMenuKey.range_info), Rect.zero, feature);
                  },
                ),
              ),
            MapInfoWidget(
              data: itemInfoTransform(feature).json,
              itemBuilder: infoRowItemBuilder,
              skipKeys: ['view_type', 'attributes', 'sub_feature', 'children', 'desc'],
              simple: true,
            ),
          ],
        ),
      ),
    );
  }

  bool showMoreInfo(Feature feature) => feature.name != 'null';

  Widget? infoRowItemBuilder(BuildContext context, String key, value) => null;

  bool get showCartesianToolTip => true;

  Widget tooltipBuilder(BuildContext context, item, cancel) {
    if (item is CartesianDataItem) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Text('${item.tooltip}', style: TextStyle(fontFamily: 'Courier New')),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Text('${item}', style: TextStyle(fontFamily: 'Courier New')),
    );
  }

  Feature itemInfoTransform(Feature feature) {
    return feature;
  }

  AbstractTrackPainter? findTrackPainter() {
    RenderBox? box = _paintKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    RenderCustomPaint _customPaint = box as RenderCustomPaint;
    return _customPaint.painter as AbstractTrackPainter;
  }

  void _onTrackLongPressOrSecondaryPress(details) {
    if (widget.touchScaling) return;
    RenderBox box = _paintKey.currentContext!.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.globalPosition);
    final result = BoxHitTestResult();
//        RenderCustomPaint _customPaint = box as RenderCustomPaint;
    bool hit = box.hitTest(result, position: offset);
    RenderCustomPaint _customPaint = box as RenderCustomPaint;
    AbstractTrackPainter painter = _customPaint.painter as AbstractTrackPainter;
    var _selectedItem = painter.hitItem;
    if (isMobile(context)) {
      showTrackContextMenu(
        target: details.globalPosition,
        hitItem: _selectedItem,
        preferDirection: PreferDirection.rightCenter,
      );
    } else {
      showTrackContextMenu(target: details.globalPosition, hitItem: _selectedItem);
    }
  }

  Widget? buildLabel() {
    if (portrait(context)) return null;
    Widget label = Text('${widget.track.trackName}');
    if (!isMobile(context)) {
      return Material(
        color: Theme.of(context).canvasColor.withAlpha(180),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: label,
        ),
      );
    }

    return Builder(
      builder: (context) {
        return Material(
          color: Theme.of(context).canvasColor.withAlpha(180),
          child: InkWell(
            onTap: () => showTrackContextMenu(
              targetContext: context,
              preferDirection: PreferDirection.bottomCenter,
              hitItem: null,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: label,
            ),
          ),
        );
      },
    );
  }

  void showTrackContextMenu({
    Offset? target,
    BuildContext? targetContext,
    var hitItem,
    PreferDirection preferDirection = PreferDirection.rightTop,
  }) async {
    List<SettingItem> menuList = getContextMenuList(hitItem);
    registerContextMenuSettings(menuList);

    bool _mobile = isMobile(context);
    bool _landscape = smallLandscape(context);
    Widget _contentWidget([cancel]) {
      return SettingListWidget(
        settings: menuList,
        onItemChanged: onContextMenuItemChanged,
        onItemTap: (item, rect) {
          cancel?.call();
          if (null == cancel) Navigator.of(context).pop();
          onContextMenuItemTap(item, rect, hitItem);
        },
      );
    }

    if (portrait(context)) {
      var result = await showModalBottomSheet(
        context: context,
        clipBehavior: Clip.antiAlias,
        shape: modelShape(bottomSheet: _mobile),
        barrierColor: Colors.black12.withAlpha(50),
        builder: (context) => Container(
          child: SingleChildScrollView(child: _contentWidget()),
          constraints: BoxConstraints.expand(),
//          padding: EdgeInsets.symmetric(vertical: 16),
        ),
      );
      return;
    }

    if (target != null && _landscape) {
      target = Offset(target.dx, 30);
    }

    showAttachedWidget(
      target: target,
      targetContext: targetContext,
      preferDirection: preferDirection,
      backgroundColor: Colors.transparent,
      attachedBuilder: (cancel) {
        return Material(
          elevation: 6,
          clipBehavior: Clip.antiAlias,
          color: Theme.of(context).dialogBackgroundColor,
          shape: modelShape(bottomSheet: _mobile),
          child: Container(
            constraints: BoxConstraints.tightFor(width: _landscape ? 300 : 340),
            child: _contentWidget(cancel),
          ),
        );
      },
    );
  }

  void onMenuChangeCallback(SettingItem? parentItem, SettingItem item) {}

  bool onContextMenuItemChanged(SettingItem? p, SettingItem item) {
    var result = _onContextMenuItemChanged(p, item);
    SgsConfigService.get()!.saveCustomTrackStyle(widget.track);
    return result;
  }

  bool _onContextMenuItemChanged(SettingItem? parentItem, SettingItem item) {
    Map _cm = trackStyle['color_map'] ?? {};
    if (_cm.containsKey(item.key)) {
      Color _color = item.value;
      _cm[item.key] = _color;
      customTrackStyle.setColorMapEntry(item.key, _color);
      setState(() => onMenuChangeCallback(parentItem, item));
    } //
    if (parentItem?.key == TrackContextMenuKey.color_map) {
      trackStyle.colorMap?[item.key] = item.value;
      customTrackStyle.setColorMapEntry(item.key, item.value);
      setState(() => onMenuChangeCallback(parentItem, item));
    }
    if (item.key == TrackContextMenuKey.pin_top) {
      widget.eventCallback?.call('togglePinTop', widget.track..pinTop = item.value);
      return true;
    } //
    else if (item.key == TrackContextMenuKey.track_max_height) {
      trackStyle.trackMaxHeight = item.enabled == null || item.enabled! ? item.value : -item.value;
      customTrackStyle.trackMaxHeight = trackStyle.trackMaxHeight;
      // updateTrackStyle(trackStyle);
      setState(() => onMenuChangeCallback(parentItem, item));
      return true;
    } //
    else if (item.key == TrackContextMenuKey.max_value) {
      customTrackStyle.customMaxValue = EnabledValue(enabled: item.enabled!, value: item.value);
      customTrackStyle.customMaxValue = trackStyle.customMaxValue;
      setState(() => onMenuChangeCallback(parentItem, item));
      return true;
    } else if (item.key == TrackContextMenuKey.min_value) {
      customTrackStyle.customMinValue = EnabledValue(enabled: item.enabled!, value: item.value);
      trackStyle.customMinValue = customTrackStyle.customMinValue;
      setState(() => onMenuChangeCallback(parentItem, item));
      return true;
    }
    //
    else if (item.key == TrackContextMenuKey.active_data_view) {
      SgsConfigService.get()!.dataActiveTrack = item.value == true ? widget.track : null;
      notifyDataViewer(needToggle: true, expanded: item.value);
      return true;
    } else if (item.key == TrackContextMenuKey.stack_chart_split) {
      _splitChart = item.value;
      trackTotalHeight = 0;
      setState(() => onMenuChangeCallback(parentItem, item));
      return true;
    } else if (item.key == TrackContextMenuKey.cartesian_value_type) {
      cartesianValueType = item.value;
      trackData?.clear();
      loadTrackData(true);
      return true;
    }
    setState(() {
      if (item.key == TrackContextMenuKey.show_label ||
          item.key == TrackContextMenuKey.track_collapse_mode ||
          item.key == TrackContextMenuKey.track_height ||
          item.key == TrackContextMenuKey.label_font_size) {
        TrackLayoutManager.clear(widget.track);
        trackTotalHeight = 0;
      }
      trackStyle.fromSetting(item, parent: parentItem);
      customTrackStyle.fromSetting(item, parent: parentItem, addIfNone: true);
    });
    return true;
  }

  List<SettingItem> getContextMenuList(dynamic hitItem) {
    if (hitItem == null) return TrackMenuConfig.basicTrackContextMenus;
    return TrackMenuConfig.basicTrackItemContextMenus;
  }

  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter();

  AbstractTrackPainter<TrackData, StyleConfig>? getForegroundPainter() => null;

  TrackViewType getTrackViewType([RelationParams? params]) {
    RelationParams relationParams = params ?? this.relationParams;
    double sizeOfPixel = relationParams.sizeOfPixel1;
    double rangePercent = (relationParams.range1.size / relationParams.chr1.size);
    //logger.d('sizeOfPixel: $sizeOfPixel, rangePercent:${rangePercent}, chr size:${relationParams.chr.size}');

    return TrackViewType.cartesian;
  }

  num findTargetScale([RelationParams? relationParams]) {
    RelationParams _trackParams = relationParams ?? this.relationParams;
    return _trackParams.zoomConfig1.findTargetScale(_trackParams.pixelPerSeq1);
  }

  void onContextMenuItemTap(SettingItem item, Rect menuRect, [dynamic target]) async {
    //showToast(text: 'Select ${item.title}');
    if (item.key == TrackContextMenuKey.zoom_to_feature) {
      var _feature;
      if (target is Feature) {
        _feature = target;
      } else if (target is CartesianDataItem && target.hasRange) {
        _feature = RangeFeature.onlyRange(Range(start: target.start!, end: target.end!));
      }
      if (_feature != null) widget.onZoomToRange?.call(_feature);
    } //
    else if (item.key == TrackContextMenuKey.range_info) {
      if (target is RangeFeature) {
        if (portrait(context)) {
          Navigator.of(context).pushNamed(RoutePath.feature_info, arguments: {
            'feature': target,
            'chr': relationParams.chr1,
            'species': relationParams.speciesId,
            'track': widget.track,
          });
        } else {
          showModalHorizontalSheet(
            context: context,
            builder: (c) {
              return Container(
                constraints: BoxConstraints.expand(width: SIDE_WIDGET_WIDTH),
                child: RangeInfoWidget(
                  feature: target,
                  chr: relationParams.chr1,
                  species: relationParams.speciesId!,
                  track: widget.track,
                  asPage: false,
                ),
              );
            },
          );
        }
      }
    } else if (item.key == TrackContextMenuKey.save_image) {
      WidgetUtil.widget2Image(
        _repaintBoundaryKey,
        fileName: '${widget.site.currentSpecies}-${widget.track.trackName}-${relationParams.chr1.chrName}-${relationParams.chr2.chrName}-${widget.track.bioType}',
      );
    } else if (item.key == TrackContextMenuKey.remove_track) {
      // widget.onRemoveTrack?.call(widget.track);
      widget.eventCallback?.call('hideTrack', widget.track);
    } else if (item.key == TrackContextMenuKey.rename_track) {
      await showRenameTrackDialog();
    } else if (item.key == TrackContextMenuKey.meta_data) {
      Feature feature = target;
      double width = MediaQuery.of(context).size.width * .8;
      var dialog = AlertDialog(
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        shape: modelShape(context: context),
        title: Text('Metadata'),
        scrollable: true,
        content: Container(
          constraints: BoxConstraints.tightFor(width: width),
          child:
              //TreeWidget(treeMap: feature.dataSource, expandAll: true),
              SelectableText(
            feature.pretty(),
            toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
          ),
        ),
      );
      showDialog(context: context, builder: (context) => dialog);
    } else if (item.key == TrackContextMenuKey.search) {
      await showSearchDialog();
    } else if (item.key == TrackContextMenuKey.r_terminal) {
      OpenFile.open('/Applications/iTerm.app');
    }
  }

  Future showSearchDialog() async {
    var dialog = AlertDialog(
      title: Text('Search Feature'),
      shape: modelShape(context: context),
      content: Container(
        constraints: BoxConstraints.tightFor(width: 400),
        child: FeatureSearchWidget(
          dataSource: trackData!.cast<Feature>(),
          onResult: (v) async {
            Navigator.of(context).pop(v);
          },
        ),
      ),
    );
    var result = await showDialog(context: context, builder: (context) => dialog);
    if (result != null) {
      Feature feature = result;
      widget.eventCallback?.call('range-change', feature);
    }
  }

  void registerContextMenuSettings(List<SettingItem> settings) async {
    trackStyle.registerSettings(settings);
    SettingItem? maxHeightItem = settings.firstOrNullWhere((s) => s.key == TrackContextMenuKey.track_max_height);
    maxHeightItem?.enabled = trackStyle.trackMaxHeight.enabled;
    maxHeightItem?.value = trackStyle.trackMaxHeight.value;

    SettingItem? maxValueItem = settings.firstOrNullWhere((s) => s.key == TrackContextMenuKey.max_value);
    maxValueItem?.enabled = customTrackStyle.customMaxValue.enabled;
    maxValueItem?.value = customTrackStyle.customMaxValue.value;

    SettingItem? miValueItem = settings.firstOrNullWhere((s) => s.key == TrackContextMenuKey.min_value);
    miValueItem?.enabled = customTrackStyle.customMinValue.enabled;
    miValueItem?.value = customTrackStyle.customMinValue.value;

    SettingItem? item = settings.firstOrNullWhere((e) => e.key == TrackContextMenuKey.active_data_view);
    item?.value = widget.track.id == SgsConfigService.get()!.dataActiveTrack?.id;
  }

  Future showRenameTrackDialog() async {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String _name = widget.track.trackName;
    var dialog = AlertDialog(
      shape: modelShape(context: context),
      title: Text('Rename Track'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('CANCEL'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Navigator.of(context).pop(_name);
            }
          },
          child: Text('Ok'),
        ),
        SizedBox(width: 10),
      ],
      content: Form(
        key: _formKey,
        child: TextFormField(
          decoration: InputDecoration(
            hintText: 'Input track name',
            labelText: 'Track Name',
            border: inputBorder(),
          ),
          autofocus: true,
          initialValue: _name,
          validator: (value) {
            if (value!.isEmpty) return 'Name is empty';
            return null;
          },
          onSaved: (value) {
            _name = value!;
          },
          maxLines: 1,
        ),
      ),
    );
    var __name = await showDialog<String>(context: context, builder: (context) => dialog);
    if (__name != null && __name != widget.track.trackName) {
      widget.track.trackName = __name;
      setState(() {});
    }
  }

  num? prettyNumber(num? maxValue) {
    if (maxValue == null) return null;
    int r = maxValue.floor();
    int e = 0;
    while (r > 10) {
      r ~/= 10;
      e++;
    }
    double interval = e > 1 ? pow(10, e - 1) * 1.0 : 2.0;
    // num delta = maxValue % interval;
    int tickerCount = maxValue ~/ interval + 1;
    num _maxValue = interval * tickerCount;
    return _maxValue;
  }
}
