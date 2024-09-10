import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

import 'utils.dart';

import 'track_line_entry.dart';

typedef OnAnimationEnd();
typedef PaintCallback(bool lastFrame);
typedef ChangeEraCallback(TrackLineEntry era);
typedef ChangeHeaderColorCallback(Color background, Color text);

class Timeline {
  /// Some aptly named constants for properly aligning the Timeline view.
  static const double LineWidth = 2.0;
  static const double LineSpacing = 10.0;
  static const double DepthOffset = LineSpacing + LineWidth;

  static const double EdgePadding = 8.0;
  static const double MoveSpeed = 10.0;
  static const double MoveSpeedInteracting = 40.0;
  static const double Deceleration = 3.0;
  static const double GutterLeft = 45.0;
  static const double GutterLeftExpanded = 75.0;

  static const double EdgeRadius = 4.0;
  static const double MinChildLength = 50.0;
  static const double BubbleHeight = 50.0;
  static const double BubbleArrowSize = 19.0;
  static const double BubblePadding = 20.0;
  static const double BubbleTextHeight = 20.0;
  static const double AssetPadding = 30.0;
  static const double Parallax = 100.0;
  static const double AssetScreenScale = 0.3;

//  static const double InitialViewportPadding = 100.0;
//  static const double TravelViewportPaddingTop = 400.0;

  static const double ViewportPaddingTop = 0.0;
  static const double ViewportPaddingBottom = 0.0;
  static const int SteadyMilliseconds = 500;

  /// The current platform is initialized at boot, to properly initialize
  /// [ScrollPhysics] based on the platform we're on.
  late TargetPlatform _platform;

  late Range _totalRange;
  late Axis _orientation;

  double _start = 0.0;
  double _end = 0.0;
  late double _renderStart;
  late double _renderEnd;
  double _lastFrameTime = 0.0;
  double _height = 0.0;
  double _offsetDepth = 0.0;
  double _renderOffsetDepth = 0.0;

  double _simulationTime = 0.0;
  double _timeMin = 0.0;
  double _timeMax = 0.0;
  double _gutterWidth = GutterLeft;

  bool _showFavorites = false;
  bool _isFrameScheduled = false;
  bool _isInteracting = false;
  bool _isScaling = false;
  bool _isActive = false;
  bool _isSteady = false;

  HeaderColors? _currentHeaderColors;

  Color? _headerTextColor;
  Color? _headerBackgroundColor;

  /// Depending on the current [Platform], different values are initialized
  /// so that they behave properly on iOS&Android.
  ScrollPhysics? _scrollPhysics;

  /// [_scrollPhysics] needs a [ScrollMetrics] value to function.
  ScrollMetrics? _scrollMetrics;
  Simulation? _scrollSimulation;

  EdgeInsets padding = EdgeInsets.zero;
  EdgeInsets devicePadding = EdgeInsets.zero;

  Timer? _steadyTimer;

  /// A gradient is shown on the background, depending on the [_currentEra] we're in.
  List<TrackLineBackgroundColor>? _backgroundColors;

  /// [Ticks] also have custom colors so that they are always visible with the changing background.
  List<TickColors>? _tickColors;
  List<HeaderColors>? _headerColors;

  /// Callback set by [TimelineRenderWidget] when adding a reference to this object.
  /// It'll trigger [RenderBox.markNeedsPaint()].
  List<PaintCallback>? _paintCallbackList;
  PaintCallback? onNeedPaint;
  OnAnimationEnd? onAnimationEnd;

  /// These next two callbacks are bound to set the state of the [TimelineWidget]
  /// so it can change the appeareance of the top AppBar.
  ChangeEraCallback? onEraChanged;
  ChangeHeaderColorCallback? onHeaderColorsChanged;

  Timeline({
    TargetPlatform platform = TargetPlatform.macOS,
    required Range totalRange,
    Range? visibleRange,
    Axis orientation = Axis.horizontal,
    double height = double.maxFinite,
  }) {
    _platform = platform;
    _totalRange = totalRange;
    _orientation = orientation;
    if (visibleRange == null) visibleRange = Range(start: totalRange.start, end: totalRange.end);
    setViewport(start: visibleRange.start.toDouble(), end: visibleRange.end.toDouble(), height: height);
  }

  Range get totalRange => _totalRange;

  void set totalRange(Range range) => _totalRange = range;

  double get renderOffsetDepth => _renderOffsetDepth;

  double get start => _start;

  double get end => _end;

  double get renderStart => _renderStart;

  double get renderEnd => _renderEnd;

  void set renderStart(num start) {
    _renderStart = start.toDouble();
    _start = start.toDouble();
  }

  void set renderEnd(num end) {
    _renderEnd = end.toDouble();
    _end = end.toDouble();
  }

  double get gutterWidth => _gutterWidth;

  bool get isInteracting => _isInteracting;

  bool get showFavorites => _showFavorites;

  bool get isActive => _isActive;

  Color? get headerTextColor => _headerTextColor;

  Color? get headerBackgroundColor => _headerBackgroundColor;

  HeaderColors? get currentHeaderColors => _currentHeaderColors;

  List<TrackLineBackgroundColor>? get backgroundColors => _backgroundColors;

  List<TickColors>? get tickColors => _tickColors;

//  List<TimelineAsset> get renderAssets => _renderAssets;

  /// Setter for toggling the gutter on the left side of the timeline with
  /// quick references to the favorites on the timeline.
  set showFavorites(bool value) {
    if (_showFavorites != value) {
      _showFavorites = value;
      _startRendering();
    }
  }

  /// When a scale operation is detected, this setter is called:
  /// e.g. [_TimelineWidgetState.scaleStart()].
  set isInteracting(bool value) {
    if (value != _isInteracting) {
      _isInteracting = value;
      _updateSteady();
    }
  }

  /// Used to detect if the current scaling operation is still happening
  /// during the current frame in [advance()].
  set isScaling(bool value) {
    if (value != _isScaling) {
      _isScaling = value;
      _updateSteady();
    }
  }

  /// Toggle/stop rendering whenever the timeline is visible or hidden.
  set isActive(bool isIt) {
    if (isIt != _isActive) {
      _isActive = isIt;
      if (_isActive) {
        _startRendering();
      }
    }
  }

  void addPaintCallback(PaintCallback paintCallback) {
    if (_paintCallbackList == null) _paintCallbackList = [];
    _paintCallbackList!.add(paintCallback);
  }

  void clearCallback() {
    _paintCallbackList?.clear();
    _paintCallbackList = null;
    onNeedPaint = null;
  }

  /// Check that the viewport is steady - i.e. no taps, pans, scales or other gestures are being detected.
  void _updateSteady() {
    bool isIt = !_isInteracting && !_isScaling;

    /// If a timer is currently active, dispose it.
    if (_steadyTimer != null) {
      _steadyTimer!.cancel();
      _steadyTimer = null;
    }

    if (isIt) {
      /// If another timer is still needed, recreate it.
      _steadyTimer = Timer(Duration(milliseconds: SteadyMilliseconds), () {
        _steadyTimer = null;
        _isSteady = true;
        _startRendering();
      });
    } else {
      /// Otherwise update the current state and schedule a new frame.
      _isSteady = false;
      _startRendering();
    }
  }

  /// Schedule a new frame.
  void _startRendering() {
    if (!_isFrameScheduled) {
      _isFrameScheduled = true;
      _lastFrameTime = 0.0;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }
  }

  double screenPaddingInTime(double padding, double start, double end) {
    return padding / computeScale(start, end);
  }

  /// Compute the viewport scale from the start/end times.
  double computeScale(double start, double end) {
    return _height == 0.0 ? 1.0 : _height / (end - start);
  }

  /// Load all the resources from the local bundle.
  ///
  /// This function will load and decode `timline.json` from disk,
  /// decode the JSON file, and populate all the [TimelineEntry]s.
  Future<List<TrackLineEntry>> loadFromBundle(String filename) async {
    String data = await rootBundle.loadString(filename);
    List jsonEntries = json.decode(data) as List;

    List<TrackLineEntry> allEntries = <TrackLineEntry>[];
    _backgroundColors = <TrackLineBackgroundColor>[];
    _tickColors = <TickColors>[];
    _headerColors = <HeaderColors>[];

    /// The JSON decode doesn't provide strong typing, so we'll iterate
    /// on the dynamic entries in the [jsonEntries] list.

    /// sort the full list so they are in order of oldest to newest
    allEntries.sort((TrackLineEntry a, TrackLineEntry b) {
      return a.start.compareTo(b.start);
    });

    _backgroundColors!.sort((TrackLineBackgroundColor a, TrackLineBackgroundColor b) {
      return a.start!.compareTo(b.start!);
    });

    _timeMin = double.maxFinite;
    _timeMax = -double.maxFinite;

    return allEntries;
  }

  /// Make sure that while scrolling we're within the correct timeline bounds.
  clampScroll() {
    _scrollMetrics = null;
    _scrollPhysics = null;
    _scrollSimulation = null;

    /// Get measurements values for the current viewport.
    double scale = computeScale(_start, _end);
    double padTop = (devicePadding.top + ViewportPaddingTop) / scale;
    double padBottom = (devicePadding.bottom + ViewportPaddingBottom) / scale;
    bool fixStart = _start < _timeMin - padTop;
    bool fixEnd = _end > _timeMax + padBottom;

    /// As the scale changes we need to re-solve the right padding
    /// Don't think there's an analytical single solution for this
    /// so we do it in steps approaching the correct answer.
    for (int i = 0; i < 20; i++) {
      double scale = computeScale(_start, _end);
      double padTop = (devicePadding.top + ViewportPaddingTop) / scale;
      double padBottom = (devicePadding.bottom + ViewportPaddingBottom) / scale;
      if (fixStart) {
        _start = _timeMin - padTop;
      }
      if (fixEnd) {
        _end = _timeMax + padBottom;
      }
    }
    if (_end < _start) {
      _end = _start + _height / scale;
    }

    /// Be sure to reschedule a new frame.
    if (!_isFrameScheduled) {
      _isFrameScheduled = true;
      _lastFrameTime = 0.0;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }
  }

  double? _viewportWidth = null;

  /// This method bounds the current viewport depending on the current start and end positions.
  void setViewport({
    double start = double.maxFinite,
    bool pad = false,
    double end = double.maxFinite,
    double height = double.maxFinite,
    double velocity = double.maxFinite,
    bool animate = false,
    bool touchEnd = false,
  }) {
    //fix width;
    if (start != double.maxFinite && end != double.maxFinite) {
      double _size = end - start;
      if (_size > _totalRange.size) {
        start = _totalRange.start;
        end = _totalRange.end;
        velocity = double.maxFinite;
        animate = false;
      } else if (start < _totalRange.start) {
        start = _totalRange.start;
        end = start + _size;
        animate = false;
        velocity = double.maxFinite;
      } else if (end > totalRange.end) {
        start = totalRange.end - _size;
        end = totalRange.end;
        animate = false;
        velocity = double.maxFinite;
      }
    }

    /// Calculate the current height.
    if (height != double.maxFinite) {
      if (_height == 0.0) {
        double scale = height / (_end - _start);
        _start = _start - padding.top / scale;
        _end = _end + padding.bottom / scale;
      }
      _height = height;
    }

    /// If a value for start&end has been provided, evaluate the top/bottom position
    /// for the current viewport accordingly.
    /// Otherwise build the values separately.
    if (start != double.maxFinite && end != double.maxFinite) {
      _start = start;
      _end = end;
      if (pad && _height != 0.0) {
        double scale = _height / (_end - _start);
        _start = _start - padding.top / scale;
        _end = _end + padding.bottom / scale;
      }
    } else {
      if (start != double.maxFinite) {
        double scale = height / (_end - _start);
        _start = pad ? start - padding.top / scale : start;
      }
      if (end != double.maxFinite) {
        double scale = height / (_end - _start);
        _end = pad ? end + padding.bottom / scale : end;
      }
    }

    _viewportWidth = _end - _start;

    /// If a velocity value has been passed, use the [ScrollPhysics] to create
    /// a simulation and perform scrolling natively to the current platform.
    if (velocity != double.maxFinite) {
      double scale = computeScale(_start, _end);
      double padTop = (devicePadding.top + ViewportPaddingTop) / computeScale(_start, _end);
      double padBottom = (devicePadding.bottom + ViewportPaddingBottom) / computeScale(_start, _end);
      double rangeMin = (_timeMin - padTop) * scale;
      double rangeMax = (_timeMax + padBottom) * scale - _height;
      if (rangeMax < rangeMin) {
        rangeMax = rangeMin;
      }

      _simulationTime = 0.0;
      if (_platform == TargetPlatform.iOS || _platform == TargetPlatform.android) {
        _scrollPhysics = RangeMaintainingScrollPhysics();
      } else {
        _scrollPhysics = RangeMaintainingScrollPhysics();
      }
      _scrollMetrics = FixedScrollMetrics(
        devicePixelRatio: 1.0,
        minScrollExtent: double.negativeInfinity,
        maxScrollExtent: double.infinity,
        pixels: 0.0,
        viewportDimension: _height,
        axisDirection: velocity > 0 ? AxisDirection.right : AxisDirection.left,
      );
      _scrollSimulation = _scrollPhysics!.createBallisticSimulation(_scrollMetrics!, velocity);
    }
    if (!animate || velocity == 0) {
      _renderStart = _start;
      _renderEnd = _end;
      advance(0.0, false);
      _callNeedPaint(touchEnd);
    } else if (!_isFrameScheduled) {
      _isFrameScheduled = true;
      _lastFrameTime = 0.0;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }
  }

  /// Make sure that all the visible assets are being rendered and advanced
  /// according to the current state of the timeline.
  void beginFrame(Duration timeStamp) {
    _isFrameScheduled = false;
    final double t = timeStamp.inMicroseconds / Duration.microsecondsPerMillisecond / 1000.0;
    if (_lastFrameTime == 0.0) {
      _lastFrameTime = t;
      _isFrameScheduled = true;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
      return;
    }

    double elapsed = t - _lastFrameTime;
    _lastFrameTime = t;

    bool doneRendering = advance(elapsed, true);
    _callNeedPaint(doneRendering);

    if (!doneRendering && !_isFrameScheduled) {
      _isFrameScheduled = true;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }
//    if (doneRendering) {
//      onAnimationEnd?.call();
//    }
  }

  _callNeedPaint(bool lastFrame) {
    onNeedPaint?.call(lastFrame);
    if (_paintCallbackList != null) {
      for (PaintCallback callback in _paintCallbackList!) {
        callback.call(lastFrame);
      }
    }
  }

  TickColors? findTickColors(double screen) {
    if (_tickColors == null) {
      return null;
    }
    for (TickColors color in _tickColors!.reversed) {
      if (screen >= color.screenY!) {
        return color;
      }
    }

    return screen < _tickColors!.first.screenY! ? _tickColors!.first : _tickColors!.last;
  }

  HeaderColors? _findHeaderColors(double screen) {
    if (_headerColors == null) {
      return null;
    }
    for (HeaderColors color in _headerColors!.reversed) {
      if (screen >= color.screenY!) {
        return color;
      }
    }

    return screen < _headerColors!.first.screenY! ? _headerColors!.first : _headerColors!.last;
  }

  bool advance(double elapsed, bool animate) {
    if (_height <= 0) {
      /// Done rendering. Need to wait for height.
      return true;
    }

    /// The current scale based on the rendering area.
    double scale = _height / (_renderEnd - _renderStart);

    bool doneRendering = true;
    bool stillScaling = true;

    /// If the timeline is performing a scroll operation adjust the viewport
    /// based on the elapsed time.
    if (_scrollSimulation != null) {
      doneRendering = false;
      _simulationTime += elapsed;
      double scale = _height / (_end - _start);

      double velocity = _scrollSimulation!.dx(_simulationTime);

      double displace = velocity * elapsed / scale;

      _start -= displace;
      _end -= displace;

      double _size = _end - _start;
      if (_size > _totalRange.size) {
        _start = _totalRange.start;
        _end = _totalRange.end;
        velocity = double.maxFinite;
        //animate = false;
      } else if (_start < _totalRange.start) {
        _start = _totalRange.start;
        _end = start + _size;
        //animate = false;
        velocity = double.maxFinite;
      } else if (end > totalRange.end) {
        _start = totalRange.end - _size;
        _end = totalRange.end;
        animate = false;
        velocity = double.maxFinite;
      }

      /// If scrolling has terminated, clean up the resources.
      if (_scrollSimulation!.isDone(_simulationTime)) {
        _scrollMetrics = null;
        _scrollPhysics = null;
        _scrollSimulation = null;
      }
    }

    // double _size = _end - _start;
    // double _minSize = _height / 30;
    // if (_size < _minSize) {
    //   double _mid = _start + _size / 2;
    //   _start = _mid - _minSize / 2;
    //   _end = _mid + _minSize / 2;
    // }

    /// Animate movement.
    double speed = min(1.0, elapsed * (_isInteracting ? MoveSpeedInteracting : MoveSpeed));
    double ds = _start - _renderStart;
    double de = _end - _renderEnd;

    /// If the current view is animating, adjust the [_renderStart]/[_renderEnd] based on the interaction speed.
    if (!animate || ((ds * scale).abs() < 1.0 && (de * scale).abs() < 1.0)) {
      stillScaling = false;
      _renderStart = _start;
      _renderEnd = _end;
    } else {
      doneRendering = false;

      double __start = _renderStart + ds * speed;
      double __end = _renderEnd + de * speed;

      _renderStart = __start;
      _renderEnd = __end;
    }
//    if (_start < totalRange.start) {
//      _start = totalRange.start;
//      _end = _start + _totalRange.size;
//    }
//    if (_end > totalRange.end) {
//      _end = totalRange.end;
//      _start = _end - _totalRange.size;
//    }

    isScaling = stillScaling;

    /// Update scale after changing render range.
    scale = _height / (_renderEnd - _renderStart);

    if (_isSteady) {
      double dd = _offsetDepth - renderOffsetDepth;
      if (!animate || dd.abs() * DepthOffset < 1.0) {
        _renderOffsetDepth = _offsetDepth;
      } else {
        /// Needs a second run.
        doneRendering = false;
        _renderOffsetDepth += dd * min(1.0, elapsed * 12.0);
      }
    }

    return doneRendering;
  }

  double bubbleHeight(TrackLineEntry entry) {
    return BubblePadding * 2.0 + 1 * BubbleTextHeight;
  }
}