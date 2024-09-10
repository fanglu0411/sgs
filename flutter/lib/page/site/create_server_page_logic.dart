import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/page/site/password_field.dart';
import 'package:flutter_smart_genome/platform/platform_adapter.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';
import 'package:flutter_smart_genome/storage/isar/site_provider.dart';

import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/widget/basic/alert_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter_smart_genome/widget/basic/fast_rich_text.dart';
import 'package:get/get.dart';
import 'package:xterm/xterm.dart';

class StepItem {
  StepType? type;
  final String title;
  final String? subtitle;
  final String? content;
  final String? command;

  bool active = false;

  StepItem({
    this.type,
    required this.title,
    this.subtitle,
    this.content,
    this.command,
    this.active = false,
  });
}

enum StepType {
  choose_target,
  connect_server,
  set_params,
  // check_permission,
  deploy_sgs,
  install_finish,
  error,
}

enum SgsTarget {
  local,
  remote,
}

class StepResponse {
  late List<String> _data;

  StepResponse() {
    _data = [];
  }

  add(String line) {
    _data.add(line);
  }

  String print() {
    return _data.join('\n');
  }
}

class CreateServerPageLogic extends GetxController {
  String? error;
  SgsTarget? target;

  Terminal? _terminal;
  Pty? pty;

  SSHClient? _sshClient;

  SSHClient? get sshClient => _sshClient;

  SSHSession? _shell;

  StepType? _currentStep;

  StepType? get currentStep => _currentStep;

  StepState get stepState {
    if (_currentStep == StepType.error) return StepState.error;
    if (_currentStep == StepType.install_finish) return StepState.complete;
    return StepState.indexed;
  }

  String? _sgsPath;

  String? get sgsPath => _sgsPath;

  Map _scriptParams = {};

  String? _remoteHost;

  String? get remoteHost => _remoteHost;

  String get host => _remoteHost != null ? _remoteHost!.split(':').first : '0.0.0.0';

  CancelFunc? _loading;

  RxString deployStatusMessage = ''.obs;

  String get apiUrl => "http://${host}:${_scriptParams['api_port']}";

  String get webUrl => "http://${host}:${_scriptParams['web_port']}";

  String getDeployScript(Map params, String sudoName) {
    return [
      '( curl -fsSL https://gitee.com/Orth/sgs-site/raw/master/deploy.sh -o deploy-sgs.sh || wget -q https://gitee.com/Orth/sgs-site/raw/master/deploy.sh -O deploy-sgs.sh )',
      // 'curl -fsSL https://gitee.com/Orth/sgs-site/raw/master/deploy-compose.sh -o deploy-sgs-compose.sh',
      // 'curl -fsSL https://gitee.com/Orth/sgs-site/raw/master/docker-compose.yaml -o docker-compose.yaml',
      '${sudoName} chmod 777 deploy-sgs.sh',
      '${sudoName} bash deploy-sgs.sh DATA_PATH="${params['data_path']}" SERVER_HOST=${params['server_host']} DB_PORT=${params['mysql_port']} API_PORT=${params['api_port']} WEB_PORT=${params['web_port']}',
    ].join(' && ');
  }

  String? _title;

  String? get title => _title;

  String? _token;

  String? get token => _token;

  String? get parseToken {
    if (null == _token) return null;
    try {
      var _t = json.decode(_token!.trim());
      return _t['token'];
    } catch (e) {
      return e.toString();
    }
  }

  Map<StepType, StepResponse> _stepResponse = {};

  Terminal? get terminal => _terminal;

  String get defaultDataPath {
    return targetIsMac ? r'$HOME/docker/vol/sgs' : '/data/docker/vol/sgs';
  }

  void onInit() {
    super.onInit();
    _currentStep = StepType.choose_target;
  }

  @override
  void onReady() {
    super.onReady();
  }

  void sendCommand(String command) {
    if (_shell == null) {
      pty!.write(Uint8List.fromList(command.toUtf8()));
      pty!.write(Uint8List.fromList('\n'.toUtf8()));
      // _terminal.write(command);
      // _terminal.write('\r\n');
      // _terminal.keyInput(TerminalKey.enter);
    } else {
      _shell!.stdin.add(Uint8List.fromList(command.toUtf8()));
      _shell!.stdin.add(Uint8List.fromList('\n'.toUtf8()));
      // _shell.write(command.toUtf8());
    }
  }

  void onBack() {
    if (target == SgsTarget.local) {
      _currentStep = StepType.choose_target;
      _remoteHost = null;
    } else {
      _currentStep = StepType.connect_server;
    }
    _terminate();
    update();
  }

  void chooseTarget() {
    _currentStep = StepType.choose_target;
    _scriptParams.clear();
    update();
  }

  void confirmParams({
    required String serverHost,
    required int mysqlPort,
    required int apiPort,
    required int webPort,
    required String path,
  }) {
    _scriptParams = {
      'server_host': serverHost,
      'mysql_port': mysqlPort,
      'api_port': apiPort,
      'web_port': webPort,
      'data_path': path,
    };
    _sgsPath = _scriptParams['data_path'];
    _onNextStep(delay: false);
  }

  void _onNextStep({bool delay = true}) async {
    if (delay) await Future.delayed(Duration(milliseconds: 1000));
    if (_currentStep != StepType.install_finish) {
      _currentStep = StepType.values[_currentStep!.index + 1];
      _stepResponse[_currentStep!] = StepResponse();

      switch (_currentStep!) {
        case StepType.choose_target:
          break;
        case StepType.connect_server:
          break;
        case StepType.set_params:
          _loading?.call();
          //update() state to show widget
          break;
        case StepType.deploy_sgs:
          String cmd = getDeployScript(_scriptParams, _getSudoName());
          sendCommand(cmd);
          break;
        case StepType.install_finish:
          //add site to list
          // Future.delayed(Duration(milliseconds: 2500), () async {
          //   sendCommand('curl http://localhost:${_scriptParams['api_port']}/api/token/admin');
          // });
          if (_scriptParams['api_port'] != null) {
            var url = '${apiUrl}';
            var sites = await BaseStoreProvider.get().getSiteList();
            var cached = sites.where((s) => s.url == url);
            if (cached.length == 0) {
              BaseStoreProvider.get().addSite(SiteItem(url: url));
            }
          }
          break;
        default:
          break;
      }
      update();
    }
  }

  void clickLocalDevice() async {
    if (!(DeviceOS.isMacOS || DeviceOS.isLinux || DeviceOS.isWindows)) {
      showWarnNotification(title: Text('Sorry! SGS Server only support Linux, Macos, and Windows!'));
      return;
    }
    if (DeviceOS.isMacOS || DeviceOS.isWindows) {
      var result = await _showMacosDockerInstallTip();
      bool? _installed = result;
      if (_installed == null) return;
      if (!_installed) {
        var url = 'https://docs.docker.com/desktop/install/${DeviceOS.isMacOS ? 'mac-install' : 'windows-install'}/';
        PlatformAdapter.create().openBrowser(url);
        return;
      }
    }
    setNativeTarget();
  }

  void setNativeTarget() {
    target = SgsTarget.local;
    _currentStep = StepType.connect_server;
    _initNativeTerminal();
    update();
  }

  void setRemoteTarget() {
    target = SgsTarget.remote;
    // _currentStep = StepType.set_params;
    _currentStep = StepType.connect_server;
    update();
  }

  void _cancelLogin() {
    _terminate();
    _loading?.call();
    _loading = null;
  }

  void connectServer([host, port, name, pass]) async {
    _token = null;
    _loading?.call();
    _loading = BotToast.showCustomLoading(toastBuilder: (c) {
      return Container(
        decoration: BoxDecoration(
          color: Get.theme.dialogBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomSpin(color: Get.theme.colorScheme.primary, size: 30),
            SizedBox(height: 10),
            Text('Logging in to server!'),
            SizedBox(height: 10),
            IconButton(
              onPressed: _cancelLogin,
              icon: Icon(Icons.cancel),
              padding: EdgeInsets.zero,
              iconSize: 18,
              constraints: BoxConstraints.tightFor(width: 36, height: 36),
            ),
          ],
        ),
      );
    });
    _currentStep = StepType.connect_server;
    _stepResponse[StepType.connect_server] = StepResponse();

    _terminal = Terminal(
      onTitleChange: (t) {},
      onOutput: (s) {
        // print('on out: ${s}');
        _onResponse(s);
      },
    );
    _remoteHost = host;

    String? socketError;
    var socket = await SSHSocket.connect(host, port ?? 22).catchError((e) {
      socketError = e is SocketException ? '${e.message}, please check your host and port!' : e.toString();
    });

    if (socketError != null) {
      _loading?.call();
      showToast(text: socketError!, duration: Duration(seconds: 5));
      return;
    }

    _sshClient = SSHClient(
      socket,
      username: name,
      onPasswordRequest: () => pass,
      onAuthenticated: () {
        __remoteConnected();
      },
      printDebug: (debug) {
        // print('debug: $debug');
      },
      printTrace: (s) {
        // print('trace: $s');
        // if (s.contains('SSH_Message_Userauth_Failure')) {
        // }
      },
    );
    _sshClient!.authenticated.catchError((err) {
      // print('------:$err');
      _loading?.call();
      showToast(text: 'Auth Fail, Check username and password!', duration: Duration(seconds: 5));
    });
  }

  void _initNativeTerminal() {
    _remoteHost = null;
    _token = null;
    _currentStep = StepType.connect_server;
    _stepResponse[StepType.connect_server] = StepResponse();
    _terminal = Terminal();
    final (command, args) = _platformShell;
    pty = Pty.start(
      command,
      arguments: args,
      environment: {...Platform.environment},
      columns: _terminal!.viewWidth,
      rows: _terminal!.viewHeight,
    );
    pty!.output.listen((bytes) {
      var data = utf8.decode(bytes);
      _terminal?.write(data);
      _onResponse(data);
    });
    // pty.output.cast<List<int>>().transform(Utf8Decoder()).listen(_terminal.write);

    pty!.exitCode.then((code) {
      _terminal?.write('the process exited with exit code $code');
    });

    _terminal!.onOutput = (data) {
      // print('_terminal on out: ${data}');
      // _onResponse(data);
      pty!.write(const Utf8Encoder().convert(data));
    };

    _terminal!.onResize = (w, h, pw, ph) {
      pty!.resize(h, w);
    };
    Future.delayed(Duration(milliseconds: 2000)).then((s) {
      _onConnected();
    });
  }

  String get shell {
    if (Platform.isMacOS) {
      // return 'bash';
      return Platform.environment['SHELL'] ?? 'bash';
    } else if (Platform.isLinux) {
      return Platform.environment['SHELL'] ?? 'bash';
    } else if (Platform.isWindows) {
      return 'cmd.exe';
    }
    return 'sh';
  }

  (String command, List<String> args) get _platformShell {
    if (Platform.isMacOS) {
      final user = Platform.environment['USER'];
      return ('login', ['-fp', user!]);
    }

    if (Platform.isWindows) {
      return ('powershell.exe', []);
    }

    final shell = Platform.environment['SHELL'] ?? 'sh';
    return (shell, []);
  }

  void __remoteConnected() async {
    _shell = await _sshClient!.shell();

    _terminal!.onOutput = (data) {
      _shell!.write(utf8.encode(data));
    };
    // _shell.stdout.cast<List<int>>().transform(Utf8Decoder()).listen(_terminal.write);
    // _shell.stderr.cast<List<int>>().transform(Utf8Decoder()).listen(_terminal.write);

    _shell!.stdout.listen((list) {
      _terminal!.write(utf8.decode(list));
      _onResponse(utf8.decode(list));
    });
    _shell!.stderr.listen((list) {
      _terminal!.write(utf8.decode(list));
      _onResponse(utf8.decode(list));
    });

    _onConnected();
  }

  void _onConnected() {
    Future.delayed(Duration(milliseconds: 500), () async {
      // _loading?.call();
      sendCommand('cd && echo OS="\$(uname -s)"');
      // _onNextStep();
    });
  }

  void _onDisconnected([String? msg]) {
    _loading?.call();
    if (msg != null) {
      showToast(text: msg, duration: Duration(milliseconds: 4500));
    }
  }

  String? _targetOS;

  void _onResponse(String data) {
    data = data.replaceAll(r'[0;32m|', '').replaceAll(r'[0m', '');
    _stepResponse[_currentStep]!.add(data);

    if (_currentStep!.index > StepType.connect_server.index) {
      if (data.contains('[sudo] password for') || data.startsWith('Password:') || data.contains('的密码')) {
        _showRootPasswordForm();
        return;
      }
    }
    switch (_currentStep!) {
      case StepType.choose_target:
        break;
      case StepType.connect_server:
        if (data.startsWith('OS=')) {
          _targetOS = data.split('=')[1];
          // print('target os is :${_targetOS}');
          _onNextStep();
        } else if (data.split('OS=').length > 2) {
          _targetOS = data.split('OS=').reversed.first;
          // print('target os is :${_targetOS}');
          _onNextStep();
        }
        break;
      case StepType.set_params:
        break;
        //nothing
        break;
      // case StepType.check_permission:
      //   if (data.startsWith('USER_ID=') || data.split('USER_ID=').length > 2) {
      //     final uid = data.split('USER_ID=').reversed.first.trim();
      //     if ('${uid}' == '0') {
      //       _onNextStep();
      //     } else {
      //       _sendCommand('su');
      //       // _showRootPasswordForm();
      //     }
      //   }
      //   //
      //   else if (data.contains('Authentication failure')) {
      //     _sendCommand('su');
      //     // _showRootPasswordForm();
      //   } else if (data.contains('root@')) {
      //     // root authorized
      //     _onNextStep();
      //   } //
      //   break;
      case StepType.deploy_sgs:
        if (data.contains('3 incorrect password attempts')) {
          _currentStep = StepType.error;
          _stepResponse[_currentStep!] = StepResponse();
          error = "root password error";
          deployStatusMessage.value = error!;
          showToast(text: 'Password incorrect!', duration: Duration(seconds: 5));
          update();
        } else if (data.contains('Choose your option') || data.contains('Do you want to reinstall SGS?')) {
          _showConfirmForm();
        } else if (data.contains('SGS already running!') || data.contains('SGS started!')) {
          _onNextStep();
        } else if (data.contains('SGS_PATH=')) {
          _sgsPath = data.split('=').last.trim();
        } else if (data.contains('I: ')) {
          _title = data.split('I: ')[1];
          deployStatusMessage.value = _title!;
          update();
        }
        break;
      case StepType.install_finish:
        deployStatusMessage.value = "finish";
        if (data.contains('"token"')) {
          _token = data.trim();
          update();
        }
        break;
      case StepType.error:
        break;
    }
  }

  _showConfirmForm() async {
    var dialog = AlertDialog(
      title: Text('Confirm operation!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SGS is already installed, what do you want to do?', style: Get.textTheme.bodyLarge),
          SizedBox(height: 16),
          ListTile(
            title: Text('Update'),
            subtitle: Text('Update images and restart containers!'),
            textColor: Get.theme.colorScheme.primary,
            onTap: () => Navigator.of(Get.context!).pop('2'),
          ),
          Divider(thickness: 1, height: 1),
          ListTile(
            title: Text('Restart'),
            subtitle: Text('Just restart containers!'),
            textColor: Get.theme.colorScheme.primary,
            onTap: () => Navigator.of(Get.context!).pop('3'),
          ),
          Divider(thickness: 1, height: 1),
          ListTile(
            title: Text('Re install (be-careful)'),
            textColor: Colors.red,
            isThreeLine: true,
            subtitle: Text('Update images and create new containers!\nmysql data will be removed, data in api folder will keep!'),
            onTap: () => Navigator.of(Get.context!).pop('1'),
          ),
          Divider(thickness: 1, height: 1),
          ListTile(
            title: Text('Do nothing and go back!'),
            subtitle: Text('Nothing will be changed!'),
            onTap: () => Navigator.of(Get.context!).pop('n'),
          ),
        ],
      ),
    );
    var result = await showDialog(
      context: Get.context!,
      builder: (c) => dialog,
      barrierDismissible: false,
    );
    sendCommand(result ?? 'NO');
  }

  bool _rootAuthDialogShowing = false;

  void _showRootPasswordForm() async {
    if (_rootAuthDialogShowing) return;
    TextEditingController _controller = TextEditingController();
    var dialog = AlertDialog(
      actionsPadding: EdgeInsets.only(right: 20, bottom: 20),
      title: FastRichText(
        textStyle: Get.textTheme.bodyMedium!.copyWith(fontSize: 18, fontFamily: MONOSPACED_FONT),
        children: [
          TextSpan(text: 'Require '),
          TextSpan(text: 'root ', style: TextStyle(color: Theme.of(Get.context!).primaryColor, fontWeight: FontWeight.w900)),
          TextSpan(text: 'password!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AlertWidget.info(message: Text('Passwords are not stored, only used locally!')),
          SizedBox(height: 16),
          SizedBox(
            width: 300,
            child: PasswordField(
              controller: _controller,
              onSubmitted: (v) {
                if (_controller.text.length == 0) {
                  return;
                }
                Navigator.of(Get.context!).pop(_controller.text);
              },
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(Get.context!).pop(null);
          },
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_controller.text.length == 0) {
              return;
            }
            Navigator.of(Get.context!).pop(_controller.text);
          },
          child: Text('Authorize'),
        ),
      ],
    );
    _rootAuthDialogShowing = true;
    var result = await showDialog(context: Get.context!, builder: (c) => dialog, barrierDismissible: false);
    _rootAuthDialogShowing = false;
    if (result != null) {
      sendCommand(result);
    } else {
      _currentStep = StepType.error;
      _stepResponse[_currentStep!] = StepResponse();
      error = "canceled to input password";
      deployStatusMessage.value = error!;
      update();
    }
  }

  Future _showMacosDockerInstallTip() async {
    var dialog = AlertDialog(
      title: Text('Tips'),
      actionsPadding: EdgeInsets.only(bottom: 20, right: 20),
      content: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Make sure you are already installed Docker Desktop on your computer!',
          style: Get.textTheme.bodyLarge,
        ),
      ),
      actions: [
        ElevatedButton(
          child: Text('View Docker Install Doc'),
          style: ElevatedButton.styleFrom(foregroundColor: Colors.blueAccent),
          onPressed: () {
            Navigator.of(Get.context!).pop(false);
          },
        ),
        FilledButton(
          child: Text('Docker is Ready'),
          onPressed: () {
            Navigator.of(Get.context!).pop(true);
          },
        ),
      ],
    );
    return showDialog(context: Get.context!, builder: (c) => dialog);
  }

  void _terminate() {
    if (null != _sshClient) {
      _sshClient!.close();
    }
    _shell = null;
    _sshClient = null;
    _remoteHost = null;
    _token = null;
    _scriptParams.clear();

    if (pty != null) {
      pty!.kill();
      pty = null;
    }
    _terminal = null;
  }

  bool get targetIsMac {
    if (target == SgsTarget.local) {
      return DeviceOS.isMacOS;
    }
    return _targetOS!.contains('Mac') || _targetOS!.contains('Darwin');
  }

  String _getSudoName() {
    if (target == SgsTarget.local) {
      if (DeviceOS.isMacOS) return "sudo";
      return 'sudo';
    }
    if (_targetOS == null) return 'sudo';
    if (_targetOS!.contains('Mac') || _targetOS!.contains('Darwin')) {
      return 'sudo';
    }
    return 'sudo';
  }

  @override
  void onClose() {
    _terminate();
    super.onClose();
  }
}
