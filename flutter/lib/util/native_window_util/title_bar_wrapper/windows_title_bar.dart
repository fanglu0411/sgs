// import 'package:bitsdojo_window/bitsdojo_window.dart';
// import 'package:flutter/material.dart';
//
// /// Native TitleBar for Windows, uses BitDojo platform
// class WindowsTitleBar extends StatelessWidget {
//   const WindowsTitleBar(this.child, {Key key}) : super(key: key);
//   final Widget child;
//
//   @override
//   Widget build(BuildContext context) {
//     bool _dark = Theme.of(context).brightness == Brightness.dark;
//     Color _priColor = Theme.of(context).colorScheme.primary;
//     final WindowButtonColors _btnColors = WindowButtonColors(
//       iconNormal: _dark ? Colors.white : Colors.black,
//       iconMouseOver: Colors.white,
//       iconMouseDown: Colors.white,
//       mouseOver: _priColor,
//       mouseDown: _priColor.withOpacity(.8),
//       normal: Colors.black.withOpacity(0),
//     );
//     final WindowButtonColors _closeBtnColors = WindowButtonColors(
//       iconNormal: _dark ? Colors.white : Colors.black,
//       mouseOver: Color(0xFFD32F2F),
//       mouseDown: Color(0xFFB71C1C),
//     );
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         MoveWindow(
//           child: Padding(
//             padding: EdgeInsets.only(right: 130.0),
//             child: child,
//           ),
//         ),
//         Align(
//           alignment: Alignment.topRight,
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               MinimizeWindowButton(colors: _btnColors),
//               MaximizeWindowButton(colors: _btnColors),
//               CloseWindowButton(colors: _closeBtnColors),
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

/// Native TitleBar for Windows
class WindowsTitleBar extends StatefulWidget {
  final List<Widget>? extras;
  final List<Widget>? leading;

  const WindowsTitleBar(
    this.child, {
    Key? key,
    this.leading,
    this.extras = const [],
  }) : super(key: key);
  final Widget child;

  @override
  State<WindowsTitleBar> createState() => _WindowsTitleBarState();
}

class _WindowsTitleBarState extends State<WindowsTitleBar> with TitleBarMixin {
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
  void didUpdateWidget(covariant WindowsTitleBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    getMaximized().then((value) {
      _isMaximized = value;
      if (mounted) setState(() {});
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
                onPressed: closeWindow,
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
