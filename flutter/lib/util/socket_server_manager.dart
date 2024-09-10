
import 'package:socket_io/socket_io.dart';

class SocketServerManager {
  static SocketServerManager _instance = SocketServerManager._init();

  Server? _socket;
  Socket? _client;
  String? _lastData;

  factory SocketServerManager() {
    return _instance;
  }

  SocketServerManager._init() {}

  bool isClientConnected() {
    return _client?.connected ?? false;
  }

  startServer() {
    if (_socket != null) return;
    _socket = Server(server: 9898);
    var nsp = _socket!.of('/sgs');
    nsp
      ..on('connect', (client) {
        _client = client;
        print('client: ${client.featureId} connected');
        if (null != _lastData) {
          _client!.emit('data', _lastData);
        }
      })
      ..on('error', (data) {
        print('error: $data');
      })
      ..on('msg', (data) {
        print('msg: $data');
      })
      ..on('disconnect', (data) {
        _client = null;
        print('disconnect: $data');
      });
  }

  void sendEvent(String event, String data) {
    if (null == _socket || null == _client) return;
    if (_client!.connected) {
      _client!.emit(event, data);
    }
  }

  void sendData(String data) {
    _lastData = data;
    if (null == _socket) {
      startServer();
    } else if (_client != null) {
      if (_client!.connected) {
        _client!.emit('data', data);
      } else {
        print('${_client!.id} is disconnected');
      }
    }
  }

  dispose() {
    _socket?.close();
  }
}