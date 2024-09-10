// import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/util/native_window_util/title_bar_wrapper/linux_title_bar.dart';
import 'package:flutter_smart_genome/util/native_window_util/title_bar_wrapper/macos_title_bar.dart';
import 'package:flutter_smart_genome/util/native_window_util/title_bar_wrapper/tablet_title_bar.dart';
import 'package:flutter_smart_genome/util/native_window_util/title_bar_wrapper/windows_title_bar.dart';
import 'package:flutter_smart_genome/util/native_window_util/window_util.dart';
import 'package:window_manager/window_manager.dart';

IoUtils _instance = IoUtilsNative();
IoUtils getInstance() => _instance;

class IoUtilsNative implements IoUtils {
  IoUtilsNative() {}

  void showWindowWhenReady() {
    if (DeviceOS.isMobile) return;
    // doWhenWindowReady(() {
    //   final win = appWindow;
    //   win.minSize = Size(800, 600);
    //   win.size = DeviceOS.isMacOS ? Size(1680, 1024) : Size(1280, 720);
    //   win.alignment = Alignment.center;
    //   win.title = "SGS";
    //   win.show();
    // });
  }

  Widget wrapNativeTitleBarIfRequired(Widget child, {List<Widget>? leading, List<Widget>? extras = const []}) {
    if (DeviceOS.isLinux) {
      return LinuxTitleBar(child, leading: leading, extras: extras);
    } //
    else if (DeviceOS.isMacOS) {
      return MacosTitleBar(child, leading: leading, extras: extras);
    } //
    else if (DeviceOS.isWindows) {
      return WindowsTitleBar(child, leading: leading, extras: extras);
    }
    return TabletTitleBar(child, leading: leading, extras: extras);
  }

  @override
  void setTitle(String title) {
    // appWindow.title = title;
  }

  @override
  void closeWindow() {
    // appWindow.close();
  }

  @override
  Rect getWindowRect() {
    return Rect.zero;
    // return appWindow.rect;
  }

  @override
  Widget wrapDragToMoveIfRequired({required Widget child}) {
    return DragToMoveArea(child: child);
  }
}
