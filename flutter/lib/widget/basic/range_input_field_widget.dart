import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

class RangeInputFieldWidget extends StatefulWidget {
  final BoxDecoration? decoration;
  final double? inputWidth;
  final Widget? prefix;
  final Range? range;
  final bool autoFocus;
  final double borderWidth;
  final Brightness? brightness;
  final String submitText;

  final ValueChanged<Range>? onSubmit;

  const RangeInputFieldWidget({
    Key? key,
    this.decoration,
    this.inputWidth,
    this.prefix,
    this.range,
    this.onSubmit,
    this.autoFocus = false,
    this.borderWidth = 0,
    this.brightness,
    this.submitText = 'GO',
  }) : super(key: key);

  @override
  RangeInputFieldWidgetState createState() => RangeInputFieldWidgetState();
}

class RangeInputFieldWidgetState extends State<RangeInputFieldWidget> {
  late TextEditingController _startController;
  late TextEditingController _endController;
  Range? _range;
  late FocusNode _endFocusNode;

  @override
  void initState() {
    super.initState();
    _range = widget.range;
    _startController = TextEditingController(text: '${_range?.start.floor() ?? ''}');
    _endController = TextEditingController(text: '${_range?.end.floor() ?? ''}');
    _endFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(RangeInputFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.range != widget.range) {
      updateRange(widget.range);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _dark = (widget.brightness ?? Theme.of(context).brightness) == Brightness.dark;
    Color color = _dark ? Colors.white : Theme.of(context).colorScheme.primary;

    Widget startInput = TextField(
      controller: _startController,
      maxLines: 1,
      cursorColor: color,
      cursorWidth: 2.0,
      style: TextStyle(color: color),
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      autofocus: widget.autoFocus,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        isDense: true,
        focusColor: color,
        //labelText: 'start',
        hintText: '10,000,000',
        alignLabelWithHint: true,
        hintStyle: TextStyle(color: color.withOpacity(.5)),
        labelStyle: TextStyle(color: color.withOpacity(.8)),
        border: widget.borderWidth == 0 ? InputBorder.none : UnderlineInputBorder(),
        fillColor: Colors.white10,
      ),
      onSubmitted: (v) {
        _endFocusNode.requestFocus();
      },
    );

    if (widget.inputWidth == null) {
      startInput = Expanded(child: startInput);
    } else {
      startInput = SizedBox(
        width: widget.inputWidth,
        child: startInput,
      );
    }

    Widget endInput = TextField(
      controller: _endController,
      maxLines: 1,
      cursorColor: color,
      cursorWidth: 2.0,
      style: TextStyle(color: color),
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      focusNode: _endFocusNode,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        isDense: true,
        focusColor: color,
        //labelText: 'end',
        alignLabelWithHint: true,
        hintText: '20,000,000',
        hintStyle: TextStyle(color: color.withOpacity(.5)),
        labelStyle: TextStyle(color: color.withOpacity(.8)),
        border: widget.borderWidth == 0 ? InputBorder.none : UnderlineInputBorder(),
        fillColor: Colors.white10,
      ),
      onSubmitted: (v) => _onSubmit(),
    );
    if (widget.inputWidth == null) {
      endInput = Expanded(child: endInput);
    } else {
      endInput = SizedBox(
        width: widget.inputWidth,
        child: endInput,
      );
    }

    return Container(
      decoration: widget.decoration,
      // padding: EdgeInsets.symmetric(horizontal: 4),
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.prefix != null) widget.prefix!,
          startInput,
          Text('-', style: TextStyle(color: color)),
          endInput,
          TextButton(
//            color: Theme.of(context).colorScheme.primary,
            style: TextButton.styleFrom(
              textStyle: TextStyle(color: color),
              minimumSize: Size(30, 30),
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),

            child: DecoratedBox(
              decoration: BoxDecoration(
                // border: Border.all(color: Colors.white70),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Text(widget.submitText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
              ),
            ),
            //tooltip: 'Locate',
            onPressed: _onSubmit,
          ),
        ],
      ),
    );
  }

  void _onSubmit() {
    int? start = int.tryParse(_startController.text);
    int? end = int.tryParse(_endController.text);
    if (start == null || end == null) {
      showToast(text: 'start or end is invalid', align: Alignment(0, -.9));
      return;
    }
    if (start >= end) {
      showToast(text: 'end should be bigger than start', align: Alignment(0, -.9));
      return;
    }
    widget.onSubmit?.call(Range(start: start, end: end));
  }

  @override
  void dispose() {
    super.dispose();
    _startController.dispose();
    _endController.dispose();
  }

  void updateRange(Range? range) {
    _range = range;
    _startController.text = '${_range?.start.floor() ?? ''}';
    _endController.text = '${_range?.end.floor() ?? ''}';
  }
}
