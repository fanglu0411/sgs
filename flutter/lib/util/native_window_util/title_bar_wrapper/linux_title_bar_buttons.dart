// import 'package:bitsdojo_window/bitsdojo_window.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_font_icons/flutter_font_icons.dart';
//
// import 'linux_title_bar_icons.dart';
//
// class _LinuxWindowButton extends WindowButton {
//   _LinuxWindowButton({
//     Key? key,
//     required WindowButtonColors colors,
//     required WindowButtonIconBuilder iconBuilder,
//     required VoidCallback onPressed,
//   }) : super(
//           key: key,
//           colors: colors,
//           iconBuilder: iconBuilder,
//           builder: _linuxWindowButtonBuilder,
//           onPressed: onPressed,
//         );
// }
//
// class LinuxMinimizeButton extends _LinuxWindowButton {
//   LinuxMinimizeButton({
//     Key? key,
//     required WindowButtonColors colors,
//     VoidCallback onPressed,
//   }) : super(
//           key: key,
//           colors: colors,
//           iconBuilder: (buttonContext) => Icon(
//             MaterialCommunityIcons.window_minimize,
//             color: buttonContext.iconColor,
//           ),
//           onPressed: onPressed ?? () => appWindow.minimize(),
//         );
// }
//
// class LinuxMaximizeButton extends _LinuxWindowButton {
//   LinuxMaximizeButton({
//     Key? key,
//     required WindowButtonColors colors,
//     VoidCallback onPressed,
//   }) : super(
//           key: key,
//           colors: colors,
//           iconBuilder: (buttonContext) => Icon(
//             MaterialCommunityIcons.window_maximize,
//             color: buttonContext.iconColor,
//           ),
//           onPressed: onPressed ?? () => appWindow.maximizeOrRestore(),
//         );
// }
//
// class LinuxUnmaximizeButton extends _LinuxWindowButton {
//   LinuxUnmaximizeButton({
//     Key? key,
//     required WindowButtonColors colors,
//     VoidCallback onPressed,
//   }) : super(
//           key: key,
//           colors: colors,
//           iconBuilder: (buttonContext) => Icon(
//             MaterialCommunityIcons.window_restore,
//             color: buttonContext.iconColor,
//           ),
//           onPressed: onPressed ?? () => appWindow.maximizeOrRestore(),
//         );
// }
//
// class LinuxCloseButton extends _LinuxWindowButton {
//   LinuxCloseButton({
//     Key? key,
//     required WindowButtonColors colors,
//     VoidCallback onPressed,
//   }) : super(
//           key: key,
//           colors: colors,
//           iconBuilder: (buttonContext) => Icon(MaterialCommunityIcons.close, color: buttonContext.iconColor),
//           onPressed: onPressed ?? () => appWindow.close(),
//         );
// }
//
// Widget _linuxWindowButtonBuilder(WindowButtonContext context, Widget icon) {
//   return Container(
//     margin: EdgeInsets.all(5),
//     decoration: ShapeDecoration(shape: CircleBorder(), color: context.backgroundColor),
//     child: icon,
//   );
// }