import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  final double height;
  final bool checked;
  final ValueChanged<bool>? onChanged;
  final Widget label;
  final String? tooltip;
  final bool border;
  final OutlinedBorder shape;
  final double borderWidth;
  final EdgeInsetsGeometry padding;

  const ToggleButton({
    Key? key,
    this.height = 26,
    this.onChanged,
    this.checked = false,
    this.tooltip,
    this.shape = const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
    this.border = true,
    this.borderWidth = .5,
    required this.label,
  }) : super(key: key);

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.checked;
  }

  @override
  void didUpdateWidget(ToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checked = widget.checked;
  }

  @override
  Widget build(BuildContext context) {
    Widget btn = OutlinedButton(
      onPressed: _onPressed,
      child: widget.label,
      style: OutlinedButton.styleFrom(
        padding: widget.padding,
        minimumSize: Size(16, widget.height),
        foregroundColor: _checked ? Theme.of(context).colorScheme.primary : Theme.of(context).unselectedWidgetColor,
        elevation: 0,
        shape: widget.shape,
        side: widget.border ? BorderSide(color: _checked ? Theme.of(context).colorScheme.primary : Theme.of(context).unselectedWidgetColor, width: widget.borderWidth) : BorderSide.none,
      ),
    );
    if (widget.tooltip != null) {
      btn = Tooltip(
        message: widget.tooltip,
        child: btn,
      );
    }
    return btn;
  }

  void _onPressed() {
    _checked = !_checked;
    setState(() {});
    widget.onChanged?.call(_checked);
  }
}
