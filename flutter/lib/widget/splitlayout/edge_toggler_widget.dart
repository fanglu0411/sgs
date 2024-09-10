import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/splitlayout/side_tab_item.dart';

class EdgeToggleWidget extends StatefulWidget {
  final PanelPosition position;
  final double width;
  final VoidCallback? onPressed;

  const EdgeToggleWidget({
    Key? key,
    required this.position,
    this.width = 32.0,
    this.onPressed,
  }) : super(key: key);

  @override
  _EdgeToggleWidgetState createState() => _EdgeToggleWidgetState();
}

class _EdgeToggleWidgetState extends State<EdgeToggleWidget> {
  @override
  Widget build(BuildContext context) {
    bool hor = widget.position == PanelPosition.left || widget.position == PanelPosition.right;
    double? width = hor ? widget.width : null;
    double? height = hor ? widget.width : null;
    var _icon = hor ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up;

    Widget button = TextButton(
      onPressed: widget.onPressed,
      child: Icon(_icon),
    );
    if (hor) {
      int truns = 0;
      if (widget.position == PanelPosition.left) truns = -1;
      if (widget.position == PanelPosition.right) truns = 1;
      button = RotatedBox(quarterTurns: truns, child: button);
    }
    var border = BorderSide(color: Theme.of(context).dividerColor, width: 1.5);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: widget.position == PanelPosition.bottom ? border : BorderSide.none,
          right: widget.position == PanelPosition.left ? border : BorderSide.none,
          left: widget.position == PanelPosition.right ? border : BorderSide.none,
          bottom: widget.position == PanelPosition.top ? border : BorderSide.none,
        ),
      ),
      constraints: BoxConstraints.expand(width: width, height: height),
      child: button,
    );
  }
}
