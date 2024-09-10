// import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'title_bar_base.dart';

// import 'package:flutter_smart_genome/components/sgs_logo.dart';
//

class MacosTitleBar extends StatelessWidget with TitleBarMixin {
  final Widget child;
  final List<Widget>? leading;
  final List<Widget>? extras;

  const MacosTitleBar(
    this.child, {
    Key? key,
    this.leading,
    this.extras = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Padding(padding: EdgeInsets.only(left: 70), child: child);
    // return MoveWindow(
    //   child: child,
    // Padding(
    //   padding: const EdgeInsets.only(left: 70),
    //   child: child,
    // ),
    // );
    return Stack(
      children: [
        drawToMoveArea(child),
        if (leading != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [SizedBox(width: 70), ...leading!],
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (extras != null) ...extras!,
            ],
          ),
        ),
      ],
    );
  }
}
