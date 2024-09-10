import 'package:flutter/material.dart';

//
class WebTitleBar extends StatelessWidget {
  final Widget child;
  final List<Widget>? leading;
  final List<Widget>? extras;
  const WebTitleBar(
    this.child, {
    Key? key,
    this.leading,
    this.extras = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (leading != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [...leading!],
            ),
          ),
        child,
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if(extras != null) ...extras!,
            ],
          ),
        ),
      ],
    );
  }
}