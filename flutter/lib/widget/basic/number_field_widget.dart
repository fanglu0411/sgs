import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';

class NumberFieldWidget extends StatefulWidget {
  final num value;
  final double width;
  final double? step;
  final double min;
  final double max;
  final bool? enabled;

  final ValueChanged<double>? onChanged;

  NumberFieldWidget({
    Key? key,
    this.value = 0.0,
    this.width = 68,
    this.step = 1.0,
    this.min = double.infinity,
    this.max = double.infinity,
    this.onChanged,
    this.enabled,
  }) : super(key: key);

  @override
  _NumberFieldWidgetState createState() => _NumberFieldWidgetState();
}

class _NumberFieldWidgetState extends State<NumberFieldWidget> {
  TextEditingController? _controller;
  num? _value;
  bool _valueEnabled = true;
  FocusNode? _focusNode;
  String? _error;
  Debounce? _debounce;

  @override
  void initState() {
    super.initState();
    _debounce = Debounce(milliseconds: 1000);
    _focusNode = FocusNode();
    _value = widget.value;
    _valueEnabled = widget.enabled == null || widget.enabled!;
    _controller = TextEditingController(text: formatNum(_value!));
    // _controller!.addListener(_debounceEditChange);
  }

  String formatNum(num value) {
    if (_value == null) return '';
    if (value is int) {
      return '${value}';
    }
    if (value - value.truncate() == 0) {
      return '${value.truncate()}';
    }
    return '${value.toStringAsFixed(value > 1 ? 1 : 2)}';
  }

  void _debounceEditChange(v) {
    _debounce?.run(_onEditChange);
  }

  void _onEditChange() {
    String value = _controller!.text;
    num? _newValue = num.tryParse(value);
    if (_newValue == null || _newValue == _value) return;

    var __error = null;
    if (widget.min != double.infinity && _newValue < widget.min) {
      _newValue = widget.min;
      String text = '${widget.min}';
      _controller!.value = _controller!.value.copyWith(
        text: text,
        selection: TextSelection(baseOffset: text.length, extentOffset: text.length),
      );
      __error = 'Min number is ${widget.min}';
      showToast(text: __error);
      return;
    }
    if (widget.max != double.infinity && _newValue > widget.max) {
      _newValue = widget.max;
      String text = '${widget.max}';
      _controller!.value = _controller!.value.copyWith(
        text: text,
        selection: TextSelection(baseOffset: text.length, extentOffset: text.length),
      );
      __error = 'Max number is ${widget.max}';
      showToast(text: __error);
      return;
    }
    _value = _newValue.toDouble();
    setState(() {});
    widget.onChanged?.call(_value!.toDouble());
  }

  @override
  void didUpdateWidget(NumberFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
    _valueEnabled = widget.enabled == null || widget.enabled!;
    _controller!.text = formatNum(_value!);
  }

  _onEnableChange(v) {
    _valueEnabled = v;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            padding: EdgeInsets.zero,
            splashRadius: 20,
            constraints: BoxConstraints.tightFor(width: 30, height: 30),
            icon: Icon(Icons.indeterminate_check_box),
            onPressed: (widget.min != double.infinity && _value == widget.min) || !_valueEnabled
                ? null
                : () {
                    double _newValue = (_value! - widget.step!);
                    if (widget.min != double.infinity && _newValue < widget.min) {
                      _newValue = widget.min;
                    }
                    _value = _newValue;
                    _controller!.text = formatNum(_newValue);
                    widget.onChanged?.call(_newValue);
                  },
          ),
          Container(
            width: widget.width,
            height: 28,
            child: TextField(
              maxLines: 1,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              // style: TextStyle(color: _error != null ? Colors.red : null),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: .3),
                ),
              ),
              controller: _controller,
              enabled: _valueEnabled,
              onChanged: _debounceEditChange,
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            icon: Icon(Icons.add_box),
            padding: EdgeInsets.zero,
            splashRadius: 20,
            constraints: BoxConstraints.tightFor(width: 30, height: 30),
            onPressed: (widget.max != double.infinity && _value == widget.max) || !_valueEnabled
                ? null
                : () {
                    double _newValue = _value! + widget.step!;
                    if (widget.max != double.infinity && _newValue > widget.max) {
                      _newValue = widget.max;
                    }
                    _value = _newValue;
                    _controller!.text = formatNum(_newValue);
                    widget.onChanged?.call(_newValue);
                  },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _debounce?.dispose();
    _controller?.dispose();
  }
}
