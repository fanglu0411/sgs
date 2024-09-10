// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_smart_genome/components/terminal/ssh_terminal.dart';
// import 'package:xterm/xterm.dart';
//
// class TerminalSideWidget extends StatefulWidget {
//   const TerminalSideWidget({Key key}) : super(key: key);
//
//   @override
//   _TerminalSideWidgetState createState() => _TerminalSideWidgetState();
// }
//
// class _TerminalSideWidgetState extends State<TerminalSideWidget> {
//   Terminal _terminal;
//
//   // MyBackend _backend;
//   SSHTerminalBackend _backend;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _backend = SSHTerminalBackend('ssh://119.23.79.220:10022', 'bio_test', '');
//
//     _terminal = Terminal(
//       backend: _backend,
//       maxLines: 1000,
//       onTitleChange: (t) {},
//       platform: getPlatform(),
//       theme: TerminalThemes.defaultTheme,
//     );
//     _backend.exitCode.then((value) {
//       print('exit code: ${value}');
//     });
//   }
//
//   PlatformBehavior getPlatform() {
//     if (Platform.isWindows) {
//       return PlatformBehaviors.windows;
//     }
//     return PlatformBehaviors.unix;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         children: [
//           Expanded(
//             child: TerminalView(
//               terminal: _terminal,
//             ),
//           ),
//           // Container(
//           //   padding: EdgeInsets.symmetric(vertical: 10),
//           //   child: SimpleInputField(
//           //     onSubmitted: (v) {
//           //       _backend.write('${v}\n');
//           //     },
//           //   ),
//           // )
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
