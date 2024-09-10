import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/global_state.dart';
import 'package:flutter_smart_genome/components/window/multi_window_controller.dart';
import 'package:window_manager/window_manager.dart';

mixin TitleBarMixin {
  bool get isMainWindow => kWindowType == WindowType.main;

  Widget drawToMoveArea(Widget child) {
    if (isMainWindow) {
      return DragToMoveArea(child: child);
    }
    return SubWindowDragToMoveArea(child: child);
  }

  void minimizeWindow() async {
    if (isMainWindow) {
      windowManager.minimize();
    } else {
      WindowController.fromWindowId(kWindowId).minimize();
    }
  }

  void toggleMaximize() async {
    if (isMainWindow) {
      var _isMaximized = await windowManager.isMaximized();
      _isMaximized ? windowManager.unmaximize() : windowManager.maximize();
    } else {
      var widowController = WindowController.fromWindowId(kWindowId);
      var _isMaximized = await widowController.isMaximized();
      _isMaximized ? widowController.unmaximize() : widowController.maximize();
    }
  }

  void closeWindow() async {
    if (isMainWindow) {
      await windowManager.setPreventClose(false);
      await windowManager.close();
    } else {
      multiWindowController.notifyWindowCall(WindowType.main, WindowCallEvent.closeDataManager.name, {});
      await WindowController.fromWindowId(kWindowId).setPreventClose(false);
      await WindowController.fromWindowId(kWindowId).close();
    }
  }

  Future<bool> getMaximized() async {
    await Future.delayed(Duration(milliseconds: 200));
    var f = isMainWindow ? windowManager.isMaximized() : WindowController.fromWindowId(kWindowId).isMaximized();
    return await f;
  }

  Future<bool> getMinimized() async {
    await Future.delayed(Duration(milliseconds: 200));
    var f = isMainWindow ? windowManager.isMinimized() : WindowController.fromWindowId(kWindowId).isMinimized();
    return await f;
  }
}

class SubWindowDragToMoveArea extends StatelessWidget {
  const SubWindowDragToMoveArea({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        WindowController.fromWindowId(kWindowId).startDragging();
      },
      onDoubleTap: () async {
        var winController = WindowController.fromWindowId(kWindowId);
        bool isMaximized = await winController.isMaximized();
        if (!isMaximized) {
          winController.maximize();
        } else {
          winController.unmaximize();
        }
      },
      child: child,
    );
  }
}
