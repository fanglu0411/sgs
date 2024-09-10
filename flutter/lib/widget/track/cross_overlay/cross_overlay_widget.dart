import 'package:flutter/material.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/cross_overlay/cross_overlay_logic.dart';
import 'package:flutter_smart_genome/widget/track/cross_overlay/cross_overlay_painter.dart';
import 'package:flutter_smart_genome/widget/track/track_group_logic.dart';
import 'package:get/get.dart';

class CrossOverlayWidget extends StatefulWidget {
  final CursorSelection? selection;
  final String tag;

  const CrossOverlayWidget({
    Key? key,
    this.selection,
    this.tag = 'group1',
  }) : super(key: key);

  @override
  CrossOverlayWidgetState createState() => CrossOverlayWidgetState();
}

class CrossOverlayWidgetState extends State<CrossOverlayWidget> with SingleTickerProviderStateMixin {
  ValueNotifier<CursorSelection>? get positionNotifier => TrackGroupLogic.safe(tag: widget.tag)?.crossoverPositionNotifier;

  late CrossOverlayLogic _logic;

  // AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _logic = CrossOverlayLogic.safe() ?? Get.put(CrossOverlayLogic());
    _logic.setAnimationController(AnimationController(vsync: this, duration: Duration(milliseconds: 200)));
    // _selection = widget.selection;
    positionNotifier?.addListener(_onPositionChange);
  }

  void _onPositionChange() {
    // updatePosition(positionNotifier?.value);
    _logic.selection = positionNotifier?.value;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CrossOverlayLogic>(
      autoRemove: false,
      init: _logic,
      builder: _buildWidget,
    );
  }

  Widget _buildWidget(CrossOverlayLogic logic) {
    Range range = TrackGroupLogic.safe(tag: widget.tag)!.visibleRange;
    Scale<num, num> scale = TrackGroupLogic.safe(tag: widget.tag)!.linearScale!;
    return CustomPaint(
      painter: CrossOverlayPainter(
        selection: logic.selection,
        range: range,
        scale: scale,
        flashColor: logic.flashColor,
        flashRange: logic.flashRange,
      ),
    );
  }

  @override
  void dispose() {
    _logic.disposeAnimationController();
    positionNotifier?.removeListener(_onPositionChange);
    super.dispose();
  }
}
