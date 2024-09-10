// import 'package:bitsdojo_window/bitsdojo_window.dart';
// import 'package:flutter/material.dart';
//
// import 'linux_title_bar_buttons.dart';
//
// /// Native TitleBar for Linux, uses BitDojo platform
// class LinuxTitleBar extends StatelessWidget {
//   const LinuxTitleBar(this.child, {Key key}) : super(key: key);
//   final Widget child;
//
//   @override
//   Widget build(BuildContext context) {
//     ThemeData _theme = Theme.of(context);
//     final WindowButtonColors btnColors = WindowButtonColors(
//       iconNormal: Colors.black,
//       mouseOver: Colors.black.withOpacity(.1),
//       mouseDown: Colors.black.withOpacity(.2),
//       normal: Colors.transparent,
//     );
//     final WindowButtonColors closeBtnColors = WindowButtonColors(
//       normal: _theme.primaryColor,
//       iconNormal: _theme.primaryColor,
//     );
//
//     return Stack(
//       children: [
//         MoveWindow(
//           child: Padding(padding: EdgeInsets.only(right: 100.0, top: 10), child: child),
//         ),
//         Align(
//           alignment: Alignment.centerRight,
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               LinuxMinimizeButton(colors: btnColors),
//               appWindow.isMaximized ? LinuxUnmaximizeButton(colors: btnColors) : LinuxMaximizeButton(colors: btnColors),
//               LinuxCloseButton(colors: closeBtnColors),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'title_bar_base.dart';

/// Native TitleBar for Linux, uses BitDojo platform
class LinuxTitleBar extends StatefulWidget {
  const LinuxTitleBar(this.child, {Key? key, this.leading, this.extras = const []}) : super(key: key);
  final Widget child;
  final List<Widget>? leading;
  final List<Widget>? extras;

  @override
  State<LinuxTitleBar> createState() => _LinuxTitleBarState();
}

class _LinuxTitleBarState extends State<LinuxTitleBar> with TitleBarMixin {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    getMaximized().then((value) {
      _isMaximized = value;
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant LinuxTitleBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    getMaximized().then((value) {
      _isMaximized = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // ThemeData _theme = Theme.of(context);
    return Stack(
      children: [
        drawToMoveArea(widget.child),
        if (widget.leading != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.leading!,
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.extras != null) ...widget.extras!,
              MaterialButton(
                onPressed: minimizeWindow,
                child: Icon(Ionicons.ios_remove, size: 18),
                shape: RoundedRectangleBorder(),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                minWidth: 40,
              ),
              MaterialButton(
                onPressed: toggleMaximize,
                child: Icon(_isMaximized ? MaterialCommunityIcons.window_restore : Ionicons.ios_square_outline, size: 18),
                shape: RoundedRectangleBorder(),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                minWidth: 40,
              ),
              MaterialButton(
                onPressed: isMainWindow ? closeWindow : minimizeWindow,
                hoverColor: Colors.red,
                child: Icon(Ionicons.md_close, size: 18),
                shape: RoundedRectangleBorder(),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                minWidth: 40,
              )
            ],
          ),
        ),
      ],
    );
  }
}
