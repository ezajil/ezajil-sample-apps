import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:whatsapp_clone/sdk/token_manager.dart';

class Transport {
  WebSocket? _conn;
  final String wsEndpoint;
  final TokenManager tokenManager = TokenManager();
  ConnectionState connectionState = ConnectionState.disconnected;
  final StreamController _controller = StreamController.broadcast();
  Timer? _pingTimeoutId;
  Timer? _reconnectId;
  int pingInterval = 10000;
  int maxReconnectInterval = 30000;
  int reconnectExponentialBackoff = 2;
  int? reconnectAttempts;

  Transport({required this.wsEndpoint});

  Stream<dynamic> on(String event) => _controller.stream
      .where((e) => e['event'] == event)
      .map((e) => e['data']);

  Future<void> connect([bool forceTokenRefresh = false]) async {
    if (connectionState != ConnectionState.disconnected) {
      print('Skip connect. Already connecting or connected');
      return;
    }
    connectionState = ConnectionState.connecting;

    try {
      var accessToken = await tokenManager.get(forceTokenRefresh);
      _conn = await WebSocket.connect(wsEndpoint, protocols: [accessToken]);
      _bindWsEvents();
      connectionState = ConnectionState.connected;
      _controller.add({'event': 'open'});
    } catch (error) {
      connectionState = ConnectionState.disconnected;
      _handleConnectionError(error);
    }
  }

  void _handleConnectionError(Object error) {
    print('Connection error: $error');
    connectionState = ConnectionState.disconnected;
    // Emitting an error event to be handled by listeners
    _controller.add({'event': 'error', 'data': error.toString()});

    // Depending on the error, you might want to reconnect or handle it differently
    if (error is WebSocketException) {
      _reconnect(); // Try reconnecting
    } else {
      // If the error is not recoverable immediately, emit a close event
      _controller.add({
        'event': 'close',
        'data': {'code': 1006, 'reason': error.toString(), 'clientError': false}
      });
    }
  }

  void _bindWsEvents() {
    _conn?.listen(
      (data) {
        _onMessage(data);
      },
      onDone: () {
        _onClose();
      },
      onError: (error) {
        _onError(error);
      },
      cancelOnError: true,
    );
  }

  void _onMessage(String data) {
    try {
      var parsed = json.decode(data);
      _controller.add({'event': parsed['event'], 'data': parsed['payload']});
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  void _onClose() {
    if (_conn?.closeCode != null) {
      var isClientError = [4000, 4001, 4004, 4006].contains(_conn?.closeCode);
      _controller.add({
        'event': 'close',
        'data': {
          'code': _conn?.closeCode,
          'reason': _conn?.closeReason,
          'clientError': isClientError
        }
      });
    }
    connectionState = ConnectionState.disconnected;
    _reconnect();
  }

  void _onError(Object error) {
    _controller.add({'event': 'error', 'data': error});
    connectionState = ConnectionState.disconnected;
    _reconnect();
  }

  void send(dynamic data) {
    try {
      _conn?.add(jsonEncode(data));
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void _reconnect() {
    if (connectionState != ConnectionState.disconnected) {
      print('Reconnect called when not in a disconnected state');
      return;
    }

    final int reconnectInterval = min(
        (reconnectAttempts ?? 0) * reconnectExponentialBackoff * 1000,
        maxReconnectInterval);

    print(
        'Reconnect attempt ${reconnectAttempts ?? 0}, retry after $reconnectInterval ms');
    reconnectAttempts = (reconnectAttempts ?? 0) + 1;

    // Schedule reconnect
    _reconnectId = Timer(Duration(milliseconds: reconnectInterval), () {
      connect(true); // Force token refresh on reconnect
    });
  }

  void close() {
    _conn?.close();
  }
}

enum ConnectionState { connecting, connected, disconnected }
