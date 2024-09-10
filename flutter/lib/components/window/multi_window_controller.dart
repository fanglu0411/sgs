import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_genome/base/global_state.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bloc/track_config/bloc.dart';
import 'package:flutter_smart_genome/service/public_service.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

import 'package:flutter_smart_genome/util/device_info.dart';

enum WindowType {
  main,
  dataManager,
  setting,
}

WindowType fromIndex(int index) {
  return WindowType.values[index];
}

final multiWindowController = MultiWindowController();

enum WindowCallEvent {
  changeTheme,
  changeAdminServerSite,
  logout,
  closeDataManager,
  updateLastDataPath,
  addData,
  deleteData,
}

class MultiWindowController {
  static final MultiWindowController _instance = MultiWindowController._init();

  MultiWindowController._init() {}

  factory MultiWindowController() {
    return _instance;
  }

  Map<WindowType, int> _windowIdMap = {};

  Future<WindowController> openDataManager({required AccountBean account}) async {
    // await closeWindows(WindowType.dataManager); // linux will exit main
    return _createWindow(
      windowType: WindowType.dataManager,
      title: 'SGS Data Manager',
      extras: {
        "account": account.toJson()..removeWhere((k, v) => v == null),
      },
    );
  }

  Future<WindowController> _createWindow({
    required WindowType windowType,
    String title = '',
    Map extras = const {},
  }) async {
    int themeIndex = PublicService.get()!.themeIndex;
    var params = {"type": windowType.index, "theme": themeIndex, 'themeMode': PublicService.get()!.themeMode.index, 'title': title, ...extras};
    final msg = json.encode(params);
    var _windowId = _windowIdMap[windowType];
    try {
      final ids = await DesktopMultiWindow.getAllSubWindowIds();
      if (!ids.contains(_windowId)) {
        _windowId = null;
      }
    } on Error {
      _windowId = null;
    }
    if (_windowId == null) {
      final windowController = await DesktopMultiWindow.createWindow(msg);
      windowController
        ..setFrame(const Offset(0, 0) & const Size(1280, 720))
        ..center()
        ..setTitle(title);
      if (DeviceOS.isMacOS || DeviceOS.isLinux) {
        Future.microtask(() => windowController.show());
      }
      registerActiveWindow(windowType, windowController);
      return windowController;
    } else {
      /// window already exists
      var controller = WindowController.fromWindowId(_windowId)
        ..focus()
        ..show();
      notifyWindowCall(windowType, WindowCallEvent.changeAdminServerSite.name, params['account']);
      return controller;
    }
  }

  /// 接收其他窗口发送过来的消息
  Future<dynamic> handleMessage(MethodCall call, fromWindowId) async {
    debugPrint('from:${fromWindowId}, method: ${call.method}, arg: ${call.arguments}');
    if (call.method == WindowCallEvent.changeTheme.name) {
      PublicService.get()!.changeTheme(call.arguments);
      return true;
    } else if (call.method == WindowCallEvent.changeAdminServerSite.name) {
      Map _account = call.arguments;
      AccountBean bean = AccountBean.fromMap(_account);
      //reload window
      accountObs.value = bean;
    } else if (call.method == WindowCallEvent.logout.name) {
      Map account = call.arguments;
      BaseStoreProvider.get().deleteAccountByUrl(account['url']);
    } else if (call.method == WindowCallEvent.closeDataManager.name) {
      await closeWindows(WindowType.dataManager);
    } else if (call.method == WindowCallEvent.updateLastDataPath.name) {
      Map account = call.arguments;
      BaseStoreProvider.get().setAccount(AccountBean.fromMap(account));
    } else if (call.method == WindowCallEvent.addData.name) {
      Map params = call.arguments;
      var speciesId = params['speciesId'];
      if (speciesId == SgsAppService.get()!.session!.speciesId) {
        SgsAppService.get()!.sendEvent(ForceUpdateTracksEvent());
      }
    } else if (call.method == WindowCallEvent.deleteData.name) {
      Map params = call.arguments;
      var speciesId = params['speciesId'];
      if (speciesId == SgsAppService.get()!.session!.speciesId) {
        SgsAppService.get()!.sendEvent(ForceUpdateTracksEvent());
      }
    }
  }

  ///设置当前窗口接收消息的回调函数
  void setMethodHandler(Future<dynamic> Function(MethodCall call, int fromWindowId) handler) {
    DesktopMultiWindow.setMethodHandler(handler);
  }

  /// 给指定窗口发送消息，这个方法只能从主窗口发，否则 findWindow 找不到id
  void notifyWindowCall(WindowType windowType, String method, dynamic args) {
    int? window = findWindow(windowType);
    if (null == window) return;
    DesktopMultiWindow.invokeMethod(window, method, args);
  }

  void notifyMainWindow(String method, dynamic args) {
    DesktopMultiWindow.invokeMethod(0, method, args);
  }

  /// 关闭所有字窗口， 只能从主窗口调用
  Future<void> closeAllSubWindows() async {
    await Future.wait(_windowIdMap.entries.map((e) => closeWindows(e.key)));
  }

  //关闭当前窗口
  closeSelf() async {
    await WindowController.fromWindowId(kWindowId).setPreventClose(false);
    WindowController.fromWindowId(kWindowId).close();
  }

  /// 关闭窗口
  Future<void> closeWindows(WindowType windowType) async {
    if (windowType == WindowType.main) {
      // skip main window, use window manager instead
      return;
    }
    int? wId = _windowIdMap[windowType];
    if (wId != null) {
      debugPrint("closing multi window: ${windowType.toString()}");
      await saveWindowPosition(windowType, wId);
      try {
        final ids = await DesktopMultiWindow.getAllSubWindowIds();
        if (ids.contains(wId)) {
          await WindowController.fromWindowId(wId).setPreventClose(false);
          await WindowController.fromWindowId(wId).close();
          // unregister the sub window in the main window.
        }
        // no such window already
      } catch (e) {
        debugPrint("$e");
      } finally {
        unRegisterWindow(windowType);
      }
    }
  }

  int? findWindow(WindowType type) {
    return _windowIdMap[type];
  }

  registerActiveWindow(WindowType type, WindowController windowController) {
    _windowIdMap[type] = windowController.windowId;
  }

  unRegisterWindow(WindowType type) {
    _windowIdMap.removeWhere((t, value) => t == type);
  }

  Future saveWindowPosition(WindowType type, int windowId) async {
    var controller = WindowController.fromWindowId(windowId);
  }
}
