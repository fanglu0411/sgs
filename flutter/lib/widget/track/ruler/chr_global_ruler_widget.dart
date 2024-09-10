import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/ruler/chr_global_ruler_painter.dart';
import 'package:flutter_smart_genome/widget/track/track_group_logic.dart';

import '../chromosome/chromosome_data.dart';

class GlobalChrRulerWidget extends StatefulWidget {
  final ChromosomeData trackData;

  final double width;
  final Offset? panOrigin;
  final Range visibleRange;
  final ScaleLinear<num> scale;

  final Axis orientation;
  final String tag;

  final ValueChanged<Range>? onRangeChange;

  const GlobalChrRulerWidget({
    Key? key,
    required this.trackData,
    this.width = 30,
    this.panOrigin,
    required this.visibleRange,
    required this.scale,
    this.orientation = Axis.horizontal,
    this.onRangeChange,
    this.tag = 'group1',
  }) : super(key: key);

  @override
  ChrGlobalRulerWidgetState createState() => ChrGlobalRulerWidgetState();
}

class ChrGlobalRulerWidgetState extends State<GlobalChrRulerWidget> {
  Offset? _down;
  Offset? _delta;
  Offset? _cursor;

  ValueNotifier<Offset?>? get cursorNotifier => TrackGroupLogic.safe(tag: widget.tag)?.globalRulerCursorNotifier;

  @override
  void initState() {
    super.initState();
    cursorNotifier?.addListener(_onCursorChange);
  }

  void _onCursorChange() {
    if (null == cursorNotifier) return;
    updateCursor(cursorNotifier!.value);
  }

  void updateCursor(Offset? offset) {
    setState(() {
      _cursor = offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    double size = widget.width;
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    Color _priColor = Theme.of(context).colorScheme.primary;
    return Listener(
      onPointerHover: (h) {
        setState(() {
          _cursor = h.localPosition;
        });
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.precise,
        child: Container(
          constraints: widget.orientation == Axis.vertical ? BoxConstraints.expand(width: size) : BoxConstraints.expand(height: size),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (details) {
              // logger.i('tap down $details');
            },
            onPanDown: (downDetails) {
              setState(() {
                _down = downDetails.localPosition - Offset(2, 2);
                _delta = Offset(4, 4);
              });
            },
            onPanStart: (startDetails) {
              setState(() {
                _delta = startDetails.localPosition - _down!;
              });
            },
            onPanUpdate: (updateDetails) {
              setState(() {
                _delta = updateDetails.localPosition - _down!;
              });
            },
            onPanEnd: (endDetails) {
              _onPanEnd(_down!, _down! + _delta!);
              setState(() {
                _down = null;
                _delta = null;
              });
            },
            onPanCancel: () {
              _onPanEnd(_down!, _down! + _delta!, true);
              setState(() {
                _down = null;
                _delta = null;
              });
            },
            child: CustomPaint(
              painter: GlobalChrRulerPainter(
                visibleRange: widget.visibleRange,
                trackData: widget.trackData,
                panOrigin: widget.panOrigin,
                styleConfig: StyleConfig(
                  selectedColor: _dark ? _priColor.withAlpha(200) : _priColor.withAlpha(180),
                  brightness: Theme.of(context).brightness,
                  borderColor: _priColor,
                  backgroundColor: _dark ? Colors.grey[500] : Colors.white70,
                ),
                scale: widget.scale,
                orientation: widget.orientation,
                currentRange: widget.visibleRange,
                userStart: _down,
                userDelta: _delta,
                cursor: _cursor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onPanEnd(Offset start, Offset end, [bool cancel = false]) {
    _cursor = null;
    if (widget.onRangeChange == null) return;
//    print('==start $start, end $end cancel $cancel');
    bool _horizontal = widget.orientation == Axis.horizontal;
    if (cancel) {
      double half = widget.visibleRange.size / 2;
      Offset __start = (_down! + Offset(2, 2));
      var _start = widget.scale.invert(_horizontal ? __start.dx : __start.dy) - half;
      var _end = _start + half * 2;
      if (_start > _end) {
        var tmp = _end;
        _end = _start;
        _start = tmp;
      }
      widget.onRangeChange?.call(Range(start: _start, end: _end));
    } else {
      var _start = widget.scale.invert(_horizontal ? start.dx : start.dy);
      var _end = widget.scale.invert(_horizontal ? end.dx : end.dy);
      if (_start > _end) {
        var tmp = _end;
        _end = _start;
        _start = tmp;
      }
      widget.onRangeChange?.call(Range(start: _start, end: _end));
    }
  }

  @override
  void dispose() {
    cursorNotifier?.removeListener(_onCursorChange);
    super.dispose();
  }
}
