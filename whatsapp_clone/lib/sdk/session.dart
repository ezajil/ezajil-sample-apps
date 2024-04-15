import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:whatsapp_clone/sdk/page_result.dart';
import 'package:whatsapp_clone/sdk/utils/http.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'transport.dart';
import 'chatroom.dart';
import 'token_manager.dart';

class Session {
  final String apiEndpoint;
  final String wsEndpoint;
  final User currentUser;
  final TokenManager tokenManager = TokenManager();
  late final Transport transport;
  final StreamController _controller = StreamController.broadcast();

  Session(String endpoint, this.currentUser, {bool enableLogging = false})
      : apiEndpoint = _formatEndpoint(endpoint, false),
        wsEndpoint = _formatEndpoint(endpoint, true) {
    transport = Transport(wsEndpoint: wsEndpoint);
  }

  static String _formatEndpoint(String endpoint, bool isWebSocket) {
    String cleanEndpoint = _removeProtocol(endpoint);
    bool isSsl = !cleanEndpoint.startsWith('localhost') &&
        !cleanEndpoint.startsWith('127.0.0.1');
    return isWebSocket
        ? (isSsl
            ? 'wss://$cleanEndpoint/chat/v1'
            : 'ws://$cleanEndpoint/chat/v1')
        : (isSsl ? 'https://$cleanEndpoint' : 'http://$cleanEndpoint');
  }

  static String _removeProtocol(String url) {
    return url.replaceAll(RegExp(r'^[a-zA-Z]+:\\/\\/'), '');
  }

  Stream<dynamic> on(String event) => _controller.stream
      .where((e) => e['event'] == event)
      .map((e) => e['data']);

  void setToken(String accessToken) {
    tokenManager.setToken(accessToken);
  }

  void setFetchTokenCallback(Future<String> Function() fetchToken) {
    tokenManager.setFetchTokenCallback(fetchToken);
  }

  void connect() {
    transport.connect();
    _bindTransportEvents();
  }

  void close() {
    transport.close();
  }

  void _bindTransportEvents() {
    transport.on('open').listen((_) => print('Connection opened'));
    transport.on('ready').listen((_) {
      print('Connection ready');
      _controller.add({'event': 'connected'});
    });
    transport.on('close').listen((data) {
      print(
          'Connection closed: ${data['reason']} (code: ${data['code']} - Client error: ${data['clientError']})');
      _controller.add({'event': 'disconnected', 'data': data});
    });
    transport.on('error').listen((event) {
      _controller.add({'event': 'error', 'data': event});
    });
    // Further events
  }

  Future<Chatroom> createSingleChatroom(
      String name, String participantId, Map<String, dynamic> metadata) async {
    try {
      http.Response response = await httpPost(
          '$apiEndpoint/api/v1/chatrooms/single',
          tokenManager.get,
          jsonEncode({
            'name': name,
            'participantId': participantId,
            'metadata': metadata
          }));
      Map<String, dynamic> data = jsonDecode(response.body);
      return Chatroom.fromJson(this, data);
    } catch (err) {
      throw Exception('Error creating chatroom: $err');
    }
  }

  Future<Chatroom> createGroupChatroom(String name, List<String> participantIds,
      Map<String, dynamic> metadata) async {
    try {
      var response = await httpPost(
          '$apiEndpoint/api/v1/chatrooms/group',
          tokenManager.get,
          jsonEncode({
            'name': name,
            'participantIds': participantIds,
            'metadata': metadata
          }));

      var data = jsonDecode(response.body);
      return Chatroom.fromJson(this, data);
    } catch (err) {
      throw Exception('Error creating group chatroom: $err');
    }
  }

  Future<PageResult<Chatroom>> getChatroom(String chatroomId) async {
    try {
      var response = await httpGet(
          '$apiEndpoint/api/v1/chatrooms/$chatroomId', tokenManager.get);

      var data = jsonDecode(response.body);
      List<Chatroom> chatrooms = (data['results'] as List)
          .map((result) => Chatroom.fromJson(this, result))
          .toList();
      return PageResult<Chatroom>(
        results: chatrooms,
        pagingState: data['pagingState'],
        totalResults: data['totalResults']
      );
    } catch (err) {
      throw Exception('Error fetching chatroom $chatroomId: $err');
    }
  }

  Future<PageResult<Chatroom>> getChatroomsOfUser(
      {String? pagingState, int? limit}) async {
    try {
      var queryParams = {
        'pagingState': pagingState,
        'limit': limit?.toString()
      };
      var response = await httpGet('$apiEndpoint/api/v1/chatrooms/latest',
          (refresh) => tokenManager.get(refresh), queryParams);

      var data = jsonDecode(response.body);
      var chatrooms = (data['results'] as List)
          .map((result) => Chatroom.fromJson(this, result))
          .toList();
      return PageResult<Chatroom>(
          results: chatrooms,
          pagingState: data['pagingState'],
          totalResults: data['totalResults']
      );
    } catch (err) {
      throw Exception('Error fetching user chatrooms: $err');
    }
  }

  Future<PageResult<Chatroom>> getSingleChatroomsOfUser(
      {String? pagingState, int? limit}) async {
    try {
      var queryParams = {
        'pagingState': pagingState,
        'limit': limit?.toString()
      };
      var response = await httpGet(
          '$apiEndpoint/api/v1/chatrooms/latest/single',
          (refresh) => tokenManager.get(refresh),
          queryParams);

      var data = jsonDecode(response.body);
      var chatrooms = (data['results'] as List)
          .map((result) => Chatroom.fromJson(this, result))
          .toList();
      return PageResult<Chatroom>(
          results: chatrooms,
          pagingState: data['pagingState'],
          totalResults: data['totalResults']
      );
    } catch (err) {
      throw Exception('Error fetching single chatrooms: $err');
    }
  }

  Future<PageResult<Chatroom>> getGroupChatroomsOfUser(
      {String? pagingState, int? limit}) async {
    try {
      var queryParams = {
        'pagingState': pagingState,
        'limit': limit?.toString()
      };
      var response = await httpGet('$apiEndpoint/api/v1/chatrooms/latest/group',
          (refresh) => tokenManager.get(refresh), queryParams);

      var data = jsonDecode(response.body);
      var chatrooms = (data['results'] as List)
          .map((result) => Chatroom.fromJson(this, result))
          .toList();
      return PageResult<Chatroom>(
          results: chatrooms,
          pagingState: data['pagingState'],
          totalResults: data['totalResults']
      );
    } catch (err) {
      throw Exception('Error fetching group chatrooms: $err');
    }
  }

  Future<List<User>> getUsers(List<String> userIds) async {
    try {
      final responseData = await httpPost('$apiEndpoint/api/v1/users/list',
          tokenManager.get, {'userIds': userIds});

      final List<dynamic> dataList = responseData as List<dynamic>;
      return dataList
          .map<User>((result) => User.fromJson(result as Map<String, dynamic>))
          .toList();
    } catch (err) {
      throw Exception('Error fetching users: $err');
    }
  }

  Future<List<User>> subscribeToUsersPresence(List<String> userIds) async {
    try {
      final response = await httpPost('$apiEndpoint/api/v1/users/subscribe',
          tokenManager.get, jsonEncode({'userIds': userIds}));
      final data = jsonDecode(response.body) as List;
      return data.map<User>((item) => User.fromJson(item)).toList();
    } catch (err) {
      throw Exception('Error subscribing to user presence: $err');
    }
  }

  Future<void> unsubscribeFromUsersPresence(List<String> userIds) async {
    try {
      await httpPost('$apiEndpoint/api/v1/users/unsubscribe', tokenManager.get,
          jsonEncode({'userIds': userIds}));
    } catch (err) {
      throw Exception('Error unsubscribing from user presence: $err');
    }
  }

  Future<void> unsubscribeFromAllUsersPresence() async {
    try {
      await httpPost('$apiEndpoint/api/v1/users/unsubscribe-all',
          tokenManager.get, jsonEncode({}));
    } catch (err) {
      throw Exception('Error unsubscribing from all user presences: $err');
    }
  }

  void fireUserTyping(String chatroomId) {
    transport.send({
      'event': 'user-typing',
      'payload': {
        'chatroomId': chatroomId,
        ...currentUser.toJson() // Ensure User has a toJson method
      }
    });
  }

  void markMessageAsDelivered(String chatroomId, int latestMessageDelivered) {
    transport.send({
      'event': 'messages-delivered',
      'payload': {
        'chatroomId': chatroomId,
        'latestMessageDelivered': latestMessageDelivered
      }
    });
  }

  void markMessageAsRead(String chatroomId, int latestMessage) {
    transport.send({
      'event': 'messages-read',
      'payload': {'chatroomId': chatroomId, 'latestMessageRead': latestMessage}
    });
  }
}
