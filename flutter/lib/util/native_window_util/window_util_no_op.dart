import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/util/native_window_util/title_bar_wrapper/web_title_bar.dart';

import 'window_util.dart';

IoUtils _instance = IoUtilsNoOp();
IoUtils getInstance() => _instance;

class IoUtilsNoOp implements IoUtils {
  void showWindowWhenReady() {}
  Widget wrapNativeTitleBarIfRequired(Widget child, {List<Widget>? leading, List<Widget>? extras = const []}) {
    return WebTitleBar(child, leading: leading, extras: extras);
  }

  void setMinSize(Size size) {}

  @override
  void setTitle(String title) {}

  @override
  void closeWindow() {}

  @override
  Rect getWindowRect() {
    return Rect.zero;
  }

  @override
  Widget wrapDragToMoveIfRequired({required Widget child}) {
    return child;
  }
}