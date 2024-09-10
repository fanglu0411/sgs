import 'package:flutter/material.dart';

class HoverEditableWidget extends StatefulWidget {
  final Widget child;
  final Widget fontChild;
  final BoxConstraints? constraints;
  final GestureTapCallback? onTap;
  final Color? hoverColor;

  const HoverEditableWidget({
    Key? key,
    required this.fontChild,
    required this.child,
    this.onTap,
    this.constraints,
    this.hoverColor,
  }) : super(key: key);

  @override
  _HoverEditableWidgetState createState() => _HoverEditableWidgetState();
}

class _HoverEditableWidgetState extends State<HoverEditableWidget> {
  bool _hovered = false;

  _onHoverChange(hover) {
    setState(() {
      _hovered = hover;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary.withAlpha(50),
      child: InkWell(
        hoverColor: widget.hoverColor ?? Theme.of(context).colorScheme.primary.withAlpha(100),
        onHover: _onHoverChange,
        onTap: widget.onTap,
        child: Container(
          constraints: widget.constraints,
          child: Stack(
//        fit: StackFit.expand,
            children: <Widget>[
              widget.child,
              if (_hovered) widget.fontChild,
            ],
          ),
        ),
      ),
    );
  }
}
