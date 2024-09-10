import 'dart:async';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';

class SSHTerminalBackend
// implements TerminalBackend
{
  SSHClient? client;

  String _host;
  String _username;
  String _password;

  VoidCallback? onConnected;
  Function? onDisConnected;
  ValueChanged<String>? onResponse;
  ValueChanged<String>? onAuthFail;

  Completer<int>? _exitCodeCompleter;
  StreamController<String>? _outStream;
  bool _closed = false;

  String? get host => _host;

  SSHTerminalBackend(
    this._host,
    this._username,
    this._password, {
    this.onConnected,
    this.onDisConnected,
    this.onResponse,
    this.onAuthFail,
  });

  void onWrite(String data) {
    if (_closed) {
      print('connection closed.');
      return;
    }
    _outStream!.sink.add(data);
  }

  @override
  Future<int> get exitCode => _exitCodeCompleter!.future;

  bool _connected = false;

  void _debugPrint(error) {
    print('debug: ${error}');
  }

  @override
  void init() async {
    _exitCodeCompleter = Completer<int>();
    _outStream = StreamController<String>();
    onWrite('connecting $_host...\n');
    Future.delayed(Duration(seconds: 15)).then((value) {
      if (_connected) return;
      onDisConnected?.call('Connect time out');
    });
    client = SSHClient(
      await SSHSocket.connect(_host, 22),
      username: _username,
      printDebug: _debugPrint,
      onPasswordRequest: () => _password,
      // getPassword: () => utf8.encode(_password),
      // response: (transport, data) {
      //   onWrite(data);
      //   onResponse?.call(data);
      // },
      onAuthenticated: () async {
        _connected = true;
        await Future.delayed(Duration(milliseconds: 800));
        // onWrite('connected.\n');
        // write('echo OS=\$(uname -s)\n');
        onConnected?.call();
      },

      // disconnected: () {
      //   _connected = false;
      //   onWrite('disconnected.\n');
      //   _outStream.close();
      //   onDisConnected?.call();
      // },
      printTrace: (trace) {
        print(trace);
        if (trace!.contains('MSG_USERAUTH_FAILURE') && trace.contains('useauthFail=1')) {
          onAuthFail?.call(trace);
        }
      },
    );
    final shell = await client!.shell();

    // _outStream.addStream(shell.stdout);
  }

  @override
  Stream<String> get out => _outStream!.stream;

  // @override
  // void resize(int width, int height, int pixelWidth, int pixelHeight) {
  //   client.setTerminalWindowSize(width, height);
  // }
  //
  // @override
  // void write(String input) {
  //   // user input
  //   client?.sendChannelData(utf8.encode(input));
  // }
  //
  // @override
  // void terminate() {
  //   client?.disconnect('terminate');
  // }
  //
  // @override
  // void ackProcessed() {
  //   // NOOP
  // }
}