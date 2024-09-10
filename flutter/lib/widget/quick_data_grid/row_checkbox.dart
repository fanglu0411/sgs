import 'package:flutter/material.dart';

class RowCheckbox extends StatefulWidget {
  final bool value;
  final bool tristate;
  final ValueChanged<bool>? onChanged;

  const RowCheckbox({
    super.key,
    this.value = false,
    this.tristate = false,
    this.onChanged,
  });

  @override
  State<RowCheckbox> createState() => _RowCheckboxState();
}

class _RowCheckboxState extends State<RowCheckbox> {
  late bool _checked;
  late bool _tristate;

  @override
  void initState() {
    super.initState();
    _checked = widget.value;
    _tristate = widget.tristate;
  }

  @override
  void didUpdateWidget(covariant RowCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checked = widget.value;
    _tristate = widget.tristate;
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
        value: _checked,
        tristate: _tristate,
        onChanged: (v) {
          _checked = v ?? false;
          setState(() {});
          widget.onChanged?.call(_checked);
        });
  }
}
