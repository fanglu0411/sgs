library native_utils;

import 'package:flutter/material.dart';

import 'window_util_no_op.dart' if (dart.library.io) 'window_util_native.dart' as pkg;

abstract class IoUtils {
  static IoUtils get instance => pkg.getInstance();

  void setTitle(String title);
  void showWindowWhenReady();
  Widget wrapNativeTitleBarIfRequired(Widget child, {List<Widget>? leading, List<Widget>? extras});
  Widget wrapDragToMoveIfRequired({required Widget child});
  void closeWindow();
  Rect getWindowRect();
}