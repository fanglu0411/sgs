// import 'dart:io';
// import 'dart:ui';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter_smart_genome/util/device_info.dart';
// import 'package:pty/pty.dart';
// import 'package:xterm/xterm.dart';
//
// TerminalBackend createLocalTerminalBackend({
//   VoidCallback onConnected,
//   ValueChanged<String> onResponse,
// }) =>
//     LocalBackend(onConnected: onConnected, onResponse: onResponse);
//
// class LocalBackend extends TerminalBackend {
//   PseudoTerminal _pty;
//
//   VoidCallback onConnected;
//   ValueChanged<String> _onResponse;
//
//   LocalBackend({
//     this.onConnected,
//     ValueChanged<String> onResponse,
//   }) {
//     _onResponse = onResponse;
//     if (!DeviceOS.isWindows) {
//       Directory.current = Platform.environment['HOME'] ?? '/';
//     }
//     print(Directory.current.absolute.path);
//
//     final shell = getShell();
//
//     _pty = PseudoTerminal.start(
//       shell,
//       ['-l'],
//       environment: {'TERM': 'xterm-256color'},
//     );
//     // write('echo OS="\$(uname -s)"\n');
//     // write('echo Terminal connected\n');
//     onConnected?.call();
//     // _pty.exitCode.then((_) {});
//   }
//
//   String getShell() {
//     if (DeviceOS.isWindows) {
//       // return r'C:\windows\system32\cmd.exe';
//       return r'C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe';
//     }
//
//     return Platform.environment['SHELL'] ?? 'sh';
//   }
//
//   @override
//   void ackProcessed() {
//     _pty.ackProcessed();
//   }
//
//   @override
//   Future<int> get exitCode => _pty.exitCode;
//
//   @override
//   void init() {
//     _pty.init();
//   }
//
//   @override
//   Stream<String> get out => _pty.out;
//
//   @override
//   void resize(int width, int height, int pixelWidth, int pixelHeight) {
//     _pty.resize(width, height);
//   }
//
//   @override
//   void terminate() {
//     _pty.kill();
//   }
//
//   @override
//   void write(String input) {
//     _pty.write(input);
//     // _onResponse?.call(input);
//   }
// }
