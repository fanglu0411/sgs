import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

class ScrollControllerBuilder extends StatefulWidget {
  final Function2<BuildContext, ScrollController, Widget> builder;
  final ScrollController? controller;

  const ScrollControllerBuilder({
    Key? key,
    required this.builder,
    this.controller,
  }) : super(key: key);

  @override
  _ScrollControllerBuilderState createState() => _ScrollControllerBuilderState();
}

class _ScrollControllerBuilderState extends State<ScrollControllerBuilder> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder.call(context, _controller);
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.controller == null) _controller.dispose();
  }
}