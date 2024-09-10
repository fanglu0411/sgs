import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

class SliderWidget extends StatefulWidget {
  final ValueChanged<double>? onChanged;
  final double value;
  final double min;
  final double max;
  final bool isColor;
  final String? label;
  final int? divisions;
  final Function1<double, String>? labelFormatter;

  const SliderWidget({
    Key? key,
    this.onChanged,
    this.divisions,
    this.isColor = false,
    this.label,
    required this.value,
    required this.min,
    required this.max,
    this.labelFormatter,
  }) : super(key: key);

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant SliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) Text('${widget.label ?? 'Value'}'),
        Slider(
          min: widget.min,
          max: widget.max,
          divisions: widget.divisions,
          activeColor: widget.isColor ? Theme.of(context).colorScheme.primary.withOpacity(_value) : Theme.of(context).colorScheme.primary,
          value: _value,
          label: widget.labelFormatter?.call(_value) ?? '${_value.toStringAsFixed(1)}',
          autofocus: true,
          onChanged: (v) {
            _value = v;
            setState(() {});
            widget.onChanged?.call(v);
          },
        ),
      ],
    );
  }
}
