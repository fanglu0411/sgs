import 'package:dartx/dartx.dart' as dx;
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

import '../common.dart';

class RangeTween extends Tween<Range> {
  RangeTween({required Range begin, required Range end}) : super(begin: begin, end: end);

  /// Returns the value this variable has at the given animation clock value.
  @override
  Range lerp(double t) => Range.lerp(begin, end, t)!;
}

class RangeViewportController implements TickerProvider {
  late Range? _totalRange;

  void set totalRange(Range range) => _totalRange = range;

  Range? _range;

  set range(Range? range) {
    _range = range;
  }

  Range? get range => _range;

  late Curve _curve;

  set curve(Curve curve) => _curve = curve;

  late int _animationTime;

  void set animationTime(int duration) {
    _animationTime = duration;
  }

  RangeTween? _tween;
  Animation<Range>? _viewportAnimation;
  AnimationController? _animationController;

  dx.Function2<Range, bool, void>? onRangeUpdate;

  RangeViewportController({
    Range? totalRage,
    this.onRangeUpdate,
    int animationTime = 600,
    Curve curve = Curves.decelerate,
  }) {
    _totalRange = totalRage;
    _animationTime = animationTime;
    _curve = curve;
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: _animationTime));
  }

  void setViewport(Range range, {bool animation = true, bool userTouch = false, int animationTime = 400}) {
    _animationTime = animationTime;
    range = range.clamp(_totalRange!);
    if (animation && !userTouch) {
      _animateToViewport(range);
    } else {
      _range = range.copy();
      _viewportUpdateCallback(!userTouch);
    }
  }

  void _animateToViewport(Range range) {
    if (_animationController!.isAnimating) {
      print('viewport animating');
      return;
    }
    _viewportAnimation?.removeListener(_matrixAnimationUpdate);
    _viewportAnimation?.removeStatusListener(_onStatus);
    _viewportAnimation = null;
    _animationController!.reset();

    _curve = SgsConfigService.get()!.trackAnimationCurve;
    _animationController!.duration = Duration(milliseconds: BaseStoreProvider.get().getTrackAnimationDuration());

    _completed = false;
    _tween = RangeTween(begin: _range!, end: range);
    _viewportAnimation = _tween!.animate(CurvedAnimation(parent: _animationController!, curve: _curve));
    _viewportAnimation!
      ..addListener(_matrixAnimationUpdate)
      ..addStatusListener(_onStatus);
    _animationController!.forward();
  }

  bool _completed = false;

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_completed) {
      _completed = true;
      _viewportUpdateCallback(true);
    }
  }

  _matrixAnimationUpdate() {
    _range = _viewportAnimation!.value;
    _viewportUpdateCallback(false);
  }

  void _viewportUpdateCallback(bool lastFrame) {
    onRangeUpdate?.call(_range!, lastFrame);
  }

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
