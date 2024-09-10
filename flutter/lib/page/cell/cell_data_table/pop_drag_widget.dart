import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/split_widget.dart';
import 'package:get/get.dart';

class PopDragWidget extends StatefulWidget {
  final double minHeight;
  final double? maxHeight;
  final double? height;
  final ValueChanged<double>? onHeightChange;
  final Widget child;

  const PopDragWidget({super.key, required this.child, this.height, this.minHeight = 200, this.maxHeight = double.maxFinite, this.onHeightChange});

  @override
  State<PopDragWidget> createState() => _PopDragWidgetState();
}

class _PopDragWidgetState extends State<PopDragWidget> {
  late RxDouble _popTableHeight;

  @override
  void initState() {
    super.initState();
    _popTableHeight = (widget.height ?? widget.minHeight).obs;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.resizeRow,
          child: GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
              ),
              clipBehavior: Clip.hardEdge,
              child: DefaultSplitter(isHorizontal: false, splitterWidth: 6),
            ),
            onPanUpdate: (event) {
              var _h = _popTableHeight.value - event.delta.dy;
              if (_h < widget.minHeight) _h = widget.minHeight;
              if (_h > widget.maxHeight!) _h = widget.maxHeight!;
              _popTableHeight.value = _h;
              widget.onHeightChange?.call(_h);
            },
          ),
        ),
        ObxValue<RxDouble>(
          (h) => Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            constraints: BoxConstraints.expand(height: h.value),
            child: widget.child,
          ),
          _popTableHeight,
        ),
      ],
    );
  }
}
