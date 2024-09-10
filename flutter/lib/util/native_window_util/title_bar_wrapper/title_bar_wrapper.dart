import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/util/native_window_util/window_util.dart';

Widget TitleBarWrapper({
  required Widget child,
  List<Widget>? extras,
  List<Widget>? leading,
}) {
  return IoUtils.instance.wrapNativeTitleBarIfRequired(
    child,
    extras: extras ?? [],
    leading: leading,
  );
}

Widget MoveAreaWrapper({Widget child = const SizedBox(), double height = 36, Color? color}) {
  return IoUtils.instance.wrapDragToMoveIfRequired(
    child: Container(
      child: child,
      color: color,
      constraints: BoxConstraints.expand(height: height),
    ),
  );
}

class TitleBarWrapper2 extends StatelessWidget {
  final Widget child;
  final List<Widget> extras;
  final double? height;

  const TitleBarWrapper2({Key? key, required this.child, this.height, this.extras = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IoUtils.instance.wrapNativeTitleBarIfRequired(child, extras: extras);
    // return Container(
    //   child: IoUtils.instance.wrapNativeTitleBarIfRequired(child, extras: extras),
    //   constraints: BoxConstraints.expand(height: height ?? HORIZONTAL_TOOL_BAR_HEIGHT),
    // );
  }
}
