import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/window/prompt_window.dart';
import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/util/socket_server_manager.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:win32_registry/win32_registry.dart';
import '../platform/platform_adapter.dart';
import 'package:path/path.dart' as _path;
import 'package:window_size/window_size.dart' as window_size;
import 'dart:math' show max;

PlatformAdapter createPlatformAdapter() => NativeAdapter();

class NativeAdapter implements PlatformAdapter {
  static NativeAdapter _instance = NativeAdapter._init();

  factory NativeAdapter() => _instance;

  NativeAdapter._init() {}

  String getLocationOrigin() {
    return '';
  }

  String getLocationHost() {
    return "";
  }

  String getLocationUrl() {
    return '';
  }

  void updateUrl(String url) {}

  @override
  Future deleteCacheFile(String path) async {
    if (FileSystemEntity.isDirectorySync(path)) {
      Directory dir = Directory(path);
      if (dir.existsSync()) {
        await dir.delete(recursive: true);
      }
    } else if (FileSystemEntity.isFileSync(path)) {
      final file = File(path);
      file.deleteSync(recursive: true);
    }
  }

  @override
  Future<T?> openUrl<T extends Object>(BuildContext context, String url,
      {Object? arguments}) {
    var _url = url;
    if (url.startsWith('/#')) _url = url.substring(2);
    return Navigator.of(context).pushNamed<T>(_url, arguments: arguments);
  }

  @override
  Future<bool> saveFile({String? filename, content}) async {
    String? path = await FilePicker.platform.saveFile(fileName: filename);

    if (path == null) return false;
    File file = File(path);
    if (await file.exists()) {
    } else {
      file.createSync(recursive: true);
    }
    await file.writeAsString(content, flush: true);
    return true;
  }

  @override
  List<SiteItem> getDefaultSite() {
    return [
      SiteItem(
        isDemoServer: true,
        url: 'http://192.168.1.202:6102',
      ),
    ];
  }

  @override
  void openWindow(WindowDataSource dataSource) async {
    var exePath = await _checkPlugin();
    if (exePath == null) {
      showErrorNotification(title: Text('Plugin not found'));
      return;
    }
    bool connected = SocketServerManager().isClientConnected();
    _sendData(dataSource);

    if (connected) {
      return;
    }

    OpenFile.open(exePath).then((rst) {
      print('${rst.type} ${rst.message}');
      if (rst.type != ResultType.done) {
        _tryOpenPrompt(exePath);
      }
    });
  }

  _tryOpenPrompt(String path) {
    Process.run(
      path,
      [
        // '-a',
        // exePath,
      ],
      runInShell: true,
    ).then((rst) {
      // print('err: ${rst.stderr}');
      // print('cmd out: ${rst.stdout}');
      if (rst.stderr != null) showToast(text: rst.stderr);
    });
  }

  @override
  void openBrowser(String url) {
    // var _loading = BotToast.showLoading();
    OpenFile.open(url).then((rst) {
      // _loading?.call();
      if (rst.type != ResultType.done) {
        Get.showSnackbar(GetSnackBar(
            title: 'Error',
            message: '${rst.message}',
            icon: Icon(Icons.error)));
        if (DeviceOS.isWindows)
          _exeCommand(cmd: 'start', params: ['iexplore.exe', url]);
      }
    }).catchError((e) {});
  }

  void _exeCommand({required String cmd, required List<String> params}) {
    Process.run(
      cmd,
      params,
      runInShell: true,
    ).then((rst) {
      if (rst.exitCode != 0) {
        Get.showSnackbar(GetSnackBar(
          title: 'Error code: ${rst.exitCode}',
          message: '${rst.stderr}.',
          icon: Icon(Icons.error),
          duration: Duration(seconds: 8),
        ));
      }
    });
  }

  Future<String?> _checkPlugin() async {
    File _exeFile = File(Platform.resolvedExecutable);
    Directory exeDirectory = _exeFile.parent;

    if (DeviceOS.isWindows) {
      File _promptFile = File(_path.join(exeDirectory.path,
          'flutter_sgs_prompt_window', 'flutter_sgs_prompt_window.exe'));
      return _promptFile.path;
    } else if (DeviceOS.isMacOS) {
      File _promptFile = File(_path.join(exeDirectory.parent.parent.parent.path,
          'flutter_sgs_prompt_window.app'));
      return _promptFile.path;
    } else if (DeviceOS.isLinux) {
      File _promptFile = File(_path.join(exeDirectory.path,
          'flutter_sgs_prompt_window', 'flutter_sgs_prompt_window'));
      return _promptFile.path;
    }
    return null;
  }

  void _sendData(WindowDataSource windowDataSource) async {
    try {
      SocketServerManager().sendData(windowDataSource.toString());
    } catch (e) {
      Get.log.printError(info: '${e}');
    }
  }

  @override
  void openTerminal(List<String> params) {
    _exeCommand(
      cmd: 'open',
      params: [
        // '-c',
        // 'open -a /System/Applications/Utilities/Terminal.app ./deploy-sgs.sh'
        '-a',
        'Terminal.app',
        './deploy-sgs.sh',
      ],
    );
  }

  @override
  void setWindowSize(Size size,
      {bool center = true, bool fullscreen = false}) async {
    print('set window size $size, fullscreen: $fullscreen, center: $center');
    // windowManager.setSizeAlignment(size,  Alignment.center);
    window_size.getWindowInfo().then((window) {
      if (window.screen != null) {
        final screenFrame = window.screen!.visibleFrame;
        final width = fullscreen
            ? max((screenFrame.width * .75).roundToDouble(), 1920.0)
                .clamp(800.0, screenFrame.width)
            : size.width;
        final height = fullscreen
            ? max((screenFrame.height * .75).roundToDouble(), 1080.0)
                .clamp(600.0, screenFrame.height)
            : size.height;

        // final width =size.width;
        // final height =size.height;
        final left = screenFrame.left +
            ((screenFrame.width - width) / 2).roundToDouble();
        final top = screenFrame.top +
            ((screenFrame.height - height) / 2).roundToDouble();
        final frame = Rect.fromLTWH(left, top, width, height);
        window_size.setWindowMinSize(Size(1200, 720));
        //设置窗口信息
        window_size.setWindowFrame(frame);
      }
    });
  }

  @override
  Future registrySchema(String scheme) async {
    if (!Platform.isWindows) return;
    String appPath = Platform.resolvedExecutable;
    String protocolRegKey = 'Software\\Classes\\$scheme';
    RegistryValue protocolRegValue = const RegistryValue(
      'URL Protocol',
      RegistryValueType.string,
      '',
    );
    String protocolCmdRegKey = 'shell\\open\\command';
    RegistryValue protocolCmdRegValue = RegistryValue(
      '',
      RegistryValueType.string,
      '"$appPath" "%1"',
    );

    final regKey = Registry.currentUser.createKey(protocolRegKey);
    regKey.createValue(protocolRegValue);
    regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);
  }
}
