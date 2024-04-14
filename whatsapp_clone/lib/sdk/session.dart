import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:whatsapp_clone/sdk/page_result.dart';
import 'transport.dart';  // Assuming Transport class is converted to Dart
import 'user.dart';       // Assuming User class is converted to Dart
import 'chatroom.dart';   // Assuming Chatroom class is converted to Dart
import 'token_manager.dart';  // Assuming TokenManager class is converted to Dart

class Session {
  String apiEndpoint;
  String wsEndpoint;
  User currentUser;
  TokenManager tokenManager;
  Transport transport;
  StreamController _controller = StreamController.broadcast();

  Session(String endpoint, this.currentUser, {bool enableLogging = false}) {
    endpoint = _removeProtocol(endpoint);
    bool isSsl = !endpoint.startsWith('localhost') && !endpoint.startsWith('127.0.0.1');
    apiEndpoint = isSsl ? 'https://$endpoint' : 'http://$endpoint';
    wsEndpoint = isSsl ? 'wss://$endpoint/chat/v1' : 'ws://$endpoint/chat/v1';
    tokenManager = TokenManager();
    transport = Transport(this);  // Assuming dependencies are adjusted for Dart
  }

  Stream<dynamic> on(String event) => _controller.stream.where((e) => e['event'] == event).map((e) => e['data']);

  void setToken(String accessToken) {
    tokenManager.setToken(accessToken);
  }

  void setFetchTokenCallback(Future<String> Function() fetchToken) {
    tokenManager.setFetchTokenCallback(fetchToken);
  }

  String _removeProtocol(String url) {
    return url.replaceAll(RegExp(r'^[a-zA-Z]+:\/\/'), '');
  }

  void connect() {
    transport.connect();
    _bindTransportEvents();
  }

  void close() {
    transport.close();
  }

  void _bindTransportEvents() {
    // Assuming Transport emits events via StreamController, listen here and forward
    transport.on('open').listen((_) => print('Connection opened'));
    transport.on('ready').listen((_) {
      print('Connection ready');
      _controller.add({'event': 'connected'});
    });
    transport.on('close').listen((data) {
      print('Connection closed: ${data['reason']} (code: ${data['code']} - Client error: ${data['clientError']})');
      _controller.add({'event': 'disconnected', 'data': data});
    });
    transport.on('error').listen((event) {
      _controller.add({'event': 'error', 'data': event});
    });
    // Further events
  }

  Future<void> createSingleChatroom(String name, String participantId, Map<String, dynamic> metadata) async {
    String body = jsonEncode({ 'name': name, 'participantId': participantId, 'metadata': metadata });
    http.Response response = await http.post(Uri.parse('$apiEndpoint/api/v1/chatrooms/single'),
        headers: {
          'Authorization': 'Bearer ${await tokenManager.get()}',
          'Content-Type': 'application/json'
        },
        body: body
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return Chatroom(this, data['chatroomId'], data['name'], data['latestMessage'],
          data['creationDate'], data['creatorId'], data['single'], data['users'], data['metadata']);
    } else {
      throw Exception('Failed to create chatroom');
    }
  }

  Future<Chatroom> createGroupChatroom(String name, List<String> participantIds, Map<String, dynamic> metadata) async {
    var body = jsonEncode({'name': name, 'participantIds': participantIds, 'metadata': metadata});
    var url = Uri.parse('$apiEndpoint/api/v1/chatrooms/group');
    var token = await tokenManager.get(true);  // Assuming refresh is always true for simplicity
    var response = await http.post(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    }, body: body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return Chatroom.fromJson(data);
    } else {
      throw Exception('Failed to create group chatroom: ${response.body}');
    }
  }

  Future<Chatroom> getChatroom(String chatroomId) async {
    var url = Uri.parse('$apiEndpoint/api/v1/chatrooms/$chatroomId');
    var token = await tokenManager.get();
    var response = await http.get(url, headers: {
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return Chatroom.fromJson(data);
    } else {
      throw Exception('Failed to fetch chatroom: ${response.body}');
    }
  }

  Future<PageResult<Chatroom>> getChatroomsOfUser({String? pagingState, int? limit}) async {
    var queryParams = {'pagingState': pagingState, 'limit': limit?.toString()};
    var url = Uri.parse('$apiEndpoint/api/v1/chatrooms/latest').replace(queryParameters: queryParams);
    var token = await tokenManager.get();
    var response = await http.get(url, headers: {
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var chatrooms = (data['results'] as List).map((result) => Chatroom.fromJson(result)).toList();
      return PageResult<Chatroom>(chatrooms, data['pagingState'], data['totalResults']);
    } else {
      throw Exception('Failed to fetch chatrooms: ${response.body}');
    }
  }


}
