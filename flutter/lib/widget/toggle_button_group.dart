import 'package:flutter/material.dart';

class ToggleButtonGroup extends StatefulWidget {
  final List<Widget> children;
  final int? selectedIndex;
  final ValueChanged<int>? onChange;
  final BoxConstraints? constraints;
  final BorderRadius? borderRadius;
  final Color? selectedColor;
  final Color? fillColor;
  final Color? borderColor;
  final Color? highlightColor;
  final bool raido;
  final Axis direction;
  final bool buttonMode;

  const ToggleButtonGroup({
    Key? key,
    required this.children,
    this.selectedIndex,
    this.onChange,
    this.constraints,
    this.borderRadius,
    this.selectedColor,
    this.fillColor,
    this.borderColor,
    this.highlightColor,
    this.raido = true,
    this.buttonMode = false,
    this.direction = Axis.horizontal,
  }) : super(key: key);

  @override
  _ToggleButtonGroupState createState() => _ToggleButtonGroupState();
}

class _ToggleButtonGroupState extends State<ToggleButtonGroup> {
  late List<bool> toggleButtonStateList;
  late int _selectedTypeIndex;

  @override
  void initState() {
    toggleButtonStateList = widget.children.map<bool>((e) => false).toList();
    _selectedTypeIndex = widget.buttonMode ? -1 : widget.selectedIndex ?? 0;
    if (_selectedTypeIndex >= 0) toggleButtonStateList[_selectedTypeIndex] = true;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ToggleButtonGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      toggleButtonStateList = widget.children.map<bool>((e) => false).toList();
      _selectedTypeIndex = widget.buttonMode ? -1 : widget.selectedIndex ?? 0;
      if (_selectedTypeIndex >= 0) toggleButtonStateList[_selectedTypeIndex] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      splashColor: widget.fillColor,
      constraints: widget.constraints,
      borderRadius: widget.borderRadius,
      selectedColor: widget.selectedColor,
      fillColor: widget.fillColor,
      borderColor: widget.borderColor,
      highlightColor: widget.highlightColor,
      isSelected: toggleButtonStateList,
      onPressed: _onButtonTap,
      direction: widget.direction,
      children: widget.children,
    );
  }

  void _onButtonTap(int index) {
    if (widget.buttonMode) {
      widget.onChange?.call(index);
      return;
    }
    if (_selectedTypeIndex == index && widget.raido) {
      // toggleButtonStateList[index] = !toggleButtonStateList[index];
      return;
    }
    for (int buttonIndex = 0; buttonIndex < toggleButtonStateList.length; buttonIndex++) {
      if (buttonIndex == index) {
        toggleButtonStateList[buttonIndex] = !toggleButtonStateList[buttonIndex];
      } else {
        toggleButtonStateList[buttonIndex] = false;
      }
      _selectedTypeIndex = index;
    }
    setState(() {});
    if (null != widget.onChange) {
      widget.onChange!(_selectedTypeIndex);
    }
  }
}
