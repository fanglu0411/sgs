import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class CircularProgressView extends StatefulWidget {
  final double width;
  final double height;
  final Color? backgroundColor;
  final double strokeWidth;
  final bool finish;
  final Duration? finishDuration;
  final int updatePeriod;

  const CircularProgressView({
    super.key,
    this.width = 60,
    this.height = 60,
    this.backgroundColor,
    this.strokeWidth = 6,
    this.finish = false,
    this.updatePeriod = 300,
    this.finishDuration = const Duration(milliseconds: 1000),
  });

  @override
  State<CircularProgressView> createState() => _CircularProgressViewState();
}

class _CircularProgressViewState extends State<CircularProgressView> with TickerProviderStateMixin {
  Timer? _timer;
  double _value = 0;
  late Random _random;

  AnimationController? _valueController;

  @override
  void initState() {
    super.initState();
    _random = Random();
    _timer = Timer.periodic(Duration(milliseconds: widget.updatePeriod), _onTimer);
  }

  @override
  void didUpdateWidget(covariant CircularProgressView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.finish) {
      _finishProgress();
    }
  }

  num _randomValue() {
    if (_value >= .99) return 0;
    if (_value >= .95) {
      return (_random.nextBool() && _random.nextBool() && _random.nextBool()) ? 1 : 0;
    }
    if (_value >= .9) {
      return (_random.nextBool() && _random.nextBool()) ? 1 : 0;
    }
    if (_value >= .8) {
      return _random.nextBool() ? 1 : 0;
    }
    if (_value >= .6) {
      return _random.nextInt(3).clamp(0, 2);
    }
    return _random.nextInt(3).clamp(1, 2);
  }

  void _onTimer(Timer timer) {
    final n = _randomValue();
    if (n == 0) return;

    _value += n / 100;
    if (_value > 1.0) {
      _value = 1.0;
      _timer?.cancel();
      _timer = null;
    }
    setState(() {});
  }

  void _finishProgress() {
    if (_value >= 1.0) return;

    _timer?.cancel();
    _timer = null;

    // _valueController?.removeListener(_onFinishProgressUpdate);
    // _valueController?.dispose();

    _valueController = AnimationController(
      vsync: this,
      value: _value,
      lowerBound: _value,
      upperBound: 1.0,
      duration: widget.finishDuration,
    );
    _valueController?.addListener(_onFinishProgressUpdate);
    _valueController?.forward();
  }

  void _onFinishProgressUpdate() {
    if (_valueController != null) {
      _value = _valueController!.value;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: _value,
            strokeWidth: widget.strokeWidth,
            strokeCap: StrokeCap.round,
            backgroundColor: widget.backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              '${(_value * 100).round()}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _valueController?.removeListener(_onFinishProgressUpdate);
    _valueController?.dispose();
    _valueController = null;
    super.dispose();
  }
}
