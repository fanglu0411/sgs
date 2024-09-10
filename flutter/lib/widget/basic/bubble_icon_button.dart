import 'package:flutter/material.dart';

extension BubbleExtension on Widget {
  Widget withBubble({
    String? text,
    Widget? child,
    double radius = 8,
    Color bubbleColor = Colors.redAccent,
    double right = 2,
    double top = 2,
  }) {
    if (text == null && child == null) return this;
    Widget? label = child ?? (text != null ? Text('${text}', style: TextStyle(fontSize: 10, color: Colors.white), maxLines: 1) : null);

    // return Badge(
    //   backgroundColor: bubbleColor,
    //   label: label,
    //   textColor: Colors.white,
    //   smallSize: 10,
    //   largeSize: 10,
    //   padding: EdgeInsets.zero,
    //   child: this,
    //   offset: Offset(right, top),
    // );

    return Stack(
      children: <Widget>[
        this,
        Positioned(
          child: CircleAvatar(
            radius: radius,
            backgroundColor: bubbleColor,
            child: label,
          ),
          right: right,
          top: top,
        ),
      ],
    );
  }
}