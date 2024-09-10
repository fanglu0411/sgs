import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/animation/tween.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/highlight_range.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:flutter_smart_genome/chart/base/interactive_viewport.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container_logic.dart';
import 'package:flutter_smart_genome/page/track/track_control_bar/track_control_bar.dart';
import 'package:flutter_smart_genome/page/track/zoom_config.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/side/highlight_side.dart';
import 'package:flutter_smart_genome/side/search_side.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/util/undo_redo_manager.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/range_input_field_widget.dart';
import 'package:flutter_smart_genome/widget/basic/scroll_top_button.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/cross_overlay/cross_overlay_logic.dart';
import 'package:flutter_smart_genome/widget/track/track_list_view_widget.dart';
import 'package:flutter_smart_genome/widget/track/trackline/range_viewport_controller.dart';
import 'package:get/get.dart';

import 'base/track_data.dart';
import 'base/layout/track_layout_manager.dart';
import 'chromosome/chromosome_data.dart';
import 'trackline/track_line1.dart';

class CursorSelection {
  Offset hover = Offset.infinite;
  Offset start = Offset.infinite;
  Offset end = Offset.infinite;

  CursorSelection(this.start, this.end, this.hover);

  CursorSelection.start(this.start);

  CursorSelection.range(this.start, this.end);

  CursorSelection.hover(this.hover);

  double get width => end.dx - start.dx;

  CursorSelection copy({Offset? hover, Offset? start, Offset? end}) {
    return CursorSelection(start ?? this.start, end ?? this.end, hover ?? this.hover);
  }

  CursorSelection.infinite() {}

  @override
  bool operator ==(Object other) => identical(this, other) || other is CursorSelection && runtimeType == other.runtimeType && hover == other.hover && start == other.start && end == other.end;

  @override
  int get hashCode => hover.hashCode ^ start.hashCode ^ end.hashCode;
}

class TrackGroupLogic extends GetxController {
  static const String TAG_1 = 'track-view-group1';
  static const String TAG_2 = 'track_view-group2';

  int numPointers = 0;

  bool zooming = false;

  bool get _panZoomAnimation => SgsConfigService.get()!.trackAnimation;

  List<PointerDownEvent> pointerDownEvents = [];
  List<PointerMoveEvent> pointerMoveEvents = [];
  PointerDownEvent? _pointerDownEvent;

  GlobalKey<InteractiveViewerState> _viewportKey = GlobalKey<InteractiveViewerState>();

  GlobalKey<InteractiveViewerState> get viewportKey => _viewportKey;

  Offset? scalePoint;
  ScaleUpdateDetails? scaleUpdateDetails;
  Offset translate = Offset.zero;

  Size? _widgetSize;

  int trackMaxCount = 4;

  var chrRuler;
  late ChromosomeData _chromosomeData;
  late TrackSession _session;
  late Range _visibleRange;
  late Range _range;

  bool _floatControlVisible = true;

  OverlayEntry? _overlayEntry;

  ScaleLinear<num>? _linearScaleByRange;
  double? sizeOfPixel; // range of one pixel
  double? pixelOfRange; // pixel of one seq

  var _loadingCallback;

  // Timeline? _timeline;
  Offset? _lastFocalPoint;
  double _scaleStartRangeStart = -100.0;
  double _scaleStartRangeEnd = 100.0;
  ZoomConfig? _zoomConfig;

  ZoomConfig? get zoomConfig => _zoomConfig;

  late Axis _trackOrientation;

  // var crossOverlayKey = GlobalKey<CrossOverlayWidgetState>();
  // var globalRulerKey = GlobalKey<ChrGlobalRulerWidgetState>();
  // var crossoverKey = GlobalKey<CrossOverlayWidgetState>();

  late ValueNotifier<Offset?> globalRulerCursorNotifier;

  // ValueNotifier<Offset> crossoverCursorNotifier;
  late ValueNotifier<CursorSelection> crossoverPositionNotifier;

  late GlobalKey<ScrollTopButtonState> _scrollButtonKey;

  bool _dragMode = true;
  bool _touchScaling = false;
  double? _touchScale = null;

  double? get touchScale => _touchScale;

  bool get touchScaling => _touchScaling;

  Range get visibleRange => _range ?? _visibleRange;

  ScaleLinear<num>? get linearScale => _linearScaleByRange;

  late List<Track> tracks;

  late GestureDetector _gestureDetector;

  late Debounce _scaleDebounce;
  late Debounce _hoverDebounce;

  bool _splitMode = false;

  // BuildContext context;

  TrackSession get session => _session
    ..range = visibleRange
    ..tracks = tracks.map((e) => e.id!).toList();

  bool get splitMode => _splitMode;

  ScaleLinear<num>? get linearScaleByRange => _linearScaleByRange;

  Axis get trackOrientation => _trackOrientation;

  GestureDetector? get gestureDetector => _gestureDetector;

  Size? get widgetSize => _widgetSize;
  late String tag;

  late RangeViewportController _viewportController;

  static TrackGroupLogic? safe({String tag = TAG_1}) {
    if (Get.isRegistered<TrackGroupLogic>(tag: tag)) {
      return Get.find<TrackGroupLogic>(tag: tag);
    }
    return null;
  }

  TrackGroupLogic(TrackListViewWidget widget) {
    _scrollButtonKey = GlobalKey<ScrollTopButtonState>();
    _scaleDebounce = Debounce(milliseconds: 180);
    _hoverDebounce = Debounce(milliseconds: 5000);
    _gestureDetector = gestureWrapper(Container());
    _trackOrientation = Axis.horizontal;

    globalRulerCursorNotifier = ValueNotifier<Offset?>(null);
    // crossoverCursorNotifier = ValueNotifier<Offset>(null);
    crossoverPositionNotifier = ValueNotifier<CursorSelection>(CursorSelection.infinite());

    init(widget);

    // saveSession();
    UndoRedoManager.get().reset();
    UndoRedoManager.get().add(TrackCommand(state: _visibleRange.copy(), callback: undo_redo));
  }

  void init(TrackListViewWidget widget) {
    _chromosomeData = widget.chromosomeData;
    _session = widget.session;
    _visibleRange = _session.range ?? _chromosomeData.range;
    _range = _visibleRange;

    tag = widget.tag;
    tracks = widget.tracks ?? [];
    onToggleActions = widget.onToggleActions;
    onRangeChangeCallback = widget.onRangeChange;

    var totalRange = _chromosomeData.range;
    _viewportController = RangeViewportController(
      onRangeUpdate: _onViewportUpdate,
      animationTime: BaseStoreProvider.get().getTrackAnimationDuration(),
      curve: SgsConfigService.get()!.trackAnimationCurve,
    );
    _viewportController
      ..range = _range
      ..totalRange = totalRange
      ..animationTime = BaseStoreProvider.get().getTrackAnimationDuration()
      ..curve = SgsConfigService.get()!.trackAnimationCurve;

    // if (null == _timeline) {
    //   _timeline = Timeline(
    //     platform: Get.theme.platform,
    //     totalRange: totalRange,
    //     visibleRange: _visibleRange.copy(),
    //     orientation: _trackOrientation,
    //   );
    // } else {
    //   _timeline!
    //     ..totalRange = totalRange
    //     ..renderStart = _range.start
    //     ..renderEnd = _range.end;
    // }
    if (null != widgetSize) {
      _zoomConfig = ZoomConfig(_chromosomeData.range, widgetSize!.width);
      setLinearScale();
    }
  }

  void didUpdateWidget(TrackListViewWidget widget, TrackListViewWidget oldWidget) {
    init(widget);
    // saveSession();
    if (oldWidget.scale != widget.scale ||
        oldWidget.chromosomeData != widget.chromosomeData || //
        oldWidget.session != widget.session) {}
    TrackLayoutManager.clear();
  }

  GestureDetector gestureWrapper(Widget widget) {
    return GestureDetector(
      child: widget,
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      onScaleEnd: onScaleEnd,
      onDoubleTap: onDoubleTap,
      onTap: onTap,
      onTapDown: onTapDown,
      onSecondaryTapDown: onSecondaryTapDown,
      onSecondaryTapUp: onSecondaryTapUp,
      onSecondaryTapCancel: onSecondaryTapCancel,
    );
  }

  Widget withListener(Widget widget, BuildContext context) {
    return Listener(
      onPointerDown: (e) => onPointerDown(context, e),
      onPointerUp: onPointerUp,
      onPointerMove: (e) => onPointerMove(context, e),
      onPointerHover: (e) => onPointerHover(context, e),
      onPointerCancel: onPointerCancel,
      child: widget,
    );
  }

  @override
  void onReady() {
    super.onReady();
  }

  void toggleAnimation(bool animation) {
    SgsConfigService.get()!.trackAnimation = animation;
    BaseStoreProvider.get().setTrackAnimation(animation);
  }

  void mockUserScale(double scaleDelta, [Tween<double>? tween, Offset? _point]) {
    // var targetScale = _zoomConfig.findTargetScale(pixelOfRange);
    if (tween != null && tween.begin! < tween.end! && _zoomConfig!.isMaxScale(pixelOfRange!)) {
      showToast(text: 'Max scale reached', align: Alignment(0, .1));
      return;
    }
    if (tween != null && tween.begin! > tween.end! && _zoomConfig!.isMinScale(pixelOfRange!)) {
      showToast(text: 'Min scale reached', align: Alignment(0, .1));
      return;
    }
    if (!_visibleRange.isValid && _range.isValid) {
      _visibleRange = _range.copy();
    }
    double _width = _visibleRange.size / tween!.end!;

    if (viewSize / _width > _zoomConfig!.maxPxPerBp) {
      _width = viewSize / _zoomConfig!.maxPxPerBp;
    }
//    if (_width / tween.end.floor() < viewSize ~/ 60) {
//      return;
//    }
    _touchScale = tween.end;
    double _percent = _point != null ? _point.dx / viewSize : .5;
    double _leftWidth = _width * _percent;
    double _rightWidth = _width - _leftWidth;

    double _anchor = _visibleRange.start + _visibleRange.size * _percent;

    double _start = _anchor - _leftWidth, _end = _anchor + _rightWidth;

    if (_start < _chromosomeData.range.start) {
      _start = _chromosomeData.range.start;
      _end = _start + _width;
      _end = min(_end, _chromosomeData.rangeEnd);
    } else if (_end > _chromosomeData.range.end) {
      _end = _chromosomeData.range.end;
      _start = _end - _width;
      _start = max(_start, _chromosomeData.rangeStart);
    }
    _visibleRange = Range(start: _start.floorToDouble(), end: _end.ceilToDouble());
    _debounceScale();
  }

  void _debounceScale([bool? animation, bool store = true]) {
    bool _animation = animation ?? _panZoomAnimation;
    _scaleDebounce.run(() {
      if (!_animation) {
        TrackLayoutManager.clear();
      }
      _touchScaling = _animation;

      if (!_visibleRange.isValid) {
        logger.i('scale to -> ${_visibleRange} is invalid');
        return;
      }
      // _timeline!.setViewport(start: _visibleRange.start, end: _visibleRange.end, height: viewSize, animate: _animation);
      _viewportController.setViewport(_visibleRange, animation: _animation, animationTime: BaseStoreProvider.get().getTrackAnimationDuration());
      // saveSession();
      if (store) UndoRedoManager.get().add(TrackCommand(state: _visibleRange.copy(), callback: undo_redo));
    });
  }

  void mockUserPan(TrackControlAction direction) {
    bool _animation = _panZoomAnimation;
    if (direction == TrackControlAction.pan_right) {
      if (_visibleRange.end == _chromosomeData.range.end) return;
      _touchScale = 1.0;
      _visibleRange = Range(start: _visibleRange.end, end: _visibleRange.end + _visibleRange.size);
    } else if (direction == TrackControlAction.pan_left) {
      if (_visibleRange.start == _chromosomeData.range.start) return;
      _touchScale = 1.0;
      _visibleRange = Range(start: _visibleRange.start - _visibleRange.size, end: _visibleRange.start);
    } else if (direction == TrackControlAction.pan_end) {
      if (_visibleRange.end == _chromosomeData.range.end) return;
      _animation = false;
      _visibleRange = Range(start: _chromosomeData.rangeEnd - _visibleRange.size, end: _chromosomeData.rangeEnd);
    } else if (direction == TrackControlAction.pan_start) {
      if (_visibleRange.start == _chromosomeData.range.start) return;
      //to the start
      _animation = false;
      _touchScale = 10;
      _visibleRange = Range(start: 0.0, end: _visibleRange.size);
    } else if (direction == TrackControlAction.pan_min_scale) {
      if (_zoomConfig!.isMinScale(pixelOfRange!)) {
        showToast(text: 'Min scale reached', align: Alignment(0, .1));
        return;
      }
      //to min scale
      _animation = false;
      _touchScale = 10;
      _visibleRange = Range(start: 0.0, end: _chromosomeData.rangeEnd);
    } else if (direction == TrackControlAction.pan_max_scale) {
      //to the max scale
      if (_zoomConfig!.isMaxScale(pixelOfRange!)) {
        showToast(text: 'Max scale reached', align: Alignment(0, .1));
        return;
      }
      _animation = false;
      double rangeHalfWidth = (viewSize / _zoomConfig!.maxPxPerBp) / 2;
      num center = _visibleRange.center;
      if (center - rangeHalfWidth < 0) {
        _visibleRange = Range(start: 0, end: rangeHalfWidth * 2);
      } else if (center + rangeHalfWidth > _chromosomeData.rangeEnd) {
        _visibleRange = Range(start: _chromosomeData.rangeEnd - rangeHalfWidth * 2, end: _chromosomeData.rangeEnd);
      } else {
        _visibleRange = Range(start: center - rangeHalfWidth, end: center + rangeHalfWidth);
      }
      _touchScale = 10;
    }
    _debounceScale(_animation);
  }

  void undo_redo(TrackCommand command, bool undo) {
    _visibleRange = command.state;
    _debounceScale(_panZoomAnimation, false);
  }

  void onModeChange(bool dragMode) {
    _dragMode = dragMode;
    update();
  }

  void _onLastFrame() {
    bool _zooming = scaleZooming;
    if (_touchScale != 1.0 || (_zooming && mobilePlatform()) || (fixedZooming && mobilePlatform())) {
      TrackLayoutManager.clear();
    }
    saveSession(true);
  }

  double get viewSize => _trackOrientation == Axis.vertical ? _widgetSize!.height : _widgetSize!.width;

  void setLinearScale() {
    //根据widget高度

    // Scale<num, num> linearScale =  createScale(visibleRange, viewSize);
    _linearScaleByRange = createScale(visibleRange, viewSize);

    sizeOfPixel = visibleRange.size / viewSize;
    pixelOfRange = viewSize / visibleRange.size;
    _zoomConfig!.updateTargetScale(pixelOfRange!);

    // 根据chromosome 长度
    var chrStart = _chromosomeData.rangeStart, chrEnd = _chromosomeData.rangeEnd;
    // _linearScaleByRange =
    //     ScaleLinear.number(
    //   domain: [chrStart, chrEnd + 1],
    //   range: [linearScale[chrStart]!, linearScale[chrEnd + 1]!],
    // );
  }

  Function? onToggleActions;
  Function? onRangeChangeCallback;

  void _toggleTopBarAnimation() {
    onToggleActions?.call();

    // if (_floatControlVisible) {
    //   _floatAnimationController.reverse();
    // } else {
    //   _floatAnimationController.forward();
    // }
    // _floatControlVisible = !_floatControlVisible;
  }

  void _onViewportUpdate(Range range, bool lastFrame) {
    if (!initialized || isClosed) return;
    if (!range.isValid) {
      print('_onViewportUpdate -----> invalid range:${range}');
      return;
    }
    _range = range;
    setLinearScale();
    if (lastFrame) _touchScaling = false;
    onRangeChangeCallback?.call(_range);
    if (lastFrame) _onLastFrame();
    update(['id-${tag}']);
  }

  // void onNeedPaint(bool lastFrame) {
  //   if (!initialized || isClosed) return;
  //   var __range = Range(start: _timeline.renderStart, end: _timeline.renderEnd);
  //   if (lastFrame) _touchScaling = false;
  //   bool rangeChange = _range == null || __range != _range;
  //   _range = __range;
  //   setLinearScale();
  //   onRangeChangeCallback?.call(__range);
  //   if (lastFrame) _onLastFrame();
  //   update();
  // }

  void initIfNeed(BuildContext context, Size widgetSize) {
    double _preWidgetWidth = _widgetSize?.width ?? 0;
    bool sizeChanged = _preWidgetWidth > 0 && _preWidgetWidth != widgetSize.width;
    double _deltaWidth = widgetSize.width - _preWidgetWidth;

    _widgetSize = widgetSize;
    if (null == zoomConfig || sizeChanged) {
      _zoomConfig = ZoomConfig(_chromosomeData.range, widgetSize.width);
      setLinearScale();
    }

    if (sizeChanged) {
      var delta = _visibleRange.size * (_deltaWidth / _preWidgetWidth);
      _visibleRange = _visibleRange.copy(end: _visibleRange.start + _visibleRange.size + delta);
      if (_visibleRange.size > _chromosomeData.size) {
        _visibleRange = _chromosomeData.range.copy();
      }
      _range = _visibleRange.copy();
      saveSession(true);
      // _timeline!
      //   ..renderStart = _range.start
      //   ..renderEnd = _range.end;
      _viewportController.range = _range;
      setLinearScale();
      Future.delayed(Duration(microseconds: 300)).then((v) {
        _viewportController.setViewport(_range, animation: false);
      });
    }
  }

  bool get scaleZooming => _scales.where((s) => s != 1.0).length > 0;

  bool get fixedZooming => _scales.length <= 8 && _scales.every((s) => s == 1.0);

  void onScaleStart(ScaleStartDetails details) {
    if (!_dragMode) return;
    _scales.clear();
    _scaleTemplate = null;
    _lastFocalPoint = details.focalPoint;
    _scaleStartRangeStart = _viewportController.range!.start; //_timeline!.start;
    _scaleStartRangeEnd = _viewportController.range!.end; //_timeline!.end;
    // _timeline!.isInteracting = true;
    // _timeline!.setViewport(velocity: 0.0, animate: _panZoomAnimation);
  }

  double adaptPoint(Offset offset) {
    return _trackOrientation == Axis.vertical ? offset.dy : offset.dx;
  }

  double? _scaleTemplate = null;

  List<double> _scales = [];

  CancelFunc? _toastFunc;

  void onScaleUpdate(ScaleUpdateDetails details) {
    if (!_dragMode) return;
//    if (_scaleTemplate == details.scale) return;
    double changeScale = details.scale;
    if (changeScale == 1.0 && _lastFocalPoint != null && (_lastFocalPoint!.dx - details.focalPoint.dx) <= 0 && _visibleRange.start == 1) {
      _toastFunc?.call();
      _toastFunc = showToast(text: 'Already at the start');
      return;
    }
    if (changeScale == 1.0 && _lastFocalPoint != null && (_lastFocalPoint!.dx - details.focalPoint.dx) >= 0 && _visibleRange.end == _chromosomeData.rangeEnd) {
      _toastFunc?.call();
      _toastFunc = showToast(text: 'Already at the end');
      return;
    }

    _touchScale = changeScale;
    _scales.add(changeScale);
    _touchScaling = true;

    // print('scale ${details.scale} ${details.focalPoint} ${details.localFocalPoint}');
    double scale = (_scaleStartRangeEnd - _scaleStartRangeStart) / viewSize;

    double focus = _scaleStartRangeStart + adaptPoint(details.focalPoint) * scale;
    double focalDiff = (_scaleStartRangeStart + adaptPoint(_lastFocalPoint ?? details.focalPoint) * scale) - focus;

    double _start = focus + (_scaleStartRangeStart - focus) / changeScale + focalDiff;
    double _end = focus + (_scaleStartRangeEnd - focus) / changeScale + focalDiff;

    _scaleTemplate = details.scale;
    // debugPrint('start:$_start end:$_end size:${_end - _start} scale: $changeScale');

    if (_scaleTemplate != 1) {
      if (_start < _chromosomeData.rangeStart) {
        _start = _chromosomeData.rangeStart;
      }
      if (_end > _chromosomeData.rangeEnd) {
        _end = _chromosomeData.rangeEnd;
      }
    }

    _visibleRange = Range(start: _start, end: _end);
    // _timeline!.setViewport(start: _visibleRange.start, end: _visibleRange.end, height: viewSize, animate: _panZoomAnimation);
    _viewportController.setViewport(_visibleRange, animation: false, userTouch: true);
  }

  void onScaleEnd(ScaleEndDetails details) {
    if (!_dragMode) return;
    // print('scale end velocity: ${details.velocity.pixelsPerSecond.dy}');
    // _timeline!.isInteracting = false;
//    _touchScale = null;
    _touchScaling = false;
    // onNeedPaint(true);
    _viewportController.setViewport(_visibleRange, animation: false);

    // if (!_panZoomAnimation) return;
    // print('scaling:${_scales}');

//     double velocity = adaptPoint(details.velocity.pixelsPerSecond);
//     velocity = velocity.clamp(-2000.0, 2000.0);
//     print('velocity: $velocity');
//
//     bool flipPlatform = !kIsWeb && (mobilePlatform() || Platform.isMacOS);
//     if (!flipPlatform) velocity = double.maxFinite;
// //    if (mobilePlatform()) _touchScale = 10;
//     _timeline.setViewport(velocity: velocity, animate: _panZoomAnimation && flipPlatform, touchEnd: true);
//     saveSession();
  }

  void onTap() {
    //logger.d('on tap');
//    setState(() {
//      _floatControlVisible = !_floatControlVisible;
//    });
    _toggleTopBarAnimation();
  }

  void onTapDown(TapDownDetails details) {
    //logger.d('tap down');
    // _timeline.setViewport(velocity: 0, animate: _panZoomAnimation);
  }

  void onDoubleTap() {
    mockUserScale(1.0, Tween(begin: 1.0, end: 2.0), crossoverPositionNotifier.value.hover);
  }

  void onSecondaryTapDown(TapDownDetails details) {
//    print('second tap down');
  }

  void onSecondaryTapUp(TapUpDetails details) {
//    showAttachedWidget(
//      target: details.globalPosition,
//      preferDirection: PreferDirection.rightTop,
//      attachedBuilder: (cancel) {
//        return Material(
//          elevation: 5,
//          shadowColor: Theme.of(context).colorScheme.primary,
//          child: MenuListWidget(
//            items: _trackBlankMenus,
//            onChange: (item) {
//              cancel();
//              _onContextMenuTap(item);
//            },
//          ),
//        );
//      },
//    );
  }

  void onSecondaryTapCancel() {}

  /// 通过导航位置搜索基因
  void onSearchKeyword(String value) async {
    TrackContainerLogic.safe()?.setSide(SideModel.search, true);
    await Future.delayed(Duration(milliseconds: 100));
    SearchSideLogic.safe()?.search(keyword: value);
  }

  void zoomToGene(Range range) {
    // double visibleWidth = range.size / .3;
    var _targetRange = range;
    double _width = _targetRange.size;
    if (viewSize / _width > _zoomConfig!.maxPxPerBp) {
      _width = viewSize / _zoomConfig!.maxPxPerBp;
      final center = range.center;
      _targetRange = Range(start: center - _width / 2, end: center + _width / 2);
    }

    if (_targetRange.size >= _visibleRange.size) {
      _targetRange = _targetRange.inflate(_targetRange.size);
    } else {
      _targetRange = _targetRange.inflate(_targetRange.size / 2);
      // _targetRange = range.inflate((_visibleRange.size - _targetRange.size) / 2);
    }
    if (_targetRange.start < _chromosomeData.rangeStart) {
      _targetRange.start = _chromosomeData.rangeStart;
    }

    if (_targetRange.end > _chromosomeData.rangeEnd) {
      _targetRange.end = _chromosomeData.rangeEnd;
    }
    // CrossOverlayLogic.safe()?.addFlashRange(range);
    zoomToRange(_targetRange);
  }

  void zoomToRange(Range range) {
    range = range.clamp(_chromosomeData.range);
    int pad = 0;
    _visibleRange = Range(start: range.start - pad, end: range.end + pad);
    _touchScaling = true;
    // _timeline!.setViewport(start: _visibleRange.start.toDouble(), end: _visibleRange.end.toDouble(), height: viewSize, animate: _panZoomAnimation);
    _viewportController.setViewport(_visibleRange, animation: _panZoomAnimation);
    // saveSession();
    UndoRedoManager.get().add(TrackCommand(state: _visibleRange.copy(), callback: undo_redo));
  }

  void onZoomToRange(Feature feature) {
    zoomToRange(feature.range);
  }

  ScaleLinear<num> createScale(Range range, double width) {
    return ScaleLinear.number(domain: [range.start, range.end + 1], range: [0, width]);
  }

  void onRangeChangeManual(Range range) => zoomToRange(range);

  void onRemoveTrack(Track track) {
    tracks.remove(track);
    update();
  }

  void onPointerDown(BuildContext context, PointerDownEvent event) {
    _pointerDownEvent = event;
    if (_dragMode) return;
    // logger.i('pointer down ${event.buttons}');
    if (numPointers < 2) {
      pointerDownEvents.add(event);
      numPointers++;
      // logger.i('pointer down ${event.pointer}');
      // _addOverlay(context, event.position, null);
      crossoverPositionNotifier.value = CursorSelection.start(_pointerDownEvent!.localPosition);
      // CrossOverlayLogic.safe().selection = CursorSelection.start(_pointerDownEvent.localPosition);
    } else {
      // _overlayEntry?.remove();
    }
  }

  void onPointerMove(BuildContext context, PointerMoveEvent event) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset local = renderBox.globalToLocal(event.position);
    globalRulerCursorNotifier.value = local;
    // crossoverCursorNotifier.value = local;

    if (_dragMode) return;
    var findIndex = pointerMoveEvents.indexWhere((e) => e.pointer == event.pointer);
    if (findIndex >= 0) {
      pointerMoveEvents[findIndex] = event;
    } else {
      pointerMoveEvents.add(event);
      findIndex = pointerMoveEvents.length - 1;
    }

    if (numPointers == 1 && pointerMoveEvents[0].pointer == event.pointer) {
      crossoverPositionNotifier.value = CursorSelection(_pointerDownEvent!.localPosition, local, local);
      // CrossOverlayLogic.safe().selection = CursorSelection(_pointerDownEvent.localPosition, local, local);
      translate += event.localDelta;
      // update();
    }
  }

  void onPointerUp(PointerUpEvent event) {
    if (_dragMode) return;
    for (var i = 0; i < pointerDownEvents.length; i++) {
      if (pointerDownEvents[i].pointer == event.pointer) {
        pointerDownEvents.removeAt(i);
        numPointers--;
//        print('pointer up ${event.pointer}');
      }
    }
    for (var i = 0; i < pointerMoveEvents.length; i++) {
      if (pointerMoveEvents[i].pointer == event.pointer) {
        pointerMoveEvents.removeAt(i);
      }
    }
    _checkAddHighlight(event.position);
    crossoverPositionNotifier.value = crossoverPositionNotifier.value.copy(start: Offset.infinite, end: Offset.infinite, hover: event.localPosition);
    // CrossOverlayLogic.safe().selection = CrossOverlayLogic.safe().selection.copy(start: Offset.infinite, end: Offset.infinite, hover: event.localPosition);
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _checkAddHighlight(Offset anchor) {
    if (crossoverPositionNotifier.value.end == Offset.infinite) return;
    if (crossoverPositionNotifier.value.width <= 1) return;

    double start = crossoverPositionNotifier.value.start.dx;
    double end = crossoverPositionNotifier.value.end.dx;

    var rangeStart = linearScale!.invert(start);
    var rangeEnd = linearScale!.invert(end);

    Range highlightRange = Range(start: rangeStart, end: rangeEnd);

    showAddHighlightDialog(highlightRange, anchor);
  }

  ///add highlight range
  void showAddHighlightDialog(Range range, Offset anchor) {
    showAttachedWidget(
      target: anchor + Offset(10, -10),
      preferDirection: PreferDirection.rightTop,
      attachedBuilder: (c) {
        return Material(
          color: Get.theme.dialogBackgroundColor,
          shape: modelShape(),
          elevation: 6,
          child: Container(
            padding: EdgeInsets.all(12),
            constraints: BoxConstraints.tightFor(width: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Highlight Range',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                RangeInputFieldWidget(
                  range: range,
                  submitText: 'ADD',
                  decoration: BoxDecoration(
                    border: Border.all(color: Get.theme.primaryColor),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  onSubmit: (range) {
                    c.call();
                    _addHighlight(range);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addHighlight(Range range) async {
    var session = SgsAppService.get()!.session ?? _session;
    if (session.chrId == null) {
      showToast(text: 'chr id is invalid!');
      return;
    }
    var highlight = HighlightRange.create(
      serverId: session.siteId,
      speciesId: session.speciesId,
      speciesName: session.speciesName!,
      chrId: session.chrId!,
      chrName: session.chrName!,
      start: range.start,
      end: range.end,
    );
    await BaseStoreProvider.get().addOrPutHighlight(highlight);
    HighlightsLogic.safe()?.reloadData();
  }

  void onPointerHover(BuildContext context, PointerHoverEvent hoverEvent) {
    // print('hover $hoverEvent');
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset local = renderBox.globalToLocal(hoverEvent.position);
    globalRulerCursorNotifier.value = local;
    crossoverPositionNotifier.value = crossoverPositionNotifier.value.copy(hover: local);

    _hoverDebounce.run(() {
      crossoverPositionNotifier.value = crossoverPositionNotifier.value.copy(hover: Offset.infinite);
    });
  }

  void onPointerExit(PointerExitEvent exitEvent) {
    globalRulerCursorNotifier.value = null;
  }

  void onPointerCancel(PointerCancelEvent exitEvent) {
    globalRulerCursorNotifier.value = null;
    crossoverPositionNotifier.value = CursorSelection.infinite();
  }

  TrackParams createTrackParams(Track track, ChromosomeData chr) {
    return TrackParams(
      track: track,
      speciesId: _session.speciesId,
      speciesName: _session.speciesName!,
      chrId: chr.id,
      chr: chr,
      bpPerPixel: sizeOfPixel!,
      pixelPerBp: pixelOfRange!,
      zoomConfig: _zoomConfig!,
    );
  }

  @override
  void onClose() {
    saveSession(true);
    _scaleDebounce.dispose();
    _hoverDebounce.dispose();
    // _timeline?.clearCallback();
    onToggleActions = null;
    onRangeChangeCallback = null;
    super.onClose();
  }

  void saveSession([bool immediate = false]) {
    if (tag == TAG_1) {
      SgsAppService.get()!.updateCurrentSession(visibleRange);
    } else if (tag == TAG_2) {
      SgsAppService.get()!.updateCurrentSession2(visibleRange);
    }
  }

  void toggleSplitMode() {
    _splitMode = !_splitMode;
    update();
  }
}
